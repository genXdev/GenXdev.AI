<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Test-ComfyUIQueueEmpty.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.272.2025
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
Checks if the ComfyUI processing queue is empty

.DESCRIPTION
Queries the ComfyUI /queue endpoint to determine if there are any pending
or running tasks. This function is useful for determining whether it's safe
to shut down ComfyUI without interrupting ongoing processing.

.EXAMPLE
Test-ComfyUIQueueEmpty

Returns $true if the queue is empty, $false if there are pending tasks.

.EXAMPLE
if (Test-ComfyUIQueueEmpty) { Stop-ComfyUI }

Conditionally shuts down ComfyUI only if no tasks are queued.

.NOTES
This function requires an active ComfyUI server connection and uses the
$script:comfyUIApiUrl variable to determine the API endpoint. If the queue
endpoint is not accessible, the function assumes the queue is empty to
avoid blocking shutdown.
#>
function Test-ComfyUIQueueEmpty {

    [CmdletBinding()]

    param()

    begin {

        GenXdev.AI\EnsureComfyUI

        # construct queue api endpoint url
        $queueUrl = "${script:comfyUIApiUrl}/queue"
    }

    process {

        try {

            # query the queue endpoint to get current status
            $queueResponse = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $queueUrl `
                -Method GET `
                -TimeoutSec 3

            # analyze queue response structure
            $queueEmpty = $true

            # check for pending tasks in queue_pending
            if ($queueResponse.queue_pending -and ($queueResponse.queue_pending.Count -gt 0)) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Found $($queueResponse.queue_pending.Count) pending tasks in queue"

                $queueEmpty = $false
            }

            # check for running tasks in queue_running
            if ($queueResponse.queue_running -and ($queueResponse.queue_running.Count -gt 0)) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Found $($queueResponse.queue_running.Count) running tasks in queue"

                $queueEmpty = $false
            }

            # verbose output for debugging
            if ($queueEmpty) {

                Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI queue is empty"
            } else {

                Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI queue has active tasks"
            }

            return $queueEmpty
        }

        catch {

            # if queue endpoint is not accessible, assume it's safe to shutdown
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Could not access ComfyUI queue endpoint: $($_.Exception.Message)"

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Assuming queue is empty for shutdown purposes"

            return $true
        }
    }

    end {

    }
}
###############################################################################