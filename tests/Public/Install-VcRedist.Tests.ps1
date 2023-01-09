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

Describe -Name "Install-VcRedist" -ForEach $TestReleases {
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
	}

	Context "Install <Release> x64 Redistributable" {
		BeforeAll {
			$VcRedist = Get-VcList -Release $Release -Architecture "x64" | Save-VcRedist -Path $Path
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture>" {
			{ Install-VcRedist -VcList $VcRedist -Path $Path -Silent } | Should -Not -Throw
		}

		It "Returns the list of installed VcRedists after install" {
			Install-VcRedist -VcList $VcRedist -Path $Path -Silent | Should -BeOfType "System.Management.Automation.PSObject"
		}
	}

	Context "Install <Release> x86 Redistributable" {
		BeforeAll {
			$VcRedist = Get-VcList -Release $Release -Architecture "x86" | Save-VcRedist -Path $Path
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture>" {
			{ Install-VcRedist -VcList $VcRedist -Path $Path -Silent } | Should -Not -Throw
		}

		It "Returns the list of installed VcRedists after install" {
			Install-VcRedist -VcList $VcRedist -Path $Path -Silent | Should -BeOfType "System.Management.Automation.PSObject"
		}
	}
}
