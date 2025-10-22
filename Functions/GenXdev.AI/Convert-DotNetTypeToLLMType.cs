// ################################################################################
// Part of PowerShell module : GenXdev.AI
// Original cmdlet filename  : Convert-DotNetTypeToLLMType.cs
// Original author           : René Vaessen / GenXdev
// Version                   : 1.308.2025
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



using System.Management.Automation;

namespace GenXdev.AI
{
    /// <summary>
    /// <para type="synopsis">
    /// Converts .NET type names to LLM (Language Model) type names.
    /// </para>
    ///
    /// <para type="description">
    /// This function takes a .NET type name as input and returns the corresponding
    /// simplified type name used in Language Models. It handles common .NET types
    /// and provides appropriate type mappings.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -DotNetType &lt;string&gt;<br/>
    /// The .NET type name to convert to an LLM type name.<br/>
    /// - <b>Position</b>: 0<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Convert a .NET type to LLM type</para>
    /// <para>This example shows how to convert a System.String type to its LLM equivalent.</para>
    /// <code>
    /// Convert-DotNetTypeToLLMType -DotNetType "System.String"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsData.Convert, "DotNetTypeToLLMType")]
    [OutputType(typeof(string))]
    public class ConvertDotNetTypeToLLMTypeCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The .NET type name to convert to an LLM type name
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The .NET type name to convert to an LLM type name")]
        public string DotNetType { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose($"Converting .NET type '{DotNetType}' to LLM type");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Convert the .net type to a simplified llm type using a switch statement
            // Note: For MCP content types, arrays should be treated as objects since 'array' is not a valid MCP content type
            string result = DotNetType switch
            {
                "System.Management.Automation.SwitchParameter" => "boolean",
                "System.Management.Automation.PSObject" => "object",
                "System.String" => "string",
                "System.Int32" => "number",
                "System.Int64" => "number",
                "System.Double" => "number",
                "System.Boolean" => "boolean",
                "System.Object[]" => "object",
                "System.Collections.Generic.List`1" => "object",
                "System.Collections.Hashtable" => "object",
                "System.Collections.Generic.Dictionary`2" => "object",
                _ => "object"
            };

            WriteVerbose($"Converted '{DotNetType}' to '{result}'");

            WriteObject(result);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}