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
            https://docs.stealthpuppy.com/docs/vcredist/usage/installing-the-redistributables

        .PARAMETER VcList
            An array containing details of the Visual C++ Redistributables from Get-VcList.

        .PARAMETER Path
            A folder containing the downloaded Visual C++ Redistributables.

        .PARAMETER Silent
            Perform a completely silent install of the VcRedist with no UI. The default install is passive.

        .EXAMPLE
            $VcRedists = Get-VcList -Release 2013, 2019 -Architecture x64
            Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists

            Description:
            Installs the 2013 and 2019 64-bit Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

        .EXAMPLE
            $VcRedists = Get-VcList -Release "2012","2013",2017" -Architecture x64
            Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists

            Description:
            Installs only the 64-bit 2012, 2013 and 2017 Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

        .EXAMPLE
            $VcRedists = Get-VcList -Release "2012","2013",2017" -Architecture x64    
            Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists -Silent

            Description:
            Installs all supported Visual C++ Redistributables using a completely silent install.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI="https://docs.stealthpuppy.com/docs/vcredist/usage/installing-the-redistributables")]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [PSCustomObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( {If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $False)]
        [switch] $Silent
    )

    Begin {
        # Get script elevation status
        [bool] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        If (!($Elevated)) {
            Throw "Installing the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again."
            Break
        }

        # Get currently installed VcRedist versions
        $currentInstalled = Get-InstalledVcRedist
    }

    Process {
        ForEach ($vc in $VcList) {
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
 