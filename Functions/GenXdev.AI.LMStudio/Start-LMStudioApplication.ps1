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

    [CmdletBinding()]
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
        Write-Verbose "Checking LM Studio installation..."
        if (-not (Test-LMStudioInstallation)) {

            Write-Verbose "LM Studio not found, initiating installation..."
            $null = Install-LMStudioApplication
        }
    }

    process {

        # check if we need to start or show the process
        if (-not (Test-LMStudioProcess -ShowWindow:$ShowWindow) -or $ShowWindow) {

            Write-Verbose "Preparing to start or show LM Studio..."

            # get installation paths
            $paths = Get-LMStudioPaths

            # validate executable path
            if (-not $paths.LMStudioExe) {
                throw "LM Studio executable could not be located"
            }

            # start background job for non-blocking operation
            $jobParams = @{
                ScriptBlock  = {
                    param($paths, $showWindow)

                    # start server component
                    $null = Start-Process `
                        -FilePath $paths.LMSExe `
                        -ArgumentList "server", "start", "--port", "1234" `
                        -NoNewWindow
                    Start-Sleep -Seconds 4
                }
                ArgumentList = @($paths, ($ShowWindow -eq $true))
            }

            $null = Start-Job @jobParams | Wait-Job

            if ($showWindow) {

                $null = Get-LMStudioWindow -ShowWindow -NoAutoStart -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
            }

            # verify process starts within timeout period
            Write-Verbose "Waiting for LM Studio process..."
            $timeout = 30
            $timer = [System.Diagnostics.Stopwatch]::StartNew()

            while (-not (Test-LMStudioProcess) -and
                   ($timer.Elapsed.TotalSeconds -lt $timeout)) {

                Start-Sleep -Seconds 1
            }

            if (-not (Test-LMStudioProcess)) {
                throw "LM Studio failed to start within $timeout seconds"
            }
        }

        # return process object if requested
        if ($Passthru) {
            Get-Process -Name "LM Studio" -ErrorAction Stop
        }
    }

    end {
        if ($ShowWindow) {

            $null = Get-LMStudioWindow -NoAutoStart -ShowWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }
}
################################################################################