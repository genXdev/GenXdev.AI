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
Start-LMStudioApplication -ShowWindow -Passthru
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
        [Alias("sw")]
        [switch]$ShowWindow,
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
        if (-not (Test-LMStudioProcess) -or $ShowWindow) {

            Write-Verbose "Preparing to start or show LM Studio..."

            # get installation paths
            $paths = Get-LMStudioPaths

            # validate executable path
            if (-not $paths.LMStudioExe) {
                throw "LM Studio executable could not be located"
            }

            # start background job for non-blocking operation
            $jobParams = @{
                ScriptBlock = {
                    param($paths, $showWindow)

                    # start server component
                    $null = Start-Process `
                        -FilePath $paths.LMSExe `
                        -ArgumentList "server", "start", "--port", "1234" `
                        -NoNewWindow
                    Start-Sleep -Seconds 4

                    if ($showWindow) {
                        # launch ui component
                        $null = Start-Process `
                            -FilePath $paths.LMStudioExe `
                            -WindowStyle "Normal"
                        Start-Sleep -Seconds 3

                        # ensure window visibility and focus
                        Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue |
                            Where-Object { $_.MainWindowHandle -ne 0 } |
                            ForEach-Object {
                                [GenXdev.Helpers.WindowObj]$window = `
                                    Get-Window -ProcessId $_.Id

                                if ($null -ne $window) {
                                    $null = $window.Show()
                                    $null = $window.SetForeground()
                                }

                                $null = Set-ForegroundWindow `
                                    -WindowHandle $_.MainWindowHandle
                            }

                        Start-Sleep -Seconds 2
                    }
                }
                ArgumentList = @($paths, ($true -eq $ShowWindow))
            }

            $null = Start-Job @jobParams | Wait-Job
            Start-Sleep -Seconds 6

            # verify process starts within timeout period
            Write-Verbose "Waiting for LM Studio process..."
            $timeout = 30
            $timer = [System.Diagnostics.Stopwatch]::StartNew()

            while (-not (Test-LMStudioProcess) -and
                   ($timer.Elapsed.TotalSeconds -lt $timeout)) {
                Start-Sleep -Seconds 2
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
    }
}
################################################################################