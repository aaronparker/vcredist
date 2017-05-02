# Install-VisualCRedistributables.ps1
This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents release and processor architecture.

*NOTE:* some validation of the Redistributables listed in the XML file is required, as not all need to be installed.

This can be run to download and optionally install the Visual C++ (2005 - 2017) Redistributables as specified in the external XML file passed to the script.

The basic structure of the XML file should be as follows (an XSD schema is included in the repository):

    <Redistributables>
    <Platform Architecture="x64" Release="" Install="">
    <Redistributable>
    <Name></Name>
    <URL></URL>
    <Download></Download>
    </Platform>
    <Platform Architecture="x86" Release="" Install="">
    <Redistributable>
    <Name></Name>
    <URL></URL>
    <Download></Download>
    </Redistributable>
    </Platform>
    </Redistributables>

The Redistributables will install in the order specified in the XML file.

## Parameters
### File
The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

Example - Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml"

### Path
Specify a target folder to download the Redistributables to, otherwise use the current folder.

Example - Downloads the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path C:\Redist


### Install
By default the script will only download the Redistributables. This allows you to download the Redistributables for seperate deployment (e.g. in a reference image). Add -Install to install each of the Redistributables as well.

Example - Downloads and installs the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Install:$True

## Results
Here is an example of the end result with the Redistributables installed. Note that 2015 and 2017 are the same major version (14.x), so once 2017 is installed, 2015 will not be displayed in the programs list.

Visual C++ Redistributables 2005 to 2015 installed:

![Visual C++ Redistributables 2005-2015](https://raw.githubusercontent.com/aaronparker/appinstall-scripts/master/Install-VisualCRedistributables/images/2005-2015.PNG "Visual C++ Redistributables 2005-2015")

Visual C++ Redistributables 2005 to 2017 (including 2015) installed:

![Visual C++ Redistributables 2005-2017](https://raw.githubusercontent.com/aaronparker/appinstall-scripts/master/Install-VisualCRedistributables/images/2005-2017.PNG "Visual C++ Redistributables 2005-2017")
