function Export-VcManifest {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Export-VcXml")]
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://vcredist.com/export-vcmanifest/")]
    [OutputType([System.String])]
    param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline)]
        [ValidateNotNull()]
        [ValidateScript( { if (Test-Path -Path $(Split-Path -Path $_ -Parent) -PathType 'Container' -ErrorAction "SilentlyContinue") { $True } else { throw "Cannot find path $(Split-Path -Path $_ -Parent)" } })]
        [System.String] $Path
    )

    process {
        # Get the list of VcRedists from Get-VcList
        [System.String] $Manifest = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json")

        # Output the manifest to supplied path
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Copying $Manifest to $Path."
            Copy-Item -Path $Manifest -Destination $Path
        }
        catch {
            Write-Warning -Message "$($MyInvocation.MyCommand): Failed to copy $Manifest to $Path."
            throw $_.Exception.Message
        }
        finally {
            Write-Output -InputObject (Resolve-Path -Path $Path)
        }
    }
}
