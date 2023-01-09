function Update-VcMdtBundle {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/update-vcmdtbundle/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $true } else { throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $false)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false, Position = 1)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $MdtDrive = "DS099",

        [Parameter(Mandatory = $false, Position = 2)]
        [ValidatePattern("^[a-zA-Z0-9]+$")]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $false, Position = 3)]
        [ValidatePattern("^[a-zA-Z0-9\+ ]+$")]
        [System.String] $BundleName = "Visual C++ Redistributables"
    )

    begin {
        # Variables
        $Applications = "Applications"
        Write-Warning -Message "Attempting to update bundle: [$Publisher $BundleName]."

        # If running on PowerShell Core, error and exit.
        if (Test-PSCore) {
            Write-Warning -Message "PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module."
            throw [System.Management.Automation.InvalidPowerShellStateException]
            Exit
        }
    }

    process {
        # Import the MDT module and create a PS drive to MdtPath
        if (Import-MdtModule) {
            if ($PSCmdlet.ShouldProcess($Path, "Mapping")) {
                try {
                    $params = @{
                        Drive       = $MdtDrive
                        Path        = $MdtPath
                        ErrorAction = "SilentlyContinue"
                    }
                    New-MdtDrive @params > $null
                    Restore-MDTPersistentDrive -Force > $null
                }
                catch [System.Exception] {
                    Write-Warning -Message "Failed to map drive to [$MdtPath]."
                    throw $_.Exception.Message
                }
            }
        }
        else {
            Write-Warning -Message "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            throw [System.Management.Automation.InvalidPowerShellStateException]
        }

        # Get properties from the existing bundle/s
        try {
            $gciParams = @{
                Path        = "$($MdtDrive):\$Applications"
                Recurse     = $true
                ErrorAction = "SilentlyContinue"
            }
            $Bundles = Get-ChildItem @gciParams | Where-Object { $_.Name -eq "$Publisher $BundleName" }
        }
        catch [System.Exception] {
            Write-Warning -Message "Failed to retrieve the existing Visual C++ Redistributables bundle."
            throw $_.Exception.Message
        }

        foreach ($Bundle in $Bundles) {
            Write-Verbose -Message "Found bundle: '$($Bundle.Name)'."

            # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
            $target = "$($MdtDrive):\$Applications\$AppFolder"
            Write-Verbose -Message "Gathering VcRedist applications in: $target"
            $existingVcRedists = Get-ChildItem -Path $target | Where-Object { ($_.Name -like "*Visual C++*") -and ($_.guid -ne $bundle.guid) -and ($_.CommandLine -ne "") }
            $existingVcRedists = $existingVcRedists | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false }
            $dependencies = @(); foreach ($app in $existingVcRedists) { $dependencies += $app.guid }

            if ($PSCmdlet.ShouldProcess($bundle.PSPath, "Update dependencies")) {
                try {
                    $sipParams = @{
                        Path        = ($bundle.PSPath.Replace($bundle.PSProvider, "")).Trim(":")
                        Name        = "Dependency"
                        Value       = $dependencies
                        ErrorAction = "SilentlyContinue"
                        Force       = $true
                    }
                    Set-ItemProperty @sipParams > $null
                }
                catch [System.Exception] {
                    Write-Warning -Message "Error updating VcRedist bundle dependencies."
                    throw $_.Exception.Message
                }
            }
            if ($PSCmdlet.ShouldProcess($bundle.PSPath, "Update version")) {
                try {
                    $sipParams = @{
                        Path        = $($bundle.PSPath.Replace($bundle.PSProvider, "")).Trim(":")
                        Name        = "Version"
                        Value       = $(Get-Date -Format (([System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat).ShortDatePattern))
                        ErrorAction = "SilentlyContinue"
                        Force       = $true
                    }
                    Set-ItemProperty @sipParams > $null
                }
                catch [System.Exception] {
                    Write-Warning -Message "Error updating VcRedist bundle version."
                    throw $_.Exception.Message
                }
            }

            # Write the bundle to the pipeline
            Write-Output -InputObject ($bundle | Select-Object -Property * )
        }
    }
}
