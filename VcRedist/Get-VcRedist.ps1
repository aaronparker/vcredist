# Requires -Version 3
<#
    .SYNOPSIS
        Downloads the Visual C++ Redistributables listed in an external XML file.

    .DESCRIPTION
        This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents release and processor architecture.
        If the redistributable exists in the specified path, it will not be re-downloaded.

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
        Name: Get-VcRedist.ps1
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
#>
[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low", DefaultParameterSetName = 'Base')]
PARAM (
    [Parameter(ParameterSetName = 'Base', Mandatory = $True, HelpMessage = "The path to the XML document describing the Redistributables.")]
    [ValidateScript( { If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
    [string]$Xml,

    [Parameter(ParameterSetName = 'Base', Mandatory = $False, HelpMessage = "Specify a target path to download the Redistributables to.")]
    [ValidateScript( { If (Test-Path $_ -PathType 'Container') { $True } Else { Throw "Cannot find path $_" } })]
    [string]$Path = ".\",

    [Parameter(ParameterSetName = 'Base', Mandatory = $False, HelpMessage = "Specify the version of the Redistributables to install.")]
    [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017')]
    [string[]]$Release = @("2008", "2010", "2012", "2013", "2015", "2017"),

    [Parameter(ParameterSetName = 'Base', Mandatory = $False, HelpMessage = "Specify the processor architecture/s to install.")]
    [ValidateSet('x86', 'x64')]
    [string[]]$Architecture = @("x86", "x64")
)

BEGIN {
    # Get script elevation status
    # [bool]$Elevated = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")

    # Remove the temporary folder
    If ($pscmdlet.ShouldProcess($tempFolder, "Remove")) {
        Remove-Item "$tempFolder" -Recurse -Force
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
        }
    }
}