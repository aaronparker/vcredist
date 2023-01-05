function New-VcMdtBundle {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://vcredist.com/import-vcmdtapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $True } else { throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $False, Position = 1)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $MdtDrive = "DS099",

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $False, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9\+ ]+$')]
        [System.String] $BundleName = "Visual C++ Redistributables",

        [Parameter(Mandatory = $False, Position = 5)]
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
                    Write-Warning -Message "Failed to map drive to: $MdtPath, with: $($_.Exception.Message)"
                    throw $_
                }
            }
        }
        else {
            $Msg = "Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            throw [System.Management.Automation.InvalidPowerShellStateException]::New($Msg)
        }
    }

    process {
        Write-Verbose -Message "Getting existing Visual C++ Redistributables the deployment share"
        $TargetMdtFolder = "$($MdtDrive):\Applications\$AppFolder"
        $existingVcRedists = Get-ChildItem -Path $TargetMdtFolder -ErrorAction "SilentlyContinue" | Where-Object { $_.Name -like "*Visual C++*" }
        if ($null -eq $existingVcRedists) {
            Write-Warning -Message "Failed to find existing VcRedist applications in the MDT share. Please import the VcRedists with Import-VcMdtApplication."
        }

        if (($null -ne $existingVcRedists) -and (Test-Path -Path $TargetMdtFolder)) {

            # Remove the existing bundle if -Force was specified
            if ($PSBoundParameters.ContainsKey("Force")) {
                if (Test-Path -Path $("$TargetMdtFolder\$Publisher $BundleName")) {
                    if ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Remove bundle")) {
                        Remove-Item -Path $("$TargetMdtFolder\$Publisher $BundleName") -Force
                    }
                }
            }

            # Create the application bundle
            if (Test-Path -Path "$TargetMdtFolder\$Publisher $BundleName") {
                Write-Verbose "'$($Publisher) $($BundleName)' exists. Use -Force to overwrite the existing bundle."
            }
            else {
                if ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Create bundle")) {

                    # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
                    Write-Verbose -Message "Gathering VcRedist applications in: $TargetMdtFolder"
                    $existingVcRedists = $existingVcRedists | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false }
                    $dependencies = @(); foreach ($app in $existingVcRedists) { $dependencies += $app.guid }

                    # Import the bundle
                    try {
                        # Splat the Import-MDTApplication parameters
                        $importMDTAppParams = @{
                            Path       = $TargetMdtFolder
                            Name       = "$($Publisher) $($BundleName)"
                            Enable     = $True
                            Reboot     = $False
                            Hide       = $False
                            Comments   = "Application bundle for installing Visual C++ Redistributables. Generated by $($MyInvocation.MyCommand)"
                            ShortName  = $BundleName
                            Version    = $(Get-Date -Format (([System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat).ShortDatePattern))
                            Publisher  = $Publisher
                            Language   = $Language
                            Dependency = $dependencies
                            Bundle     = $True
                        }
                        Import-MDTApplication @importMDTAppParams > $null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "Error importing the VcRedist bundle. If -Force was specified, the original bundle will have been removed."
                        throw $_
                    }
                }
            }
        }
        else {
            Write-Error -Message "Failed to find path $TargetMdtFolder."
        }

        if (Test-Path -Path $TargetMdtFolder) {
            # Return list of apps to the pipeline
            Write-Output -InputObject (Get-ChildItem -Path "$TargetMdtFolder\$($Publisher) $($BundleName)" | Select-Object -Property *)
        }
        else {
            Write-Error -Message "Failed to find path $TargetMdtFolder."
        }
    }
}
