// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Get-LMStudioModelList.cs
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
    /// Retrieves a list of installed LM Studio models.
    /// </para>
    ///
    /// <para type="description">
    /// Gets a list of all models installed in LM Studio by executing the LM Studio CLI
    /// command and parsing its JSON output. Returns an array of model objects containing
    /// details about each installed model.
    /// </para>
    ///
    /// <para type="description">
    /// OUTPUTS
    /// </para>
    ///
    /// <para type="description">
    /// System.Object[]
    /// Returns an array of model objects containing details about installed models.
    /// </para>
    ///
    /// <example>
    /// <para>Retrieves all installed LM Studio models and returns them as objects.</para>
    /// <code>
    /// Get-LMStudioModelList
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Retrieves models while showing detailed progress information.</para>
    /// <code>
    /// Get-LMStudioModelList -Verbose
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "LMStudioModelList")]
    [OutputType(typeof(System.Object[]))]
    public class GetLMStudioModelListCommand : PSGenXdevCmdlet
    {
        private string lmsExe;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Check if lm studio is installed
            var installedResult = InvokeCommand.InvokeScript("GenXdev.AI\\Test-LMStudioInstallation");

            bool installed = (bool)((PSObject)installedResult[0]).BaseObject;

            if (!installed)
            {
                throw new Exception("LM Studio is not installed or not found in expected location");
            }

            // Get paths for lm studio components
            var lmPathsResult = InvokeCommand.InvokeScript("GenXdev.AI\\Get-LMStudioPaths");

            var lmPaths = (Hashtable)lmPathsResult[0].BaseObject;

            lmsExe = lmPaths["LMSExe"].ToString();

            WriteVerbose("Retrieved LM Studio installation paths");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                // Get path to lm studio executable
                WriteVerbose($"Using LM Studio executable: {lmsExe}");

                // Execute cli command to get model list
                WriteVerbose("Retrieving model list from LM Studio...");

                foreach (var o in InvokeCommand.InvokeScript($"& '{lmsExe}' ls --json | Microsoft.PowerShell.Utility\\ConvertFrom-Json"))
                {
                    WriteObject(o);
                }
            }
            catch (Exception ex)
            {
                var errorMsg = $"Failed to get model list: {ex.Message}";

                var errorRecord = new ErrorRecord(ex, "GetLMStudioModelListError", ErrorCategory.InvalidOperation, null);

                WriteError(errorRecord);

                throw new Exception(errorMsg);
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