<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : EnsurePython.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.308.2025
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
Ensures Python is installed and available in the system PATH.

.DESCRIPTION
Verifies that Python is installed and accessible via the system PATH. If Python
is not found, attempts to install it using winget (Windows Package Manager).
Supports specific version requirements and provides progress feedback during
installation. Returns the path to the Python executable if successful; throws
Write-Error on failure.

This function prioritizes existing Python installations but can force
reinstallation when needed. It validates Python functionality by checking
version output and ensures the installation is properly accessible.

.PARAMETER Version
The Python version to ensure is installed. Defaults to "3.12". Must follow
the format "major.minor" (e.g., "3.11", "3.12").

.PARAMETER Timeout
Timeout in seconds for Python installation process. Defaults to 600 seconds
(10 minutes) to accommodate download and installation time.

.PARAMETER Force
Forces reinstallation of Python even if it's already available. Useful for
updating corrupted installations or ensuring the latest version.

.EXAMPLE
EnsurePython

Ensures Python 3.12 is installed using default settings.

.EXAMPLE
$pythonPath = EnsurePython -Version "3.11" -Timeout 900

Installs Python 3.11 with extended timeout and returns the executable path.

.EXAMPLE
EnsurePython -Force -Verbose

Forces reinstallation of Python 3.12 with detailed progress information.

.EXAMPLE
EnsurePython -Version "3.10" -Force

