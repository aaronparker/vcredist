# Requires -Version 3
Function Export-VcXml {
    <#
    .SYNOPSIS
        Exports the Visual C++ Redistributables XML to an external file.

    .DESCRIPTION
        Reads the Visual C++ Redistributables XML manifests included in the VcRedist module and exports the XML to an external file.
        The XML file can then be edited and read with other functions such as Get-VcXml.

    .OUTPUTS
        System.String
    
    .NOTES
        Name: Export-VcXml
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://stealthpuppy.com

    .PARAMETER Path
        Path to the XML file the content will be exported to.

    .PARAMETER Export
        Defines the list of Visual C++ Redistributables to export - All Redistributables or Supported Redistributables only.
        Defaults to exporting the Supported Redistributables.

    .EXAMPLE
        Export-VcXml -Path "C:\Temp\VisualCRedistributablesSupported.xml" -Export Supported

        Description:
        Export the list of supported Visual C++ Redistributables to C:\Temp\VisualCRedistributablesSupported.xml.
#>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter(Mandatory = $True, HelpMessage = "Path to the XML file content will be exported to.")]
        [ValidateNotNull()]
        [ValidateScript({ If (Test-Path $(Split-Path -Path $_ -Parent) -PathType 'Container') { $True } Else { Throw "Cannot find path $(Split-Path -Path $_ -Parent)" } })]
        [string]$Path,

        [Parameter(Mandatory = $False)]
        [ValidateSet('All', 'Supported')]
        [string]$Export = "Supported"
    )
    Begin {
        Switch ($Export) {
            "All" { $Xml = "$($MyInvocation.MyCommand.Module.ModuleBase)\VisualCRedistributablesAll.xml" }
            "Supported" { $Xml = "$($MyInvocation.MyCommand.Module.ModuleBase)\VisualCRedistributablesSupported.xml" }
        }
        If (!(Test-Path -Path $Xml -PathType 'Leaf')) {
            Throw "Cannot find file $Xml. Reinstall the VcRedist module."
        }
    }
    Process {
        # Read the specifed XML document
        Try {
            Write-Verbose "Reading XML document $Xml."
            [xml]$xmlDocument = Get-Content -Path $Xml -ErrorVariable xmlReadError -ErrorAction SilentlyContinue
        }
        Catch {
            Throw "Unable to read $Xml. $xmlReadError"
        }

        # TODO: Put some code here to filter on Release and Architecture
    }
    End {
        # Write the document out to the file system and return the path to the file.
        Write-Verbose "Writing XML to $Path."
        $xmlDocument.Save($Path)
        $Path
    }
}