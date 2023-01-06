function Import-VcMdtApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Import-VcMdtApp")]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/import-vcmdtapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $true } else { throw "Cannot find path $_" } })]
        [System.String] $Path,

        [Parameter(Mandatory = $true, Position = 2)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $true } else { throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $DontHide,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $false, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $MdtDrive = "DS099",

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidatePattern('^[a-zA-Z0-9-]+$')]
        [System.String] $Language = "en-US"
    )

    begin {
        # If running on PowerShell Core, error and exit.
        if (Test-PSCore) {
            $Msg = "We can't load the MicrosoftDeploymentToolkit module on PowerShell Core. Please use PowerShell 5.1."
            throw [System.TypeLoadException]::New($Msg)
        }

        # Import the MDT module and create a PS drive to MdtPath
        if (Import-MdtModule) {
            if ($PSCmdlet.ShouldProcess($Path, "Mapping")) {
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

        # Create the Application folder
        if ($AppFolder.Length -gt 0) {
            if ($PSCmdlet.ShouldProcess($AppFolder, "Create")) {
                try {
                    $params = @{
                        Drive       = $(Edit-MdtDrive -Drive $MdtDrive)
                        Name        = $AppFolder
                    }
                    New-MdtApplicationFolder @params > $null
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failed to create folder: $AppFolder, with: $($_.Exception.Message)"
                    throw $_
                }
            }
            $TargetMdtFolder = "$(Edit-MdtDrive -Drive $MdtDrive)\Applications\$AppFolder"
        }
        else {
            $TargetMdtFolder = "$(Edit-MdtDrive -Drive $MdtDrive)\Applications"
        }
        Write-Verbose -Message "VcRedists will be imported into: $TargetMdtFolder"
        Write-Verbose -Message "Retrieving existing Visual C++ Redistributables from the deployment share"
        $existingVcRedists = Get-ChildItem -Path $TargetMdtFolder -ErrorAction "SilentlyContinue" | Where-Object { $_.Name -like "*Visual C++*" }
    }

    process {
        foreach ($VcRedist in $VcList) {

            # Set variables
            Write-Verbose -Message "processing: [$($VcRedist.Name) $($VcRedist.Architecture)]."
            $supportedPlatform = if ($VcRedist.Architecture -eq "x86") {
                @("All x86 Windows 7 and Newer", "All x64 Windows 7 and Newer")
            }
            else {
                @("All x64 Windows 7 and Newer")
            }

            # Check for existing application by matching current VcRedist
            $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
            $VcMatched = $existingVcRedists | Where-Object { $_.Name -eq $ApplicationName }

            # Remove the matched VcRedist application
            if ($PSBoundParameters.ContainsKey("Force")) {
                if ($VcMatched.UninstallKey -eq $VcRedist.ProductCode) {
                    if ($PSCmdlet.ShouldProcess($VcMatched.Name, "Remove")) {
                        Remove-Item -Path $("$TargetMdtFolder\$($VcMatched.Name)") -Force
                    }
                }
            }

            # Import as an application into the MDT deployment share
            if (Test-Path -Path "$TargetMdtFolder\$($VcMatched.Name)") {
                Write-Verbose -Message "'$("$TargetMdtFolder\$($VcMatched.Name)")' exists. Use -Force to overwrite the existing application."
            }
            else {
                if ($PSCmdlet.ShouldProcess("$($VcRedist.Name) in $MdtPath", "Import")) {
                    try {

                        # Splat the Import-MDTApplication arguments
                        $importMDTAppParams = @{
                            Path                  = $TargetMdtFolder
                            Name                  = $ApplicationName
                            Enable                = $true
                            Reboot                = $false
                            Hide                  = $(if ($DontHide.IsPresent) { "False" } else { "True" })
                            Comments              = "Generated by $($MyInvocation.MyCommand), https://vcredist.com/"
                            ShortName             = "$($VcRedist.Name) $($VcRedist.Architecture)"
                            Version               = $VcRedist.Version
                            Publisher             = $Publisher
                            Language              = $Language
                            CommandLine           = ".\$(Split-Path -Path $VcRedist.URI -Leaf) $(if ($Silent.IsPresent) { $VcRedist.SilentInstall } else { $VcRedist.Install })"
                            ApplicationSourcePath = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                            DestinationFolder     = "$Publisher VcRedist\$($VcRedist.Release)\$($VcRedist.Version)\$($VcRedist.Architecture)"
                            WorkingDirectory      = ".\Applications\$Publisher VcRedist\$($VcRedist.Release)\$($VcRedist.Version)\$($VcRedist.Architecture)"
                            UninstallKey          = $VcRedist.ProductCode
                            SupportedPlatform     = $supportedPlatform
                        }
                        Import-MDTApplication @importMDTAppParams > $null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "Error encountered importing the application: [$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)]."
                        throw $_
                    }
                }
            }
        }
    }

    end {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        Write-Verbose -Message "Retrieving Visual C++ Redistributables imported into the deployment share"
        Write-Output -InputObject (Get-ChildItem -Path $TargetMdtFolder | Where-Object { $_.Name -like "*Visual C++*" } | Select-Object -Property *)
    }
}
