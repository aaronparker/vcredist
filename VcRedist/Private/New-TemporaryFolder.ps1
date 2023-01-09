function New-TemporaryFolder {
    <#
        .SYNOPSIS
            Creates a new temporary folder

        .NOTES
            Author: Aaron Parker
            Twitter: @stealthpuppy
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([System.String])]
    param ()

    # Check whether current PowerShell environment matches or is higher than $Version
    try {
        $Folder = "vcredist_$([System.Convert]::ToString((Get-Random -Maximum 65535),16).PadLeft(4,'0')).tmp"
        $T = Join-Path -Path $Env:Temp -ChildPath $Folder
        if ($PSCmdlet.ShouldProcess($T, "New directory.")) {
            $Path = New-Item -Path $T -ItemType "Directory" -ErrorAction "SilentlyContinue"
            Write-Output -InputObject $Path.FullName
        }
    }
    catch {
        throw $_
    }
}
