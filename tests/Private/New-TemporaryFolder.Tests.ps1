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
		BeforeAll {
			if ($env:Temp) {
				$Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
			}
			elseif ($env:TMPDIR) {
				$Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
			}
			elseif ($env:RUNNER_TEMP) {
				$Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
			}
			New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null
		}

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
