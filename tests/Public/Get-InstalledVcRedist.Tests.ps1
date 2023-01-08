<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$VcList = Get-InstalledVcRedist
	$AllVcList = Get-InstalledVcRedist -ExportAll
}

Describe -Name "Get-InstalledVcRedist" {
	Context "Validate Get-InstalledVcRedist" {
		It "Should not throw" {
			{ Get-InstalledVcRedist } | Should -Not -Throw
		}

		It "Should not throw with -ExportAll" {
			{ Get-InstalledVcRedist -ExportAll } | Should -Not -Throw
		}
	}
}

Describe -Name "Get-InstalledVcRedist with default VcRedists" -ForEach $VcList {
	Context "Validate Get-InstalledVcRedist array properties" {
		It "VcRedist <_.Name> has expected Name property" {
			[System.Boolean]$_.Name | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected Version property" {
			[System.Boolean]$_.Version | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected ProductCode property" {
			[System.Boolean]$_.ProductCode | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected UninstallString property" {
			[System.Boolean]$_.UninstallString | Should -BeTrue
		}
	}
}

Describe -Name "Get-InstalledVcRedist with all VcRedists" -ForEach $AllVcList {
	Context "Validate Get-InstalledVcRedist array properties" {
		It "VcRedist <_.Name> has expected Name property" {
			[System.Boolean]$_.Name | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected Version property" {
			[System.Boolean]$_.Version | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected ProductCode property" {
			[System.Boolean]$_.ProductCode | Should -BeTrue
		}

		It "VcRedist <_.Name> has expected UninstallString property" {
			[System.Boolean]$_.UninstallString | Should -BeTrue
		}
	}
}
