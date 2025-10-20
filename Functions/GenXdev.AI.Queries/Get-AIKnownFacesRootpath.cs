// ################################################################################
// Part of PowerShell module : GenXdev.AI.Queries
// Original cmdlet filename  : Get-AIKnownFacesRootpath.cs
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



using System.Collections;
using System.Management.Automation;

namespace GenXdev.AI.Queries
{
    /// <summary>
    /// <para type="synopsis">
    /// Gets the configured directory for face image files used in GenXdev.AI operations.
    /// </para>
    ///
    /// <para type="description">
    /// This function retrieves the global face directory used by the GenXdev.AI
    /// module for various face recognition and AI operations. It checks Global
    /// variables first (unless SkipSession is specified), then falls back to
    /// persistent preferences, and finally uses system defaults.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -FacesDirectory &lt;String&gt;<br/>
    /// Optional faces directory override. If specified, this directory will be
    /// returned instead of retrieving from configuration.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: (none)<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SessionOnly &lt;SwitchParameter&gt;<br/>
    /// Use alternative settings stored in session for AI preferences like Language,
    /// Image collections, etc<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ClearSession &lt;SwitchParameter&gt;<br/>
    /// Clear the session setting (Global variable) before retrieving<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -PreferencesDatabasePath &lt;String&gt;<br/>
    /// Database path for preference data files<br/>
    /// - <b>Aliases</b>: DatabasePath<br/>
    /// - <b>Default</b>: (none)<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SkipSession &lt;SwitchParameter&gt;<br/>
    /// Dont use alternative settings stored in session for AI preferences like
    /// Language, Image collections, etc<br/>
    /// - <b>Aliases</b>: FromPreferences<br/>
    /// - <b>Default</b>: false<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Gets the currently configured faces directory from Global variables or preferences.</para>
    /// <code>
    /// Get-AIKnownFacesRootpath
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Gets the configured faces directory only from persistent preferences, ignoring any session setting.</para>
    /// <code>
    /// Get-AIKnownFacesRootpath -SkipSession
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Clears the session faces directory setting and then gets the directory from persistent preferences.</para>
    /// <code>
    /// Get-AIKnownFacesRootpath -ClearSession
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Returns the specified directory after expanding the path.</para>
    /// <code>
    /// Get-AIKnownFacesRootpath "C:\MyFaces"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "AIKnownFacesRootpath")]
    [OutputType(typeof(string))]
    public class GetAIKnownFacesRootpathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Optional faces directory override. If specified, this directory will be
        /// returned instead of retrieving from configuration.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "Directory path for face image files")]
        public string FacesDirectory { get; set; }

        /// <summary>
        /// Use alternative settings stored in session for AI preferences like Language,
        /// Image collections, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences like Language, Image collections, etc"))]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// Clear the session setting (Global variable) before retrieving
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = ("Clear the session setting (Global variable) before " +
                "retrieving"))]
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
        /// Dont use alternative settings stored in session for AI preferences like
        /// Language, Image collections, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = ("Dont use alternative settings stored in session for " +
                "AI preferences like Language, Image collections, etc"))]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

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
            // Check if FacesDirectory is provided and return expanded path
            if (!string.IsNullOrWhiteSpace(FacesDirectory))
            {
                WriteObject(ExpandPath(FacesDirectory));
                return;
            }

            // Get default pictures path
            string defaultPicturesPath = ExpandPath("~\\Pictures");

            // Try to get known folder path for pictures directory
            try
            {
                defaultPicturesPath = InvokeScript<string>(@"GenXdev.Windows\Get-KnownFolderPath Pictures");
            }
            catch
            {
                // Keep the default fallback path
            }

            // Set faces directory to default since FacesDirectory is empty
            string facesDirectory = defaultPicturesPath;

            // Call Copy-IdenticalParamValues to get parameters for Get-GenXdevPreference
            var paramsDict = CopyIdenticalParamValues(@"GenXdev.Data\Get-GenXdevPreference");

            // Call Get-GenXdevPreference with the copied parameters
            var prefResult = InvokeCommand.InvokeScript(@"
                param($params, $name, $default)
                GenXdev.Data\Get-GenXdevPreference @params -Name $name -DefaultValue $default
            ", paramsDict, "AIKnownFacesRootpath", facesDirectory);
            string prefValue = prefResult[0].BaseObject.ToString();

            // Expand the path of the preference value
            WriteObject(ExpandPath(prefValue));
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}