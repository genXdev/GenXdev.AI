// ################################################################################
// Part of PowerShell module : GenXdev.AI.Queries
// Original cmdlet filename  : Set-AIMetaLanguage.cs
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
    /// Sets the default language and optionally the image directories for GenXdev.AI image metadata operations.
    /// </para>
    ///
    /// <para type="description">
    /// This cmdlet configures the global default language for image metadata operations in the GenXdev.AI module. Optionally, it can also set the global image directories. Both settings are persisted in the module's preference storage for use across sessions.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Language &lt;string&gt;<br/>
    /// The default language to use for image metadata operations. This will be used by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no language is explicitly specified.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: (GenXdev.Helpers\Get-DefaultWebLanguage)<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -PreferencesDatabasePath &lt;string&gt;<br/>
    /// Database path for preference data files.<br/>
    /// - <b>Aliases</b>: DatabasePath<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SessionOnly &lt;SwitchParameter&gt;<br/>
    /// When specified, stores the settings only in the current session (Global variables) without persisting to preferences. Settings will be lost when the session ends.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ClearSession &lt;SwitchParameter&gt;<br/>
    /// When specified, clears only the session settings (Global variables) without affecting persistent preferences.<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -SkipSession &lt;SwitchParameter&gt;<br/>
    /// Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc.<br/>
    /// - <b>Aliases</b>: FromPreferences<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Sets the language and image directories persistently in preferences.</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIMetaLanguage -Language "Spanish" -ImageDirectories @("C:\Images", "D:\Photos")
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Sets the language persistently in preferences.</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIMetaLanguage "French"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Sets the language only for the current session (Global variable).</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIMetaLanguage -Language "German" -SessionOnly
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Clears the session language setting (Global variable) without affecting persistent preferences.</para>
    /// <para>Detailed explanation of the example.</para>
    /// <code>
    /// Set-AIMetaLanguage -ClearSession
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "AIMetaLanguage")]
    [OutputType(typeof(void))]
    public partial class SetAIMetaLanguageCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The default language to use for image metadata operations. This will be used by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no language is explicitly specified.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The default language for image metadata operations")]
        [ValidateSet(
            "Afrikaans",
            "Akan",
            "Albanian",
            "Amharic",
            "Arabic",
            "Armenian",
            "Azerbaijani",
            "Basque",
            "Belarusian",
            "Bemba",
            "Bengali",
            "Bihari",
            "Bosnian",
            "Breton",
            "Bulgarian",
            "Cambodian",
            "Catalan",
            "Cherokee",
            "Chichewa",
            "Chinese (Simplified)",
            "Chinese (Traditional)",
            "Corsican",
            "Croatian",
            "Czech",
            "Danish",
            "Dutch",
            "English",
            "Esperanto",
            "Estonian",
            "Ewe",
            "Faroese",
            "Filipino",
            "Finnish",
            "French",
            "Frisian",
            "Ga",
            "Galician",
            "Georgian",
            "German",
            "Greek",
            "Guarani",
            "Gujarati",
            "Haitian Creole",
            "Hausa",
            "Hawaiian",
            "Hebrew",
            "Hindi",
            "Hungarian",
            "Icelandic",
            "Igbo",
            "Indonesian",
            "Interlingua",
            "Irish",
            "Italian",
            "Japanese",
            "Javanese",
            "Kannada",
            "Kazakh",
            "Kinyarwanda",
            "Kirundi",
            "Kongo",
            "Korean",
            "Krio (Sierra Leone)",
            "Kurdish",
            "Kurdish (Soranî)",
            "Kyrgyz",
            "Laothian",
            "Latin",
            "Latvian",
            "Lingala",
            "Lithuanian",
            "Lozi",
            "Luganda",
            "Luo",
            "Macedonian",
            "Malagasy",
            "Malay",
            "Malayalam",
            "Maltese",
            "Maori",
            "Marathi",
            "Mauritian Creole",
            "Moldavian",
            "Mongolian",
            "Montenegrin",
            "Nepali",
            "Nigerian Pidgin",
            "Northern Sotho",
            "Norwegian",
            "Norwegian (Nynorsk)",
            "Occitan",
            "Oriya",
            "Oromo",
            "Pashto",
            "Persian",
            "Polish",
            "Portuguese (Brazil)",
            "Portuguese (Portugal)",
            "Punjabi",
            "Quechua",
            "Romanian",
            "Romansh",
            "Runyakitara",
            "Russian",
            "Scots Gaelic",
            "Serbian",
            "Serbo-Croatian",
            "Sesotho",
            "Setswana",
            "Seychellois Creole",
            "Shona",
            "Sindhi",
            "Sinhalese",
            "Slovak",
            "Slovenian",
            "Somali",
            "Spanish",
            "Spanish (Latin American)",
            "Sundanese",
            "Swahili",
            "Swedish",
            "Tajik",
            "Tamil",
            "Tatar",
            "Telugu",
            "Thai",
            "Tigrinya",
            "Tonga",
            "Tshiluba",
            "Tumbuka",
            "Turkish",
            "Turkmen",
            "Twi",
            "Uighur",
            "Ukrainian",
            "Urdu",
            "Uzbek",
            "Vietnamese",
            "Welsh",
            "Wolof",
            "Xhosa",
            "Yiddish",
            "Yoruba",
            "Zulu")]
        public string Language { get; set; }

        /// <summary>
        /// Database path for preference data files.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for preference data files")]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// When specified, stores the settings only in the current session (Global variables) without persisting to preferences. Settings will be lost when the session ends.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc")]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// When specified, clears only the session settings (Global variables) without affecting persistent preferences.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc")]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc")]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Copy identical parameters to Set-GenXdevPreference
            var invocationParams = CopyIdenticalParamValues("GenXdev.Data\\Set-GenXdevPreference");

            // Determine the value for AIMetaLanguage
            string value;
            if (string.IsNullOrWhiteSpace(Language))
            {
                var gdwlParams = CopyIdenticalParamValues("GenXdev.Helpers\\Get-DefaultWebLanguage");
                var defaultValueScript = ScriptBlock.Create("param ($gdwlParams) GenXdev.Helpers\\Get-DefaultWebLanguage @gdwlParams");
                var defaultValueResult = defaultValueScript.Invoke(gdwlParams);
                value = ((PSObject)defaultValueResult[0]).BaseObject.ToString();
            }
            else
            {
                value = Language;
            }

            // Create a fresh Hashtable clone for the Set-GenXdevPreference invocation
            // This avoids mutating the original invocationParams returned by CopyIdenticalParamValues
            var setPrefParams = CopyIdenticalParamValues("GenXdev.Data\\Set-GenXdevPreference");

            // Set the Name and Value parameters on the cloned hashtable
            setPrefParams["Name"] = "AIMetaLanguage";
            setPrefParams["Value"] = value;

            // Invoke Set-GenXdevPreference with the cloned parameters
            var invokeScript = ScriptBlock.Create("param($params) GenXdev.Data\\Set-GenXdevPreference @params");
            foreach (var line in invokeScript.Invoke(setPrefParams))
            {
                Console.WriteLine(line.ToString().Trim());
            }
        }
    }
}