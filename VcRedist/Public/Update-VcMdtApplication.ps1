function Update-VcMdtApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/update-vcmdtapplication/")]
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

        [Parameter(Mandatory = $true)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $true } else { throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $false)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $MdtDrive = "DS099",

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $Publisher = "Microsoft"
    )

    begin {
        # If running on PowerShell Core, error and exit.
        if (Test-PSCore) {
            $Msg = "We can't load the MicrosoftDeploymentToolkit module on PowerShell Core. Please use PowerShell 5.1."
            throw [System.TypeLoadException]::New($Msg)
        }

        # Import the MDT module and create a PS drive to MdtPath
        if (Import-MdtModule) {
            if ($PSCmdlet.ShouldProcess($MdtPath, "Mapping")) {
                try {
                    $params = @{
                        Drive       = $MdtDrive
                        Path        = $MdtPath
                        ErrorAction = "Continue"
                    }
                    New-MdtDrive @params > $null
                    Restore-MDTPersistentDrive -Force > $null
                }
                catch [System.Exception] {
                    $Msg = "Failed to map drive to: $MdtPath. Error: $($_.Exception.Message)"
                    throw $Msg
                }
            }
        }
        else {
            $Msg = "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            throw [System.Management.Automation.InvalidPowerShellStateException]::New($Msg)
        }

        $MdtTargetFolder = "$(Edit-MdtDrive -Drive $MdtDrive)\Applications\$AppFolder"
        Write-Verbose -Message "Update applications in: $MdtTargetFolder"
    }

    process {

        # Make sure that $VcList has the required properties
        if ((Test-VcListObject -VcList $VcList) -ne $true) {
            $Msg = "Required properties not found. Please ensure the output from Save-VcRedist is sent to this function. "
            throw [System.Management.Automation.PropertyNotFoundException]::New($Msg)
        }

        if (Test-Path -Path $MdtTargetFolder) {
            foreach ($VcRedist in $VcList) {

                # Get the existing VcRedist applications in the MDT share
                $params = @{
                    Path        = $MdtTargetFolder
                    ErrorAction = "Continue"
                }
                $ExistingVcRedist = Get-ChildItem @params | Where-Object { $_.ShortName -match "$($VcRedist.Release) $($VcRedist.Architecture)" }

                if ($null -ne $ExistingVcRedist) {
                    try {
                        Write-Verbose -Message "Found application: [$($ExistingVcRedist.ShortName)]."

                        # Determine whether update is required
                        $Update = $false
                        if ($ExistingVcRedist.UninstallKey -ne $VcRedist.ProductCode) { $Update = $true }
                        if ([System.Version]$ExistingVcRedist.Version -lt [System.Version]$VcRedist.Version) { $Update = $true }
                        if ($ExistingVcRedist.CommandLine -ne ".\$(Split-Path -Path $VcRedist.URI -Leaf) $(if ($Silent.IsPresent) { $VcRedist.SilentInstall } else { $VcRedist.Install })") { $Update = $true }
                        if ($Update -eq $true) {

                            # Copy the updated executable
                            try {
                                Write-Verbose -Message "Copy VcRedist installer."
                                #$SourceFolder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                                $SourceFolder = $(Split-Path -Path $VcRedist.Path -Parent)
                                $ContentLocation = [System.IO.Path]::Combine((Resolve-Path -Path $MdtPath), "Applications", "$Publisher VcRedist", $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                                $params = @{
                                    FilePath     = "$env:SystemRoot\System32\robocopy.exe"
                                    ArgumentList = "*.exe `"$SourceFolder`" `"$ContentLocation`" /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL"
                                }
                                $result = Invoke-Process @params
                            }
                            catch {
                                $ExeTarget = Join-Path -Path $ContentLocation -ChildPath $(Split-Path -Path $VcRedist.URI -Leaf)
                                if (Test-Path -Path $ExeTarget) {
                                    Write-Verbose -Message "Copy successful: '$ExeTarget'."
                                }
                                else {
                                    Write-Warning -Message "Failed to copy Redistributables from '$SourceFolder' to '$ContentLocation'."
                                    Write-Warning -Message "Captured error (if any): [$result]."
                                    throw $_
                                }
                            }

                            # Check the existing command line on the application and update
                            if ($PSCmdlet.ShouldProcess($ExistingVcRedist.PSPath, "Update CommandLine")) {
                                $params = @{
                                    Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
                                    Name  = "CommandLine"
                                    Value = ".\$(Split-Path -Path $VcRedist.URI -Leaf) $(if ($Silent.IsPresent) { $VcRedist.SilentInstall } else { $VcRedist.Install })"
                                }
                                Set-ItemProperty @params > $null
                            }

                            # Update ProductCode
                            if ($PSCmdlet.ShouldProcess($ExistingVcRedist.PSPath, "Update UninstallKey")) {
                                $sipParams = @{
                                    Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
                                    Name  = "UninstallKey"
                                    Value = $VcRedist.ProductCode
                                }
                                Set-ItemProperty @sipParams > $null
                            }

                            # Update Version number
                            if ($PSCmdlet.ShouldProcess($ExistingVcRedist.PSPath, "Update Version")) {
                                $sipParams = @{
                                    Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
                                    Name  = "Version"
                                    Value = $VcRedist.Version
                                }
                                Set-ItemProperty @sipParams > $null
                            }

                            if ($PSCmdlet.ShouldProcess($ExistingVcRedist.PSPath, "Update Source")) {
                                $sipParams = @{
                                    Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
                                    Name  = "Source"
                                    Value = $ExistingVcRedist.Source -replace "(\d+(\.\d+){1,4})", $VcRedist.Version
                                }
                                Set-ItemProperty @sipParams > $null
                            }

                            if ($PSCmdlet.ShouldProcess($ExistingVcRedist.PSPath, "Update WorkingDirectory")) {
                                $sipParams = @{
                                    Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
                                    Name  = "WorkingDirectory"
                                    Value = $ExistingVcRedist.WorkingDirectory -replace "(\d+(\.\d+){1,4})", $VcRedist.Version
                                }
                                Set-ItemProperty @sipParams > $null
                            }

                            if ($PSCmdlet.ShouldProcess($ExistingVcRedist.PSPath, "Update Name")) {
                                $sipParams = @{
                                    Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
                                    Name  = "Name"
                                    Value = $ExistingVcRedist.Name -replace "(\d+(\.\d+){1,4})", $VcRedist.Version
                                }
                                Set-ItemProperty @sipParams > $null
                            }
                        }
                    }
                    catch [System.Exception] {
                        throw $_
                    }
                }
            }
        }
        else {
            Write-Warning -Message "Failed to find path $MdtTargetFolder."
        }
    }

    end {
        if (Test-Path -Path $MdtTargetFolder) {

            # Get the imported Visual C++ Redistributables applications to return on the pipeline
            Write-Verbose -Message "Getting Visual C++ Redistributables from the deployment share"
            Write-Output -InputObject (Get-ChildItem -Path $MdtTargetFolder | Where-Object { $_.Name -like "*Visual C++*" | Select-Object -Property * })
        }
        else {
            Write-Warning -Message "Failed to find path $MdtTargetFolder."
        }
    }
}
