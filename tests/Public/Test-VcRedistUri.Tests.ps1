<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleases = @("2015", "2017", "2019", "2022")
}

Describe -Name "Test-VcRedistUri" -ForEach $SupportedReleases {
	BeforeAll {
		$Release = $_
	}

	Context "Test-VcRedistUri returns true for release <Release> x64" {
		BeforeAll {
			$params = @{
				VcList       = (Get-VcList -Release $Release -Architecture "x64")
				ShowProgress = $true
			}
			$Test = Test-VcRedistUri @params
		}

		It "Returns a true result" {
			$Test.Result | Should -BeTrue
		}

		It "Returns an architecture of x64" {
			$Test.Architecture | Should -BeExactly "x64"
		}
	}

	Context "Test-VcRedistUri returns true for release <Release> x86" {
		BeforeAll {
			$params = @{
				VcList       = (Get-VcList -Release $Release -Architecture "x86")
				ShowProgress = $true
			}
			$Test = Test-VcRedistUri @params
		}

		It "Returns a true result" {
			$Test.Result | Should -BeTrue
		}

		It "Returns an architecture of x86" {
			$Test.Architecture | Should -BeExactly "x86"
		}
	}
}
