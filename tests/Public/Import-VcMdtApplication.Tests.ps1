<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
}

Describe -Name "Import-VcMdtApplication with <Release>" -ForEach $SupportedReleases {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"

		$Release = $_
		$Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
		New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" | Out-Null

		$VcListX64 = Get-VcList -Release $Release -Architecture "x64" | Save-VcRedist -Path $Path
		$VcListX86 = Get-VcList -Release $Release -Architecture "x86" | Save-VcRedist -Path $Path
	}

	Context "Import-VcMdtApplication imports Redistributables into the MDT share" {
		It "Imports the <Release> x64 Redistributables into MDT OK" {
			$params = @{
				VcList    = $VcListX64
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				DontHide  = $true
				Force     = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
				Language  = "en-US"
			}
			{ Import-VcMdtApplication @params } | Should -Not -Throw
		}

		It "Imports the <Release> x86 Redistributables into MDT OK" {
			$params = @{
				VcList    = $VcListX86
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				DontHide  = $true
				Force     = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
				Language  = "en-US"
			}
			{ Import-VcMdtApplication @params } | Should -Not -Throw
		}
	}
}
