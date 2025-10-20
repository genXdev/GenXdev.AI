<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : QueueComfyWorkflow.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.302.2025
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
Submits workflow to ComfyUI processing queue for execution.

.DESCRIPTION
Takes a workflow configuration hashtable and submits it to the ComfyUI server
for processing via the /prompt API endpoint. This function handles the JSON
serialization of the workflow, generates a unique client ID for tracking,
and manages process priority optimization for CPU-based processing.

The function returns a prompt ID that can be used to monitor the workflow's
progress and retrieve results once processing is complete. The workflow
hashtable should contain properly structured ComfyUI nodes with correct
input/output connections as expected by the ComfyUI execution engine.

.PARAMETER Workflow
Hashtable containing the complete workflow configuration with all nodes,
connections, and parameters. This should be a properly structured ComfyUI
workflow definition as created by CreateComfyUniversalWorkflow or similar
workflow generation functions.

.EXAMPLE
$promptId = QueueComfyWorkflow -Workflow $workflowHashtable
Submits a workflow and returns the prompt ID for tracking.

.EXAMPLE
QueueComfyWorkflow $workflow
Submit a simple workflow using positional parameter syntax.

.EXAMPLE
$workflowHashtable | QueueComfyWorkflow
Submit workflow via pipeline input.

.NOTES
This function requires an active ComfyUI server connection and uses the
$script:comfyUIApiUrl variable to determine the API endpoint. The function
automatically optimizes CPU processing by setting idle priority to maintain
system responsiveness during long-running generation tasks.

The returned prompt ID is essential for tracking workflow completion and
should be passed to WaitForComfyCompletion to monitor progress.
#>
function QueueComfyWorkflow {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Hashtable containing the complete workflow " +
                          "configuration"
        )]
        [ValidateNotNullOrEmpty()]
        [hashtable] $Workflow
        #######################################################################
    )

    begin {

        GenXdev.AI\EnsureComfyUI

        # construct api url
        $queueurl = "${script:comfyUIApiUrl}/prompt"

        # generate client id
        $clientid = [System.Guid]::NewGuid().ToString()
    }

    process {

        # create body
        $body = @{
            "prompt"    = $Workflow
            "client_id" = $clientid
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        try {

            # submit to server
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $queueurl `
                -Method POST `
                -Body $body `
                -ContentType "application/json"

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Workflow queued. Prompt ID: $($response.prompt_id)"

            # optimize cpu priority if not gpu
            if (-not $UseGPU) {

                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2

                GenXdev.AI\SetComfyUIProcessPriority

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "CPU processing started with IDLE priority and ${CpuThreads} threads"
            }

            return $response.prompt_id
        }

        catch {

            $errormessage = $_.Exception.Message

            if ($_.Exception -is [System.Net.WebException] -or `
                $_.Exception.InnerException -is [System.Net.WebException]) {

                try {

                    $response = $_.Exception.Response

                    if ($response) {

                        $responsestream = $response.GetResponseStream()

                        $reader = Microsoft.PowerShell.Utility\New-Object System.IO.StreamReader $responsestream

                        $responsecontent = $reader.ReadToEnd()

                        $reader.Close()

                        if ($responsecontent) {

                            $errormessage += ". Server: $responsecontent"
                        }
                    }
                }

                catch {

                    # ignore read error
                }
            }

            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to queue workflow: $errormessage"

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Failed JSON: $body"

            throw
        }
    }

    end {

    }
}
###############################################################################