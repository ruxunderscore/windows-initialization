#######################################################################################################
#                                               |   __      __.__            .___                     #
#                                               |  /  \    /  \__| ____    __| _/______  _  ________  #
#       Author        : Jonathan Rux            |  \   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/  #
#       Email         : jrux@email.com          |   \        /|  |   |  \/ /_/ (  <_> )     /\___ \   #
#       Version       : 1.0                     |    \__/\  / |__|___|  /\____ |\____/ \/\_//____  >  #
#       OS Support    : Windows 10,11 x64       |         \/          \/      \/                 \/   #
#                                               |       Initialization Setup Script.                  #
#                                               |                                                     #
#######################################################################################################

<#
.DESCRIPTION
    This script initializes Windows 10/11 x64 and, then, installs initial software needed by employees at <insert company here>.
.SYNOPSIS
    This script initializes Windows 10/11 x64 and, then, installs initial software needed by employees at <insert company here>.
#>

#########################
#       Functions       #
#########################

function header($title) {
    <#
    .DESCRIPTION
        Creates header for each function.
    .SYNOPSIS
        Creates header for each function.
    #>
    Write-Output "###################################`n# $title`n###################################"
}

function AAP($pkg) {
    <#
        .SYNOPSIS
            Installs AppxPackage.
        .DESCRIPTION
            Installs AppxPackage.
    #>
    Add-AppxPackage -ErrorAction:SilentlyContinue $pkg 
}

function InstallPrereqs {
    <#
    .DESCRIPTION
        Installs Winget Prerequisites from the .\prereqs directory.
    .SYNOPSIS
        Installs Winget Prerequisites from the .\prereqs directory.
    #>

    header("Installing Winget Prerequisites...")
    AAP(".\prereqs\Microsoft.VCLibs.x64.14.00.Desktop.appx")
    AAP(".\prereqs\Microsoft.UI.Xaml.2.7.appx")
}

function WingetCheck {
    header("Checking for Winget...")
    if (Get-Command -ErrorAction:SilentlyContinue winget) {
        Write-Output "Winget is installed.`nContinuing..."
    } else {
        InstallPrereqs
        Write-Output "Winget doesn't exist.`nWinget is being downloaded..."
        $ProgressPreference='Silent'
        Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.3.2691/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile .\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
        Write-Output "Installing winget..."
        AAP(".\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle")
        Write-Output "Cleaning up (Removing winget install file)..."
        Remove-Item ".\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Write-Output "Refreshing Environment Variables..."
        #Refresh environment variables. Thanks to weq in the PowerShell Discord for this.
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
    }
}

function InstallApps { #Check for Winget, Install Winget if it isn't installed, and then install apps from a list.
    header("Installing Applications...")
    $Apps = ".\apps.json"
    winget import -i $Apps --accept-package-agreements --accept-source-agreements
}

#########################
#    Call Functions     #
#########################
WingetCheck
InstallApps