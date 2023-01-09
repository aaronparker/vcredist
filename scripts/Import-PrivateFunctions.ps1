<#
    .SYNOPSIS
    Imports the private functions for testing.
#>
$projectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
$Private = @( Get-ChildItem -Path $projectRoot\VcRedist\Private\*.ps1 -ErrorAction "SilentlyContinue" )
foreach ($import in $Private) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}
