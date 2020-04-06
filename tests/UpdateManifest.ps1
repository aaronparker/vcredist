<#
    .SYNOPSIS
        Private Pester function tests.
#>
[OutputType()]
Param ()

$Manifest = Get-Content -Path $VcManifest | ConvertFrom-Json
$Installed = Get-InstalledVcRedist

$2019Installed = $Installed | Where-Object { $_.Release -eq "2019" }
$2019Manifest = $Manifest.Supported | Where-Object { $_.Release -eq "2019" }


ForEach ($VcRedist in $Manifest.Supported) {
    $Item = $Installed | Where-Object { ($_.Release -eq $VcRedist.Release) -and ($_.Architecture -eq $VcRedist.Architecture) }
    If ($Item.Count -gt 0) {
        If ($Item.ProductCode -ne $VcRedist.ProductCode) {
            Write-Host -ForegroundColor Cyan "Comparing: [$($Item.Release)][$($Item.Architecture)]"
            Write-Host -ForegroundColor Cyan "With     : [$($VcRedist.Release)][$($VcRedist.Architecture)]"
            #$Item
            Write-Host -ForegroundColor Cyan "[$($Item.ProductCode)] does not match [$($VcRedist.ProductCode)]"
        }
    }
}


$Item = $Installed | Where-Object { ($_.Release -eq $VcRedist.Release) -and ($_.Architecture -eq $VcRedist.Architecture) }
If ($Item.Count -gt 0) {
    If ($Item.ProductCode -ne $VcRedist.ProductCode) {
        Write-Host -ForegroundColor Cyan "Comparing: [$($Item.Release)][$($Item.Architecture)]"
        Write-Host -ForegroundColor Cyan "With     : [$($VcRedist.Release)][$($VcRedist.Architecture)]"
        #$Item
        Write-Host -ForegroundColor Cyan "[$($Item.ProductCode)] does not match [$($VcRedist.ProductCode)]"
    }
}

