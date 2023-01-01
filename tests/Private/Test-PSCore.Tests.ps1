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
	Describe "Test-PSCore" {
		Context "Test for Windows PowerShell or PowerShell Core" {
			if (($PSVersionTable.PSVersion -ge [System.Version]::Parse("6.0.0")) -and ($PSVersionTable.PSEdition -eq "Core")) {
				It "Returns true when running on PowerShell Core" {
					Test-PSCore | Should -BeTrue
				}
			}

			if ($PSVersionTable.PSEdition -eq "Desktop") {
				It "Returns False if running Windows PowerShell" {
					Test-PSCore | Should -BeFalse
				}

				It "Returns False if running Windows PowerShell and when passed a version string" {
					Test-PSCore -Version "7.0.0" | Should -BeFalse
				}
			}
		}
	}
}
