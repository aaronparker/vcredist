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
	Describe 'New-TemporaryFolder' {
		Context "Test New-TemporaryFolder" {
			It "Does not throw" {
				{ $Path = New-TemporaryFolder } | Should -Not -Throw
			}

			It "Creates a temporary directory" {
				Test-Path -Path $Path | Should -BeTrue
			}
		}
	}
}
