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

Describe -Name "Import-VcIntuneApplication imports VcRedists" -ForEach $TestReleases {
	BeforeAll {
		foreach ($Module in @("MSAL.PS", "IntuneWin32App")) {
			Install-Module -Name $Module -Force
		}
	}

	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without an authentication token" {
			{ Import-VcIntuneApplication -VcList $_ } | Should -Throw
		}
	}

	Context "Import-VcIntuneApplication imports VcRedists into a target tenant" {
		BeforeAll {
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

		It "Imports into the target tenant OK" {
			# Path with VcRedist downloads
			$Path = "$env:RUNNER_TEMP\Deployment"
			$SavedVcRedist = Save-VcRedist -Path $Path -VcList (Get-VcList -Release $_)
			{ Import-VcIntuneApplication -VcList $SavedVcRedist | Out-Null } | Should -Not -Throw
		}
	}
}
