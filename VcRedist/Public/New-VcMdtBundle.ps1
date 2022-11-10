function New-VcMdtBundle {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://vcredist.com/import-vcmdtapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } else { throw "Cannot find path $_" } })]
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
            Write-Warning -Message "$($MyInvocation.MyCommand): PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module."
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
                    Write-Warning -Message "$($MyInvocation.MyCommand): Failed to map drive to [$MdtPath]."
                    throw $_.Exception.Message
                }
            }
        }
        else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            throw [System.Management.Automation.InvalidPowerShellStateException]
        }

        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Getting existing Visual C++ Redistributables the deployment share"
            $target = "$($MdtDrive):\Applications\$AppFolder"
            $existingVcRedists = Get-ChildItem -Path $target -ErrorAction "SilentlyContinue" | Where-Object { $_.Name -like "*Visual C++*" }
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed when returning existing VcRedist packages."
            throw $_.Exception.Message
        }

        if ($null -eq $existingVcRedists) {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to find existing VcRedist applications in the MDT share. Please import the VcRedists with Import-VcMdtApplication."
            break
        }

        if (Test-Path -Path $target -ErrorAction "SilentlyContinue") {

            # Remove the existing bundle if -Force was specified
            if ($PSBoundParameters.ContainsKey("Force")) {
                if (Test-Path -Path $("$target\$Publisher $BundleName") -ErrorAction "SilentlyContinue") {
                    if ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Remove bundle")) {
                        try {
                            Remove-Item -Path $("$target\$Publisher $BundleName") -Force
                        }
                        catch [System.Exception] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to remove item: [$target\$Publisher $BundleName)]."
                            throw $_.Exception.Message
                        }
                    }
                }
            }

            # Create the application bundle
            if (Test-Path -Path $("$target\$Publisher $BundleName") -ErrorAction "SilentlyContinue") {
                Write-Verbose "$($MyInvocation.MyCommand): '$($Publisher) $($BundleName)' exists. Use -Force to overwrite the existing bundle."
            }
            else {
                if ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Create bundle")) {

                    # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Gathering VcRedist applications in: $target"
                    $existingVcRedists = $existingVcRedists | Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $false }
                    $dependencies = @(); foreach ($app in $existingVcRedists) { $dependencies += $app.guid }

                    # Import the bundle
                    try {
                        # Splat the Import-MDTApplication parameters
                        $importMDTAppParams = @{
                            Path       = $target
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
                        Write-Warning -Message "$($MyInvocation.MyCommand): Error importing the VcRedist bundle. If -Force was specified, the original bundle will have been removed."
                        throw $_.Exception.Message
                    }
                }
            }
        }
        else {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed to find path $target."
        }

        if (Test-Path -Path $target -ErrorAction "SilentlyContinue") {
            # Return list of apps to the pipeline
            Write-Output -InputObject (Get-ChildItem -Path "$target\$($Publisher) $($BundleName)" | Select-Object -Property *)
        }
        else {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed to find path $target."
        }
    }
}
