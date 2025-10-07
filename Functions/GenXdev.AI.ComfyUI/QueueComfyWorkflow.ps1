<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : QueueComfyWorkflow.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.296.2025
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