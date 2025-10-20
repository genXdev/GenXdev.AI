// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Test-LMStudioProcess.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.302.2025
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
using System.Linq;
using System.Management.Automation;

namespace GenXdev.AI.LMStudio
{

    /// <summary>
    /// <para type="synopsis">
    /// Tests if LM Studio process is running and configures its window state.
    /// </para>
    ///
    /// <para type="description">
    /// Checks if LM Studio is running, and if so, returns true. If not running, it
    /// returns false.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -ShowWindow &lt;SwitchParameter&gt;<br/>
    /// If specified, only considers LM Studio processes with a valid window handle.<br/>
    /// - <b>Aliases</b>: sw<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Example description</para>
    /// <para>Check if LM Studio is running</para>
    /// <code>
    /// [bool] $lmStudioRunning = Test-LMStudioProcess
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example description</para>
    /// <para>Check if LM Studio is running with a visible window</para>
    /// <code>
    /// [bool] $lmStudioRunning = Test-LMStudioProcess -ShowWindow
    /// </code>
    /// </example>
    ///
    /// </summary>
    [Cmdlet(VerbsDiagnostic.Test, "LMStudioProcess")]
    [OutputType(typeof(bool))]
    public class TestLMStudioProcessCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// If specified, only considers LM Studio processes with a valid window handle.
        /// </summary>
        [Parameter(Mandatory = false)]
        [Alias("sw")]
        public SwitchParameter ShowWindow { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Searching for LM Studio process...");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get LM Studio processes
            var processes = System.Diagnostics.Process.GetProcessesByName("LM Studio");

            // Filter processes if ShowWindow is specified
            if (ShowWindow.ToBool())
            {
                processes = processes.Where(p => p.MainWindowHandle != IntPtr.Zero).ToArray();
            }

            // Return true if any process exists, false otherwise
            bool exists = processes.Length > 0;
            WriteObject(exists);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}