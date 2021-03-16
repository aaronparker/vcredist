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
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
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

            ForEach ($vc in $VcList) {
                If ($currentInstalled | Where-Object { $vc.ProductCode -contains $_.ProductCode }) {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Already installed: [$($vc.Architecture), $($vc.Name)]."
                }
                Else {
                    # Avoid installing 64-bit Redistributable on x86 Windows 
                    If ((Get-Bitness -Architecture 'x86') -and ($vc.Architecture -eq 'x64')) {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Incompatible architecture: [$($vc.Architecture), $($vc.Name)]."
                    }
                    Else {
                        # Construct full path to VcRedist installer
                        $folder = Join-Path -Path (Join-Path -Path (Join-Path -Path $(Resolve-Path -Path $Path) -ChildPath $vc.Release) -ChildPath $vc.Architecture) -ChildPath $vc.ShortName
                        $filename = Join-Path -Path $folder -ChildPath $(Split-Path -Path $vc.Download -Leaf)

                        Write-Verbose -Message "$($MyInvocation.MyCommand): Install: [$($vc.Architecture), $($vc.Name)]."
                        If (Test-Path -Path $filename) {
                            If ($PSCmdlet.ShouldProcess("$filename $($vc.Install)'", "Install")) {

                                try {
                                    # Create parameters with -ArgumentList set based on -Silent argument used in this function
                                    # Install the VcRedist using the Invoke-Process private function
                                    $invokeProcessParams = @{
                                        FilePath     = $filename
                                        ArgumentList = If ($Silent) { $vc.SilentInstall } Else { $vc.Install }
                                    }
                                    Invoke-Process @invokeProcessParams
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Failure in installing Visual C++ Redistributable."
                                    Throw $_.Exception.Message
                                    Continue
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
