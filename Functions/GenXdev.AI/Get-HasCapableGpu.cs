// ################################################################################
// Part of PowerShell module : GenXdev.AI
// Original cmdlet filename  : Get-HasCapableGpu.cs
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
using System.Management;
using System.Management.Automation;

namespace GenXdev.AI
{
    /// <summary>
    /// <para type="synopsis">
    /// Determines if a CUDA-capable GPU with sufficient memory is present.
    /// </para>
    ///
    /// <para type="description">
    /// This function checks the system for CUDA-compatible GPUs with at least 4GB of
    /// video RAM. It uses Windows Management Instrumentation (WMI) to query installed
    /// video controllers and verify their memory capacity. This check is essential for
    /// AI workloads that require significant GPU memory.
    /// </para>
    ///
    /// <para type="description">
    /// OUTPUTS
    /// </para>
    ///
    /// <para type="description">
    /// [bool] Returns true if a capable GPU is found, false otherwise.
    /// </para>
    ///
    /// <example>
    /// <para>Example of checking for capable GPU</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// $hasGpu = Get-HasCapableGpu
    /// Write-Host "System has capable GPU: $hasGpu"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "HasCapableGpu")]
    [OutputType(typeof(bool))]
    public class GetHasCapableGpuCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting GPU capability verification");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Define minimum required GPU memory (4GB in bytes)
            ulong requiredMemory = 1024UL * 1024UL * 1024UL * 4UL;

            // Query system for video controllers meeting memory requirement
            using (var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_VideoController"))
            {
                var controllers = searcher.Get();
                int capableGpuCount = 0;

                foreach (ManagementObject controller in controllers)
                {
                    var adapterRam = controller["AdapterRAM"] as ulong?;
                    if (adapterRam.HasValue && adapterRam.Value >= requiredMemory)
                    {
                        capableGpuCount++;
                    }
                }

                // Output number of capable GPUs found for debugging
                WriteVerbose($"Detected {capableGpuCount} GPUs with 4GB+ RAM");

                // Return true if at least one capable GPU was found
                WriteObject(capableGpuCount > 0);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}