function Install-VcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>

    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/install-vcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Save-VcRedist.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $false)]
        [System.ObsoleteAttribute("This parameter is not longer supported. The Path property must be on the object passed to -VcList.")]
        [System.String] $Path,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false)]
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

        # Make sure that $VcList has the required properties
        if ((Test-VcListObject -VcList $VcList) -ne $true) {
            $Msg = "Required properties not found. Please ensure the output from Save-VcRedist is sent to this function. "
            throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
        }

        # Sort $VcList by version number from oldest to newest
        foreach ($VcRedist in ($VcList | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false })) {

            # If already installed or the -Force parameter is not specified, skip
            if (($currentInstalled | Where-Object { $VcRedist.ProductCode -contains $_.ProductCode }) -and !($PSBoundParameters.ContainsKey("Force"))) {
                Write-Information -MessageData "VcRedist already installed: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'" -InformationAction "Continue"
            }
            else {

                # Avoid installing 64-bit Redistributable on x86 Windows
                if (((Get-Bitness) -eq "x86") -and ($VcRedist.Architecture -eq "x64")) {
                    Write-Warning -Message "Incompatible architecture: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'"
                }
                else {

                    if (Test-Path -Path $VcRedist.Path) {
                        Write-Verbose -Message "Installing VcRedist: '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'"
                        if ($PSCmdlet.ShouldProcess("$($VcRedist.Path) $($VcRedist.Install)", "Install")) {

                            try {
                                # Create parameters with -ArgumentList set based on Install/SilentInstall properties in the manifest
                                $params = @{
                                    FilePath     = $VcRedist.Path
                                    ArgumentList = if ($Silent) { $VcRedist.SilentInstall } else { $VcRedist.Install }
                                    PassThru     = $true
                                    Wait         = $true
                                    NoNewWindow  = $true
                                    Verbose      = $VerbosePreference
                                    ErrorAction  = "Continue"
                                }
                                $Result = Start-Process @params
                            }
                            catch {
                                throw $_
                            }
                            $Installed = Get-InstalledVcRedist | Where-Object { $_.ProductCode -eq $VcRedist.ProductCode }
                            if ($Installed) {
                                Write-Verbose -Message "Installed successfully: VcRedist '$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)'; ExitCode: $($Result.ExitCode)"
                            }
                        }
                    }
                    else {
                        Write-Warning -Message "Cannot find: '$($VcRedist.Path)'. Download with Save-VcRedist."
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
