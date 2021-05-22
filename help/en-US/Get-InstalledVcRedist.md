---
external help file: VcRedist-help.xml
Module Name: VcRedist
online version: https://stealthpuppy.com/vcredist/get-installedvcredist.html
schema: 2.0.0
---

# Get-InstalledVcRedist

## SYNOPSIS

Returns the installed Visual C++ Redistributables.

## SYNTAX

```powershell
Get-InstalledVcRedist [-ExportAll] [<CommonParameters>]
```

## DESCRIPTION

Queries the registry to find the installed Visual C++ Redistributables on the local system and returns the list to the pipeline. This includes the primary Redistributable entries by default and can export the additional and minimum Redistributable components also listed in the Registry.

## EXAMPLES

### EXAMPLE 1

```powershell
Get-InstalledVcRedist
```

Description:
Returns the installed Microsoft Visual C++ Redistributables from the current system.

### EXAMPLE 2

```powershell
Get-InstalledVcRedist -ExportAll
```

Description:
Returns the installed Microsoft Visual C++ Redistributables from the current system including the Additional and Minimum Runtimes.

## PARAMETERS

### -ExportAll

Export all installed Redistributables including the Additional and Minimum Runtimes typically hidden from Programs and Features.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
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

[Get the locally installed Redistributables:](https://stealthpuppy.com/vcredist/get-installedvcredist.html)
