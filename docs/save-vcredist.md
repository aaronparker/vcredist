# Download the Redistributables

To download the Visual C++ Redistributables to a local folder, use `Save-VcRedist`. This will read the array of Visual C++ Redistributables returned from `Get-VcList` and download each one to a local folder specified in `-Path`. Use the `-Release` or `-Architecture` parameters in `Get-VcList` to filter for specific Visual C++ Redistributables.

Save-VcRedist downloads the Redistributables and returns the array passed from Get-VcList to the pipeline so that it can be passed to other functions `Install-VcRedist`.

## Parameters

### Required parameters

* `VcList` - An array containing details of the Visual C++ Redistributables from `Get-VcList`
* `Path` - A folder to downloaded Visual C++ Redistributables into

### Optional parameters

* `Proxy` - Specify a proxy server to use when downloading the Visual C++ Redistributables
* `ProxyCredential` - If the proxy server requires authentication, credentials can be specified as an PSCredential object

## Examples

To download the default list of Redistributables to `C:\Temp\VcRedist`, use the following command:

```powershell
New-Item -Path C:\Temp\VcRedist -ItemType Directory
Get-VcList | Save-VcRedist -Path C:\Temp\VcRedist
```

Redistributables are downloaded into the target folder:

![Microsoft Visual C++ Redistributables installed on the local PC](assets/images/vcredist-folder.png)

Pass the list of 2013 and 2019 x86 supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

```powershell
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

Download the 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist.

```powershell
Save-VcRedist -VcList (Get-VcList -Release 2012, 2013, 2019) -Path C:\Redist
```

Downloads the 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist using the proxy server 'proxy.domain.local'

```powershell
Save-VcRedist -VcList (Get-VcList -Release 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```
