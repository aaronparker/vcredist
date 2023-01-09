function Export-VcManifest {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Export-VcXml")]
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/export-vcmanifest/")]
    [OutputType([System.IO.FileSystemInfo])]
    param (
        [Parameter(Mandatory = $true, Position = 0, ValueFromPipeline)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Container") { $true } else { throw [System.IO.DirectoryNotFoundException]::New("Cannot find path: $_") } })]
        [System.String] $Path
    )

    process {
        # Get the list of VcRedists from Get-VcList
        [System.String] $Manifest = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json")

        # Output the manifest to supplied path
        try {
            Write-Verbose -Message "Copy from: '$Manifest'."
            Write-Verbose -Message "  Copy to: '$Path'."
            $params = @{
                Path        = $Manifest
                Destination = $Path
                PassThru    = $true
                ErrorAction = "Stop"
            }
            Copy-Item @params
        }
        catch {
            throw $_
        }
    }
}
