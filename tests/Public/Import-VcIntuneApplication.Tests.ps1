<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleases = @("2022")
	if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
		$Skip = $false
	}
	else {
		$Skip = $true
	}
}

BeforeAll {
}

Describe -Name "Import-VcIntuneApplication without IntuneWin32App" -ForEach $SupportedReleases -Skip:$Skip {
	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without IntuneWin32App" {
			{ Import-VcIntuneApplication -VcList (Get-VcList -Release $_) } | Should -Throw
		}
	}
}

Describe -Name "Import-VcIntuneApplication imports VcRedists" -ForEach $SupportedReleases -Skip:$Skip {
	BeforeAll {
		foreach ($Module in @("MSAL.PS", "IntuneWin32App")) {
			Install-Module -Name $Module -Force
		}
	}

	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without an authentication token" {
			{ Import-VcIntuneApplication -VcList (Get-VcList -Release $_) } | Should -Throw
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

		It "Imports VcRedist into the target tenant OK" {
			# Path with VcRedist downloads
			$Path = "$env:RUNNER_TEMP\Deployment"
			$SavedVcRedist = Save-VcRedist -Path $Path -VcList (Get-VcList -Release $_ -Architecture "x64")
			{ Import-VcIntuneApplication -VcList $SavedVcRedist | Out-Null } | Should -Not -Throw
		}
	}
}
