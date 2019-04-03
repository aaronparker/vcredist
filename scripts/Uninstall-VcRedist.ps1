<#
    .SYNOPSIS    
        Uninstall all of the installed Visual C++ Redistributables on the local system
#>

[CmdletBinding()]
param (
)

$InstalledVcRedists = Get-InstalledVcRedist
ForEach ($Vc in $InstalledVcRedists) {
    Write-Output $Vc.Name
    If ($Null -eq $vc.QuietUninstallString) {
        Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList $vc.QuietUninstallString -Wait
    }
    Else {
        Start-Process -FilePath "$env:SystemRoot\System32\cmd.exe" -ArgumentList "/c $($Vc.UninstallString) /passive" -Wait
    }
}
