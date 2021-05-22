---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/vcredist/save-vcredist.html
schema: 2.0.0
---

# Save-VcRedist

## SYNOPSIS

Downloads the Visual C++ Redistributables from an manifest returned by Get-VcList.

## SYNTAX

```powershell
Save-VcRedist [-VcList] <PSObject> [[-Path] <String>] [-ForceWebRequest] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-NoProgress] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION

Downloads the Visual C++ Redistributables from an manifest returned by Get-VcList into a folder structure that represents release, version and processor architecture.
If the redistributable exists in the specified path, it will not be re-downloaded.

For example, the following folder structure will be created when downloading the 2010, 2012, 2013 and 2019 Redistributables to C:\VcRedist:

C:\VcRedist\2010\10.0.40219.325\x64
C:\VcRedist\2010\10.0.40219.325\x86
C:\VcRedist\2012\11.0.61030.0\x64
C:\VcRedist\2012\11.0.61030.0\x86
C:\VcRedist\2013\12.0.40664.0\x64
C:\VcRedist\2013\12.0.40664.0\x86
C:\VcRedist\2019\14.28.29913.0\x64
C:\VcRedist\2019\14.28.29913.0\x86

## EXAMPLES

### EXAMPLE 1

```powershell
Save-VcRedist -VcList (Get-VcList) -Path C:\Redist
```

Description:
Downloads the supported Visual C++ Redistributables to C:\Redist.

### EXAMPLE 2

```powershell
Get-VcList | Save-VcRedist -Path C:\Redist
```

Description:
Passes the list of supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

### EXAMPLE 3

```powershell
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Save-VcRedist -VcList $VcList -Path C:\Redist
```

Description:
Passes the list of 2013 and 2019 x86 supported Visual C++ Redistributables to Save-VcRedist and downloads the Redistributables to C:\Redist.

### EXAMPLE 4

```powershell
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist
```

Description:
Downloads the 2010, 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist.

### EXAMPLE 5

```powershell
Save-VcRedist -VcList (Get-VcList -Release 2010, 2012, 2013, 2019) -Path C:\Redist -Proxy proxy.domain.local
```

Description:
Downloads the 2010, 2012, 2013, and 2019 Visual C++ Redistributables to C:\Redist using the proxy server 'proxy.domain.local'

## PARAMETERS

### -VcList

Specifies the array that lists the Visual C++ Redistributables to download.

```yaml
Type: PSObject
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path

Specify a target folder to download the Redistributables to, otherwise use the current folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 2
Default value: (Resolve-Path -Path $PWD)
Accept pipeline input: False
Accept wildcard characters: False
```

### -ForceWebRequest

Force the use of Invoke-WebRequest instead of Start-BitsTransfer. Included for backwards compatibility only.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -Priority

Force the priority when using Start-BitsTransfer. Included for backwards compatibility only.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Foreground
Accept pipeline input: False
Accept wildcard characters: False
```

### -Proxy

Specifies a proxy server for the request, rather than connecting directly to the internet resource.
Enter the URI of a network proxy server.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProxyCredential

Specifies a user account that has permission to use the proxy server that is specified by the Proxy parameter.
The default is the current user.

```yaml
Type: PSCredential
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: [System.Management.Automation.PSCredential]::Empty
Accept pipeline input: False
Accept wildcard characters: False
```

### -NoProgress

Specify this switch with -Verbose to show verbose output but also suppress Invoke-WebRequest progress to speed downloads.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -WhatIf

Shows what would happen if the cmdlet runs.
The cmdlet is not run.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: wi

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Confirm

Prompts you for confirmation before running the cmdlet.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases: cf

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Management.Automation.PSObject

## NOTES

Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[Download the Redistributables:](https://stealthpuppy.com/vcredist/save-vcredist.html)
