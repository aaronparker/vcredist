<#
    .SYNOPSIS
        Pester tests for Get-VcIntuneApplication
#>
[CmdletBinding()]
param ()

Describe "Get-VcIntuneApplication" {
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

    It "Should not throw when called" {
        { Get-VcIntuneApplication } | Should -Not -Throw
    }

    It "Should return the list of Intune apps" {
        $result = Get-VcIntuneApplication
        $result | Should -BeOfType System.Object[]
    }
}
