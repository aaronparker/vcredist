function Install-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://vcredist.com/install-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $True } else { throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    begin {
        # Get script elevation status
        [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
        if ($Elevated -eq $false) {
            $Msg = "Installing the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again"
            throw [System.Management.Automation.ScriptRequiresException]::New($Msg)
        }

        # Get currently installed VcRedist versions
        $currentInstalled = Get-InstalledVcRedist
    }

    process {

        # Sort $VcList by version number from oldest to newest
        foreach ($VcRedist in ($VcList | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false })) {

            # If already installed or the -Force parameter is not specified, skip
            if (($currentInstalled | Where-Object { $VcRedist.ProductCode -contains $_.ProductCode }) -and !($PSBoundParameters.ContainsKey("Force"))) {
                Write-Warning -Message "VcRedist already installed: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
            }
            else {

                # Avoid installing 64-bit Redistributable on x86 Windows
                if ((Get-Bitness -eq "x86") -and ($VcRedist.Architecture -eq 'x64')) {
                    Write-Warning -Message "Incompatible architecture: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                }
                else {

                    # Target folder structure; VcRedist setup file
                    Write-Verbose -Message "Construct target installer folder and filename."
                    $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                    $filename = Join-Path -Path $folder -ChildPath $(Split-Path -Path $VcRedist.Download -Leaf)

                    Write-Verbose -Message "Install VcRedist: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                    if (Test-Path -Path $filename) {
                        if ($PSCmdlet.ShouldProcess("$filename $($VcRedist.Install)", "Install")) {

                            try {
                                # Create parameters with -ArgumentList set based on Install/SilentInstall properties in the manifest
                                # Install the VcRedist using the Invoke-Process private function
                                $invokeProcessParams = @{
                                    FilePath     = $filename
                                    ArgumentList = if ($Silent) { $VcRedist.SilentInstall } else { $VcRedist.Install }
                                }
                                $result = Invoke-Process @invokeProcessParams
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failure in installing Visual C++ Redistributable."
                                Write-Warning -Message "Captured error (if any): [$result]."
                            }
                            finally {
                                $Installed = Get-InstalledVcRedist | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode }
                                if ($Installed) {
                                    Write-Verbose -Message "Installed successfully: VcRedist $($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)"
                                }
                            }
                        }
                    }
                    else {
                        Write-Warning -Message "Cannot find: [$filename]. Download with Save-VcRedist."
                    }
                }
            }
        }
    }

    end {
        # Get the installed Visual C++ Redistributables applications to return on the pipeline
        Write-Output -InputObject (Get-InstalledVcRedist)
    }
}
