###############################################################################################################
#                                                       |   __      __.__            .___                     #
#                                                       |  /  \    /  \__| ____    __| _/______  _  ________  #
#       Author        : Jonathan Rux                    |  \   \/\/   /  |/    \  / __ |/  _ \ \/ \/ /  ___/  #
#       Email         : jonathan.e.rux@underscore.com   |   \        /|  |   |  \/ /_/ (  <_> )     /\___ \   #
#       Version       : 2.0                             |    \__/\  / |__|___|  /\____ |\____/ \/\_//____  >  #
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


# Function to create a header for each section
function header {
    param (
        [string]$title
    )
    <#
    .DESCRIPTION
        Creates header for each function.
    .SYNOPSIS
        Creates header for each function.
    #>
    Write-Output "$($title)`n$('='*64)`n"
}

# Function to install AppxPackage
function AAP {
    param (
        [string]$pkg
    )
    <#
    .SYNOPSIS
        Installs AppxPackage.
    .DESCRIPTION
        Installs AppxPackage.
    #>
    Write-Output "  Installing $($pkg)..."
    Add-AppxPackage -ErrorAction:SilentlyContinue $pkg
    Write-Output "  $($pkg) installed. Continuing...`n"
}

# Function to install prerequisites for Winget
function InstallPrereqs {
    <#
    .DESCRIPTION
        Downloads and Installs Winget Prerequisites.
    .SYNOPSIS
        Downloads and Installs Winget Prerequisites.
    #>

    header -title "Installing winget-cli Prerequisites..."
    Write-Output "  Downloading Microsoft.VCLibs.x64.14.00.Desktop.appx..."
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Write-Output "  Downloading Microsoft.UI.Xaml.2.7.x64.appx...`n"
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
    AAP -pkg "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    AAP -pkg "Microsoft.UI.Xaml.2.7.x64.appx"
}

# Function to get the latest version of Winget from GitHub
function Get-LatestGitHubRelease {
    <#
    .DESCRIPTION
        Checks Github API for latest version of Winget.
    .SYNOPSIS
        Checks Github API for latest version of Winget.
    #>
    param (
        [int]$assetIndex
    )
    
    header -title "Checking GitHub API for the latest version of winget-cli..."
    
    try {
        $response = Invoke-RestMethod -Uri "https://api.github.com/repos/microsoft/winget-cli/releases/latest"
        $latestVersion = $response.tag_name
        Write-Output "  Latest version:`t$($latestVersion)`n"
        $assetUrl = $response.assets[$assetIndex].browser_download_url
        Invoke-WebRequest -Uri $assetUrl -OutFile Microsoft.DesktopAppInstaller.msixbundle
    } catch {
        Write-Host "  Error: $_"
    }
}


# Function to check for Winget; if not found, install prerequisites and Winget
function WingetCheck {
    <#
    .SYNOPSIS
        Check for Winget; If doesn't exist, install prerequisites and winget.
    .DESCRIPTION
        Check for Winget; If doesn't exist, install prerequisites and winget.
    #>
    header -title "Checking for Winget..."
    if (-not (Get-Command -ErrorAction SilentlyContinue winget)) {
        Write-Host "  Winget not found. Installing prerequisites...`n"
        InstallPrereqs
        Write-Host "  Downloading the latest winget-cli...`n"
        Get-LatestGitHubRelease -assetIndex 2
        Write-Output "  Installing winget-cli..."
        AAP -pkg "Microsoft.DesktopAppInstaller.msixbundle"
        Write-Output "  Refreshing Environment Variables...`n"
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
    }
    Write-Output "  Winget-cli is installed. Continuing...`n"
}

# Function to install applications from a JSON list
function InstallApps {
    <#
    .SYNOPSIS
        Install apps from json list.
    .DESCRIPTION
        Install apps from json list.
    #>
    header -title "Installing Applications..."
    $appsJson = ".\apps.json"
    Write-Output "  Installing applications from $($appsJson)..."
    winget import -i $appsJson --accept-package-agreements --accept-source-agreements
    Write-Output "  Complete install of applications from $($appsJson)... Exiting..."
}

#########################
#    Call Functions     #
#########################

# Check for Winget and install if not found
WingetCheck

# Install applications
InstallApps