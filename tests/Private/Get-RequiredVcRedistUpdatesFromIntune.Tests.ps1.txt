<#
    .SYNOPSIS
        Pester tests for Get-RequiredVcRedistUpdatesFromIntune
#>
[CmdletBinding()]
param ()

InModuleScope VcRedist {
    Describe "Get-RequiredVcRedistUpdatesFromIntune" {
        Context "Basic Functionality" {
            It "Should not throw when called with no parameters" {
                { Get-RequiredVcRedistUpdatesFromIntune } | Should -Not -Throw
            }
            It "Should return an array or $null" {
                $result = Get-RequiredVcRedistUpdatesFromIntune
                ($result -is [System.Array] -or $null -eq $result) | Should -BeTrue
            }
        }
        Context "Parameter validation" {
            It "Should throw when VcList is missing" {
                { Get-RequiredVcRedistUpdatesFromIntune } | Should -Throw
            }
        }
    }
}
