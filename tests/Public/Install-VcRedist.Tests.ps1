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

Describe "Install-VcRedist" {
    BeforeAll {
        $TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
    }

    Context "Install Redistributables" -ForEach $TestReleases {
        BeforeAll {
            $VcRedist = $_

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

            $VcList = Get-VcList -Release $VcRedist | Save-VcRedist -Path $Path
            $Architectures = @("x86", "x64")
        }

        Context "Test architecture" -ForEach $Architectures {
            BeforeAll {
                $Architecture = $_
                $List = $VcList | Where-Object { $_.Architecture -match $Architecture }
            }

            It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture>" {
                $Installed = Install-VcRedist -VcList $VcList -Architecture $Architecture -Path $Path -Silent
            }

            It "Installed the VcRedist: <VcRedist.Name> <VcRedist.Architecture> successfully" {
                $List.ProductCode | Should -BeIn $Installed.ProductCode
            }
        }
    }
}
