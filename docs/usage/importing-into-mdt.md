# Importing into MDT

To install the Visual C++ Redistributables as a part of a reference image or for use with a deployment solution based on the Microsoft Deployment Toolkit, `Import-VcMdtApp` will import each of the Visual C++ Redistributables as a separate application that includes silent command lines, platform support and the UninstallKey for detecting whether the Visual C++ Redistributable is already installed. Visual C++ Redistributables can be filtered for release and processor architecture.

```powershell
$VcList = Get-VcList
Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment
```

Each Redistributables will be imported into the deployment share with application properties for a successful deployment.

![Microsoft Visual C++ Redistributables applications imported into an MDT share](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/MdtVisualCApplications.png)

The folder structure in the deployment share, will look thus:

![Visual C++ Redistributables in the deployment share Application folder](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/MdtVisualCApplicationsFolder.PNG)

An option is provided to an Application Bundle with the `-Bundle` switch. This will import all of the Redistributables and create a single Application Bundle with the Redistributables as dependencies. If specified, the `-Bundle` switch will hide the Redistributables, leaving on the bundle visible in the Deployment Wizard.

```powershell
$VcList = Get-VcList
Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle
```

The install command line arguments used by default are passive. Fully silent install command line arguments can be specified with the `-Silent` parameter when importing the applications into an MDT deployment share.

```powershell
$VcList = Get-VcList
Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle -Silent
```
