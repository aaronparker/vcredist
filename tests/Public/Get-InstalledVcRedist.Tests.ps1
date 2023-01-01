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

Describe "Get-InstalledVcRedist" {
	BeforeAll {
		$VcList = Get-InstalledVcRedist
	}

	Context "Validate Get-InstalledVcRedist array properties" -ForEach $VcList {
		It "VcRedist <_.Name> has expected Name property" {
            [System.Boolean]($_.Name) | Should -BeTrue
		}

        It "VcRedist <_.Name> has expected Version property" {
            [System.Boolean]($_.Version) | Should -BeTrue
		}

        It "VcRedist <_.Name> has expected ProductCode property" {
            [System.Boolean]($_.ProductCode) | Should -BeTrue
		}

        It "VcRedist <_.Name> has expected UninstallString property" {
            [System.Boolean]($_.UninstallString) | Should -BeTrue
		}
	}
}
