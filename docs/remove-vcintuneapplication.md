# Remove Visual C++ Redistributables from Microsoft Intune

`Remove-VcIntuneApplication` automates the removal of Visual C++ Redistributable Win32 applications from Microsoft Intune. It matches applications in Intune based on the provided VcList and removes them using the IntuneWin32App module.

## Features

- Removes Win32 applications for Visual C++ Redistributables from Intune
- Accepts a VcList object (from `Save-VcRedist`) to identify which apps to remove
- Supports `-WhatIf` and `-Confirm` for safe operation
- Provides verbose output for tracking removals

## Prerequisites

- The [IntuneWin32App](https://github.com/MSEndpointMgr/IntuneWin32App) PowerShell module must be installed and imported
- You must be authenticated to Intune with `Connect-MSIntuneGraph`
- A valid Microsoft Graph API access token must be present

## Parameters

- `VcList` (**required**): An array of Visual C++ Redistributable objects, typically from `Save-VcRedist`. Used to match and remove corresponding Intune applications.

## Example Usage

```powershell
# Get the list of redistributables you want to remove
$VcList = Get-VcList -Release "2022" | Save-VcRedist -Path C:\Temp\VcRedist

# Remove the corresponding Intune applications
Remove-VcIntuneApplication -VcList $VcList -Verbose -Confirm:$false
```

> **Tip:** Use `-WhatIf` to view which applications would be removed from Intune.

## How It Works

1. Retrieves existing Visual C++ Redistributable Win32 apps in Intune using `Get-VcRedistAppsFromIntune`
2. For each matched application, calls `Remove-IntuneWin32App` to remove it from Intune
3. Supports PowerShell's `ShouldProcess` for `-WhatIf` and `-Confirm` safety

## Troubleshooting

- **Missing modules:** Ensure `IntuneWin32App` is installed and imported
- **Authentication errors:** Authenticate with `Connect-MSIntuneGraph` and ensure `$Global:AccessToken` is set
- **No matching apps:** Ensure your `VcList` matches the apps you want to remove

## See Also

- [IntuneWin32App PowerShell Module](https://github.com/MSEndpointMgr/IntuneWin32App)
- [VcRedist Documentation](https://vcredist.com/)
