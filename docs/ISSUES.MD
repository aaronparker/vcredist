# Known Issues

## Import-VcMdtApp

If the path specificed by -AppFolder exists, import fails with:

```
Import-MDTApplication : Cannot bind parameter 'Path' to the target. Exception setting "Path": "Cannot process argument because the value of argument "paths" is null. Change the value of argument "paths" to a non-null value."
```

Delete the sub-folder of Applications in the MDT share and re-try the import.