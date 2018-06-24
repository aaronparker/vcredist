Function Get-InstalledVcRedist {
    <#
        .SYNOPSIS
            Returns the installed Visual C++ Redistributables.

        .DESCRIPTION
            Returns the installed Visual C++ Redistributables.

        .OUTPUTS
            System.Array
        
        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .LINK
            https://github.com/aaronparker/Install-VisualCRedistributables

        .PARAMETER ExportAll
            Export all installed Redistributables including the Additional and Minimum Runtimes

        .EXAMPLE
            Get-InstalledVcRedist

            Description:
            Returns the installed Microsoft Visual C++ Redistributables from the current system

        .EXAMPLE
            Get-InstalledVcRedist -ExportAll

            Description:
            Returns the installed Microsoft Visual C++ Redistributables from the current system including the Additional and Minimum Runtimes.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    [OutputType([System.Management.Automation.PSObject])]
    Param (
        [Parameter(Mandatory = $False)]
        [switch] $ExportAll
    )

    # Get all installed Visual C++ Redistributables installed components
    $VcRedists = Get-InstalledSoftware | Where-Object { $_.Name -like "Microsoft Visual C++*" }

    # If -ExportAll used, export everything instead of filtering for the primary Redistributable
    If (-not $ExportAll) {
        $VcRedists = $VcRedists | ForEach-Object { If (-not (Select-String -InputObject $_ -Pattern "Additional|Minimum")) {$_} } | `
            Sort-Object Name
    }
    
    # Write the installed VcRedists to the pipeline
    Write-Output $VcRedists
}
