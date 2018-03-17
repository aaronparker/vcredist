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
        Name: Import-VcMdtApp
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://stealthpuppy.com

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
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $False, `
                HelpMessage = "An array containing details of the Visual C++ Redistributables from Get-VcList.")]
        [ValidateNotNull()]
        [array]$VcList,

        [Parameter(Mandatory = $True, Position = 1, HelpMessage = "A folder containing the downloaded Visual C++ Redistributables.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$Path,

        [Parameter(Mandatory = $True, HelpMessage = "The path to the MDT deployment share.")]
        [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
        [string]$MdtPath,

        [Parameter(Mandatory = $False, HelpMessage = "Specify Applications folder to import the VC Redistributables into.")]
        [ValidatePattern('^[a-zA-Z0-9]+$')]
        [ValidateNotNullOrEmpty()]
        [string]$AppFolder = "VcRedists",

        [Parameter(Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
        [string[]]$Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

        [Parameter(Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
        [ValidateSet('x86', 'x64')]
        [string[]]$Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False, HelpMessage = "Add the imported Visual C++ Redistributables into an Application Bundle.")]
        [switch]$Bundle,

        [Parameter()]$MdtDrive = "DS001",
        [Parameter()]$Publisher = "Microsoft",
        [Parameter()]$BundleName = "Visual C++ Redistributables",
        [Parameter()]$Language = "en-US"
    )
    Begin {
        # If we can find the MDT PowerShell module, import it. Requires MDT console to be installed
        $mdtModule = "$((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4" -ErrorAction SilentlyContinue).Install_Dir)bin\MicrosoftDeploymentToolkit.psd1"
        If (Test-Path -Path $mdtModule) {
            Try {            
                Import-Module -Name $mdtModule -ErrorAction SilentlyContinue
            }
            Catch {
                Throw "Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            }
        }
        Else {
            Throw "Cannot find the MDT PowerShell module. Is the MDT console installed?"
        }

        # Create the PSDrive for MDT
        If ($PSCmdlet.ShouldProcess("MDT deployment share $MdtPath", "Mapping")) {
            If (Test-Path -Path "$($MdtDrive):") {
                Write-Verbose "Found existing MDT drive $MdtDrive. Removing."
                Remove-PSDrive -Name $MdtDrive -Force
            }
            New-PSDrive -Name $MdtDrive -PSProvider MDTProvider -Root $MdtPath -ErrorAction SilentlyContinue
            If (!(Test-Path -Path "$($MdtDrive):")) {
                Throw "Failed to map MDT drive: $MdtDrive"
            }
        }

        # Create a sub-folder below Applications to import the Redistributables into, if $AppFolder not null
        # Create $Target as the target Application folder to import into
        If ($AppFolder.Length -ne 0) {
            If (!(Test-Path -Path "$($MdtDrive):\Applications\$($AppFolder)")) {
                If ($PSCmdlet.ShouldProcess("$($MdtDrive):\Applications\$($AppFolder)", "Creating folder")) {
                    New-Item -Path "$($MdtDrive):\Applications" -Enable "True" -Name $AppFolder `
                        -Comments "$($Publisher) $($BundleName)" -ItemType "Folder" -ErrorAction SilentlyContinue
                }
                $Target = "$($MdtDrive):\Applications\$($AppFolder)"
            }
        }
        Else {
            $Target = "$($MdtDrive):\Applications"
        }
    }
    Process {
        # Filter release and architecture if specified
        If ($PSBoundParameters.ContainsKey('Release')) {
            Write-Verbose "Filtering releases for platform."
            $VcList = $VcList | Where-Object { $_.Release -eq $Release }
        }
        If ($PSBoundParameters.ContainsKey('Architecture')) {
            Write-Verbose "Filtering releases for architecture."
            $VcList = $VcList | Where-Object { $_.Architecture -eq $Architecture }
        }

        ForEach ($Vc in $VcList) {
            # Import as an application into MDT
            If ($PSCmdlet.ShouldProcess("$($Vc.Name) in $MdtPath", "Import MDT app")) {

                # Configure parameters
                $Source = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
                $Filename = Split-Path -Path $Vc.Download -Leaf
                $Dir = "$Publisher VcRedist\$($Vc.Release) $($Vc.ShortName) $($Vc.Architecture)"
                $SupportedPlatform = If ($Vc.Architecture -eq "x86") { "All x86 Windows 7 and Newer" } `
                    Else { @("All x64 Windows 7 and Newer", "All x86 Windows 7 and Newer") }

                Import-MDTApplication -Path $Target `
                    -Name "$Publisher $($Vc.Name) $($Vc.Architecture)" `
                    -Enable $True `
                    -Reboot $False `
                    -Hide $(If ($Bundle) {"True"} Else {"False"}) `
                    -Comments "" `
                    -ShortName "$($Vc.Name) $($Vc.Architecture)" `
                    -Version $Vc.Release `
                    -Publisher $Publisher `
                    -Language $Language `
                    -CommandLine ".\$FileName $($Vc.Install)" `
                    -WorkingDirectory ".\Applications\$Dir" `
                    -ApplicationSourcePath $Source `
                    -DestinationFolder $Dir `
                    -UninstallKey $Vc.ProductCode `
                    -SupportedPlatform $SupportedPlatform `
                    -Dependency ""             
            }
        }
    }
    End {
        # Get the imported Visual C++ Redistributables applications to return on the pipeline
        Write-Verbose "Getting Visual C++ Redistributables from the deployment share"
        $Output = Get-ChildItem -Path $Target | Where-Object { $_.Name -like "*Visual C++*" } | `
            ForEach-Object { Get-ItemProperty -Path "$($Target)\$($_.Name)" }

        # Create the application bundle
        If ($Bundle) {
            If ($PSCmdlet.ShouldProcess("$($Publisher) $($BundleName)", "Creating bundle")) {

                # Grab the Visual C++ Redistributable application guids
                $Dependencies = @(); ForEach ( $App in $Output ) { $Dependencies += $App.guid }

                # Import the bundle
                Import-MDTApplication -Path $Target `
                    -Name "$($Publisher) $($BundleName)" `
                    -Enable $True `
                    -Reboot $False `
                    -Hide $False `
                    -Comments "Application bundle for installing Visual C++ Redistributables." `
                    -ShortName $BundleName `
                    -Version "" `
                    -Publisher $Publisher `
                    -Language $Language `
                    -Bundle `
                    -Dependency $Dependencies
            }
        }
        # Return list of apps to the pipeline
        $Output | Select-Object PSChildName, Source, CommandLine, Version, Language, SupportedPlatform, UninstallKey, Reboot
    }
}