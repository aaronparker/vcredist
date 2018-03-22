# Get-VcRedist

## SYNOPSIS
Downloads the Visual C++ Redistributables from an array returned by Get-VcXml.

## SYNTAX

```
Get-VcRedist [-VcList] <Array> [[-Path] <String>] [-Release <String[]>] [-Architecture <String[]>] [-WhatIf]
 [-Confirm] [<CommonParameters>]
```

## DESCRIPTION
Downloads the Visual C++ Redistributables from an array returned by Get-VcXml into a folder structure that represents release and processor architecture.
If the redistributable exists in the specified path, it will not be re-downloaded.

## EXAMPLES

### EXAMPLE 1
```
Get-VcXml | Get-VcRedist -Path C:\Redist
```

Description:
Downloads the supported Visual C++ Redistributables to C:\Redist.

### EXAMPLE 2
```
Get-VcRedist -VcXml $VcRedists -Release "2012","2013",2017"
```

Description:
Downloads only the 2012, 2013 & 2017 releases of the  Visual C++ Redistributables listed in $VcRedists

### EXAMPLE 3
```
Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist -Architecture x64
```

Description:
Downloads only the 64-bit versions of the Visual C++ Redistributables listed in $VcRedists.

## PARAMETERS

### -VcList
Sepcifies the array that lists the Visual C++ Redistributables to download

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
Specify a target folder to download the Redistributables to, otherwise use the current folder.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
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
For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES
Name: Get-VcRedist
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://github.com/aaronparker/Install-VisualCRedistributables](https://github.com/aaronparker/Install-VisualCRedistributables)