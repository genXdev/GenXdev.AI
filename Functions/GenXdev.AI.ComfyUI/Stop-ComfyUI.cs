// ################################################################################
// Part of PowerShell module : GenXdev.AI.ComfyUI
// Original cmdlet filename  : Stop-ComfyUI.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.304.2025
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
using System.Diagnostics;
using System.Management.Automation;
using System.Threading;

namespace GenXdev.AI.ComfyUI
{
    /// <summary>
    /// <para type="synopsis">
    /// Terminates all running ComfyUI processes and releases associated resources.
    /// </para>
    ///
    /// <para type="description">
    /// Safely stops all processes related to ComfyUI by identifying processes with
    /// the name 'comfyui'. This cmdlet is used to clean up ComfyUI processes after
    /// image generation or when a forced shutdown is requested. It provides verbose
    /// feedback for debugging and handles cases where no ComfyUI processes are
    /// running.
    /// </para>
    ///
    /// <example>
    /// <para>Terminates ComfyUI processes with detailed output for debugging.</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Stop-ComfyUI -Verbose
    /// </code>
    /// </example>
    ///
    /// <para type="description">
    /// This cmdlet is designed to be called by other ComfyUI-related cmdlets, such
    /// as Invoke-ComfyUIImageGeneration, particularly when the -Force parameter is used or
    /// when -KeepComfyUIRunning is not specified. It uses .NET's process
    /// management to ensure clean termination without leaving orphaned processes.
    /// </para>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Stop, "ComfyUI")]
    public class StopComfyUICommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - display progress indicator to inform user of operation status
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteProgress(
                new ProgressRecord(
                    0,
                    "ComfyUI Termination",
                    "Stopping ComfyUI processes...")
            );
        }

        /// <summary>
        /// Process record - main cmdlet logic for terminating ComfyUI processes
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                // search for all running processes with the name 'comfyui'
                Process[] comfyProcesses = Process.GetProcessesByName("comfyui");

                // evaluate if any comfyui processes were discovered
                if (comfyProcesses.Length > 0)
                {
                    // inform user about the number of processes found
                    WriteVerbose(
                        $"Found {comfyProcesses.Length} ComfyUI process(es) to terminate."
                    );

                    // iterate through each discovered process for termination
                    foreach (Process process in comfyProcesses)
                    {
                        // inform user about the specific process being terminated
                        WriteVerbose(
                            $"Terminating process ID {process.Id}..."
                        );

                        // forcefully terminate the process to ensure cleanup
                        process.Kill();
                    }

                    // pause briefly to allow system to complete process termination
                    Thread.Sleep(500);

                    // check if any comfyui processes are still running after termination
                    Process[] remainingProcesses = Process.GetProcessesByName("comfyui");

                    // verify successful termination of all processes
                    if (remainingProcesses.Length == 0)
                    {
                        // confirm successful termination to user
                        WriteVerbose(
                            "All ComfyUI processes successfully terminated."
                        );
                    }
                    else
                    {
                        // warn user about processes that could not be terminated
                        WriteWarning(
                            "Some ComfyUI processes could not be terminated."
                        );
                    }
                }
                else
                {
                    // inform user that no comfyui processes were found
                    WriteVerbose(
                        "No ComfyUI processes found running."
                    );
                }
            }
            catch (Exception ex)
            {
                // handle and report any errors during process termination
                WriteWarning(
                    $"Failed to stop ComfyUI processes: {ex.Message}"
                );
            }
        }

        /// <summary>
        /// End processing - complete the progress indicator to signal operation completion
        /// </summary>
        protected override void EndProcessing()
        {
            WriteProgress(
                new ProgressRecord(
                    0,
                    "ComfyUI Termination",
                    "Stopping ComfyUI processes...")
                {
                    RecordType = ProgressRecordType.Completed
                }
            );
        }
    }
}