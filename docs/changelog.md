# Changelog

## 3.0.315

* Update for VcRedist 2022 version `14.30.30708.0`
* Update for VcRedist 2019 version `14.29.30139.0`

## 3.0.307

* Updated online help pages to [https://vcredist.com/](https://vcredist.com/)

## 3.0.302

* Maintenance release - addresses issues identified by PSScriptAnalyzer and code style improvements

## 3.0.292

* Adds support for Visual C++ Redistributable for Visual Studio 2022, version `14.30.30704.0`
* Moves the `Visual C++ 2010 Service Pack 1 Redistributable Package MFC Security Update` to the unsupported list of Redistributables

## 3.0.281

* Update for VcRedist 2019 version `14.29.30135.0`

## 3.0.273

* Update for VcRedist 2019 version `14.29.30133.0`
* Fixes an issue with `Import-VcConfigMgrApplication` that produces an error `String was not recognized as a valid DateTime`. Function now uses the short date/time format of the current session when importing the application
* Updated `New-VcMdtBundle` and `Update-VcMdtBundle` to use the short date/time format of the current session when creating or updating the bundle

## 3.0.271

* Update for VcRedist 2019 version `14.29.30040.0`

## 3.0.263

* Update for VcRedist 2019 version `14.29.30037.0`
* Updates module to use external help MAML-based help with platyPS to make updating help content easier
* General code improvements across various functions
* Update module for documentation site updates

## 3.0.255

* Updates the VcRedist manifest for VcRedist 2019 `14.28.29914.0`
* Adds `Path` property to output from `Save-VcRedist` that includes the path to the downloaded VcRedist

## 3.0.251

* IMPORTANT: This release moves the Visual C++ Redistributable 2008 to the list of unsupported Redistributables and therefore will not be returned by default by `Get-VcList`. See the documentation on [how to retrieve the supported and unsupported list of Redistributables](https://vcredist.com/get-vclist.html)
* Fixes an issue when passing the list of Redistributables to `Install-VcRedist` via the pipeline [#77](https://github.com/aaronparker/VcRedist/issues/77)
* Fixes an issue with the output from `Save-VcRedist` where it would fail to return the list of Redistributables to the pipeline when run a second time

## 3.0.243

* Fix an issue in `Get-VcList` where it fails when exporting an unsupported Visual C++ Redistributable
* Sort the list of Visual C++ Redistributables passed to `Install-VcRedist` by version number so that Redistributables are installed in order from oldest to newest
* Update `Save-VcRedist` to not throw when attempting to download a Visual C++ Redistributable URL that returns a 404, so that it will continue to download the remaining Redistributables. See the [known issues](https://vcredist.com/known-issues.html) for Redistributables that are no longer available for download
* Update `Install-VcRedist` to not throw when a Redistributable installer is unavailable in the target path and continue to install the remaining Redistributables. This allows this function to continue the install process when specific Redistributables are not downloaded by `Save-VcRedist`
* Update `Uninstall-VcRedist` for pipeline support correctly. This enables commands such as `Get-InstalledVcRedist | Uninstall-VcRedist`

## 3.0.238

* Updates the major version to 3 due to the introduction of a breaking change
* Changes the folder structure used when downloading VcRedists and importing into MDT or ConfigMgr. Structure is now: `Release\Version\Architecture`. For example: `2019\14.28.29913.0\x64`. This change has been introduced to allow importing VcRedist installers into ConfigMgr and Microsoft Intune as distinct application versions that can be used to supersede earlier versions and upgrade target PCs
* Updates `Import-VcMdtApplication` to import VcRedist applications with new folder structure and naming convention. Applications will be created in the following format: `Visual C++ Redistributable Release Architecture Version`, for example: `Visual C++ Redistributable 2019 x86 14.28.29913.0`
* Validates previous changes in `Import-VcConfigMgrApplication` that import VcRedist applications with new folder structure and naming convention. Applications will be created in the following format: `Visual C++ Redistributable Release Architecture Version`, for example: `Visual C++ Redistributable 2019 x86 14.28.29913.0`
* Fixes an issue in `Import-VcConfigMgrApplication` when copying the VcRedist setup executable into the ConfigMgr deployment share via robocopy that reported an error even where it had successfully copied the target executable. Addresses issue: [#63](https://github.com/aaronparker/VcRedist/issues/63)
* Updates `Import-VcConfigMgrApplication` to copy the VcRedist setup executables individually instead of copying the entire VcRedist download folder (saved with `Save-VcRedist`). This allows for individual installers to be imported with only the content required for each version
* Adds parameter `-NoProgress` to `Save-VcRedist` to allow for suppressing `Invoke-WebRequest` download progress while using the `-Verbose` parameter. Download speed if affected when `Invoke-WebRequest` displays the download progress
* Updates inline help across various functions
* Various clean-up of code for robustness, error checking and spelling

## 2.0.231

* Updates the VcRedist manifest for VcRedist 2019 `14.28.29913.0`
* Adds the `UninstallKey` property to the VcRedist manifest for use with adding detection methods for 32-bit or 64-bit Registry keys
* Adds the `UninstallKey` to `Get-InstalledVcRedist` to assist with determining application detection methods (e.g. with ConfigMgr, Intune etc.)
* Updates `Import-VcConfigMgrApplication` with:
  * Updates application name in the format: `Visual C++ Redistributable 2010 x64 10.0.40219.325`
  * Updates application detection method to detect target Registry key (in the correct 32-bit or 64-bit Registry). Addresses issue: [#58](https://github.com/aaronparker/VcRedist/issues/58)
  * Adds parameter `-NoCopy` to allow import of VcRedist applications into without needing to copy content to the ConfigMgr deployment share
* Various clean-up of code and spelling

## 2.0.218

* Update VcRedist `2019` to `14.28.29325.2`
* Fix an issue where `Save-VcRedist` was not returning downloaded VcRedists details to the pipeline
* Adds private function `Get-DigitalSignature` to return digital signature / certificate info from VcRedist installers via `Get-FileMetadata`

## 2.0.214

* Update VcRedist `2019` to `14.27.29112.0`
* Update VcRedist `2017` to `14.16.27033.0`
* Update `Import-VcConfigMgrApplication` to support spaces in paths with ROBOCOPY
* Rename `Master` branch to `Main`

## 2.0.209

* Update VcRedist `2019` to `14.27.29016.0`
* Update `Uninstall-VcRedist` to ensure a VcRedist uninstall does not trigger a reboot

## 2.0.203

* Update for VcRedist `2019` version `14.26.28720`
* Automate updating the `VcRedist` manifest for new `2019` releases
* Update functions with new evaluations from `PSScriptAnalyzer`

## 2.0.183

* Fixes an issue where `Get-InstalledVcRedist` was not returning installed VcRedists due to incorrect RegEx match. Improve code that filters output with the `ExportAll` parameter

## 2.0.181

* `Import-MdtModule` - simplify code and ensure exception is thrown when module cannot be loaded
* `Get-InstalledVcRedist` - update filtering for Redistributables and update code style
* `Save-VcRedist.ps1` - update inline help, remove use of `Start-BitsTransfer` (now only uses `Invoke-WebRequest`), force use of TLS 1.2, fix reference to `ProxyCredential` parameter, fix output of downloaded VcRedists to the pipeline
* `Update-VcMdtApplication.ps1` - ensure correct path in verbose output, fix issue with VcRedist executables not being copied to the MDT deployment share
* `Update-VcMdtBundle` - update inline help, update approach to finding the existing VcRedist bundle to fix an issue where the bundle isn't in the default location, update approach to updating bundle properties
* Update Pester tests for public functions

## 2.0.174

* Add `$ProgressPreference = "SilentlyContinue"` to `Save-VcRedist for faster downloads
* Update manifest to support VcRedist 2019 `14.25.28508.3`
* Update module description
* Export variable `VcManifest` for future use

## 2.0.168

* Updates the manifest for VcRedist 2019 `14.24.28127.4`
* Updates to `Import-VcConfigMgrApplication` for UNC path and ConfigMgr module validation
* Updates to `Export-VcManifest` to export entire manifest. Working toward automatic updates to the manifest with new VcRedist releases

## 2.0.163

* Update the manifest for VcRedist 2019 version `14.23.27820.0` for Visual Studio 2019 `16.3`

## 2.0.161

* VcRedists imported into the MDT deployment share don't have the `Hide this application in the Deployment Wizard` option enabled
* Added `-DontHide` parameter to `Import-VcMdtApplication` to not hide applications in the MDT Deployment Wizard

## 2.0.158

* Add default path for `-Path` parameter in `Save-VcRedist` and `Install-VcRedist` to address [#53](https://github.com/aaronparker/vcredist/issues/53) and ensure function works when parameter is not specified
* Add Begin,Process,End to fix pipeline support in `Save-VcRedist`, `Install-VcRedist`, `Import-VcConfigMgrApplication`, `Import-VcMdtApplication`, `Update-VcMdtApplication` and `Update-VcMdtBundle` and address [#53](https://github.com/aaronparker/vcredist/issues/53)
* Add function `Uninstall-VcRedist` to manage uninstalling VcRedists
* Update Pester tests for Public functions

## 2.0.147

* Add basic proxy support to `Save-VcRedist`
* Update output for `Import-VcMdtApplication`, `New-VcMdtBundle`, `Update-VcMdtApplication`, `Update-VcMdtBundle` to export all application properties
* General code formatting and quality updates - use of full type names and cmdlet/function parameters, parameter splatting
* Update verbose output messages
* Consistent parameter declaration on Public functions
* Additional Try/Catch statements for better handling of exceptions
* Remove Begin/Process/End statements from functions that don't need to support multiple objects on the pipeline
* Move module manifest location from `/Manifest` to top level module folder and update `Get-VcList` to reflect new location
* Update AppVeyor integration and scripts layout

## 2.0.140

* Update the manifest for VcRedist `2019` version `14.21.27702.2` for Visual Studio 2019 `16.1`

## 2.0.138

* Fixed issue [#45 Blank Dependency entry on Apps imported from Import-VcMdtApplication](https://github.com/aaronparker/VcRedist/issues/45)
* Fixing issue when importing VcRedists into ConfigMgr [#47](https://github.com/aaronparker/VcRedist/issues/47)

## 2.0.132

* Simplify version semantics to major.minor.build
* Add VcRedist `2019` to the manifest
* Convert the manifest to JSON for easier management and simpler code
* Update function `Get-VcList` to support JSON manifest format
* Combine VcRedists into a single manifest
* Rename `Get-VcRedist` to `Save-VcRedist`
* Rename `Import-VcCmApp` to `Import-VcConfigMgrApplication`
* Rename function `Export-VcXml` to `Export-VcManifest`
* Rename `Import-VcMdtApp` to `Import-VcMdtApplication`
* Split function `Import-VcMdtApplication` into `Import-VcMdtApplication`, `Update-VcMdtApplication`, `New-VcMdtBundle`, `Update-VcMdtBundle` to simplify code and provide more robust functions
* Update HelpUri property on each function
* Update `Get-InstalledVcRedist` to export additional properties including `Release` and `Architecture`
* Add private functions `New-MdtApplicationFolder`, `New-MdtDrive`
* Update function `Get-VcList` with `-Export` parameter for `All, Supported, Unsupported`
* Add ability to filter `Get-VcList` output with `-Release` and `-Architecture`
* Fix pipeline support for `Install-VcRedist`, `Import-VcMdtApplication` and `Import-VcConfigMgrApplication` to accept output from `Get-VcList` on the pipeline
* Remove `-Release` and `-Architecture` parameters from `Install-VcRedist`, `Import-VcMdtApplication` and `Import-VcConfigMgrApplication`. Use `Get-VcList` to filter for release and architecture instead
* Update Pester tests for public and private functions

## 1.5.2.98

* Update manifests with correct details for VcRedist 2017 `14.16.27027.1`. v1.5.1.95 included the incorrect manifest commit.

## 1.5.1.95

* Update manifests with VcRedist 2017 `14.16.27024.1`
* Update module to export alias `Save-VcRedist` for `Get-VcRedist`. Next major version will rename `Get-VcRedist` to `Save-VcRedist`
* Change `-VcList` to use `[PSCustomObject]` instead of `[array]` in `Import-VcCmApp` and `Import-VcMdtApp`
* Update module icon to use new Visual Studio 2019 icon

## 1.5.0.92

* Added private function `Import-MdtModule` to improve MDT module loading code
* Update `Import-VcMdtApp` for more robust error checking
* Update private function `Get-ValidPath` to avoid errors on invalid path
* Update manifest with VcRedist 2017 version `14.16.27024.1`

## 1.4.3.88

* Fix private function `Get-Bitness` to ensure only single output when using no parameters or with `-Architecture`

## 1.4.2.85

* Fixed incorrect working directory when importing VcRedists into MDT in `Import-VcMdtApp`

## 1.4.1.79

* Add private function `Invoke-Process` (by Adam Bertram)
* Update `Install-VcRedist` to use `Invoke-Process` for better `Start-Process` handling
* Fix Resolve-Path / TrimEnd in private function `Get-ValidPath`
* Fix relative path issue in `Import-VcCmApp` * closes issue [#24](https://github.com/aaronparker/vcredist/issues/24)
* Bundle added to MDT now adds Redistributables as dependencies in order from oldest to newest
* Splatting arguments in `Install-VcRedist`, `Import-VcMdtApp`, `Import-VcCmApp`
* Code formatting updates
* Documentation updates

## 1.4.0.69

* Update manifests for latest `2017` release, version `14.15.26706.0`
* Update manifests with silent install command line arguments
* Added `-Silent` switch to `Install-VcRedist`, `Import-VcMdtApp` & `Import-VcCmApp` to support optional silent install command line arguments
* Added private function `Get-Bitness` to support determining processor architecture of current OS
* Update `Install-VcRedist` to avoid installing 64-bit Redistributables on 32-bit Windows
* Removed pipeline support for `-VcRedist` parameter in `Install-VcRedist`, `Import-VcMdtApp` & `Import-VcCmApp`. Passing output from `Get-VcList` to these commands is not working correctly. Pipeline support may be added back in a future release
* Removed `2015` Redistributables from default value for `-Release` parameter for `Install-VcRedist`, `Import-VcMdtApp` & `Import-VcCmApp` functions to avoid installing `2015` then `2017` Redistributables that are the same major release version

## 1.3.7.60

* Update manifests with `2013`, version `12.0.40664`
* Added `UninstallString` to function `Get-InstalledVcRedist` output
* `Get-VcList` will attempt to match the VcRedist version in the manifest to the `Product Version` property on an existing downloaded file. If the manifest has a higher version, the file will be re-downloaded
* Added private function `Get-FileMetadata` to support retrieving `Product Version` from downloaded file
* Update logic in `Install-VcRedist` when querying for installed VcRedists

## 1.3.6.56

* Add `Get-InstalledVcRedist`, using private function `Get-InstalledSoftware`. Closing issue [#18](https://github.com/aaronparker/vcredist/issues/18) with feature request for this function. `Get-InstallSoftware` function by [Adam Bertram](https://4sysops.com/archives/find-the-product-guid-of-installed-software-with-powershell/)
* Update manifests with correct ProductCodes
* Update documentation

## 1.3.5.48

* Update manifests with `2017`, version `14.14`
* Update manifests with `<Version></Version>` to enable better install logic e.g. skipping installing `2015` over `2017`

## 1.3.4.45

* Fix import of Redistributables with correct `x86`, `x64` platform selection in MDT application in `Import-VcMdtApp`
* Fix import of Redistributables into a folder specified by -AppFolder where the folder already exists in `Import-VcMdtApp`

## 1.3.3.39

* Update manifests with `2017` `14.13.26020` release
* Update module `ReleaseNotes` property with a link to changelog [https://vcredist.com/change-log](https://vcredist.com/change-log)
* Update functions with explicit `Write-Output`

## 1.3.2.35

* Code formatting updates
* Use `Join-Path` to build folder/file paths to better work on PSCore
* Pester tests updates
* Version update to better align with feature changes

## 1.3.1.4

* Fixes to ConfigMgr application import

## 1.3.1.2

* Add `-Bundle` to `Import-VcMdtApp` to create an Application Bundle with the Redistributables as dependencies. Redistributables will be hidden so that only the Bundle is selectable in the deployment wizard
* Updating simple Pester tests and getting Appveyor integration working
* Cleanup inline help
* Generated external help with platyPS

## 1.3.1.0

* Added function `Import-VcCmApp` for importing Visual C++ Redistributables into ConfigMgr.

## 1.3.0.0

* Refactored into a PowerShell module to simplify coding and publishing to the PowerShell Gallery.
