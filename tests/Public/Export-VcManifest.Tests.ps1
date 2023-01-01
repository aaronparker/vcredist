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

Describe "Export-VcManifest" {
	Context 'Validation' {
		BeforeAll {
			$Json = [System.IO.Path]::Combine($env:RUNNER_TEMP, "Redists.json")
			Export-VcManifest -Path $Json
			$VcList = Get-VcList -Path $Json
			$VcCount = @{
				"Default"     = 6
				"Supported"   = 12
				"Unsupported" = 24
				"All"         = 36
			}
		}

		It "Given valid parameter -Path, it exports an JSON file" {
			Test-Path -Path $Json | Should -BeTrue
		}
		It "Given valid parameter -Path, it exports an JSON file" {
			$VcList.Count | Should -BeGreaterOrEqual $VcCount.Default
		}
		It "Given an invalid path, it should throw an error" {
			{ Export-VcManifest -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Temp", "Temp.json")) } | Should -Throw
		}
	}
}
