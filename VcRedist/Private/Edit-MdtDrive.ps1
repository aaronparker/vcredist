function Edit-MdtDrive {
    <#
        .SYNOPSIS
            Tests for a validate drive letter and adds the : character if required
    #>
    [CmdletBinding(SupportsShouldProcess = $false)]
    param (
        [System.String] $Drive
    )

    switch -Regex ($Drive) {
        "^[a-z|A-Z|0-9]+$" {
            Write-Output -InputObject $("$Drive$(":")").ToUpper()
        }
        "^[a-z|A-Z|0-9]+:$" {
            Write-Output -InputObject $Drive.ToUpper()
        }
        default {
            throw [System.FormatException]::New("The MDT drive letter string represented by $Drive is not valid.")
        }
    }
}
