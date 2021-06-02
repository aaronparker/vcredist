---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/vcredist/install-vcredist/
schema: 2.0.0
---

# Uninstall-VcRedist

## SYNOPSIS

Uninstall the installed Visual C++ Redistributables on the local system.

## SYNTAX

### Manual (Default)

```powershell
Uninstall-VcRedist [[-Release] <String[]>] [[-Architecture] <String[]>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

### Pipeline

```powershell
Uninstall-VcRedist [-VcList] <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Uninstall the specified Release and/or Architecture of the installed Visual C++ Redistributables on the local system. All or specific Visual C++ Redistributables can be uninstalled.

## EXAMPLES

### EXAMPLE 1

```powershell
Uninstall-VcRedist -Confirm:$True
```

Description:
Uninstalls all installed x64, x86 2005-2019 Visual C++ Redistributables.

### EXAMPLE 2

```powershell
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description:
Uninstalls all installed x64, x86 2008 and 2010 Visual C++ Redistributables.

### EXAMPLE 3

```powershell
Uninstall-VcRedist -Release 2008, 2010 -Confirm:$True
```

Description:
Uninstalls all installed x64, x86 2008 and 2010 Visual C++ Redistributables.

## PARAMETERS

### -Release

Specifies the release of the redistributables to uninstall.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 1
Default value: @("2005", "2008", "2010", "2012", "2013", "2015", "2017", "2019")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture

Specifies the processor architecture to of the redistributables to uninstall.
Can be x86 or x64.

```yaml
Type: String[]
Parameter Sets: Manual
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -VcList

Specifies the array that lists the Visual C++ Redistributables to download.

```yaml
Type: PSObject
Parameter Sets: Pipeline
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
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

[Uninstall the Redistributables:](https://stealthpuppy.com/vcredist/uninstall-vcredist/)
