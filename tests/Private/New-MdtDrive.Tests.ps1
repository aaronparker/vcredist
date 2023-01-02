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
            Import-Module -Name "$Env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
        }

        Context "Creates a new MDT drive" {
            It "Does not throw when connecting to an MDT share" {
                $Path = "$Env:RUNNER_TEMP\Deployment"
                { $Drive = New-MdtDrive -Drive "DS020" -Path $Path } | Should -Not -Throw
            }

            It "Returns the expected MDT drive name" {
                $Path = "$Env:RUNNER_TEMP\Deployment"
                New-MdtDrive -Drive "DS020" -Path $Path | Should -Be "DS020"
            }
        }
    }
}
