<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : EnsurePip.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.304.2025
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
Ensures pip is installed and functional for the specified Python installation.

.DESCRIPTION
Verifies that pip is available and functional for the given Python executable.
If pip is not available, attempts to install it using ensurepip. Validates
pip functionality by checking version and basic operations. Returns $true if
pip is ready; throws Write-Error on failure.

.PARAMETER PythonPath
The path to the Python executable. If not specified, uses the Python found
in PATH.

.PARAMETER Timeout
Timeout in seconds for pip installation and verification.

.PARAMETER Force
Forces reinstallation/upgrade of pip.

.EXAMPLE
EnsurePip

Ensures pip is available for the default Python installation.

.EXAMPLE
EnsurePip -PythonPath "C:\Python39\python.exe" -Force

Forces pip installation for a specific Python executable.

.EXAMPLE
$pythonPath = EnsurePython
EnsurePip -PythonPath $pythonPath

Ensures pip for a specific Python installation returned by EnsurePython.
#>
function EnsurePip {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to Python executable"
        )]
        [string] $PythonPath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Timeout in seconds for pip installation"
        )]
        [ValidateRange(30, 1800)]
        [int] $Timeout = 300,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces reinstallation/upgrade of pip"
        )]
        [switch] $Force
        #######################################################################
    )

    begin {
        # initialize variables
        $pipAvailable = $false
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # show initial progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "pip Installation" `
            -Status "Checking pip availability..."
    }

    process {
        # determine python path
        if (-not $PythonPath) {
            $pythonCmd = Microsoft.PowerShell.Core\Get-Command python -ErrorAction SilentlyContinue
            if (-not $pythonCmd) {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Python not found in PATH. Please specify -PythonPath or ensure Python is installed."
                return
            }
            $PythonPath = $pythonCmd.Source
        }

        # verify python executable exists
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $PythonPath)) {
            Microsoft.PowerShell.Utility\Write-Error `
                "Python executable not found at: ${PythonPath}"
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using Python at: ${PythonPath}"

        # check if pip is already available (unless Force is specified)
        if (-not $Force) {
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "pip Installation" `
                -Status "Checking existing pip installation..." `
                -PercentComplete 25

            # check pip via command line
            $pipversion = & $PythonPath -m pip --version 2>$null

            if ($pipversion) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "pip already available: ${pipversion}"
                return $true
            }

            # fallback: check pip via Python import
            $pipcheck = & $PythonPath -c "import pip; print('pip', pip.__version__)" 2>$null

            if ($pipcheck) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "pip detected via Python import: ${pipcheck}"
                return $true
            }
        }

        # install/upgrade pip using ensurepip
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "pip Installation" `
            -Status "Installing pip via ensurepip..." `
            -PercentComplete 50

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Installing pip via ensurepip"

        try {
            $ensurepipArgs = @("-m", "ensurepip", "--default-pip")
            if ($Force) {
                $ensurepipArgs += "--upgrade"
            }

            $ensurepipOutput = & $PythonPath $ensurepipArgs 2>&1
            Microsoft.PowerShell.Utility\Write-Verbose "ensurepip output: $ensurepipOutput"

        } catch {
            Microsoft.PowerShell.Utility\Write-Verbose "ensurepip failed: $($_.Exception.Message)"
        }

        # verify pip installation
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "pip Installation" `
            -Status "Verifying pip installation..." `
            -PercentComplete 75

        # try pip command line again
        $pipversion = & $PythonPath -m pip --version 2>$null

        if ($pipversion) {
            Microsoft.PowerShell.Utility\Write-Verbose `
                "pip successfully installed: ${pipversion}"
            $pipAvailable = $true
        } else {
            # try alternative pip check
            $pipcheck = & $PythonPath -c "import pip; print('pip', pip.__version__)" 2>$null

            if ($pipcheck) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "pip available via Python import: ${pipcheck}"
                $pipAvailable = $true
            } else {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to install or verify pip. Try manually installing pip or reinstalling Python with pip support."
                return
            }
        }

        # upgrade pip if Force is specified and pip is available
        if ($Force -and $pipAvailable) {
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "pip Installation" `
                -Status "Upgrading pip..." `
                -PercentComplete 90

            try {
                $upgradeOutput = & $PythonPath -m pip install --upgrade pip 2>&1
                Microsoft.PowerShell.Utility\Write-Verbose "pip upgrade output: $upgradeOutput"
            } catch {
                Microsoft.PowerShell.Utility\Write-Verbose "pip upgrade failed: $($_.Exception.Message)"
            }
        }

        # check timeout
        if ($stopwatch.Elapsed.TotalSeconds -gt $Timeout) {
            Microsoft.PowerShell.Utility\Write-Error `
                "pip installation timed out after ${Timeout} seconds."
            return
        }

        # final verification
        $finalPipVersion = & $PythonPath -m pip --version 2>$null
        if ($finalPipVersion) {
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Final pip verification: ${finalPipVersion}"
        }

        # complete progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "pip Installation" `
            -Status "pip ready" `
            -PercentComplete 100

        return $pipAvailable
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "pip Installation" `
            -Completed
    }
}
###############################################################################