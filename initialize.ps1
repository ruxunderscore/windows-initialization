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
    Write-Output "`n  $($title)`n=============================================`n"
}

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
    Add-AppxPackage -ErrorAction:SilentlyContinue $pkg 
}

function InstallPrereqs {
    <#
    .DESCRIPTION
        Downloads and Installs Winget Prerequisites.
    .SYNOPSIS
        Downloads and Installs Winget Prerequisites.
    #>

    header -title "Installing winget-cli Prerequisites..."
    Invoke-WebRequest -Uri https://aka.ms/Microsoft.VCLibs.x64.14.00.Desktop.appx -OutFile Microsoft.VCLibs.x64.14.00.Desktop.appx
    Invoke-WebRequest -Uri https://github.com/microsoft/microsoft-ui-xaml/releases/download/v2.7.3/Microsoft.UI.Xaml.2.7.x64.appx -OutFile Microsoft.UI.Xaml.2.7.x64.appx
    AAP -pkg "Microsoft.VCLibs.x64.14.00.Desktop.appx"
    AAP -pkg "Microsoft.UI.Xaml.2.7.x64.appx"
}

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
        Write-Output "Latest version:`t$($latestVersion)`n"
        $assetUrl = $response.assets[$assetIndex].browser_download_url
        $assetUrlString = [string]$assetUrl
        Write-Output "LatestVersionUri:`t$($assetUrlString)`n"
        return [System.Uri]::new($assetUrlString)  # Use the constructor to create a System.Uri
    } catch {
        Write-Host "Error: $_"
    }
}


function WingetCheck {
    <#
    .SYNOPSIS
        Check for Winget; If doesn't exist, install prerequisites and winget.
    .DESCRIPTION
        Check for Winget; If doesn't exist, install prerequisites and winget.
    #>
    header -title "Checking for Winget..."
    if (-not (Get-Command -ErrorAction SilentlyContinue winget)) {
        $ProgressPreference = 'Silent'
        InstallPrereqs
        Write-Output "Downloading and installing winget..."
        $assetIndex = 2
        $latestUri = Get-LatestGitHubRelease -assetIndex $assetIndex
        Write-Output "URI:`t$($latestUri)"
        Invoke-WebRequest -Uri $latestUri -OutFile Microsoft.DesktopAppInstaller.msixbundle
        AAP -pkg "Microsoft.DesktopAppInstaller.msixbundle"
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
    header -title "Installing Applications..."
    $Apps = ".\apps.json"
    winget import -i $Apps --accept-package-agreements --accept-source-agreements
}

#########################
#    Call Functions     #
#########################
WingetCheck
InstallApps