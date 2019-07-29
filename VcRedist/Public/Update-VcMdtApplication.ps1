Function Update-VcMdtApplication {
    <#
        .SYNOPSIS
            Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

        .DESCRIPTION
            Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes properties such as target Silent command line, Platform and Uninstall key.

            Use Get-VcList and Get-VcRedist to download the Redistributables and create the array for importing into MDT.

        .OUTPUTS
            System.Array

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/importing-into-mdt

        .PARAMETER VcList
            An array containing details of the Visual C++ Redistributables from Get-VcList.

        .PARAMETER Path
            A folder containing the downloaded Visual C++ Redistributables.

        .PARAMETER MdtPath
            The local or network path to the MDT deployment share.

        .PARAMETER Silent
            Add a completely silent command line install of the VcRedist with no UI. The default install is passive.

        .EXAMPLE
            Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -Path C:\Temp\VcRedist -MdtPath \\server\deployment

            Description:
            Retrieves the default list of supported Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the MDT deployment share at \\server\deployment.

        .EXAMPLE
            $VcList = Get-VcList -Export All
            Save-VcRedist -VcList $VcList -Path C:\Temp\VcRedist
            Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle

            Description:
            Retrieves the list of supported and unsupported Visual C++ Redistributables in the variable $VcList, downloads them to C:\Temp\VcRedist, imports each Redistributable into the MDT deployment share at \\server\deployment and creates an application bundle.
    #>
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/importing-into-mdt")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path,

        [Parameter(Mandatory = $True)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
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
        [System.String] $Publisher = "Microsoft",

        [Parameter(Mandatory = $False, Position = 4)]
        [ValidatePattern('^[a-zA-Z0-9\+ ]+$')]
        [System.String] $BundleName = "Visual C++ Redistributables",

        [Parameter(Mandatory = $False, Position = 5)]
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
            If ($pscmdlet.ShouldProcess($Path, "Mapping")) {
                try {
                    New-MdtDrive -Drive $MdtDrive -Path $MdtPath -ErrorAction SilentlyContinue | Out-Null
                    Restore-MDTPersistentDrive -Force | Out-Null
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
        If (Test-Path -Path $target -ErrorAction SilentlyContinue) {
            ForEach ($Vc in $VcList) {
                # Set variables
                $vcName = "$Publisher $($Vc.Name) $($Vc.Architecture)"

                try {
                    $gciParams = @{
                        Path        = (Join-Path -Path $target -ChildPath $vcName)
                        ErrorAction = "SilentlyContinue"
                    }
                    $existingVc = Get-ChildItem @gciParams
                }
                catch [System.Exception] {
                    Write-Warning -Message "$($MyInvocation.MyCommand): Failed to retreive the existing application: [$vcName]."
                    Throw $_.Exception.Message
                    Exit
                }
    
                If ($Null -ne $existingVc) {
                    try {
                        If ($existingVc.CommandLine -ne ".\$(Split-Path -Path $Vc.Download -Leaf) $(If ($Silent) { $vc.SilentInstall } Else { $vc.Install })") {
                            If ($PSCmdlet.ShouldProcess($existingVc.PSPath, "Update CommandLine")) {
                                try {
                                    $sipParams = @{
                                        Path  = (Join-Path -Path $target -ChildPath $vcName)
                                        Name  = "CommandLine"
                                        Value = ".\$(Split-Path -Path $Vc.Download -Leaf) $(If ($Silent) { $vc.SilentInstall } Else { $vc.Install })"
                                    }
                                    Set-ItemProperty @sipParams | Out-Null
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist application command line."
                                    Throw $_.Exception.Message
                                    Continue
                                }
                            }
                        }
                        If ($existingVc.UninstallKey -ne $Vc.ProductCode) {
                            If ($PSCmdlet.ShouldProcess($existingVc.PSPath, "Update UninstallKey")) {
                                try {
                                    $sipParams = @{
                                        Path  = (Join-Path -Path $target -ChildPath $vcName)
                                        Name  = "UninstallKey"
                                        Value = $Vc.ProductCode
                                    }
                                    Set-ItemProperty @sipParams | Out-Null
                                }
                                catch [System.Exception] {
                                    Write-Warning -Message "$($MyInvocation.MyCommand): Error updating VcRedist application dependencies."
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
        If (Test-Path -Path $target -ErrorAction SilentlyContinue) {
            # Get the imported Visual C++ Redistributables applications to return on the pipeline
            Write-Verbose -Message "$($MyInvocation.MyCommand): Getting Visual C++ Redistributables from the deployment share"
            Write-Output -InputObject (Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" | Select-Object -Property * })
        }
        Else {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to find path $target."
        }
    }
}
