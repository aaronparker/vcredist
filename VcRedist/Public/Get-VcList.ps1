Function Get-VcList {
    <#
        .SYNOPSIS
            Returns an array of Visual C++ Redistributables.

        .DESCRIPTION
            This function reads the Visual C++ Redistributables listed in an internal manifest or an external JSON file into an array that can be passed to other VcRedist functions.

            A complete listing of the supported and all known redistributables is included in the module. These internal manifests can be exported with Export-VcManifest.

        .OUTPUTS
            System.Array
        
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/vcredist/usage/export-manifests

        .PARAMETER Manifest
            The JSON file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

        .PARAMETER ExportAll
            Defines the list of Visual C++ Redistributables to export - All Redistributables or Supported Redistributables only.
            Defaults to exporting the Supported Redistributables.

        .EXAMPLE
            Get-VcList

            Description:
            Return an array of the supported Visual C++ Redistributables from the embedded manifest.

        .EXAMPLE
            Get-VcList -ExportAll

            Description:
            Return an array of the all Visual C++ Redistributables from the embedded manifest, including unsupported versions.

        .EXAMPLE
            Get-VcList -Manifest ".\VisualCRedistributables.json"

            Description:
            Return an array of the Visual C++ Redistributables listed in the external manifest VisualCRedistributables.json.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, DefaultParameterSetName='Manifest')]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ParameterSetName='Manifest', `
            HelpMessage = "Path to the JSON document describing the Redistributables.")]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
        [Alias("Xml")]
        [string] $Manifest = (Join-Path (Join-Path $MyInvocation.MyCommand.Module.ModuleBase "Manifests") "VisualCRedistributablesSupported.json"),

        [Parameter(Mandatory = $False, ParameterSetName='Export')]
        [switch] $ExportAll
    )
    
    If ($ExportAll) {
        $Manifest = Join-Path (Join-Path $MyInvocation.MyCommand.Module.ModuleBase "Manifests") "VisualCRedistributablesAll.json"
        Write-Warning "This manifest includes unsupported Visual C++ Redistributables."
    }

    try {
        Write-Verbose "Reading JSON document $Manifest."
        $content = Get-Content -Raw -Path $Manifest -ErrorVariable readError -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to read manifest $Manifest. $readError"
        Break
    }
    
    try {
        # Convert the JSON content to an object
        Write-Verbose "Converting JSON."
        $output = $content | ConvertFrom-Json -ErrorVariable convertError -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to convert JSON to object. $convertError"
        Break
    }
    finally {
        # Return array to the pipeline
        Write-Output $output
    }
}
