<#
	.SYNOPSIS
		Public Pester function tests.
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
[CmdletBinding()]
param ()

BeforeDiscovery {
    Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$False
    $ValidateReleases = @("2017", "2019", "2022")
}

Describe "VcRedist manifest tests" -ForEach $ValidateReleases {
    Context "Validate manifest" {
        BeforeAll {
            $VcManifest = "$env:GITHUB_WORKSPACE\VcRedist\VisualCRedistributables.json"
            Write-Host -ForegroundColor "Cyan" "`tGetting manifest from: $VcManifest."
            $CurrentManifest = Get-Content -Path $VcManifest | ConvertFrom-Json
            $VcRedist = $_

            $Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
            New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" > $null
            Save-VcRedist -VcList (Get-VcList -Release $VcRedist) -Path $Path

            $Architectures = @("x86", "x64")
        }

        Context "Compare manifest version against installed version for <VcRedist>" -ForEach $Architectures {
            BeforeEach {
                Install-VcRedist -VcList (Get-VcList -Release $VcRedist) -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads")) -Silent
                $InstalledVcRedists = Get-InstalledVcRedist
            
                $ManifestVcRedist = $CurrentManifest.Supported | Where-Object { $_.Release -eq $VcRedist }
                $InstalledItem = $InstalledVcRedists | Where-Object { ($VcRedist -eq $ManifestVcRedist.Release) -and ($_ -eq $ManifestVcRedist.Architecture) }
            }

            # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
            It "$($ManifestVcRedist.Release) $($ManifestVcRedist.Architecture) version should be current" {
                [System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version | Should -Be $False
            }
        }
    }
}

AfterAll {
    Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$False -WarningAction "SilentlyContinue"
}