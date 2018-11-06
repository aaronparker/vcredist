Function Install-VcRedist {
    <#
        .SYNOPSIS
            Installs the Visual C++ Redistributables.

        .DESCRIPTION
            Installs the Visual C++ Redistributables from a list created by Get-VcList and downloaded locally with Get-VcRedist.

        .OUTPUTS
            System.Array

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Install-VisualCRedistributables

        .PARAMETER VcList
            An array containing details of the Visual C++ Redistributables from Get-VcList.

        .PARAMETER Path
            A folder containing the downloaded Visual C++ Redistributables.

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to download or install.

        .PARAMETER Architecture
            Specifies the processor architecture to download or install.

        .PARAMETER Silent
            Perform a completely silent install of the VcRedist with no UI. The default install is passive.

        .EXAMPLE
            Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists

            Description:
            Installs the Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

        .EXAMPLE
            Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists -Release "2012","2013",2017" -Architecture x64

            Description:
            Installs only the 64-bit 2012, 2013 and 2017 Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

        .EXAMPLE
            Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists -Silent

            Description:
            Installs all supported Visual C++ Redistributables using a completely silent install.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNullOrEmpty()]
        [array] $VcList,

        [Parameter(Mandatory = $True, Position = 1, `
                HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript( {If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]] $Release = @("2008", "2010", "2012", "2013", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False, HelpMessage = "Perform a silent install of the VcRedist.")]
        [switch] $Silent
    )
    Begin {
        # Get script elevation status
        [bool] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        If (!($Elevated)) { Throw "Installing the Visual C++ Redistributables requires elevation." }
            
        # Get currently installed VcRedist versions
        $currentInstalled = Get-InstalledVcRedist

        # Filter release and architecture
        Write-Verbose "Filtering releases for platform and architecture."
        $filteredVcList = $VcList | Where-Object { $Release -contains $_.Release } | Where-Object { $Architecture -contains $_.Architecture }
    }
    Process {
        ForEach ($vc in $filteredVcList) {
            If ($currentInstalled | Where-Object { $vc.ProductCode -contains $_.ProductCode }) {
                Write-Verbose "Already installed: [$($vc.Architecture)]$($vc.Name)"
            }
            Else {
                # Avoid installing 64-bit Redistributable on x86 Windows 
                If ((Get-Bitness -Architecture 'x86') -and ($vc.Architecture -eq 'x64')) {
                    Write-Verbose "Incompatible architecture: [$($vc.Architecture)]$($vc.Name)"
                }
                Else {
                    # Construct full path to VcRedist installer
                    $folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $vc.Release) $vc.Architecture) $vc.ShortName
                    $filename = Join-Path $folder $(Split-Path -Path $vc.Download -Leaf)

                    Write-Verbose "Install: [$($vc.Architecture)]$($vc.Name)"
                    If (Test-Path -Path $filename) {
                        If ($pscmdlet.ShouldProcess("$filename $($vc.Install)'", "Install")) {

                            # Create parameters with -ArgumentList set based on -Silent argument used in this function
                            $invokeProcessParams = @{
                                FilePath     = $filename
                                ArgumentList = If($Silent) { $vc.SilentInstall } Else { $vc.Install }
                            }

                            # Install the VcRedist using the Invoke-Process private function
                            Invoke-Process @invokeProcessParams
                        }
                    }
                    Else {
                        Write-Error "Cannot find: $filename"
                    }
                }
            }
        }
    }
    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        Write-Output (Get-InstalledVcRedist)
    }
}
 