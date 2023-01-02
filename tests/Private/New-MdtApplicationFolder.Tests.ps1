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

	Describe 'New-MdtApplicationFolder' {
		Context "Application folder exists" {
			BeforeEach {
				Mock Test-Path { $True }
			}

			It "Returns True if the Application folder exists" {
				New-MdtApplicationFolder -Drive "DS001" -Name "VcRedists" | Should -BeTrue
			}
		}

		Context "Creates a new Packages folder" {
			BeforeEach {
				function New-Item {}
				Mock Test-Path { $False }
				Mock New-Item { $obj = [PSCustomObject]@{Name = "VcRedists" } }
			}

			It "Successfully creates a Application folder" {
				New-MdtApplicationFolder -Drive "DS001" -Name "VcRedists" | Should -BeTrue
			}
		}
	}
}
