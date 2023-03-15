# Update Redistributables in MDT

Use `Update-VcMdtApplication` to update the Visual C++ Redistributables that have previously been imported into the Microsoft Deployment Toolkit by `Import-VcMdtApplication`. As updates Visual C++ Redistributables are released (typically updates to existing versions), the existing applications may require updating. While `Import-VcMdtApplication` supports the `-Force` parameter, it will first delete the existing application and re-import it. `Update-VcMdtApplication` will update the properties of the existing application, keeping the application GUID intact.

Visual C++ Redistributables can be filtered for release and processor architecture by `Get-VcList` before passing to `Save-VcRedist` and `Import-VcMdtApplication`. The output from `Save-VcRedist` is required, because it includes the `Path` property that is populated with the path to each installer.

## Parameters

### Required parameters

* `VcList` - An array containing details of the Visual C++ Redistributables from `Save-VcRedist`
* `MdtPath` - the local or network path to the MDT deployment share

### Optional parameters

* `Silent` - Configures the MDT application quiet install command to be completely silent instead of using the default passive install command line
* `Force` - Forces overwrite of an existing Visual C++ Redistributable application
* `AppFolder` - Imports the Visual C++ Redistributables into a sub-folder. Defaults to `VcRedists`
* `MdtDrive` - The drive letter that will be mapped to the MDT deployment share. Not required and defaults to `DS001`
* `Publisher` - The publisher that will be assigned to the Visual C++ Redistributables bundle. Not required and defaults to "Microsoft"
* `Language` - The language assigned to the Visual C++ Redistributables bundle. Defaults to `en-US`

## Examples

Update the `2012`, `2013` and `2022` supported Redistributables in an MDT deployment share with the fully silent install command line:

```powershell
$VcList = Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
Update-VcMdtApplication -VcList $VcList -MdtPath \\server\deployment -Silent
```
