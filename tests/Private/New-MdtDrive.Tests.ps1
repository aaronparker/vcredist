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

InModuleScope -ModuleName "VcRedist" {
    Describe "New-MdtDrive" {
        BeforeAll {
            # Install the MDT Workbench
            & "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"
        }

        Context "Creates a new MDT drive" {
            It "Does not throw when connecting to an MDT share" {
                $Drive = New-MdtDrive -Drive "DS020" -Path $Path | Should -Not -Throw
            }

            It "Returns the expected MDT drive name" {
                $Drive | Should -Be "DS020"
            }
        }
    }
}
