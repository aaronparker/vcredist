<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
Param (
    $Version = "2019"
)

# Get an array of VcRedists from the curernt manifest and the installed VcRedists
$CurrentManifest = Get-Content -Path $VcManifest | ConvertFrom-Json
$InstalledVcRedists = Get-InstalledVcRedist

# Filter the VcRedists for the target version and compare against what has been installed
ForEach ($ManifestVcRedist in ($CurrentManifest.Supported | Where-Object { $_.Release -eq $Version })) {
    $InstalledItem = $InstalledVcRedists | Where-Object { ($_.Release -eq $ManifestVcRedist.Release) -and ($_.Architecture -eq $ManifestVcRedist.Architecture) }

    # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
    If (($InstalledItem.Count -gt 0) -and ($InstalledItem.Version -gt $ManifestVcRedist.Version)) {
        Write-Host " "
        Write-Host -ForegroundColor Cyan "VcRedist manifest is out of date."
        Write-Host -ForegroundColor Cyan "Installed version:`t$($InstalledItem.Version)"
        Write-Host -ForegroundColor Cyan "Manifest version:`t$($ManifestVcRedist.Version)"

        # Find the index of the VcRedist in the manifest and update it's properties
        $Index = $CurrentManifest.Supported::IndexOf($CurrentManifest.Supported.ProductCode, $ManifestVcRedist.ProductCode)
        $CurrentManifest.Supported[$Index].ProductCode = $InstalledItem.ProductCode
        $CurrentManifest.Supported[$Index].Version = $InstalledItem.Version
    }
}

# Convert to JSON and export to the module manifest
#$VcManifest = "C:\Temp\VcRedists.json"
$CurrentManifest | ConvertTo-Json | Set-Content -Path $VcManifest -Force
