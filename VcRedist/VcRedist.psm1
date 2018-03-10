# Get function definition files.
$Functions = @( Get-ChildItem -Path $PSScriptRoot\*.ps1 -ErrorAction SilentlyContinue )

# Dot source the files
ForEach ($import in $Functions) {
    Try {
        . $import.fullname
    }
    Catch {
        Write-Error -Message "Failed to import function $($import.fullname): $_"
    }
}

# Export the Public modules
Export-ModuleMember -Function $Functions.Basename