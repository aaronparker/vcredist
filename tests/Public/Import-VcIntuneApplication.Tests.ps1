<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
}

Describe "Import-VcIntuneApplication without IntuneWin32App" {
	BeforeAll {

	}
	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without IntuneWin32App" {
			{ Get-VcList | Import-VcIntuneApplication } | Should -Throw
		}
	}
}

Describe "Import-VcIntuneApplication without authentication" {
	BeforeAll {
		Install-Module -Name "IntuneWin32App"
	}
	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without an authentication token" {
			{ Get-VcList | Import-VcIntuneApplication } | Should -Throw
		}
	}
}
