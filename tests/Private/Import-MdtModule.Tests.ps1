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
	Describe "Import-MdtModule without MDT installed" {
		Context "Import-MdtModule without MDT installed" {
			It "Should throw when MDT is not installed" {
				{ Import-MdtModule } | Should -Throw
			}
		}
	}

	Describe "Import-MdtModule with MDT installed OK" {
		BeforeAll {
			# Install the MDT Workbench
			Write-Host "Downloading and installing the Microsoft Deployment Toolkit"
			$Url = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
			$OutFile = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "MicrosoftDeploymentToolkit_x64.msi"))
			if (-not(Test-Path -Path $OutFile)) {
				$params = @{
					Uri             = $Url
					OutFile         = $OutFile
					UseBasicParsing = $true
				}
				Invoke-WebRequest @params
			}
			$MdtModule = [System.IO.Path]::Combine($MdtInstallDir, "bin", "MicrosoftDeploymentToolkit.psd1")
			if (-not(Test-Path -Path $MdtModule)) {
				$params = @{
					FilePath     = "$env:SystemRoot\System32\msiexec.exe"
					ArgumentList = "/package $OutFile /quiet"
					NoNewWindow  = $true
					Wait         = $false
					PassThru     = $false
				}
				Start-Process @params
			}
		}

		Context "Import-MdtModule with MDT installed OK" {
			It "Should return true if the module is installed" {
				Import-MdtModule -Force | Should -BeTrue
			}
		}
	}

	Describe "Import-MdtModule fails with MDT installed but module missing" {
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
