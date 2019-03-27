Function Update-VcMdtBundle {
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

        .PARAMETER Bundle
            Add to create an Application Bundle named 'Visual C++ Redistributables' to simplify installing the Redistributables.

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
        [Parameter(Mandatory = $True, HelpMessage = "The path to the MDT deployment share.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $MdtPath,

        [Parameter(Mandatory = $False, HelpMessage = "Specify Applications folder to import the VC Redistributables into.")]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [string] $AppFolder = "VcRedists",

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
    }

    Process {
        If ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Update bundle")) {
            # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
            $existingVcRedists = Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" }
            $existingVcRedists = $existingVcRedists | Sort-Object -Property Version
            $dependencies = @(); ForEach ($app in $existingVcRedists) { $dependencies += $app.guid }

            try {
                $bundle = Get-ChildItem -Path "$target\$($Publisher) $($BundleName)" -ErrorAction SilentlyContinue
            }
            catch {
                Throw "Failed to retreive the existing Visual C++ Redistributables bundle"
            }

            If ($Null -ne $bundle) {
                try {
                    Set-ItemProperty -Path $bundle.PSPath -Name "Dependency" -Value $dependencies
                }
                catch {
                    Throw "Error updating VcRedist bundle dependencies."
                }    
            }
        }
    }

    End {
        # Return list of apps to the pipeline
        $bundle = Get-ChildItem -Path "$target\$($Publisher) $($BundleName)"
        Write-Output $bundle
    }
}
