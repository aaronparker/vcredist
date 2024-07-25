function Get-VcList {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [Alias("Get-VcRedist")]
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding(DefaultParameterSetName = "Manifest", HelpURI = "https://vcredist.com/get-vclist/")]
    param (
        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Manifest")]
        [ValidateSet("2012", "2013", "2015", "2017", "2019", "2022")]
        [System.String[]] $Release = @("2012", "2013", "2022"),

        [Parameter(Mandatory = $false, Position = 1, ParameterSetName = "Manifest")]
        [ValidateSet("x86", "x64", "ARM64")]
        [System.String[]] $Architecture = @("x86", "x64"),

        [Parameter(Mandatory = $false, Position = 2, ValueFromPipeline, ParameterSetName = "Manifest")]
        [ValidateScript( { if (Test-Path -Path $_ -PathType "Leaf") { $true } else { throw "Cannot find file $_" } })]
        [ValidateNotNullOrEmpty()]
        [Alias("Xml")]
        [System.String] $Path = $(Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json"),

        [Parameter(Mandatory = $false, Position = 0, ParameterSetName = "Export")]
        [ValidateSet("Supported", "All", "Unsupported")]
        [System.String] $Export = "Supported"
    )

    process {
        try {
            # Convert the JSON content to an object
            Write-Verbose -Message "Reading VcRedist manifest '$Path'."
            $params = @{
                Path        = $Path
                Raw         = $true
                ErrorAction = "Stop"
            }
            $Content = Get-Content @params
            Write-Verbose -Message "Converting JSON."
            $JsonManifest = $Content | ConvertFrom-Json -ErrorAction "Continue"
        }
        catch [System.Exception] {
            Write-Warning -Message "Unable to convert manifest JSON to required object. Please validate the input manifest."
            throw $_
        }

        if ($null -ne $JsonManifest) {
            if ($PSBoundParameters.ContainsKey("Export")) {
                switch ($Export) {
                    "All" {
                        Write-Verbose -Message "Exporting all VcRedists."
                        Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                        [System.Management.Automation.PSObject] $Output = $JsonManifest.Supported + $JsonManifest.Unsupported
                        break
                    }
                    "Supported" {
                        Write-Verbose -Message "Exporting supported VcRedists."
                        [System.Management.Automation.PSObject] $Output = $JsonManifest.Supported
                        break
                    }
                    "Unsupported" {
                        Write-Verbose -Message "Exporting unsupported VcRedists."
                        Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                        [System.Management.Automation.PSObject] $Output = $JsonManifest.Unsupported
                        break
                    }
                }
            }
            else {
                # Filter the list for architecture and release
                # if ($Release -match $JsonManifest.Unsupported.Release) {
                #     Write-Warning -Message "This list includes unsupported Visual C++ Redistributables."
                # }
                [System.Management.Automation.PSObject[]] $Output = $JsonManifest.Supported | Where-Object { $Release -contains $_.Release } | `
                    Where-Object { $Architecture -contains $_.Architecture }
            }

            try {
                # Get the count of items in $Output; Because it's a PSCustomObject we can't use the .count property so need to measure the object
                # Grab a NoteProperty and count how many of those there are to get the object count
                $Property = $Output | Get-Member -ErrorAction "SilentlyContinue" | Where-Object { $_.MemberType -eq "NoteProperty" } | Select-Object -ExpandProperty "Name" | Select-Object -First 1
                $Count = $Output.$Property.Count - 1
            }
            catch {
                $Count = 0
            }

            # Replace strings in the manifest
            Write-Verbose -Message "Object count is: $($Output.$Property.Count)."
            for ($i = 0; $i -le $Count; $i++) {
                try {
                    $Output[$i].SilentUninstall = $Output[$i].SilentUninstall `
                        -replace "#Installer", $(Split-Path -Path $Output[$i].URI -Leaf) `
                        -replace "#ProductCode", $Output[$i].ProductCode
                }
                catch {
                    Write-Verbose -Message "Failed to replace strings in: $($JsonManifest[$i].Name)."
                }
            }
            Write-Output -InputObject $Output
        }
    }
}
