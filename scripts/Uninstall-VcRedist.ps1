<#
    Uninstall Visual C++ Redistributables
#>

$InstalledVcRedists = Get-InstalledVcRedist
ForEach ($VcRedist in $InstalledVcRedists) {
    Write-Host $VcRedist.Name
    Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList "/c $($VcRedist.UninstallString) /passive" -Wait
}
