[Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingConvertToSecureStringWithPlainText', '')]
[CmdletBinding()]
param()

BeforeAll {
    # Import module
    $ProjectRoot = $(Split-Path -Parent $(Split-Path -Parent $PSScriptRoot))
    $ModulePath = $(Join-Path $ProjectRoot "VcRedist")
    $ManifestPath = $(Join-Path $ModulePath "VcRedist.psd1")
    Import-Module $ManifestPath -Force
}

Describe "New-IntuneWin32AppDetectionRule" {
    BeforeAll {
        # Mock the required functions
        Mock -CommandName New-IntuneWin32AppDetectionRuleMSI -MockWith { return @{ Type = "MSI" } }
        Mock -CommandName New-IntuneWin32AppDetectionRuleScript -MockWith { return @{ Type = "Script" } }
        Mock -CommandName New-IntuneWin32AppDetectionRuleRegistry -MockWith { return @{ Type = "Registry" } }
        Mock -CommandName New-IntuneWin32AppDetectionRuleFile -MockWith { return @{ Type = "File" } }

        # Create test data
        $TestVcList = @(
            @{
                Architecture = "x64"
                Version = "14.32.31332.0"
                ProductCode = "{12345678-1234-1234-1234-123456789012}"
                DetectionFile = "C:\Windows\System32\vcruntime140.dll"
                UninstallKey = "64"
            }
        )

        $TestIntuneManifest = @{
            DetectionRule = @(
                @{
                    Type = "MSI"
                    ProductCode = "{12345678-1234-1234-1234-123456789012}"
                    ProductVersionOperator = "greaterThanOrEqual"
                    ProductVersion = "14.32.31332.0"
                },
                @{
                    Type = "Registry"
                    DetectionMethod = "Existence"
                    KeyPath = "HKLM:\SOFTWARE\Microsoft\VisualStudio\14.0\VC\Runtimes\x64\{guid}"
                    ValueName = "Version"
                },
                @{
                    Type = "File"
                    DetectionMethod = "Version"
                    Path = "C:\Windows\System32"
                    FileOrFolder = "vcruntime140.dll"
                    Operator = "greaterThanOrEqual"
                }
            )
        }
    }

    Context "Parameter validation" {
        It "Should throw when VcList is null" {
            { New-IntuneWin32AppDetectionRule -VcList $null -IntuneManifest $TestIntuneManifest } | 
            Should -Throw
        }

        It "Should throw when IntuneManifest is null" {
            { New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $null } | 
            Should -Throw
        }
    }

    Context "Detection rule creation" {
        It "Should create MSI detection rule" {
            $result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $TestIntuneManifest
            Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleMSI -Times 1
            $result | Should -Not -BeNullOrEmpty
            $result[0].Type | Should -Be "MSI"
        }

        It "Should create Registry detection rule" {
            $result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $TestIntuneManifest
            Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleRegistry -Times 1
            $result | Should -Not -BeNullOrEmpty
            $result[1].Type | Should -Be "Registry"
        }

        It "Should create File detection rule" {
            $result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $TestIntuneManifest
            Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleFile -Times 1
            $result | Should -Not -BeNullOrEmpty
            $result[2].Type | Should -Be "File"
        }

        It "Should handle multiple VcRedist items" {
            $multipleVcList = @($TestVcList[0], $TestVcList[0])
            $result = New-IntuneWin32AppDetectionRule -VcList $multipleVcList -IntuneManifest $TestIntuneManifest
            Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleMSI -Times 2
            $result.Count | Should -Be 6  # 2 VcRedist items * 3 detection rules each
        }
    }

    Context "Registry detection rules" {
        BeforeAll {
            $registryManifest = @{
                DetectionRule = @(
                    @{
                        Type = "Registry"
                        DetectionMethod = "Existence"
                        KeyPath = "HKLM:\SOFTWARE\Test\{guid}"
                        ValueName = "Version"
                    },
                    @{
                        Type = "Registry"
                        DetectionMethod = "VersionComparison"
                        KeyPath = "HKLM:\SOFTWARE\Test"
                        ValueName = "Version"
                        Operator = "greaterThanOrEqual"
                        Value = "14.0"
                    },
                    @{
                        Type = "Registry"
                        DetectionMethod = "StringComparison"
                        KeyPath = "HKLM:\SOFTWARE\Test"
                        ValueName = "Edition"
                        Operator = "equal"
                        Value = "Enterprise"
                    },
                    @{
                        Type = "Registry"
                        DetectionMethod = "IntegerComparison"
                        KeyPath = "HKLM:\SOFTWARE\Test"
                        ValueName = "BuildNumber"
                        Operator = "greaterThan"
                        Value = "10000"
                    }
                )
            }
        }

        It "Should create all types of registry detection rules" {
            $result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $registryManifest
            Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleRegistry -Times 4
            $result.Count | Should -Be 4
        }
    }

    Context "File detection rules" {
        BeforeAll {
            $fileManifest = @{
                DetectionRule = @(
                    @{
                        Type = "File"
                        DetectionMethod = "Existence"
                        Path = "C:\Test"
                        FileOrFolder = "test.dll"
                        DetectionType = "exists"
                    },
                    @{
                        Type = "File"
                        DetectionMethod = "DateModified"
                        Path = "C:\Test"
                        FileOrFolder = "test.dll"
                        Operator = "greaterThan"
                        DateTimeValue = "2025-01-01"
                    },
                    @{
                        Type = "File"
                        DetectionMethod = "DateCreated"
                        Path = "C:\Test"
                        FileOrFolder = "test.dll"
                        Operator = "lessThan"
                        DateTimeValue = "2025-12-31"
                    },
                    @{
                        Type = "File"
                        DetectionMethod = "Size"
                        Path = "C:\Test"
                        FileOrFolder = "test.dll"
                        Operator = "greaterThan"
                        SizeInMBValue = "1"
                    }
                )
            }
        }

        It "Should create all types of file detection rules" {
            $result = New-IntuneWin32AppDetectionRule -VcList $TestVcList -IntuneManifest $fileManifest
            Should -Invoke -CommandName New-IntuneWin32AppDetectionRuleFile -Times 4
            $result.Count | Should -Be 4
        }
    }
}
