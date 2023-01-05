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

Describe -Name "Update-VcMdtApplication with <Release>" -ForEach $TestReleases {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"

		$Release = $_
		$Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
		New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" | Out-Null
		Save-VcRedist -Path $Path -VcList (Get-VcList -Release $Release)
	}

	Context "Update-VcMdtApplication updates Redistributables in the MDT share" {
		It "Updates the <Release> x64 Redistributables in MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release $Release -Architecture "x64")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
			}
			{ Update-VcMdtApplication @params } | Should -Not -Throw
		}

		It "Updates the <Release> x86 Redistributables in MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release $Release -Architecture "x86")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
			}
			{ Update-VcMdtApplication @params } | Should -Not -Throw
		}
	}
}
