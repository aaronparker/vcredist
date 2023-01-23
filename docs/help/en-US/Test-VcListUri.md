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
Test-VcRedistUri [-VcList] <PSObject> [[-Proxy] <String>] [[-ProxyCredential] <PSCredential>] [-ShowProgress]
 [-WhatIf] [-Confirm] [<CommonParameters>]
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

[Download the Redistributables:](https://vcredist.com/save-vcredist/)
