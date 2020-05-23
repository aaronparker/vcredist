Function Export-VcManifest {
    <#
        .SYNOPSIS
            Exports the Visual C++ Redistributables JSON to an external file.

        .DESCRIPTION
            Reads the Visual C++ Redistributables JSON manifests included in the VcRedist module and exports the JSON to an external file.
            This enables editing of the JSON manifest for custom scenarios.
        
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/export-manifests

        .PARAMETER Path
            Path to the JSON file the content will be exported to.

        .PARAMETER ExportAll
            Switch parameter that forces the export of Visual C++ Redistributables including unsupported Redistributables.

        .EXAMPLE
            Export-VcManifest -Path "C:\Temp\VisualCRedistributablesSupported.json"

            Description:
            Export the list of supported Visual C++ Redistributables to C:\Temp\VisualCRedistributablesSupported.json

        .EXAMPLE
            Export-VcManifest -Path "C:\Temp\VisualCRedistributables.json" -Export All

            Description:
            Export the full list of Visual C++ Redistributables, including unsupported, to C:\Temp\VisualCRedistributables.json
    #>
    [Alias("Export-VcXml")]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/export-manifests")]
    [OutputType([System.String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path $(Split-Path -Path $_ -Parent) -PathType 'Container') { $True } Else { Throw "Cannot find path $(Split-Path -Path $_ -Parent)" } })]
        [System.String] $Path
    )

    Process {
        # Get the list of VcRedists from Get-VcList
        [System.String] $Manifest = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json")

        # Output the manifest to supplied path
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Copying $Manifest to $Path."
            Copy-Item -Path $Manifest -Destination $Path
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to copy $Manifest to $Path."
            Throw $_.Exception.Message
            Break
        }
        finally {
            Write-Output -InputObject (Resolve-Path -Path $Path)
        }
    }
}
