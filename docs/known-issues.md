# Known issues

* The bundle doesn't currently add the MDT redistributables in order from oldest to newest. Install order shouldn't matter however
* 'English - United States' is the only supported language. The module will only download the en-US versions of the Redistributables
* `Get-VcList` will attempt to match the VcRedist version in the manifest to the `Product Version` property on the downloaded file. Because Product Version on the 2005 and 2008 VcRedist installers doesn't match the file will be redownloaded even though the installer is the correct version
