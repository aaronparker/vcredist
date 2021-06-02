# Create a Redistributables bundle in MDT

Once the Visual C++ Redistributables have been imported into a MDT deployment share, they will be available as individual applications that can be added to a task sequence. To simplify selection of the Redistributables, they can be added to an application bundle. A bundle is an application in the MDT share that does not install applications itself, but includes other applications as dependencies. Thus a bundle can install a set of applications in a specific order using a single action in a task sequence.

The Version property of the bundle is stamped with the current date making it easy to see when the bundle was created or last updated.

## Parameters

### Required parameters

* `MdtPath` - the local or network path to the MDT deployment share

### Optional parameters

* `AppFolder` - imports the Visual C++ Redistributables into a sub-folder. Defaults to "VcRedists"
* `MdtDrive` - the drive letter that will be mapped to the MDT deployment share. Not required and defaults to "DS001"
* `Publisher` - the publisher that will be assigned to the Visual C++ Redistributables bundle. Not required and defaults to "Microsoft"
* `BundleName` - the bundle short name assigned to the Visual C++ Redistributables bundle. Not required and defaults to "Visual C++ Redistributables"
* `Language` - defaults to "en-US"

## Examples

To create the bundle in the target deployment share, run `New-VcMdtBundle`. This function will scan for the Visual C++ Redistributables in the default application folder (VcRedists) and create a bundle with each Redistributable application as a dependency in order from oldest to newest Redistributable.

```powershell
New-VcMdtBundle -MdtPath \\server\deployment
```
