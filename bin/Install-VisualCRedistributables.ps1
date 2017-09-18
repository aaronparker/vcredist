<#
    .SYNOPSIS
        Installs and/or downloads the Visual C++ Redistributables listed in an external XML file.

    .DESCRIPTION
        This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents release and processor architecture. If the redistributable exists in the specified path, it will not be re-downloaded.

        In addition the script can optionally perform one of 3 tasks:
         1. Install the redistributables on the local machine
         2. Create a single application in MDT to install the redistributables
         3. Create an application for each redistributable in ConfigMgr.

        You can filter on redistributable releases and processor architectures with the -Release and -Architecture parameters.

        A complete XML file listing the redistributables is included. The basic structure of the XML file should be:

        <Redistributables>
            <Platform Architecture="x64" Release="" Install="">
                <Redistributable>
                    <Name></Name>
                    <ShortName></ShortName>
                    <URL></URL>
                    <ProductCode></ProductCode>
                    <Download></Download>
            </Platform>
            <Platform Architecture="x86" Release="" Install="">
                <Redistributable>
                    <Name></Name>
                    <ShortName></ShortName>
                    <URL></URL>
                    <ProductCode></ProductCode>
                    <Download></Download>
                </Redistributable>
            </Platform>
        </Redistributables>

    .NOTES
        Name: Install-VisualCRedistributables.ps1
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .PARAMETER Xml
        The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml"

        Description:
        Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .PARAMETER Path
        Specify a target folder to download the Redistributables to, otherwise use the current folder.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path C:\Redist

        Description:
        Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

    .PARAMETER Release
        Specifies the release (or version) of the redistributables to download or install.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Release "2012","2013",2017"

        Description:
        Downloads only the 2012, 2013 & 2017 releases of the  Visual C++ Redistributables listed in VisualCRedistributables.xml

    .PARAMETER Architecture
        Specifies the processor architecture to download or install.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Architecture "x64"

        Description:
        Downloads only the 64-bit versions of the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .PARAMETER Install
        By default the script will only download the Redistributables. Add -Install to install each of the Redistributables as well.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Install

        Description:
        Downloads and installs the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .PARAMETER CreateCMApp
        Switch parameter to create ConfigMgr apps from downloaded redistributables.

    .Parameter SMSSiteCode
        Specify the Site Code for ConfigMgr app creation.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path \\server1\Sources\Apps\VSRedist -CreateCMApp -SMSSiteCode S01

        Description:
        Downloads Visual C++ Redistributables listed in VisualCRedistributables.xml and creates ConfigMgr Applications for the selected Site.

    .PARAMETER CreateMDTApp
        Switch parameter to create a single MDT apps for the downloaded redistributables.

    .Parameter MDTPath
        Specify the root path to the MDT deployment share.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -CreateMDTApp -MDTPath \\server1\deploymentshare

        Description:
        Downloads Visual C++ Redistributables listed in VisualCRedistributables.xml and creates a single MDT application in the deployment share \\server1\deploymentshare.
#>

