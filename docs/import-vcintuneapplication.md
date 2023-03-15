# Import Redistributables into Microsoft Intune

To install the Visual C++ Redistributables with Microsoft Endpoint Manager / Intune, `Import-VcIntuneApplication` will package each of the Visual C++ Redistributables and import them as a separate application into a target tenant.

Visual C++ Redistributables can be filtered for release and processor architecture by `Get-VcList` and `Save-VcRedist` before passing to `Import-VcIntuneApplication`. The output from `Save-VcRedist` is required, because it includes the `Path` property that is populated with the path to each installer.

An application package will be created for each Visual C++ Redistributable with properties including Name, Description, Publisher, App Version, Information URL, Privacy URL, Notes, Logo, Install command, Uninstall command, Install behavior, Operating system architecture, Minimum operating system, and Detection rules.

This function requires the [IntuneWin32App](https://github.com/MSEndpointMgr/IntuneWin32App) PowerShell module and supported Windows PowerShell only. Before using this function to import the Redistributables into an Intune tenant, authenticate first with Connect-MSIntuneGraph.

## Initial Setup

To import the Visual C++ Redistributables into Microsoft Intune, some initial setup is required - first, install the required modules from the PowerShell Gallery:

```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name VcRedist, IntuneWin32App
```

## Parameters

### Required parameters

* `VcList` - An array containing details of the Visual C++ Redistributables from `Save-VcRedist`

## Examples

Authenticate to a target tenant, retrieve the list of Visual C++ Redistributables for the 2022 version, download the installers to `C:\Temp\VcRedist` and imports each Redistributable into the target Intune tenant as separate application.

```powershell
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
$Vc = Get-VcList -Release "2022"
$VcList = Save-VcRedist -VcList $Vc -Path C:\Temp\VcRedist
Import-VcIntuneApplication -VcList $VcList
```

Authenticates to the specified tenant using an Azure AD app registration for non-interactive authentication, retrieves the supported list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the target Intune tenant as separate application.

```powershell
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
Get-VcList | Save-VcRedist | Import-VcIntuneApplication
```

![Microsoft Visual C++ Redistributables applications imported into Intune](assets/images/intuneapp.jpeg)

## Create application assignments

With the application packages imported, configure assignments with `Add-IntuneWin32AppAssignmentAllDevices`. `Import-VcIntuneApplication` will return details of the applications imported into Intune, including the `Id` property required for adding assignments.

In the example below, the Redistributables imported into Intune will be assigned to all devices.

```powershell
$Apps = Get-VcList | Save-VcRedist | Import-VcIntuneApplication
ForEach ($App in $Apps) {
    $params = @{
        Id                           = $App.Id
        Intent                       = "required"
        Notification                  = "hideAll"
        DeliveryOptimizationPriority = "foreground"
        Verbose                      = $true
    }
    Add-IntuneWin32AppAssignmentAllDevices @params
}
```
