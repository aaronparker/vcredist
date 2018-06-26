# Importing into ConfigMgr

To install the Visual C++ Redistributables with System Center Configuration Manager, `Import-VcCmApp` will import each of the Visual C++ Redistributables as a seperate application that includes the application and a single deployment type. Visual C++ Redistributables can be filtered for release and processor architecture.

To import the Visual C++ Redistributables as applications with a single deployment type into ConfigMgr. This includes copying the downloaded installers to a network path.

```text
$VcList = Get-VcList | Get-VcRedist -Path "C:\Temp\VcRedist"
Import-VcCmApp -VcList $VcList -Path "C:\Temp\VcRedist" -CMPath "\\server\share\VcRedist" -SMSSiteCode LAB
```

![Microsoft Visual C++ Redistributables applications imported into ConfigMgr](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/VcRedistConfigMgr.PNG)

