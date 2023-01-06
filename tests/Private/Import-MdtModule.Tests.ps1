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
	Describe -Name "Import-MdtModule without MDT installed" {
		Context "Import-MdtModule without MDT installed" {
			It "Should throw when MDT is not installed" {
				{ Import-MdtModule } | Should -Throw
			}
		}
	}

	Describe -Name "Import-MdtModule with MDT installed OK" {
		BeforeAll {
			# Install the MDT Workbench
			& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"
		}

		Context "Import-MdtModule with MDT installed OK" {
			It "Should return true if the module is installed" {
				Import-MdtModule -Force | Should -BeTrue
			}
		}
	}

	Describe -Name "Import-MdtModule fails with MDT installed but module missing" {
		BeforeAll {
			$RegPath = "HKLM:SOFTWARE\Microsoft\Deployment 4"
			$MdtReg = Get-ItemProperty -Path $RegPath -ErrorAction "SilentlyContinue"
			$MdtInstallDir = Resolve-Path -Path $MdtReg.Install_Dir
			$MdtModule = [System.IO.Path]::Combine($MdtInstallDir, "bin", "MicrosoftDeploymentToolkit.psd1")
			Rename-Item -Path $MdtModule -NewName "MicrosoftDeploymentToolkit.psd1.rename"
		}

		Context "Import-MdtModule with MDT module file missing" {
			It "Should throw when MDT module file is missing" {
				{ Import-MdtModule } | Should -Throw
			}
		}

		AfterAll {
			$MdtModule = [System.IO.Path]::Combine($MdtInstallDir, "bin", "MicrosoftDeploymentToolkit.psd1.rename")
			Rename-Item -Path $MdtModule -NewName "MicrosoftDeploymentToolkit.psd1"
		}
	}
}
