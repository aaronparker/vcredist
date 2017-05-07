# Install-VisualCRedistributables.ps1
Deploying the Microsoft Visual C++ Redistributables in any complex desktop environment kinda sucks because there are so many versions that might be required. I got tired of updating my MDT deployment share with the redistributables manually, so wrote a script to automate the process.

This script will download the Visual C++ Redistributables listed in an external XML file into a folder structure that represents major release, processor architecture and update release (e.g. SP1, MFC, ATL etc.). The script defines the available redistributables and can be updated with each release with no changes made to the script.

*NOTE:* some validation of the Redistributables listed in the XML file is required, as not all may need to be installed in your environment.

This can be run to download and optionally install the Visual C++ (2005 - 2017) Redistributables as specified in the external XML file passed to the script.

The basic structure of the XML file should be as follows (an XSD schema is included in the repository):

    <Redistributables>
    <Platform Architecture="x64" Release="" Install="">
    <Redistributable>
    <Name></Name>
    <ShortName></ShortName>
    <URL></URL>
    <ProductCode></ProductCode>
    <Download></Download>
    </Platform>
    <Platform Architecture="x86" Release="" Install="">
    <Redistributable>
    <Name></Name>
    <ShortName></ShortName>
    <URL></URL>
    <ProductCode></ProductCode>
    <Download></Download>
    </Redistributable>
    </Platform>
    </Redistributables>

Each major version of the redistributables is grouped by <Platform> that defines the major release, processor architecture and install arguments passed to the installer.

The properties of each redistributable are defined in each <Redistributable> node:
- Name - the name of the redistributable as displayed on the download page. Not used in the script, but useful for reading the XML file.
- ShortName - the redistributable will be downloaded to Release\Architecture\ShortName
- URL - this is the URL to the page at microsoft.com/downloads. Not used in the script, but useful for referencing the download as needed
- ProductCode - this is the MSI Product Code for the specified VC++ App that will be used to import the package into Configuration Manager
- Download - this is the URL to the installer so that the script can download each redistributable

## Parameters
### Xml
The XML file that contains the details about the Visual C++ Redistributables. This must be in the expected format.

Example: download the Visual C++ Redistributables listed in VisualCRedistributables.xml to the current folder.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml"

### Path
Specify a target folder to download the Redistributables to, otherwise use the current folder.

Example: download the Visual C++ Redistributables listed in VisualCRedistributables.xml to C:\Redist.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path C:\Redist


### Install
By default the script will only download the Redistributables. This allows you to download the Redistributables for seperate deployment (e.g. in a reference image). Add -Install to install each of the Redistributables as well.

Example: download (to the current folder) and install the Visual C++ Redistributables listed in VisualCRedistributables.xml.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Install

The Redistributables will installed in the order specified in the XML file.

### CreateCMApp
This Switch Parameter allows for automatic creation of Application Containers in Configuration Manager with a single Deployment Type containing the downloaded EXE file.

### SMSSiteCode
Specify the Configuration Manager SIte you would like the application packages to. If this parameter is in use you will need to select a UNC Path for the download. Otherwise the Deployment Type Creation will fail.

## Results
Here is an example of the end result with the Redistributables installed. Note that 2015 and 2017 are the same major version (14.x), so once 2017 is installed, 2015 will not be displayed in the programs list.

Visual C++ Redistributables 2005 to 2015 installed:

![Visual C++ Redistributables 2005-2015](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/2005-2015.PNG "Visual C++ Redistributables 2005-2015")

Visual C++ Redistributables 2005 to 2017 (including 2015) installed:

![Visual C++ Redistributables 2005-2017](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/2005-2017.PNG "Visual C++ Redistributables 2005-2017")

## Configuration Manager 
Support for downloading the Redistributables and creating applications in System Center Configuration Manager is also supported.

### CreateCMApp
Switch Parameter to create ConfigMgr apps from downloaded redistributables.

### SMSSiteCode
Specify SMS Site Code for ConfigMgr app creation.

Example: Download Visual C++ Redistributables listed in VisualCRedistributables.xml and create ConfigMgr Applications for the selected Site.

    .\Install-VisualCRedistributables.ps1 -Xml ".\VisualCRedistributables.xml" -Path \\server1.contoso.com\Sources\Apps\VSRedist -CreateCMApp -SMSSiteCode S01

This will look similar to the following in Configuration Manager:

![Visual C++ Redistributables in Configuration Manager](https://raw.githubusercontent.com/aaronparker/Install-VisualCRedistributables/master/images/VCredist_ConfigMgr.PNG)
