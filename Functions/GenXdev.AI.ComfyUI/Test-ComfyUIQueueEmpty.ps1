<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Test-ComfyUIQueueEmpty.ps1
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