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
	$TestVcRedists = Get-VcList -Release $TestReleases
}

Describe -Name "Validate Get-VcList for <VcRedist.Name>" -ForEach $TestVcRedists {
	BeforeAll {
		$VcRedist = $_
		$Name = $_.Name
		$Architecture = $_.Architecture
	}

	Context "Validate Get-VcList array properties" {
		It "VcRedist '<Name>, <Architecture>' has a Name property" {
            [System.Boolean]($VcRedist.Name) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a ProductCode property" {
            [System.Boolean]($VcRedist.ProductCode) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a Version property" {
            [System.Boolean]($VcRedist.Version) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a URL property" {
            [System.Boolean]($VcRedist.URL) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a URI property" {
            [System.Boolean]($VcRedist.URI) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a Release property" {
            [System.Boolean]($VcRedist.Release) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has an Architecture property" {
            [System.Boolean]($VcRedist.Architecture) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has an Install property" {
            [System.Boolean]($VcRedist.Install) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a SilentInstall property" {
            [System.Boolean]($VcRedist.SilentInstall) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has a SilentUninstall property" {
            [System.Boolean]($VcRedist.SilentUninstall) | Should -BeTrue
        }

        It "VcRedist '<Name>, <Architecture>' has an UninstallKey property" {
            [System.Boolean]($VcRedist.UninstallKey) | Should -BeTrue
        }
	}
}

Describe -Name "Get-VcRedist parameters" {
    Context "Test Get-VcRedist parameters" {
        It "Returns the expected output for VcRedist 2022" {
            (Get-VcList -Release "2022")[0].Name | Should -BeExactly "Visual C++ Redistributable for Visual Studio 2022"
        }

        It "Returns 3 items for x64" {
            (Get-VcList -Architecture "x64").Count | Should -BeExactly 3
        }
    }
}

Describe -Name "Validate manifest counts from Get-VcList" {
	BeforeAll {
		$VcCount = @{
			"Default"     = 6
			"Supported"   = 12
			"Unsupported" = 24
			"All"         = 36
		}
	}

	Context "Return built-in manifest with Get-VcList" {
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

Describe -Name "Validate manifest scenarios with Get-VcList" {
	Context 'Validate Get-VcList' {
		BeforeAll {
			$Json = Export-VcManifest -Path $env:RUNNER_TEMP
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
			{ Get-VcList -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "RedistsFail.json")) } | Should -Throw
		}
		It "Given an invalid JSON file, should throw an error on read" {
			{ Get-VcList -Path $([System.IO.Path]::Combine($env:RUNNER_TEMP, "README.MD")) } | Should -Throw
		}
	}
}
