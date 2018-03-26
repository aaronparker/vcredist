# Downloading the Redistributables

To download the Visual C++ Redistributables to a local folder, use `Get-VcRedist`. This will read the array of Visual C++ Redistributables returned from `Get-VcList` and download each one to a local folder specified in `-Path`. Visual C++ Redistributables can be filtered for release and processor architecture.

```powershell
New-Item C:\Temp\VcRedist -ItemType Directory
Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist
```

Get-VcRedist downloads the Redistribuables and returns the array passed from Get-VcList to the pipeline so that it can be passed to other functions (such as [Install-VcRedist](install-windows.MD))

Redistribuables are downloaded into the target folder:

![Microsoft Visual C++ Redistributables installed on the local PC](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/VcRedist-Folder.PNG)