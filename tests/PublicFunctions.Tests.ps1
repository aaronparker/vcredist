# Pester tests
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $ProjectRoot = $env:APPVEYOR_BUILD_FOLDER
}
Else {
    # Local Testing, get parent folder
    $ProjectRoot = ((Get-Item (Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)).Parent).FullName
}
Import-Module (Join-Path $ProjectRoot "VcRedist") -Force

#region Functions used in tests
Function Test-VcDownloads {
    <#
        .SYNOPSIS
            Tests downloads from Get-VcList are sucessful.
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [PSCustomObject] $VcList,

        [Parameter()]
        [string] $Path
    )
    $Output = $False
    ForEach ($Vc in $VcList) {
        $Folder = Join-Path (Join-Path (Join-Path $(Resolve-Path -Path $Path) $Vc.Release) $Vc.Architecture) $Vc.ShortName
        $Target = Join-Path $Folder $(Split-Path -Path $Vc.Download -Leaf)
        If (Test-Path -Path $Target -PathType Leaf) {
            Write-Verbose "$($Target) - exists."
            $Output = $True
        }
        Else {
            Write-Warning "$($Target) - not found."
            $Output = $False
        }
    }
    Write-Output $Output
}
#endregion

#region Pester tests
Describe 'Get-VcList' {
    Context 'Return built-in manifest' {
        $VcList = Get-VcList
        It 'Given no parameters, it returns supported Visual C++ Redistributables' {
            $VcList | Should -HaveCount 10
        }
        $VcList = Get-VcList -Export All
        It 'Given valid parameter -Export All, it returns all Visual C++ Redistributables' {
            $VcList | Should -HaveCount 34
        }
        $VcList = Get-VcList -Export Supported
        It 'Given valid parameter -Export Supported, it returns all Visual C++ Redistributables' {
            $VcList | Should -HaveCount 14
        }
        $VcList = Get-VcList -Export Unsupported
        It 'Given valid parameter -Export Unsupported, it returns unsupported Visual C++ Redistributables' {
            $VcList | Should -HaveCount 20
        }
    }
    Context 'Validate Get-VcList array properties' {
        $VcList = Get-VcList
        ForEach ($vc in $VcList) {
            It "VcRedist '$($vc.Name)' has expected properties" {
                $vc.Name.Length | Should -BeGreaterThan 0
                $vc.ProductCode.Length | Should -BeGreaterThan 0
                $vc.Version.Length | Should -BeGreaterThan 0
                $vc.URL.Length | Should -BeGreaterThan 0
                $vc.Download.Length | Should -BeGreaterThan 0
                $vc.Release.Length | Should -BeGreaterThan 0
                $vc.Architecture.Length | Should -BeGreaterThan 0
                $vc.ShortName.Length | Should -BeGreaterThan 0
                $vc.Install.Length | Should -BeGreaterThan 0
                $vc.SilentInstall.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context 'Return external manifest' {
        $Json = Join-Path -Path $ProjectRoot -ChildPath "Redists.json"
        Export-VcManifest -Path $Json -Export All
        $VcList = Get-VcList -Path $Json
        It 'Given valid parameter -Path, it returns Visual C++ Redistributables from an external manifest' {
            $VcList | Should -HaveCount 22
        }
    }
    Context 'Test fail scenarios' {
        $Json = Join-Path -Path $ProjectRoot -ChildPath "RedistsFail.json"
        It 'Given an JSON file that does not exist, it should throw an error' {
            { Get-VcList -Path $Json } | Should Throw
        }
        $Json = Join-Path -Path $ProjectRoot -ChildPath "README.MD"
        It 'Given an invalid JSON file, should throw an error on read' {
            { Get-VcList -Path $Json } | Should Throw
        }
    }
}

Describe 'Export-VcManifest' {
    Context 'Export manifest' {
        $Json = Join-Path -Path $ProjectRoot -ChildPath "Redists.json"
        Export-VcManifest -Path $Json
        It 'Given valid parameter -Path, it exports an JSON file' {
            Test-Path -Path $Json | Should -Be $True
        }
    }
    Context 'Export and read manifest' {
        $Json = Join-Path -Path $ProjectRoot -ChildPath "Redists.json"
        Export-VcManifest -Path $Json -Export All
        $VcList = Get-VcList -Path $Json
        It 'Given valid parameter -Path, it exports an JSON file' {
            $VcList | Should -HaveCount 22
        }
    }
    Context 'Test fail scenarios' {
        It 'Given an invalid path, it should throw an error' {
            { Export-VcManifest -Path (Join-Path -Path (Join-Path -Path $ProjectRoot -ChildPath "Temp") -ChildPath "Temp.json") } | Should Throw
        }
    }
}

Describe 'Save-VcRedist' {
    Context 'Download Redistributables' {
        $Path = Join-Path -Path $env:Temp -ChildPath "VcDownload"
        If (!(Test-Path $Path)) { New-Item $Path -ItemType Directory -Force }
        $VcList = Get-VcList
        Save-VcRedist -VcList $VcList -Path $Path -Verbose -ForceWebRequest
        It 'Downloads supported Visual C++ Redistributables' {
            Test-VcDownloads -VcList $VcList -Path $Path | Should -Be $True
        }
    }
    Context "Test pipeline support" {
        It "Should not throw when passed via pipeline with no parameters" {
            New-Item -Path (Join-Path -Path $env:Temp -ChildPath "VcTest") -ItemType Directory | Out-Null
            Push-Location -Path (Join-Path -Path $env:Temp -ChildPath "VcTest")
            Get-VcList | Save-VcRedist -ForceWebRequest | Should -Not Throw
            Pop-Location
        }
    }
    Context 'Test fail scenarios' {
        It 'Given an invalid path, it should throw an error' {
            { Save-VcRedist -Path (Join-Path -Path $ProjectRoot -ChildPath "Temp") } | Should Throw
        }
    }
}

Describe 'Install-VcRedist' {
    Context 'Test exception handling for invalid VcRedist download path' {
        It "Should throw when passed via pipeline with no parameters" {
            Push-Location -Path $env:Temp
            Get-VcList | Install-VcRedist | Should Throw
            Pop-Location
        }
    }
    Context 'Install Redistributables' {
        $VcRedists = Get-VcList
        $Path = Join-Path -Path $env:Temp -ChildPath "VcDownload"
        $Installed = Install-VcRedist -VcList $VcRedists -Path $Path -Silent -Verbose
        ForEach ($Vc in $VcRedists) {
            It "Installed the VcRedist: '$($vc.Name)'" {
                $vc.ProductCode -match $Installed.ProductCode | Should -Not -BeNullOrEmpty
            }
        }
    }
}

Describe 'Get-InstalledVcRedist' {
    Context 'Validate Get-InstalledVcRedist array properties' {
        $VcList = Get-InstalledVcRedist
        ForEach ($vc in $VcList) {
            It "VcRedist '$($vc.Name)' has expected properties" {
                $vc.Name.Length | Should -BeGreaterThan 0
                $vc.Version.Length | Should -BeGreaterThan 0
                $vc.ProductCode.Length | Should -BeGreaterThan 0
                $vc.UninstallString.Length | Should -BeGreaterThan 0
            }
        }
    }
}
#endregion
