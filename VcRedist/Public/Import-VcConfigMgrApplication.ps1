function Import-VcConfigMgrApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias('Import-VcCmApp')]
    [CmdletBinding(SupportsShouldProcess = $true, HelpURI = "https://vcredist.com/import-vcconfigmgrapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $true, Position = 1)]
        [ValidateScript( { if (Test-Path -Path $_ -PathType 'Container') { $true } else { throw "Cannot find path $_." } })]
        [System.String] $Path,

        [Parameter(Mandatory = $true, Position = 2)]
        [System.String] $CMPath,

        [Parameter(Mandatory = $true, Position = 3)]
        [ValidateScript( { if ($_ -match "^[a-zA-Z0-9]{3}$") { $true } else { throw "$_ is not a valid ConfigMgr site code." } })]
        [System.String] $SMSSiteCode,

        [Parameter(Mandatory = $false, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $NoCopy,

        [Parameter(Mandatory = $false, Position = 5)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $false, Position = 6)]
        [ValidatePattern('^[a-zA-Z0-9\+ ]+$')]
        [System.String] $Keyword = "Visual C++ Redistributable"
    )

    begin {
        #region CMPath will be the network location for copying the Visual C++ Redistributables to
        try {
            Write-Verbose -Message "Setting location to: $Path."
            Set-Location -Path $Path -ErrorAction "Continue"
        }
        catch [System.Exception] {
            Write-Warning -Message "Failed to set location to: $Path."
            throw $_
        }
        #endregion

        #region Validate $CMPath
        if (Resolve-Path -Path $CMPath) {
            $CMPath = $CMPath.TrimEnd("\")

            #region If the ConfigMgr console is installed, load the PowerShell module; Requires PowerShell module to be installed
            if (Test-Path -Path env:SMS_ADMIN_UI_PATH) {
                try {
                    # Import the ConfigurationManager.psd1 module
                    Write-Verbose -Message "Importing module: $($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1."
                    Import-Module -Name "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -Verbose:$false > $null

                    # Create the folder for importing the Redistributables into
                    if ($AppFolder) {
                        $DestFolder = "$($SMSSiteCode):\Application\$($AppFolder)"
                        if ($PSCmdlet.ShouldProcess($DestFolder, "Creating")) {
                            Write-Verbose -Message "Creating: $DestFolder."
                            New-Item -Path $DestFolder -ErrorAction "Continue" > $null
                        }
                        if (Test-Path -Path $DestFolder) {
                            Write-Verbose -Message "Importing into: $DestFolder."
                        }
                    }
                    else {
                        Write-Verbose -Message "Importing into: $($SMSSiteCode):\Application."
                        $DestFolder = "$($SMSSiteCode):\Application"
                    }
                }
                catch {
                    $Msg = "Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed."
                    throw [System.Exception]::New($Msg)
                }
            }
            else {
                $Msg = "Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr console and PowerShell module installed?"
                throw [System.Exception]::New($Msg)
            }
            #endregion
        }
        else {
            $Msg = "Unable to confirm $CMPath exists. Please check that $CMPath is valid."
            throw [System.IO.DirectoryNotFoundException]::New($Msg)
        }
        #endregion
    }

    process {
        foreach ($VcRedist in $VcList) {
            Write-Verbose -Message "Importing VcRedist app: [Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)]"

            # If SMS_ADMIN_UI_PATH variable exists, assume module imported successfully earlier
            if (Test-Path -Path env:SMS_ADMIN_UI_PATH) {

                # Import as an application into ConfigMgr
                if ($PSCmdlet.ShouldProcess("$($VcRedist.Name) in $CMPath", "Import ConfigMgr app")) {

                    # Create the ConfigMgr application with properties from the manifest
                    if ((Get-Item -Path $DestFolder).PSDrive.Name -eq $SMSSiteCode) {
                        if ($PSCmdlet.ShouldProcess($VcRedist.Name + " $($VcRedist.Architecture)", "Creating ConfigMgr application")) {

                            # Build paths
                            $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                            $ContentLocation = [System.IO.Path]::Combine($CMPath, $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)

                            #region Copy VcRedists to the network location. Use robocopy for robustness
                            if ($NoCopy) {
                                Write-Warning -Message "NoCopy specified, skipping copy to $ContentLocation. Ensure VcRedists exist in the target."
                            }
                            else {
                                if ($PSCmdlet.ShouldProcess("$($folder) to $($ContentLocation)", "Copy")) {
                                    if (!(Test-Path -Path $ContentLocation)) {
                                        New-Item -Path $ContentLocation -ItemType "Directory" -ErrorAction "Continue" > $null
                                    }
                                    try {
                                        $invokeProcessParams = @{
                                            FilePath     = "$env:SystemRoot\System32\robocopy.exe"
                                            ArgumentList = "*.exe `"$folder`" `"$ContentLocation`" /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL"
                                        }
                                        Invoke-Process @invokeProcessParams | Out-Null
                                    }
                                    catch [System.Exception] {
                                        $Err = $_
                                        $Target = Join-Path -Path $ContentLocation -ChildPath $(Split-Path -Path $VcRedist.URI -Leaf)
                                        if (Test-Path -Path $Target) {
                                            Write-Verbose -Message "Copy successful: [$Target]."
                                        }
                                        else {
                                            Write-Warning -Message "Failed to copy Redistributables from [$folder] to [$ContentLocation]."
                                            throw $Err
                                        }
                                    }
                                }
                            }
                            #endregion

                            # Change to the SMS Application folder before importing the applications
                            Write-Verbose -Message "Setting location to: $($DestFolder)"
                            try {
                                Set-Location -Path $DestFolder -ErrorAction "Continue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to set location to: $DestFolder."
                                throw $_
                            }

                            try {
                                # Splat New-CMApplication parameters, add the application and move into the target folder
                                $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
                                $cmAppParams = @{
                                    Name              = $ApplicationName
                                    Description       = "$Publisher $ApplicationName imported by $($MyInvocation.MyCommand). https://vcredist.com"
                                    SoftwareVersion   = $VcRedist.Version
                                    LinkText          = $VcRedist.URL
                                    Publisher         = $Publisher
                                    Keyword           = $Keyword
                                    ReleaseDate       = $(Get-Date -Format (([System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat).ShortDatePattern))
                                    PrivacyUrl        = "https://go.microsoft.com/fwlink/?LinkId=521839"
                                    UserDocumentation = "https://visualstudio.microsoft.com/vs/support/"
                                }
                                $app = New-CMApplication @cmAppParams
                                if ($AppFolder) {
                                    $app | Move-CMObject -FolderPath $DestFolder -ErrorAction "SilentlyContinue" > $null
                                }
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to create application $($VcRedist.Name) $($VcRedist.Architecture)."
                                throw $_
                            }
                            # Write app detail to the pipeline
                            Write-Output -InputObject $app

                            try {
                                Write-Verbose -Message "Setting location to: $Path."
                                Set-Location -Path $Path -ErrorAction "Continue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to set location to: $Path."
                                throw $_
                            }
                        }

                        # Add a deployment type to the application
                        if ($PSCmdlet.ShouldProcess($("$($VcRedist.Name) $($VcRedist.Architecture) $($VcRedist.Version)"), "Adding deployment type")) {

                            # Change to the SMS Application folder before importing the applications
                            try {
                                Set-Location -Path $DestFolder -ErrorAction "Continue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to set location to [$DestFolder]."
                                throw $_
                            }
                            Write-Verbose -Message "Set location to [$DestFolder]."

                            try {
                                # Create the detection method
                                $params = @{
                                    Hive    = "LocalMachine"
                                    Is64Bit = if ($VcRedist.UninstallKey -eq "64") { $true } else { $false }
                                    KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($VcRedist.ProductCode)"
                                }
                                $detectionClause = New-CMDetectionClauseRegistryKey @params

                                # Splat Add-CMScriptDeploymentType parameters and add the application deployment type
                                $cmScriptParams = @{
                                    ApplicationName          = $ApplicationName
                                    InstallCommand           = "$(Split-Path -Path $VcRedist.URI -Leaf) $(if ($Silent) { $VcRedist.SilentInstall } else { $VcRedist.Install })"
                                    ContentLocation          = $ContentLocation
                                    AddDetectionClause       = $detectionClause
                                    DeploymentTypeName       = "SCRIPT_$($VcRedist.Name)"
                                    UserInteractionMode      = "Hidden"
                                    UninstallCommand         = $VcRedist.SilentUninstall
                                    LogonRequirementType     = "WhetherOrNotUserLoggedOn"
                                    InstallationBehaviorType = "InstallForSystem"
                                    Comment                  = "Generated by $($MyInvocation.MyCommand). https://vcredist.com"
                                }
                                Add-CMScriptDeploymentType @cmScriptParams > $null
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to add script deployment type."
                                throw $_
                            }

                            try {
                                Write-Verbose -Message "Setting location to: $Path."
                                Set-Location -Path $Path -ErrorAction "Continue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "Failed to set location to: $Path."
                                throw $_
                            }
                        }
                    }
                }
            }
        }
    }

    end {
        Write-Verbose -Message "Set location to: $Path."
        Set-Location -Path $Path -ErrorAction "SilentlyContinue"
    }
}
