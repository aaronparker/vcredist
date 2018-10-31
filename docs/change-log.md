# Change log

## v1.4.0.69

* Update manifests for latest `2017` release, version `14.15.26706.0`
* Update manifests with silent install command line arguments
* Added `-Silent` switch to `Install-VcRedist`, `Import-VcMdtApp` & `Import-VcCmApp` to support optional silent install command line arguments
* Added private function `Get-Bitness` to support determining processor architecture of current OS
* Update `Install-VcRedist` to avoid installing 64-bit Redistributables on 32-bit Windows
* Removed pipeline support for `-VcRedist` parameter in `Install-VcRedist`, `Import-VcMdtApp` & `Import-VcCmApp`. Passing output from `Get-VcList` to these commands is not working correctly. Pipeline support may be added back in a future release
* Removed `2015` Redistributables from default value for `-Release` parameter for `Install-VcRedist`, `Import-VcMdtApp` & `Import-VcCmApp` functions to avoid installing `2015` then `2017` Redistributables that are the same major release version

## v1.3.7.60

* Update manifests with `2013`, version `12.0.40664`
* Added `UninstallString` to function `Get-InstalledVcRedist` output
* `Get-VcList` will attempt to match the VcRedist version in the manifest to the `Product Version` property on an existing downloaded file. If the manifest has a higher version, the file will be re-downloaded
* Added private function `Get-FileMetadata` to support retrieving `Product Version` from downloaded file
* Update logic in `Install-VcRedist` when querying for installed VcRedists

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
