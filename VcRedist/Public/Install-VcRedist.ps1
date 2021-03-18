Function Install-VcRedist {
    <#
        .SYNOPSIS
            Installs the Visual C++ Redistributables.

        .DESCRIPTION
            Installs the Visual C++ Redistributables from a list created by Get-VcList and downloaded locally with Get-VcRedist.

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
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/installing-the-redistributables")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Silent
    )

    Begin {
        # Get script elevation status
        [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
    }

    Process {
        If ($Elevated) {
            # Get currently installed VcRedist versions
            $currentInstalled = Get-InstalledVcRedist

            ForEach ($VcRedist in $VcList) {
                If ($currentInstalled | Where-Object { $VcRedist.ProductCode -contains $_.ProductCode }) {
                    Write-Warning -Message "$($MyInvocation.MyCommand): VcRedist already installed: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                }
                Else {
                    # Avoid installing 64-bit Redistributable on x86 Windows 
                    If ((Get-Bitness -Architecture 'x86') -and ($VcRedist.Architecture -eq 'x64')) {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Incompatible architecture: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                    }
                    Else {
                        
                        # Target folder structure
                        $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)

                        # VcRedist setup file
                        $filename = Join-Path -Path $folder -ChildPath $(Split-Path -Path $VcRedist.Download -Leaf)

                        Write-Verbose -Message "$($MyInvocation.MyCommand): Install VcRedist: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                        If (Test-Path -Path $filename -ErrorAction "SilentlyContinue") {
                            If ($PSCmdlet.ShouldProcess("$filename $($VcRedist.Install)'", "Install")) {

                                try {
                                    # Create parameters with -ArgumentList set based on Install/SilentInstall properties in the manifest
                                    # Install the VcRedist using the Invoke-Process private function
                                    $invokeProcessParams = @{
                                        FilePath     = $filename
                                        ArgumentList = If ($Silent) { $VcRedist.SilentInstall } Else { $VcRedist.Install }
                                    }
                                    $result = Invoke-Process @invokeProcessParams
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Failure in installing Visual C++ Redistributable."
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Captured error (if any): [$result]."
                                    Throw "Failed to install VcRedist $($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)"
                                    Break
                                }
                                finally {
                                    $Installed = Get-InstalledVcRedist | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode }
                                    If ($Installed) {
                                        Write-Verbose -Message "Installed successfully: VcRedist $($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)"
                                    }
                                }
                            }
                        }
                        Else {
                            Write-Warning -Message "$($MyInvocation.MyCommand): Cannot find: [$filename]. Download with Save-VcRedist."
                            Throw "$($MyInvocation.MyCommand): Install Failure. Missing installer: [$filename]."
                            Break
                        }
                    }
                }
            }

            # Get the imported Visual C++ Redistributables applications to return on the pipeline
            Write-Output -InputObject (Get-InstalledVcRedist)
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Installing the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again."
            Throw [System.Management.Automation.ScriptRequiresException]
        }
    }
 
    End { }
}
