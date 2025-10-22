// ################################################################################
// Part of PowerShell module : GenXdev.AI.ComfyUI
// Original cmdlet filename  : Get-ComfyUIModelPath.cs
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



using System;
using System.Collections.Generic;
using System.IO;
using System.Management.Automation;
using System.Text.RegularExpressions;

namespace GenXdev.AI.ComfyUI
{
    /// <summary>
    /// <para type="synopsis">
    /// Gets the correct ComfyUI models directory path for the current installation
    /// </para>
    ///
    /// <para type="description">
    /// Detects the actual ComfyUI installation path and returns the appropriate models
    /// directory path. This cmdlet centralizes the logic for finding ComfyUI
    /// installations across different installation methods (standard, Electron app,
    /// portable, etc.) and provides a consistent way for other cmdlets to locate
    /// model storage directories.
    ///
    /// The cmdlet checks multiple possible installation paths in order of preference
    /// and returns the first existing path. If no installation is found, it returns
    /// the most likely path where ComfyUI would be installed.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Subfolder &lt;String&gt;<br/>
    /// The subfolder under the models directory (e.g., "checkpoints", "vae", "loras").<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Default</b>: "checkpoints"<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -ReturnAll &lt;SwitchParameter&gt;<br/>
    /// Switch to return all possible model paths instead of just the first existing one.<br/>
    /// Useful for cmdlets that need to search across all possible locations.<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Get the path to the checkpoints directory for the current ComfyUI installation.</para>
    /// <para>This example demonstrates how to get the default model path.</para>
    /// <code>
    /// $modelPath = Get-ComfyUIModelPath
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Get the path to the VAE models directory.</para>
    /// <para>This example shows how to specify a subfolder.</para>
    /// <code>
    /// $vaePath = Get-ComfyUIModelPath -Subfolder "vae"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Return all possible model paths for comprehensive searching.</para>
    /// <para>This example demonstrates returning all paths.</para>
    /// <code>
    /// $allPaths = Get-ComfyUIModelPath -ReturnAll
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "ComfyUIModelPath")]
    [OutputType(typeof(string))]
    public partial class GetComfyUIModelPathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The subfolder under the models directory (e.g., "checkpoints", "vae", "loras").
        /// Defaults to "checkpoints" for standard diffusion models.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "Subfolder under models directory (e.g., checkpoints, vae, loras)")]
        public string Subfolder { get; set; } = "checkpoints";

        /// <summary>
        /// Switch to return all possible model paths instead of just the first existing one.
        /// Useful for cmdlets that need to search across all possible locations.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Return all possible paths instead of just the first existing one")]
        public SwitchParameter ReturnAll { get; set; }

        private List<string> modelPaths;

        private List<string> possibleBasePaths;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Resolve local application data directory for default electron install
            string localAppData = Environment.GetFolderPath(
                Environment.SpecialFolder.LocalApplicationData
            );

            if (string.IsNullOrWhiteSpace(localAppData))
            {
                localAppData = Environment.GetEnvironmentVariable("LOCALAPPDATA");
            }

            possibleBasePaths = new List<string>();

            if (!string.IsNullOrWhiteSpace(localAppData))
            {
                possibleBasePaths.Add(
                    ExpandPath(
                        Path.Combine(
                            localAppData,
                            "Programs",
                            "@comfyorgcomfyui-electron",
                            "resources",
                            "ComfyUI"
                        )
                    )
                );
            }
            else
            {
                WriteVerbose(
                    "LOCALAPPDATA not resolved; using current directory fallback for ComfyUI."
                );

                possibleBasePaths.Add(
                    ExpandPath(Path.Combine(Environment.CurrentDirectory, "ComfyUI"))
                );
            }

            // Initialize list to store discovered model paths
            modelPaths = new List<string>();

            // Iterate through each potential ComfyUI installation path
            foreach (string basePath in possibleBasePaths)
            {
                // Construct path to the extra model paths YAML configuration file
                string yamlPath = Path.Combine(basePath, "extra_model_paths.yaml");

                // Check if custom YAML configuration exists
                if (File.Exists(yamlPath))
                {
                    // Read the entire YAML configuration file content
                    string yamlContent = File.ReadAllText(yamlPath);

                    // Check for custom section with base_path and subfolder configuration
                    Match customMatch = Regex.Match(yamlContent, @"(?ms)^custom:\s*\n.*?base_path:\s*(.+?)\s*\n.*?" + Regex.Escape(Subfolder) + @":\s*(.+?)\s*(\n|$)");
                    if (customMatch.Success)
                    {
                        // Extract the custom base path from YAML
                        string customBasePath = customMatch.Groups[1].Value.Trim();

                        // Extract the subfolder path from YAML
                        string customSubfolder = customMatch.Groups[2].Value.Trim();

                        // Combine base path with subfolder to create full path
                        string customFullPath = ExpandPath(
                            Path.Combine(customBasePath, customSubfolder)
                        );

                        // Expand and add the custom path to model paths list
                        modelPaths.Add(customFullPath);

                        WriteVerbose($"Custom path from YAML custom section: {customFullPath}");

                        continue;
                    }

                    // Fallback check for direct subfolder mapping in legacy format
                    Match directMatch = Regex.Match(yamlContent, Regex.Escape(Subfolder) + @":\s*(.+?)\s*(\n|$)");
                    if (directMatch.Success)
                    {
                        // Extract the custom subfolder path
                        string customSubPath = ExpandPath(
                            directMatch.Groups[1].Value.Trim()
                        );

                        // Expand and add the custom path to model paths list
                        modelPaths.Add(customSubPath);

                        WriteVerbose($"Custom path from YAML direct mapping: {customSubPath}");

                        continue;
                    }
                }

                // Construct default model path for this installation
                string subPath = string.IsNullOrEmpty(Subfolder) ? "" : Path.Combine("models", Subfolder);

                // Combine base path with models subfolder
                string defaultModelPath = ExpandPath(Path.Combine(basePath, subPath));

                // Add default path to model paths list
                modelPaths.Add(defaultModelPath);
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check if caller wants all possible paths returned
            if (ReturnAll.ToBool())
            {
                WriteVerbose($"Returning all paths for subfolder: {Subfolder}");

                WriteObject(modelPaths, true);
                return;
            }

            // Prioritize custom YAML configured paths even if they don't exist yet
            foreach (string modelPath in modelPaths)
            {
                WriteVerbose($"Checking: {modelPath}");

                // If this is a custom path from YAML configuration, return it immediately
                // because it represents the user's explicit configuration choice
                if (Regex.IsMatch(modelPath, @"^[A-Za-z]:\\") &&
                    !Regex.IsMatch(modelPath, @"\\Programs\\@comfyorgcomfyui-electron\\"))
                {
                    WriteVerbose($"Using custom configured path: {modelPath}");

                    WriteObject(modelPath);
                    return;
                }

                // For default paths, only return if they exist
                if (Directory.Exists(modelPath) || File.Exists(modelPath))
                {
                    WriteVerbose($"Found existing path: {modelPath}");

                    WriteObject(modelPath);
                    return;
                }
            }

            // Initialize variable for preferred fallback path
            string preferredPath = null;

            // Check for any existing ComfyUI installation as fallback
            foreach (string basePath in possibleBasePaths)
            {
                // Test if this base installation path exists
                if (Directory.Exists(basePath))
                {
                    // Construct the expected model path for this installation
                    string subPath = string.IsNullOrEmpty(Subfolder) ? "" : Path.Combine("models", Subfolder);

                    // Combine base path with models subfolder
                    preferredPath = ExpandPath(Path.Combine(basePath, subPath));

                    WriteVerbose($"Installation at: {basePath}, preferred: {preferredPath}");

                    WriteObject(preferredPath);
                    return;
                }
            }

            // Use ultimate fallback path when no installation found
            string fallbackPath = modelPaths.Count > 0
                ? modelPaths[0]
                : ExpandPath(
                    Path.Combine(
                        Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                        "Programs",
                        "@comfyorgcomfyui-electron",
                        "resources",
                        "ComfyUI",
                        string.IsNullOrEmpty(Subfolder) ? "" : Path.Combine("models", Subfolder)
                    )
                );

            WriteVerbose($"Fallback: {fallbackPath}");

            WriteObject(fallbackPath);
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