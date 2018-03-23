<#
    .SYNOPSIS
        Simple script for listing the DiplayName and UninstallString for the Visual C++ Redistributables.
        Used to grab GUIDs when Redistributables are updated.
#>
Get-ChildItem -Path HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall, HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall | `
Get-ItemProperty | Where-Object {$_.DisplayName -like "Microsoft Visual C*"} | Select-Object Publisher, DisplayName, DisplayVersion, UninstallString | `
Sort-Object DisplayName