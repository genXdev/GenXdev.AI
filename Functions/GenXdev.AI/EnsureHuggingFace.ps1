<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : EnsureHuggingFace.ps1
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
Ensures the Hugging Face CLI is installed and functional.

.DESCRIPTION
Orchestrates the installation of Python, pip, and the Hugging Face CLI by
calling EnsurePython and EnsurePip, then installing the huggingface_hub package.
Stores the CLI path in a JSON file and ensures all components are available
in the system PATH. Returns $true if successful; throws Write-Error on failure.

.PARAMETER PythonVersion
The Python version to ensure. Defaults to "3.12".

.PARAMETER Timeout
Timeout in seconds for installation processes.

.PARAMETER Force
Forces reinstallation of all components.

.EXAMPLE
EnsureHuggingFace

Ensures Python 3.12, pip, and HuggingFace CLI are installed.

.EXAMPLE
EnsureHuggingFace -PythonVersion "3.11" -Force

Forces reinstallation with Python 3.11.

.EXAMPLE
EnsureHuggingFace -Timeout 1200

Ensures installation with a 20-minute timeout.
#>
function EnsureHuggingFace {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Python version to ensure"
        )]
        [ValidatePattern("^\d+\.\d+$")]
        [string] $PythonVersion = "3.12",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Timeout in seconds for installation processes"
        )]
        [ValidateRange(60, 3600)]
        [int] $Timeout = 600,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces reinstallation of all components"
        )]
        [switch] $Force
        #######################################################################
    )

    begin {
        # initialize variables
        $pythonPath = $null
        $clipath = $null
        $cliInstalled = $false
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # show initial progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Hugging Face CLI Installation" `
            -Status "Ensuring dependencies..."
    }

    process {
        try {
            # Step 1: Ensure Python is installed
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Hugging Face CLI Installation" `
                -Status "Ensuring Python ${PythonVersion}..." `
                -PercentComplete 20

            $pythonPath = GenXdev.AI\EnsurePython -Version $PythonVersion -Timeout $Timeout -Force:$Force

            if (-not $pythonPath) {
                Microsoft.PowerShell.Utility\Write-Error "Failed to ensure Python installation"
                return
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Python ensured at: ${pythonPath}"

            # Step 2: Ensure pip is available
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Hugging Face CLI Installation" `
                -Status "Ensuring pip..." `
                -PercentComplete 40

            $pipReady = GenXdev.AI\EnsurePip -PythonPath $pythonPath -Timeout ($Timeout / 2) -Force:$Force

            if (-not $pipReady) {
                Microsoft.PowerShell.Utility\Write-Error "Failed to ensure pip installation"
                return
            }

            Microsoft.PowerShell.Utility\Write-Verbose "pip is ready"

            # Step 3: Determine CLI path and check if already installed
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Hugging Face CLI Installation" `
                -Status "Checking Hugging Face CLI..." `
                -PercentComplete 60

            # determine cli path based on Python installation type
            if ($pythonPath -like "*WindowsApps*") {
                # Windows Store Python - check multiple possible locations
                update-refa$pythonDir = Microsoft.PowerShell.Management\Split-PathmepythonPath -Parent
                $clipath = Microsoft.PowerShell.Management\Join-Path -Path $pythonDir -ChildPath "huggingface-cli.exe"

                # Check user Scripts directory (common for --user installs)
                if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $clipath)) {
                    $userScriptsPath = Microsoft.PowerShell.Management\Join-Path -Path $env:APPDATA -ChildPath "Python\Scripts"
                    if (Microsoft.PowerShell.Management\Test-Path -Path $userScriptsPath) {
                        $clipath = Microsoft.PowerShell.Management\Join-Path -Path $userScriptsPath -ChildPath "huggingface-cli.exe"
                    }
                }
            } else {
                # Regular Python installation
                $scriptsPath = Microsoft.PowerShell.Management\Join-Path `
                    -Path (Microsoft.PowerShell.Management\Split-Path -Path $pythonPath -Parent) `
                    -ChildPath "Scripts"
                $clipath = Microsoft.PowerShell.Management\Join-Path -Path $scriptsPath -ChildPath "huggingface-cli.exe"
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Expected CLI path: ${clipath}"

            # check if CLI is already installed (unless Force is specified)
            if (-not $Force) {
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $clipath) {
                    # try to get version to verify it works
                    $cliversion = & $clipath --help 2>$null
                    if ($cliversion) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Hugging Face CLI already installed at: ${clipath}"
                        $cliInstalled = $true
                    }
                }

                # fallback: check if available via Python module
                if (-not $cliInstalled) {
                    $moduleTest = & $pythonPath -c "import huggingface_hub; print('HuggingFace Hub version:', huggingface_hub.__version__)" 2>$null
                    if ($moduleTest) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Hugging Face CLI available via Python module: $moduleTest"
                        $clipath = "python -m huggingface_hub.commands.huggingface_cli"
                        $cliInstalled = $true
                    }
                }
            }

            # Step 4: Install HuggingFace CLI if needed
            if (-not $cliInstalled) {
                Microsoft.PowerShell.Utility\Write-Progress `
                    -Activity "Hugging Face CLI Installation" `
                    -Status "Installing HuggingFace CLI..." `
                    -PercentComplete 80

                Microsoft.PowerShell.Utility\Write-Verbose "Installing huggingface_hub via pip"

                try {
                    $installArgs = @("-m", "pip", "install", "huggingface_hub", "--user", "--no-warn-script-location")
                    if ($Force) {
                        $installArgs += "--force-reinstall"
                    }

                    $installOutput = & $pythonPath $installArgs 2>&1
                    Microsoft.PowerShell.Utility\Write-Verbose "pip install output: $installOutput"

                } catch {
                    Microsoft.PowerShell.Utility\Write-Error "Failed to install huggingface_hub: $($_.Exception.Message)"
                    return
                }

                # re-check CLI availability after installation
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $clipath) {
                    $cliversion = & $clipath --help 2>$null
                    if ($cliversion) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Hugging Face CLI installed successfully"
                        $cliInstalled = $true
                    }
                } else {
                    # fallback to module approach
                    $moduleTest = & $pythonPath -c "import huggingface_hub; print('HuggingFace Hub version:', huggingface_hub.__version__)" 2>$null
                    if ($moduleTest) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Hugging Face CLI available via Python module: $moduleTest"
                        $clipath = "python -m huggingface_hub.commands.huggingface_cli"
                        $cliInstalled = $true
                    }
                }

                if (-not $cliInstalled) {
                    Microsoft.PowerShell.Utility\Write-Error "Failed to install or verify Hugging Face CLI"
                    return
                }
            }

            # Step 5: Ensure CLI is in PATH (for executable installations)
            if ($clipath -notlike "*python -m*" -and (Microsoft.PowerShell.Management\Test-Path -LiteralPath $clipath)) {
                $cliDir = Microsoft.PowerShell.Management\Split-Path -Path $clipath -Parent
                $currentPath = $env:PATH

                if ($currentPath -notlike "*$cliDir*") {
                    Microsoft.PowerShell.Utility\Write-Verbose "Adding CLI directory to PATH: $cliDir"
                    $env:PATH = $cliDir + ";" + $currentPath

                    # Update user PATH persistently
                    $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
                    if ($userPath -notlike "*$cliDir*") {
                        [System.Environment]::SetEnvironmentVariable("PATH", $cliDir + ";" + $userPath, "User")
                    }
                }
            }

            # Step 6: Store CLI path in JSON configuration
            Microsoft.PowerShell.Utility\Write-Verbose "Storing CLI configuration"

            $jsonpath = GenXdev.FileSystem\Expand-Path `
                "$ENV:LOCALAPPDATA\GenXdev.PowerShell\hfclilocation.json"

            $jsoncontent = $clipath | Microsoft.PowerShell.Utility\ConvertTo-Json

            Microsoft.PowerShell.Management\Set-Content `
                -LiteralPath $jsonpath `
                -Value $jsoncontent `
                -Force

            # check timeout
            if ($stopwatch.Elapsed.TotalSeconds -gt $Timeout) {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Installation timed out after ${Timeout} seconds."
                return
            }

            # complete progress
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Hugging Face CLI Installation" `
                -Status "Installation completed" `
                -PercentComplete 100

            Microsoft.PowerShell.Utility\Write-Verbose "HuggingFace CLI is ready at: ${clipath}"
            return $true

        } catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to ensure Hugging Face CLI: $($_.Exception.Message)"
            return
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Hugging Face CLI Installation" `
            -Completed
    }
}
###############################################################################