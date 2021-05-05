Function Update-VcMdtApplication {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://stealthpuppy.com/VcRedist/update-vcmdtapplication.html")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path,

        [Parameter(Mandatory = $True)]
        [ValidateScript( { If (Test-Path -Path $_ -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $MdtPath,

        [Parameter(Mandatory = $False)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [System.String] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $Silent,

        [Parameter(Mandatory = $False, Position = 2)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $MdtDrive = "DS001",

        [Parameter(Mandatory = $False, Position = 3)]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [System.String] $Publisher = "Microsoft"
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
            If ($PSCmdlet.ShouldProcess($MdtPath, "Mapping")) {
                try {
                    New-MdtDrive -Drive $MdtDrive -Path $MdtPath -ErrorAction "SilentlyContinue" > $Null
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

        $target = "$($MdtDrive):\Applications\$AppFolder"
        Write-Verbose -Message "$($MyInvocation.MyCommand): Update applications in: $target"
    }

    Process {
        If (Test-Path -Path $target -ErrorAction "SilentlyContinue") {
            ForEach ($VcRedist in $VcList) {
                
                # Set variables
                $ApplicationName = "Visual C++ Redistributable $($VcRedist.Release) $($VcRedist.Architecture) $($VcRedist.Version)"
                Write-Verbose -Message "$($MyInvocation.MyCommand): Update application: [$ApplicationName]."

                # Get the existing VcRedist applications in the MDT share
                try {
                    $gciParams = @{
                        Path        = (Join-Path -Path $target -ChildPath $ApplicationName)
                        ErrorAction = "SilentlyContinue"
                    }
                    $existingVc = Get-ChildItem @gciParams
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retrieve the existing application: [$ApplicationName]."
                    Throw $_.Exception.Message
                    Break
                }
    
                If ($Null -ne $existingVc) {
                    try {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Found application: [$ApplicationName]."
                        If ($existingVc.CommandLine -ne ".\$(Split-Path -Path $VcRedist.Download -Leaf) $(If ($Silent) { $VcRedist.SilentInstall } Else { $VcRedist.Install })") {
                            
                            # Check the existing command line on the application and update
                            Write-Verbose -Message "$($MyInvocation.MyCommand): Updating command line."
                            If ($PSCmdlet.ShouldProcess($existingVc.PSPath, "Update CommandLine")) {
                                try {
                                    $sipParams = @{
                                        Path  = (Join-Path -Path $target -ChildPath $ApplicationName)
                                        Name  = "CommandLine"
                                        Value = ".\$(Split-Path -Path $VcRedist.Download -Leaf) $(If ($Silent) { $VcRedist.SilentInstall } Else { $VcRedist.Install })"
                                    }
                                    Set-ItemProperty @sipParams > $Null
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist application command line."
                                    Throw $_.Exception.Message
                                    Continue
                                }
                            }
                        }
                        
                        # Determine whether update is required
                        $Update = $False
                        If ($existingVc.UninstallKey -ne $VcRedist.ProductCode) { $Update = $True }
                        If ($existingVc.Version -ne $VcRedist.Version) { $Update = $True }
                        If ($existingVc.CommandLine -ne ".\$(Split-Path -Path $VcRedist.Download -Leaf) $(If ($Silent.IsPresent) { $VcRedist.SilentInstall } Else { $VcRedist.Install })") { $Update = $True }

                        If ($Update -eq $True) {
                            If ($PSCmdlet.ShouldProcess($existingVc.PSPath, "Updating VcRedist application")) {
                                
                                # Copy the updated executable
                                try {
                                    Write-Verbose -Message "$($MyInvocation.MyCommand): Copy VcRedist installer."
                                    $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                                    $ContentLocation = [System.IO.Path]::Combine((Resolve-Path -Path $MdtPath), "Applications", "$Publisher VcRedist", $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
                                    $invokeProcessParams = @{
                                        FilePath     = "$env:SystemRoot\System32\robocopy.exe"
                                        ArgumentList = "*.exe `"$folder`" `"$ContentLocation`" /S /XJ /R:1 /W:1 /NP /NJH /NJS /NFL /NDL"
                                    }
                                    $result = Invoke-Process @invokeProcessParams
                                }
                                catch {
                                    $Target = Join-Path -Path $ContentLocation -ChildPath $(Split-Path -Path $VcRedist.Download -Leaf)
                                    If (Test-Path -Path $Target -ErrorAction "SilentlyContinue") {
                                        Write-Verbose -Message "$($MyInvocation.MyCommand): Copy successful: [$Target]."
                                    }
                                    Else {
                                        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to copy Redistributables from [$folder] to [$ContentLocation]."
                                        Write-Warning -Message "$($MyInvocation.MyCommand): Captured error (if any): [$result]."
                                        Throw $_.Exception.Message
                                        Break
                                    }
                                }

                                # Update ProductCode
                                try {
                                    Write-Verbose -Message "$($MyInvocation.MyCommand): Updating product code."
                                    $sipParams = @{
                                        Path  = (Join-Path -Path $target -ChildPath $ApplicationName)
                                        Name  = "UninstallKey"
                                        Value = $VcRedist.ProductCode
                                    }
                                    Set-ItemProperty @sipParams > $Null
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist UninstallKey."
                                    Throw $_.Exception.Message
                                    Continue
                                }

                                # Update Version number
                                try {
                                    Write-Verbose -Message "$($MyInvocation.MyCommand): Updating product code."
                                    $sipParams = @{
                                        Path  = (Join-Path -Path $target -ChildPath $ApplicationName)
                                        Name  = "Version"
                                        Value = $VcRedist.Version
                                    }
                                    Set-ItemProperty @sipParams > $Null
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist Version."
                                    Throw $_.Exception.Message
                                    Continue
                                }

                                # Update CommandLine
                                try {
                                    Write-Verbose -Message "$($MyInvocation.MyCommand): Updating product code."
                                    $sipParams = @{
                                        Path  = (Join-Path -Path $target -ChildPath $ApplicationName)
                                        Name  = "CommandLine"
                                        Value = ".\$(Split-Path -Path $VcRedist.Download -Leaf) $(If ($Silent.IsPresent) { $VcRedist.SilentInstall } Else { $VcRedist.Install })"
                                    }
                                    Set-ItemProperty @sipParams > $Null
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist CommandLine."
                                    Throw $_.Exception.Message
                                    Continue
                                }
                            }
                        }
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist application."
                        Throw $_.Exception.Message
                        Continue
                    }
                }
            }
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to find path $target."
        }
    }

    End {
        If (Test-Path -Path $target -ErrorAction "SilentlyContinue") {
            
            # Get the imported Visual C++ Redistributables applications to return on the pipeline
            Write-Verbose -Message "$($MyInvocation.MyCommand): Getting Visual C++ Redistributables from the deployment share"
            Write-Output -InputObject (Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" | Select-Object -Property * })
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to find path $target."
        }
    }
}
