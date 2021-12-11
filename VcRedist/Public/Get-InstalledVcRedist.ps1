Function Get-InstalledVcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://stealthpuppy.com/vcredist/get-installedvcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $ExportAll
    )

    # Get all installed Visual C++ Redistributables installed components
    Write-Verbose -Message "$($MyInvocation.MyCommand): Matching installed VcRedists with: [(Microsoft Visual C.*)(\bRedistributable|\bRuntime).*]."
    $VcRedists = Get-InstalledSoftware | Where-Object { $_.Name -match "(Microsoft Visual C.*)(\bRedistributable|\bRuntime).*" }

    # Add Architecture property to each entry
    Write-Verbose -Message "$($MyInvocation.MyCommand): Adding Architecture property."
    $VcRedists | ForEach-Object { If ($_.Name -contains "x64") { $_ | Add-Member -NotePropertyName "Architecture" -NotePropertyValue "x64" } }

    # If -ExportAll used, export everything instead of filtering for the primary Redistributable
    If ($PSBoundParameters.ContainsKey("ExportAll")) {

        # Write the installed VcRedists to the pipeline
        Write-Output -InputObject $VcRedists
    }
    Else {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Filtering output."
        $Output = $VcRedists | ForEach-Object { If (-not (Select-String -InputObject $_ -Pattern "Additional|Minimum")) { $_ } } | Sort-Object -Property "Name"

        # Write the filtered installed VcRedists to the pipeline
        Write-Output -InputObject $Output
    }
}
