function Get-VcList {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(DefaultParameterSetName = "Manifest", HelpURI = "https://vcredist.com/get-vclist/")]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Manifest")]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "2022")]
        [System.String[]] $Release = @("2012", "2013", "2022"),

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Manifest")]
        [ValidateSet("x86", "x64")]
        [System.String[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline, ParameterSetName = "Manifest")]
        [ValidateNotNull()]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Leaf") { $true } else { throw "Cannot find file $_" } })]
        [Alias("Xml")]
        [System.String] $Path = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json"),

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Export")]
        [ValidateSet("Supported", "All", "Unsupported")]
        [System.String] $Export = "Supported"
    )

    process {
        try {
            Write-Verbose -Message "Reading JSON document [$Path]."
            $content = Get-Content -Raw -Path $Path -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to read manifest [$Path]."
            throw $_.Exception.Message
        }
        try {
            # Convert the JSON content to an object
            Write-Verbose -Message "Converting JSON."
            $json = $content | ConvertFrom-Json -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to convert manifest JSON to required object. Please validate the input manifest."
            throw $_.Exception.Message
        }

        if ($null -ne $json) {
            if ($PSBoundParameters.ContainsKey("Export")) {
                switch ($Export) {
                    "Supported" {
                        Write-Verbose -Message "Exporting supported VcRedists."
                        [System.Management.Automation.PSObject] $output = $json.Supported
                    }
                    "All" {
                        Write-Verbose -Message "Exporting all VcRedists."
                        Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                        [System.Management.Automation.PSObject] $output = $json.Supported + $json.Unsupported
                    }
                    "Unsupported" {
                        Write-Verbose -Message "Exporting unsupported VcRedists."
                        Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                        [System.Management.Automation.PSObject] $output = $json.Unsupported
                    }
                }
            }
            else {
                # Filter the list for architecture and release
                if ($json | Get-Member -Name "Supported" -MemberType "Properties") {
                    [System.Management.Automation.PSObject] $supported = $json.Supported
                }
                else {
                    [System.Management.Automation.PSObject] $supported = $json
                }
                [System.Management.Automation.PSObject] $output = $supported | Where-Object { $Release -contains $_.Release } | `
                    Where-Object { $Architecture -contains $_.Architecture }
            }

            # Get the count of items in $output; Because it's a PSCustomObject we can't use the .count property so need to measure the object
            # Grab a NoteProperty and count how many of those there are to get the object count
            try {
                $Property = $output | Get-Member -ErrorAction "SilentlyContinue" | Where-Object { $_.MemberType -eq "NoteProperty" } | Select-Object -ExpandProperty "Name" | Select-Object -First 1
                $Count = $output.$Property.Count - 1
            }
            catch {
                $Count = 0
            }

            # Replace strings in the manifest
            Write-Verbose -Message "Object count is: $($output.$Property.Count)."
            for ($i = 0; $i -le $Count; $i++) {
                try {
                    $output[$i].SilentUninstall = $output[$i].SilentUninstall `
                        -replace "#Installer", $(Split-Path -Path $output[$i].URI -Leaf) `
                        -replace "#ProductCode", $output[$i].ProductCode
                }
                catch {
                    Write-Verbose -Message "Failed to replace strings in: $($json[$i].Name)."
                }
            }
            Write-Output -InputObject $output
        }
    }
}
