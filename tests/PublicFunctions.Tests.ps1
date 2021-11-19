<#
    .SYNOPSIS
        Public Pester function tests.
#>
[CmdletBinding()]
#[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUserDeclaredVarsMoreThanAssignments')]
Param ()

#region Functions used in tests
Function Test-VcDownloads {
    <#
        .SYNOPSIS
            Tests downloads from Get-VcList are successful.
    #>
    [CmdletBinding()]
    Param (
        [Parameter()]
        [PSCustomObject] $VcList,

        [Parameter()]
        [string] $Path
    )
    $Output = $False
    ForEach ($VcRedist in $VcList) {
        $folder = [System.IO.Path]::Combine((Resolve-Path -Path $Path), $VcRedist.Release, $VcRedist.Version, $VcRedist.Architecture)
        $Target = [System.IO.Path]::Combine($Folder, $(Split-Path -Path $VcRedist.Download -Leaf))
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

# Target download directory
If (Test-Path -Path env:Temp -ErrorAction "SilentlyContinue") {
    $downloadDir = $env:Temp
}
Else {
    $downloadDir = $env:TMPDIR
}
Write-Host -ForegroundColor "Cyan" "`tDownload dir: $downloadDir."

# VcRedist manifest counts
$TestReleases = @("2012", "2013", "2015", "2017", "2019", "2022")
$VcCount = @{
    "Default"     = 6
    "Supported"   = 12
    "Unsupported" = 24
    "All"         = 36
}

#region Function tests
Describe 'Get-VcList' -Tag "Get" {
    Context 'Return built-in manifest' {
        It 'Given no parameters, it returns supported Visual C++ Redistributables' {
            $VcList = Get-VcList
            $VcList | Should -HaveCount $VcCount.Default
        }
        It 'Given valid parameter -Export All, it returns all Visual C++ Redistributables' {
            $VcList = Get-VcList -Export "All"
            $VcList | Should -HaveCount $VcCount.All
        }
        It 'Given valid parameter -Export Supported, it returns all Visual C++ Redistributables' {
            $VcList = Get-VcList -Export "Supported"
            $VcList | Should -HaveCount $VcCount.Supported
        }
        It 'Given valid parameter -Export Unsupported, it returns unsupported Visual C++ Redistributables' {
            $VcList = Get-VcList -Export "Unsupported"
            $VcList | Should -HaveCount $VcCount.Unsupported
        }
    }
    Context 'Validate Get-VcList array properties' {
        $VcList = Get-VcList -Release $TestReleases
        ForEach ($VcRedist in $VcList) {
            It "VcRedist [$($VcRedist.Name), $($VcRedist.Architecture)] has expected properties" {
                $VcRedist.Name.Length | Should -BeGreaterThan 0
                $VcRedist.ProductCode.Length | Should -BeGreaterThan 0
                $VcRedist.Version.Length | Should -BeGreaterThan 0
                $VcRedist.URL.Length | Should -BeGreaterThan 0
                $VcRedist.Download.Length | Should -BeGreaterThan 0
                $VcRedist.Release.Length | Should -BeGreaterThan 0
                $VcRedist.Architecture.Length | Should -BeGreaterThan 0
                $VcRedist.Install.Length | Should -BeGreaterThan 0
                $VcRedist.SilentInstall.Length | Should -BeGreaterThan 0
                $VcRedist.SilentUninstall.Length | Should -BeGreaterThan 0
                $VcRedist.UninstallKey.Length | Should -BeGreaterThan 0
            }
        }
    }
    Context 'Return external manifest' {
        It 'Given valid parameter -Path, it returns Visual C++ Redistributables from an external manifest' {
            $Json = [System.IO.Path]::Combine($ProjectRoot, "Redists.json")
            Export-VcManifest -Path $Json
            $VcList = Get-VcList -Path $Json
            $VcList.Count | Should -BeGreaterOrEqual $VcCount.Default
        }
    }
    Context 'Test fail scenarios' {
        It 'Given an JSON file that does not exist, it should throw an error' {
            $Json = [System.IO.Path]::Combine($ProjectRoot, "RedistsFail.json")
            { Get-VcList -Path $Json } | Should Throw
        }
        It 'Given an invalid JSON file, should throw an error on read' {
            $Json = [System.IO.Path]::Combine($ProjectRoot, "README.MD")
            { Get-VcList -Path $Json } | Should Throw
        }
    }
}

Describe 'Export-VcManifest' -Tag "Export" {
    Context 'Export manifest' {
        It 'Given valid parameter -Path, it exports an JSON file' {
            $Json = [System.IO.Path]::Combine($ProjectRoot, "Redists.json")
            Export-VcManifest -Path $Json
            Test-Path -Path $Json | Should -Be $True
        }
    }
    Context 'Export and read manifest' {
        It 'Given valid parameter -Path, it exports an JSON file' {
            $Json = [System.IO.Path]::Combine($ProjectRoot, "Redists.json")
            Export-VcManifest -Path $Json
            $VcList = Get-VcList -Path $Json
            $VcList.Count | Should -BeGreaterOrEqual $VcCount.Default
        }
    }
    Context 'Test fail scenarios' {
        It 'Given an invalid path, it should throw an error' {
            { Export-VcManifest -Path [System.IO.Path]::Combine($ProjectRoot, "Temp", "Temp.json") } | Should Throw
        }
    }
}

Describe 'Save-VcRedist' -Tag "Save" {
    Context 'Download Redistributables' {
        It 'Downloads supported Visual C++ Redistributables' {
            If (Test-Path -Path $downloadDir -ErrorAction "SilentlyContinue") {
                $Path = [System.IO.Path]::Combine($downloadDir, "VcDownload")
                If (!(Test-Path $Path)) { New-Item $Path -ItemType Directory -Force > $Null }
                $VcList = Get-VcList -Release $TestReleases
                Write-Host "`tDownloading VcRedists." -ForegroundColor "Cyan"
                Save-VcRedist -VcList $VcList -Path $Path
                Test-VcDownloads -VcList $VcList -Path $Path | Should -Be $True
            }
            Else {
                Write-Warning -Message "$downloadDir does not exist."
            }
        }
        It 'Returns an expected object type to the pipeline' {
            $Path = [System.IO.Path]::Combine($downloadDir, "VcDownload")
            If (Test-Path -Path $Path) { Remove-Item -Path $Path -Recurse -Force }
            New-Item -Path $Path -ItemType Directory -Force > $Null
            
            Write-Host "`tDownloading VcRedists." -ForegroundColor "Cyan"
            $VcList = Get-VcList -Release $TestReleases
            $DownloadedRedists = Save-VcRedist -VcList $VcList -Path $Path
            $DownloadedRedists | Should -BeOfType PSCustomObject
        }
    }
    Context "Test pipeline support" {
        It "Should not throw when passed via pipeline with no parameters" {
            If (Test-Path -Path $downloadDir -ErrorAction "SilentlyContinue") {
                New-Item -Path ([System.IO.Path]::Combine($downloadDir, "VcTest")) -ItemType Directory -ErrorAction "SilentlyContinue" > $Null
                Push-Location -Path ([System.IO.Path]::Combine($downloadDir, "VcTest"))
                Write-Host "`tDownloading VcRedists." -ForegroundColor "Cyan"
                { Get-VcList -Release $TestReleases | Save-VcRedist } | Should -Not -Throw
                Pop-Location
            }
            Else {
                Write-Warning -Message "$downloadDir does not exist."
            }
        }
    }
    Context 'Test fail scenarios' {
        It 'Given an invalid path, it should throw an error' {
            { Save-VcRedist -Path ([System.IO.Path]::Combine($ProjectRoot, "Temp")) } | Should -Throw
        }
    }
}

# Run the following tests only if we're running on Windows
If (($Null -eq $PSVersionTable.OS) -or ($PSVersionTable.OS -like "*Windows*")) {

    Describe 'Install-VcRedist' -Tag "Install" {
        Context 'Install Redistributables' {
            If (Test-Path -Path $downloadDir -ErrorAction "SilentlyContinue") {
                $VcRedists = Get-VcList
                $Path = [System.IO.Path]::Combine($downloadDir, "VcDownload")
                Write-Host "`tInstalling VcRedists." -ForegroundColor "Cyan"
                $Installed = Install-VcRedist -VcList $VcRedists -Path $Path -Silent
                ForEach ($VcRedist in $VcRedists) {
                    It "Installed the VcRedist: '$($VcRedist.Name)'" {
                        $VcRedist.ProductCode -match $Installed.ProductCode | Should -Not -BeNullOrEmpty
                    }
                }
            }
            Else {
                Write-Warning -Message "$downloadDir does not exist."
            }
        }
    }

    Describe 'Get-InstalledVcRedist' -Tag "Install" {
        Context 'Validate Get-InstalledVcRedist array properties' {
            $VcList = Get-InstalledVcRedist
            ForEach ($VcRedist in $VcList) {
                It "VcRedist '$($VcRedist.Name)' has expected properties" {
                    $VcRedist.Name.Length | Should -BeGreaterThan 0
                    $VcRedist.Version.Length | Should -BeGreaterThan 0
                    $VcRedist.ProductCode.Length | Should -BeGreaterThan 0
                    $VcRedist.UninstallString.Length | Should -BeGreaterThan 0
                }
            }
        }
    }

    Describe 'Uninstall-VcRedist' -Tag "Uninstall" {
        Context 'Uninstall VcRedists' {
            Write-Host "`tUninstalling VcRedists." -ForegroundColor "Cyan"
            ForEach ($Release in $TestReleases) {
                Write-Host "`tUninstall: VcRedist $Release." -ForegroundColor "Cyan"
                { Uninstall-VcRedist -Release $Release -Confirm:$False } | Should -Not -Throw
            }
        }
    }

    #region Manifest test
    # Get an array of VcRedists from the current manifest and the installed VcRedists
    Write-Host -ForegroundColor "Cyan" "`tGetting manifest from: $VcManifest."
    $CurrentManifest = Get-Content -Path $VcManifest | ConvertFrom-Json

    $ValidateReleases = @("2017", "2019", "2022")
    $UpdateManifest = $False

    Describe 'VcRedist manifest tests' -Tag "Manifest" {
        Context 'Compare manifest version against installed version' {

            # Filter the VcRedists for the target version and compare against what has been installed
            ForEach ($Release in $ValidateReleases) {

                Write-Host "`tInstalling VcRedist $Release." -ForegroundColor "Cyan"
                Install-VcRedist -VcList (Get-VcList -Release $Release) -Path $([System.IO.Path]::Combine($downloadDir, "VcDownload")) -Silent
                $InstalledVcRedists = Get-InstalledVcRedist

                ForEach ($ManifestVcRedist in ($CurrentManifest.Supported | Where-Object { $_.Release -eq $Release })) {
                    $InstalledItem = $InstalledVcRedists | Where-Object { ($_.Release -eq $ManifestVcRedist.Release) -and ($_.Architecture -eq $ManifestVcRedist.Architecture) }
                    If ($InstalledItem.Version -gt $ManifestVcRedist.Version) { $UpdateManifest = $True }

                    # If the manifest version of the VcRedist is lower than the installed version, the manifest is out of date
                    It "$($ManifestVcRedist.Release) $($ManifestVcRedist.Architecture) version should be current" {
                        Write-Host -ForegroundColor "Cyan" "`tComparing installed: $($InstalledItem.Version). Against manifest: $($ManifestVcRedist.Version)."
                        $InstalledItem.Version -gt $ManifestVcRedist.Version | Should -Be $False
                    }
                }
            }
        }
    }
    #endregion

    If ($UpdateManifest -eq $True) {
        # Call update manifest script
        $params = @{
            Release = $ValidateReleases
            Path    = $([System.IO.Path]::Combine($downloadDir, "VcDownload"))
        }
        . $ProjectRoot\ci\Update-Manifest.ps1 @params
    }
}
#endregion