# Parameter sets here means that Install, MDT and ConfigMgr actions are mutually exclusive
[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low", DefaultParameterSetName='Base')]
PARAM (
    [Parameter(ParameterSetName='Base', Mandatory=$True, HelpMessage="The path to the XML document describing the Redistributables.")]
    [Parameter(ParameterSetName='Install')]
    [Parameter(ParameterSetName='ConfigMgr')]
    [Parameter(ParameterSetName='MDT')]
    [ValidateScript({ If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
    [string]$Xml,

    [Parameter(ParameterSetName='Base', Mandatory=$False, HelpMessage="Specify a target path to download the Redistributables to.")]
    [Parameter(ParameterSetName='Install')]
    [Parameter(ParameterSetName='ConfigMgr')]
    [ValidateScript({ If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
    [string]$Path = ".\",

    [Parameter(ParameterSetName='Base', Mandatory=$False, HelpMessage="Specify the version of the Redistributables to install.")]
    [Parameter(ParameterSetName='Install')]
    [Parameter(ParameterSetName='ConfigMgr')]
    [ValidateSet('2005','2008','2010','2012','2013','2015','2017')]
    [string[]]$Release = @("2008","2010","2012","2013","2015","2017"),

    [Parameter(ParameterSetName='Base', Mandatory=$False, HelpMessage="Specify the processor architecture/s to install.")]
    [Parameter(ParameterSetName='Install')]
    [Parameter(ParameterSetName='ConfigMgr')]
    [ValidateSet('x86','x64')]
    [string[]]$Architecture = @("x86","x64"),

    [Parameter(ParameterSetName='Install', Mandatory=$True, HelpMessage="Enable the installation of the Redistributables after download.")]
    [switch]$Install,

    [Parameter(ParameterSetName='ConfigMgr', Mandatory=$True, HelpMessage="Create Redistributable applications in ConfigMgr.")]
    [switch]$CreateCMApp,

    [Parameter(ParameterSetName='ConfigMgr', Mandatory=$True, HelpMessage="Specify ConfigMgr Site Code.")]
    [ValidateScript({ If ($_ -match "^[a-zA-Z0-9]{3}$") { $True } Else { Throw "$_ is not a valid ConfigMgr site code." } })]
    [string]$SMSSiteCode,

    [Parameter(ParameterSetName='MDT', Mandatory=$True, HelpMessage="Create Redistributable applications in the Microsoft Deployment Toolkit.")]
    [switch]$CreateMDTApp,

    [Parameter(ParameterSetName='MDT', Mandatory=$True, HelpMessage="The path to the MDT deployment share root.")]
    [ValidateScript({ If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
    [string]$MDTPath
)

BEGIN {
    # Get script elevation status
    # [bool]$Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    # Test $Path and throw an error if we can't find it
    # Have an issue with ValidateScript when we change $Path when creating an MDT application
    # If (!(Test-Path $Path -PathType 'Container')) { Throw "Cannot find path $Path." }

    ##### If CreateCMApp parameter specified, load the Configuration Manager module
    If ($CreateCMApp) {

        # If import apps into ConfigMgr, the download location will have to be a UNC path
        If (!([bool]([System.Uri]$Path).IsUnc)) { Throw "$Path must be a valid UNC path." }
        If (!(Test-Path $Path)) { Throw "Unable to confirm $Path exists. Please check that $Path is valid." }

        # If the ConfigMgr console is installed, load the PowerShell module
        # Requires PowerShell module to be installed
        If (Test-Path env:SMS_ADMIN_UI_PATH) {
            Try {
                Import-Module "$($env:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module
            }
            Catch {
                Throw "Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed."
            }
        } Else {
            Throw "Cannot find environment variable SMS_ADMIN_UI_PATH. Is the ConfigMgr Console and PowerShell module installed?"
        }
    }

    ##### If CreateMDTApp parameter specified, load the MDT module
    If ($CreateMDTApp) {
        $mdtDrive = "DS001"
        $tempFolder = "$env:Temp\Install-VisualCRedistributables"
        $publisher = "Microsoft"
        $shortName = "Visual C++ Redistributables"

        # If we can find the MDT PowerShell module, import it. Requires MDT console to be installed
        $mdtModule = "$((Get-ItemProperty "HKLM:SOFTWARE\Microsoft\Deployment 4").Install_Dir)bin\MicrosoftDeploymentToolkit.psd1"
        If (Test-Path -Path $mdtModule) {
            Try {
                Import-Module -Name $mdtModule
            }
            Catch {
                Throw "Could not load MDT PowerShell Module. Please make sure that the MDT console is installed correctly."
            }
        } Else {
            Throw "Cannot find the MDT PowerShell module. Is the MDT console installed?"
        }

        If ($pscmdlet.ShouldProcess("Script and XML for import.", "Copy")) {
            # Copy the script and XML file to a temporary folder for importing
            Write-Verbose "Creating folder: $tempFolder"
            New-Item "$tempFolder" -Type Directory | Out-Null
            Copy-Item $MyInvocation.MyCommand.Definition $tempFolder
            Copy-Item $Xml $tempFolder
        }

        # Create the PSDrive for MDT
        If ($pscmdlet.ShouldProcess("Mapping PSDrive to MDT deployment share $MDTPath", "Mapping")) {
            If (Test-Path "$($mdtDrive):") {
                Write-Verbose "Found existing MDT drive $mdtDrive. Removing."
                Remove-PSDrive -Name $mdtDrive -Force
            }
            New-PSDrive -Name $mdtDrive -PSProvider MDTProvider -Root $MDTPath
        }

        If ($pscmdlet.ShouldProcess("$shortName in $MDTPath", "Import MDT app")) {

            If (!(Test-Path("$($mdtDrive):.\Applications\$publisher $shortName"))) {

                # Convert arrays to strings to pass to the MDT command line
                $cRelease = [system.String]::Join(",", $Release)
                $cArchitecture = [system.String]::Join(",", $Architecture)

                $filename = $xml.Substring($xml.LastIndexOf("\") + 1)
                $CommandLine = "powershell.exe -ExecutionPolicy Bypass -NonInteractive -WindowStyle Minimized -File .\$($MyInvocation.MyCommand.Name) -Xml '.\$filename' -Install"

                # Import as an application into MDT
                Import-MDTApplication -path "$($mdtDrive):\Applications" -enable "True" `
                -Name "$publisher $shortName" `
                -ShortName $shortName `
                -Version "" -Publisher $publisher -Language "en-US" `
                -CommandLine $CommandLine `
                -WorkingDirectory ".\Applications\$publisher $shortName" `
                -ApplicationSourcePath $tempFolder `
                -DestinationFolder "$publisher $shortName"
            } Else {
                Throw "Application: '$publisher $shortName' already exists in the specified MDT deployment share."
            }
        }

        # Remove the temporary folder
        If ($pscmdlet.ShouldProcess($tempFolder, "Remove")) {
            Remove-Item "$tempFolder" -Recurse -Force
        }

        # Update Path to point to the MDT application location
        # Script will then download the redistributables there for install at deployment time
        Remove-Variable Path
        $Path = "$MDTPath\Applications\$publisher $shortName"
        If ($pscmdlet.ShouldProcess($Path, "Create")) {
            If (!(Test-Path $Path)) { New-Item -Path $Path -Type 'Directory' -Force | Out-Null }
        }
    }
}

PROCESS {

    # Read the specifed XML document
    Try {
        [xml]$xmlDocument = Get-Content -Path $Xml -ErrorVariable xmlReadError
    }
    Catch {
        Throw "Unable to read $Xml. $xmlReadError"
    }

    ##### If -Release and -Architecture are specified, filter the XML content
    If ($PSBoundParameters.ContainsKey('Release') -or $PSBoundParameters.ContainsKey('Architecture')) {

            # Create an array that we'll add the filtered XML content to
            $xmlContent = @()

            # If -Release alone is specified, filter on platform
            If ($PSBoundParameters.ContainsKey('Release') -and (!($PSBoundParameters.ContainsKey('Architecture')))) {
                ForEach ($rel in $Release) {
                    $xmlContent += (Select-Xml -XPath "/Redistributables/Platform[@Release='$rel']" -Xml $xmlDocument).Node
                }
            }
            # If -Architecture alone is specified, filter on architecture
            If ($PSBoundParameters.ContainsKey('Architecture') -and (!($PSBoundParameters.ContainsKey('Release')))) {
                ForEach ($arch in $Architecture) {
                    $xmlContent += (Select-Xml -XPath "/Redistributables/Platform[@Architecture='$arch']" -Xml $xmlDocument).Node
                }
            }
            # If -Architecture and -Release are specified, filter on both
            If ($PSBoundParameters.ContainsKey('Architecture') -and $PSBoundParameters.ContainsKey('Release')) {
                ForEach ($rel in $Release) {
                    ForEach ($arch in $Architecture) {
                        $xmlContent += (Select-Xml -XPath "/Redistributables/Platform[@Release='$rel'][@Architecture='$arch']" -Xml $xmlDocument).Node
                    }
                }
            }
    } Else {

        # Pass the XML document contents to $xmlContent, so that we don't need to provide
        # different logic if -Platform and -Architectures are not supplied
        $xmlContent = @()
        $xmlContent += (Select-Xml -XPath "/Redistributables/Platform" -Xml $xmlDocument).Node
    }

    ##### Loop through each setting in the XML structure to process each redistributable
    ForEach ($platform in $xmlContent) {

        # Create variables from the Platform content to simplify references below
        $plat = $platform | Select-Object -ExpandProperty Architecture
        $rel = $platform | Select-Object -ExpandProperty Release
        $arg = $platform | Select-Object -ExpandProperty Install

        # Step through each redistributable defined in the XML
        ForEach ($redistributable in $platform.Redistributable) {

            # Create variables from the Redistributable content to simplify references below
            $uri = $redistributable.Download
            $filename = $uri.Substring($uri.LastIndexOf("/") + 1)
            If ([bool]([System.Uri]$Path).IsUnc) {
                $target= "$Path\$rel\$plat\$($redistributable.ShortName)"
            } Else {
                $target= "$((Get-Item $Path).FullName)\$rel\$plat\$($redistributable.ShortName)"
            }

            # Create the folder to store the downloaded file. Skip if it exists
            If (!(Test-Path -Path $target)) {
                If ($pscmdlet.ShouldProcess($target, "Create")) {
                    New-Item -Path $target -Type Directory -Force | Out-Null
                }
            } Else {
                Write-Verbose "Folder '$($redistributable.ShortName)' exists. Skipping."
            }


            ##### Download the Redistributable to the target path. Skip if it exists
            If (!(Test-Path -Path "$target\$filename" -PathType 'Leaf')) {
                If ($pscmdlet.ShouldProcess($uri, "Download")) {
                    Invoke-WebRequest -Uri $uri -OutFile "$target\$filename"
                }
            } Else {
                Write-Verbose "Redistributable exists. Skipping."
            }

            # Install the Redistributable if the -Install switch is specified
            If ($Install) {
                If ($pscmdlet.ShouldProcess("'$target\$filename $arg'", "Installing")) {
                    Start-Process -FilePath "$target\$filename" -ArgumentList $arg -Wait
                }
            }


            ##### Create an application for the redistributable in ConfigMgr
            If ($CreateCMApp) {

                # Ensure the current folder is saved
                Push-Location -StackName FileSystem
                Try {
                    If ($pscmdlet.ShouldProcess($SMSSiteCode + ":", "Set location")) {

                        # Set location to the PSDrive for the ConfigMgr site
                        Set-Location ($SMSSiteCode + ":") -ErrorVariable ConnectionError
                    }
                }
                Catch {
                    $ConnectionError
                }
                Try {

                    # Create the ConfigMgr application with properties from the XML file
                    If ($pscmdlet.ShouldProcess($redistributable.Name + " $plat", "Creating ConfigMgr application")) {
                        $app = New-CMApplication -Name ($redistributable.Name + " $plat") -ErrorVariable CMError -Publisher "Microsoft" -AutoInstall $true

                        Add-CMScriptDeploymentType -InputObject $app -InstallCommand "$filename $arg" -ContentLocation $target `
                        -ProductCode $redistributable.ProductCode -DeploymentTypeName ("SCRIPT_" + $redistributable.Name) `
                        -UserInteractionMode Hidden -UninstallCommand "msiexec /x $($redistributable.ProductCode) /qn-" `
                        -LogonRequirementType WhetherOrNotUserLoggedOn -InstallationBehaviorType InstallForSystem -ErrorVariable CMError `
                        -Comment "Generated by $($MyInvocation.MyCommand.Name)"
                    }

                }
                Catch {
                    $CMError
                }

                # Go back to the original folder
                Pop-Location -StackName FileSystem
            }
        }
    }
}
