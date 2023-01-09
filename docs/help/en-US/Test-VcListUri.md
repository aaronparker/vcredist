---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/test-vcredisturi/
schema: 2.0.0
---

# Test-VcRedistUri

## SYNOPSIS

Tests that the downloads for the Visual C++ Redistributables as listed in the manifest returned by Get-VcList are available (i.e. return a HTTP 200 response).

## SYNTAX

```
Test-VcRedistUri [-VcList] <PSObject> [[-Path] <String>] [-Priority <String>]
 [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-UserAgent <String>] [-ShowProgress] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Tests that the downloads for the Visual C++ Redistributables as listed in the manifest returned by Get-VcList are available (i.e. return a HTTP 200 response).

A true or false value is returned for each Visual C++ Redistributables passed to the function.

## EXAMPLES

### EXAMPLE 1

```powershell
Test-VcRedistUri -VcList (Get-VcList)
```

Description:
Test the Visual C++ Redistributables passed from Get-VcList.

### EXAMPLE 2

```powershell
Get-VcList | Test-VcRedistUri
```

Description:
Passes the list of supported Visual C++ Redistributables from Get-VcList to Test-VcRedistUri via the pipeline

### EXAMPLE 3

```powershell
$VcList = Get-VcList -Release 2013, 2019 -Architecture x86
Test-VcRedistUri -VcList $VcList
```

Description:
Tests the list of 2013 and 2019 x86 supported Visual C++ Redistributables.

### EXAMPLE 4

```powershell
Test-VcRedistUri -VcList (Get-VcList -ExportAll)
```

Description:
Exports all supported and unsupported Visual C++ Redistributables and tests the downloads to determine whether they are valid.

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

### -ShowProgress

Instructs Invoke-WebRequest used by this function to display progress.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -UserAgent

Specifies a user agent string for the web request.

The default user agent is similar to the below with slight variations for each operating system and platform.

Mozilla/5.0 (Macintosh; Darwin 22.2.0 Darwin Kernel Version 22.2.0: Fri Nov 11 02:04:44 PST 2022; root:xnu-8792.61.2~4/RELEASE_ARM64_T8103; en-AU) AppleWebKit/534.6 (KHTML, like Gecko) Chrome/7.0.500.0 Safari/534.6

To test a website with the standard user agent string that's used by most internet browsers, use the properties of the PSUserAgent class, such as Chrome, FireFox, InternetExplorer, Opera, and Safari.

For example, the following command uses the user agent string for Internet Explorer: Save-EvergreenApp -UserAgent ([Microsoft.PowerShell.Commands.PSUserAgent]::InternetExplorer)

```yaml
Type: String
Parameter Sets: (All)
Aliases:

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

[Download the Redistributables:](https://vcredist.com/save-vcredist/)
