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
            https://docs.stealthpuppy.com/vcredist/usage/getting-the-vcredist-list

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
            Get-VcList -Path ".\VisualCRedistributables.json"

            Description:
            Return an array of the Visual C++ Redistributables listed in the external manifest VisualCRedistributables.json.
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(SupportsShouldProcess = $False, DefaultParameterSetName = 'Manifest', `
            HelpURI = "https://docs.stealthpuppy.com/vcredist/usage/getting-the-vcredist-list")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, ParameterSetName = 'Manifest')]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
        [Alias("Xml")]
        [string] $Path = (Join-Path (Join-Path $MyInvocation.MyCommand.Module.ModuleBase "Manifests") "VisualCRedistributables.json"),

        [Parameter(Mandatory = $False, ParameterSetName = 'Export')]
        [ValidateSet('Supported', 'All', 'Unsupported')]
        [string] $Export = "Supported"
    )
    
    try {
        Write-Verbose -Message "Reading JSON document $Path."
        $content = Get-Content -Raw -Path $Path -ErrorVariable readError -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to read manifest $Path. $readError"
        Break
    }
    
    try {
        # Convert the JSON content to an object
        Write-Verbose -Message "Converting JSON."
        $content = $content | ConvertFrom-Json -ErrorVariable convertError -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to convert JSON to object. $convertError"
        Break
    }
    finally {
        # Create the output object
        Switch ($Export) {
            "Supported" {
                Write-Verbose -Message "Exporting supported VcRedists."
                $output = $content.Supported
            }
            "All" {
                Write-Verbose -Message "Exporting all VcRedists."
                Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                $output = $content.Supported + $content.Unsupported
            }
            "Unsupported" {
                Write-Verbose -Message "Exporting unsupported VcRedists."
                Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                $output = $content.Unsupported
            }
        }

        # Return array to the pipeline
        Write-Output $output
    }
}
