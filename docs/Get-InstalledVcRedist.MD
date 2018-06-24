# Get-InstalledVcRedist

## SYNOPSIS
Returns the installed Visual C++ Redistributables.

## SYNTAX

```
Get-InstalledVcRedist [-ExportAll] [<CommonParameters>]
```

## DESCRIPTION
Returns the installed Visual C++ Redistributables.

## EXAMPLES

### EXAMPLE 1
```
Get-InstalledVcRedist
```

Description:
Returns the installed Microsoft Visual C++ Redistributables from the current system

### EXAMPLE 2
```
Get-InstalledVcRedist -ExportAll
```

Description:
Returns the installed Microsoft Visual C++ Redistributables from the current system including the Additional and Minimum Runtimes.

## PARAMETERS

### -ExportAll
Export all installed Redistributables including the Additional and Minimum Runtimes

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
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable.
For more information, see about_CommonParameters (http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES
Author: Aaron Parker
Twitter: @stealthpuppy

## RELATED LINKS

[https://github.com/aaronparker/Install-VisualCRedistributables](https://github.com/aaronparker/Install-VisualCRedistributables)