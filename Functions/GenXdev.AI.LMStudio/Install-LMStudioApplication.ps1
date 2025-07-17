###############################################################################
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
                $null = Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client' -ErrorAction Stop
                return $true
            }
            catch {
                return $false
            }
        }

        # helper function to install winget if missing
        function Install-WingetDependency {
            if (-not (Test-WingetDependency)) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Installing WinGet PowerShell module...'
                $null = PowerShellGet\Install-Module 'Microsoft.WinGet.Client' `
                    -Force `
                    -AllowClobber `
                    -ErrorAction Stop

                $null = Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client' -ErrorAction Stop
            }
        }
    }


    process {
        try {
            # ensure winget module is available
            Install-WingetDependency

            # package identifier for lm studio
            $lmStudioId = 'ElementLabs.LMStudio'

            # check if already installed
            Microsoft.PowerShell.Utility\Write-Verbose 'Checking if LM Studio is already installed...'
            $installed = Microsoft.WinGet.Client\Get-WinGetPackage -Id $lmStudioId -ErrorAction Stop

            if ($null -eq $installed) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Installing LM Studio...'

                try {
                    # attempt install via powershell module
                    $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id $lmStudioId `
                        -Force `
                        -ErrorAction Stop
                }
                catch {
                    # fallback to winget cli
                    Microsoft.PowerShell.Utility\Write-Verbose 'Falling back to WinGet CLI...'
                    winget install $lmStudioId

                    if ($LASTEXITCODE -ne 0) {
                        throw 'WinGet CLI installation failed'
                    }
                }

                # reset cached paths after install
                $script:LMStudioExe = $null
                $script:LMSExe = $null
                Get-LMStudioPaths
                $null = Microsoft.PowerShell.Management\Get-Process 'LM Studio' -ErrorAction SilentlyContinue | Microsoft.PowerShell.Management\Stop-Process -Force
                $null = Microsoft.PowerShell.Management\Start-Process -FilePath ($script:LMStudioExe) -WindowStyle Maximized
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose 'LM Studio is already installed'
            }
        }
        catch {
            throw "Failed to install LM Studio: $_"
        }
    }

    end {}
}