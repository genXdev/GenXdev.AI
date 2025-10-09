<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Test-LMStudioInstallation.ps1
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
Tests if LMStudio is installed and accessible on the system.

.DESCRIPTION
Verifies the LMStudio installation by checking if the executable exists at the
expected path location. Uses Get-LMStudioPaths helper function to determine the
installation path and validates the executable's existence.

.EXAMPLE
Test-LMStudioInstallation
Returns $true if LMStudio is properly installed, $false otherwise.

.EXAMPLE
tlms
Uses the alias to check LMStudio installation status.
#>
function Test-LMStudioInstallation {

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    begin {

        # retrieve the lmstudio installation paths using helper function
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving LMStudio installation paths...'
        $paths = GenXdev.AI\Get-LMStudioPaths
    }


    process {

        # check if the exe exists and return result
        Microsoft.PowerShell.Utility\Write-Verbose "Verifying LMStudio executable at: $($paths.LMSExe)"

        # use system.io for better performance
        return ((-not [string]::IsNullOrWhiteSpace($paths.LMSExe)) -and
            [System.IO.File]::Exists($paths.LMSExe) -and
            (-not [string]::IsNullOrWhiteSpace($paths.LMStudioExe)) -and
            [System.IO.File]::Exists($paths.LMStudioExe))
    }

    end {}
}