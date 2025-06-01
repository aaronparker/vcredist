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

	Describe -Name "Get-Bitness" {
		Context "Get-Bitness returns the architecture" {
			It "Returns x64 when run on a 64-bit machine" {
				Get-Bitness | Should -BeExactly "x64"
			}
		}
	}
}
