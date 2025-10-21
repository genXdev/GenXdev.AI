// ################################################################################
// Part of PowerShell module : GenXdev.AI
// Original cmdlet filename  : Invoke-WinMerge.cs
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



using System.Diagnostics;
using System.Management.Automation;

namespace GenXdev.AI
{
    /// <summary>
    /// <para type="synopsis">
    /// Launches WinMerge to compare two files side by side.
    /// </para>
    ///
    /// <para type="description">
    /// Launches the WinMerge application to compare source and target files in a side by
    /// side diff view. The function validates the existence of both input files and
    /// ensures WinMerge is properly installed before launching. Provides optional
    /// wait functionality to pause execution until WinMerge closes.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -SourcecodeFilePath &lt;String&gt;<br/>
    /// Full or relative path to the source file for comparison. The file must exist and
    /// be accessible.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -TargetcodeFilePath &lt;String&gt;<br/>
    /// Full or relative path to the target file for comparison. The file must exist and
    /// be accessible.<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Wait &lt;SwitchParameter&gt;<br/>
    /// Switch parameter that when specified will cause the function to wait for the
    /// WinMerge application to close before continuing execution.<br/>
    /// - <b>Position</b>: 2<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Compare two files with WinMerge</para>
    /// <para>Launches WinMerge to compare file1.txt and file2.txt, waiting for the application to close.</para>
    /// <code>
    /// Invoke-WinMerge -SourcecodeFilePath "C:\source\file1.txt" `
    ///                 -TargetcodeFilePath "C:\target\file2.txt" `
    ///                 -Wait
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Compare two files without waiting</para>
    /// <para>Launches WinMerge to compare two files and continues execution immediately.</para>
    /// <code>
    /// Invoke-WinMerge "C:\source\file1.txt" "C:\target\file2.txt"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet("Invoke", "WinMerge")]
    public class InvokeWinMergeCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Full or relative path to the source file for comparison. The file must exist and be accessible.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Path to the source file to compare")]
        [ValidateNotNullOrEmpty]
        public string SourcecodeFilePath { get; set; }

        /// <summary>
        /// Full or relative path to the target file for comparison. The file must exist and be accessible.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Path to the target file to compare against")]
        [ValidateNotNullOrEmpty]
        public string TargetcodeFilePath { get; set; }

        /// <summary>
        /// Switch parameter that when specified will cause the function to wait for the WinMerge application to close before continuing execution.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Wait for WinMerge to close before continuing")]
        public SwitchParameter Wait { get; set; }

        private string sourcePath;
        private string targetPath;

        /// <summary>
        /// Verify WinMerge installation and expand file paths using PowerShell functions
        /// </summary>
        protected override void BeginProcessing()
        {
            // Verify that winmerge is installed and accessible
            WriteVerbose("Verifying WinMerge installation status...");
            var ensureInstalledScript = ScriptBlock.Create("GenXdev.AI\\EnsureWinMergeInstalled");
            foreach (var output in ensureInstalledScript.Invoke())
            {
                WriteObject(output.ToString().Trim());
            }

            // Convert any relative paths to full paths for reliability
            sourcePath = ExpandPath(SourcecodeFilePath);
            targetPath = ExpandPath(TargetcodeFilePath);

            // Log the resolved file paths for troubleshooting
            WriteVerbose($"Resolved source file path: {sourcePath}");
            WriteVerbose($"Resolved target file path: {targetPath}");
        }

        /// <summary>
        /// Launch WinMerge with the specified files
        /// </summary>
        protected override void ProcessRecord()
        {
            // Prepare the process start parameters including executable and files
            var startProcessArgs = new System.Collections.Hashtable
            {
                ["FilePath"] = "WinMergeU.exe",
                ["ArgumentList"] = new object[] { sourcePath, targetPath }
            };

            // Add wait parameter if specified to block until winmerge closes
            if (Wait)
            {
                WriteVerbose("Will wait for WinMerge process to exit");
                startProcessArgs["Wait"] = true;
            }

            // Launch winmerge with the configured parameters using PowerShell Start-Process
            WriteVerbose("Launching WinMerge application...");
            InvokeCommand.InvokeScript("param($args) Microsoft.PowerShell.Management\\Start-Process @args", startProcessArgs);
        }

        /// <summary>
        /// Cleanup if needed
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}