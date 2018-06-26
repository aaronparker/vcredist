# Import-VcMdtApp

## SYNOPSIS

Creates Visual C++ Redistributable applications in a Microsoft Deployment Toolkit share.

## SYNTAX

```text
Import-VcMdtApp [-VcList] <Array> [-Path] <String> -MdtPath <String> [-AppFolder <String>]
 [-Release <String[]>] [-Architecture <String[]>] [-Bundle] [-MdtDrive <Object>] [-Publisher <Object>]
 [-BundleName <Object>] [-Language <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]
```

## DESCRIPTION

Creates an application in a Microsoft Deployment Toolkit share for each Visual C++ Redistributable and includes properties such as target Silent command line, Platform and Uninstall key.

Use Get-VcList and Get-VcRedist to download the Redistributables and create the array for importing into MDT.

## EXAMPLES

### EXAMPLE 1

```text
Get-VcList | Get-VcRedist -Path C:\Temp\VcRedist | Import-VcMdtApp -Path C:\Temp\VcRedist -MdtPath \\server\deployment
```

Description: Retrieves the list of Visual C++ Redistributables, downloads them to C:\Temp\VcRedist and imports each Redistributable into the MDT deployment share at \\server\deployment.

### EXAMPLE 2

```text
$VcList = Get-VcList -Export All
```

Get-VcRedist -VcList $VcList -Path C:\Temp\VcRedist Import-VcMdtApp -VcList $VcList -Path C:\Temp\VcRedist -MdtPath \\server\deployment -Bundle

Description: Retrieves the list of supported and unsupported Visual C++ Redistributables in the variable $VcList, downloads them to C:\Temp\VcRedist, imports each Redistributable into the MDT deployment share at \\server\deployment and creates an application bundle.

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

### -MdtPath

The local or network path to the MDT deployment share.

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

Specify Applications folder to import the VC Redistributables into.

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

Specifies the release \(or version\) of the redistributables to import into MDT.

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

Specifies the processor architecture to import into MDT. Can be x86 or x64.

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

### -Bundle

Add to create an Application Bundle named 'Visual C++ Redistributables' to simplify installing the Redistributables.

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

### -MdtDrive

Defaults to 'DS001'. PSDrive letter for mounting the MDT deployment share.

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

Defaults to 'Microsoft'.

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

### -BundleName

The name for the Application Bundle. Defaults to 'Microsoft Visual C++ Redistributables'.

```yaml
Type: Object
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: Visual C++ Redistributables
Accept pipeline input: False
Accept wildcard characters: False
```

### -Language

Defaults to 'en-US'.

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

Shows what would happen if the cmdlet runs. The cmdlet is not run.

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

This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about\_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

### System.Array

## NOTES

Name: Import-VcMdtApp Author: Aaron Parker Twitter: @stealthpuppy

## RELATED LINKS

[https://github.com/aaronparker/Install-VisualCRedistributables](https://github.com/aaronparker/Install-VisualCRedistributables)

