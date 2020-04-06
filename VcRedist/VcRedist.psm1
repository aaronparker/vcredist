<#
    .SYNOPSIS
        VcRedist script to initiate the module
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
[CmdletBinding()]
Param ()

#region Get public and private function definition files
$publicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$privateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$public = @( Get-ChildItem -Path (Join-Path $publicRoot "*.ps1") -ErrorAction SilentlyContinue )
$private = @( Get-ChildItem -Path (Join-Path $privateRoot "*.ps1") -ErrorAction SilentlyContinue )

# Dot source the files
ForEach ($import in @($public + $private)) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Warning -Message "Failed to import function $($import.fullname)."
        Throw $_.Exception.Message
    }
}

# Export the public functions, aliases and variables
[System.String] $VcManifest = Join-Path -Path $PSScriptRoot -ChildPath "VisualCRedistributables.json"
Export-ModuleMember -Function $public.Basename -Alias * -Variable VcManifest
