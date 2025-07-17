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
        [switch]$Passthru
        ########################################################################
    )

    begin {

        # verify lm studio installation
        Microsoft.PowerShell.Utility\Write-Verbose 'Checking LM Studio installation...'
        if (-not (Test-LMStudioInstallation)) {

            if ($PSCmdlet.ShouldProcess('LM Studio', 'Install application')) {
                Microsoft.PowerShell.Utility\Write-Verbose 'LM Studio not found, initiating installation...'
                $null = Install-LMStudioApplication
            }
        }
    }


    process {

        # check if we need to start or show the process
        if (-not (Test-LMStudioProcess -ShowWindow:$ShowWindow) -or $ShowWindow) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Preparing to start or show LM Studio...'

            # get installation paths
            $paths = Get-LMStudioPaths

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

                while (-not (Test-LMStudioProcess) -and
                    ($timer.Elapsed.TotalSeconds -lt $timeout)) {

                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds 1
                }

                if (-not (Test-LMStudioProcess)) {
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