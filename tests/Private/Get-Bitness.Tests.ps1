<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
		$Skip = $false
	}
	else {
		$Skip = $true
	}
}

InModuleScope VcRedist {
	BeforeAll {
	}

	Describe -Name "Get-Bitness" -Skip:$Skip {
		Context "Get-Bitness returns the architecture" {
			It "Returns x64 when run on a 64-bit machine" {
				Get-Bitness | Should -BeExactly "x64"
			}
		}
	}
}
