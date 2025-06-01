<#
	.SYNOPSIS
		Manifest tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
    $ValidateReleasesAmd64 = @("2017", "2019", "2022")
    $ValidateReleasesArm64 = @("2022")

    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $SkipAmd = $false
    }
    else {
        $SkipAmd = $true
    }
    if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
        $SkipArm = $false
    }
    else {
        $SkipArm = $true
    }
}

Describe -Name "VcRedist manifest tests AMD64" -ForEach $ValidateReleasesAmd64 -Skip:$SkipAmd {
    BeforeAll {
        Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$false
    }

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
                $VcList = Get-VcList -Release $VcRedist | Save-VcRedist -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
                Install-VcRedist -VcList $VcList -Silent
                $InstalledVcRedists = Get-InstalledVcRedist

                $ManifestVcRedist = $CurrentManifest.Supported | Where-Object { $_.Release -eq $VcRedist }
                $InstalledItem = $InstalledVcRedists | Where-Object { ($VcRedist -eq $ManifestVcRedist.Release) -and ($_ -eq $ManifestVcRedist.Architecture) }
            }

            # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
            It "$($ManifestVcRedist.Release) $($ManifestVcRedist.Architecture) version should be current" {
                [System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version | Should -Be $false
            }
        }
    }
}

Describe -Name "VcRedist manifest tests ARM64" -ForEach $ValidateReleasesArm64 -Skip:$SkipArm {
    BeforeAll {
        Get-InstalledVcRedist | Uninstall-VcRedist -Confirm:$false
    }

    Context "Validate manifest" {
        BeforeAll {
            $VcManifest = "$env:GITHUB_WORKSPACE\VcRedist\VisualCRedistributables.json"
            Write-Host -ForegroundColor "Cyan" "`tGetting manifest from: $VcManifest."
            $CurrentManifest = Get-Content -Path $VcManifest | ConvertFrom-Json
            $VcRedist = $_

            $Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
            New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" > $null
            Save-VcRedist -VcList (Get-VcList -Release $VcRedist) -Path $Path

            $Architectures = @("arm64")
        }

        Context "Compare manifest version against installed version for <VcRedist>" -ForEach $Architectures {
            BeforeEach {
                $VcList = Get-VcList -Release $VcRedist | Save-VcRedist -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
                Install-VcRedist -VcList $VcList -Silent
                $InstalledVcRedists = Get-InstalledVcRedist

                $ManifestVcRedist = $CurrentManifest.Supported | Where-Object { $_.Release -eq $VcRedist }
                $InstalledItem = $InstalledVcRedists | Where-Object { ($VcRedist -eq $ManifestVcRedist.Release) -and ($_ -eq $ManifestVcRedist.Architecture) }
            }

            # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
            It "$($ManifestVcRedist.Release) $($ManifestVcRedist.Architecture) version should be current" {
                [System.Version]$InstalledItem.Version -gt [System.Version]$ManifestVcRedist.Version | Should -Be $false
            }
        }
    }
}
