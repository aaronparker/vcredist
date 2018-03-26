# Installing the Visual C++ Redistributables

To install the Visual C++ Redistributables on the local machine, use `Install-VcRedist`. This function accepts the array of Visual C++ Redistributables passed from `Get-VcList` and installs the Visual C++ Redistributables downloaded to a local path with `Get-VcRedist`.

The following command will install the Visual C++ Redistributables already downloaded locally with `Get-VcRedist` to C:\Temp\VcRedist.

```powershell
Get-VcList | Install-VcRedist -Path C:\Temp\VcRedists
```

Visual C++ Redistributables can be filtered for release and processor architecture.

![Microsoft Visual C++ Redistributables installed on the local PC](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/VisualCPrograms.PNG)