Forces installation of Python 3.10 even if another version exists.
#>
function EnsurePython {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Python version to ensure is installed"
        )]
        [ValidatePattern("^\d+\.\d+(\.\d+)?$")]
        [string] $Version = "3.12",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Timeout in seconds for Python installation"
        )]
        [ValidateRange(60, 3600)]
        [int] $Timeout = 600,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces reinstallation of Python"
        )]
        [switch] $Force
        #######################################################################
    )

    begin {
        # initialize variables
        $pythonPath = $null
        $pythonInstalled = $false
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # show initial progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Python Installation" `
            -Status "Checking Python availability..."
    }

    process {
        try {
            # check if python is already available (unless Force is specified)
            if (-not $Force) {
                Microsoft.PowerShell.Utility\Write-Progress `
                    -Activity "Python Installation" `
                    -Status "Checking existing Python installation..." `
                    -PercentComplete 20

                # Function to check if found version is compatible with requested version
                function Test-VersionCompatibility {
                    param(
                        [string]$FoundVersion,
                        [string]$RequestedVersion
                    )

                    if (-not $FoundVersion -or -not $RequestedVersion) { return $false }

                    $foundParts = $FoundVersion.Split('.')
                    $requestedParts = $RequestedVersion.Split('.')

                    # Must match major.minor at minimum
                    if ($foundParts.Length -ge 2 -and $requestedParts.Length -ge 2) {
                        $foundMajorMinor = "$($foundParts[0]).$($foundParts[1])"
                        $requestedMajorMinor = "$($requestedParts[0]).$($requestedParts[1])"

                        if ($foundMajorMinor -eq $requestedMajorMinor) {
                            # If only major.minor requested (e.g., "3.12"), accept any patch version
                            if ($requestedParts.Length -eq 2) {
                                return $true
                            }
                            # If patch version specified, found version should be >= requested
                            if ($requestedParts.Length -eq 3 -and $foundParts.Length -ge 3) {
                                try {
                                    $foundPatch = [int]$foundParts[2]
                                    $requestedPatch = [int]$requestedParts[2]
                                    return $foundPatch -ge $requestedPatch
                                } catch {
                                    # If patch version parsing fails, accept major.minor match
                                    return $true
                                }
                            }
                            return $true
                        }
                    }

                    return $false
                }

                # Function to check Python installation and version
                function Test-PythonInstallation {
                    param([string]$PythonExePath)

                    if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $PythonExePath)) { return $null }

                    try {
                        $versionOutput = & $PythonExePath --version 2>$null
                        if ($versionOutput -and $versionOutput -match "Python (\d+\.\d+(\.\d+)?)") {
                            return $Matches[1]
                        }
                    } catch {
                        return $null
                    }
                    return $null
                }

                # Function to add Python to PATH if needed
                function Add-PythonToPath {
                    param([string]$PythonExePath)

                    $pythonDir = Microsoft.PowerShell.Management\Split-Path $PythonExePath -Parent
                    $scriptsDir = Microsoft.PowerShell.Management\Join-Path $pythonDir "Scripts"

                    $currentPath = $env:PATH
                    $pathsToAdd = @()

                    if ($currentPath -notlike "*$pythonDir*") {
                        $pathsToAdd += $pythonDir
                    }

                    if ((Microsoft.PowerShell.Management\Test-Path -LiteralPath $scriptsDir) -and ($currentPath -notlike "*$scriptsDir*")) {
                        $pathsToAdd += $scriptsDir
                    }

                    if ($pathsToAdd.Count -gt 0) {
                        $env:PATH = ($pathsToAdd -join ";") + ";" + $env:PATH
                        Microsoft.PowerShell.Utility\Write-Verbose "Added to PATH: $($pathsToAdd -join ', ')"
                    }
                }

                # First, check if python is in PATH
                $pythonCmd = Microsoft.PowerShell.Core\Get-Command python -ErrorAction SilentlyContinue
                if ($pythonCmd) {
                    $foundVersion = Test-PythonInstallation -PythonExePath $pythonCmd.Source
                    if ($foundVersion -and (Test-VersionCompatibility -FoundVersion $foundVersion -RequestedVersion $Version)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Python ${foundVersion} already available in PATH at: $($pythonCmd.Source) (compatible with ${Version})"
                        return $pythonCmd.Source
                    }
                }

                # Search common Python installation locations
                $versionForPath = $Version -replace '\.', ''
                if ($Version.Split('.').Count -eq 3) {
                    # For x.y.z versions, use x.y for path (e.g., 3.12.11 -> 312)
                    $majorMinor = ($Version.Split('.')[0..1] -join '.')
                    $versionForPath = $majorMinor -replace '\.', ''
                }

                $commonPaths = @(
                    "$env:LOCALAPPDATA\Programs\Python\Python$versionForPath\python.exe",
                    "$env:LOCALAPPDATA\Programs\Python\Python$versionForPath-32\python.exe",
                    "$env:PROGRAMFILES\Python$versionForPath\python.exe",
                    "$env:PROGRAMFILES(X86)\Python$versionForPath\python.exe",
                    "$env:USERPROFILE\AppData\Local\Programs\Python\Python$versionForPath\python.exe",
                    "$env:USERPROFILE\AppData\Local\Programs\Python\Python$versionForPath-32\python.exe"
                )

                # Also search for any Python installations via registry or common paths
                $pythonVersions = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath "$env:LOCALAPPDATA\Programs\Python" -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Core\Where-Object { $_.Name -like "Python*" }

                foreach ($pythonDir in $pythonVersions) {
                    $pythonExe = Microsoft.PowerShell.Management\Join-Path $pythonDir.FullName "python.exe"
                    $commonPaths += $pythonExe
                }

                foreach ($pythonPath in $commonPaths) {
                    $foundVersion = Test-PythonInstallation -PythonExePath $pythonPath
                    if ($foundVersion -and (Test-VersionCompatibility -FoundVersion $foundVersion -RequestedVersion $Version)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Found Python ${foundVersion} at: ${pythonPath} (compatible with ${Version})"
                        Add-PythonToPath -PythonExePath $pythonPath
                        return $pythonPath
                    }
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Python ${Version} not found in common locations"
            }

            # check for winget availability
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Python Installation" `
                -Status "Checking winget availability..." `
                -PercentComplete 30

            if (-not (Microsoft.PowerShell.Core\Get-Command winget -ErrorAction SilentlyContinue)) {
                Microsoft.PowerShell.Utility\Write-Error `
                    "winget (Windows Package Manager) is not installed. Please install winget and try again."
                return
            }

            # search for requested python version
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Python Installation" `
                -Status "Searching for Python ${Version}..." `
                -PercentComplete 40

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Searching for Python ${Version} via winget"

            # For winget, use major.minor version for package ID (e.g., 3.12.11 -> 3.12)
            $packageVersion = $Version
            if ($Version.Split('.').Count -eq 3) {
                $packageVersion = ($Version.Split('.')[0..1] -join '.')
            }
            $packageId = "Python.Python.${packageVersion}"
            $pythonSearch = winget search python --id $packageId --exact 2>$null

            if (-not $pythonSearch -or $pythonSearch -match "No package found") {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Python ${Version} not found via winget. Available versions may be different."
                return
            }

            # request consent for python installation
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Python Installation" `
                -Status "Requesting installation consent..." `
                -PercentComplete 50

            try {
                $consentResult = GenXdev.FileSystem\Confirm-InstallationConsent `
                    -ApplicationName "Python ${Version}" `
                    -Source "Winget" `
                    -Description "Python interpreter and runtime environment for executing Python scripts and applications" `
                    -Publisher "Python Software Foundation"

                if (-not $consentResult) {
                    Microsoft.PowerShell.Utility\Write-Error `
                        "Python ${Version} installation was declined by user."
                    return
                }
            } catch {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to confirm installation consent: $($_.Exception.Message)"
                return
            }

            # install python via winget
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Python Installation" `
                -Status "Installing Python ${Version}..." `
                -PercentComplete 60

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Installing Python ${Version} via winget"

            try {
                $installArgs = @(
                    "install",
                    "--id", $packageId,
                    "--exact",
                    "--scope", "user",
                    "--accept-package-agreements",
                    "--accept-source-agreements",
                    "--silent"
                )

                $installResult = & winget $installArgs 2>&1

                Microsoft.PowerShell.Utility\Write-Verbose "winget install result: $installResult"

            } catch {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to install Python ${Version} via winget: $($_.Exception.Message)"
                return
            }

            # wait for python to be available and refresh PATH
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Python Installation" `
                -Status "Verifying Python installation..." `
                -PercentComplete 80

            # refresh environment variables from registry
            $machinePath = [System.Environment]::GetEnvironmentVariable("PATH", "Machine")
            $userPath = [System.Environment]::GetEnvironmentVariable("PATH", "User")
            $env:PATH = $machinePath + ";" + $userPath

            # give some time for installation to complete
            Microsoft.PowerShell.Utility\Start-Sleep -Seconds 3

            # try to find python command again
            $attempts = 0
            $maxAttempts = 15

            while ($attempts -lt $maxAttempts) {
                # First check if python is now in PATH
                $pythonCmd = Microsoft.PowerShell.Core\Get-Command python -ErrorAction SilentlyContinue
                if ($pythonCmd) {
                    $foundVersion = Test-PythonInstallation -PythonExePath $pythonCmd.Source
                    if ($foundVersion -and (Test-VersionCompatibility -FoundVersion $foundVersion -RequestedVersion $Version)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Python ${foundVersion} successfully available in PATH at: $($pythonCmd.Source) (compatible with ${Version})"
                        $pythonPath = $pythonCmd.Source
                        $pythonInstalled = $true
                        break
                    }
                }

                # If not in PATH, search common installation locations again
                $versionForPath = $Version -replace '\.', ''
                if ($Version.Split('.').Count -eq 3) {
                    # For x.y.z versions, use x.y for path (e.g., 3.12.11 -> 312)
                    $majorMinor = ($Version.Split('.')[0..1] -join '.')
                    $versionForPath = $majorMinor -replace '\.', ''
                }

                $commonPaths = @(
                    "$env:LOCALAPPDATA\Programs\Python\Python$versionForPath\python.exe",
                    "$env:LOCALAPPDATA\Programs\Python\Python$versionForPath-32\python.exe",
                    "$env:PROGRAMFILES\Python$versionForPath\python.exe",
                    "$env:PROGRAMFILES(X86)\Python$versionForPath\python.exe",
                    "$env:USERPROFILE\AppData\Local\Programs\Python\Python$versionForPath\python.exe",
                    "$env:USERPROFILE\AppData\Local\Programs\Python\Python$versionForPath-32\python.exe"
                )

                foreach ($testPath in $commonPaths) {
                    $foundVersion = Test-PythonInstallation -PythonExePath $testPath
                    if ($foundVersion -and (Test-VersionCompatibility -FoundVersion $foundVersion -RequestedVersion $Version)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Found Python ${foundVersion} at: ${testPath} (compatible with ${Version})"
                        Add-PythonToPath -PythonExePath $testPath
                        $pythonPath = $testPath
                        $pythonInstalled = $true
                        break
                    }
                }

                if ($pythonInstalled) { break }

                $attempts++
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2
            }

            if (-not $pythonInstalled) {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to verify Python ${Version} installation. Python may not be in PATH."
                return
            }

            # check timeout
            if ($stopwatch.Elapsed.TotalSeconds -gt $Timeout) {
                Microsoft.PowerShell.Utility\Write-Error `
                    "Python installation timed out after ${Timeout} seconds."
                return
            }

            # complete progress
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Python Installation" `
                -Status "Python installation completed" `
                -PercentComplete 100

            Microsoft.PowerShell.Utility\Write-Verbose "Python is ready at: ${pythonPath}"
            return $pythonPath

        } catch {
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to ensure Python installation: $($_.Exception.Message)"
            return
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Python Installation" `
            -Completed
    }
}
###############################################################################