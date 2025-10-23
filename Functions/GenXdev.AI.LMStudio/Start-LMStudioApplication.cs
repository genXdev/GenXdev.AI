// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Start-LMStudioApplication.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 2.1.2025
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
using System.Collections;
using System.Diagnostics;
using System.Management.Automation;

namespace GenXdev.AI.LMStudio
{
    /// <summary>
    /// <para type="synopsis">
    /// Starts the LM Studio application if it's not already running.
    /// </para>
    ///
    /// <para type="description">
    /// This cmdlet checks if LM Studio is installed and running. If not installed, it
    /// will install it. If not running, it will start it with the specified window
    /// visibility.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Passthru &lt;SwitchParameter&gt;<br/>
    /// When specified, returns the Process object of the LM Studio application.<br/>
    /// - <b>Aliases</b>: pt<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ShowWindow &lt;SwitchParameter&gt;<br/>
    /// Determines if the LM Studio window should be visible after starting.<br/>
    /// - <b>Position</b>: Named<br/>
    /// - <b>Default</b>: False<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Start LM Studio application with window visible and return process object</para>
    /// <para>This example starts LM Studio if not running, makes the window visible, and returns the process object.</para>
    /// <code>
    /// Start-LMStudioApplication -ShowWindow -Passthru
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Start, "LMStudioApplication")]
    [OutputType(typeof(System.Diagnostics.Process))]
    public class StartLMStudioApplicationCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// When specified, returns the Process object of the LM Studio application
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Return the Process object")]
        [Alias("pt")]
        public SwitchParameter Passthru { get; set; }

        /// <summary>
        /// Determines if the LM Studio window should be visible after starting
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Show LM Studio window after starting")]
        public SwitchParameter ShowWindow { get; set; }

        /// <summary>
        /// Begin processing - verify LM Studio installation
        /// </summary>
        protected override void BeginProcessing()
        {
            // Verify LM Studio installation
            WriteVerbose("Checking LM Studio installation...");

            // Call GenXdev.AI\Test-LMStudioInstallation
            var testInstallScript = ScriptBlock.Create("GenXdev.AI\\Test-LMStudioInstallation");
            var installResult = testInstallScript.Invoke();
            bool isInstalled = false;

            if (installResult != null && installResult.Count > 0)
            {
                isInstalled = (bool)installResult[0].BaseObject;
            }

            if (!isInstalled)
            {
                if (ShouldProcess("LM Studio", "Install application"))
                {
                    WriteVerbose("LM Studio not found, initiating installation...");

                    // Call GenXdev.AI\Install-LMStudioApplication
                    var installScript = ScriptBlock.Create("GenXdev.AI\\Install-LMStudioApplication");
                    foreach (var line in installScript.Invoke())
                    {
                        Console.WriteLine(line.ToString().Trim());
                    }
                }
            }
        }

        /// <summary>
        /// Process record - start LM Studio application if needed
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check if we need to start or show the process
            var testProcessScript = ScriptBlock.Create("param($showWindow) GenXdev.AI\\Test-LMStudioProcess -ShowWindow:$showWindow");
            var processResult = testProcessScript.Invoke(ShowWindow.ToBool());
            bool processRunning = false;

            if (processResult != null && processResult.Count > 0)
            {
                processRunning = (bool)processResult[0].BaseObject;
            }

            if (!processRunning || ShowWindow.ToBool())
            {
                WriteVerbose("Preparing to start or show LM Studio...");

                // Get installation paths
                var getPathsScript = ScriptBlock.Create("GenXdev.AI\\Get-LMStudioPaths");
                var pathsResult = getPathsScript.Invoke();

                if (pathsResult == null || pathsResult.Count == 0)
                {
                    throw new InvalidOperationException("Failed to get LM Studio paths");
                }

                Hashtable paths = (Hashtable)pathsResult[0].BaseObject;

                // Validate executable path
                if (paths["LMStudioExe"] == null)
                {
                    throw new InvalidOperationException("LM Studio executable could not be located");
                }

                if (ShouldProcess("LM Studio", "Start application"))
                {
                    // Start server component
                    var startServerScript = ScriptBlock.Create("param($lmsExe) Start-Process -FilePath $lmsExe -ArgumentList 'server', 'start', '--port', '1234'");
                    foreach (var line in startServerScript.Invoke(paths["LMSExe"]))
                    {
                        Console.WriteLine(line.ToString().Trim());
                    }

                    // Wait 4 seconds
                    System.Threading.Thread.Sleep(4000);

                    // Start LM Studio application
                    var startAppScript = ScriptBlock.Create("param($lmStudioExe) Start-Process -FilePath $lmStudioExe");
                    foreach (var line in startAppScript.Invoke(paths["LMStudioExe"]))
                    {
                        Console.WriteLine(line.ToString().Trim());
                    }

                    // Wait 4 seconds
                    System.Threading.Thread.Sleep(4000);

                    // Verify process starts within timeout period
                    WriteVerbose("Waiting for LM Studio process...");
                    int timeout = 30;
                    DateTime startTime = DateTime.Now;

                    while (true)
                    {
                        // Check if process is running
                        var checkProcessScript = ScriptBlock.Create("GenXdev.AI\\Test-LMStudioProcess");
                        var checkResult = checkProcessScript.Invoke();
                        bool isRunning = false;

                        if (checkResult != null && checkResult.Count > 0)
                        {
                            isRunning = (bool)checkResult[0].BaseObject;
                        }

                        if (isRunning)
                        {
                            break;
                        }

                        if ((DateTime.Now - startTime).TotalSeconds >= timeout)
                        {
                            throw new TimeoutException($"LM Studio failed to start within {timeout} seconds");
                        }

                        // Wait 1 second
                        System.Threading.Thread.Sleep(1000);
                    }
                }
            }

            // Return process object if requested
            if (Passthru.ToBool())
            {
                var getProcessScript = ScriptBlock.Create("Get-Process -Name 'LM Studio' -ErrorAction Stop | Where-Object { $_.MainWindowHandle -ne 0 } | Select-Object -First 1");
                var processResult2 = getProcessScript.Invoke();

                if (processResult2 != null && processResult2.Count > 0)
                {
                    WriteObject(processResult2[0].BaseObject);
                }
            }
        }
    }
}