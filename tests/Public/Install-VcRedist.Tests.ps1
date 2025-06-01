<#
	.SYNOPSIS
		Public Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
	$SupportedReleasesAmd64 = @("2015", "2017", "2019", "2022")
	$SupportedReleasesArm64 = @("2022")
	$UnsupportedReleases = Get-VcList -Export "Unsupported"

	if ($env:PROCESSOR_ARCHITECTURE -eq "AMD64") {
		$SkipAmd = $false
	}
	else {
		$SkipAmd = $true
	}
	if ($env:PROCESSOR_ARCHITECTURE -eq "ARM64") {
		$SkipArm = $false
	}
	else {
		$SkipArm = $true
	}
}

Describe -Name "Install-VcRedist with unsupported Redistributables AMD64" -ForEach $UnsupportedReleases {
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
		New-Item -Path $Path -ItemType "Directory" -Force -ErrorAction "SilentlyContinue" > $null
	}

	Context "Install <Release[0].Name> Redistributable" -Skip:$SkipAmd {
		BeforeAll {
			$VcRedist = $Release | Save-VcRedist -Path $Path
		}

		It "Installs OK via parameters" {
			{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
		}
	}
}

Describe -Name "Install-VcRedist with supported Redistributables AMD64" -ForEach $SupportedReleasesAmd64 -Skip:$SkipAmd {
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

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
			{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
		}

		It "Returns the list of installed VcRedists after install" {
			Install-VcRedist -VcList $VcRedist -Silent | Should -BeOfType "System.Management.Automation.PSObject"
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
			{ Get-VcList -Release $Release -Architecture "x64" | `
					Save-VcRedist -Path $Path | `
					Install-VcRedist -Silent } | Should -Not -Throw
		}
	}

	Context "Install <Release> x86 Redistributable" {
		BeforeAll {
			$VcRedist = Get-VcList -Release $Release -Architecture "x86" | Save-VcRedist -Path $Path
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
			{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
		}

		It "Returns the list of installed VcRedists after install" {
			Install-VcRedist -VcList $VcRedist -Silent | Should -BeOfType "System.Management.Automation.PSObject"
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
			{ Get-VcList -Release $Release -Architecture "x86" | `
					Save-VcRedist -Path $Path | `
					Install-VcRedist -Silent } | Should -Not -Throw
		}
	}
}

Describe -Name "Install-VcRedist with supported Redistributables ARM64" -ForEach $SupportedReleasesArm64 -Skip:$SkipArm {
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

	Context "Install <Release> arm64 Redistributable" {
		BeforeAll {
			$VcRedist = Get-VcList -Release $Release -Architecture "arm64" | Save-VcRedist -Path $Path
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via parameters" {
			{ Install-VcRedist -VcList $VcRedist -Silent } | Should -Not -Throw
		}

		It "Returns the list of installed VcRedists after install" {
			Install-VcRedist -VcList $VcRedist -Silent | Should -BeOfType "System.Management.Automation.PSObject"
		}

		It "Installs the VcRedist: <VcRedist.Name> <VcRedist.Architecture> via the pipeline" {
			{ Get-VcList -Release $Release -Architecture "arm64" | `
					Save-VcRedist -Path $Path | `
					Install-VcRedist -Silent } | Should -Not -Throw
		}
	}
}
