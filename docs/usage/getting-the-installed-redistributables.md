# Getting the Installed Redistributables

`Get-InstalledVcRedist` is used to return the list of Redistributables installed on the current system. This function can be used to compare the installed list of Redistributables against that listed in the manifests included in the module.

The following command will return the list of installed Redistributables:

```text
Get-InstalledVcRedist
```

![Microsoft Visual C++ Redistributables installed on the local PC](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/installed-vcredist.png)

This list won't include the Additional and Minimum Runtimes by default. These can be returned with the `-ExportAll` switch:

```text
Get-InstalledVcRedist -ExportAll
```

