<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$TestReleases = @("2022")
	$TestVcRedists = Get-VcList -Release $TestReleases
}

Describe -Name "Validate Import-VcConfigMgrApplication" -ForEach $TestReleases {
	Context "ConfigMgr is not installed" {
		It "Should throw when the ConfigMgr module is not installed" {
			$params = @{
				VcList      = $_
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
				VcList      = $_
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
				VcList      = $_
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
