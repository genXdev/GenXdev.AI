// ################################################################################
// Part of PowerShell module : GenXdev.AI.Queries
// Original cmdlet filename  : Set-AIKnownFacesRootpath.cs
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



using System.Collections;
using System.Collections.Generic;
using System.Management.Automation;

namespace GenXdev.AI.Queries
{
    /// <summary>
    /// <para type="synopsis">
    /// Sets the directory for face image files used in GenXdev.AI operations.
    /// </para>
    ///
    /// <para type="description">
    /// This function configures the global face directory used by the GenXdev.AI
    /// module for various face recognition and AI operations. Settings can be stored
    /// persistently in preferences (default), only in the current session (using
    /// -SessionOnly), or cleared from the session (using -ClearSession).
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -FacesDirectory &lt;String&gt;<br/>
    /// A directory path where face image files are located. This directory
    /// will be used by GenXdev.AI functions for face discovery and processing
    /// operations.<br/>
    /// - <b>Position</b>: 0<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -PreferencesDatabasePath &lt;String&gt;<br/>
    /// Database path for preference data files.<br/>
    /// - <b>Aliases</b>: DatabasePath<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SessionOnly &lt;SwitchParameter&gt;<br/>
    /// When specified, stores the setting only in the current session (Global
    /// variable) without persisting to preferences. Setting will be lost when the
    /// session ends.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ClearSession &lt;SwitchParameter&gt;<br/>
    /// When specified, clears only the session setting (Global variable) without
    /// affecting persistent preferences.<br/>
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
    /// <para>Example 1: Sets the faces directory persistently in preferences</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIKnownFacesRootpath -FacesDirectory "C:\Faces"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example 2: Sets the faces directory persistently in preferences</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIKnownFacesRootpath "C:\FacePictures"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example 3: Sets the faces directory only for the current session</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIKnownFacesRootpath -FacesDirectory "C:\TempFaces" -SessionOnly
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Example 4: Clears the session faces directory setting</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIKnownFacesRootpath -ClearSession
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "AIKnownFacesRootpath")]
    [OutputType(typeof(void))]
    public class SetAIKnownFacesRootpathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// A directory path where face image files are located
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "Directory path for face image files"
        )]
        public string FacesDirectory { get; set; }

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
        /// Use alternative settings stored in session for AI preferences like Language, Image collections, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences like Language, Image collections, etc")
        )]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// Clear alternative settings stored in session for AI preferences like Language, Image collections, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences like Language, Image collections, etc")
        )]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = ("Dont use alternative settings stored in session for " +
                "AI preferences like Language, Image collections, etc")
        )]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get picturesPath using GenXdev functions
            string picturesPath;
            try
            {
                // Attempt to get known folder path for pictures directory
                var getKnownFolderScript = ScriptBlock.Create("GenXdev.Windows\\Get-KnownFolderPath Pictures");
                var knownFolderResult = getKnownFolderScript.Invoke();
                picturesPath = ((PSObject)knownFolderResult[0]).BaseObject.ToString();
            }
            catch
            {
                // Fallback to default system directories
                picturesPath = ExpandPath("~\\Pictures");
            }

            // Determine the faces path based on input parameter
            string facesPath = string.IsNullOrWhiteSpace(FacesDirectory) ?
                picturesPath + "\\Faces\\" : FacesDirectory;

            // Expand the path and create directory if needed
            string expandedPath = ExpandPath(facesPath);

            // Prepare bound parameters for parameter copying
            var boundParams = MyInvocation.BoundParameters;

            // Copy identical parameters using GenXdev utility function
            var paramsDict = CopyIdenticalParamValues("GenXdev.Data\\Set-GenXdevPreference");

            // Set the specific parameters for this preference
            paramsDict["Name"] = "AIKnownFacesRootpath";
            paramsDict["Value"] = expandedPath;

            // Invoke the preference setting function
            var setPrefScript = ScriptBlock.Create("param($params) GenXdev.Data\\Set-GenXdevPreference @params");
            foreach (var line in setPrefScript.Invoke(paramsDict))
            {
                Console.WriteLine(line.ToString().Trim());
            }
        }
    }
}