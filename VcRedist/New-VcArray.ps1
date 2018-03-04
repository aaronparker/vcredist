# Requires -Version 3
<#
    .SYNOPSIS
        Creates and array of Visual C++ Redistributables listed in an external XML file.

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

    .OUTPUTS
         System.Array
    
    .NOTES
        Name: New-VcArray.ps1
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        http://stealthpuppy.com

    .PARAMETER Xml
        The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

    .EXAMPLE
        .\New-VcArray.ps1 -Xml ".\VisualCRedistributablesSupported.xml"

        Description:
        Build an array of the Visual C++ Redistributables listed in VisualCRedistributablesSupported.xml.
#>
[CmdletBinding(SupportsShouldProcess = $True, ConfirmImpact = "Low", DefaultParameterSetName = 'Base')]
Param (
    [Parameter(ParameterSetName = 'Base', Mandatory = $False, HelpMessage = "Path to the XML document describing the Redistributables.")]
    [ValidateScript( { If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
    [string]$Xml = ".\VisualCRedistributablesSupported.xml"
)
Begin {
    $Output = @()
}
Process {
    # Read the specifed XML document
    Try {
        [xml]$xmlDocument = Get-Content -Path $Xml -ErrorVariable xmlReadError
    }
    Catch {
        Throw "Unable to read $Xml. $xmlReadError"
    }

    # Build the output object by compiling an array of each redistributable
    $xmlContent = (Select-Xml -XPath "/Redistributables/Platform" -Xml $xmlDocument).Node
    ForEach ($platform in $xmlContent) {
        ForEach ($redistributable in $platform.Redistributable) {
            $item = New-Object PSObject
            $item | Add-Member -Type NoteProperty -Name 'Name' -Value $redistributable.Name
            $item | Add-Member -Type NoteProperty -Name 'ShortName' -Value $redistributable.ShortName
            $item | Add-Member -Type NoteProperty -Name 'URL' -Value $redistributable.URL
            $item | Add-Member -Type NoteProperty -Name 'ProductCode' -Value $redistributable.ProductCode
            $item | Add-Member -Type NoteProperty -Name 'Download' -Value $redistributable.Download
            $item | Add-Member -Type NoteProperty -Name 'Release' -Value $platform.Release
            $item | Add-Member -Type NoteProperty -Name 'Architecture' -Value $platform.Architecture 
            $Output += $item
        }
    }
}
End {
    $Output
}