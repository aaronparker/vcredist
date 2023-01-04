<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
}

Describe -Name "Test-VcRedistDownload" -ForEach $TestReleases {
	BeforeAll {
		$Release = $_
	}

	Context "Test-VcRedistDownload returns true for release <Release> x64" {
		BeforeAll {
			$params = @{
				InputObject = Get-VcRedist -Release $Release -Architecture "x64"
				NoProgress  = $true
			}
			$Test = Test-VcRedistDownload @params
		}

		It "Returns a true result" {
			$Test.Result | Should -BeTrue
		}

		It "Returns an architecture of x64" {
			$Test.Architecture | Should -BeExactly "x64"
		}
	}

	Context "Test-VcRedistDownload returns true for release <Release> x86" {
		BeforeAll {
			$params = @{
				InputObject = Get-VcRedist -Release $Release -Architecture "x86"
				NoProgress  = $true
			}
			$Test = Test-VcRedistDownload @params
		}

		It "Returns a true result" {
			$Test.Result | Should -BeTrue
		}

		It "Returns an architecture of x86" {
			$Test.Architecture | Should -BeExactly "x86"
		}
	}
}
