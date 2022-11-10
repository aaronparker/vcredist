<#
	.SYNOPSIS
		Public Pester function tests.
#>
# [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost")]
# [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseShouldProcessForStateChangingFunctions")]
# [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments")]
[CmdletBinding()]
param ()

BeforeDiscovery {
	$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
	$TestVcRedists = Get-VcList -Release $TestReleases

	if ([System.String]::IsNullOrWhiteSpace($env:Temp)) { $DownloadDir = $env:Temp } else { $DownloadDir = $env:TMPDIR }
	$Path = [System.IO.Path]::Combine($DownloadDir, "VcDownload")
	New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" > $null
	#Save-VcRedist -VcList (Get-VcList) -Path $Path

	if (Test-Path -Path env:GITHUB_WORKSPACE -ErrorAction "SilentlyContinue") {
		[System.Environment]::SetEnvironmentVariable("WorkingPath", $env:GITHUB_WORKSPACE)
	}
	else {
		[System.Environment]::SetEnvironmentVariable("WorkingPath", $env:APPVEYOR_BUILD_FOLDER)
	}
}

Describe -Name "Validate Get-VcList for <VcRedist.Name>" -ForEach $TestVcRedists {
	BeforeAll {
		$VcRedist = $_
	}

	Context "Validate Get-VcList array properties" {
		It "VcRedist [$($VcRedist.Name), $($VcRedist.Architecture)] has expected properties" {
			$VcRedist.Name.Length | Should -BeGreaterThan 0
			$VcRedist.ProductCode.Length | Should -BeGreaterThan 0
			$VcRedist.Version.Length | Should -BeGreaterThan 0
			$VcRedist.URL.Length | Should -BeGreaterThan 0
			$VcRedist.Download.Length | Should -BeGreaterThan 0
			$VcRedist.Release.Length | Should -BeGreaterThan 0
			$VcRedist.Architecture.Length | Should -BeGreaterThan 0
			$VcRedist.Install.Length | Should -BeGreaterThan 0
			$VcRedist.SilentInstall.Length | Should -BeGreaterThan 0
			$VcRedist.SilentUninstall.Length | Should -BeGreaterThan 0
			$VcRedist.UninstallKey.Length | Should -BeGreaterThan 0
		}
	}
}

Describe "Uninstall-VcRedist" {
	BeforeAll {
		$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
	}

	Context "Uninstall VcRedist <_.Name>" -ForEach $TestReleases {
		{ Uninstall-VcRedist -Release $_ -Confirm:$False } | Should -Not -Throw
	}
}

Describe "Install-VcRedist" {
	BeforeAll {
		$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
	}

	Context "Install Redistributables" -Foreach $TestReleases {
		BeforeAll {
			$VcRedist = $_

			if ([System.String]::IsNullOrWhiteSpace($env:Temp)) { $DownloadDir = $env:Temp } else { $DownloadDir = $env:TMPDIR }
			$Path = [System.IO.Path]::Combine($DownloadDir, "VcDownload")
			New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" > $null

			$VcList = Get-VcList -Release $VcRedist | Save-VcRedist -Path $Path
			$Installed = Install-VcRedist -VcList $VcList -Path $Path -Silent

			$Architectures = @("x86", "x64")
		}

		Context "Test architecture" -ForEach $Architectures {
			BeforeAll {
				$Architecture = $_
				$List = $VcList | Where-Object { $_.Architecture -match $Architecture }
			}

			It "Installed the VcRedist: <VcRedist.Name>" {
				$List.ProductCode | Should -BeIn $Installed.ProductCode
			}
		}
	}
}

Describe -Name "Validate manifest counts" {
	BeforeAll {
		$VcCount = @{
			"Default"     = 6
			"Supported"   = 12
			"Unsupported" = 24
			"All"         = 36
		}
	}

	Context "Return built-in manifest" {
		It "Given no parameters, it returns supported Visual C++ Redistributables" {
			Get-VcList | Should -HaveCount $VcCount.Default
		}
		It "Given valid parameter -Export All, it returns all Visual C++ Redistributables" {
			Get-VcList -Export "All" | Should -HaveCount $VcCount.All
		}
		It "Given valid parameter -Export Supported, it returns all Visual C++ Redistributables" {
			Get-VcList -Export "Supported" | Should -HaveCount $VcCount.Supported
		}
		It "Given valid parameter -Export Unsupported, it returns unsupported Visual C++ Redistributables" {
			Get-VcList -Export "Unsupported" | Should -HaveCount $VcCount.Unsupported
		}
	}
}

