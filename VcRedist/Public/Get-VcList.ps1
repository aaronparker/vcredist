Function Get-VcList {
    <#
        .SYNOPSIS
            Returns an array of Visual C++ Redistributables.

        .DESCRIPTION
            This function reads the Visual C++ Redistributables listed in an internal manifest or an external JSON file into an array that can be passed to other VcRedist functions.

            A complete listing of the supported and all known redistributables is included in the module. These internal manifests can be exported with Export-VcManifest.
        
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/getting-the-vcredist-list

        .PARAMETER Manifest
            The JSON file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

        .PARAMETER Export
            Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables.
            Defaults to exporting the Supported Redistributables.

        .PARAMETER Release
            Specifies the release (or version) of the redistributables to return.

        .PARAMETER Architecture
            Specifies the processor architecture to of the redistributables to return. Can be x86 or x64.

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
    [CmdletBinding(DefaultParameterSetName = 'Manifest', HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/getting-the-vcredist-list")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ValueFromPipeline, ParameterSetName = 'Manifest')]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path $_ -PathType 'Leaf') { $True } Else { Throw "Cannot find file $_" } })]
        [Alias("Xml")]
        [System.String] $Path = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json"),

        [Parameter(Mandatory = $False, ParameterSetName = 'Manifest')]
        [ValidateSet('2005', '2008', '2010', '2012', '2013', '2015', '2017', '2019')]
        [System.String[]] $Release = @("2008", "2010", "2012", "2013", "2019"),

        [Parameter(Mandatory = $False, ParameterSetName = 'Manifest')]
        [ValidateSet('x86', 'x64')]
        [System.String[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False, ParameterSetName = 'Export')]
        [ValidateSet('Supported', 'All', 'Unsupported')]
        [System.String] $Export = "Supported"
    )
    
    Process {
        try {
            Write-Verbose -Message "$($MyInvocation.MyCommand): Reading JSON document [$Path]."
            $content = Get-Content -Raw -Path $Path -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Unable to read manifest [$Path]."
            Throw $_.Exception.Message
            Exit
        }
    
        try {
            # Convert the JSON content to an object
            Write-Verbose -Message "$($MyInvocation.MyCommand): Converting JSON."
            $json = $content | ConvertFrom-Json -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Unable to convert manifest JSON to required object. Please validate the input manifest."
            Throw $_.Exception.Message
            Break
        }

        If ($Null -ne $json) {
            If ($PSBoundParameters.ContainsKey('Export')) {
                Switch ($Export) {
                    "Supported" {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Exporting supported VcRedists."
                        [System.Management.Automation.PSObject] $output = $json.Supported
                    }
                    "All" {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Exporting all VcRedists."
                        Write-Warning -Message "$($MyInvocation.MyCommand): This list includes unsupported Visual C++ Redistributables."
                        [System.Management.Automation.PSObject] $output = $json.Supported + $json.Unsupported
                    }
                    "Unsupported" {
                        Write-Verbose -Message "$($MyInvocation.MyCommand): Exporting unsupported VcRedists."
                        Write-Warning -Message "$($MyInvocation.MyCommand): This list includes unsupported Visual C++ Redistributables."
                        [System.Management.Automation.PSObject] $output = $json.Unsupported
                    }
                }
            }
            Else {
                # Filter the list for architecture and release
                If ($json | Get-Member -Name "Supported" -MemberType "Properties") {
                    [System.Management.Automation.PSObject] $supported = $json.Supported
                }
                Else {
                    [System.Management.Automation.PSObject] $supported = $json
                }
                [System.Management.Automation.PSObject] $release = $supported | Where-Object { $Release -contains $_.Release }
                [System.Management.Automation.PSObject] $output = $release | Where-Object { $Architecture -contains $_.Architecture }
            }

            # Replace strings in the manifest
            try {
                $File = Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VcRedist.json"
                $res = Get-Content -Path $File | ConvertFrom-Json
            }
            catch {
                Write-Warning -Message "$($MyInvocation.MyCommand): $($_.Exception.Message)."
            }
            If ($res) {
                For ($i = 0; $i -le ($output.Count - 1); $i++) {
                    try {
                        $output[$i].SilentUninstall = $output[$i].SilentUninstall `
                            -replace $res.ReplaceText.Installer, $(Split-Path -Path $output[$i].Download -Leaf) `
                            -replace $res.ReplaceText.ProductCode, $output[$i].ProductCode
                    }
                    catch {
                        Write-Verbose -Message "Failed to replace strings in: $($json[$i].Name)."
                    }
                }
            }
            Write-Output -InputObject $output
        }
    }
}
