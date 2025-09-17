<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Start-LMStudioApplication.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.274.2025
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
Starts the LM Studio application if it's not already running.

.DESCRIPTION
This function checks if LM Studio is installed and running. If not installed, it
will install it. If not running, it will start it with the specified window
visibility.

.PARAMETER ShowWindow
Determines if the LM Studio window should be visible after starting.

.PARAMETER Passthru
When specified, returns the Process object of the LM Studio application.

.EXAMPLE
Start-LMStudioApplication -ShowWindow -Passthru
#>
function Start-LMStudioApplication {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return the Process object'
        )]
        [Alias('pt')]
        [switch]$Passthru,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show LM Studio window after starting'
        )]
        [switch]$ShowWindow
        ########################################################################
    )

    begin {

        # verify lm studio installation
        Microsoft.PowerShell.Utility\Write-Verbose 'Checking LM Studio installation...'
        if (-not (GenXdev.AI\Test-LMStudioInstallation)) {

            if ($PSCmdlet.ShouldProcess('LM Studio', 'Install application')) {
                Microsoft.PowerShell.Utility\Write-Verbose 'LM Studio not found, initiating installation...'
                $null = GenXdev.AI\Install-LMStudioApplication
            }
        }
    }


    process {

        # check if we need to start or show the process
        if (-not (GenXdev.AI\Test-LMStudioProcess -ShowWindow:$ShowWindow) -or $ShowWindow) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Preparing to start or show LM Studio...'

            # get installation paths
            $paths = GenXdev.AI\Get-LMStudioPaths

            # validate executable path
            if (-not $paths.LMStudioExe) {
                throw 'LM Studio executable could not be located'
            }

            if ($PSCmdlet.ShouldProcess('LM Studio', 'Start application')) {
                # start background job for non-blocking operation
                $jobParams = @{
                    ScriptBlock  = {
                        param($paths, $showWindow)

                        # start server component
                        $null = Microsoft.PowerShell.Management\Start-Process `
                            -FilePath $paths.LMSExe `
                            -ArgumentList 'server', 'start', '--port', '1234'
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 4
                        $null = Microsoft.PowerShell.Management\Start-Process `
                            -FilePath $paths.LMStudioExe
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 4

                    }
                    ArgumentList = @($paths, ($ShowWindow -eq $true))
                }

                $null = Microsoft.PowerShell.Core\Start-Job @jobParams | Microsoft.PowerShell.Core\Wait-Job

                # verify process starts within timeout period
                Microsoft.PowerShell.Utility\Write-Verbose 'Waiting for LM Studio process...'
                $timeout = 30
                $timer = [System.Diagnostics.Stopwatch]::StartNew()

                while (-not (GenXdev.AI\Test-LMStudioProcess) -and
                    ($timer.Elapsed.TotalSeconds -lt $timeout)) {

                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds 1
                }

                if (-not (GenXdev.AI\Test-LMStudioProcess)) {
                    throw "LM Studio failed to start within $timeout seconds"
                }
            }
        }

        # return process object if requested
        if ($Passthru) {
            Microsoft.PowerShell.Management\Get-Process -Name 'LM Studio' -ErrorAction Stop |
                Microsoft.PowerShell.Core\Where-Object -Property MainWindowHandle -NE 0 |
                Microsoft.PowerShell.Utility\Select-Object -First 1
        }
    }
}