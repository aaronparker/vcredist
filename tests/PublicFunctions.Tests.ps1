# Pester tests
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing, get parent folder
    $ProjectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
Import-Module $ProjectRoot\VcRedist

# Functions used in tests
Function Test-VcDownloads {
    <#
        .SYNOPSIS
            Tests downloads from Get-VcList are sucessful.
    #>
    [CmdletBinding(SupportsShouldProcess = $False)]
    Param (
        [Parameter()]
        [array]$VcList,

        [Parameter()]
        [string]$Path
    )
    $Output = $False
    ForEach ($Vc in $VcList) {
        $Folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $Vc.Release) $Vc.Architecture) $Vc.ShortName
        $Target = Join-Path $Folder $(Split-Path -Path $Vc.Download -Leaf)
        If (Test-Path -Path $Target -PathType Leaf) {
            Write-Verbose "$($Target) - exists."
            $Output = $True
        } Else {
            Write-Warning "$($Target) - not found."
            $Output = $False
        }
    }
    Write-Output $Output
}

# Pester tests
Describe 'Export-VcXml' {
    Context "Export manifest" {
        It "Given valid parameter -Path, it exports an XML file" {
            $Xml = Join-Path -Path $ProjectRoot -ChildPath "Redists.xml"
            Export-VcXml -Path $Xml -Verbose
            Test-Path -Path $Xml | Should -Be $True
        }
    }
    Context "Export and read manifest" {
        It "Given valid parameter -Path, it exports an XML file" {
            $Xml = Join-Path -Path $ProjectRoot -ChildPath "Redists.xml"
            Export-VcXml -Path $Xml -Export All -Verbose
            $VcList = Get-VcList -Xml $Xml
            $VcList.Count | Should -Be 32
        }
    }
}

Describe 'Get-VcList' {
    Context "Return built-in manifest" {
        It "Given no parameters, it returns supported Visual C++ Redistributables" {
            $VcList = Get-VcList -Verbose
            $VcList.Count | Should -Be 12
        }
        It "Given valid parameter -Export 'All', it returns all Visual C++ Redistributables" {
            $VcList = Get-VcList -Export All -Verbose
            $VcList.Count | Should -Be 32
        }
    }
    Context "Return external manifest" {
        It "Given valid parameter -Xml, it returns Visual C++ Redistributables from an external manifest" {
            $Xml = Join-Path -Path $ProjectRoot -ChildPath "Redists.xml"
            Export-VcXml -Path $Xml -Verbose
            $VcList = Get-VcList -Xml $Xml -Verbose
            $VcList.Count | Should -Be 12
        }
    }
}

Describe 'Get-VcRedist' {
    Context "Download Redistributables" {
        It "Downloads supported Visual C++ Redistributables" {
            $Path = Join-Path -Path $ProjectRoot -ChildPath "VcDownload"
            If (!(Test-Path $Path)) { New-Item $Path -ItemType Directory -Force -Verbose }
            $VcList = Get-VcList
            $Downloads = Get-VcRedist -VcList $VcList -Path $Path -Verbose
            Test-VcDownloads -VcList $Downloads -Path $Path | Should -Be $True
        }
    }
}
