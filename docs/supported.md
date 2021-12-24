# Supported platforms

## Windows Versions

VcRedist supports installing the Visual C++ Redistributables on Windows 10/11 (64-bit) and Windows Server 2016+ (GUI and Server Core). Basic testing has been done on earlier versions of Windows; however, only best effort support is provided for 32-bit and / or downlevel operating systems.

## PowerShell Editions

VcRedist supports PowerShell 5.0 and above with testing completed on Windows 10/11 and Windows Server 2016+ and even macOS. Given that the Visual C++ Redistributables are only installable on Windows, full support is only offered for Windows.

Some testing has been performed on Windows 7 with WMF 5.1. If you are running an earlier version of PowerShell, update to the latest release of the [Windows Management Framework](https://docs.microsoft.com/en-us/powershell/wmf/readme).

### PowerShell Core

Most functions support PowerShell Core, thus `Get-VcList`, `Save-VcRedist`, `Export-VcManifest` will work on macOS and Linux; however, because the remaining functions (`Get-InstalledVcRedist`, `Import-VcConfigMgrApplication`, `Import-VcMdtApplication`, `Install-VcRedist`, `New-VcMdtBundle`, `Update-VcMdtApplication`, `Update-VcMdtBundle`) either require Windows, the MDT Workbench or the ConfigMgr console, they will work best under Windows PowerShell.

Full support for PowerShell Core on Windows will depend on Microsoft updating the MDT and ConfigMgr PowerShell modules to support it. Testing with the `WindowsCompatibility` module has not yet been completed.
