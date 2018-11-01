# Exporting the Manifests

`Export-VcXml` will export the internal Redistributable manifests if you want to store an external copy or edit them to create custom versions. Both the supported and unsupported Redistributable manifests can be exported to a specified file in XML format.

Export the manifest of supported Redistributables:

```powershell
Export-VcXml -Path .\VcRedists.xml
```

Export the manifest of all supported and unsupported Redistributables:

```powershell
Export-VcXml -Path .\VcRedists.xml -Export All
```
