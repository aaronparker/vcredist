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
		$ValidObject = [PSCustomObject]@{
			Name            = "Visual C++ Redistributable for Visual Studio 2022"
			ProductCode     = "{6ba9fb5e-8366-4cc4-bf65-25fe9819b2fc}"
			Version         = "14.34.31931.0"
			URL             = "https://www.visualstudio.com/downloads/"
			URI             = "https://aka.ms/vs/17/release/VC_redist.x86.exe"
			Release         = "2022"
			Architecture    = "x86"
			Install         = "/install /passive /norestart"
			SilentInstall   = "/install /quiet /norestart"
			SilentUninstall = "%ProgramData%\Package Cache\{6ba9fb5e-8366-4cc4-bf65-25fe9819b2fc}\VC_redist.x86.exe /uninstall /quiet /norestart"
			UninstallKey    = "32"
			Path            = "C:\Temp\VcRedist.exe"
			PackageId       = "b1e3c2a7-8f2d-4c3a-9e2a-7c4b1e2d3f4a"
			DetectionFile   = "%SystemRoot%\\System32\\vcruntime140.dll"
		}

		$InvalidObject = [PSCustomObject]@{
			Property1 = "Visual C++ Redistributable for Visual Studio 2022"
			Property2 = "{6ba9fb5e-8366-4cc4-bf65-25fe9819b2fc}"
		}
	}

	Describe -Name "Test-VcListObject" {
		Context "Test-VcListObject validates a valid VcList object" {
			It "Should not throw with a valid object" {
				{ Test-VcListObject -VcList $ValidObject } | Should -Not -Throw
			}

			It "Should return true a valid object" {
				Test-VcListObject -VcList $ValidObject | Should -BeTrue
			}
		}

		Context "Test-VcListObject validates an invalid VcList object" {
			It "Should throw with a valid object" {
				{ Test-VcListObject -VcList $InvalidObject } | Should -Throw
			}
		}
	}
}
