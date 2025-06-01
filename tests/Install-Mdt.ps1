<#
  Downloads and installs the Microsoft Deployment Toolkit for testing MDT functions
#>

# Check if the script is running in x64 environment
if ($Env:PROCESSOR_ARCHITECTURE -eq "AMD64") {

	# Download the MDT Workbench
	$OutFile = $([System.IO.Path]::Combine($env:RUNNER_TEMP, "MicrosoftDeploymentToolkit_x64.msi"))
	if (-not(Test-Path -Path $OutFile)) {
		Write-Host "Downloading and installing the Microsoft Deployment Toolkit"
		$Url = "https://download.microsoft.com/download/3/3/9/339BE62D-B4B8-4956-B58D-73C4685FC492/MicrosoftDeploymentToolkit_x64.msi"
		$ProgressPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
		$params = @{
			Uri             = $Url
			OutFile         = $OutFile
			UseBasicParsing = $true
		}
		Invoke-WebRequest @params
	}

	# Install the Microsoft Deployment Toolkit
	$MdtModule = "$Env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
	if (-not(Test-Path -Path $MdtModule)) {
		$params = @{
			FilePath     = "$env:SystemRoot\System32\msiexec.exe"
			ArgumentList = "/package $OutFile /quiet"
			NoNewWindow  = $true
			Wait         = $true
			PassThru     = $false
		}
		Start-Process @params
	}

	# Create a deployment share for testing
	$Path = "$Env:RUNNER_TEMP\Deployment"
	if (-not(Test-Path -Path "$Path\Control\CustomSettings.ini")) {
		Import-Module -Name "$Env:ProgramFiles\Microsoft Deployment Toolkit\Bin\MicrosoftDeploymentToolkit.psd1"
		New-Item -Path $Path -ItemType "Directory" -ErrorAction "SilentlyContinue" | Out-Null
		$params = @{
			Name        = "DS020"
			PSProvider  = "MDTProvider"
			Root        = $Path
			Description = "MDT Deployment Share"
		}
		New-PSDrive @params | Add-MDTPersistentDrive
	}
}
