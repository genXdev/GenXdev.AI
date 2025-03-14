################################################################################
<#
.SYNOPSIS
Installs LM Studio application using WinGet package manager.

.DESCRIPTION
Ensures LM Studio is installed on the system by checking WinGet dependencies and
installing LM Studio if not already present. Uses WinGet module with CLI fallback.

.EXAMPLE
Install-LMStudioApplication
#>
function Install-LMStudioApplication {

    [CmdletBinding()]
    param()

    begin {

        # helper function to verify and install winget module
        function Test-WingetDependency {
            try {
                $null = Import-Module "Microsoft.WinGet.Client" -ErrorAction Stop
                return $true
            }
            catch {
                return $false
            }
        }

        # helper function to install winget if missing
        function Install-WingetDependency {
            if (-not (Test-WingetDependency)) {
                Write-Verbose "Installing WinGet PowerShell module..."
                $null = Install-Module "Microsoft.WinGet.Client" `
                    -Force `
                    -AllowClobber `
                    -ErrorAction Stop

                $null = Import-Module "Microsoft.WinGet.Client" -ErrorAction Stop
            }
        }
    }

    process {
        try {
            # ensure winget module is available
            Install-WingetDependency

            # package identifier for lm studio
            $lmStudioId = "ElementLabs.LMStudio"

            # check if already installed
            Write-Verbose "Checking if LM Studio is already installed..."
            $installed = Get-WinGetPackage -Id $lmStudioId -ErrorAction Stop

            if ($null -eq $installed) {
                Write-Verbose "Installing LM Studio..."

                try {
                    # attempt install via powershell module
                    $null = Install-WinGetPackage -Id $lmStudioId `
                        -Force `
                        -ErrorAction Stop
                }
                catch {
                    # fallback to winget cli
                    Write-Verbose "Falling back to WinGet CLI..."
                    winget install $lmStudioId

                    if ($LASTEXITCODE -ne 0) {
                        throw "WinGet CLI installation failed"
                    }
                }

                # reset cached paths after install
                $script:LMStudioExe = $null
                $script:LMSExe = $null
                Get-LMStudioPaths
                $null = Get-Process "LM Studio" -ErrorAction SilentlyContinue | Stop-Process -Force
                $null = Start-Process -FilePath ($script:LMStudioExe) -WindowStyle Maximized
            }
            else {
                Write-Verbose "LM Studio is already installed"
            }
        }
        catch {
            throw "Failed to install LM Studio: $_"
        }
    }

    end {}
}
################################################################################