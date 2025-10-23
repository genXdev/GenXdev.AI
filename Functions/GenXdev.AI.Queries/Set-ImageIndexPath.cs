// ################################################################################
// Part of PowerShell module : GenXdev.AI.Queries
// Original cmdlet filename  : Set-ImageIndexPath.cs
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
using System.IO;
using System.Management.Automation;

namespace GenXdev.AI.Queries
{
    /// <summary>
    /// <para type="synopsis">
    /// Sets the default database file path for image operations in GenXdev.AI.
    /// </para>
    ///
    /// <para type="description">
    /// This function configures the default database file path used by GenXdev.AI
    /// functions for image processing and AI operations. The path can be stored
    /// persistently in preferences (default), only in the current session (using
    /// -SessionOnly), or cleared from the session (using -ClearSession).
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -DatabaseFilePath &lt;String&gt;<br/>
    /// The path to the image database file. The directory will be created if it
    /// doesn't exist.<br/>
    /// - <b>Aliases</b>: dbpath, database<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Mandatory</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -PreferencesDatabasePath &lt;String&gt;<br/>
    /// Database path for preference data files.<br/>
    /// - <b>Aliases</b>: DatabasePath<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Mandatory</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SessionOnly &lt;SwitchParameter&gt;<br/>
    /// When specified, stores the setting only in the current session (Global
    /// variables) without persisting to preferences. Settings will be lost when the
    /// session ends.<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ClearSession &lt;SwitchParameter&gt;<br/>
    /// When specified, clears only the session setting (Global variable) without
    /// affecting persistent preferences.<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SkipSession &lt;SwitchParameter&gt;<br/>
    /// When specified, stores the setting only in persistent preferences without
    /// affecting the current session setting.<br/>
    /// - <b>Aliases</b>: FromPreferences<br/>
    /// - <b>Position</b>: named<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Set-ImageIndexPath -DatabaseFilePath "C:\MyProject\images.db"</para>
    /// <para>Sets the image database path persistently in preferences.</para>
    /// <code>
    /// Set-ImageIndexPath -DatabaseFilePath "C:\MyProject\images.db"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Set-ImageIndexPath "D:\Data\custom_images.db"</para>
    /// <para>Sets the image database path persistently in preferences using positional
    /// parameter.</para>
    /// <code>
    /// Set-ImageIndexPath "D:\Data\custom_images.db"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Set-ImageIndexPath -DatabaseFilePath "C:\Temp\temp_images.db" -SessionOnly</para>
    /// <para>Sets the image database path only for the current session (Global variables).</para>
    /// <code>
    /// Set-ImageIndexPath -DatabaseFilePath "C:\Temp\temp_images.db" -SessionOnly
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Set-ImageIndexPath -ClearSession</para>
    /// <para>Clears the session image database path setting (Global variable) without
    /// affecting persistent preferences.</para>
    /// <code>
    /// Set-ImageIndexPath -ClearSession
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "ImageIndexPath", SupportsShouldProcess = true)]
    public class SetImageIndexPathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Specifies the path to the image database file
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The path to the image database file"
        )]
        [ValidateNotNullOrEmpty]
        [Alias("dbpath", "database")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// Database path for preference data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for preference data files"
        )]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// Use alternative settings stored in session for AI preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use alternative settings stored in session for AI preferences"
        )]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// Clear alternative settings stored in session for AI preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences"
        )]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Store setting only in persistent preferences without affecting session
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Store setting only in persistent preferences without affecting session"
        )]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        protected override void BeginProcessing()
        {

            // Validate parameters - DatabaseFilePath is required unless clearing
            if (!ClearSession.ToBool() && string.IsNullOrWhiteSpace(DatabaseFilePath))
            {

                throw new ArgumentException(
                    "DatabaseFilePath parameter is required when not using -ClearSession"
                );
            }

            // Expand and validate the database file path if provided
            if (!ClearSession.ToBool() && !string.IsNullOrWhiteSpace(DatabaseFilePath))
            {

                try
                {

                    // Expand the database file path to full path
                    DatabaseFilePath = ExpandPath(DatabaseFilePath);
                }
                catch (Exception ex)
                {

                    throw new ArgumentException(
                        $"Failed to expand database file path '{DatabaseFilePath}': {ex.Message}",
                        ex
                    );
                }

                // Get parent directory for validation
                string parentDir = Path.GetDirectoryName(DatabaseFilePath);

                // Validate that the parent directory exists or can be created
                if (!string.IsNullOrWhiteSpace(parentDir) && !Directory.Exists(parentDir))
                {

                    try
                    {

                        // Create parent directory if it doesn't exist
                        Directory.CreateDirectory(parentDir);

                        WriteVerbose($"Created parent directory: {parentDir}");
                    }
                    catch (Exception ex)
                    {

                        throw new IOException(
                            $"Failed to create parent directory '{parentDir}': {ex.Message}",
                            ex
                        );
                    }
                }
            }
        }

        protected override void ProcessRecord()
        {

            // Handle clearing session variables
            if (ClearSession.ToBool())
            {

                // Prepare confirmation message for clearing session
                string clearMessage = "Clear session image database path setting (Global variable)";

                // Confirm the operation with the user before proceeding
                if (ShouldProcess("GenXdev.AI Module Configuration", clearMessage))
                {

                    // Clear the global variable
                    InvokeCommand.InvokeScript("$Global:ImageIndexPath = $null");

                    WriteVerbose("Cleared session setting: ImageIndexPath");
                }

                return;
            }

            // Handle session-only storage
            if (SessionOnly.ToBool())
            {

                // Prepare confirmation message for session-only storage
                string sessionMessage = $"Set session-only image database path to: {DatabaseFilePath}";

                // Confirm the operation with the user before proceeding
                if (ShouldProcess("GenXdev.AI Module Configuration", sessionMessage))
                {

                    // Set global variable for session-only storage
                    var setGlobalScript = ScriptBlock.Create(
                        "param($path) $Global:ImageIndexPath = $path"
                    );

                    setGlobalScript.Invoke(DatabaseFilePath);

                    WriteVerbose($"Set session-only image database path: {DatabaseFilePath}");
                }

                return;
            }

            // Handle persistent storage (default behavior)
            // Prepare confirmation message for persistent storage
            string persistentMessage = $"Set image database path to: {DatabaseFilePath}";

            // Confirm the operation with the user before proceeding
            if (ShouldProcess("GenXdev.AI Module Configuration", persistentMessage))
            {

                // Output verbose message about setting database path
                WriteVerbose($"Setting ImageIndexPath preference to: {DatabaseFilePath}");

                // Store the configuration in module preferences for persistence
                SetGenXdevPreference(
                    "ImageIndexPath",
                    DatabaseFilePath,
                    PreferencesDatabasePath,
                    SessionOnly.ToBool(),
                    ClearSession.ToBool(),
                    SkipSession.ToBool()
                );
            }
        }

        protected override void EndProcessing()
        {
        }
    }
}
