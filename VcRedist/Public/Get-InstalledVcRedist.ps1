Function Get-InstalledVcRedist {
    <#
        .SYNOPSIS
            Returns the installed Visual C++ Redistributables.

        .DESCRIPTION
            Returns the installed Visual C++ Redistributables.
        
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://docs.stealthpuppy.com/docs/vcredist/usage/getting-the-installed-redistributables

        .PARAMETER ExportAll
            Export all installed Redistributables including the Additional and Minimum Runtimes typically hidden from Programs and Features

        .EXAMPLE
            Get-InstalledVcRedist

            Description:
            Returns the installed Microsoft Visual C++ Redistributables from the current system

        .EXAMPLE
            Get-InstalledVcRedist -ExportAll

            Description:
            Returns the installed Microsoft Visual C++ Redistributables from the current system including the Additional and Minimum Runtimes.
    #>
    [CmdletBinding(SupportsShouldProcess = $False, HelpURI = "https://docs.stealthpuppy.com/docs/vcredist/usage/getting-the-installed-redistributables")]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $False)]
        [System.Management.Automation.SwitchParameter] $ExportAll
    )

    # Get all installed Visual C++ Redistributables installed components
    Write-Verbose -Message "$($MyInvocation.MyCommand): Matching installed VcRedists with [$Filter]."
    $VcRedists = Get-InstalledSoftware | Where-Object { $_.Name -match $script:resourceStrings.Filters.Redist }

    # Add Architecture property to each entry
    Write-Verbose -Message "$($MyInvocation.MyCommand): Adding Architecture property."
    $VcRedists | ForEach-Object { If ($_.Name -contains "x64") { $_ | Add-Member -NotePropertyName "Architecture" -NotePropertyValue "x64" } }

    # If -ExportAll used, export everything instead of filtering for the primary Redistributable
    If ($ExportAll.IsPresent) {
        # Write the installed VcRedists to the pipeline
        Write-Output -InputObject $VcRedists
    }
    Else {
        Write-Verbose -Message "$($MyInvocation.MyCommand): Filtering output."
        $Output = $VcRedists | ForEach-Object { If (-not (Select-String -InputObject $_ -Pattern $script:resourceStrings.Filters.All)) { $_ } } | Sort-Object -Property "Name"

        # Write the filtered installed VcRedists to the pipeline
        Write-Output -InputObject $Output
    }
}
