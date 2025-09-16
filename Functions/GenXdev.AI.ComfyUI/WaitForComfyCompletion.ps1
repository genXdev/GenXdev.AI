<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : WaitForComfyCompletion.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.268.2025
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
Waits for ComfyUI workflow completion with progress monitoring

.DESCRIPTION
Monitors the completion status of a submitted workflow by checking the ComfyUI
history and queue endpoints. Provides visual progress feedback and returns
the completed workflow data when processing is complete.

.PARAMETER PromptId
The unique prompt identifier returned from workflow submission

.EXAMPLE
WaitForComfyCompletion -PromptId "12345678-1234-1234-1234-123456789012"

.EXAMPLE
WaitForComfyCompletion "12345678-1234-1234-1234-123456789012"
#>
function WaitForComfyCompletion {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = ("The unique prompt identifier returned from " +
                          "workflow submission")
        )]
        [string]$PromptId
        #######################################################################
    )

    begin {

        # construct api endpoint url for monitoring workflow completion
        $historyUrl = "${script:comfyUIApiUrl}/history/${PromptId}"

        # determine processing mode for user feedback display
        $processingMode = if ($UseGPU) { "GPU" } else { "CPU" }

        # output processing mode to verbose stream for debugging
        Microsoft.PowerShell.Utility\Write-Verbose ("Processing with " +
            "${processingMode} settings...")

        # initialize progress tracking variables for monitoring
        $startTime = Microsoft.PowerShell.Utility\Get-Date

        # construct path to comfyui log file for progress parsing
        $logFile = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "comfyui.log"

        # initialize tracking variables for progress monitoring
        $lastProgress = -1
        $lastLogPosition = 0
    }

    process {

        # continuous monitoring loop until workflow completion is detected
        while ($true) {

            try {

                # check if workflow processing has completed via api
                $history = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                    -Uri $historyUrl `
                    -Method GET `
                    -Verbose:$false `
                    -ProgressAction Continue `
                    -TimeoutSec 2

                # verify if our specific prompt id has completed processing
                if ($history.$PromptId) {

                    # complete all progress indicators
                    Microsoft.PowerShell.Utility\Write-Progress `
                        -Id 1 `
                        -Activity "ComfyUI Generation" `
                        -Completed

                    Microsoft.PowerShell.Utility\Write-Progress `
                        -Id 2 `
                        -Activity "ComfyUI Live Progress" `
                        -Completed

                    # output completion message to verbose stream
                    Microsoft.PowerShell.Utility\Write-Verbose ("Generation " +
                        "completed!")

                    # return the completed workflow data to caller
                    return $history.$PromptId
                }
            }
            catch {

                # ignore timeouts as they indicate processing is still ongoing
            }

            # parse log file for progress information if it exists
            if (Microsoft.PowerShell.Management\Test-Path `
                    -LiteralPath $logFile) {

                try {

                    # read log content efficiently from last known position
                    $fileStream = [System.IO.FileStream]::new($logFile,
                        [System.IO.FileMode]::Open,
                        [System.IO.FileAccess]::Read,
                        [System.IO.FileShare]::ReadWrite)

                    # seek to last read position to avoid re-reading content
                    $null = $fileStream.Seek($lastLogPosition,
                        [System.IO.SeekOrigin]::Begin)

                    # create reader for efficient text processing
                    $reader = [System.IO.StreamReader]::new($fileStream)

                    # read only new content since last check
                    $newContent = $reader.ReadToEnd()

                    # close file handles to release resources
                    $reader.Close()
                    $fileStream.Close()

                    # update position tracker for next read operation
                    $lastLogPosition = (Microsoft.PowerShell.Management\Get-Item `
                        -LiteralPath $logFile).Length

                    # parse progress information from new log content
                    $progressLines = $newContent -split "`n" |
                        Microsoft.PowerShell.Core\Where-Object {
                            $_ -match '(\d+)\%\s*\|.*\|\s*(\d+)\/(\d+)'
                        }

                    # process progress lines if any were found
                    if ($progressLines) {

                        # get the most recent progress line for display
                        $lastProgressLine = $progressLines[-1]

                        # extract percentage and step information
                        if ($lastProgressLine -match '(\d+)\%\s*\|.*\|\s*(\d+)\/(\d+)') {

                            # parse progress values from regex matches
                            $percent = [int]$matches[1]
                            $currentStep = [int]$matches[2]
                            $totalSteps = [int]$matches[3]

                            # update progress display if value has increased
                            if ($percent -gt $lastProgress) {

                                # format status message with step information
                                $status = ("Processing step ${currentStep} of " +
                                          "${totalSteps}")

                                # calculate estimated time remaining based on progress
                                $secondsRemaining = if ($percent -gt 0) {

                                    # calculate elapsed time since start
                                    $elapsed = (Microsoft.PowerShell.Utility\Get-Date) - $startTime

                                    # estimate total time based on current progress
                                    $totalEstimated = ($elapsed.TotalSeconds / $percent) * 100

                                    # calculate remaining time estimate
                                    [int]($totalEstimated - $elapsed.TotalSeconds)
                                }
                                else {

                                    # no progress yet, cannot estimate time
                                    0
                                }

                                # update progress display with current information
                                Microsoft.PowerShell.Utility\Write-Progress `
                                    -Id 1 `
                                    -Activity "ComfyUI Generation" `
                                    -Status $status `
                                    -PercentComplete $percent `
                                    -SecondsRemaining $secondsRemaining

                                # store current progress for comparison
                                $lastProgress = $percent
                            }
                        }
                    }

                    # extract other relevant status information from log
                    $statusLines = $newContent -split "`n" |
                        Microsoft.PowerShell.Core\Where-Object {
                            ($_ -match 'INFO:') -or
                            ($_ -match 'WARNING:') -or
                            ($_ -match 'ERROR:') -or
                            ($_ -match 'Loading model') -or
                            ($_ -match 'Model loaded') -or
                            ($_ -match 'Saving image')
                        }

                    # process each relevant status line found
                    foreach ($line in $statusLines) {

                        # check if line contains model or image operations
                        if ($line -match 'Loading model|Model loaded|Saving image') {

                            # clean up timestamp and process prefixes from line
                            $cleanLine = $line -replace ('^\d{2}:\d{2}:\d{2}\.\d{3} > ' +
                                '@todesktop/runtime: '), '' -replace ('^\[\d{4}-\d{2}-\d{2} ' +
                                '\d{2}:\d{2}:\d{2},\d{3}\] '), ''

                            # display cleaned status in progress indicator
                            Microsoft.PowerShell.Utility\Write-Progress `
                                -Id 1 `
                                -Activity "ComfyUI Generation" `
                                -Status $cleanLine
                        }
                        else {

                            # output other log lines as verbose information
                            Microsoft.PowerShell.Utility\Write-Verbose $line
                        }
                    }
                }
                catch {

                    # ignore errors reading log file as it might be locked
                    Microsoft.PowerShell.Utility\Write-Verbose ("Could not " +
                        "read log file: $_")
                }
            }

            # attempt to get real-time progress from ComfyUI window title
            try {
                # find ComfyUI processes with main windows
                $comfyProcesses = Microsoft.PowerShell.Management\Get-Process -Name "ComfyUI" |
                    Microsoft.PowerShell.Core\Where-Object {
                        $_.MainWindowHandle -gt 0
                    }

                if ($comfyProcesses -and ($comfyProcesses.Count -gt 0)) {
                    $comfyProcess = $comfyProcesses[0]
                    # safely access window title with additional null checks
                    try {
                        $windowTitle = $comfyProcess.MainWindowTitle
                    }
                    catch {
                        # process might have exited or window closed during access
                        Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI process no longer accessible"
                        $windowTitle = $null
                    }

                    if ($windowTitle -and $windowTitle -ne "") {
                        # extract percentage from title (ComfyUI shows "[75%] Node")
                        if ($windowTitle -match '\[(\d+)%\]') {
                            try {
                                $progressPercent = [int]$matches[1]
                                # validate percentage is within reasonable range
                                if ($progressPercent -ge 0 -and $progressPercent -le 100) {
                                    $comfyUIProgress = "${progressPercent}%"

                                    Microsoft.PowerShell.Utility\Write-Progress `
                                        -Id 2 `
                                        -Activity "ComfyUI Live Progress" `
                                        -Status "ComfyUI: $comfyUIProgress | $windowTitle" `
                                        -PercentComplete $progressPercent

                                    Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI title progress: $windowTitle"
                                }
                            }
                            catch {
                                Microsoft.PowerShell.Utility\Write-Verbose "Could not parse percentage from title: $windowTitle"
                            }
                        }
                        # extract step information (like "Step 15/20" or "Node 15/20")
                        elseif ($windowTitle -match '(?:Step|Node)\s+(\d+)/(\d+)') {
                            try {
                                $currentStep = [int]$matches[1]
                                $totalSteps = [int]$matches[2]
                                # validate step numbers are reasonable
                                if (($currentStep -ge 0) -and ($totalSteps -gt 0) -and ($currentStep -le $totalSteps)) {
                                    $stepPercent = [math]::Round(($currentStep / $totalSteps) * 100, 0)

                                    Microsoft.PowerShell.Utility\Write-Progress `
                                        -Id 2 `
                                        -Activity "ComfyUI Live Progress" `
                                        -Status "ComfyUI: Step $currentStep/$totalSteps | $windowTitle" `
                                        -PercentComplete $stepPercent

                                    Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI step progress: $windowTitle"
                                }
                            }
                            catch {
                                Microsoft.PowerShell.Utility\Write-Verbose "Could not parse step information from title: $windowTitle"
                            }
                        }
                        # fallback for any ComfyUI activity (display only, no percentage)
                        elseif ($windowTitle -match 'ComfyUI') {
                            Microsoft.PowerShell.Utility\Write-Progress `
                                -Id 2 `
                                -Activity "ComfyUI Live Progress" `
                                -Status "ComfyUI: $windowTitle"

                            Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI activity: $windowTitle"
                        }
                    }
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Could not read ComfyUI window title: $_"
            }

            # wait before next status check to avoid excessive polling
            Microsoft.PowerShell.Utility\Start-Sleep -Seconds 1
        }
    }

    end {
    }
}
###############################################################################