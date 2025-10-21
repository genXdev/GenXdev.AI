// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Get-LMStudioLoadedModelList.cs
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
using System.Collections;
using System.Management.Automation;

namespace GenXdev.AI.LMStudio
{
    /// <summary>
    /// <para type="synopsis">
    /// Retrieves the list of currently loaded models from LM Studio.
    /// </para>
    ///
    /// <para type="description">
    /// Gets a list of all models that are currently loaded in LM Studio by querying
    /// the LM Studio process. Returns null if no models are loaded or if an error
    /// occurs. Requires LM Studio to be installed and accessible.
    /// </para>
    ///
    /// <example>
    /// <para>Get-LMStudioLoadedModelList</para>
    /// <para>Retrieves the list of currently loaded models from LM Studio.</para>
    /// <code>
    /// Get-LMStudioLoadedModelList
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "LMStudioLoadedModelList")]
    [OutputType(typeof(PSCustomObject[]))]
    public class GetLMStudioLoadedModelListCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Private field to store LM Studio paths retrieved in BeginProcessing
        /// </summary>
        private Hashtable paths;

        /// <summary>
        /// Begin processing - initialization logic for verifying LM Studio installation and retrieving paths
        /// </summary>
        protected override void BeginProcessing()
        {
            // Verify lm studio is properly installed
            WriteVerbose("Verifying LM Studio installation...");
            var testResult = InvokeCommand.InvokeScript("GenXdev.AI\\Test-LMStudioInstallation");
            if (!(bool)testResult[0].BaseObject)
            {
                throw new Exception("LM Studio is not installed or accessible");
            }

            // Get required paths for lm studio components
            WriteVerbose("Retrieving LM Studio paths...");
            var pathsResult = InvokeCommand.InvokeScript("GenXdev.AI\\Get-LMStudioPaths");
            this.paths = (Hashtable)pathsResult[0].BaseObject;
        }

        /// <summary>
        /// Process record - main cmdlet logic for querying loaded models
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Querying LM Studio for loaded models...");

            try
            {
                // Query lm studio process and convert json output to objects
                string lmsExe = paths["LMSExe"].ToString();
                string script = $"& \"{lmsExe}\" ps --json | Microsoft.PowerShell.Utility\\ConvertFrom-Json";

                foreach (var o in InvokeCommand.InvokeScript(script))
                {
                    WriteObject(o);
                }
            }
            catch (Exception ex)
            {
                WriteVerbose($"Failed to retrieve model list: {ex.Message}");
                throw;
            }
        }

        /// <summary>
        /// End processing - cleanup logic (empty in this case)
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}