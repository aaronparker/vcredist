---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS
Creates and array of Visual C++ Redistributables listed in an external XML file.

## SYNTAX

```
Get-VcList [[-Xml] <String>] [-Export <String>] [<CommonParameters>]
```

## DESCRIPTION
This function reads the Visual C++ Redistributables listed in an external XML file into an array that can be passed to other VcRedist functions.

A complete XML file listing the redistributables is included.
The basic structure of the XML file should be:

\<Redistributables\>
    \<Platform Architecture="x64" Release="" Install=""\>
        \<Redistributable\>
            \<Name\>\</Name\>
            \<ShortName\>\</ShortName\>
            \<URL\>\</URL\>
            \<ProductCode\>\</ProductCode\>
            \<Download\>\</Download\>
    \</Platform\>
    \<Platform Architecture="x86" Release="" Install=""\>
        \<Redistributable\>
            \<Name\>\</Name\>
            \<ShortName\>\</ShortName\>
            \<URL\>\</URL\>
            \<ProductCode\>\</ProductCode\>
            \<Download\>\</Download\>
        \</Redistributable\>
    \</Platform\>
\</Redistributables\>

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES
Name: Get-VcXml
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://stealthpuppy.com](https://stealthpuppy.com)

