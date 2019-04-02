Function Update-VcMdtApplication {
    <#
        .SYNOPSIS
            Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

        .DESCRIPTION
            Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes properties such as target Silent command line, Platform and Uninstall key.

            Use Get-VcList and Get-VcRedist to download the Redistributables and create the array for importing into MDT.

        .OUTPUTS
            System.Array

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/vcredist/usage/importing-into-mdt

        .PARAMETER VcList
            An array containing details of the Visual C++ Redistributables from Get-VcList.

        .PARAMETER Path
            A folder containing the downloaded Visual C++ Redistributables.

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to import into MDT.

        .PARAMETER Architecture
            Specifies the processor architecture to import into MDT. Can be x86 or x64.

        .PARAMETER MdtPath
            The local or network path to the MDT deployment share.

        .PARAMETER Silent
            Add a completely silent command line install of the VcRedist with no UI. The default install is passive.

        .EXAMPLE
            Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -Path C:\Temp\VcRedist -MdtPath \\server\deployment

            Description:
            Retrieves the list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the MDT deployment share at \\server\deployment.

        .EXAMPLE
            $VcList = Get-VcList -ExportAll
            Get-VcRedist -VcList $VcList -Path C:\Temp\VcRedist
            Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle

            Description:
            Retrieves the list of supported and unsupported Visual C++ Redistributables in the variable $VcList, downloads them to C:\Temp\VcRedist, imports each Redistributable into the MDT deployment share at \\server\deployment and creates an application bundle.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/vcredist/usage/importing-into-mdt")]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSCustomObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $True)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $MdtPath,

        [Parameter(Mandatory = $False)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [string] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False)]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017', '2019')]
        [string[]] $Release = @("2008", "2010", "2012", "2013", "2019"),

        [Parameter(Mandatory = $False)]
        [ValidateSet('x86', 'x64')]
        [string[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False)]
        [switch] $Silent,

        [Parameter(Mandatory = $False)]
        [switch] $Force,

        [Parameter()][string] $MdtDrive = "DS001",
        [Parameter()][string] $Publisher = "Microsoft",
        [Parameter()][string] $BundleName = "Visual C++ Redistributables",
        [Parameter()][string] $Language = "en-US"
    )

    Begin {
        # If running on PowerShell Core, error and exit.
        If (Test-PSCore) {
            Write-Error -Message "PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module." -ErrorAction Stop
            Break
        }

        # Import the MDT module and create a PS drive to MdtPath
        If (Import-MdtModule) {
            If ($pscmdlet.ShouldProcess($Path, "Mapping")) {
                New-MdtDrive -Drive $MdtDrive -Path $MdtPath -ErrorAction SilentlyContinue
                Restore-MDTPersistentDrive -Force | Out-Null
            }
        }
        Else {
            Write-Error -Message "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again." -ErrorAction Stop
            Break
        }

        # Create the Application folder
        If ($AppFolder.Length -gt 0) {
            New-MdtApplicationFolder -Drive $MdtDrive -Name $AppFolder -Description $("$Publisher $BundleName")
            $target = "$($MdtDrive):\Applications\$AppFolder"
        }
        Else {
            $target = "$($MdtDrive):\Applications"
        }
        Write-Verbose -Message "Importing applications into $target"

        # Filter release and architecture
        Write-Verbose -Message "Filtering releases for platform and architecture."
        $filteredVcList = $VcList | Where-Object { $Release -contains $_.Release } | Where-Object { $Architecture -contains $_.Architecture }

        try {
            Write-Verbose -Message "Getting existing Visual C++ Redistributables the deployment share"
            $existingVcRedists = Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" }
        }
        catch {
            Throw "Failed when returning existing VcRedist packages."
        }
    }

    Process {
        ForEach ($Vc in $filteredVcList) {
            # Set variables
            $supportedPlatform = If ($Vc.Architecture -eq "x86") {
                @("All x86 Windows 7 and Newer", "All x64 Windows 7 and Newer")
            }
            Else { "All x64 Windows 7 and Newer" }
            $vcName = "$Publisher $($Vc.Name) $($Vc.Architecture)"

            # Check for existing application by matching current VcRedist
            Write-Verbose -Message "Matching for $VcName"
            $vcMatched = $existingVcRedists | Where-Object { $_.Name -eq $VcName  }

            # Each scenario accounted for here for clarity 
            If (($vcMatched.UninstallKey -ne $Vc.ProductCode) -or $Force.IsPresent) {
                # Remove if ProductKey does not match or the -Force parameter is specified
                If ($PSCmdlet.ShouldProcess($vcMatched.Name, "Remove app")) {
                    Remove-Item -Path $("$target\$($vcMatched.Name)") -Force
                    $updateApp = $True
                }
            }
            ElseIf ($vcMatched.UninstallKey -eq $Vc.ProductCode) {
                # Existing VcRedist matches
                Write-Verbose -Message "Found: $VcName"
                $updateApp = $False
            }
            ElseIf ($Null -eq $vcMatched) {
                # No existing VcRedist
                Write-Verbose -Message "Not found: $VcName"
                $updateApp = $True
            }
            Else {
                # If all else fails avoid errors when attempting to import app
                Write-Verbose -Message "Taking the safe route"
                $updateApp = $False
            }

            # Import as an application into the MDT deployment share
            If ($updateApp) {
                If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $MdtPath", "Import app")) {
                    try {
                        # Splat the Import-MDTApplication arguments
                        $importMDTAppParams = @{
                            Path                  = $target
                            Name                  = $vcName
                            Enable                = $True
                            Reboot                = $False
                            Hide                  = $(If ($Bundle) { "True" } Else { "False" })
                            Comments              = "Generated by $($MyInvocation.MyCommand)"
                            ShortName             = "$($Vc.Name) $($Vc.Architecture)"
                            Version               = $Vc.Release
                            Publisher             = $Publisher
                            Language              = $Language
                            CommandLine           = ".\$(Split-Path -Path $Vc.Download -Leaf) $(If($Silent) { $vc.SilentInstall } Else { $vc.Install })"
                            WorkingDirectory      = ".\Applications\$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                            ApplicationSourcePath = "$(Get-ValidPath $Path)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                            DestinationFolder     = "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                            UninstallKey          = $Vc.ProductCode
                            SupportedPlatform     = $supportedPlatform
                            Dependency            = ""
                        }
                        Import-MDTApplication @importMDTAppParams
                    }
                    catch {
                        Throw "Error encountered importing the application - $($Vc.Name) $($Vc.Architecture)."
                    }
                }
            }
        }
    }

    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        Write-Verbose -Message "Getting Visual C++ Redistributables from the deployment share"
        $importedVcRedists = Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" }

        # Return list of apps to the pipeline
        Write-Output $importedVcRedists
    }
}
