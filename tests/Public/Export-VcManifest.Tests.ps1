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

Describe -Name "Export-VcManifest" {
	Context "Validate Export-VcManifest" {
		BeforeAll {
			$Json = Export-VcManifest -Path $env:RUNNER_TEMP
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
			{ Export-VcManifest -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Temp")) } | Should -Throw
		}

		It "Given an valid path, it should not throw an error" {
			{ Export-VcManifest -Path $env:RUNNER_TEMP } | Should -Not -Throw
		}

		It "Given an valid path, it should not throw an error" {
			{ Export-VcManifest -Path $env:RUNNER_TEMP } | Should -Not -Throw
		}
	}
}
