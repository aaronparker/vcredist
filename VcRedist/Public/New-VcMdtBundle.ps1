Function New-VcMdtBundle {
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

        .PARAMETER MdtPath
            The local or network path to the MDT deployment share.

        .PARAMETER AppFolder
            Import the Visual C++ Redistributables into a sub-folder. Defaults to "VcRedists".

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
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $MdtPath,

        [Parameter(Mandatory = $False)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [string] $AppFolder = "VcRedists",

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

        try {
            Write-Verbose -Message "Getting existing Visual C++ Redistributables the deployment share"
            $target = "$($MdtDrive):\Applications\$AppFolder"
            $existingVcRedists = Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" }
        }
        catch {
            Throw "Failed when returning existing VcRedist packages."
        }
        If ($Null -eq $existingVcRedists) {
            Write-Error -Message "Failed to find existing VcRedist applications in the MDT share. Please import the VcRedists with Import-VcMdtApplication."
            Break
        }
    }

    Process {
        If (Test-Path -Path $target -ErrorAction SilentlyContinue) {
            # Remove the existing bundle if -Force was specified
            If ($Force.IsPresent) {
                If (Test-Path -Path $("$target\$Publisher $BundleName") -ErrorAction SilentlyContinue) {
                    If ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Remove bundle")) {
                        Remove-Item -Path $("$target\$Publisher $BundleName") -Force
                    }
                }
            }

            # Create the application bundle
            If (Test-Path -Path $("$target\$Publisher $BundleName") -ErrorAction SilentlyContinue) {
                Write-Verbose "'$($Publisher) $($BundleName)' exists. Use -Force to overwrite the exsiting bundle."
            }
            Else {
                If ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Create bundle")) {
                    # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
                    $existingVcRedists = $existingVcRedists | Sort-Object -Property Version
                    $dependencies = @(); ForEach ($app in $existingVcRedists) { $dependencies += $app.guid }

                    # Import the bundle
                    try {
                        # Splat the Import-MDTApplication parameters
                        $importMDTAppParams = @{
                            Path       = $target
                            Name       = "$($Publisher) $($BundleName)"
                            Enable     = $True
                            Reboot     = $False
                            Hide       = $False
                            Comments   = "Application bundle for installing Visual C++ Redistributables. Generated by $($MyInvocation.MyCommand)"
                            ShortName  = $BundleName
                            Version    = (Get-Date -format "yyyy-MMM-dd")
                            Publisher  = $Publisher
                            Language   = $Language
                            Dependency = $dependencies
                        }
                        Import-MDTApplication @importMDTAppParams -Bundle
                    }
                    catch {
                        Throw "Error importing the VcRedist bundle. If -Force was specified, the original bundle will have been removed."
                    }
                }
            }
        }
        Else {
            Write-Error -Message "Failed to find path $target."
        }
    }

    End {
        If (Test-Path -Path $target -ErrorAction SilentlyContinue) {
            # Return list of apps to the pipeline
            $bundle = Get-ChildItem -Path "$target\$($Publisher) $($BundleName)"
            Write-Output $bundle
        }
        Else {
            Write-Error -Message "Failed to find path $target."
        }
    }
}
