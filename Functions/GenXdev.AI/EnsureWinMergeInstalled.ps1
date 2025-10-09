<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : EnsureWinMergeInstalled.ps1
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
Ensures WinMerge is installed and available for file comparison operations.

.DESCRIPTION
Verifies if WinMerge is installed and properly configured in the system PATH.
If not found, installs WinMerge using WinGet and adds it to the user's PATH.
Handles the complete installation and configuration process automatically.

.EXAMPLE
EnsureWinMergeInstalled
Ensures WinMerge is installed and properly configured.
#>
function EnsureWinMergeInstalled {

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
            Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client' `
                -ErrorAction SilentlyContinue

            # verify if module was loaded successfully
            $ModuleObj = Microsoft.PowerShell.Core\Get-Module 'Microsoft.WinGet.Client' `
                -ErrorAction SilentlyContinue

            return $null -ne $ModuleObj
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

            # request user consent before installing winget module
            $consent = GenXdev.FileSystem\Confirm-InstallationConsent `
                -ApplicationName 'Microsoft.WinGet.Client' `
                -Source 'PowerShell Gallery' `
                -Description 'PowerShell module for Windows Package Manager operations' `
                -Publisher 'Microsoft'

            if (-not $consent) {
                throw 'Installation of Microsoft.WinGet.Client was denied by user.'
            }

            # install and import winget module with force to ensure success
            Microsoft.PowerShell.Utility\Write-Verbose 'Installing WinGet PowerShell client...'
            $null = PowerShellGet\Install-Module 'Microsoft.WinGet.Client' -Force -AllowClobber

            # load the newly installed module
            Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client'
        }
    }


    process {

        # verify if winmerge is available in current session
        if (@(Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            # define the standard installation location for winmerge
            $winMergePath = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA 'Programs\WinMerge'

            # get the current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure winmerge path exists in user's path variable
            if ($currentPath -notlike "*$winMergePath*") {

                Microsoft.PowerShell.Utility\Write-Verbose 'Adding WinMerge to system PATH...'
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')
            }

            # update current session's path only if not already present
            if ($env:PATH -notlike "*$winMergePath*") {
                $env:PATH = "$env:PATH;$winMergePath"
            }


            # check if winmerge is now accessible
            if (@(Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -gt 0) {
                return
            }

            Microsoft.PowerShell.Utility\Write-Host 'WinMerge not found. Installing WinMerge...'

            # ensure winget is available for installation
            if (-not (IsWinGetInstalled)) {
                InstallWinGet
            }

            # request user consent before installing winmerge
            $consentWinMerge = GenXdev.FileSystem\Confirm-InstallationConsent `
                -ApplicationName 'WinMerge' `
                -Source 'WinGet' `
                -Description 'Visual diff and merge tool for files and folders' `
                -Publisher 'WinMerge Team'

            if (-not $consentWinMerge) {
                throw 'Installation of WinMerge was denied by user.'
            }

            # install winmerge using winget package manager
            $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'WinMerge.WinMerge' -Force
            # define the standard installation location for winmerge
            $winMergePath = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA 'Programs\WinMerge'

            # get the current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure winmerge path exists in user's path variable
            if ($currentPath -notlike "*$winMergePath*") {

                Microsoft.PowerShell.Utility\Write-Verbose 'Adding WinMerge to system PATH...'
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')
            }

            # update current session's path only if not already present
            if ($env:PATH -notlike "*$winMergePath*") {
                $env:PATH = "$env:PATH;$winMergePath"
            }

            # verify successful installation
            if (-not (Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue)) {
                throw 'WinMerge installation failed.'
            }
        }
    }

    end {
    }
}