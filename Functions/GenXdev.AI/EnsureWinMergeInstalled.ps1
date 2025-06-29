################################################################################
<#
.SYNOPSIS
Ensures WinMerge is installed and available for file comparison operations.

.DESCRIPTION
Verifies if WinMerge is installed and properly configured in the system PATH.
If not found, installs WinMerge using WinGet and adds it to the user's PATH.
Handles the complete installation and configuration process automatically.

.EXAMPLE
EnsureWinMergeInstalled
Ensures WinMerge is installed and properly configured.
#>
function EnsureWinMergeInstalled {

    [CmdletBinding()]
    param()

    begin {

        ########################################################################
        <#
        .SYNOPSIS
        Checks if the WinGet PowerShell module is installed.

        .DESCRIPTION
        Attempts to import the Microsoft.WinGet.Client module and verifies its
        presence.

        .EXAMPLE
        IsWinGetInstalled
        #>
        function IsWinGetInstalled {

            # attempt to load the winget module silently
            Microsoft.PowerShell.Core\Import-Module "Microsoft.WinGet.Client" `
                -ErrorAction SilentlyContinue

            # verify if module was loaded successfully
            $module = Microsoft.PowerShell.Core\Get-Module "Microsoft.WinGet.Client" `
                -ErrorAction SilentlyContinue

            return $null -ne $module
        }

        ########################################################################
        <#
        .SYNOPSIS
        Installs the WinGet PowerShell module.

        .DESCRIPTION
        Installs and imports the Microsoft.WinGet.Client module for package
        management.

        .EXAMPLE
        InstallWinGet
        #>
        function InstallWinGet {

            # install and import winget module with force to ensure success
            Microsoft.PowerShell.Utility\Write-Verbose "Installing WinGet PowerShell client..."
            $null = PowerShellGet\Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber

            # load the newly installed module
            Microsoft.PowerShell.Core\Import-Module "Microsoft.WinGet.Client"
        }
    }


    process {

        # verify if winmerge is available in current session
        if (@(Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            # define the standard installation location for winmerge
            $winMergePath = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA "Programs\WinMerge"

            # get the current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure winmerge path exists in user's path variable
            if ($currentPath -notlike "*$winMergePath*") {

                Microsoft.PowerShell.Utility\Write-Verbose "Adding WinMerge to system PATH..."
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')

                # update current session's path only if not already present
                if ($env:PATH -notlike "*$winMergePath*") {
                    $env:PATH = "$env:PATH;$winMergePath"
                }
            }

            # check if winmerge is now accessible
            if (@(Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -gt 0) {
                return
            }

            Microsoft.PowerShell.Utility\Write-Host "WinMerge not found. Installing WinMerge..."

            # ensure winget is available for installation
            if (-not (IsWinGetInstalled)) {
                InstallWinGet
            }

            # install winmerge using winget package manager
            $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'WinMerge.WinMerge' -Force
            # define the standard installation location for winmerge
            $winMergePath = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA "Programs\WinMerge"

            # get the current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure winmerge path exists in user's path variable
            if ($currentPath -notlike "*$winMergePath*") {

                Microsoft.PowerShell.Utility\Write-Verbose "Adding WinMerge to system PATH..."
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')

                # update current session's path only if not already present
                if ($env:PATH -notlike "*$winMergePath*") {
                    $env:PATH = "$env:PATH;$winMergePath"
                }
            }
            # verify successful installation
            if (-not (Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue)) {
                throw "WinMerge installation failed."
            }
        }
    }

    end {
    }
}
################################################################################