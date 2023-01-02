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
	$TestVcRedists = Get-VcList -Release $TestReleases
}

Describe -Name "Import-VcMdtApplication" -ForEach $TestVcRedists {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"

		$VcRedist = $_
	}

	Context "Import-VcMdtApplication imports Redistributables into the MDT share" {
		It "Imports the <VcRedist> x64 Redistributables into MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release $VcRedist -Architecture "x64")
				Path      = "$env:RUNNER_TEMP\Downloads"
				MdtPath   = "$Env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				DontHide  = $true
				Force     = $true
				MdtDrive  = "DS099"
				Publisher = "Microsoft"
				Language  = "en-US"
			}
			Import-VcMdtApplication @params | Should -Not -Throw
		}

		It "Imports the <VcRedist> x86 Redistributables into MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release $VcRedist -Architecture "x86")
				Path      = "$env:RUNNER_TEMP\Downloads"
				MdtPath   = "$Env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				DontHide  = $true
				Force     = $true
				MdtDrive  = "DS099"
				Publisher = "Microsoft"
				Language  = "en-US"
			}
			Import-VcMdtApplication @params | Should -Not -Throw
		}
	}
}
