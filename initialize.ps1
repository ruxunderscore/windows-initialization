#######################################################################################################
#                                               |   __      __.__            .___                     #
#                                               |  /  \    /  \__| ____    __| _/______  _  ________  #
#       Author        : Jonathan Rux            |  \   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/  #
#       Email         : jrux@email.com          |   \        /|  |   |  \/ /_/ (  <_> )     /\___ \   #
#       Version       : 1.0                     |    \__/\  / |__|___|  /\____ |\____/ \/\_//____  >  #
#       OS Support    : Windows 10,11           |         \/          \/      \/                 \/   #
#                                               |       Initialization Setup Script.                  #
#                                               |                                                     #
#######################################################################################################

<#
.DESCRIPTION
        This script initializes Windows 10/11 and, then, installs initial software needed by
        employees at <insert company here>. 
#>

#########################
#       Functions       #
#########################

function InstallApps { #Check for Winget, Install Winget if it isn't installed, and then install apps from a list.
    Write-Output "Checking for Winget..."
    $Command = "winget" #try-catch using Get-Command to check if winget is present on system.
    try {
        if (Get-Command $Command) {
            "$Command is installed.`nContinuing..."
        }
    } catch {
        Write-Output "Winget doesn't exist.`nInstalling Winget..."
        Set-ExecutionPolicy RemoteSigned #Allows the msixbundle installer to check signing with Microsoft's github.
        $Winget = "https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Write-Output "Winget is being downloaded..."
        Invoke-WebRequest -Uri $Winget -OutFile winget-installer.msixbundle
        Write-Output "Installing winget..."
        .\winget-installer.msixbundle #Run the installer.
    }

    Write-Output "Installing Applications"
    $Apps = @( #Define's application's names as appears in winget.
        @{name = "7zip.7zip"}
        @{name = "Git.Git"}
        @{name = "Google.Chrome"}
        @{name = "Microsoft.PowerShell"}
        @{name = "Microsoft.PowerToys"}
        @{name = "Microsoft.VisualStudioCode"}
        @{name = "Microsoft.VisualStudio.2022.Community"}
        @{name = "Microsoft.WindowsTerminal"}
        @{name = "Notepad++.Notepad++"}
        @{name = "Microsoft.Teams"}
        @{name = "voidtools.Everything.Lite"}
    )

    foreach ($App in $Apps) {
        $listApp = winget list --exact -q $App.name
        if (![String]::Join("", $listApp).Contains($App.name)) {
            Write-Output "Installing: " $App.name
            winget install -e -h --accept-source-agreements --accept-package-agreements --id $App.name
        } else {
            Write-Output "Skipping:   "$App.name " is already installed; skipping."
        }
    }
}

#########################
#    Call Functions     #
#########################
InstallApps