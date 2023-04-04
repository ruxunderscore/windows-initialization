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
    if (Get-Command winget) {
        Write-Output "Winget is installed.`nContinuing..."
    } else {
        Write-Output "Winget doesn't exist.`nInstalling Winget...`nWinget is being downloaded..."
        $ProgressPreference='Silent'
        Invoke-WebRequest -Uri https://github.com/microsoft/winget-cli/releases/download/v1.3.2691/Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -OutFile ( New-Item -Path .\packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle -Force )
        Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile .\packages\Microsoft.VCLibs.x64.14.00.Desktop.appx
        Write-Output "Installing winget..."
        Add-AppxPackage .\packages\Microsoft.VCLibs.x64.14.00.Desktop.appx
        Add-AppxPackage .\packages\Microsoft.DesktopAppInstaller_8wekyb3d8bbwe.msixbundle
    }
    $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 
    Set-ExecutionPolicy Unrestricted
    Write-Output "Installing Applications..."
    $Apps = @( #Define's application's names as appears in winget.
        "7zip.7zip",
        "Git.Git",
        "Google.Chrome",
        "Microsoft.PowerShell",
        "Microsoft.PowerToys",
        "Microsoft.VisualStudioCode",
        "Microsoft.VisualStudio.2022.Community",
        "Microsoft.WindowsTerminal",
        "Notepad++.Notepad++",
        "Microsoft.Teams",
        "voidtools.Everything.Lite"
    )

    foreach ($App in $Apps) {
        $listApp = winget list --exact -q $App
        if ($listApp -contains $App) {
            Write-Output "Installing: $($App)..."
            winget install -e -h --accept-source-agreements --accept-package-agreements --id $App
        } else {
            Write-Output "Skipping:  $($App) is already installed; Skipping..."
        }
    }
}

#########################
#    Call Functions     #
#########################
InstallApps