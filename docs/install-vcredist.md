---
title: "Install the Redistributables"
keywords: vcredist
tags: [install]
sidebar: home_sidebar
permalink: install-vcredist.html
summary: 
---
To install the Visual C++ Redistributables on the local machine, use `Install-VcRedist`. This function accepts the array of Visual C++ Redistributables passed from `Get-VcList` and installs the Visual C++ Redistributables downloaded to a local path with `Save-VcRedist`.

`Install-VcRedist` supports both passive installs (default) or silent installs with the `-Silent` parameter.

## Parameters

### Required parameters

* `VcList` - An array containing details of the Visual C++ Redistributables from `Get-VcList`
* `Path` - A folder containing the downloaded Visual C++ Redistributables downloaded with `Save-VcList`

### Optional parameters

* `Silent` - Configures the MDT application quiet install command to be completely silent instead of using the default passive install command line

## Examples

The following command will install the Visual C++ Redistributables already downloaded locally with `Save-VcRedist` to C:\Temp\VcRedist.

```powershell
$VcList = Get-VcList
Install-VcRedist -Path C:\Temp\VcRedist -VcList $VcList
```

Fully silent install command line arguments can be specified with the `-Silent` parameter when installing the Redistributables.

```powershell
Install-VcRedist -Path C:\Temp\VcRedist -VcList (Get-VcList) -Silent
```

![Microsoft Visual C++ Redistributables installed on the local PC](/images/visualcprograms.png)

{% include links.html %}
