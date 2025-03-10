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
            try {
                Import-Module "Microsoft.WinGet.Client" -ErrorAction Stop
                $module = Get-Module "Microsoft.WinGet.Client" -ErrorAction Stop
                return $null -ne $module
            }
            catch [System.IO.FileNotFoundException] {
                Write-Verbose "WinGet module not found"
                return $false
            }
            catch {
                Write-Warning "Error checking WinGet installation: $_"
                return $false
            }
        }

        ########################################################################
        <#
        .SYNOPSIS
        Installs the WinGet PowerShell module.

        .DESCRIPTION
        Forces installation of the Microsoft.WinGet.Client module and imports it.
        #>
        function InstallWinGet {
            try {
                Write-Verbose "Installing WinGet PowerShell client..."
                Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber -ErrorAction Stop
                Import-Module "Microsoft.WinGet.Client" -ErrorAction Stop
            }
            catch [System.UnauthorizedAccessException] {
                throw "Insufficient permissions to install WinGet module. Run as administrator: $_"
            }
            catch {
                throw "Failed to install WinGet module: $_"
            }
        }
    }

    process {
        $ErrorActionPreference = 'Stop'
        try {
            if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {
                Write-Verbose "GitHub CLI not found in PATH, checking installation..."
                $githubCliPath = "$env:ProgramFiles\GitHub CLI"
                $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

                if ($currentPath -notlike "*$githubCliPath*") {
                    try {
                        Write-Verbose "Adding GitHub CLI to PATH..."
                        [Environment]::SetEnvironmentVariable(
                            'PATH',
                            "$currentPath;$githubCliPath",
                            'User')
                        $env:PATH = [Environment]::GetEnvironmentVariable('PATH', 'User')
                    }
                    catch [System.Security.SecurityException] {
                        throw "Access denied while updating PATH environment variable: $_"
                    }
                }

                if (@(Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {
                    Write-Verbose "Installing GitHub CLI..."

                    if (-not (IsWinGetInstalled)) {
                        InstallWinGet
                    }

                    try {
                        $null = Install-WinGetPackage -Id 'GitHub.cli' -Force
                    }
                    catch {
                        throw "Failed to install GitHub CLI via WinGet: $_"
                    }

                    if (-not (Get-Command 'gh.exe' -ErrorAction SilentlyContinue)) {
                        throw "GitHub CLI installation failed: Command not found after installation"
                    }

                    try {
                        Write-Verbose "Initiating GitHub authentication..."
                        $null = gh auth login --web -h github.com
                    }
                    catch {
                        Write-Error "GitHub authentication failed: $_"
                    }
                }
            }
        }
        catch {
            $errorMessage = "Failed to setup GitHub CLI: $($_.Exception.Message)"
            Write-Error -Exception $_.Exception -Message $errorMessage -Category OperationStopped
            throw
        }
        finally {
            $ErrorActionPreference = 'Continue'
        }
    }

    end {}
}
################################################################################
