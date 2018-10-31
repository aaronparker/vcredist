# Getting the VcRedist List

`Get-VcList` returns the list of Visual C++ Redistributables. The VcRedist module includes two manifests - the list of [supported Redistributables](../redistributables/supported-redistributables.md) and the complete list of [available Redistributables](../redistributables/all-redistributables.md).

Unless you have a specific requirement, it is highly recommend that you install only the supported Redistributables.

Running `Get-VcList` with no parameters will return an array of the supported Redistributables by reading the internal manifest. Output can then be manipulated to filter the results. Here's a sample of what's returned.

```text
PS C:\> Get-VcList


Name         : Visual C++ 2008 Service Pack 1 Redistributable Package MFC Security Update
ProductCode  : {5FCE6D76-F5DC-37AB-B2B8-22AB8CEDB1D4}
URL          : https://www.microsoft.com/en-us/download/details.aspx?id=26368
Download     : https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x64.exe
Release      : 2008
Architecture : x64
ShortName    : SP1MFC
Install      : /Q

Name         : Visual C++ 2008 Service Pack 1 Redistributable Package MFC Security Update
ProductCode  : {9BE518E6-ECC6-35A9-88E4-87755C07200F}
URL          : https://www.microsoft.com/en-us/download/details.aspx?id=26368
Download     : https://download.microsoft.com/download/5/D/8/5D8C65CB-C849-4025-8E95-C3966CAFD8AE/vcredist_x86.exe
Release      : 2008
Architecture : x86
ShortName    : SP1MFC
Install      : /Q
```

## Return all Redistributables

To return the complete list of available Redistributables, run `Get-VcList -Export All`.

The internal manifests can be exported to an XML file with [Export-VcXml](../function-syntax/export-vcxml.md)
