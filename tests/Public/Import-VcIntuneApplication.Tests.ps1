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

Describe -Name "Import-VcIntuneApplication without IntuneWin32App" -ForEach $TestReleases {
	BeforeAll {
	}

	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without IntuneWin32App" {
			{ Import-VcIntuneApplication -VcList $_ } | Should -Throw
		}
	}
}

Describe -Name "Import-VcIntuneApplication without authentication" -ForEach $TestReleases {
	BeforeAll {
		Install-Module -Name "IntuneWin32App" -Force
	}

	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without an authentication token" {
			{ Import-VcIntuneApplication -VcList $_ } | Should -Throw
		}
	}
}

Describe -Name "Import-VcIntuneApplication imports VcRedists" -ForEach $TestReleases {
	BeforeAll {
		foreach ($Module in @("MSAL.PS", "IntuneWin32App")) {
			Install-Module -Name $Module -Force
		}

		try {
			# Authenticate to the Graph API
			# Expects secrets to be passed into environment variables
			Write-Information -MessageData "Authenticate to the Graph API"
			$params = @{
				TenantId     = "$env:TENANT_ID"
				ClientId     = "$env:CLIENT_ID"
				ClientSecret = "$env:CLIENT_SECRET"
			}
			$script:AuthToken = Connect-MSIntuneGraph @params
		}
		catch {
			throw $_
		}
	}

	Context "Import-VcIntuneApplication imports VcRedists into a target tenant" {
		{ Import-VcIntuneApplication -VcList (Get-VcList -Release $_) } | Should -Not -Throw
	}
}
