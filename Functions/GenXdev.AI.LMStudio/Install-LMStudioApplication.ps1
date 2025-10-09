<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Install-LMStudioApplication.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
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
                # request consent before installing winget module
                $consent = GenXdev.FileSystem\Confirm-InstallationConsent `
                    -ApplicationName 'Microsoft.WinGet.Client PowerShell Module' `
                    -Source 'PowerShell Gallery' `
                    -Description 'Required for managing Windows software packages programmatically' `
                    -Publisher 'Microsoft'

                if (-not $consent) {
                    throw 'Installation consent denied for WinGet PowerShell module'
                }

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
                # request consent before installing lm studio
                $consent = GenXdev.FileSystem\Confirm-InstallationConsent `
                    -ApplicationName 'LM Studio' `
                    -Source 'WinGet' `
                    -Description 'Local AI model management and inference platform' `
                    -Publisher 'Element Labs'

                if (-not $consent) {
                    Microsoft.PowerShell.Utility\Write-Warning 'Installation consent denied for LM Studio'
                    return
                }

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
                GenXdev.AI\Get-LMStudioPaths
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