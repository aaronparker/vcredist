# Get the VcRedist list

`Get-VcList` returns the list of Visual C++ Redistributables. The VcRedist module includes the full list of available supported and unsupported  Redistributables and returns only the supported list by default. Unless you have a specific requirement, it is highly recommend that you install only [the supported Redistributables](https://support.microsoft.com/en-au/help/2977003/the-latest-supported-visual-c-downloads).

Running `Get-VcList` with no parameters will return an array of the supported Redistributables by reading the internal manifest. Output can then be manipulated to filter the results. Note though, the default behaviour of `Get-VcList` is to return only the `2012`, `2013` and `2022` Redistributables. This is because the `2015`, `2017`, `2019` and `2022` Redistributables are all the same major version and will be upgraded to the `2022` release and can't be installed side-by-side.

Here's a sample of what's returned:

```powershell
PS C:\> Get-VcList

Name            : Visual C++ Redistributable for Visual Studio 2012 Update 4
ProductCode     : {ca67548a-5ebe-413a-b50c-4b9ceb6d66c6}
Version         : 11.0.61030.0
URL             : https://www.microsoft.com/en-us/download/details.aspx?id=30679
Download        : https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x64.exe
Release         : 2012
Architecture    : x64
Install         : /install /passive /norestart
SilentInstall   : /quiet /norestart
SilentUninstall : "%ProgramData%\Package Cache\{ca67548a-5ebe-413a-b50c-4b9ceb6d66c6}\vcredist_x64.exe" /uninstall /quiet /noreboot
UninstallKey    : 32

Name            : Visual C++ Redistributable for Visual Studio 2012 Update 4
ProductCode     : {33d1fd90-4274-48a1-9bc1-97e33d9c2d6f}
Version         : 11.0.61030.0
URL             : https://www.microsoft.com/en-us/download/details.aspx?id=30679
Download        : https://download.microsoft.com/download/1/6/B/16B06F60-3B20-4FF2-B699-5E9B7962F9AE/VSU_4/vcredist_x86.exe
Release         : 2012
Architecture    : x86
Install         : /install /passive /norestart
SilentInstall   : /install /quiet /norestart
SilentUninstall : "%ProgramData%\Package Cache\{33d1fd90-4274-48a1-9bc1-97e33d9c2d6f}\vcredist_x86.exe" /uninstall /quiet /noreboot
UninstallKey    : 32

Name            : Visual C++ 2013 Update 5 Redistributable Package
ProductCode     : {042d26ef-3dbe-4c25-95d3-4c1b11b235a7}
Version         : 12.0.40664.0
URL             : https://support.microsoft.com/en-us/help/4032938/update-for-visual-c-2013-redistributable-package
Download        : https://download.visualstudio.microsoft.com/download/pr/10912041/cee5d6bca2ddbcd039da727bf4acb48a/vcredist_x64.exe
Release         : 2013
Architecture    : x64
Install         : /install /passive /norestart
SilentInstall   : /install /quiet /norestart
SilentUninstall : "%ProgramData%\Package Cache\{042d26ef-3dbe-4c25-95d3-4c1b11b235a7}\vcredist_x64.exe" /uninstall /quiet /noreboot
UninstallKey    : 32

Name            : Visual C++ 2013 Update 5 Redistributable Package
ProductCode     : {9dff3540-fc85-4ed5-ac84-9e3c7fd8bece}
Version         : 12.0.40664.0
URL             : https://support.microsoft.com/en-us/help/4032938/update-for-visual-c-2013-redistributable-package
Download        : https://download.visualstudio.microsoft.com/download/pr/10912113/5da66ddebb0ad32ebd4b922fd82e8e25/vcredist_x86.exe
Release         : 2013
Architecture    : x86
Install         : /install /passive /norestart
SilentInstall   : /install /quiet /norestart
SilentUninstall : "%ProgramData%\Package Cache\{9dff3540-fc85-4ed5-ac84-9e3c7fd8bece}\vcredist_x86.exe" /uninstall /quiet /noreboot
UninstallKey    : 32

Name            : Visual C++ Redistributable for Visual Studio 2022
ProductCode     : {fa7f6d52-f85e-48ef-8f56-a37268aa5773}
Version         : 14.30.30000.0
URL             : https://www.visualstudio.com/downloads/
Download        : https://aka.ms/vs/17/release/VC_redist.x64.exe
Release         : 2022
Architecture    : x64
Install         : /install /passive /norestart
SilentInstall   : /install /quiet /norestart
SilentUninstall : "%ProgramData%\Package Cache\{fa7f6d52-f85e-48ef-8f56-a37268aa5773}\VC_redist.x64.exe" /uninstall /quiet /noreboot
UninstallKey    : 32

Name            : Visual C++ Redistributable for Visual Studio 2019
ProductCode     : {b7a2b241-3f54-4d7d-94d1-8ce0146e03c8}
Version         : 14.30.30000.0
URL             : https://www.visualstudio.com/downloads/
Download        : https://aka.ms/vs/17/release/VC_redist.x86.exe
Release         : 2022
Architecture    : x86
Install         : /install /passive /norestart
SilentInstall   : /install /quiet /norestart
SilentUninstall : "%ProgramData%\Package Cache\{b7a2b241-3f54-4d7d-94d1-8ce0146e03c8}\VC_redist.x86.exe" /uninstall /quiet /noreboot
UninstallKey    : 32
```

Output from `Get-VcList` can be piped to `Save-VcRedist`, `Install-VcRedist`, `Import-VcMdtApplication`, `Update-VcMdtApplication`, `Import-VcConfigMgrApplication` and `Update-VcConfigMgrApplication`. Additionally, output from `Get-VcList` can be filtered using `Where-Object`. This approach is useful where you want to export the full list of Redistributables but filter for specific processor architectures.

## Parameters

### Optional parameters

* `Release` - Specifies the release (or version) of the redistributables to return (e.g. `2022`, `2019`, `2010`, `2012`, etc.)
* `Architecture` - Specifies the processor architecture to of the redistributables to return. Can be `x86` or `x64`
* `Export` - Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables. Defaults to exporting the Supported Redistributables.
* `Manifest` - An external JSON file that contains the details about the Visual C++ Redistributables. This must be in the expected format

### Returning Supported Redistributables

`Get-VcList` without additional parameters will return all of the supported Redistributables. Using the `-Release` and `-Architecture` parameters will return the specified release and architecture from the supported Redistributables only.

### Returning Unsupported Redistributables

To return Redistributables from the list of unsupported Redistributables or the entire list, the `-Export` parameter is required. The `-Export` parameter cannot be used with the `-Release` and `-Architecture` parameters; therefore to filter in the full list or the unsupported list of Redistributables, the output from `Get-VcList` must be filtered with `Where-Object`.

## Filtering Output

The output from `Get-VcList` can be filtered before sending to other functions. `Get-VcList` has the `-Release` parameter for filtering on the `2005`, `2008`, `2010`, `2012`, `2013`, `2015`, `2017`, `2019` and `2022` releases of the Redistributables. Additionally, the `-Architecture` parameter can filter on `x86` and `x64` processor architectures.

These parameters cannot be used with the `-Export` parameter. If you require filtering when exporting All, Supported or Unsupported Redistributables, pipe the output to the `Where-Object` function.

## Examples

Return the current list of supported Redistributables:

```powershell
Get-VcList
```

`Get-VcList` does not return the `2015`, `2017` or `2019` releases by default. To return specific releases and processor architectures from the supported list of Redistributables, the following example can be used:

```powershell
Get-VcList -Release 2012, 2013, 2017 -Architecture x64
```

To return the complete list of available supported and unsupported Redistributables:

```powershell
Get-VcList -Export All
```

You may want to export the complete list of available supported and unsupported Redistributables, but filter for 64-bit Redistributables only:

```powershell
Get-VcList -Export All | Where-Object { $_.Architecture -eq "x64" }
```

To return a specific release and architecture from the list of unsupported Visual C++ Redistributables from the embedded manifest, the following can be used to filter for the `2008`, 64-bit versions of the Redistributables.

```powershell
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" -and $_.Architecture -eq "x64" }
```
