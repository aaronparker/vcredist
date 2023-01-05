<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$TestReleases = @("2022")
	$TestVcRedists = Get-VcList -Release $TestReleases
}

Describe "Import-VcIntuneApplication without IntuneWin32App" -ForEach $TestReleases {
	BeforeAll {
	}

	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without IntuneWin32App" {
			{ Import-VcIntuneApplication -VcList $_ } | Should -Throw
		}
	}
}

Describe "Import-VcIntuneApplication without authentication" -ForEach $TestReleases {
	BeforeAll {
		Install-Module -Name "IntuneWin32App" -Force
	}

	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without an authentication token" {
			{ Import-VcIntuneApplication -VcList $_ } | Should -Throw
		}
	}
}
