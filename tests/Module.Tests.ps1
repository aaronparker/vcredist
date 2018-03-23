# AppVeyor Testing
If (Test-Path 'env:APPVEYOR_BUILD_FOLDER') {
    $manifest = "$env:APPVEYOR_BUILD_FOLDER\VcRedist\VcRedist.psd1"
    $module = "$env:APPVEYOR_BUILD_FOLDER\VcRedist\VcRedist.psm1"
}
Else {
    # Local Testing 
    $manifest = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\VcRedist\VcRedist.psd1"
    $module = "$(Split-Path -Parent -Path $MyInvocation.MyCommand.Definition)\..\VcRedist\VcRedist.psm1"
}

Describe 'Module Metadata Validation' {      
    it 'Script fileinfo should be OK' {
        {Test-ModuleManifest $manifest -ErrorAction Stop} | Should Not Throw
    }
        
    it 'Import module should be OK' {
        {Import-Module $module -Force -ErrorAction Stop} | Should Not Throw
    }
}