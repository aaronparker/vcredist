Describe 'Export-VcXml' {
    Context "Export manifest" {
        It "Given valid parameter -Path, it exports an XML file" {
            $Xml = "$($pwd)\Redists.xml"
            Export-VcXml -Path $Xml -Verbose
            Test-Path -Path $Xml | Should -Be $True
        }
    }
    Context "Export and read manifest" {
        It "Given valid parameter -Path, it exports an XML file" {
            $Xml = "$($pwd)\Redists.xml"
            Export-VcXml -Path $Xml -Export All -Verbose
            $VcList = Get-VcList -Xml $Xml
            $VcList.Count | Should -Be 32
        }
    }
}