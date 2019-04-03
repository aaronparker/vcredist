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

        .PARAMETER Export
            Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables.
            Defaults to exporting the Supported Redistributables.

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to import into MDT.

        .PARAMETER Architecture
            Specifies the processor architecture to import into MDT. Can be x86 or x64.

        .EXAMPLE
            Get-VcList

            Description:
            Return an array of the supported Visual C++ Redistributables from the embedded manifest.

        .EXAMPLE
            Get-VcList

            Description:
            Returns the 2008, 2010, 2012, 2013 and 2019, x86 and x64 versions of the supported Visual C++ Redistributables from the embedded manifest.

        .EXAMPLE
            Get-VcList -Export All

            Description:
            Returns a list of the all Visual C++ Redistributables from the embedded manifest, including unsupported versions.

        .EXAMPLE
            Get-VcList -Export Supported

            Description:
            Returns the full list of supported Visual C++ Redistributables from the embedded manifest.

        .EXAMPLE
            Get-VcList -Release 2013, 2019 -Architecture x86

            Description:
            Returns the 2013 and 2019 x64 Visual C++ Redistributables from the list of supported Redistributables in the embedded manifest.

        .EXAMPLE
            Get-VcList -Path ".\VisualCRedistributables.json"

            Description:
            Returns a list of the Visual C++ Redistributables listed in the external manifest VisualCRedistributables.json.
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
        [string] $Export = "Supported",

        [Parameter(Mandatory = $False, ParameterSetName = 'Manifest')]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017', '2019')]
        [string[]] $Release = @("2008", "2010", "2012", "2013", "2019"),

        [Parameter(Mandatory = $False, ParameterSetName = 'Manifest')]
        [ValidateSet('x86', 'x64')]
        [string[]] $Architecture = @("x86", "x64")
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
        $json = $content | ConvertFrom-Json -ErrorVariable convertError -ErrorAction SilentlyContinue
    }
    catch {
        Throw "Unable to convert JSON to object. $convertError"
        Break
    }
    finally {
        If ($PSBoundParameters.ContainsKey('Export')) {
            Switch ($Export) {
                "Supported" {
                    Write-Verbose -Message "Exporting supported VcRedists."
                    [PSCustomObject] $output = $json.Supported
                }
                "All" {
                    Write-Verbose -Message "Exporting all VcRedists."
                    Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                    [PSCustomObject] $output = $json.Supported + $content.Unsupported
                }
                "Unsupported" {
                    Write-Verbose -Message "Exporting unsupported VcRedists."
                    Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                    [PSCustomObject] $output = $json.Unsupported
                }
            }
            Write-Output $output
        }
        Else {
            # Filter the list for architecture and release
            [PSCustomObject] $supported = $json.Supported
            [PSCustomObject] $release = $supported | Where-Object { $Release -contains $_.Release }
            [PSCustomObject] $output = $release | Where-Object { $Architecture -contains $_.Architecture }
            Write-Output $output
        }
    }
}
