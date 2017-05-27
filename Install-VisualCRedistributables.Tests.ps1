$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\bin\$sut" -Xml .\bin\VisualCRedistributablesSupported.xml -WhatIf
 
Describe "Install-VisualCRedistributables" {
    It 'Downloads the Visual C++ Redistributable' {
        Mock -CommandName 'Invoke-WebRequest' -MockWith {
            Return @{FullName = "vc_redist.x86.exe"}
        }
    }
    Context 'Download' {
        It 'Verifies file name for x86' {
            $filename | should be 'vc_redist.x86.exe'
        }
    }
}
