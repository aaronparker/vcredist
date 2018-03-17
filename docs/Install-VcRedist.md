---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com
schema: 2.0.0
---

# Install-VcRedist

## SYNOPSIS
Installs the Visual C++ Redistributables.

## SYNTAX

```
Install-VcRedist [-VcList] <Array> [-Path] <String> [-Release <String[]>] [-Architecture <String[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Installs the Visual C++ Redistributables from a list created by Get-VcList and downloaded locally with Get-VcRedist.

## EXAMPLES

### EXAMPLE 1
```
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists
```

Description:
Installs the Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

### EXAMPLE 2
```
Install-VcRedist -VcList $VcRedists -Path C:\Temp\VcRedists -Release "2012","2013",2017" -Architecture x64
```

Description:
Installs only the 64-bit 2012, 2013 and 2017 Visual C++ Redistributables listed in $VcRedists and downloaded to C:\Temp\VcRedists.

## PARAMETERS

### -VcList
An array containing details of the Visual C++ Redistributables from Get-VcList.

```yaml
Type: Array
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Path
A folder containing the downloaded Visual C++ Redistributables.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Release
Specifies the release (or version) of the redistributables to download or install.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @("2008", "2010", "2012", "2013", "2015", "2017")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture
Specifies the processor architecture to download or install.

```yaml
Type: String[]
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: @("x86", "x64")
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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES
Name: Install-VcRedist
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://stealthpuppy.com](https://stealthpuppy.com)

