<#
    .SYNOPSIS
        Installs and/or downloads the Visual C++ Redistributables listed in an external XML file.

    .DESCRIPTION
        This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents release and processor architecture.

        This can be run to download and optionally install the Visual C++ Redistributables as specified in the external XML file passed to the script.

        The basic structure of the XML file should be:

        <Redistributables>
            <Platform Architecture="x64" Release="" Install="">
                <Redistributable>
                    <Name></Name>
                    <ShortName></ShortName>
                    <URL></URL>
                    <Download></Download>
            </Platform>
            <Platform Architecture="x86" Release="" Install="">
                <Redistributable>
                    <Name></Name>
                    <ShortName></ShortName>
                    <URL></URL>
                    <Download></Download>
                </Redistributable>
            </Platform>
        </Redistributables>

    .NOTES
        Name: Install-VisualCRedistributables.ps1
        Author: Aaron Parker
        Version: 1.1
        DateUpdated: 2017-05-02

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

    .PARAMETER CreateCMApp
        Switch Parameter to create ConfigMgr apps from downloaded redistributables.

    .Parameter SMSSiteCode
        Specify SMS Site Code for ConfigMgr app creation.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path C:\Redist

        Description:
        Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

    .PARAMETER Install
        By default the script will only download the Redistributables. Add -Install:$True to install each of the Redistributables as well.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Install:$True

        Description:
        Downloads and installs the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .EXAMPLE
        .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -CreateCMApp -SMSSiteCode S01 -Download \\server1.contoso.com\Sources\Apps\VSRedist

        Description:
        Downloads Visual C++ Redistributables listed in VisualCRedistributables.xml and creates ConfigMgr Applications for the selected Site.

    .CHANGELOG
    02/05/2017: Added <ShortName> to the XML and updated script to use ShortName instead of Name as the target folder
    03/05/2017: Changed -File to -Xml
    02/05/2017: Added functionality to create ConfigMgr Applications

#>

[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low")]
PARAM (
    [Parameter(Mandatory=$True, HelpMessage="The path to the XML document describing the Redistributables.")]
    [ValidateScript({ Test-Path $_ -PathType 'Leaf' })]
    [string]$Xml,

    [Parameter(Mandatory=$False, HelpMessage="Specify a target path to download the Redistributables to.")]
    [ValidateScript({ Test-Path $_ -PathType 'Container' })]
    [string]$Path = ".\",

    [Parameter(Mandatory=$False, HelpMessage="Enable the installation of the Redistributables after download.")]
    [bool]$Install = $False,

    [Parameter(Mandatory=$False, HelpMessage="Create Applications in ConfigMgr.")]
    [switch]$CreateCMApp,

    [Parameter(Mandatory=$False, HelpMessage="Specify ConfigMgr Site Code.")]
    [String]$SMSSiteCode
)

BEGIN {
    # Variables
    # $build = [Environment]::OSVersion.Version

    # Get script elevation status
    # [bool]$Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
}

PROCESS {

    if ($CreateCMApp)
    {
        try {
            Import-Module "$($ENV:SMS_ADMIN_UI_PATH)\..\ConfigurationManager.psd1" # Import the ConfigurationManager.psd1 module
        }
        catch
        {
            return "Could not load ConfigMgr Module. Please make sure that the ConfigMgr Console is installed"
        }
    }

    # Read the specifed XML document
    $xmlContent = ( Select-Xml -Path $Xml -XPath "/Redistributables/Platform" ).Node

    # Loop through each setting in the XML structure to set the registry value
    ForEach ( $platform in $xmlContent ) {

        # Create variables from the content to simplify references below
        $plat = $platform | Select-Object -ExpandProperty Architecture
        $rel = $platform | Select-Object -ExpandProperty Release
        $arg = $platform | Select-Object -ExpandProperty Install

        # Step through each redistributable defined in the XML
        ForEach ($redistributable in $platform.Redistributable) {

            # Create variables from the content to simplify references below
            $uri = $redistributable.Download
            $filename = $uri.Substring($uri.LastIndexOf("/") + 1)
            $target= "$((Get-Item $Path).FullName)\$rel\$plat\$($redistributable.ShortName)"

            # Create the folder to store the downloaded file. Skip if it exists
            If (!(Test-Path -Path $target)) {
                If ($pscmdlet.ShouldProcess($target, "Create")) {
                    New-Item -Path $target -Type Directory -Force
                }
            } Else {
                Write-Verbose "Folder '$($redistributable.ShortName)' exists. Skipping."
            }

            # Download the Redistributable to the target path. Skip if it exists
            If (!(Test-Path -Path "$target\$filename" -PathType 'Leaf')) {
                If ($pscmdlet.ShouldProcess("$uri", "Download")) {
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

            If ($CreateCMApp)
            {
                Push-Location -StackName FileSystem
                try
                {
                    Set-Location ($SMSSiteCode + ":") -ErrorVariable ConnectionError
                }
                catch
                {
                    $ConnectionError
                }
                try
                {
                $app = New-CMApplication -Name ("DEV_" + $redistributable.Name + "_$plat") -ErrorVariable CMError

                Add-CMScriptDeploymentType -InputObject $app -InstallCommand "$filename $arg" -ContentLocation $target `
                    -ProductCode $redistributable.ProductCode -DeploymentTypeName ("SCRIPT_" + $redistributable.Name) `
                    -UserInteractionMode Hidden -UninstallCommand "msiexec /x $($redistributable.ProductCode) /qn" `
                    -LogonRequirementType WhetherOrNotUserLoggedOn -InstallationBehaviorType InstallForSystem -ErrorVariable CMError
                }
                catch
                {
                    $CMError
                }

                Pop-Location -StackName FileSystem
            }
        }
    }
}
