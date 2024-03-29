<#
    Invokes Pester tests in an AppVeyor build
#>
try {
    Write-Host "Import VcRedist." -ForegroundColor "Cyan"
    Import-Module "$env:APPVEYOR_BUILD_FOLDER\VcRedist" -Force
}
catch {
    throw $_
}

try {
    Write-Host "Install Pester." -ForegroundColor "Cyan"
    Install-PackageProvider -Name "NuGet" -MinimumVersion "2.8.5.208"
    Set-PSRepository -Name "PSGallery" -InstallationPolicy "Trusted"
    Install-Module -Name "Pester" -SkipPublisherCheck -Force
    Import-Module -Name "Pester" -Force
}
catch {
    throw $_
}

# Run tests
$Config = [PesterConfiguration]::Default
$Config.Run.Path = "$env:APPVEYOR_BUILD_FOLDER\tests"
$Config.Run.PassThru = $true
$Config.TestResult.Enabled = $true
$Config.TestResult.OutputFormat = "NUnitXml"
$Config.TestResult.OutputPath = "$env:APPVEYOR_BUILD_FOLDER\tests\TestResults.xml"
$res = Invoke-Pester -Configuration $Config
if ($res.FailedCount -gt 0) { throw "$($res.FailedCount) tests failed." }

# Upload test results
$wc = New-Object -TypeName "System.Net.WebClient"
$wc.UploadFile("https://ci.appveyor.com/api/testresults/nunit/$($env:APPVEYOR_JOB_ID)", "$env:APPVEYOR_BUILD_FOLDER\tests\TestResults.xml")
