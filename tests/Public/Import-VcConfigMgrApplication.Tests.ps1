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

Describe -Name "Validate Import-VcConfigMgrApplication" {
	Context "ConfigMgr is not installed" {
		It "Should throw when the ConfigMgr module is not installed" {
			$params = @{
				VcList      = (Get-VcList)
				Path        = "$env:RUNNER_TEMP\Downloads"
				CMPath      = $env:RUNNER_TEMP
				SMSSiteCode = "LAB"
				AppFolder   = "VcRedists"
				Silent      = $true
				NoCopy      = $true
				Publisher   = "Microsoft"
				Keyword     = "Visual C++ Redistributable"
			}
			{ Import-VcConfigMgrApplication @params } | Should -Throw
		}
	}

	Context "ConfigMgr is not installed but env:SMS_ADMIN_UI_PATH set to a valid path" {
		BeforeAll {
			[Environment]::SetEnvironmentVariable("SMS_ADMIN_UI_PATH", "$env:RUNNER_TEMP")
		}

		It "Should throw when env:SMS_ADMIN_UI_PATH is valid but module does not exist" {
			$params = @{
				VcList      = (Get-VcList)
				Path        = "$env:RUNNER_TEMP\Downloads"
				CMPath      = $env:RUNNER_TEMP
				SMSSiteCode = "LAB"
				AppFolder   = "VcRedists"
				Silent      = $true
				NoCopy      = $true
				Publisher   = "Microsoft"
				Keyword     = "Visual C++ Redistributable"
			}
			{ Import-VcConfigMgrApplication @params } | Should -Throw
		}
	}

	Context "ConfigMgr is not installed but env:SMS_ADMIN_UI_PATH set to an invalid path" {
		BeforeAll {
			[Environment]::SetEnvironmentVariable("SMS_ADMIN_UI_PATH", "$env:RUNNER_TEMP\Test")
		}

		It "Should throw when env:SMS_ADMIN_UI_PATH is invalid" {
			$params = @{
				VcList      = (Get-VcList)
				Path        = "$env:RUNNER_TEMP\Downloads"
				CMPath      = $env:RUNNER_TEMP
				SMSSiteCode = "LAB"
				AppFolder   = "VcRedists"
				Silent      = $true
				NoCopy      = $true
				Publisher   = "Microsoft"
				Keyword     = "Visual C++ Redistributable"
			}
			{ Import-VcConfigMgrApplication @params } | Should -Throw
		}
	}
}
