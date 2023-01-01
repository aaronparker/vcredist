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
	Describe 'New-MdtApplicationFolder' {
		Context "Application folder exists" {
			BeforeEach {
				Mock Test-Path { $True }
			}

			It "Returns True if the Application folder exists" {
				New-MdtApplicationFolder -Drive "DS001" -Name "VcRedists" | Should -BeTrue
			}
		}

		Context "Creates a new Packages folder" {
			BeforeEach {
				function New-Item {}
				Mock Test-Path { $False }
				Mock New-Item { $obj = [PSCustomObject]@{Name = "VcRedists" } }
			}

			It "Successfully creates a Application folder" {
				New-MdtApplicationFolder -Drive "DS001" -Name "VcRedists" | Should -BeTrue
			}
		}
	}
}
