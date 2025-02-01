################################################################################
function AssureGithubCLIInstalled {

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
    if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

        # Get the installation directory of GithubCLI
        $GithubCLIPath = "$env:ProgramFiles\GitHub CLI"

        # Add GithubCLI's path to the current user's environment PATH
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
        if ($currentPath -notlike "*$GithubCLIPath*") {

            [Environment]::SetEnvironmentVariable('PATH', "$currentPath;$GithubCLIPath", 'User')

            # Update the PATH for the current session
            $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
        }

        # Check if GithubCLI command is available
        if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -gt 0) {

            return;
        }

        Write-Host "GithubCLI not found. Installing GithubCLI..."

        if (-not (IsWinGetInstalled)) {

            InstallWinGet
        }

        Install-WinGetPackage -Id 'GitHub.cli' -Force

        if (-not (Get-Command 'gh.exe' -ErrorAction SilentlyContinue)) {

            Write-Error "GithubCLI installation path not found."

            return
        }

        gh extension install github/gh-copilot
        gh auth login --web -h github.com
    }
}
