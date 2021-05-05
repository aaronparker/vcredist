Function Import-VcMdtApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Import-VcMdtApp")]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/VcRedist/import-vcmdtapplication.html")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path,

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $DontHide,

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Force,

        [Parameter(Mandatory = $False, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $MdtDrive = "DS001",

        [Parameter(Mandatory = $False, Position = 5)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $False, Position = 6)]
        [ValidatePattern('^[a-zA-Z0-9-]+$')]
        [System.String] $Language = "en-US"
    )

    Begin {
        # If running on PowerShell Core, error and exit.
        If (Test-PSCore) {
            Write-Warning -Message "$($MyInvocation.MyCommand): PowerShell Core doesn't support PSSnapins. We can't load the MicrosoftDeploymentToolkit module."
            Throw [System.Management.Automation.InvalidPowerShellStateException]
            Exit
        }

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
                    Exit
                }
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to import the MDT PowerShell module. Please install the MDT Workbench and try again."
            Throw [System.Management.Automation.InvalidPowerShellStateException]
            Exit
        }

        # Create the Application folder
        If ($AppFolder.Length -gt 0) {
            If ($PSCmdlet.ShouldProcess($AppFolder, "Create")) {
                try {
                    $params = @{
                        Drive       = $MdtDrive
                        Name        = $AppFolder
                        Description = "Microsoft Visual C++ Redistributables"
                    }
                    New-MdtApplicationFolder @params > $Null
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Failed to create folder: [$AppFolder]."
                    Throw $_.Exception.Message
                    Exit
                }
            }
            $target = "$($MdtDrive):\Applications\$AppFolder"
        }
        Else {
            $target = "$($MdtDrive):\Applications"
        }
        Write-Verbose -Message "$($MyInvocation.MyCommand): VcRedists will be imported into: $target"

        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Retrieving existing Visual C++ Redistributables from the deployment share"
            $existingVcRedists = Get-ChildItem -Path $target -ErrorAction "SilentlyContinue" | Where-Object { $_.Name -like "*Visual C++*" }
        }
        catch {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed when returning existing VcRedist packages."
        }
    }

    Process {
        ForEach ($VcRedist in $VcList) {

            # Set variables
            Write-Verbose -Message "$($MyInvocation.MyCommand): processing: [$($VcRedist.Name) $($VcRedist.Architecture)]."
            $supportedPlatform = If ($VcRedist.Architecture -eq "x86") {
                @("All x86 Windows 7 and Newer", "All x64 Windows 7 and Newer")
            }
            Else {
                @("All x64 Windows 7 and Newer")
            }

            # Check for existing application by matching current VcRedist
            $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
            $VcMatched = $existingVcRedists | Where-Object { $_.Name -eq $ApplicationName }

            
            # Remove the matched VcRedist application
            If ($PSBoundParameters.ContainsKey("Force")) {
                If ($VcMatched.UninstallKey -eq $VcRedist.ProductCode) {
                    If ($PSCmdlet.ShouldProcess($VcMatched.Name, "Remove")) {
                        try {
                            Remove-Item -Path $("$target\$($VcMatched.Name)") -Force
                        }
                        catch [System.Exception] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to remove item: [$target\$($VcMatched.Name)]."
                            Throw $_.Exception.Message
                            Continue
                        }
                    }
                }
            }

            # Import as an application into the MDT deployment share
            If (Test-Path -Path $("$target\$($VcMatched.Name)") -ErrorAction "SilentlyContinue") {
                Write-Verbose -Message "$($MyInvocation.MyCommand): '$("$target\$($VcMatched.Name)")' exists. Use -Force to overwrite the existing application."
            }
            Else {
                If ($PSCmdlet.ShouldProcess("$($VcRedist.Name) in $MdtPath", "Import")) {
                    try {

                        # Splat the Import-MDTApplication arguments
                        $importMDTAppParams = @{
                            Path                  = $target
                            Name                  = $ApplicationName
                            Enable                = $True
                            Reboot                = $False
                            Hide                  = $(If ($DontHide.IsPresent) { "False" } Else { "True" })
                            Comments              = "Generated by $($MyInvocation.MyCommand)"
                            ShortName             = "$($VcRedist.Name) $($VcRedist.Architecture)"
                            Version               = $VcRedist.Version
                            Publisher             = $Publisher
                            Language              = $Language
                            CommandLine           = ".\$(Split-Path -Path $VcRedist.Download -Leaf) $(If ($Silent.IsPresent) { $VcRedist.SilentInstall } Else { $VcRedist.Install })"
                            ApplicationSourcePath = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                            DestinationFolder     = "$Publisher VcRedist\$($VcRedist.Release)\$($VcRedist.Version)\$($VcRedist.Architecture)"
                            WorkingDirectory      = ".\Applications\$Publisher VcRedist\$($VcRedist.Release)\$($VcRedist.Version)\$($VcRedist.Architecture)"
                            UninstallKey          = $VcRedist.ProductCode
                            SupportedPlatform     = $supportedPlatform
                        }
                        Import-MDTApplication @importMDTAppParams > $Null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Error encountered importing the application: [$($VcRedist.Name) $($VcRedist.Version) $($VcRedist.Architecture)]."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
            }
        }
    }

    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        Write-Verbose -Message "$($MyInvocation.MyCommand): Retrieving Visual C++ Redistributables imported into the deployment share"
        Write-Output -InputObject (Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" } | Select-Object -Property *)
    }
}
