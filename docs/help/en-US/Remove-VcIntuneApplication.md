---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/remove-vcintuneapplication/
schema: 2.0.0
---

# Remove-VcIntuneApplication

## SYNOPSIS

Removes Microsoft Visual C++ Redistributables imported into Microsoft Intune via Import-VcIntuneApplication. Accepts a list of Visual C++ Redistributables from Get-VcList, queries Intune for matching Visual C++ Redistributables, and removes them from Intune.

## SYNTAX

```
Remove-VcIntuneApplication [-VcList] <PSObject> [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Removes Microsoft Visual C++ Redistributables imported into Microsoft Intune via Import-VcIntuneApplication. Accepts a list of Visual C++ Redistributables from Get-VcList, queries Intune for matching Visual C++ Redistributables, and removes them from Intune.

## EXAMPLES

### EXAMPLE 1

```powershell
$VcList = Get-VcList -Release "2017"
Remove-VcIntuneApplication -VcList $VcList -Confirm:$false
```

Description:
Queries Microsoft Intune for the Microsoft Visual C++ Redistributables 2017 packages and removes them.

## PARAMETERS

### -VcList

An array containing details of the Visual C++ Redistributables from Get-VcList or Save-VcRedist.

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

## RELATED LINKS

[Remove the Redistributables:](https://vcredist.com/remove-vcintuneapplication/)
