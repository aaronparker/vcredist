Function Import-VcMdtApp {
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
            https://github.com/aaronparker/Install-VisualCRedistributables

        .PARAMETER VcList
            An array containing details of the Visual C++ Redistributables from Get-VcList.

        .PARAMETER Path
            A folder containing the downloaded Visual C++ Redistributables.

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to import into MDT.

        .PARAMETER Architecture
            Specifies the processor architecture to import into MDT. Can be x86 or x64.

        .PARAMETER MdtPath
            The local or network path to the MDT deployment share.

        .PARAMETER Silent
            Add a completely silent command line install of the VcRedist with no UI. The default install is passive.

        .PARAMETER Bundle
            Add to create an Application Bundle named 'Visual C++ Redistributables' to simplify installing the Redistributables.

        .EXAMPLE
            Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -Path C:\Temp\VcRedist -MdtPath \\server\deployment

            Description:
            Retrieves the list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the MDT deployment share at \\server\deployment.

        .EXAMPLE
            $VcList = Get-VcList -Export All
            Get-VcRedist -VcList $VcList -Path C:\Temp\VcRedist
            Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle

            Description:
            Retrieves the list of supported and unsupported Visual C++ Redistributables in the variable $VcList, downloads them to C:\Temp\VcRedist, imports each Redistributable into the MDT deployment share at \\server\deployment and creates an application bundle.
    #>
    [CmdletBinding(SupportsShouldProcess = $True)]
    [OutputType([Array])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [array] $VcList,

        [Parameter(Mandatory = $True, Position = 1, `
                HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $Path,

        [Parameter(Mandatory = $True, HelpMessage = "The path to the MDT deployment share.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string] $MdtPath,

        [Parameter(Mandatory = $False, HelpMessage = "Specify Applications folder to import the VC Redistributables into.")]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [string] $AppFolder = "VcRedists",

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]] $Release = @("2008", "2010", "2012", "2013", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False, HelpMessage = "Add the imported Visual C++ Redistributables into an Application Bundle.")]
        [switch] $Bundle,

        [Parameter(Mandatory = $False, HelpMessage = "Set a silent install command line.")]
        [switch] $Silent,

        [Parameter()][string] $mdtDrive = "DS001",
        [Parameter()][string] $Publisher = "Microsoft",
        [Parameter()][string] $BundleName = "Visual C++ Redistributables",
        [Parameter()][string] $Language = "en-US",
        [Parameter()][string] $Comments = "Application bundle for installing Visual C++ Redistributables."
    )
    Begin {

        # Import the MDT module and create a PS drive to MdtPath
        If (Import-MdtModule) {
            If ($PSCmdlet.ShouldProcess("MDT deployment share $MdtPath", "Mapping")) {
                If (Test-Path -Path "$($mdtDrive):") {
                    Write-Verbose "Found existing MDT drive $mdtDrive. Removing."
                    Remove-PSDrive -Name $mdtDrive -Force
                }
                try {
                    New-PSDrive -Name $mdtDrive -PSProvider MDTProvider -Root $MdtPath -ErrorAction SilentlyContinue
                }
                catch {
                    Throw "Failed to map MDT drive: $mdtDrive"
                }
                finally {
                    # Create a sub-folder below Applications to import the Redistributables into, if $AppFolder not null
                    # Create $target as the target Application folder to import into
                    If ($AppFolder.Length -ne 0) {
                        $target = "$($mdtDrive):\Applications\$($AppFolder)"

                        If (!(Test-Path -Path "$($mdtDrive):\Applications\$($AppFolder)")) {
                            If ($PSCmdlet.ShouldProcess("$($mdtDrive):\Applications\$($AppFolder)", "Creating folder")) {

                                # Splat New-Item parameters
                                $newItemParams = @{
                                    Path        = "$($mdtDrive):\Applications"
                                    Enable      = "True"
                                    Name        = $AppFolder
                                    Comments    = "$($Publisher) $($BundleName)"
                                    ItemType    = "Folder"
                                    ErrorAction = "SilentlyContinue"
                                }

                                # Create -AppFolder below Applications
                                try {
                                    New-Item @newItemParams
                                }
                                catch {
                                    Throw "Unable to create MDT Applications folder: $AppFolder"
                                }
                            }
                        }
                    }
                    Else {
                        $target = "$($mdtDrive):\Applications"
                    }
                    Write-Verbose "Importing applications into $target"
                }
            }
        }
        Else {
            Throw "Could not load MDT PowerShell module. Please make sure that the MDT console is installed correctly."
        }

        # Filter release and architecture
        Write-Verbose "Filtering releases for platform and architecture."
        $filteredVcList = $VcList | Where-Object { $Release -contains $_.Release } | Where-Object { $Architecture -contains $_.Architecture }
    }
    Process {
        ForEach ($Vc in $filteredVcList) {
            # Import as an application into MDT
            If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $MdtPath", "Import MDT app")) {

                # Supported platforms might be better coming from the XML manifest
                # This is basically hard coding the target platform
                $supportedPlatform = If ($Vc.Architecture -eq "x86") {
                    @("All x86 Windows 7 and Newer", "All x64 Windows 7 and Newer") 
                }
                Else { "All x64 Windows 7 and Newer" }

                # The target directory
                $dir = "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"

                # Splat the Import-MDTApplication arguments
                $importMDTAppParams = @{
                    Path                  = $target
                    Name                  = "$Publisher $($Vc.Name) $($Vc.Architecture)"
                    Enable                = $True
                    Reboot                = $False
                    Hide                  = $(If ($Bundle) {"True"} Else {"False"})
                    Comments              = "Generated by $($MyInvocation.MyCommand)"
                    ShortName             = "$($Vc.Name) $($Vc.Architecture)"
                    Version               = $Vc.Release
                    Publisher             = $Publisher
                    Language              = $Language
                    CommandLine           = ".\$(Split-Path -Path $Vc.Download -Leaf) $(If($Silent) { $vc.SilentInstall } Else { $vc.Install })"
                    WorkingDirectory      = ".\Applications\$dir"
                    ApplicationSourcePath = "$(Get-ValidPath $Path)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                    DestinationFolder     = $dir
                    UninstallKey          = $Vc.ProductCode
                    SupportedPlatform     = $supportedPlatform
                    Dependency            = ""
                }

                # Import the application into the MDT deployment share
                try {
                    Import-MDTApplication @importMDTAppParams
                }
                catch {
                    Throw "Error encountered importing the application - $($Vc.Name) $($Vc.Architecture)."
                }
            }
        }
    }
    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        try {
            Test-Path $target > $Null
        }
        catch {
            Throw "Unable to find path $target."
        }
        finally {
            Write-Verbose "Getting Visual C++ Redistributables from the deployment share"
            $importedVcRedists = Get-ChildItem -Path $target | Where-Object { $_.Name -like "*Visual C++*" } | `
                ForEach-Object { Get-ItemProperty -Path "$($target)\$($_.Name)" }
        }

        # Create the application bundle
        If ($Bundle) {
            If ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Creating bundle")) {

                # Grab the Visual C++ Redistributable application guids; Sort added VcRedists by version so they are ordered correctly
                $importedVcRedists = $importedVcRedists | Sort-Object -Property Version
                $dependencies = @(); ForEach ( $App in $importedVcRedists ) { $dependencies += $App.guid }

                # Splat the Import-MDTApplication parameters
                $importMDTAppParams = @{
                    Path       = $target
                    Name       = "$($Publisher) $($BundleName)"
                    Enable     = $True
                    Reboot     = $False
                    Hide       = $False
                    Comments   = $Comments
                    ShortName  = $BundleName
                    Version    = ""
                    Publisher  = $Publisher
                    Language   = $Language
                    Dependency = $dependencies
                }

                # Import the bundle
                try {
                    Import-MDTApplication @importMDTAppParams -Bundle
                }
                catch {
                    Throw "Error importing the VcRedist bundle."
                }
            }
        }

        # Return list of apps to the pipeline
        Write-Output ($importedVcRedists | Select-Object PSChildName, Source, CommandLine, Version, Language, SupportedPlatform, UninstallKey, Reboot)
    }
}
