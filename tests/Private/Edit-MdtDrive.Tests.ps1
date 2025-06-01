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

InModuleScope VcRedist {
	BeforeAll {
		$isAmd64 = $env:PROCESSOR_ARCHITECTURE -eq "AMD64"
		if (-not $isAmd64) {
			Write-Host "Skipping tests: Not running on AMD64 architecture."
			Skip "Not running on ARM64 architecture."
		}
	}

	Describe -Name "Edit-MdtDrive" {
		Context "Validate Edit-MdtDrive" {
			It "Should not throw when sent a valid string" {
				{ Edit-MdtDrive -Drive "DS009" } | Should -Not -Throw
			}

			It "Should throw when sent an invalid string" {
				{ Edit-MdtDrive -Drive "%^&&*&&*(%^^" } | Should -Throw
			}

			It "Returns the expected value from 'ds009'" {
				Edit-MdtDrive -Drive "ds009" | Should -BeExactly "DS009:"
			}

			It "Returns the expected value from 'DS008:'" {
				Edit-MdtDrive -Drive "DS008:" | Should -BeExactly "DS008:"
			}
		}
	}
}
