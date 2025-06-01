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

Describe -Name "Update-VcMdtBundle" {
	BeforeAll {
		$isAmd64 = $env:PROCESSOR_ARCHITECTURE -eq "AMD64"
		if (-not $isAmd64) {
			Write-Host "Skipping tests: Not running on AMD64 architecture."
			Skip "Not running on AMD64 architecture."
		}

		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"

	}

	Context "Update-VcMdtBundle updates the bundle in the MDT deployment share" {
		It "Updates the bundle in the deployment share OK" {
			$params = @{
				MdtPath    = "$env:RUNNER_TEMP\Deployment"
				AppFolder  = "VcRedists"
				MdtDrive   = "DS020"
				BundleName = "Visual C++ Redistributables"
				Publisher  = "Microsoft"
			}
			{ Update-VcMdtBundle @params } | Should -Not -Throw
		}
	}
}
