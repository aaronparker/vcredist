---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://github.com/aaronparker/Install-VisualCRedistributables
schema: 2.0.0
---

# Import-VcCmApp

## SYNOPSIS
Creates Visual C++ Redistributable applications in a ConfigMgr site.

## SYNTAX

```
Import-VcCmApp [-VcList] <Array> [-Path] <String> -CMPath <String> -SMSSiteCode <String> [-AppFolder <String>]
 [-Release <String[]>] [-Architecture <String[]>] [-Publisher <Object>] [-Language <Object>]
 [-Keyword <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Creates an application in a Configuration Manager site for each Visual C++ Redistributable and includes setting whether the Redistributable can run on 32-bit or 64-bit Windows and the Uninstall key for detecting whether the Redistributable is installed.

Use Get-VcList and Get-VcRedist to download the Redistributable and create the array of Redistributables for importing into ConfigMgr.

## EXAMPLES

### EXAMPLE 1
```
$VcList = Get-VcList | Get-VcRedist -Path "C:\Temp\VcRedist"
```

Import-VcCmApp -VcList $VcList -Path "C:\Temp\VcRedist" -CMPath "\\\\server\share\VcRedist" -SMSSiteCode LAB

Description:
Download the supportee Visual C++ Redistributables to "C:\Temp\VcRedist", copy them to "\\\\server\share\VcRedist" and import as applications into the ConfigMgr site LAB.

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

### -CMPath
Specify a UNC path where the Visual C++ Redistributables will be distributed from

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

### -SMSSiteCode
Specify the Site Code for ConfigMgr app creation.

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

### -AppFolder
Import the Visual C++ Redistributables into a sub-folder.
Defaults to "VcRedists".

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: VcRedists
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

### -Keyword
{{Fill Keyword Description}}

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Visual C++ Redistributable
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
Name: Import-VcCmApp
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://github.com/aaronparker/Install-VisualCRedistributables](https://github.com/aaronparker/Install-VisualCRedistributables)

