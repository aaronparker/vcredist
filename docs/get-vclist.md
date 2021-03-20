---
title: "Get the VcRedist List"
keywords: vcredist
tags: [getting_started]
sidebar: home_sidebar
permalink: get-vclist.html
summary: 
---
`Get-VcList` returns the list of Visual C++ Redistributables. The VcRedist module includes the full list of available supported and unsupported  Redistributables and returns only the supported list by default. Unless you have a specific requirement, it is highly recommend that you install only [the supported Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads).

Running `Get-VcList` with no parameters will return an array of the supported Redistributables by reading the internal manifest. Output can then be manipulated to filter the results. Note, though, the default behaviour of `Get-VcList` is currently to return only the 2008, 2010, 2012, 2013 and 2019 Redistributables. This is because the 2015, 2017 and 2019 Redistributables are all the same major version and will be upgraded to the 2019 release and can't be installed side-by-side.

Here's a sample of what's returned:

```powershell
PS C:\> Get-VcList

Name         : Visual C++ 2008 Service Pack 1 Redistributable Package MFC Security Update
ProductCode  : {5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}
URL          : https://www.microsoft.com/en-us/download/details.aspx?id=26368
Download     : https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe
Release      : 2008
Architecture : x64
ShortName    : SP1MFC
Install      : /Q

Name          : Visual C++ 2013 Update 5 Redistributable Package
ProductCode   : {9dff3540-fc85-4ed5-ac84-9e3c7fd8bece}
Version       : 12.0.40664.0
URL           : https://support.microsoft.com/en-us/help/4032938/update-for-visual-c-2013-redistributable-package
Download      : https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe
Release       : 2013
Architecture  : x86
ShortName     : Update5
Install       : /install /passive /norestart
SilentInstall : /install /quiet /norestart

Name          : Visual C++ Redistributable for Visual Studio 2019
ProductCode   : {7b178cda-9740-4701-a92a-f168d213b343}
Version       : 14.20.27508.1
URL           : https://www.visualstudio.com/downloads/
Download      : https://aka.ms/vs/16/release/VC_redist.x64.exe
Release       : 2019
Architecture  : x64
ShortName     : RTM
Install       : /install /passive /norestart
SilentInstall : /install /quiet /norestart
```

Output from `Get-VcList` can be piped to `Save-VcRedist`, `Install-VcRedist`, `Import-VcMdtApplication`, `Update-VcMdtApplication`, `Import-VcConfigMgrApplication` and `Update-VcConfigMgrApplication`. Additionally, output from `Get-VcList` can be filtered using `Where-Object`. This approach is useful where you want to export the full list of Redistributables but filter for specific processor architectures.

## Parameters

### Optional parameters

* `Manifest` - The JSON file that contains the details about the Visual C++ Redistributables. This must be in the expected format
* `Export` - Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables. Defaults to exporting the Supported Redistributables.
* `Release` - Specifies the release (or version) of the redistributables to return (e.g. 2019, 2010, 2012, etc.)
* `Architecture` - Specifies the processor architecture to of the redistributables to return. Can be x86 or x64

## Filtering Output

The output from `Get-VcList` can be filtered before sending to other functions. `Get-VcList` has the `-Release` parameter for filtering on the 2005, 2008, 2010, 2012, 2013, 2015, 2017 and 2019 releases of the Redistributables. Additionally, the `-Architecture` parameter can filter on x86 and x64 processor architectures.

These parameters cannot be used with the `-Export` parameter. If you require filtering when exporting All, Supported or Unsuppported Redistributables, pipe the output to the `Where-Object` function.

## Examples

Return the current list of supported Redistributables:

```powershell
Get-VcList
```

To return the complete list of available supported and unsupported Redistributables:

```powershell
Get-VcList -Export All
```

You may want to export the complete list of available supported and unsupported Redistributables, but filter for 64-bit Redistributables only:

```powershell
Get-VcList -Export All | Where-Object { $_.Architecture -eq "x64" }
```

`Get-VcList` does not return the 2015 and 2017 releases by default. To return specific releases and processor architectures from the supported list of Redistributables, the following example can be used:

```powershell
Get-VcList -Release 2010, 2012, 2013, 2017 -Architecture x64
```

{% include links.html %}
