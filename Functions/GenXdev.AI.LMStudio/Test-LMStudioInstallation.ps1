<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Test-LMStudioInstallation.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.286.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
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