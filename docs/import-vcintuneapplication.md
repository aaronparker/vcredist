# Import Redistributables into Microsoft Intune

To install the Visual C++ Redistributables with Microsoft Intune, use `Import-VcIntuneApplication` to package each of the Visual C++ Redistributables and import them as a separate application into a target tenant.

An application package will be created for each Visual C++ Redistributable with properties including Name, Description, Publisher, App Version, Information URL, Privacy URL, Notes, Logo, Install command, Uninstall command, Install behavior, Operating system architecture, Minimum operating system, and Detection rules.

This function requires the [IntuneWin32App](https://github.com/MSEndpointMgr/IntuneWin32App) PowerShell module and supported Windows PowerShell only. Before using this function to import the Redistributables into an Intune tenant, authenticate first with Connect-MSIntuneGraph.

## Initial Setup

To import the Visual C++ Redistributables into Microsoft Intune, some initial setup is required - first, install the required modules from the PowerShell Gallery:

```powershell
Set-PSRepository -Name PSGallery -InstallationPolicy Trusted
Install-Module -Name VcRedist, IntuneWin32App
```

## Required parameters

- `VcList` - An array containing details of the Visual C++ Redistributables from `Save-VcRedist`

## Authentication

### Interactive Authentication

Before using `Import-VcIntuneApplication`, you need to authenticate to the Microsoft Intune tenant with `Connect-MSIntuneGraph`. This function is part of the `IntuneWin32App` module, so any supported authentication method can be used.

For an interactive sign-in that will require credentials for an account with the Intune Administrator role, use this example:

```powershell
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com
```

### Non-interactive Authentication

An Entra ID app registration can be used for non-interactive authentication. The app registration requires the **DeviceManagementApps.ReadWrite.All** application permission. Create an app registration, assign the permission and enable admin consent. Then use a client secret or client certificate to use with authentication.

![Entra ID app registration for IntuneWin32App](assets/images/appregistration.jpeg)

For a non-interactive sign-in that uses the app registration and a client secret, use this example:

```powershell
Connect-MSIntuneGraph -TenantID contoso.onmicrosoft.com -ClientId "f99877d5-f757-438e-b12b-d905b00ea6f3" -ClientSecret <secret>
```

## Import the Redistributables

The example listing below retrieves the list of Visual C++ Redistributables for the 2022 version, download the installers to `C:\Temp\VcRedist` and imports each Redistributable into the target Intune tenant as separate application.

```powershell
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path C:\Temp\VcRedist
Import-VcIntuneApplication -VcList $VcList
```

![Microsoft Visual C++ Redistributables applications imported into Intune](assets/images/intuneapp.jpeg)

## Create application assignments

With the application packages imported, configure assignments with `Add-IntuneWin32AppAssignmentAllDevices`. `Import-VcIntuneApplication` will return details of the applications imported into Intune, including the `Id` property required for adding assignments.

In the example below, the Redistributables imported into Intune will be assigned to all devices.

```powershell
$Apps = Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist | Import-VcIntuneApplication
foreach ($App in $Apps) {
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
