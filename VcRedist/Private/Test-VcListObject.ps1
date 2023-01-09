function Test-VcListObject {
    <#
        .SYNOPSIS
            Returns True is running on PowerShell Core.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER InputObject
            The InputObject to validate RequiredProperties against

        .PARAMETER Version
            An array of the require properties to validate against the InputObject
    #>
    [CmdletBinding()]
    param (
        [Parameter(Position = 0)]
        [System.Management.Automation.PSObject] $InputObject,

        [Parameter(Position = 1)]
        [System.String] $RequiredProperties = @("Architecture", "Install", "Name", "ProductCode", `
                "Release", "SilentInstall", "SilentUninstall", "UninstallKey", "URI", "URL", "Version")
    )

    $Members = Get-Member -InputObject $_ -MemberType "NoteProperty"
    $params = @{
        ReferenceObject  = $RequiredProperties
        DifferenceObject = $Members.Name
        PassThru         = $true
        ErrorAction      = "SilentlyContinue"
    }
    $MissingProperties = Compare-Object @params

    if ($null -ne $missingProperties) {
        return $true
    }
    else {
        $MissingProperties | ForEach-Object {
            throw [System.Management.Automation.ValidationMetadataException] "Property: '$_' missing."
        }
    }

    $_.PSObject.Properties | ForEach-Object {
        if (([System.String]::IsNullOrEmpty($_.Value))) {
            throw [System.Management.Automation.ValidationMetadataException] "Property '$($_.Name)' is null or empty."
        }
    }
}
