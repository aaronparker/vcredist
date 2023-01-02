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

Describe -Name "Import-VcMdtApplication with <Release>" -ForEach $TestReleases {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"

		$Release = $_
		$Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
		New-Item -Path $Path -ItemType "Directory" | Out-Null
		Save-VcRedist -Path $Path -VcList (Get-VcList -Release $Release)
	}

	Context "Import-VcMdtApplication imports Redistributables into the MDT share" {
		It "Imports the <Release> x64 Redistributables into MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release $Release -Architecture "x64")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				DontHide  = $true
				Force     = $true
				MdtDrive  = "DS099"
				Publisher = "Microsoft"
				Language  = "en-US"
			}
			{ Import-VcMdtApplication @params } | Should -Not -Throw
		}

		It "Imports the <Release> x86 Redistributables into MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release $Release -Architecture "x86")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				DontHide  = $true
				Force     = $true
				MdtDrive  = "DS099"
				Publisher = "Microsoft"
				Language  = "en-US"
			}
			{ Import-VcMdtApplication @params } | Should -Not -Throw
		}
	}
}
