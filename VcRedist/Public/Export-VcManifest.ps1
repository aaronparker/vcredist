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
        [System.String] $Path,

        [Parameter(Mandatory = $False, ParameterSetName = 'Export')]
        [ValidateSet('Supported', 'All', 'Unsupported')]
        [System.String] $Export = "Supported"
    )

    # Get the list of VcRedists from Get-VcList
    Switch ($Export) {
        "Supported" {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Exporting supported VcRedists."
            $vcList = Get-VcList -Export Supported
        }
        "All" {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Exporting all VcRedists."
            Write-Warning -Message "$($MyInvocation.MyCommand): This list includes unsupported Visual C++ Redistributables."
            $vcList = Get-VcList -Export All
        }
        "Unsupported" {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Exporting unsupported VcRedists."
            Write-Warning -Message "$($MyInvocation.MyCommand): This list includes unsupported Visual C++ Redistributables."
            $vcList = Get-VcList -Export Unsupported
        }
    }

    # Output the VcList object to a JSON file
    try {
        $vcList | ConvertTo-Json | Out-File -FilePath $Path -ErrorAction SilentlyContinue
    }
    catch {
        Write-Warning -Message "$($MyInvocation.MyCommand): Failed to write JSON to $Path with $writeError."
        Throw $_.Exception.Message
        Break
    }
    finally {
        Write-Output -InputObject (Resolve-Path -Path $Path)
    }
}
