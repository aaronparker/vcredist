[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification="Install script called at console")]
<#
    .SYNOPSIS
    Install the VcRedist module and all supported VcRedists on the local system.

    .DESCRIPTION
    Installs the VcRedist PowerShell module and installs the default Microsoft Visual C++ Redistributables on the local system.

    .NOTES
    Copyright 2021, Aaron Parker, stealthpuppy.com
    

#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = "$env:Temp\VcRedist"
)

#region Trust the PSGallery for modules
$Repository = "PSGallery"
If (Get-PSRepository | Where-Object { $_.Name -eq $Repository -and $_.InstallationPolicy -ne "Trusted" }) {
    try {
        Write-Host "Trusting the repository: $Repository."
        Install-PackageProvider -Name "NuGet" -MinimumVersion 2.8.5.208 -Force
        Set-PSRepository -Name $Repository -InstallationPolicy "Trusted"
    }
    catch {
        Throw $_
    }
}
#region

#region Install the VcRedist module; https://vcredist.com/
$Module = "VcRedist"
Write-Host "Checking whether module is installed: $Module."
$installedModule = Get-Module -Name $Module -ListAvailable -ErrorAction "SilentlyContinue" | `
    Sort-Object -Property @{ Expression = { [System.Version]$_.Version }; Descending = $true } | `
    Select-Object -First 1
$publishedModule = Find-Module -Name $Module -ErrorAction "SilentlyContinue"
If (($Null -eq $installedModule) -or ([System.Version]$publishedModule.Version -gt [System.Version]$installedModule.Version)) {
    Write-Host "Installing module: $Module $($publishedModule.Version)."
    $params = @{
        Name               = $Module
        SkipPublisherCheck = $true
        Force              = $true
        ErrorAction        = "Stop"
    }
    Install-Module @params
}
#endregion


#region tasks/install apps
Write-Host "Saving VcRedists to path: $Path."
New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null

Write-Host "Downloading supported Microsoft Visual C++ Redistributables."
Save-VcRedist -VcList (Get-VcList) -Path $Path > $Null

Write-Host "Installing supported Microsoft Visual C++ Redistributables."
$Redists = Install-VcRedist -VcList (Get-VcList) -Path $Path

Write-Host "Install complete."
Write-Host "Installed Visual C++ Redistributables:"
$Redists | Select-Object -Property "Name", "Release", "Architecture", "Version" -Unique
#endregion