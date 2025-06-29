<#
    .SYNOPSIS
        Pester tests for Get-VcIntuneApplication
#>
[CmdletBinding()]
param ()

Describe "Get-VcIntuneApplication" {
    BeforeAll {
    }

    It "Should not throw when called" {
        { Get-VcIntuneApplication } | Should -Not -Throw
    }

    It "Should call Get-VcList with -Export All" {
        Get-VcIntuneApplication | Out-Null
        Assert-MockCalled Get-VcList -Exactly 1 -Scope It -ParameterFilter { $Export -eq "All" }
    }

    It "Should call Get-VcRedistAppsFromIntune with the VcList" {
        Get-VcIntuneApplication | Out-Null
        Assert-MockCalled Get-VcRedistAppsFromIntune -Exactly 1 -Scope It
    }

    It "Should return the list of Intune apps" {
        $result = Get-VcIntuneApplication
        $result | Should -BeOfType System.Object[]
    }
}
