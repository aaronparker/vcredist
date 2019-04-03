<#
    .SYNOPSIS    
        Uninstall all of the installed Visual C++ Redistributables on the local system
#>

[CmdletBinding()]
param (
)

$InstalledVcRedists = Get-InstalledVcRedist | Where-Object { $_.Release -eq 2008 }
ForEach ($Vc in $InstalledVcRedists) {
    Write-Output $Vc.Name
    If ($Null -ne $vc.QuietUninstallString) {
        Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList $vc.QuietUninstallString -Wait
    }
    Else {
        Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList "/c $($Vc.UninstallString) /passive" -Wait
    }
}
