---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com
schema: 2.0.0
---

# Import-VcMdtApp

## SYNOPSIS
Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

## SYNTAX

```
Import-VcMdtApp [-VcList] <Array> [-Path] <String> [-Release <String[]>] [-Architecture <String[]>]
 -MdtPath <String> [-MdtDrive <Object>] [-Publisher <Object>] [-Language <Object>] [-WhatIf] [-Confirm]
 [<CommonParameters>]
```

## DESCRIPTION
Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes setting whether the Redistributable can run on 32-bit or 64-bit Windows and the Uninstall key for detecting whether the Redistributable is installed.

Use Get-VcList and Get-VcRedist to download the Redistributable and create the array of Redistributables for importing into MDT.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -MDTShare \\server\deployment
```

Description:
Retrieves the list of Visual C++ Redistributables, downloaded them C:\Temp\VcRedist and imports each Redistributable into the MDT dpeloyment share at \\\\server\deployment.

Parameter sets here means that Install, MDT and ConfigMgr actions are mutually exclusive

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

### -MdtPath
The path to the MDT deployment share.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MdtDrive
{{Fill MdtDrive Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: DS001
Accept pipeline input: False
Accept wildcard characters: False
```

### -Publisher
{{Fill Publisher Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Microsoft
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language
{{Fill Language Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: En-US
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
Name: Import-VcMdtApp
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://stealthpuppy.com](https://stealthpuppy.com)

