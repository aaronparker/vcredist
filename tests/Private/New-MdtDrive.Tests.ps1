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
	BeforeAll {
        if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
            $Skip = $false
        }
        else {
            $Skip = $true
        }
	}

    Describe -Name "New-MdtDrive" -Skip:$Skip {
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
                Remove-PSDrive -Name "DS020" -ErrorAction "SilentlyContinue"
                $Path = "$Env:RUNNER_TEMP\Deployment"
                New-MdtDrive -Drive "DS020" -Path $Path | Should -Be "DS020"
            }
        }
    }
}
