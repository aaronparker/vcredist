Function Export-VcXml {
    <#
    .SYNOPSIS
        Exports the Visual C++ Redistributables XML to an external file.

    .DESCRIPTION
        Reads the Visual C++ Redistributables XML manifests included in the VcRedist module and exports the XML to an external file.
        This enables editing of the XML manifest for custom scenarios.

    .OUTPUTS
        System.String
    
    .NOTES
        Name: Export-VcXml
        Author: Aaron Parker
        Twitter: @stealthpuppy

    .LINK
        https://github.com/aaronparker/Install-VisualCRedistributables

    .PARAMETER Path
        Path to the XML file the content will be exported to.

    .PARAMETER Export
        Switch parameter that defines the list of Visual C++ Redistributables to export - All Redistributables or Supported Redistributables only.
        Defaults to exporting the Supported Redistributables.

    .EXAMPLE
        Export-VcXml -Path "C:\Temp\VisualCRedistributablesSupported.xml" -Export Supported

        Description:
        Export the list of supported Visual C++ Redistributables to C:\Temp\VisualCRedistributablesSupported.xml.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, HelpMessage = "Path to the XML file content will be exported to.")]
        [ValidateNotNull()]
        [ValidateScript({ If (Test-Path $(Split-Path -Path $_ -Parent) -PathType 'Container') { $True } Else { Throw "Cannot find path $(Split-Path -Path $_ -Parent)" } })]
        [string]$Path,

        [Parameter(Mandatory = $False)]
        [ValidateSet('All', 'Supported')]
        [string]$Export = "Supported"
    )
    Begin {
        Switch ($Export) {
            "All" { $Xml = "$($MyInvocation.MyCommand.Module.ModuleBase)\Manifests\VisualCRedistributablesAll.xml" }
            "Supported" { $Xml = "$($MyInvocation.MyCommand.Module.ModuleBase)\Manifests\VisualCRedistributablesSupported.xml" }
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