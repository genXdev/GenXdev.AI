################################################################################
<#
.SYNOPSIS
Ensures WinMerge is installed and available in the system PATH.

.DESCRIPTION
This function checks if WinMerge is installed and accessible via command line.
If not found, it will install WinMerge using WinGet and configure the system
PATH accordingly.

.EXAMPLE
AssureWinMergeInstalled
#>
function AssureWinMergeInstalled {

    [CmdletBinding()]
    param()

    begin {

        function IsWinGetInstalled {

            # attempt to import the winget module
            Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            $module = Get-Module "Microsoft.WinGet.Client" `
                -ErrorAction SilentlyContinue

            return $null -ne $module
        }

        function InstallWinGet {

            Write-Verbose "Installing WinGet PowerShell client..."
            Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
            Import-Module "Microsoft.WinGet.Client"
        }
    }

    process {

        # check if winmerge command is available
        if (@(Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            # get the default winmerge installation path
            $winMergePath = Join-Path $env:LOCALAPPDATA "Programs\WinMerge"

            # add winmerge path to user environment if not present
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
            if ($currentPath -notlike "*$winMergePath*") {

                Write-Verbose "Adding WinMerge to PATH..."
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')

                # update current session path
                $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
            }

            # verify if winmerge is now available
            if (@(Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -gt 0) {
                return
            }

            Write-Host "WinMerge not found. Installing WinMerge..."

            # ensure winget is available for installation
            if (-not (IsWinGetInstalled)) {
                InstallWinGet
            }

            # install winmerge using winget
            Install-WinGetPackage -Id 'WinMerge.WinMerge' -Force

            # verify installation success
            if (-not (Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue)) {
                Write-Error "WinMerge installation failed."
                return
            }
        }
    }

    end {}
}
################################################################################
