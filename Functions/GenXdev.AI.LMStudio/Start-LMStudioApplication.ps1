################################################################################
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
Start-LMStudioApplication -WithVisibleWindow -Passthru
#>
function Start-LMStudioApplication {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Show or hide the LM Studio window after starting"
        )]
        [Alias("sw", "ShowWindow")]
        [switch]$WithVisibleWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Return the Process object"
        )]
        [Alias("pt")]
        [switch]$Passthru
        ########################################################################
    )

    begin {

        # verify lm studio installation
        Microsoft.PowerShell.Utility\Write-Verbose "Checking LM Studio installation..."
        if (-not (GenXdev.AI\Test-LMStudioInstallation)) {

            if ($PSCmdlet.ShouldProcess("LM Studio", "Install application")) {
                Microsoft.PowerShell.Utility\Write-Verbose "LM Studio not found, initiating installation..."
                $null = GenXdev.AI\Install-LMStudioApplication
            }
        }
    }

    process {

        # check if we need to start or show the process
        if (-not (GenXdev.AI\Test-LMStudioProcess -ShowWindow:$ShowWindow) -or $ShowWindow) {

            Microsoft.PowerShell.Utility\Write-Verbose "Preparing to start or show LM Studio..."

            # get installation paths
            $paths = GenXdev.AI\Get-LMStudioPaths

            # validate executable path
            if (-not $paths.LMStudioExe) {
                throw "LM Studio executable could not be located"
            }

            if ($PSCmdlet.ShouldProcess("LM Studio", "Start application")) {
                # start background job for non-blocking operation
                $jobParams = @{
                    ScriptBlock  = {
                        param($paths, $showWindow)

                        # start server component
                        $null = Microsoft.PowerShell.Management\Start-Process `
                            -FilePath $paths.LMSExe `
                            -ArgumentList "server", "start", "--port", "1234" `
                            -NoNewWindow
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 4
                    }
                    ArgumentList = @($paths, ($ShowWindow -eq $true))
                }

                $null = Microsoft.PowerShell.Core\Start-Job @jobParams | Microsoft.PowerShell.Core\Wait-Job

                if ($showWindow) {

                    $null = GenXdev.AI\Get-LMStudioWindow -ShowWindow -NoAutoStart -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                }

                # verify process starts within timeout period
                Microsoft.PowerShell.Utility\Write-Verbose "Waiting for LM Studio process..."
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
            Microsoft.PowerShell.Management\Get-Process -Name "LM Studio" -ErrorAction Stop
        }
    }

    end {
        if ($ShowWindow -and $PSCmdlet.ShouldProcess("LM Studio", "Show window")) {
            $null = GenXdev.AI\Get-LMStudioWindow -NoAutoStart -ShowWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }
}
################################################################################