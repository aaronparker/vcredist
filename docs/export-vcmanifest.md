# Export the Manifest

`Export-VcManifest` will export the internal Redistributable manifests if you want to store an external copy for creating a custom manifest. Both the supported and unsupported Redistributable manifests can be exported to a specified file in [JSON](https://www.json.org/) format.

## Parameters

### Required parameters

* `Path` - A directory path that the manifest will be exported to.

## Examples

Export the VcRedist manifest of supported Redistributables to `C:\Temp`. The manifest will be exported to `C:\Temp\VisualCRedistributables.json`.

```powershell
Export-VcManifest -Path C:\Temp
```
