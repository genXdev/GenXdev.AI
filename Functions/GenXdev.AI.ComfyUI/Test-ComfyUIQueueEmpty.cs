// ################################################################################
// Part of PowerShell module : GenXdev.AI.ComfyUI
// Original cmdlet filename  : Test-ComfyUIQueueEmpty.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.308.2025
// ################################################################################
// Copyright (c)  René Vaessen / GenXdev
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// ################################################################################



using System;
using System.Management.Automation;

namespace GenXdev.AI.ComfyUI
{
    /// <summary>
    /// <para type="synopsis">
    /// Checks if the ComfyUI processing queue is empty
    /// </para>
    ///
    /// <para type="description">
    /// Queries the ComfyUI /queue endpoint to determine if there are any pending
    /// or running tasks. This function is useful for determining whether it's safe
    /// to shut down ComfyUI without interrupting ongoing processing.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// This cmdlet has no parameters.
    /// </para>
    ///
    /// <example>
    /// <para>Test-ComfyUIQueueEmpty</para>
    /// <para>Returns $true if the queue is empty, $false if there are pending tasks.</para>
    /// <code>
    /// Test-ComfyUIQueueEmpty
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>if (Test-ComfyUIQueueEmpty) { Stop-ComfyUI }</para>
    /// <para>Conditionally shuts down ComfyUI only if no tasks are queued.</para>
    /// <code>
    /// if (Test-ComfyUIQueueEmpty) { Stop-ComfyUI }
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsDiagnostic.Test, "ComfyUIQueueEmpty")]
    [OutputType(typeof(bool))]
    public class TestComfyUIQueueEmptyCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - ensure ComfyUI is running and get API URL
        /// </summary>
        protected override void BeginProcessing()
        {
            // Ensure ComfyUI is running
            InvokeScript<object>("GenXdev.AI\\EnsureComfyUI");
        }

        /// <summary>
        /// Process record - check if queue is empty
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                // Get the ComfyUI API URL from script scope
                string apiUrl = InvokeScript<string>("$comfyUIApiUrl");

                // Construct queue API endpoint URL
                string queueUrl = apiUrl + "/queue";

                // Query the queue endpoint to get current status
                string restScript = $"Microsoft.PowerShell.Utility\\Invoke-RestMethod -Verbose:$false -ProgressAction Continue -Uri '{queueUrl}' -Method GET -TimeoutSec 3";
                var queueResponse = InvokeScript<object>(restScript);

                // Analyze queue response structure
                bool queueEmpty = true;

                // Check for pending tasks in queue_pending
                var queuePending = queueResponse as dynamic;
                if (queuePending != null && queuePending.queue_pending != null)
                {
                    var pendingCount = ((object[])queuePending.queue_pending).Length;
                    if (pendingCount > 0)
                    {
                        WriteVerbose($"Found {pendingCount} pending tasks in queue");
                        queueEmpty = false;
                    }
                }

                // Check for running tasks in queue_running
                if (queuePending != null && queuePending.queue_running != null)
                {
                    var runningCount = ((object[])queuePending.queue_running).Length;
                    if (runningCount > 0)
                    {
                        WriteVerbose($"Found {runningCount} running tasks in queue");
                        queueEmpty = false;
                    }
                }

                // Verbose output for debugging
                if (queueEmpty)
                {
                    WriteVerbose("ComfyUI queue is empty");
                }
                else
                {
                    WriteVerbose("ComfyUI queue has active tasks");
                }

                WriteObject(queueEmpty);
            }
            catch (Exception ex)
            {
                // If queue endpoint is not accessible, assume it's safe to shutdown
                WriteVerbose($"Could not access ComfyUI queue endpoint: {ex.Message}");
                WriteVerbose("Assuming queue is empty for shutdown purposes");
                WriteObject(true);
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}
// ###############################################################################