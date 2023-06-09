###############################################################################################################
#                                                       |   __      __.__            .___                     #
#                                                       |  /  \    /  \__| ____    __| _/______  _  ________  #
#       Author        : Jonathan Rux                    |  \   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/  #
#       Email         : jonathan.e.rux@underscore.com   |   \        /|  |   |  \/ /_/ (  <_> )     /\___ \   #
#       Version       : 1.1                             |    \__/\  / |__|___|  /\____ |\____/ \/\_//____  >  #
#       OS Support    : Windows 10,11 x64               |         \/          \/      \/                 \/   #
#                                                       |       Initialization Setup Script.                  #
#                                                       |                                                     #
###############################################################################################################

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
    Write-Output "`n  $title`n=============================================`n"
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
    <#
    .SYNOPSIS
        Check for Winget; If doesn't exist, install prerequisites and winget.
    .DESCRIPTION
        Check for Winget; If doesn't exist, install prerequisites and winget.
    #>
    header("Checking for Winget...")
    if (-not (Get-Command -ErrorAction SilentlyContinue winget)) {
        $ProgressPreference = 'Silent'
        InstallPrereqs
        Write-Output "Downloading and installing winget..."
        $url = "https://github.com/microsoft/winget-cli/releases/download/v1.4.10173/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle"
        Invoke-WebRequest -Uri $url -OutFile "Microsoft.DesktopAppInstaller.msixbundle"
        Start-Process -FilePath "Microsoft.DesktopAppInstaller.msixbundle" -ArgumentList "/silent", "/install" -Wait
        Remove-Item "Microsoft.DesktopAppInstaller.msixbundle"
        Write-Output "Refreshing Environment Variables..."
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
    Write-Output "Winget is installed. Continuing..."
}

function InstallApps {
    <#
    .SYNOPSIS
        Install apps from json list.
    .DESCRIPTION
        Install apps from json list.
    #>
    header("Installing Applications...")
    $Apps = ".\apps.json"
    winget import -i $Apps --accept-package-agreements --accept-source-agreements
}

#########################
#    Call Functions     #
#########################
WingetCheck
InstallApps