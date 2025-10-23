// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Get-LMStudioPaths.cs
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
using System.IO;
using System.Management.Automation;

namespace GenXdev.AI.LMStudio
{
    /// <summary>
    /// <para type="synopsis">
    /// Retrieves file paths for LM Studio executables.
    /// </para>
    ///
    /// <para type="description">
    /// Searches common installation locations for LM Studio executables and returns their
    /// paths. The cmdlet maintains a cache of found paths to optimize performance on
    /// subsequent calls.
    /// </para>
    ///
    /// <para type="description">
    /// OUTPUTS
    /// </para>
    ///
    /// <para type="description">
    /// System.Collections.Hashtable<br/>
    /// Returns a hashtable with two keys:<br/>
    /// - LMStudioExe: Path to main LM Studio executable<br/>
    /// - LMSExe: Path to LMS command-line executable<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Get LM Studio paths</para>
    /// <para>Retrieves the paths to LM Studio executables.</para>
    /// <code>
    /// $paths = Get-LMStudioPaths
    /// Write-Output "LM Studio path: $($paths.LMStudioExe)"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "LMStudioPaths")]
    [OutputType(typeof(Hashtable))]
    public class GetLMStudioPathsCommand : PSGenXdevCmdlet
    {
        // Static cache fields to maintain paths across cmdlet invocations
        private static string cachedLMStudioExe;
        private static string cachedLMSExe;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Define search paths for executables
            string[] searchPathsLMStudio = new string[]
            {
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "LM-Studio", "lm studio.exe"),
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "Programs", "LM-Studio", "lm studio.exe"),
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "Programs", "LM Studio", "lm studio.exe")
            };

            string[] searchPathsLMSexe = new string[]
            {
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.UserProfile), ".cache", "lm-studio", "bin", "lms.exe"),
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "LM-Studio", "lms.exe"),
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "Programs", "LM-Studio", "lms.exe"),
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "Programs", "LM Studio", "lms.exe"),
                Path.Combine(Environment.GetEnvironmentVariable("LOCALAPPDATA"), "Programs", "LM Studio", "resources", "app", ".webpack", "lms.exe")
            };

            // Check if paths need to be discovered
            if (string.IsNullOrEmpty(cachedLMStudioExe) || string.IsNullOrEmpty(cachedLMSExe))
            {
                WriteVerbose("Searching for LM Studio executables...");

                // Find main LM Studio executable
                cachedLMStudioExe = FindFirstExistingFile(searchPathsLMStudio);

                // Find LMS command-line executable
                cachedLMSExe = FindFirstExistingFile(searchPathsLMSexe);

                WriteVerbose($"Found LM Studio: {cachedLMStudioExe}");
                WriteVerbose($"Found LMS: {cachedLMSExe}");
            }

            // Return paths in a hashtable
            Hashtable result = new Hashtable
            {
                { "LMStudioExe", cachedLMStudioExe },
                { "LMSExe", cachedLMSExe }
            };

            WriteObject(result);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }

        /// <summary>
        /// Finds the first existing file from an array of paths
        /// </summary>
        /// <param name="paths">Array of file paths to check</param>
        /// <returns>The first existing file path, or null if none found</returns>
        private string FindFirstExistingFile(string[] paths)
        {
            foreach (string path in paths)
            {
                if (File.Exists(path))
                {
                    return path;
                }
            }
            return null;
        }
    }
}