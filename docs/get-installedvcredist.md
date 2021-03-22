---
title: "Get the locally installed Redistributables"
keywords: vcredist
tags: [install]
sidebar: home_sidebar
permalink: get-installedvcredist.html
summary: 
---
`Get-InstalledVcRedist` is used to return the list of Visual C++ Redistributables installed on the current system. This function can assist in performing various functions including, comparing the installed list of Redistributables against that listed in the manifests included in the module, or uninstalling the installed Redistributables.

Running the `Get-InstalledVcRedist` command returns the list of installed Redistributables with various properties, including the display name, product code, version and uninstall strings.

```text
Publisher            : Microsoft Corporation
Name                 : Microsoft Visual C++ 2015-2019 Redistributable (x64) - 14.20.27508
Version              : 14.20.27508.1
ProductCode          : {7b178cda-9740-4701-a92a-f168d213b343}
UninstallString      : "C:\ProgramData\Package Cache\{7b178cda-9740-4701-a92a-f168d213b343}\VC_redist.x64.exe"  /uninstall
QuietUninstallString : "C:\ProgramData\Package Cache\{7b178cda-9740-4701-a92a-f168d213b343}\VC_redist.x64.exe" /uninstall /quiet
BundleCachePath      : C:\ProgramData\Package Cache\{7b178cda-9740-4701-a92a-f168d213b343}\VC_redist.x64.exe
Architecture         : x64
Release              : 2019
```

## Parameters

### Optional parameters

* `ExportAll` - Export all installed Redistributables including the Additional and Minimum Runtimes typically hidden from Programs and Features

## Examples

The following command will return the list of installed Redistributables:

```powershell
Get-InstalledVcRedist
```

Output can be filtered for specific properties:

```powershell
Get-InstalledVcRedist | Select Name, Version, ProductCode
```

![Microsoft Visual C++ Redistributables installed on the local PC](/images/installed-vcredist.png)

This list won't include the Additional and Minimum Runtimes by default. These can be returned with the `-ExportAll` switch:

```powershell
Get-InstalledVcRedist -ExportAll
```

{% include links.html %}
