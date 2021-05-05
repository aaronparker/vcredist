---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/VcRedist/get-vclist.html
schema: 2.0.0
---

# Get-VcList

## SYNOPSIS

Returns an object of Microsoft Visual C++ Redistributables for use with other VcRedist functions.

## SYNTAX

### Manifest (Default)

```powershell
Get-VcList [[-Release] <String[]>] [[-Architecture] <String[]>] [[-Path] <String>] [<CommonParameters>]
```

### Export

```powershell
Get-VcList [[-Export] <String>] [<CommonParameters>]
```

## DESCRIPTION

This function reads the Visual C++ Redistributables listed in an internal manifest (or an external JSON file) into an object that can be passed to other VcRedist functions.

A complete listing of the supported and all known redistributables is included in the module.
By default, Get-VcList will only return a list of the supported Visual C++ Redistributables.
To return any of the unsupported Redistributables, the -Export parameter is required with the output filtered with Where-Object.

The internal manifest can be exported with Export-VcManifest.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-VcList
```

Description:
Return an object of the supported Visual C++ Redistributables from the embedded manifest.

### EXAMPLE 2

```powershell
Get-VcList
```

Description:
Returns the supported 2010, 2012, 2013 and 2019, x86 and x64 versions of the supported Visual C++ Redistributables from the embedded manifest.

### EXAMPLE 3

```powershell
Get-VcList -Export All
```

Description:
Returns a list of the all Visual C++ Redistributables from the embedded manifest, including unsupported versions.

### EXAMPLE 4

```powershell
Get-VcList -Export Supported
```

Description:
Returns the full list of supported Visual C++ Redistributables from the embedded manifest.
This is the same as running Get-VcList with no parameters.

### EXAMPLE 5

```powershell
Get-VcList -Export Unsupported | Where-Object { $_.Release -eq "2008" }
```

Description:
Returns the full list of unsupported Visual C++ Redistributables from the embedded manifest and filters for the 2008 versions of the Redistributables.

### EXAMPLE 6

```powershell
Get-VcList -Release 2013, 2019 -Architecture x86
```

Description:
Returns the 2013 and 2019 x86 Visual C++ Redistributables from the list of supported Redistributables in the embedded manifest.

### EXAMPLE 7

```powershell
Get-VcList -Path ".\VisualCRedistributables.json"
```

Description:
Returns a list of the Visual C++ Redistributables listed in the external manifest VisualCRedistributables.json.

## PARAMETERS

### -Release

Specifies the release (or version) of the redistributables to return.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 1
Default value: @("2010", "2012", "2013", "2019")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Architecture

Specifies the processor architecture to of the redistributables to return. Can be x86 or x64.

```yaml
Type: String[]
Parameter Sets: Manifest
Aliases:

Required: False
Position: 2
Default value: @("x86", "x64")
Accept pipeline input: False
Accept wildcard characters: False
```

### -Path

Provide a path to an external VcRedist manifest file.

```yaml
Type: String
Parameter Sets: Manifest
Aliases: Xml

Required: False
Position: 3
Default value: (Join-Path -Path $MyInvocation.MyCommand.Module.ModuleBase -ChildPath "VisualCRedistributables.json")
Accept pipeline input: True (ByValue)
Accept wildcard characters: False
```

### -Export

Defines the list of Visual C++ Redistributables to export - All, Supported or Unsupported Redistributables.
Defaults to exporting the Supported Redistributables.

```yaml
Type: String
Parameter Sets: Export
Aliases:

Required: False
Position: 1
Default value: Supported
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

[Get the list of Visual C++ Redistributables:](https://stealthpuppy.com/VcRedist/get-vclist.html)
