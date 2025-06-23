function Import-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/import-vcintuneapplication/")]
    [OutputType([System.String])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        # IntuneWin32App currently supports Windows PowerShell only
        if (Test-PSCore) {
            $Msg = "We can't load the IntuneWin32App module on PowerShell Core. Please use PowerShell 5.1."
            throw [System.TypeLoadException]::New($Msg)
        }

        # Test for required variables
        $Modules = "IntuneWin32App"
        foreach ($Module in $Modules) {
            if (Get-Module -Name $Module -ListAvailable -ErrorAction "SilentlyContinue") {
                Write-Verbose -Message "Support module installed: $Module."
            }
            else {
                $Msg = "Required module missing: $Module."
                throw [System.TypeLoadException]::New($Msg)
            }
        }

        # Test for authentication token
        if ($null -eq $Global:AccessToken) {
            $Msg = "Microsoft Graph API access token missing. Authenticate to the Graph API with Connect-MSIntuneGraph."
            throw [System.UnauthorizedAccessException]::New($Msg)
        }

        # Get the Intune app manifest
        $IntuneManifest = Get-Content -Path $(Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Intune.json") | ConvertFrom-Json -ErrorAction "Stop"
        Write-Verbose -Message "Loaded Intune app manifest."

        # Create the icon object for the app
        $IconPath = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "img", "vcredist.png")
        if (Test-Path -Path $IconPath) {
            Write-Verbose -Message "Using icon image from path: $IconPath."
            $Icon = New-IntuneWin32AppIcon -FilePath $IconPath
        }
        else {
            Write-Error -Message "Unable to find icon image in path: $IconPath."
        }
    }

    process {
        # Make sure that $VcList has the required properties
        if ((Test-VcListObject -VcList $VcList) -ne $true) {
            $Msg = "Required properties not found. Please ensure the output from Save-VcRedist is sent to this function. "
            throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
        }

        foreach ($VcRedist in $VcList) {

            # Check if the package already exists in Intune
            $AppDetails = Get-VcRedistFromIntune -VcList $VcRedist
            if ($null -eq $AppDetails -or $AppDetails.UpdateRequired -eq $true) {

                # Package MSI as .intunewin file
                $OutputFolder = New-TemporaryFolder
                $params = @{
                    SourceFolder = $(Split-Path -Path $VcRedist.Path -Parent)
                    SetupFile    = $(Split-Path -Path $VcRedist.Path -Leaf)
                    OutputFolder = $OutputFolder
                }
                $Package = New-IntuneWin32AppPackage @params
                Write-Verbose -Message "Created IntuneWin package: $($Package.Path)."

                # Requirement rule
                switch ($VcRedist.Architecture) {
                    "x86" { $Architecture = "All" }
                    "x64" { $Architecture = "x64" }
                    default {
                        $Architecture = "All"
                        continue
                    }
                }
                $params = @{
                    Architecture                   = $Architecture
                    MinimumSupportedWindowsRelease = $IntuneManifest.RequirementRule.MinimumRequiredOperatingSystem
                    MinimumFreeDiskSpaceInMB       = $IntuneManifest.RequirementRule.SizeInMBValue
                }
                $RequirementRule = New-IntuneWin32AppRequirementRule @params

                # Detection rule
                if ($VcRedist.UninstallKey -eq "32") { $Check32BitOn64System = $true } else { $Check32BitOn64System = $false }
                $DetectionRuleArgs = @{
                    "Existence"            = $true
                    "KeyPath"              = $IntuneManifest.DetectionRule.KeyPath -replace "{guid}", $VcRedist.ProductCode
                    "DetectionType"        = $IntuneManifest.DetectionRule.DetectionType
                    "Check32BitOn64System" = $Check32BitOn64System
                }
                $DetectionRule = New-IntuneWin32AppDetectionRuleRegistry @DetectionRuleArgs

                # Construct a table of default parameters for Win32 app
                $DisplayName = "$($IntuneManifest.Information.Publisher) $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)"
                Write-Verbose -Message "Creating Win32 app for $DisplayName."

                # Create a Notes property with identifying information
                $Notes = [PSCustomObject] @{
                    "CreatedBy" = "VcRedist"
                    "Guid"      = $VcRedist.PackageId
                    "Date"      = $(Get-Date -Format "yyyy-MM-dd")
                } | ConvertTo-Json -Compress

                $Win32AppArgs = @{
                    "FilePath"                 = $Package.Path
                    "DisplayName"              = $DisplayName
                    "Description"              = "$($IntuneManifest.Information.Description). $DisplayName"
                    "AppVersion"               = $VcRedist.Version
                    "Notes"                    = $Notes
                    "Publisher"                = $IntuneManifest.Information.Publisher
                    "InformationURL"           = $IntuneManifest.Information.InformationURL
                    "PrivacyURL"               = $IntuneManifest.Information.PrivacyURL
                    "CompanyPortalFeaturedApp" = $false
                    "InstallExperience"        = $IntuneManifest.Program.InstallExperience
                    "RestartBehavior"          = $IntuneManifest.Program.DeviceRestartBehavior
                    "DetectionRule"            = $DetectionRule
                    "RequirementRule"          = $RequirementRule
                    "InstallCommandLine"       = "$(Split-Path -Path $VcRedist.URI -Leaf) $($VcRedist.SilentInstall)"
                    "UninstallCommandLine"     = $VcRedist.SilentUninstall
                }
                if ($null -ne $Icon) {
                    $Win32AppArgs.Add("Icon", $Icon)
                }
                $Application = Add-IntuneWin32App @Win32AppArgs
                if ($null -ne $Application) {
                    # Exclude the largeIcon property from the output
                    $Application | Select-Object -Property * -ExcludeProperty "largeIcon" | Write-Output
                }

                # Clean up the temporary intunewin package
                Write-Verbose -Message "Removing temporary output folder: $OutputFolder."
                Remove-Item -Path $OutputFolder -Recurse -Force -ErrorAction "SilentlyContinue"
            }
            else {
                Write-Verbose -Message "No update required for $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)."
            }
        }
    }
}
