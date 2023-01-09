---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://vcredist.com/export-vcmanifest/
schema: 2.0.0
---

# Export-VcManifest

## SYNOPSIS

Exports the Visual C++ Redistributables JSON manifest to an external file.

## SYNTAX

```
Export-VcManifest [-Path] <String> [<CommonParameters>]
```

## DESCRIPTION

Reads the Visual C++ Redistributables JSON manifests included in the VcRedist module and exports the JSON to an external file.
This enables editing of the JSON manifest for custom scenarios.

## EXAMPLES

### EXAMPLE 1

```powershell
Export-VcManifest -Path "C:\Temp\VisualCRedistributablesSupported.json"
```

Description:
Export the list of supported Visual C++ Redistributables to C:\Temp\VisualCRedistributablesSupported.json.

## PARAMETERS

### -Path

Path to the JSON file the content will be exported to.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### CommonParameters

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.String

## NOTES

Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[Export the Redistributable Manifests:](https://vcredist.com/export-vcmanifest/)
