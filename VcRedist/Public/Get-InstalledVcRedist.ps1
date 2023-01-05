function Get-InstalledVcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://vcredist.com/get-installedvcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $ExportAll
    )

    # Get all installed Visual C++ Redistributables installed components
    Write-Verbose -Message "Matching installed VcRedists with: [(Microsoft Visual C.*)(\bRedistributable|\bRuntime).*]."
    $VcRedists = Get-InstalledSoftware | Where-Object { $_.Name -match "(Microsoft Visual C.*)(\bRedistributable|\bRuntime).*" }

    # Add Architecture property to each entry
    Write-Verbose -Message "Adding Architecture property."
    $VcRedists | ForEach-Object { if ($_.Name -contains "x64") { $_ | Add-Member -NotePropertyName "Architecture" -NotePropertyValue "x64" } }

    # If -ExportAll used, export everything instead of filtering for the primary Redistributable
    if ($PSBoundParameters.ContainsKey("ExportAll")) {

        # Write the installed VcRedists to the pipeline
        Write-Output -InputObject $VcRedists
    }
    else {
        Write-Verbose -Message "Filtering output."
        $Output = $VcRedists | ForEach-Object { if (-not (Select-String -InputObject $_ -Pattern "Additional|Minimum")) { $_ } } | Sort-Object -Property "Name"

        # Write the filtered installed VcRedists to the pipeline
        Write-Output -InputObject $Output
    }
}
