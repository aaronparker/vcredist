<#
    .SYNOPSIS
        AppVeyor install script.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUserDeclaredVarsMoreThanAssignments", "")]
[OutputType()]
Param ()

# Set variables
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    # AppVeyor Testing
    $projectRoot = Resolve-Path -Path $env:APPVEYOR_BUILD_FOLDER
    $module = $env:Module
}
Else {
    # Local Testing
    $projectRoot = Resolve-Path -Path (((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName)
    $module = "VcRedist"
}
$tests = Join-Path $projectRoot "tests"
$output = Join-Path $projectRoot "TestsResults.xml"

# Echo variables
Write-Host -Object ''
Write-Host "ProjectRoot: $projectRoot."
Write-Host "Module name: $module."
Write-Host "Tests path:  $tests."
Write-Host "Output path: $output."

# Line break for readability in AppVeyor console
Write-Host -Object ''
Write-Host "PowerShell Version:" $PSVersionTable.PSVersion.ToString()

# Install packages
Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.208
If (Get-PSRepository -Name "PSGallery" | Where-Object { $_.InstallationPolicy -ne "Trusted" }) {
    Set-PSRepository -Name "PSGallery" -InstallationPolicy Trusted
}
If ([Version]((Find-Module -Name Pester).Version) -gt (Get-Module -Name "Pester").Version) {
    Install-Module -Name "Pester" -SkipPublisherCheck -RequiredVersion 4.10.1 -Force
}
If ([Version]((Find-Module -Name PSScriptAnalyzer).Version) -gt (Get-Module -Name "PSScriptAnalyzer").Version) {
    Install-Module -Name "PSScriptAnalyzer" -SkipPublisherCheck -Force
}
If ([Version]((Find-Module -Name posh-git).Version) -gt (Get-Module -Name "posh-git").Version) {
    Install-Module -Name "posh-git" -Force
}
If ([Version]((Find-Module -Name posh-git).Version) -gt (Get-Module -Name "MarkdownPS").Version) {
    Install-Module -Name "MarkdownPS" -Force
}

# Import module
Write-Host -Object ''
Import-Module (Join-Path $projectRoot $module) -Verbose -Force
