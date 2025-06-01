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
        if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
            $Skip = $false
        }
        else {
            $Skip = $true
        }
	}

	Describe -Name "Invoke-Process" -Skip:$Skip {
		Context "Invoke-Process works as expected" {
			It "Should run the command without throwing an exception" {
				$params = @{
					FilePath     = "$env:SystemRoot\System32\cmd.exe"
					ArgumentList = "/c dir $Env:RUNNER_TEMP"
				}
				{ Invoke-Process @params } | Should -Not -Throw
			}

			It "Returns a string from cmd.exe" {
				$params = @{
					FilePath     = "$env:SystemRoot\System32\cmd.exe"
					ArgumentList = "/c dir $Env:RUNNER_TEMP"
				}
				Invoke-Process @params | Should -BeOfType [System.String]
			}

			It "Should throw when passed an executable that does not exist" {
				$params = @{
					FilePath     = "$env:SystemRoot\System32\cmd1.exe"
					ArgumentList = "/c dir $Env:RUNNER_TEMP"
				}
				{ Invoke-Process @params } | Should -Throw
			}
		}
	}
}
