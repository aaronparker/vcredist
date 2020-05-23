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

Describe 'VcRedist manifest tests' -Tag "Manifest" {
    Context 'Compare manifest version against installed version' {

        # Filter the VcRedists for the target version and compare against what has been installed
        ForEach ($ManifestVcRedist in ($CurrentManifest.Supported | Where-Object { $_.Release -eq $Version })) {
            $InstalledItem = $InstalledVcRedists | Where-Object { ($_.Release -eq $ManifestVcRedist.Release) -and ($_.Architecture -eq $ManifestVcRedist.Architecture) }

            # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
            It "$($ManifestVcRedist.Release) $($ManifestVcRedist.Architecture) version should be current" {
                [Version]$InstalledItem.Version -gt [Version]$ManifestVcRedist.Version | Should -Not -Be $True
            }
        }

    }
}
