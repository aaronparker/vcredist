Function Import-VcCmApp {
    <#
    .SYNOPSIS
        Creates Visual C++ Redistributable applications in a ConfigMgr site.

    .DESCRIPTION
        Creates an application in a Configuration Manager site for each Visual C++ Redistributable and includes setting whether the Redistributable can run on 32-bit or 64-bit Windows and the Uninstall key for detecting whether the Redistributable is installed.

        Use Get-VcList and Get-VcRedist to download the Redistributable and create the array of Redistributables for importing into ConfigMgr.
    
    .NOTES
        Name: Import-VcCmApp
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://stealthpuppy.com

    .PARAMETER VcList
        An array containing details of the Visual C++ Redistributables from Get-VcList.

    .PARAMETER Path
        A folder containing the downloaded Visual C++ Redistributables.

    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.

    .PARAMETER Architecture
        Specifies the processor architecture to download or install.

    .PARAMETER SMSSiteCode
        Specify the Site Code for ConfigMgr app creation.

    .PARAMETER CMPath
        Specify a UNC path where the Visual C++ Redistributables will be distributed from

    .EXAMPLE

#>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [array]$VcList,

        [Parameter(Mandatory = $True, Position = 1, HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript( {If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path,

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]]$Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]]$Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $True, HelpMessage = "Specify ConfigMgr Site Code.")]
        [ValidateScript( { If ($_ -match "^[a-zA-Z0-9]{3}$") { $True } Else { Throw "$_ is not a valid ConfigMgr site code." } })]
        [string]$SMSSiteCode,

        [Parameter(Mandatory = $True, HelpMessage = "Specify the ConfigMgr UNC path.")]
        [string]$CMPath,

        [Parameter()]$Publisher = "Microsoft",
        [Parameter()]$Language = "en-US"
    )
    Begin {        
        # CMPath will be the network location for copying the Visual C++ Redistributables to
        If (!([bool]([System.Uri]$CMPath).IsUnc)) { Throw "$CMPath must be a valid UNC path." }
        If (!(Test-Path $CMPath)) { Throw "Unable to confirm $CMPath exists. Please check that $CMPath is valid." }

        # If the ConfigMgr console is installed, load the PowerShell module; Requires PowerShell module to be installed
        If (Test-Path $env:SMS_ADMIN_UI_PATH) {
            Try {            
                Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module
            }
            Catch {
                Throw "Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed."
            }
        }
        Else {
            Throw "Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr Console and PowerShell module installed?"
        }
    }
    Process {
        # Filter release and architecture if specified
        If ($PSBoundParameters.ContainsKey('Release')) {
            Write-Verbose "Filtering releases for platform."
            $VcList = $VcList | Where-Object { $_.Release -eq $Release }
        }
        If ($PSBoundParameters.ContainsKey('Architecture')) {
            Write-Verbose "Filtering releases for architecture."
            $VcList = $VcList | Where-Object { $_.Architecture -eq $Architecture }
        }

        ForEach ($Vc in $VcList) {
            Write-Verbose "Importing app: [$($Vc.Name)][$($Vc.Release)][$($Vc.Architecture)]"

            # Import as an application into ConfigMgr
            If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $CMPath", "Import ConfigMgr app")) {

                # Configure parameters
                $Target = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                $Filename = Split-Path -Path $Vc.Download -Leaf
                $Dir = "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                $SupportedPlatform = If ($Vc.Architecture -eq "x86") { "All x86 Windows 7 and Newer" } `
                    Else { @("All x64 Windows 7 and Newer", "All x86 Windows 7 and Newer") }

                # Ensure the current folder is saved
                Push-Location -StackName FileSystem
                Try {
                    If ($pscmdlet.ShouldProcess($SMSSiteCode + ":", "Set location")) {
                        
                        # Set location to the PSDrive for the ConfigMgr site
                        Set-Location ($SMSSiteCode + ":") -ErrorVariable ConnectionError
                    }
                }
                Catch {
                    $ConnectionError
                }
                Try {
                    # Create the ConfigMgr application with properties from the XML file
                    If ($pscmdlet.ShouldProcess($Vc.Name + " $(Vc.Architecture)", "Creating ConfigMgr application")) {
                        $App = New-CMApplication -Name ($Vc.Name + " $(Vc.Architecture)") -ErrorVariable CMError -Publisher $Publisher
                        Add-CMScriptDeploymentType -InputObject $App `
                            -InstallCommand "$Filename $($Vc.Install)" `
                            -ContentLocation $Target `
                            -ProductCode $Vc.ProductCode `
                            -DeploymentTypeName ("SCRIPT_" + $Vc.Name) `
                            -UserInteractionMode Hidden `
                            -UninstallCommand "msiexec /x $($Vc.ProductCode) /qn-" `
                            -LogonRequirementType WhetherOrNotUserLoggedOn `
                            -InstallationBehaviorType InstallForSystem `
                            -ErrorVariable CMError `
                            -Comment "Generated by $($MyInvocation.MyCommand.Name)"
                    }
                }
                Catch {
                    $CMError
                }
                # Go back to the original folder
                Pop-Location -StackName FileSystem
            }
        }
    }
    End {
    }
}