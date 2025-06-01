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

Describe -Name "New-VcMdtBundle" -Skip:$Skip {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"
	}

	Context "New-VcMdtBundle creates a bundle in the MDT deployment share"{
		It "Creates the bundle in the deployment share OK" {
			$params = @{
				MdtPath    = "$env:RUNNER_TEMP\Deployment"
				AppFolder  = "VcRedists"
				Force      = $true
				MdtDrive   = "DS020"
				BundleName = "Visual C++ Redistributables"
				Publisher  = "Microsoft"
				Language   = "en-US"
			}
			{ New-VcMdtBundle @params } | Should -Not -Throw
		}
	}
}