Describe -Name "Validate manifest scenarios" {
	Context 'Validation' {
		BeforeAll {
			$Json = [System.IO.Path]::Combine($env:WorkingPath, "Redists.json")
			Export-VcManifest -Path $Json
			$VcList = Get-VcList -Path $Json
			$VcCount = @{
				"Default"     = 6
				"Supported"   = 12
				"Unsupported" = 24
				"All"         = 36
			}
		}

		It "Given valid parameter -Path, it returns Visual C++ Redistributables from an external manifest" {
			$VcList.Count | Should -BeGreaterOrEqual $VcCount.Default
		}
		It "Given an JSON file that does not exist, it should throw an error" {
			{ Get-VcList -Path $([System.IO.Path]::Combine($env:WorkingPath, "RedistsFail.json")) } | Should -Throw
		}
		It "Given an invalid JSON file, should throw an error on read" {
			{ Get-VcList -Path $([System.IO.Path]::Combine($env:WorkingPath, "README.MD")) } | Should -Throw
		}
	}
}

Describe "Export-VcManifest" {
	Context 'Validation' {
		BeforeAll {
			$Json = [System.IO.Path]::Combine($env:WorkingPath, "Redists.json")
			Export-VcManifest -Path $Json
			$VcList = Get-VcList -Path $Json
			$VcCount = @{
				"Default"     = 6
				"Supported"   = 12
				"Unsupported" = 24
				"All"         = 36
			}
		}

		It "Given valid parameter -Path, it exports an JSON file" {
			Test-Path -Path $Json | Should -BeTrue
		}
		It "Given valid parameter -Path, it exports an JSON file" {
			$VcList.Count | Should -BeGreaterOrEqual $VcCount.Default
		}
		It "Given an invalid path, it should throw an error" {
			{ Export-VcManifest -Path $([System.IO.Path]::Combine($env:WorkingPath, "Temp", "Temp.json")) } | Should -Throw
		}
	}
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

		if ([System.String]::IsNullOrWhiteSpace($env:Temp)) { $DownloadDir = $env:Temp } else { $DownloadDir = $env:TMPDIR }
		$Path = $([System.IO.Path]::Combine($DownloadDir, "VcDownload"))
		if (Test-Path -Path $Path) { Remove-Item -Path $Path -Recurse -Force }
		New-Item -Path $Path -ItemType "Directory" -Force > $null

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
		if ([System.String]::IsNullOrWhiteSpace($env:Temp)) { $DownloadDir = $env:Temp } else { $DownloadDir = $env:TMPDIR }
		$Path = [System.IO.Path]::Combine($DownloadDir, "VcDownload")
		if (Test-Path -Path $Path) { Remove-Item -Path $Path -Recurse -Force }
		New-Item -Path $Path -ItemType "Directory" -Force > $null

		$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
		$DownloadedRedists = Save-VcRedist -VcList (Get-VcList -Release $TestReleases) -Path $Path
	}

	Context "Download Redistributables" {
		It "Returns an expected object type to the pipeline" {
			$DownloadedRedists | Should -BeOfType "PSCustomObject"
		}
	}
}

Describe "Save-VcRedist pipeline" {
	BeforeAll {
		if ([System.String]::IsNullOrWhiteSpace($env:Temp)) { $DownloadDir = $env:Temp } else { $DownloadDir = $env:TMPDIR }
		New-Item -Path ([System.IO.Path]::Combine($DownloadDir, "VcTest")) -ItemType "Directory" -ErrorAction "SilentlyContinue" > $null
		Push-Location -Path ([System.IO.Path]::Combine($DownloadDir, "VcTest"))
		$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
	}

	Context "Test pipeline support" {
		It "Should not throw when passed via pipeline with no parameters" {
			{ Get-VcList -Release $TestReleases | Save-VcRedist } | Should -Not -Throw
		}
	}

	Context "Test fail scenarios" {
		It "Given an invalid path, it should throw an error" {
			{ Save-VcRedist -Path ([System.IO.Path]::Combine($env:WorkingPath, "Temp")) } | Should -Throw
		}
	}

	AfterAll {
		Pop-Location
	}
}

Describe "Get-InstalledVcRedist" {
	BeforeAll {
		$VcList = Get-InstalledVcRedist
	}

	Context "Validate Get-InstalledVcRedist array properties" -ForEach $VcList {
		It "VcRedist "\<_.Name\>" has expected properties" {
			$_.Name.Length | Should -BeGreaterThan 0
			$_.Version.Length | Should -BeGreaterThan 0
			$_.ProductCode.Length | Should -BeGreaterThan 0
			$_.UninstallString.Length | Should -BeGreaterThan 0
		}
	}
}

Describe "Import-VcIntuneApplication without IntuneWin32App" {
	BeforeAll {

	}
	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without IntuneWin32App" {
			{ Get-VcList | Import-VcIntuneApplication } | Should -Throw
		}
	}
}

Describe "Import-VcIntuneApplication without authentication" {
	BeforeAll {
		Install-Module -Name "IntuneWin32App"
	}
	Context "Validate Import-VcIntuneApplication fail scenarios" {
		It "Should fail without an authentication token" {
			{ Get-VcList | Import-VcIntuneApplication } | Should -Throw
		}
	}
}
