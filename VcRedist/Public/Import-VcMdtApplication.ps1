Function Import-VcMdtApplication {
    <#
        .SYNOPSIS
            Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

        .DESCRIPTION
            Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes properties such as target Silent command line, Platform and Uninstall key.

            Use Get-VcList and Get-VcRedist to download the Redistributables and create the array for importing into MDT.

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

        .PARAMETER DontHide
            Specify that the option 'Hide this application in the Deployment Wizard' is not selected.

        .PARAMETER AppFolder
            Specify a folder within the Applications node that the VcRedists will be imported into. Defaults to 'VcRedists'.

        .EXAMPLE
            Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApplication -Path C:\Temp\VcRedist -MdtPath \\server\deployment

            Description:
            Retrieves the list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the MDT deployment share at \\server\deployment.

        .EXAMPLE
            $VcList = Get-VcList -ExportAll
            Save-VcRedist -VcList $VcList -Path C:\Temp\VcRedist
            Import-VcMdtApplication -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle

            Description:
            Retrieves the list of supported and unsupported Visual C++ Redistributables in the variable $VcList, downloads them to C:\Temp\VcRedist, imports each Redistributable into the MDT deployment share at \\server\deployment and creates an application bundle.
    #>
    [Alias("Import-VcMdtApp")]
    [CmdletBinding(SupportsShouldProcess = $True, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/importing-into-mdt")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Mandatory = $True, Position = 1)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [System.String] $Path,

        [Parameter(Mandatory = $True, Position = 2)]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
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
            If ($pscmdlet.ShouldProcess($Path, "Mapping")) {
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

        # Create the Application folder
        If ($AppFolder.Length -gt 0) {
            If ($pscmdlet.ShouldProcess($AppFolder, "Create")) {
                try {
                    New-MdtApplicationFolder -Drive $MdtDrive -Name $AppFolder -Description "Microsoft Visual C++ Redistributables" > $Null
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
            $existingVcRedists = Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" }
        }
        catch {
            Write-Error -Message "$($MyInvocation.MyCommand): Failed when returning existing VcRedist packages."
        }
    }

    Process {
        ForEach ($Vc in $VcList) {

            # Set variables
            Write-Verbose -Message "$($MyInvocation.MyCommand): processing: [$($Vc.Name) $($Vc.Architecture)]."
            $supportedPlatform = If ($Vc.Architecture -eq "x86") {
                @("All x86 Windows 7 and Newer", "All x64 Windows 7 and Newer")
            }
            Else {
                @("All x64 Windows 7 and Newer")
            }
            $vcName = "$Publisher $($Vc.Name) $($Vc.Architecture)"

            # Check for existing application by matching current VcRedist
            $vcMatched = $existingVcRedists | Where-Object { $_.Name -eq $vcName }

            If ($Force.IsPresent) {
                If ($vcMatched.UninstallKey -eq $Vc.ProductCode) {
                    If ($PSCmdlet.ShouldProcess($vcMatched.Name, "Remove")) {
                        try {
                            Remove-Item -Path $("$target\$($vcMatched.Name)") -Force
                        }
                        catch [System.Exception] {
                            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to remove item: [$target\$($vcMatched.Name)]."
                            Throw $_.Exception.Message
                            Continue
                        }
                    }
                }
            }

            # Import as an application into the MDT deployment share
            If (Test-Path -Path $("$target\$($vcMatched.Name)") -ErrorAction "SilentlyContinue") {
                Write-Verbose -Message "$($MyInvocation.MyCommand): '$("$target\$($vcMatched.Name)")' exists. Use -Force to overwrite the existing application."
            }
            Else {
                If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $MdtPath", "Import")) {
                    try {
                        # Splat the Import-MDTApplication arguments
                        $importMDTAppParams = @{
                            Path                  = $target
                            Name                  = $vcName
                            Enable                = $True
                            Reboot                = $False
                            Hide                  = $(If ($DontHide.IsPresent) { "False" } Else { "True" })
                            Comments              = "Generated by $($MyInvocation.MyCommand)"
                            ShortName             = "$($Vc.Name) $($Vc.Architecture)"
                            Version               = $Vc.Release
                            Publisher             = $Publisher
                            Language              = $Language
                            CommandLine           = ".\$(Split-Path -Path $Vc.Download -Leaf) $(If ($Silent.IsPresent) { $vc.SilentInstall } Else { $vc.Install })"
                            WorkingDirectory      = ".\Applications\$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                            ApplicationSourcePath = "$(Get-ValidPath $Path)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                            DestinationFolder     = "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                            UninstallKey          = $Vc.ProductCode
                            SupportedPlatform     = $supportedPlatform
                        }
                        Import-MDTApplication @importMDTAppParams > $Null
                    }
                    catch [System.Exception] {
                        Write-Warning -Message "$($MyInvocation.MyCommand): Error encountered importing the application: [$($Vc.Name) $($Vc.Architecture)]."
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
