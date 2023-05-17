# Initialization Setup Script

This PowerShell script initializes a Windows 10/11 x64 machine and installs initial software needed by employees at a company or for inidividual use. It uses the Winget package manager to install applications listed in the `apps.json` file.

## Requirements
- Windows 10/11 x64 machine
- PowerShell 5.1 or later
- Internet connectivity

## Usage

1. Clone this repository to your local machine.
2. Open PowerShell (Admin) and navigate to the directory where the script is located.
3. Run the script by entering the following command: `.\initialize.ps1`.

## Functionality

The script consists of the following functions:

1. `AAP($pkg)` - Installs an AppxPackage.
3. `InstallPrereqs` - Installs Winget prerequisites from the ".\prereqs" directory.
4. `InstallApps` - Installs apps from a JSON list.

## Notes

- This script has been tested on Windows 10/11 x64.
- The `.\prereqs` directory contains the necessary prerequisites for Winget.
- The `apps.json` file contains a list of apps to be installed using Winget.

## Credits
  
This script was created by Jonathan Rux and is licensed under the MIT License. If you have any questions or issues with the script, please open an Issue.

## License
  
This project is licensed under the MIT License - see the LICENSE file for details.
