$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path).Replace(".Tests.", ".")
. "$here\bin\$sut" -Xml .\bin\VisualCRedistributablesSupported.xml -WhatIf
 
Describe "Install-VisualCRedistributables" {
    Mock Invoke-WebRequest {return @{FullName = "A_File.TXT"}}
#    It "attempts to download Visual C++ Redistributables" {
#        .\Install-VisualCRedistributables -Xml .\VisualCRedistributablesSupported.xml | Should Not Throw
#    }
    Context 'Download' {
        It 'Verifies file name for x86' {
            $filename | should be 'vc_redist.x86.exe'
        }
    }
}
