# Known issues

* 'English - United States' is the only supported language. The module will only download the en-US versions of the Redistributables
* `Get-VcList` will attempt to match the VcRedist version in the manifest to the `Product Version` property on the downloaded file. Because Product Version on the 2005 and 2008 VcRedist installers doesn't match the file will be re-downloaded even though the installer is the correct version
* `Import-VcMdtApp` and `Import-VcCmApp` will fail to import application if they already exist. No detection or error checking is completed on import as yet.
