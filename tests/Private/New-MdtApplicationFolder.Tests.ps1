<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
		$Skip = $false
	}
	else {
		$Skip = $true
	}
}

InModuleScope VcRedist {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"
		Import-Module -Name "$Env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
	}

	Describe 'New-MdtApplicationFolder' -Skip:$Skip {
		BeforeAll {
			New-MdtDrive -Drive "DS020" -Path "$Env:RUNNER_TEMP\Deployment"
			Restore-MDTPersistentDrive -Force > $null
		}

		Context "Validates New-MdtApplicationFolder" {
			It "Does not throw when creating an application folder" {
				{ New-MdtApplicationFolder -Drive "DS020:" -Name "Test1" -Verbose } | Should -Not -Throw
			}

			It "Returns true if the application folder is created" {
				New-MdtApplicationFolder -Drive "DS020:" -Name "Test2" -Verbose | Should -BeTrue
			}

			It "It throws when referencing a drive that does not exist" {
				{ New-MdtApplicationFolder -Drive "DS021:" -Name "Test1" -Verbose } | Should -Throw
			}
		}
	}
}
