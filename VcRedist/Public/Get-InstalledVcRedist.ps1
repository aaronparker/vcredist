function Get-InstalledVcRedist {
    <#
        .EXTERNALHELP VcRedist-help.xml
    #>
    [CmdletBinding(SupportsShouldProcess = $false, HelpURI = "https://vcredist.com/get-installedvcredist/")]
    [OutputType([System.Management.Automation.PSObject])]
    param (
        [Parameter(Mandatory = $false)]
        [System.Management.Automation.SwitchParameter] $ExportAll
    )

    if ($PSBoundParameters.ContainsKey("ExportAll")) {
        # If -ExportAll used, export everything instead of filtering for the primary Redistributable
        # Get all installed Visual C++ Redistributables installed components
        Write-Verbose -Message "-ExportAll specified. Exporting all install Visual C++ Redistributables and runtimes."
        $Filter = "(Microsoft Visual C.*).*"
    }
    else {
        $Filter = "(Microsoft Visual C.*)(\bRedistributable).*"
    }

    # Get all installed Visual C++ Redistributables installed components
    Write-Verbose -Message "Matching installed VcRedists with: '$Filter'."
    $VcRedists = Get-InstalledSoftware | Where-Object { $_.Name -match $Filter }

    # Add Architecture property to each entry
    Write-Verbose -Message "Add Architecture property to output object."
    $VcRedists | ForEach-Object { 
        if ($_.Name -like "*x64*") { $_.Architecture = "x64" }
        if ($_.Name -like "*Arm64*") { $_.Architecture = "ARM64" }
    }

    # Write the installed VcRedists to the pipeline
    Write-Output -InputObject $VcRedists
}
