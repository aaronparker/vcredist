<#
    .SYNOPSIS    
        Uninstall all of the installed Visual C++ Redistributables on the local system
#>

[CmdletBinding()]
Param ()

$InstalledVcRedists = Get-InstalledVcRedist
ForEach ($Vc in $InstalledVcRedists) {
    Write-Host $Vc.Name
    If ($Null -ne $vc.QuietUninstallString) {
        Write-Host "`t$($vc.QuietUninstallString)"
        Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList "/c $($vc.QuietUninstallString)" -Wait
    }
    Else {
        Write-Host "`t$($Vc.UninstallString)"
        Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList "/c $($Vc.UninstallString) /passive" -Wait
    }
}
