Function Update-VcMdtBundle {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://vcredist.com/update-vcmdtbundle/")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $False)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $MdtDrive = "DS001",

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidatePattern('^[a-zA-Z0-9\+ ]+$')]
        [System.String] $BundleName = "Visual C++ Redistributables"
    )

    Begin {
        # Variables
        $Applications = "Applications"
        Write-Warning -Message "$($MyInvocation.MyCommand): Attempting to update bundle: [$Publisher $BundleName]."

        # If running on PowerShell Core, error and exit.
        If (Test-PSCore) {
            Write-Warning -Message "$($MyInvocation.MyCommand): PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module."
            Throw [System.Management.Automation.InvalidPowerShellStateException]
            Exit
        }
    }

    Process {
        # Import the MDT module and create a PS drive to MdtPath
        If (Import-MdtModule) {
            If ($PSCmdlet.ShouldProcess($Path, "Mapping")) {
                try {
                    $params = @{
                        Drive       = $MdtDrive
                        Path        = $MdtPath
                        ErrorAction = "SilentlyContinue"
                    }
                    New-MdtDrive @params > $Null
                    Restore-MDTPersistentDrive -Force > $Null
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Failed to map drive to [$MdtPath]."
                    Throw $_.Exception.Message
                }
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            Throw [System.Management.Automation.InvalidPowerShellStateException]
        }

        # Get properties from the existing bundle/s
        try {
            $gciParams = @{
                Path        = "$($MdtDrive):\$Applications"
                Recurse     = $True
                ErrorAction = "SilentlyContinue"
            }
            $Bundles = Get-ChildItem @gciParams | Where-Object { $_.Name -eq "$Publisher $BundleName" }
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retrieve the existing Visual C++ Redistributables bundle."
            Throw $_.Exception.Message
        }

        ForEach ($Bundle in $Bundles) {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Found bundle: [$($Bundle.Name)]."

            # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
            $target = "$($MdtDrive):\$Applications\$AppFolder"
            Write-Verbose -Message "$($MyInvocation.MyCommand): Gathering VcRedist applications in: $target"
            $existingVcRedists = Get-ChildItem -Path $target | Where-Object { ($_.Name -like "*Visual C++*") -and ($_.guid -ne $bundle.guid) -and ($_.CommandLine -ne "") }
            $existingVcRedists = $existingVcRedists | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false }
            $dependencies = @(); ForEach ($app in $existingVcRedists) { $dependencies += $app.guid }

            If ($PSCmdlet.ShouldProcess($bundle.PSPath, "Update dependencies")) {
                try {
                    $sipParams = @{
                        Path        = ($bundle.PSPath.Replace($bundle.PSProvider, "")).Trim(":")
                        Name        = "Dependency"
                        Value       = $dependencies
                        ErrorAction = "SilentlyContinue"
                        Force       = $True
                    }
                    Set-ItemProperty @sipParams > $Null
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist bundle dependencies."
                    Throw $_.Exception.Message
                }
            }
            If ($PSCmdlet.ShouldProcess($bundle.PSPath, "Update version")) {
                try {
                    $sipParams = @{
                        Path        = $($bundle.PSPath.Replace($bundle.PSProvider, "")).Trim(":")
                        Name        = "Version"
                        Value       = $(Get-Date -Format (([System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat).ShortDatePattern))
                        ErrorAction = "SilentlyContinue"
                        Force       = $True
                    }
                    Set-ItemProperty @sipParams > $Null
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist bundle version."
                    Throw $_.Exception.Message
                }
            }

            # Write the bundle to the pipeline
            Write-Output -InputObject ($bundle | Select-Object -Property * )
        }
    }
}
