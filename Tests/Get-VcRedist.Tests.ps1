
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
        $Target = "$($(Get-Item -Path $Path).FullName)\$($Vc.Release)\$($Vc.Architecture)\$($Vc.ShortName)"
        If (Test-Path -Path "$Target\$(Split-Path -Path $Vc.Download -Leaf)" -PathType Leaf) {
            Write-Verbose "$Target\$(Split-Path -Path $Vc.Download -Leaf) - exists."
            $Output = $True
        } Else {
            Write-Warning "$Target\$(Split-Path -Path $Vc.Download -Leaf) - not found."
            $Output = $False
        }
    }
    Write-Output $Output
}

# Pester tests
Describe 'Get-VcRedist' {
    Context "Download Redistributables" {
        It "Downloads supported Visual C++ Redistributables" {
            $Path = ".\VcDownload"
            If (!(Test-Path $Path)) { New-Item $Path -ItemType Directory -Force -Verbose }
            $VcList = Get-VcList
            $Downloads = Get-VcRedist -VcList $VcList -Path $Path -Verbose
            Test-VcDownloads -VcList $Downloads -Path $Path | Should -Be $True
        }
    }
}