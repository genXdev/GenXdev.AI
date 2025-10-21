// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Test-LMStudioInstallation.cs
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



using System.Collections;
using System.IO;
using System.Management.Automation;

namespace GenXdev.AI.LMStudio
{
    /// <summary>
    /// <para type="synopsis">
    /// Tests if LMStudio is installed and accessible on the system.
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
    /// <para>Example 1: Test LMStudio installation</para>
    /// <para>Test-LMStudioInstallation</para>
    /// <para>Returns $true if LMStudio is properly installed, $false otherwise.</para>
    /// <code>
    /// Test-LMStudioInstallation
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example 2: Use the alias to check LMStudio installation status</para>
    /// <para>tlms</para>
    /// <para>Uses the alias to check LMStudio installation status.</para>
    /// <code>
    /// tlms
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsDiagnostic.Test, "LMStudioInstallation")]
    [OutputType(typeof(bool))]
    public class TestLMStudioInstallationCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Retrieving LMStudio installation paths...");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Call the PowerShell function to get LMStudio paths
            var results = InvokeCommand.InvokeScript("GenXdev.AI\\Get-LMStudioPaths");

            // Extract the hashtable from the results
            var paths = results[0].BaseObject as Hashtable;

            // Get the executable paths
            string lmsExe = paths["LMSExe"] as string;
            string lmStudioExe = paths["LMStudioExe"] as string;

            // Write verbose message about verification
            WriteVerbose($"Verifying LMStudio executable at: {lmsExe}");

            // Check if both executables exist and paths are not empty
            bool isInstalled = (!string.IsNullOrWhiteSpace(lmsExe) && File.Exists(lmsExe)) &&
                               (!string.IsNullOrWhiteSpace(lmStudioExe) && File.Exists(lmStudioExe));

            // Output the result
            WriteObject(isInstalled);
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