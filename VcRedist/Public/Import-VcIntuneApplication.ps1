function Import-VcIntuneApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://vcredist.com/import-vcintuneapplication/")]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList
    )

    begin {
        # IntuneWin32App currently supports Windows PowerShell only
        if (Test-PSCore) {
            throw "This function requires Windows PowerShell."
        }

        # Test for required variables
        $Modules = "IntuneWin32App"
        foreach ($Module in $Modules) {
            if (Get-Module -Name $Module -ListAvailable -ErrorAction "SilentlyContinue") {
                Write-Verbose -Message "Support module installed: $Module."
            }
            else {
                throw "Required module missing: $Module."
            }
        }

        # Test for authentication token
        if ($Null -eq $Global:AccessToken) {
            throw "Microsoft Graph API access token missing. Authenticate to the Graph API with Connect-MSIntuneGraph."
        }

        # Get the Intune app manifest
        try {
            #$Strings = $(Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VcRedist.json") | ConvertFrom-Json
            $IntuneManifest = Get-Content -Path $(Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "Intune.json") | ConvertFrom-Json
        }
        catch {
            throw $_.Exception.Message
        }

        # Create the icon object for the app
        $IconPath = [System.IO.Path]::Combine($MyInvocation.MyCommand.Module.ModuleBase, "img", "vcredist.png")
        if (Test-Path -Path $IconPath -ErrorAction "SilentlyContinue") {
            $Icon = New-IntuneWin32AppIcon -FilePath $IconPath
        }
        else {
            Write-Error -Message "Unable to find icon image in path: $IconPath."
        }
    }

    process {
        foreach ($VcRedist in $VcList) {

            # Package MSI as .intunewin file
            try {
                $SourceFolder = $(Split-Path -Path $VcRedist.Path -Parent)
                $SetupFile = $(Split-Path -Path $VcRedist.Path -Leaf)
                $OutputFolder = New-TemporaryFolder
                $params = @{
                    SourceFolder = $SourceFolder
                    SetupFile    = $SetupFile
                    OutputFolder = $OutputFolder
                }
                $Package = New-IntuneWin32AppPackage @params
            }
            catch {
                throw "Failed to create an Intune package for: $($VcRedist.Path)."
            }

            # Requirement rule
            if ($VcRedist.Architecture -eq "x86") { $Architecture = "All" } else { $Architecture = "x64" }
            $params = @{
                Architecture                    = $Architecture
                MinimumSupportedOperatingSystem = $IntuneManifest.RequirementRule.MinimumRequiredOperatingSystem
                MinimumFreeDiskSpaceInMB        = $IntuneManifest.RequirementRule.SizeInMBValue
            }
            $RequirementRule = New-IntuneWin32AppRequirementRule @params

            # Detection rule
            if ($VcRedist.UninstallKey -eq "32") { $Check32BitOn64System = $True } else { $Check32BitOn64System = $False }
            $DetectionRuleArgs = @{
                "Existence"            = $true
                "KeyPath"              = $IntuneManifest.DetectionRule.KeyPath -replace "{guid}", $VcRedist.ProductCode
                "DetectionType"        = $IntuneManifest.DetectionRule.DetectionType
                "Check32BitOn64System" = $Check32BitOn64System
            }
            $DetectionRule = New-IntuneWin32AppDetectionRuleRegistry @DetectionRuleArgs

            # Construct a table of default parameters for Win32 app
            try {
                $DisplayName = "$($IntuneManifest.Information.Publisher) $($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)"
                $Win32AppArgs = @{
                    "FilePath"                 = $Package.Path
                    "DisplayName"              = $DisplayName
                    "Description"              = "$($IntuneManifest.Information.Description). $DisplayName"
                    "AppVersion"               = $VcRedist.Version
                    "Notes"                    = "Package created with VcRedist on $(Get-Date -Format "yyyy-MM-dd"), https://vcredist.com."
                    "Publisher"                = $IntuneManifest.Information.Publisher
                    "InformationURL"           = $IntuneManifest.Information.InformationURL
                    "PrivacyURL"               = $IntuneManifest.Information.PrivacyURL
                    "CompanyPortalFeaturedApp" = $false
                    "InstallExperience"        = $IntuneManifest.Program.InstallExperience
                    "RestartBehavior"          = $IntuneManifest.Program.DeviceRestartBehavior
                    "DetectionRule"            = $DetectionRule
                    "RequirementRule"          = $RequirementRule
                    "InstallCommandLine"       = "$(Split-Path -Path $VcRedist.Download -Leaf) $($VcRedist.SilentInstall)"
                    "UninstallCommandLine"     = $VcRedist.SilentUninstall
                    "Verbose"                  = $true
                }
                if ($Null -ne $Icon) {
                    $Win32AppArgs.Add("Icon", $Icon)
                }
                $Application = Add-IntuneWin32App @Win32AppArgs
            }
            catch {
                throw $_
            }
            if ($Null -ne $Application) {
                Write-Output -InputObject $Application
            }

            # Clean up the temporary intunewin package
            try {
                Remove-Item -Path $OutputFolder -Recurse -Force
            }
            catch {
                Write-Error -Message $_.Exception.Message
            }
        }
    }
}
