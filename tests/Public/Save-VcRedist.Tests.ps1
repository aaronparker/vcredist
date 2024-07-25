<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleases = @("2015", "2017", "2019", "2022")
}

Describe -Name "Save-VcRedist" -ForEach $SupportedReleases {
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
			$Output = $false
			foreach ($VcRedist in $VcList) {
				$folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
				$Target = [System.IO.Path]::Combine($Folder, $(Split-Path -Path $VcRedist.URI -Leaf))
				if (Test-Path -Path $Target -PathType Leaf) {
					Write-Verbose "$($Target) - exists."
					$Output = $true
				}
				else {
					Write-Warning "$($Target) - not found."
					$Output = $false
				}
			}
			Write-Output $Output
		}
		#endregion
	}

	Context "Download Redistributables" {
        It "Downloads the release <_> x64 and returns the expected object" {
            Save-VcRedist -VcList (Get-VcList -Release $_ -Architecture "x64") -Path $Path | Should -BeOfType "PSCustomObject"
        }

		It "Downloads the release <_> x86 and returns the expected object" {
            Save-VcRedist -VcList (Get-VcList -Release $_ -Architecture "x86") -Path $Path | Should -BeOfType "PSCustomObject"
        }
	}

	Context "Test downloaded Redistributables" {
		It "Downloaded Visual C++ Redistributables <_> x64 OK" {
			Test-VcDownload -VcList (Get-VcList -Release $_ -Architecture "x64") -Path $Path | Should -BeTrue
		}

		It "Downloaded Visual C++ Redistributables <_> x86 OK" {
			Test-VcDownload -VcList (Get-VcList -Release $_ -Architecture "x86") -Path $Path | Should -BeTrue
		}
	}
}

Describe -Name "Save-VcRedist pipeline" -ForEach $SupportedReleases {
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
		Push-Location -Path $Path
	}

	Context "Test pipeline support" {
		It "Should not throw when passed <_> x64 via pipeline with no parameters" {
			{ Get-VcList -Release $_ -Architecture "x64" | Save-VcRedist } | Should -Not -Throw
		}

		It "Should not throw when passed <_> x86 via pipeline with no parameters" {
			{ Get-VcList -Release $_ -Architecture "x86" | Save-VcRedist } | Should -Not -Throw
		}
	}

	AfterAll {
		Pop-Location
	}
}

Describe -Name "Save-VcRedist fail scenarios" {
	Context "Test fail scenarios" {
		It "Given an invalid path, it should throw an error" {
			{ Save-VcRedist -Path ([System.IO.Path]::Combine($Path, "Temp")) } | Should -Throw
		}
	}
}
