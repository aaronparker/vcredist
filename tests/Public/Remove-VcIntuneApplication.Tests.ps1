<#!
    .SYNOPSIS
        Pester tests for Remove-VcIntuneApplication
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
    $SupportedReleases = @("2017")
    if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
        $Skip = $false
    }
    else {
        $Skip = $true
    }
}

Describe "Remove-VcIntuneApplication" -Skip:$Skip {
    BeforeAll {
    }

    Context "Parameter validation" {
        It "Should throw when VcList is null" {
            { Remove-VcIntuneApplication -VcList $null } | Should -Throw
        }
    }

    Context "Import-VcIntuneApplication imports VcRedists into a target tenant" {
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

            New-Item -Path "$env:RUNNER_TEMP\Deployment" -ItemType Directory -Force | Out-Null
            $Path = "$env:RUNNER_TEMP\Deployment"
            $SavedVcRedist = Save-VcRedist -Path $Path -VcList (Get-VcList -Release "2017" )
            Import-VcIntuneApplication -VcList $SavedVcRedist | Out-Null
        }

        It "Removes VcRedist from Intune OK" {
            { Remove-VcIntuneApplication -VcList $SavedVcRedist } | Should -Not -Throw
        }
    }

    # Context "ShouldProcess support" {
    #     It "Should honor ShouldProcess and not call Remove-IntuneWin32App if ShouldProcess returns false" {
    #         Mock -CommandName Remove-IntuneWin32App -MockWith { throw "Should not be called" }
    #         Mock -CommandName $ExecutionContext.InvokeCommand.GetCommand('ShouldProcess', 'Cmdlet') -MockWith { $false }
    #         { Remove-VcIntuneApplication -VcList $TestVcList } | Should -Not -Throw
    #     }
    # }
}
