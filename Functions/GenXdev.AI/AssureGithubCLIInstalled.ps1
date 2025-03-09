################################################################################
<#
.SYNOPSIS
Ensures GitHub CLI is properly installed and configured on the system.

.DESCRIPTION
Performs comprehensive checks and setup for GitHub CLI (gh):
- Verifies if GitHub CLI is installed and accessible in PATH
- Installs GitHub CLI via WinGet if not present
- Configures system PATH environment variable
- Installs GitHub Copilot extension
- Sets up GitHub authentication
The function handles all prerequisites and ensures a working GitHub CLI setup.

.EXAMPLE
AssureGithubCLIInstalled
This will verify and setup GitHub CLI if needed.
#>
function AssureGithubCLIInstalled {

    [CmdletBinding()]
    param()

    begin {

        ########################################################################
        <#
        .SYNOPSIS
        Verifies if WinGet PowerShell module is installed.

        .DESCRIPTION
        Attempts to import WinGet module and checks if it's available.

        .OUTPUTS
        System.Boolean. Returns true if WinGet is installed, false otherwise.
        #>
        function IsWinGetInstalled {

            # attempt to load the winget module silently
            Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue

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
        Forces installation of the Microsoft.WinGet.Client module and imports it.
        #>
        function InstallWinGet {

            # inform user about winget installation
            Write-Verbose "Installing WinGet PowerShell client..."

            # force install the winget module
            $null = Install-Module "Microsoft.WinGet.Client" `
                -Force `
                -AllowClobber

            # load the newly installed module
            Import-Module "Microsoft.WinGet.Client"
        }
    }

    process {

        # check if github cli exists in system path
        if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            Write-Verbose "GitHub CLI not found in PATH, checking installation..."

            # standard installation path for github cli
            $githubCliPath = "$env:ProgramFiles\GitHub CLI"

            # retrieve current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure github cli path is in user's path
            if ($currentPath -notlike "*$githubCliPath*") {

                Write-Verbose "Adding GitHub CLI to PATH..."

                # append github cli path to existing path
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$githubCliPath",
                    'User')

                # ensure current session has updated path
                $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
            }

            # verify if cli is now accessible after path update
            if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

                Write-Verbose "Installing GitHub CLI..."

                # ensure winget is available for installation
                if (-not (IsWinGetInstalled)) {
                    InstallWinGet
                }

                # use winget to install github cli
                $null = Install-WinGetPackage -Id 'GitHub.cli' -Force

                # verify installation success
                if (-not (Get-Command 'gh.exe' -ErrorAction SilentlyContinue)) {
                    Write-Error "GitHub CLI installation failed"
                    return
                }

                # setup github authentication
                Write-Verbose "Initiating GitHub authentication..."
                $null = gh auth login --web -h github.com
            }
        }
    }

    end {}
}
################################################################################
