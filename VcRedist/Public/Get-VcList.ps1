Function Get-VcList {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(DefaultParameterSetName = "Manifest", HelpURI = "https://vcredist.com/get-vclist/")]
    Param (
        [Parameter(Mandatory = $False, Position = 0, ParameterSetName = "Manifest")]
        [ValidateSet("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019", "2022")]
        [System.String[]] $Release = @("2012", "2013", "2022"),

        [Parameter(Mandatory = $False, Position = 1, ParameterSetName = "Manifest")]
        [ValidateSet("x86", "x64")]
        [System.String[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $False, Position = 2, ValueFromPipeline, ParameterSetName = "Manifest")]
        [ValidateNotNull()]
        [ValidateScript( { If (Test-Path -Path $_ -PathType "Leaf" -ErrorAction "SilentlyContinue") { $True } Else { Throw "Cannot find file $_" } })]
        [Alias("Xml")]
        [System.String] $Path = (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json"),

        [Parameter(Mandatory = $False, Position = 0, ParameterSetName = "Export")]
        [ValidateSet("Supported", "All", "Unsupported")]
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
        }
        try {
            # Convert the JSON content to an object
            Write-Verbose -Message "$($MyInvocation.MyCommand): Converting JSON."
            $json = $content | ConvertFrom-Json -ErrorAction "SilentlyContinue"
        }
        catch [System.Exception] {
            Write-Warning -Message "$($MyInvocation.MyCommand): Unable to convert manifest JSON to required object. Please validate the input manifest."
            Throw $_.Exception.Message
        }

        If ($Null -ne $json) {
            If ($PSBoundParameters.ContainsKey("Export")) {
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
            Write-Verbose -Message "$($MyInvocation.MyCommand): Object count is: $($output.$Property.Count)."
            For ($i = 0; $i -le $Count; $i++) {
                try {
                    $output[$i].SilentUninstall = $output[$i].SilentUninstall `
                        -replace "#Installer", $(Split-Path -Path $output[$i].Download -Leaf) `
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
