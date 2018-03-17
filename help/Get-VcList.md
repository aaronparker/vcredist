---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://github.com/aaronparker/Install-VisualCRedistributables
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
Returns an array of Visual C++ Redistributables.

## SYNTAX

```
Get-VcList [[-Xml] <String>] [-Export <String>] [<CommonParameters>]
```

## DESCRIPTION
This function reads the Visual C++ Redistributables listed in an internal manifest or an external XML file into an array that can be passed to other VcRedist functions.

A complete listing the supported and all known redistributables is included in the module.
These internal manifests can be exported with Export-VcXml.

## EXAMPLES

### EXAMPLE 1
```
Get-VcList
```

Description:
Return an array of the Visual C++ Redistributables from the embedded manifest

### EXAMPLE 2
```
Get-VcList -Xml ".\VisualCRedistributablesSupported.xml"
```

Description:
Return an array of the Visual C++ Redistributables listed in VisualCRedistributablesSupported.xml.

## PARAMETERS

### -Xml
The XML file that contains the details about the Visual C++ Redistributables.
This must be in the expected format.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 1
Default value: "$($MyInvocation.MyCommand.Module.ModuleBase)\VisualCRedistributablesSupported.xml"
Accept pipeline input: False
Accept wildcard characters: False
```

### -Export
Defines the list of Visual C++ Redistributables to export - All Redistributables or Supported Redistributables only.
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

### System.Array

## NOTES
Name: Get-VcXml
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://github.com/aaronparker/Install-VisualCRedistributables](https://github.com/aaronparker/Install-VisualCRedistributables)

