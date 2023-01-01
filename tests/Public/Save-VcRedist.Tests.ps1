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

Describe "Test-Downloads" {
	BeforeAll {
		#region Functions used in tests
		function Test-VcDownload {
			<#
		.SYNOPSIS
			Tests downloads from Get-VcList are successful.
		#>
			[CmdletBinding()]
			param (
				[Parameter()]
				[PSCustomObject] $VcList,

				[Parameter()]
				[string] $Path
			)
			$Output = $False
			foreach ($VcRedist in $VcList) {
				$folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
				$Target = [System.IO.Path]::Combine($Folder, $(Split-Path -Path $VcRedist.Download -Leaf))
				if (Test-Path -Path $Target -PathType Leaf) {
					Write-Verbose "$($Target) - exists."
					$Output = $True
				}
				else {
					Write-Warning "$($Target) - not found."
					$Output = $False
				}
			}
			Write-Output $Output
		}
		#endregion

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

		$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
		$VcList = Get-VcList -Release $TestReleases
		Save-VcRedist -VcList $VcList -Path $Path
	}

	Context "Download Redistributables" {
		It "Downloads supported Visual C++ Redistributables" {
			Test-VcDownload -VcList $VcList -Path $Path | Should -BeTrue
		}
	}
}

Describe "Save-VcRedist" {
	BeforeAll {
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

        $TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
	}

	Context "Download Redistributables" -ForEach $TestReleases {
        It "Downloads the release <_> and returns the expected object" {
            Save-VcRedist -VcList (Get-VcList -Release $_) -Path $Path | Should -BeOfType "PSCustomObject"
        }
	}
}

Describe "Save-VcRedist pipeline" {
	BeforeAll {
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

		$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
	}

	Context "Test pipeline support" -ForEach $TestReleases {
		It "Should not throw when passed <_> via pipeline with no parameters" {
			{ Get-VcList -Release $_ | Save-VcRedist } | Should -Not -Throw
		}
	}

	Context "Test fail scenarios" {
		It "Given an invalid path, it should throw an error" {
			{ Save-VcRedist -Path ([System.IO.Path]::Combine($Path, "Temp")) } | Should -Throw
		}
	}

	AfterAll {
		Pop-Location
	}
}
