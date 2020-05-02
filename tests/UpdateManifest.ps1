<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
Param ()

$Manifest = Get-Content -Path $VcManifest | ConvertFrom-Json
$Installed = Get-InstalledVcRedist

$2019Manifest = $Manifest.Supported | Where-Object { $_.Release -eq "2019" }

ForEach ($VcRedist in ($Manifest.Supported | Where-Object { $_.Release -eq "2019" })) {
    $Item = $Installed | Where-Object { ($_.Release -eq $VcRedist.Release) -and ($_.Architecture -eq $VcRedist.Architecture) }
    If (($Item.Count -gt 0) -and ($Item.Version -gt $VcRedist.Version)) {
        Write-Host -ForegroundColor Cyan " "
        Write-Host -ForegroundColor Cyan "Release:               $($Item.Release)"
        Write-Host -ForegroundColor Cyan "Architecture:          $($Item.Architecture)"
        Write-Host -ForegroundColor Cyan "Version:               $($Item.Version)"
        Write-Host -ForegroundColor Cyan "Manifest Version:      $($VcRedist.Version)"
    }
}
