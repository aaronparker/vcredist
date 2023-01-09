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

Describe -Name "Update-VcMdtApplication with <Release>" -ForEach $TestReleases {
	BeforeAll {
		# Install the MDT Workbench
		& "$env:GITHUB_WORKSPACE\tests\Install-Mdt.ps1"

		$Release = $_
		$Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
		New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" | Out-Null
		$SaveList = Save-VcRedist -Path $Path -VcList (Get-VcList -Release $Release)
	}

	Context "Update-VcMdtApplication updates OK with existing Redistributables in the MDT share" {
		It "Does not throw when updating the existing <Release> x64 Redistributables" {
			$params = @{
				VcList    = (Get-VcList -Release $Release -Architecture "x64")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
			}
			{ Update-VcMdtApplication @params } | Should -Not -Throw
		}

		It "Does not throw when updating the existing <Release> x86 Redistributables" {
			$params = @{
				VcList    = (Get-VcList -Release $Release -Architecture "x86")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
			}
			{ Update-VcMdtApplication @params } | Should -Not -Throw
		}
	}
}

Describe -Name "Update-VcMdtApplication updates an existing application" {
	BeforeAll {

		# Setup existing 2022 VcRedist applications with details that need to be updated
		$Path = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "Downloads"))
		$SaveVcRedist = Save-VcRedist -Path $Path -VcList (Get-VcList -Release "2019")
		$Version = (Get-VcList -Release "2022" -Architecture "x64").Version
		$VcPath = "$env:RUNNER_TEMP\Deployment\Applications\Microsoft VcRedist\2022\$Version"
		foreach ($Item in $SaveVcRedist) {
			foreach ($Arch in @("x64", "x86")) {
				Copy-Item -Path $Item.Path -Destination "$VcPath\$Arch" -Force
			}
		}
		Import-Module -Name "$Env:ProgramFiles\Microsoft Deployment Toolkit\bin\MicrosoftDeploymentToolkit.psd1"
		$params = @{
			Name        = "DS020"
			PSProvider  = "MDTProvider"
			Root        = "$env:RUNNER_TEMP\Deployment"
		}
		New-PSDrive @params | Add-MDTPersistentDrive
		Restore-MDTPersistentDrive | Out-Null
		$MdtDrive = "DS020"
		$MdtTargetFolder = "$($MdtDrive):\Applications\VcRedists"
		$gciParams = @{
			Path        = $MdtTargetFolder
			Recurse     = $true
			ErrorAction = "Continue"
		}
		foreach ($Architecture in @("x86", "x64")) {
			$ExistingVcRedist = Get-ChildItem @gciParams | Where-Object { $_.ShortName -match "2022 $Architecture" }
			$params = @{
				Path  = (Join-Path -Path $MdtTargetFolder -ChildPath $ExistingVcRedist.Name)
				Name  = "UninstallKey"
				Value = $((New-Guid).Guid)
			}
			Set-ItemProperty @params
		}
	}

	Context "Update-VcMdtApplication updates Redistributables in the MDT share" {
		It "Updates the 2022 x64 Redistributables in MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release "2022" -Architecture "x64")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
			}
			{ Update-VcMdtApplication @params } | Should -Not -Throw
		}

		It "Updates the 2022 x86 Redistributables in MDT OK" {
			$params = @{
				VcList    = (Get-VcList -Release "2022" -Architecture "x86")
				Path      = $Path
				MdtPath   = "$env:RUNNER_TEMP\Deployment"
				AppFolder = "VcRedists"
				Silent    = $true
				MdtDrive  = "DS020"
				Publisher = "Microsoft"
			}
			{ Update-VcMdtApplication @params } | Should -Not -Throw
		}
	}
}
