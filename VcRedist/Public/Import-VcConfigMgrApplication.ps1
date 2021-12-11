Function Import-VcConfigMgrApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias('Import-VcCmApp')]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/vcredist/import-vcconfigmgrapplication/")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_." } })]
        [System.String] $Path,

        [Parameter(Mandatory = $True, Position = 2)]
        [System.String] $CMPath,

        [Parameter(Mandatory = $True, Position = 3)]
        [ValidateScript( { If ($_ -match "^[a-zA-Z0-9]{3}$") { $True } Else { Throw "$_ is not a valid ConfigMgr site code." } })]
        [System.String] $SMSSiteCode,

        [Parameter(Mandatory = $False, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $NoCopy,

        [Parameter(Mandatory = $False, Position = 5)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $False, Position = 6)]
        [ValidatePattern('^[a-zA-Z0-9\+ ]+$')]
        [System.String] $Keyword = "Visual C++ Redistributable"
    )

    Begin {
        #region CMPath will be the network location for copying the Visual C++ Redistributables to
        try {
            Set-Location -Path $Path -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to set location to [$Path]."
            Throw $_.Exception.Message
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand): Set location to [$Path]."
        #endregion

        #region Validate $CMPath
        If (Resolve-Path -Path $CMPath) {
            $CMPath = $CMPath.TrimEnd("\")

            #region If the ConfigMgr console is installed, load the PowerShell module; Requires PowerShell module to be installed
            If (Test-Path -Path env:SMS_ADMIN_UI_PATH -ErrorAction "SilentlyContinue") {
                try {
                    # Import the ConfigurationManager.psd1 module
                    Write-Verbose -Message "$($MyInvocation.MyCommand): Importing module: $($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1."
                    Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" -Verbose:$False > $Null

                    # Create the folder for importing the Redistributables into
                    If ($AppFolder) {
                        $DestFolder = "$($SMSSiteCode):\Application\$($AppFolder)"
                        If ($PSCmdlet.ShouldProcess($DestFolder, "Creating")) {
                            try {
                                New-Item -Path $DestFolder -ErrorAction "SilentlyContinue" > $Null
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create folder: [$DestFolder]."
                                Throw $_.Exception.Message
                            }
                        }
                        If (Test-Path -Path $DestFolder -ErrorAction "SilentlyContinue") {
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Importing into: [$DestFolder]."
                        }
                    }
                    Else {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Importing into: [$($SMSSiteCode):\Application]."
                        $DestFolder = "$($SMSSiteCode):\Application"
                    }
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed."
                    Throw $_.Exception.Message
                }
            }
            Else {
                Write-Warning -Message "$($MyInvocation.MyCommand): Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr console and PowerShell module installed?"
                Break
            }
            #endregion
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Unable to confirm $CMPath exists. Please check that $CMPath is valid."
            Break
        }
        #endregion
    }

    Process {
        ForEach ($VcRedist in $VcList) {
            Write-Verbose -Message "Importing VcRedist app: [Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)]"

            # If SMS_ADMIN_UI_PATH variable exists, assume module imported successfully earlier
            If (Test-Path -Path env:SMS_ADMIN_UI_PATH -ErrorAction "SilentlyContinue") {

                # Import as an application into ConfigMgr
                If ($PSCmdlet.ShouldProcess("$($VcRedist.Name) in $CMPath", "Import ConfigMgr app")) {

                    # Create the ConfigMgr application with properties from the manifest
                    If ((Get-Item -Path $DestFolder).PSDrive.Name -eq $SMSSiteCode) {
                        If ($PSCmdlet.ShouldProcess($VcRedist.Name + " $($VcRedist.Architecture)", "Creating ConfigMgr application")) {

                            # Build paths
                            $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                            $ContentLocation = [System.IO.Path]::Combine($CMPath, $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)

                            #region Copy VcRedists to the network location. Use robocopy for robustness
                            If ($NoCopy) {
                                Write-Warning -Message "$($MyInvocation.MyCommand): NoCopy specified, skipping copy to $ContentLocation. Ensure VcRedists exist in the target."
                            }
                            Else {
                                If ($PSCmdlet.ShouldProcess("$($folder) to $($ContentLocation)", "Copy")) {
                                    try {
                                        If (!(Test-Path -Path $ContentLocation -ErrorAction "SilentlyContinue")) {
                                            New-Item -Path $ContentLocation -ItemType "Directory" -ErrorAction "SilentlyContinue" > $Null
                                        }
                                    }
                                    catch {
                                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create: [$ContentLocation]."
                                        Throw $_.Exception.Message
                                    }
                                    try {
                                        $invokeProcessParams = @{
                                            FilePath     = "$env:SystemRoot\System32\robocopy.exe"
                                            ArgumentList = "*.exe `"$folder`" `"$ContentLocation`" /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL"
                                        }
                                        $result = Invoke-Process @invokeProcessParams
                                    }
                                    catch [System.Exception] {
                                        $Target = Join-Path -Path $ContentLocation -ChildPath $(Split-Path -Path $VcRedist.Download -Leaf)
                                        If (Test-Path -Path $Target -ErrorAction "SilentlyContinue") {
                                            Write-Verbose -Message "$($MyInvocation.MyCommand): Copy successful: [$Target]."
                                        }
                                        Else {
                                            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to copy Redistributables from [$folder] to [$ContentLocation]."
                                            Write-Warning -Message "$($MyInvocation.MyCommand): Captured error (if any): [$result]."
                                            Throw $_.Exception.Message
                                        }
                                    }
                                }
                            }
                            #endregion

                            # Change to the SMS Application folder before importing the applications
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Setting location to $($DestFolder)"
                            try {
                                Set-Location -Path $DestFolder -ErrorAction "SilentlyContinue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to set location to [$DestFolder]."
                                Throw $_.Exception.Message
                            }

                            try {
                                # Splat New-CMApplication parameters, add the application and move into the target folder
                                $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
                                $cmAppParams = @{
                                    Name              = $ApplicationName
                                    Description       = "$Publisher $ApplicationName imported by $($MyInvocation.MyCommand)"
                                    SoftwareVersion   = $VcRedist.Version
                                    LinkText          = $VcRedist.URL
                                    Publisher         = $Publisher
                                    Keyword           = $Keyword
                                    ReleaseDate       = $(Get-Date -Format (([System.Globalization.CultureInfo]::CurrentUICulture.DateTimeFormat).ShortDatePattern))
                                    PrivacyUrl        = "https://go.microsoft.com/fwlink/?LinkId=521839"
                                    UserDocumentation = "https://visualstudio.microsoft.com/vs/support/"
                                }
                                $app = New-CMApplication @cmAppParams
                                If ($AppFolder) {
                                    $app | Move-CMObject -FolderPath $DestFolder -ErrorAction "SilentlyContinue" > $Null
                                }
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create application $($VcRedist.Name) $($VcRedist.Architecture)."
                                Throw $_.Exception.Message
                            }
                            finally {
                                # Write app detail to the pipeline
                                Write-Output -InputObject $app
                            }

                            try {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Setting location to [$Path]."
                                Set-Location -Path $Path -ErrorAction "SilentlyContinue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to set location to [$Path]."
                                Throw $_.Exception.Message
                            }
                        }

                        # Add a deployment type to the application
                        If ($PSCmdlet.ShouldProcess($("$($VcRedist.Name) $($VcRedist.Architecture) $($VcRedist.Version)"), "Adding deployment type")) {

                            # Change to the SMS Application folder before importing the applications
                            try {
                                Set-Location -Path $DestFolder -ErrorAction "SilentlyContinue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to set location to [$DestFolder]."
                                Throw $_.Exception.Message
                            }
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Set location to [$DestFolder]."

                            try {
                                # Create the detection method
                                $params = @{
                                    Hive    = "LocalMachine"
                                    Is64Bit = If ($VcRedist.UninstallKey -eq "64") { $True } Else { $False }
                                    KeyName = "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\$($VcRedist.ProductCode)"
                                }
                                $detectionClause = New-CMDetectionClauseRegistryKey @params

                                # Splat Add-CMScriptDeploymentType parameters and add the application deployment type
                                $cmScriptParams = @{
                                    ApplicationName          = $ApplicationName
                                    InstallCommand           = "$(Split-Path -Path $VcRedist.Download -Leaf) $(If ($Silent) { $VcRedist.SilentInstall } Else { $VcRedist.Install })"
                                    ContentLocation          = $ContentLocation
                                    AddDetectionClause       = $detectionClause
                                    DeploymentTypeName       = "SCRIPT_$($VcRedist.Name)"
                                    UserInteractionMode      = "Hidden"
                                    UninstallCommand         = $VcRedist.SilentUninstall
                                    LogonRequirementType     = "WhetherOrNotUserLoggedOn"
                                    InstallationBehaviorType = "InstallForSystem"
                                    Comment                  = "Generated by $($MyInvocation.MyCommand)"
                                }
                                Add-CMScriptDeploymentType @cmScriptParams > $Null
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to add script deployment type."
                                Throw $_.Exception.Message
                            }

                            try {
                                Write-Verbose -Message "$($MyInvocation.MyCommand): Setting location to [$Path]."
                                Set-Location -Path $Path -ErrorAction "SilentlyContinue"
                            }
                            catch [System.Exception] {
                                Write-Warning -Message "$($MyInvocation.MyCommand): Failed to set location to [$Path]."
                                Throw $_.Exception.Message
                            }
                        }
                    }
                }
            }
        }
    }

    End {
        try {
            Set-Location -Path $Path -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to set location to [$Path]."
            Throw $_.Exception.Message
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand): Set location to [$Path]."
    }
}
