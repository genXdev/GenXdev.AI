################################################################################
<#
.SYNOPSIS
Ensures that GitHub CLI is installed and configured on the system.

.DESCRIPTION
This function checks if GitHub CLI (gh) is installed and accessible. If not, it
will install it using WinGet, configure the PATH environment variable, and set up
the GitHub Copilot extension. It also handles WinGet installation if needed.

.EXAMPLE
AssureGithubCLIInstalled
#>
function AssureGithubCLIInstalled {

    [CmdletBinding()]
    param()

    begin {

        # helper function to check if winget module is installed
        function IsWinGetInstalled {

            Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            $module = Get-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            return $null -ne $module
        }

        # helper function to install winget module
        function InstallWinGet {

            Write-Verbose "Installing WinGet PowerShell client..."
            $null = Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
            Import-Module "Microsoft.WinGet.Client"
        }
    }

    process {

        # check if github cli is already available
        if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            Write-Verbose "GitHub CLI not found in PATH, checking installation..."

            # define github cli installation path
            $githubCliPath = "$env:ProgramFiles\GitHub CLI"

            # update user's path if needed
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
            if ($currentPath -notlike "*$githubCliPath*") {

                Write-Verbose "Adding GitHub CLI to PATH..."
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$githubCliPath",
                    'User')
                $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
            }

            # check if gh command is now available
            if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

                Write-Verbose "Installing GitHub CLI..."

                # ensure winget is available
                if (-not (IsWinGetInstalled)) {
                    InstallWinGet
                }

                # install github cli using winget
                $null = Install-WinGetPackage -Id 'GitHub.cli' -Force

                # verify installation
                if (-not (Get-Command 'gh.exe' -ErrorAction SilentlyContinue)) {
                    Write-Error "GitHub CLI installation failed"
                    return
                }

                Write-Verbose "Installing GitHub Copilot extension..."
                $null = gh extension install github/gh-copilot

                Write-Verbose "Initiating GitHub authentication..."
                $null = gh auth login --web -h github.com
            }
        }
    }

    end {}
}
################################################################################
