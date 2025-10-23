// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Add-GenXdevMCPServerToLMStudio.cs
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
using System.Diagnostics;
using System.Management.Automation;
using System.Text;

namespace GenXdev.AI.LMStudio
{
    /// <summary>
    /// <para type="synopsis">
    /// Adds the GenXdev MCP server to LM Studio using a deeplink configuration.
    /// </para>
    ///
    /// <para type="description">
    /// This function creates an MCP (Model Context Protocol) server configuration
    /// for GenXdev and launches LM Studio with a deeplink to automatically add the
    /// server. The function encodes the server configuration as a Base64 string and
    /// constructs an appropriate LM Studio deeplink URL for seamless integration.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -ServerName &lt;string&gt;<br/>
    /// The name to assign to the MCP server in LM Studio. This name will be displayed<br/>
    /// in the LM Studio interface when managing MCP servers.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: "GenXdev"<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Url &lt;string&gt;<br/>
    /// The HTTP URL where the GenXdev MCP server is listening for connections. This<br/>
    /// should include the protocol, host, port, and path components.<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Default</b>: "http://localhost:2175/mcp"<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Adds the GenXdev MCP server to LM Studio with default settings</para>
    /// <para>This example demonstrates adding the GenXdev MCP server to LM Studio using the default server name and URL.</para>
    /// <code>
    /// Add-GenXdevMCPServerToLMStudio
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Adds the GenXdev MCP server to LM Studio with custom settings</para>
    /// <para>This example shows how to specify a custom server name and URL when adding the MCP server.</para>
    /// <code>
    /// Add-GenXdevMCPServerToLMStudio -ServerName "MyGenXdev" -Url "http://192.168.1.100:2175/mcp"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Add, "GenXdevMCPServerToLMStudio")]
    [OutputType(typeof(void))]
    public class AddGenXdevMCPServerToLMStudioCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name to assign to the MCP server in LM Studio
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "The name to assign to the MCP server in LM Studio"
        )]
        public string ServerName { get; set; } = "GenXdev";

        /// <summary>
        /// The HTTP URL where the GenXdev MCP server is listening
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "The HTTP URL where the GenXdev MCP server is listening"
        )]
        public string Url { get; set; } = "http://localhost:2175/mcp";

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose(
                "Preparing to add GenXdev MCP server '" + ServerName + "' at '" + Url + "' to " +
                "LM Studio"
            );
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // create the mcp server configuration as a json string for lm studio
            string mcpConfig = @"{
    ""servers"": {
        """ + ServerName + @""": {
            ""type"": ""http"",
            ""url"": """ + Url + @"""
        }
    }
}";

            // output verbose information about the configuration being created
            WriteVerbose(
                "Created MCP configuration JSON for server registration"
            );

            // encode the json configuration as base64 for deeplink transmission
            string encodedConfig = Convert.ToBase64String(
                Encoding.UTF8.GetBytes(mcpConfig)
            );

            // output verbose information about the encoding process
            WriteVerbose(
                "Encoded configuration as Base64 string for deeplink URL"
            );

            // construct the lm studio deeplink url with encoded configuration
            string deeplink = "lmstudio://mcp?config=" + encodedConfig;

            // output verbose information about the deeplink construction
            WriteVerbose(
                "Constructed LM Studio deeplink: " + deeplink
            );

            // launch lm studio application with the deeplink using start-process
            Process.Start(deeplink);

            // output confirmation message to the user about the operation
            Host.UI.WriteLine(
                "Launched LM Studio with deeplink to add GenXdev MCP server."
            );
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // output verbose information about the completion of the operation
            WriteVerbose(
                "Successfully completed GenXdev MCP server addition to LM Studio"
            );
        }
    }
}
// ###############################################################################