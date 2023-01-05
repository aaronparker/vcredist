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

	Context "Uninstall VcRedist <_.Name> x64" {
		{ Uninstall-VcRedist -Release $_ -Architecture "x64" -Confirm:$False } | Should -Not -Throw
	}

	Context "Uninstall VcRedist <_.Name> x86" -ForEach $TestReleases {
		{ Uninstall-VcRedist -Release $_ -Architecture "x86" -Confirm:$False } | Should -Not -Throw
	}

	Context "Test uninstall via the pipeline" {
		{ Get-VcList -Release "2022" | Uninstall-VcRedist -Confirm:$False } | Should -Not -Throw
	}
}
