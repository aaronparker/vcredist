<#
    .SYNOPSIS
        VcRedist script to initiate the module
#>
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "Variable VcManifest is used internally by the module.")]
[CmdletBinding()]
param ()

#region Get public and private function definition files
$PublicRoot = Join-Path -Path $PSScriptRoot -ChildPath "Public"
$PrivateRoot = Join-Path -Path $PSScriptRoot -ChildPath "Private"
$Public = @( Get-ChildItem -Path (Join-Path $PublicRoot "*.ps1") -ErrorAction "SilentlyContinue" )
$Private = @( Get-ChildItem -Path (Join-Path $PrivateRoot "*.ps1") -ErrorAction "SilentlyContinue" )

# Dot source the files
foreach ($import in @($Public + $Private)) {
    try {
        . $import.FullName
    }
    catch {
        Write-Warning -Message "Failed to import function $($import.FullName)."
        throw $_
    }
}

# Export the public functions, aliases and variables
[System.String] $VcManifest = Join-Path -Path $PSScriptRoot -ChildPath "VisualCRedistributables.json"
Export-ModuleMember -Function $Public.Basename -Alias * -Variable "VcManifest"
