# Query Visual C++ Redistributables in Microsoft Intune

`Get-VcIntuneApplication` retrieves all Visual C++ Redistributable Win32 applications currently present in Microsoft Intune. It is useful for auditing, reporting, or verifying which redistributables are managed in your Intune tenant.

## Features

- Queries Intune for all Visual C++ Redistributable Win32 applications
- Returns application details including display name and ID
- Useful for inventory, reporting, or as input to other VcRedist functions

## Prerequisites

- The [IntuneWin32App](https://github.com/MSEndpointMgr/IntuneWin32App) PowerShell module must be installed and imported
- You must be authenticated to Intune with `Connect-MSIntuneGraph`
- A valid Microsoft Graph API access token must be present

## Usage

```powershell
# Query all Visual C++ Redistributable Win32 apps in Intune
$Apps = Get-VcIntuneApplication

# Display the results
$Apps | Format-Table displayName, Id
```

## How It Works

1. Calls `Get-VcList -Export All` to get a list of all known redistributables
2. Calls `Get-VcRedistAppsFromIntune` with that list to retrieve matching Intune Win32 applications
3. Returns the list of Intune application objects

## Output

Each object in the returned array includes properties such as:
- `displayName`: The application's display name in Intune
- `Id`: The Intune application ID
- Other properties as returned by `Get-VcRedistAppsFromIntune`

## Troubleshooting

- **Missing modules:** Ensure `IntuneWin32App` is installed and imported
- **Authentication errors:** Authenticate with `Connect-MSIntuneGraph` and ensure `$Global:AccessToken` is set
- **No results:** Ensure you have imported Visual C++ Redistributables into Intune using `Import-VcIntuneApplication`

## See Also

- [Import-VcIntuneApplication](import-vcintuneapplication.md)
- [Remove-VcIntuneApplication](remove-vcintuneapplication.md)
- [IntuneWin32App PowerShell Module](https://github.com/MSEndpointMgr/IntuneWin32App)
- [VcRedist Documentation](https://vcredist.com/)
