# Code for filtering XML

# Read the specifed XML document
Try {
    [xml]$xmlDocument = Get-Content -Path $Xml -ErrorVariable xmlReadError
}
Catch {
    Throw "Unable to read $Xml. $xmlReadError"
}

##### If -Release and -Architecture are specified, filter the XML content
If ($PSBoundParameters.ContainsKey('Release') -or $PSBoundParameters.ContainsKey('Architecture')) {

    # Create an array that we'll add the filtered XML content to
    $xmlContent = @()

    # If -Release alone is specified, filter on platform
    If ($PSBoundParameters.ContainsKey('Release') -and (!($PSBoundParameters.ContainsKey('Architecture')))) {
        ForEach ($rel in $Release) {
            $xmlContent += (Select-Xml -XPath "/Redistributables/Platform[@Release='$rel']" -Xml $xmlDocument).Node
        }
    }
    # If -Architecture alone is specified, filter on architecture
    If ($PSBoundParameters.ContainsKey('Architecture') -and (!($PSBoundParameters.ContainsKey('Release')))) {
        ForEach ($arch in $Architecture) {
            $xmlContent += (Select-Xml -XPath "/Redistributables/Platform[@Architecture='$arch']" -Xml $xmlDocument).Node
        }
    }
    # If -Architecture and -Release are specified, filter on both
    If ($PSBoundParameters.ContainsKey('Architecture') -and $PSBoundParameters.ContainsKey('Release')) {
        ForEach ($rel in $Release) {
            ForEach ($arch in $Architecture) {
                $xmlContent += (Select-Xml -XPath "/Redistributables/Platform[@Release='$rel'][@Architecture='$arch']" -Xml $xmlDocument).Node
            }
        }
    }
}
Else {
        
    # Pass the XML document contents to $xmlContent, so that we don't need to provide
    # different logic if -Platform and -Architectures are not supplied
    $xmlContent = @()
    $xmlContent += (Select-Xml -XPath "/Redistributables/Platform" -Xml $xmlDocument).Node
}
