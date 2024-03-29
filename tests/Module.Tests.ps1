<#
    .SYNOPSIS
        Main Pester function tests.
#>
[CmdletBinding()]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "", Justification = "This OK for the tests files.")]
[Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidUsingWriteHost", "", Justification = "Outputs to log host.")]
param ()

BeforeDiscovery {
}

Describe -Name "General module validation" {
    Context "Validation" {
        BeforeAll {
            $scripts = Get-ChildItem -Path "$env:GITHUB_WORKSPACE\VcRedist" -Recurse -Include "*.ps1", "*.psm1", "*.psd1"

            # TestCases are splatted to the script so we need hashtables
            $testCase = $scripts | ForEach-Object { @{file = $_ } }
        }

        It "Script <file> should exist" -TestCases $testCase {
            param($file)
            $file.FullName | Should -Exist
        }

        It "Script <file> should be valid PowerShell" -TestCases $testCase {
            param($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($contents, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    }
}

Describe -Name "function validation" {
    Context "Validation" {
        BeforeEach {
            $scripts = Get-ChildItem -Path "$env:GITHUB_WORKSPACE\VcRedist" -Recurse -Include "*.ps1"
            $testCase = $scripts | ForEach-Object { @{file = $_ } }
        }

        It "Script <file> should only contain one function" -TestCases $testCase {
            param($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $test = $describes.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
            $test.Count | Should -Be 1
        }

        It "<file> should match function name" -TestCases $testCase {
            param($file)
            $contents = Get-Content -Path $file.FullName -ErrorAction "Stop"
            $describes = [Management.Automation.Language.Parser]::ParseInput($contents, [ref]$null, [ref]$null)
            $test = $describes.FindAll( { $args[0] -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)
            $test[0].name | Should -Match $file.Name
        }
    }
}

# Test module and manifest
Describe -Name "Module Metadata validation" {
    Context "File info" {
        BeforeAll {
        }

        It "Script fileinfo should be OK" {
            { Test-ModuleManifest -Path "$env:GITHUB_WORKSPACE\VcRedist\VcRedist.psd1" -ErrorAction "Stop" } | Should -Not -Throw
        }

        It "Import module should be OK" {
            { Import-Module "$env:GITHUB_WORKSPACE\VcRedist" -Force -ErrorAction "Stop" } | Should -Not -Throw
        }
    }
}
