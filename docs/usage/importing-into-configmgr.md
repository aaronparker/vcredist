# Importing into ConfigMgr

To install the Visual C++ Redistributables with System Center Configuration Manager, `Import-VcCmApp` will import each of the Visual C++ Redistributables as a separate application that includes the application and a single deployment type. Visual C++ Redistributables can be filtered for release and processor architecture.

To import the Visual C++ Redistributables as applications with a single deployment type into ConfigMgr. This includes copying the downloaded installers to a network path.

```powershell
$VcList = Get-VcList
Get-VcRedist -VcList $VcList -Path "C:\Temp\VcRedist"
Import-VcCmApp -VcList $VcList -Path "C:\Temp\VcRedist" -CMPath "\\server\share\VcRedist" -SMSSiteCode LAB
```

The install command line arguments used by default are passive. Fully silent install command line arguments can be specified with the `-Silent` parameter when importing the applications into Configuration Manager.

```powershell
$VcList = Get-VcList
Get-VcRedist -VcList $VcList -Path "C:\Temp\VcRedist"
Import-VcCmApp -VcList $VcList -Path "C:\Temp\VcRedist" -CMPath "\\server\share\VcRedist" -SMSSiteCode LAB -Silent
```

![Microsoft Visual C++ Redistributables applications imported into ConfigMgr](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/VcRedistConfigMgr.PNG)
