# Import Redistributables into MDT

To install the Visual C++ Redistributables as a part of a reference image or for use with a deployment solution based on the Microsoft Deployment Toolkit (MDT), `Import-VcMdtApplication` will import each of the Visual C++ Redistributables as separate applications that includes the passive or silent command lines, platform support and the UninstallKey for detecting whether the Visual C++ Redistributable is already installed.

Visual C++ Redistributables can be filtered for release and processor architecture by `Get-VcList` before passing to `Save-VcRedist` and `Import-VcMdtApplication`. The output from `Save-VcRedist` is required, because it includes the `Path` property that is populated with the path to each installer.

## Parameters

### Required parameters

* `VcList` - An array containing details of the Visual C++ Redistributables from `Save-VcList`
* `MdtPath` - the local or network path to the MDT deployment share

### Optional parameters

* `Silent` - Configures the MDT application quiet install command to be completely silent instead of using the default passive install command line
* `Force` - Forces overwrite of an existing Visual C++ Redistributable application
* `AppFolder` - Imports the Visual C++ Redistributables into a sub-folder. Defaults to `VcRedists`
* `MdtDrive` - The drive letter that will be mapped to the MDT deployment share. Not required and defaults to `DS001`
* `Publisher` - The publisher that will be assigned to the Visual C++ Redistributables bundle. Not required and defaults to "Microsoft"
* `Language` - The language assigned to the Visual C++ Redistributables bundle. Defaults to `en-US`

## Examples

Import the `2012`, `2013` and `2022` supported Redistributables into an MDT deployment share:

```powershell
$VcList = Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
Import-VcMdtApplication -VcList $VcList -MdtPath \\server\deployment
```

Each Redistributable will be imported into the deployment share with application properties required for a successful deployment.

![Microsoft Visual C++ Redistributables applications imported into an MDT share](assets/images/mdtvisualcapplications.png)

The folder structure in the deployment share, will look thus:

![Visual C++ Redistributables in the deployment share Application folder](assets/images/mdtvisualcapplicationsfolder.png)

The install command line arguments used by default are passive. Fully silent install command line arguments can be specified with the `-Silent` parameter when importing the applications into an MDT deployment share.

```powershell
$VcList = Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
Import-VcMdtApp -VcList $VcList -MdtPath \\server\deployment -Silent
```
