# Change log

## v1.3.6.56

* Add `Get-InstalledVcRedist`, using private function `Get-InstalledSoftware`. Closing issue \#18 with feature request for this function. `Get-InstallSoftware` function by [Adam Bertram](https://4sysops.com/archives/find-the-product-guid-of-installed-software-with-powershell/)
* Update manifests with correct ProductCodes
* Update documentation

## v1.3.5.48

* Update manifests with `2017`, version `14.14`
* Update manifests with `<Version></Version>` to enable better install logic e.g. skipping installing 2015 over 2017 \(same 14.x version\)

## v1.3.4.45

* Fix import of Redistributables with correct x86, x64 platform selection in MDT application in `Import-VcMdtApp`
* Fix import of Redistributables into a folder specified by -AppFolder where the folder already exists in `Import-VcMdtApp`

## v1.3.3.39

* Update manifests with 2017 \(14.13.26020\) release
* Update module `ReleaseNotes` property with a link to changelog [https://docs.stealthpuppy.com/vcredist/change-log](https://docs.stealthpuppy.com/vcredist/change-log)
* Update functions with explicit `Write-Output`

## v1.3.2.35

* Code formatting updates
* Use `Join-Path` to build folder/file paths to better work on PSCore
* Pester tests updates
* Version update to better align with feature changes

## v1.3.1.4

* Fixes to ConfigMgr application import

## v1.3.1.2

* Add `-Bundle` to `Import-VcMdtApp` to create an Application Bundle with the Redistributables as dependencies. Redistributables will be hidden so that only the Bundle is selectable in the deployment wizard
* Updating simple Pester tests and getting Appveyor integration working
* Cleanup inline help
* Generated external help with platyPS

## v1.3.1.0

* Added function `Import-VcCmApp` for importing Visual C++ Redistributables into ConfigMgr.

## v1.3.0.0

* Refactored into a PowerShell module to simplify coding and publishing to the PowerShell Gallery.

