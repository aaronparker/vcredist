# Supported Platforms

## Windows Verisons

VcRedist supports installing the Visual C++ Redistributables on Windows 10 / Windows Server 2016+. Basic testing has been done on earlier versions of Windows; however, only best effort support is provided for downlevel operating systems.

## PowerShell Editions

VcRedist supports PowerShell 5.0 and above with testing completed on Windows 10, Windows Server 2016 and even macOS. Given that the Visual C++ Redistributables are only installable on Windows, full support is only offered for Windows.

Some testing has been performed on Windows 7 with WMF 5.1. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/powershell/wmf/readme).

### PowerShell Core

`Get-VcList`, `Get-VcRedist`, `Export-VcXml` and `Install-VcRedist` support PowerShell Core; however, because `Import-VcMdtApp` and `Import-CmApp` require the MDT Workbench or ConfigMgr console, full support for PowerShell Core will depend on Microsoft updating the MDT and ConfigMgr PowerShell modules to support it.