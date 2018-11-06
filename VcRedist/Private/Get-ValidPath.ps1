Function Get-ValidPath {
    <#
        .SYNOPSIS
            Test a file system path and return correct path string.

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy

        .PARAMETER Path
            A directory path that the function will validate and return.
    #>
    [CmdletBinding()]
    [OutputType([String])]
    Param (
        [Parameter(Mandatory = $True, Position = 0, ValueFromPipeline = $True, ValueFromPipelineByPropertyName = $True)]
        [string] $Path
    )
    $output = (Resolve-Path $Path).TrimEnd("\")
    Write-Output $output
}
