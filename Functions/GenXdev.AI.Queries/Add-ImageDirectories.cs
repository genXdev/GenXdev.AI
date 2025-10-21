// ################################################################################
// Part of PowerShell module : GenXdev.AI.Queries
// Original cmdlet filename  : Add-ImageDirectories.cs
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
using System.Collections.Generic;
using System.Linq;
using System.Management.Automation;

namespace GenXdev.AI.Queries
{
    /// <summary>
    /// <para type="synopsis">
    /// Adds directories to the configured image directories for GenXdev.AI operations.
    /// </para>
    ///
    /// <para type="description">
    /// This function adds one or more directory paths to the existing image directories
    /// configuration used by the GenXdev.AI module. It updates both the global variable
    /// and the module's preference storage to persist the configuration across sessions.
    /// Duplicate directories are automatically filtered out to prevent configuration
    /// redundancy. Paths are expanded to handle relative paths and environment
    /// variables automatically.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -ImageDirectories &lt;string[]&gt;<br/>
    /// An array of directory paths to add to the existing image directories
    /// configuration. Paths can be relative or absolute and will be expanded
    /// automatically. Duplicates are filtered out using case-insensitive comparison.<br/>
    /// - <b>Aliases</b>: imagespath, directories, imgdirs, imagedirectory<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Pipeline input</b>: True (ByValue)<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SessionOnly &lt;SwitchParameter&gt;<br/>
    /// Use alternative settings stored in session for AI preferences like Language,
    /// Image collections, etc.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ClearSession &lt;SwitchParameter&gt;<br/>
    /// Clear alternative settings stored in session for AI preferences like Language,
    /// Image collections, etc.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -PreferencesDatabasePath &lt;string&gt;<br/>
    /// Database path for preference data files.<br/>
    /// - <b>Aliases</b>: DatabasePath<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SkipSession &lt;SwitchParameter&gt;<br/>
    /// Dont use alternative settings stored in session for AI preferences like
    /// Language, Image collections, etc.<br/>
    /// - <b>Aliases</b>: FromPreferences<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Add directories using full parameter names</para>
    /// <para>Adds the specified directories to the existing image directories configuration
    /// using full parameter names.</para>
    /// <code>
    /// Add-ImageDirectories -ImageDirectories @("C:\NewPhotos", "D:\MoreImages")
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Add directories using alias with positional parameters</para>
    /// <para>Uses alias to add multiple directories to the configuration with positional
    /// parameters.</para>
    /// <code>
    /// addimgdir @("C:\Temp\Photos", "E:\Backup\Images")
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Add, "ImageDirectories", SupportsShouldProcess = true)]
    [Alias("addimgdir")]
    [OutputType(typeof(void))]
    public class AddImageDirectoriesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// An array of directory paths to add to the existing image directories configuration
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "Array of directory paths to add to image directories")]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [ValidateNotNullOrEmpty]
        public string[] ImageDirectories { get; set; }

        /// <summary>
        /// Use alternative settings stored in session for AI preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc")]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// Clear alternative settings stored in session for AI preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc")]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Database path for preference data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for preference data files")]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// Dont use alternative settings stored in session for AI preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc")]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        // Private fields for storing processed data
        private List<string> newDirectories;
        private PSObject[] currentConfig;

        /// <summary>
        /// Begin processing - retrieve current image directories configuration
        /// </summary>
        protected override void BeginProcessing()
        {

            newDirectories = new List<string>();

            try
            {
                // Retrieve current image directories configuration
                var invocationParams = CopyIdenticalParamValues("GenXdev.AI\\Get-AIImageCollection");

                // Avoid forwarding directories-to-add as fallback defaults to the getter
                if (invocationParams is IDictionary dict)
                {
                    var keyToRemove = dict.Keys
                        .Cast<object>()
                        .FirstOrDefault(k => string.Equals(k?.ToString(), "ImageDirectories", StringComparison.OrdinalIgnoreCase));

                    if (keyToRemove != null)
                    {
                        dict.Remove(keyToRemove);
                    }
                }

                // Get current image collection
                var getCurrentScript = ScriptBlock.Create("param($params) GenXdev.AI\\Get-AIImageCollection @params");
                var currentConfigResult = getCurrentScript.Invoke(invocationParams);

                // Convert PSObject results to array for processing
                currentConfig = currentConfigResult != null
                    ? currentConfigResult.ToArray()
                    : Array.Empty<PSObject>();

                // Populate collection with existing directories to preserve them
                foreach (var dir in currentConfig)
                {
                    string dirString = dir?.ToString() ?? string.Empty;
                    if (!string.IsNullOrEmpty(dirString))
                    {
                        newDirectories.Add(ExpandPath(dirString));
                    }
                }

                // Output current configuration state for debugging purposes
                var currentDirsList = string.Join(", ", newDirectories);
                WriteVerbose($"Current image directories: [{currentDirsList}]");
            }
            catch (Exception ex)
            {

                var errorRecord = new ErrorRecord(
                    ex,
                    "FailedToRetrieveCurrentImageDirectories",
                    ErrorCategory.ReadError,
                    null);
                WriteError(errorRecord);
                return;
            }
        }

        /// <summary>
        /// Process record - add each directory to the collection
        /// </summary>
        protected override void ProcessRecord()
        {

            foreach (var directory in ImageDirectories)
            {

                try
                {
                    // Expand path to resolve relative paths and environment variables
                    var expandedPath = ExpandPath(directory);

                    // Search for existing directory using case-insensitive comparison
                    var existingDir = newDirectories.FirstOrDefault(d =>
                        string.Equals(d, expandedPath, StringComparison.OrdinalIgnoreCase));

                    if (existingDir == null)
                    {
                        newDirectories.Add(expandedPath);
                        WriteVerbose($"Adding directory: {expandedPath}");
                    }
                    else
                    {

                        WriteVerbose($"Directory already exists: {expandedPath}");
                    }
                }
                catch (Exception ex)
                {

                    var errorRecord = new ErrorRecord(
                        ex,
                        "FailedToExpandPath",
                        ErrorCategory.InvalidArgument,
                        directory);
                    WriteError(errorRecord);
                    continue;
                }
            }
        }

        /// <summary>
        /// End processing - update the configuration with all directories
        /// </summary>
        protected override void EndProcessing()
        {
            // Convert list collection to array for function call compatibility
            var finalDirectories = newDirectories.ToArray();

            // Request user confirmation before modifying configuration
            var directoriesToAdd = string.Join(", ", ImageDirectories);
            if (ShouldProcess(
                "GenXdev.AI Module Configuration",
                $"Add directories to image directories: [{directoriesToAdd}]"))
            {

                // Prepare parameters for set operation using identical parameter copying
                var setParamsDict = CopyIdenticalParamValues("GenXdev.AI\\Set-AIImageCollection");

                // Add the ImageDirectories parameter to the hashtable
                setParamsDict["ImageDirectories"] = finalDirectories;

                // Update configuration using the dedicated setter function
                var setConfigScript = ScriptBlock.Create("param($params) GenXdev.AI\\Set-AIImageCollection @params");
                foreach (var line in setConfigScript.Invoke(setParamsDict))
                {
                    Console.WriteLine(line.ToString().Trim());
                }

                // Display success confirmation to user with statistics
                var message = $"Added {ImageDirectories.Length} directories to image " +
                    $"directories configuration. Total directories: {finalDirectories.Length}";

                var hostScript = ScriptBlock.Create(@"
                    param($message)
                    Microsoft.PowerShell.Utility\Write-Host $message -ForegroundColor Green
                ");
                hostScript.Invoke(message);
            }
        }
    }
}
// ###############################################################################