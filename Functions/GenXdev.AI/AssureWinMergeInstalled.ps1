################################################################################
<#
.SYNOPSIS
Ensures WinMerge is installed and available for file comparison operations.

.DESCRIPTION
Verifies if WinMerge is installed and properly configured in the system PATH.
If not found, installs WinMerge using WinGet and adds it to the user's PATH.
Handles the complete installation and configuration process automatically.

.EXAMPLE
AssureWinMergeInstalled
Ensures WinMerge is installed and properly configured.
#>
function AssureWinMergeInstalled {

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
            Import-Module "Microsoft.WinGet.Client" `
                -ErrorAction SilentlyContinue

            # verify if module was loaded successfully
            $module = Get-Module "Microsoft.WinGet.Client" `
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
            Write-Verbose "Installing WinGet PowerShell client..."
            $null = Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber

            # load the newly installed module
            Import-Module "Microsoft.WinGet.Client"
        }
    }

    process {

        # verify if winmerge is available in current session
        if (@(Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            # define the standard installation location for winmerge
            $winMergePath = Join-Path $env:LOCALAPPDATA "Programs\WinMerge"

            # get the current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure winmerge path exists in user's path variable
            if ($currentPath -notlike "*$winMergePath*") {

                Write-Verbose "Adding WinMerge to system PATH..."
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')

                # update current session's path
                $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
            }

            # check if winmerge is now accessible
            if (@(Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -gt 0) {
                return
            }

            Write-Host "WinMerge not found. Installing WinMerge..."

            # ensure winget is available for installation
            if (-not (IsWinGetInstalled)) {
                InstallWinGet
            }

            # install winmerge using winget package manager
            $null = Install-WinGetPackage -Id 'WinMerge.WinMerge' -Force

            # verify successful installation
            if (-not (Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue)) {
                throw "WinMerge installation failed."
            }
        }
    }

    end {
    }
}
################################################################################