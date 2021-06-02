Function Install-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/vcredist/install-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path = (Resolve-Path -Path $PWD),

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force
    )

    Begin {
        # Get script elevation status
        [System.Boolean] $Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator") 
        If ($Elevated) {}
        Else {
            $Message =  "Installing the Visual C++ Redistributables requires elevation. The current Windows PowerShell session is not running as Administrator. Start Windows PowerShell by using the Run as Administrator option, and then try running the script again"
            Write-Warning -Message "$($MyInvocation.MyCommand): $Message."
            Throw [System.Management.Automation.ScriptRequiresException]
        }
        
        # Get currently installed VcRedist versions
        $currentInstalled = Get-InstalledVcRedist
    }

    Process {
        
        # Sort $VcList by version number from oldest to newest
        ForEach ($VcRedist in ($VcList | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false })) {

            # If already installed or the -Force parameter is not specified, skip 
            If (($currentInstalled | Where-Object { $VcRedist.ProductCode -contains $_.ProductCode }) -and !($PSBoundParameters.ContainsKey("Force"))) {
                Write-Warning -Message "$($MyInvocation.MyCommand): VcRedist already installed: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
            }
            Else {
                
                # Avoid installing 64-bit Redistributable on x86 Windows 
                If ((Get-Bitness -Architecture 'x86') -and ($VcRedist.Architecture -eq 'x64')) {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Incompatible architecture: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                }
                Else {
                        
                    # Target folder structure; VcRedist setup file
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Construct target installer folder and filename."
                    $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                    $filename = Join-Path -Path $folder -ChildPath $(Split-Path -Path $VcRedist.Download -Leaf)

                    Write-Verbose -Message "$($MyInvocation.MyCommand): Install VcRedist: [$($VcRedist.Release), $($VcRedist.Architecture), $($VcRedist.Version)]."
                    If (Test-Path -Path $filename -ErrorAction "SilentlyContinue") {
                        If ($PSCmdlet.ShouldProcess("$filename $($VcRedist.Install)", "Install")) {

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
                    }
                }
            }
        }
    }
 
    End {
        # Get the installed Visual C++ Redistributables applications to return on the pipeline
        Write-Output -InputObject (Get-InstalledVcRedist)
    }
}
