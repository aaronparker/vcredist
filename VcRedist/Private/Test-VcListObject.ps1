function Test-VcListObject {
    <#
        .SYNOPSIS
            Returns True if running on PowerShell Core.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER InputObject
            The InputObject to validate RequiredProperties against

        .PARAMETER Version
            An array of the require properties to validate against the InputObject
    #>
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Pass a VcList object from Get-VcList.")]
        [ValidateNotNullOrEmpty()]
        [System.Management.Automation.PSObject] $VcList,

        [Parameter(Position = 1)]
        [System.String[]] $RequiredProperties = @("Architecture", "Install", "Name", "ProductCode", `
                "Release", "SilentInstall", "SilentUninstall", "UninstallKey", "URI", "URL", "Version", "Path")
    )

    process {
        foreach ($Item in $VcList) {
            $Members = Get-Member -InputObject $Item -MemberType "NoteProperty"
            $params = @{
                ReferenceObject  = $RequiredProperties
                DifferenceObject = $Members.Name
                PassThru         = $true
                ErrorAction      = "Stop"
            }
            $MissingProperties = Compare-Object @params

            if (-not($missingProperties)) {
                $Result = $true
            }
            else {
                $MissingProperties | ForEach-Object {
                    throw [System.Management.Automation.ValidationMetadataException] "Property: '$_' missing."
                }
            }

            $Item.PSObject.Properties | ForEach-Object {
                if (([System.String]::IsNullOrEmpty($_.Value))) {
                    throw [System.Management.Automation.ValidationMetadataException] "Property '$($_.Name)' is null or empty."
                }
            }
        }

        # Return true if all is good with the object
        return $Result
    }
}
