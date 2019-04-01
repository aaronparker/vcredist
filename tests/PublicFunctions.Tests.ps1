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
Describe 'Get-VcList' {
    Context "Return built-in manifest" {
        It "Given no parameters, it returns supported Visual C++ Redistributables" {
            $VcList = Get-VcList
            $VcList.Count | Should -Be 14
        }
        It "Given valid parameter -Export All, it returns all Visual C++ Redistributables" {
            $VcList = Get-VcList -Export All
            $VcList.Count | Should -Be 34
        }
        It "Given valid parameter -Export Unsupported, it returns unsupported Visual C++ Redistributables" {
            $VcList = Get-VcList -Export All
            $VcList.Count | Should -Be 20
        }
    }
    Context "Return external manifest" {
        It "Given valid parameter -Path, it returns Visual C++ Redistributables from an external manifest" {
            $Json = Join-Path -Path $ProjectRoot -ChildPath "Redists.json"
            Export-VcManifest -Path $Json
            $VcList = Get-VcList -Path $Json
            $VcList.Count | Should -Be 14
        }
    }
    Context "Test fail scenarios" {
        It "Given an JSON file that does not exist, it should throw an error" {
            $Json = Join-Path -Path $ProjectRoot -ChildPath "RedistsFail.json"
            { Get-VcList -Path $Json } | Should Throw
        }
        It "Given an invalid JSON file, should throw an error on read" {
            $Json = Join-Path -Path $ProjectRoot -ChildPath "README.MD"
            { Get-VcList -Path $Json } | Should Throw
        }
    }
}

Describe 'Export-VcManifest' {
    Context "Export manifest" {
        It "Given valid parameter -Path, it exports an JSON file" {
            $Json = Join-Path -Path $ProjectRoot -ChildPath "Redists.json"
            Export-VcManifest -Path $Json
            Test-Path -Path $Json | Should -Be $True
        }
    }
    Context "Export and read manifest" {
        It "Given valid parameter -Path, it exports an JSON file" {
            $Json = Join-Path -Path $ProjectRoot -ChildPath "Redists.json"
            Export-VcManifest -Path $Json -Export All
            $VcList = Get-VcList -Path $Json
            $VcList.Count | Should -Be 34
        }
    }
    Context "Test fail scenarios" {
        It "Given an invalid path, it should throw an error" {
            { Export-VcManifest -Path (Join-Path (Join-Path $ProjectRoot "Temp") "Temp.json") } | Should Throw
        }
    }
}

Describe 'Get-VcRedist' {
    Context "Download Redistributables" {
        It "Downloads supported Visual C++ Redistributables" {
            $Path = Join-Path -Path $ProjectRoot -ChildPath "VcDownload"
            If (!(Test-Path $Path)) { New-Item $Path -ItemType Directory -Force }
            $VcList = Get-VcList
            $Downloads = Get-VcRedist -VcList $VcList -Path $Path
            Test-VcDownloads -VcList $Downloads -Path $Path | Should -Be $True
        }
    }
    Context "Test fail scenarios" {
        It "Given an invalid path, it should throw an error" {
            { Get-VcRedist -Path (Join-Path $ProjectRoot "Temp") } | Should Throw
        }
    }
}
