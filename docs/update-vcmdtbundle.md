---
title: "Update the Redistributables bundle in MDT"
keywords: vcredist
tags: [mdt]
sidebar: home_sidebar
permalink: update-vcmdtbundle.html
summary: 
---
Where the Visual C++ Redistributables bundle in an MDT deployment requires updating for the Visual C++ Redistributable applications that are currently in the share, `Update-VcMdtBundle` will scan the deployment share and replace any dependencies on the existing bundle with the current Visual C++ Redistributable applications.

The Version property of the bundle is updated with the current date making it easy to see when the bundle was last updated.

## Parameters

### Required parameters

* `MdtPath` - the local or network path to the MDT deployment share

### Optional parameters

* `AppFolder` - updates the Visual C++ Redistributables bundle in a sub-folder. Defaults to "VcRedists"
* `MdtDrive` - the drive letter that will be mapped to the MDT deployment share. Not required and defaults to "DS001"
* `Publisher` - the publisher that will be assigned to the Visual C++ Redistributables bundle. Not required and defaults to "Microsoft"
* `BundleName` - the bundle short name assigned to the Visual C++ Redistributables bundle. Not required and defaults to "Visual C++ Redistributables"
* `Language` - defaults to "en-US"

## Examples

To create the bundle in the target deployment share, run `Update-VcMdtBundle`. This function will scan for the Visual C++ Redistributables in the default application folder (VcRedists) and update the existing bundle with each Redistributable application as a dependency in order from oldest to newest Redistributable.

```powershell
Update-VcMdtBundle -MdtPath \\server\deployment
```
