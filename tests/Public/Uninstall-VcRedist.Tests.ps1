<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$TestReleases = @("2012", "2013", "2015", "2017", "2019")
}

Describe "Uninstall-VcRedist" -ForEach $TestReleases {
	BeforeAll {
		if ($env:Temp) {
            $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
        }
        elseif ($env:TMPDIR) {
            $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
        }
        elseif ($env:RUNNER_TEMP) {
            $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
        }
        New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null

		Write-Host "Test uninstall $_"
		Get-VcList -Release $_ | Save-VcRedist -Path $Path | Out-Null
		Install-VcRedist -VcList (Get-VcList -Release $_) -Path $Path -Silent | Out-Null
	}

	Context "Uninstall VcRedist <_> x64" {
		{ Uninstall-VcRedist -Release $_ -Architecture "x64" -Confirm:$false } | Should -Not -Throw
	}

	Context "Uninstall VcRedist <_> x86" -ForEach $TestReleases {
		{ Uninstall-VcRedist -Release $_ -Architecture "x86" -Confirm:$false } | Should -Not -Throw
	}
}

Describe "Uninstall VcRedist via the pipeline" {
	Context "Test uninstall via the pipeline" {
		{ Get-VcList -Release "2022" | Uninstall-VcRedist -Confirm:$false } | Should -Not -Throw
	}
}
