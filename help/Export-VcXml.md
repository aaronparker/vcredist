---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com
schema: 2.0.0
---

# Export-VcXml

## SYNOPSIS
Exports the Visual C++ Redistributables XML to an external file.

## SYNTAX

```
Export-VcXml [-Path] <String> [-Export <String>] [<CommonParameters>]
```

## DESCRIPTION
Reads the Visual C++ Redistributables XML manifests included in the VcRedist module and exports the XML to an external file.
This enables editing of the XML manifest for custom scenarios.

## EXAMPLES

### EXAMPLE 1
```
Export-VcXml -Path "C:\Temp\VisualCRedistributablesSupported.xml" -Export Supported
```

Description:
Export the list of supported Visual C++ Redistributables to C:\Temp\VisualCRedistributablesSupported.xml.

## PARAMETERS

### -Path
Path to the XML file the content will be exported to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Switch parameter that defines the list of Visual C++ Redistributables to export - All Redistributables or Supported Redistributables only.
Defaults to exporting the Supported Redistributables.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Supported
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES
Name: Export-VcXml
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://stealthpuppy.com](https://stealthpuppy.com)

