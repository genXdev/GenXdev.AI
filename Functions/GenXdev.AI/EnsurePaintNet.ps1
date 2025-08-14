###############################################################################
<#
.SYNOPSIS
Ensures Paint.NET is properly installed and accessible on the system.

.DESCRIPTION
Performs comprehensive checks and setup for Paint.NET:
- Verifies if Paint.NET is installed and accessible in PATH
- Installs Paint.NET via WinGet if not present
- Configures system PATH environment variable
- Ensures paintdotnet.exe is available for command-line usage
The function handles all prerequisites and ensures a working Paint.NET installation.

.EXAMPLE
EnsurePaintNet
This will verify and setup Paint.NET if needed.
#>
function EnsurePaintNet {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param()

    begin {
        # ensure graphics assembly is loaded for image processing
        if (-not [System.Drawing.Rectangle]) {

            Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Drawing
        }

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
                Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client' -ErrorAction Stop
                $ModuleObj = Microsoft.PowerShell.Core\Get-Module 'Microsoft.WinGet.Client' -ErrorAction Stop
                return $null -ne $ModuleObj
            }
            catch [System.IO.FileNotFoundException] {
                Microsoft.PowerShell.Utility\Write-Verbose 'WinGet module not found'
                return $false
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Error checking WinGet installation: $_"
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
                Microsoft.PowerShell.Utility\Write-Verbose 'Installing WinGet PowerShell client...'
                PowerShellGet\Install-Module 'Microsoft.WinGet.Client' -Force -AllowClobber -ErrorAction Stop
                Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client' -ErrorAction Stop
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
        try {
            # First, ensure current session PATH is up to date with both Machine and User PATH
            $paintNetPath = 'C:\Program Files\paint.net'

            # Only add Paint.NET path to user PATH if it's not already present
            $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
            if ($userPath -notlike "*$paintNetPath*") {
                $userPath = "$userPath;$paintNetPath"
                [System.Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')
            }

            # Only update session PATH if Paint.NET path is not already in current session
            if ($env:PATH -notlike "*$paintNetPath*") {
                $env:PATH = "$env:PATH;$paintNetPath"
            }

            # Check if Paint.NET is already accessible
            Microsoft.PowerShell.Utility\Write-Verbose 'Paint.NET not found in PATH, checking installation...'

            # Check again after updating PATH
            if (@(Microsoft.PowerShell.Core\Get-Command 'paintdotnet.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

                Microsoft.PowerShell.Utility\Write-Verbose 'Installing Paint.NET...'

                if (-not (IsWinGetInstalled)) {

                    InstallWinGet
                }

                try {
                    $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'dotPDN.PaintDotNet' -Force
                }
                catch {
                    throw "Failed to install Paint.NET via WinGet: $_"
                }                    # Update PATH after installation
                $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
                if ($userPath -notlike "*$paintNetPath*") {
                    try {
                        Microsoft.PowerShell.Utility\Write-Verbose 'Adding Paint.NET to User PATH after installation...'
                        [Environment]::SetEnvironmentVariable(
                            'PATH',
                            "$userPath;$paintNetPath",
                            'User')
                        # Update current session PATH only if not already present
                        if ($env:PATH -notlike "*$paintNetPath*") {
                            $env:PATH = "$env:PATH;$paintNetPath"
                        }
                    }
                    catch [System.Security.SecurityException] {
                        throw "Access denied while updating PATH environment variable: $_"
                    }
                }

                if (-not (Microsoft.PowerShell.Core\Get-Command 'paintdotnet.exe' -ErrorAction SilentlyContinue)) {
                    throw 'Paint.NET installation failed: paintdotnet.exe not found after installation'
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Paint.NET is now available at: $(Microsoft.PowerShell.Core\Get-Command 'paintdotnet.exe' -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object -ExpandProperty Source)"
        }
        catch {
            $errorMessage = "Failed to setup Paint.NET: $($_.Exception.Message)"
            Microsoft.PowerShell.Utility\Write-Error -Exception $_.Exception -Message $errorMessage -Category OperationStopped
            throw
        }
    }

    end {}
}