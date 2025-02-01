################################################################################

function AssureWinMergeInstalled {

    function IsWinGetInstalled {

        Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
        $module = Get-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue

        if ($null -eq $module) {

            return $false
        }

        return $true
    }

    function InstallWinGet {

        Write-Verbose "Installing WinGet PowerShell client.."
        Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
        Import-Module "Microsoft.WinGet.Client"
    }

    # Check if WinMerge command is available
    if (@(Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

        # Get the installation directory of WinMerge
        $winMergePath = Join-Path ${env:LOCALAPPDATA} "Programs\WinMerge"

        # Add WinMerge's path to the current user's environment PATH
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
        if ($currentPath -notlike "*$winMergePath*") {

            [Environment]::SetEnvironmentVariable('PATH', "$currentPath;$winMergePath", 'User')

            # Update the PATH for the current session
            $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
        }

        # Check if WinMerge command is available
        if (@(Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -gt 0) {

            return;
        }

        Write-Host "WinMerge not found. Installing WinMerge..."

        if (-not (IsWinGetInstalled)) {

            InstallWinGet
        }

        Install-WinGetPackage -Id 'WinMerge.WinMerge' -Force

        if (-not (Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue)) {

            Write-Error "WinMerge installation path not found."

            return
        }
    }
}
