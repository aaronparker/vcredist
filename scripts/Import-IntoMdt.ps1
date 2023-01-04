<#
    .SYNOPSIS
    Downloads the VcRedists, imports them into an MDT deployment share and creates a bundle.
#>
[CmdletBinding()]
param (
    [Parameter(Mandatory = $False)]
    [System.String] $Path = "C:\Temp\VcRedists",

    [Parameter(Mandatory = $False)]
    [System.String] $DeploymentShare = "\\marty.local\Deployment\Automata"
)

# Download the VcRedists
if (!(Test-Path -Path $Path)) { New-Item -Path $Path -ItemType Directory }
Save-VcRedist -VcList (Get-VcList) -Path $Path

# Add to the deployment share
Import-VcMdtApplication -VcList (Get-VcList) -Path $Path -MdtPath $DeploymentShare -Silent
New-VcMdtBundle -MdtPath $DeploymentShare

$params = @{
    VcList    = (Get-VcList -Release "2022" -Architecture "x64")
    Path      = "E:\Temp\Deploy"
    MdtPath   = "E:\Temp\VcRedist"
    AppFolder = "VcRedists"
    Silent    = $true
    DontHide  = $true
    Force     = $true
    MdtDrive  = "DS099"
    Publisher = "Microsoft"
    Language  = "en-US"
    Verbose   = $true
}
Import-VcMdtApplication @params
