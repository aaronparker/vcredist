# Install the Redistributables

A [quick install option](https://vcredist.com/quick/) is provided; however for a custom install of the Visual C++ Redistributables on a local machine, use `Install-VcRedist`. This function accepts the array of Visual C++ Redistributables passed from `Get-VcList` and installs the Visual C++ Redistributables downloaded to a local path with `Save-VcRedist`. The output from `Save-VcRedist` is required, because it includes the `Path` property that is populated with the path to each installer.

`Install-VcRedist` supports both passive installs (default) or silent installs with the `-Silent` parameter.

After the Visual C++ Redistributables are installed, the list of installed Visual C++ Redistributables is returned to the pipeline from `Get-InstalledVcRedist`.

## Parameters

### Required parameters

* `VcList` - An array containing details of the Visual C++ Redistributables from `Save-VcList`

### Optional parameters

* `Silent` - Configures the MDT application quiet install command to be completely silent instead of using the default passive install command line

## Examples

The following commands will install the default supported Visual C++ Redistributables downloaded locally with `Save-VcRedist` to C:\Temp\VcRedist.

```powershell
$VcList = Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
Install-VcRedist -VcList $VcList
```

These commands can be simplified by passing output to the subsequent command via the pipeline:

```powershell
Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist | Install-VcRedist -VcList $VcList
```

Fully silent install command line arguments can be specified with the `-Silent` parameter when installing the Redistributables.

```powershell
Install-VcRedist -VcList (Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist) -Silent
```

![Microsoft Visual C++ Redistributables installed on the local PC](assets/images/visualcprograms.png)
