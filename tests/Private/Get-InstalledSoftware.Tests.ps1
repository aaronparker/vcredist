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
	Describe "Get-InstalledSoftware" {
		Context "Get-InstalledSoftware returns the expected output" {
			It "Returns null for software that is not installed" {
				Get-InstalledSoftware -Name "SoftwareThatIsNotInstalled" | Should -BeNullOrEmpty
			}

			It "Returns an object of the expected type" {
				Get-InstalledSoftware | Should -BeOfType [System.Management.Automation.PSObject]
			}

			It "Returns details for installed software" {
				(Get-InstalledSoftware).Count | Should -BeGreaterThan 0
			}

			It "Returns details for GitHub CLI" {
				(Get-InstalledSoftware -Name "Github CLI").Publisher | Should -BeExactly "GitHub, Inc."
			}
		}
	}
}
