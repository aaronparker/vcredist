<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
    $TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
}

Describe -Name "Uninstall-VcRedist" -ForEach $TestReleases {
    BeforeAll {
        $Release = $_

        # Create download path
        if ($env:Temp) {
            $Path = Join-Path -Path $env:Temp -ChildPath "Downloads"
        }
        elseif ($env:TMPDIR) {
            $Path = Join-Path -Path $env:TMPDIR -ChildPath "Downloads"
        }
        elseif ($env:RUNNER_TEMP) {
            $Path = Join-Path -Path $env:RUNNER_TEMP -ChildPath "Downloads"
        }
        New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $Null

        Get-VcList -Release $Release | Save-VcRedist -Path $Path | Out-Null
        Install-VcRedist -VcList (Get-VcList -Release $Release) -Path $Path -Silent | Out-Null
    }

    Context "Uninstall VcRedist <Release>" {
        It "Uninstalls the VcRedist <Release> x64" {
            { Uninstall-VcRedist -Release $Release -Architecture "x64" -Confirm:$false } | Should -Not -Throw
        }

        It "Uninstalls the VcRedist <Release> x86" {
            { Uninstall-VcRedist -Release $Release -Architecture "x86" -Confirm:$false } | Should -Not -Throw
        }
    }
}

Describe -Name "Uninstall VcRedist via the pipeline" {
    Context "Test uninstall via the pipeline" {
        It "Uninstalls the 2022 Redistributables via the pipeline" {
            { Get-VcList -Release "2022" | Uninstall-VcRedist -Confirm:$false } | Should -Not -Throw
        }
    }
}
