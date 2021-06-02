# Export the Manifests

`Export-VcManifest` will export the internal Redistributable manifests if you want to store an external copy for creating a custom manifest. Both the supported and unsupported Redistributable manifests can be exported to a specified file in [JSON](https://www.json.org/) format.

## Parameters

### Required parameters

* `Path` - Path to the JSON file the content will be exported to.

### Optional parameters

* `ExportAll` - Switch parameter that forces the export of Visual C++ Redistributables including unsupported Redistributables

## Examples

Export the manifest of supported Redistributables:

```powershell
Export-VcManifest -Path C:\Temp\VcRedists.json
```

Export the manifest of all supported and unsupported Redistributables:

```powershell
Export-VcManifest -Path .\VcRedists.json -Export All
```

Export the manifest of all supported Redistributables:

```powershell
Export-VcManifest -Path .\VcRedists.json -Export Supported
```

Export the manifest of all unsupported Redistributables:

```powershell
Export-VcManifest -Path .\VcRedists.json -Export Unsupported
```
