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
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"
		Import-Module -Name "$Env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
	}

	Describe 'New-MdtApplicationFolder' {
		BeforeAll {
			New-MdtDrive -Drive "DS020" -Path "$Env:RUNNER_TEMP\Deployment"
		}

		Context "Validates New-MdtApplicationFolder" {
			It "Does not throw when creating an application folder" {
				{ New-MdtApplicationFolder -Drive "DS020:" -Name "Test1" -Verbose } | Should -Not -Throw
			}

			It "Returns true if the application folder is created" {
				New-MdtApplicationFolder -Drive "DS020:" -Name "Test2" -Verbose | Should -BeTrue
			}
		}
	}
}
