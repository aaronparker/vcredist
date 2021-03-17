Function Get-InstalledSoftware {
    <#
        .SYNOPSIS
            Retrieves a list of all software installed

        .EXAMPLE
            Get-InstalledSoftware
            
            This example retrieves all software installed on the local computer
            
        .PARAMETER Name
            The software title you"d like to limit the query to.

        .NOTES
            Author: Adam Bertram
            URL: https://4sysops.com/archives/find-the-product-guid-of-installed-software-with-powershell/
    #>
    [OutputType([System.Management.Automation.PSObject])]
    [CmdletBinding()]
    Param (
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [System.String] $Name
    )

    $UninstallKeys = "HKLM:\Software\Microsoft\Windows\CurrentVersion\Uninstall", "HKLM:\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall"
    $null = New-PSDrive -Name "HKU" -PSProvider "Registry" -Root "Registry::HKEY_USERS"
    $UninstallKeys += Get-ChildItem -Path "HKU:" -ErrorAction "SilentlyContinue" | Where-Object { $_.Name -match "S-\d-\d+-(\d+-){1,14}\d+$" } | `
        ForEach-Object { "HKU:\$($_.PSChildName)\Software\Microsoft\Windows\CurrentVersion\Uninstall" }
    If (-not $UninstallKeys) {
        Write-Verbose -Message "$($MyInvocation.MyCommand): No software registry keys found."
    }
    Else {
        ForEach ($UninstallKey in $UninstallKeys) {
            If ($PSBoundParameters.ContainsKey("Name")) {
                $WhereBlock = { ($_.PSChildName -match "^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$") -and ($_.GetValue("DisplayName") -like "$Name*") }
            }
            Else {
                $WhereBlock = { ($_.PSChildName -match "^{[A-Z0-9]{8}-([A-Z0-9]{4}-){3}[A-Z0-9]{12}}$") -and ($_.GetValue("DisplayName")) }
            }
            $gciParams = @{
                Path        = $UninstallKey
                ErrorAction = "SilentlyContinue"
            }
            $selectProperties = @(
                @{n = "Publisher"; e = { $_.GetValue("Publisher") } },
                @{n = "Name"; e = { $_.GetValue("DisplayName") } },
                @{n = "Version"; e = { $_.GetValue("DisplayVersion") } },
                @{n = "ProductCode"; e = { $_.PSChildName } },
                @{n = "BundleCachePath"; e = { $_.GetValue("BundleCachePath") } },
                @{n = "Architecture"; e = { If ($_.GetValue("DisplayName") -like "*x64*") { "x64" } Else { "x86" } } },
                @{n = "Release"; e = { If ($_.GetValue("DisplayName") -match [RegEx]"(\d{4})\s+") { $matches[0].Trim(" ") } } },
                @{n = "UninstallString"; e = { $_.GetValue("UninstallString") } },
                @{n = "QuietUninstallString"; e = { $_.GetValue("QuietUninstallString") } },
                @{n = "UninstallKey"; e = { $UninstallKey } }
            )
            Get-ChildItem @gciParams | Where-Object $WhereBlock | Select-Object -Property $selectProperties
        }
    }
}
