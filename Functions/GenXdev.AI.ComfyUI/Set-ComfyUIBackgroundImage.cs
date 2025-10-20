// ################################################################################
// Part of PowerShell module : GenXdev.AI.ComfyUI
// Original cmdlet filename  : Set-ComfyUIBackgroundImage.cs
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



using System;
using System.Collections;
using System.IO;
using System.Management.Automation;
using System.Web;

namespace GenXdev.AI.ComfyUI
{
    /// <summary>
    /// <para type="synopsis">
    /// Sets or clears the background image for ComfyUI's canvas interface
    /// </para>
    ///
    /// <para type="description">
    /// Configures ComfyUI to display a custom background image in the canvas area by
    /// updating the comfy.settings.json file. The function handles copying the image
    /// to the appropriate ComfyUI directory and updating the configuration settings.
    ///
    /// The background image is displayed behind the workflow nodes in ComfyUI's main
    /// canvas area, providing visual customization of the interface. Images are
    /// automatically copied to ComfyUI's input/backgrounds/ directory structure.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -ImagePath &lt;string&gt;<br/>
    /// Path to the image file to use as the background. Supported formats include
    /// PNG, JPG, JPEG, GIF, BMP, and WEBP. The image will be copied to ComfyUI's
    /// backgrounds directory and referenced in the settings.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>ParameterSet</b>: SetImage<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Clear &lt;SwitchParameter&gt;<br/>
    /// Removes the background image configuration from ComfyUI, returning the canvas
    /// to its default appearance without a background image.<br/>
    /// - <b>ParameterSet</b>: Clear<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Sets the specified image as ComfyUI's canvas background. The image will be
    /// copied to the ComfyUI backgrounds directory and configured in settings.</para>
    /// <code>
    /// Set-ComfyUIBackgroundImage -ImagePath "C:\Pictures\my-background.png"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Sets abstract-art.jpg as the background image for ComfyUI's canvas interface.</para>
    /// <code>
    /// Set-ComfyUIBackgroundImage "D:\Images\abstract-art.jpg"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Removes the current background image configuration, restoring ComfyUI's
    /// default canvas appearance without a background image.</para>
    /// <code>
    /// Set-ComfyUIBackgroundImage -Clear
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Set, "ComfyUIBackgroundImage")]
    [OutputType(typeof(void))]
    public partial class SetComfyUIBackgroundImageCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Path to the image file to set as background
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ParameterSetName = "SetImage",
            HelpMessage = "Path to the image file to set as background")]
        [ValidateNotNullOrEmpty]
        public string ImagePath { get; set; }

        /// <summary>
        /// Remove the background image configuration
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "Clear",
            HelpMessage = "Remove the background image configuration")]
        public SwitchParameter Clear { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Get ComfyUI base path
            var scriptBlock = ScriptBlock.Create("GenXdev.AI\\Get-ComfyUIModelPath -Verbose:$false");
            var result = scriptBlock.Invoke();
            var comfyPath = result.Count > 0 ? result[0]?.ToString() : null;
            if (string.IsNullOrEmpty(comfyPath))
            {
                var errorRecord = new ErrorRecord(
                    new InvalidOperationException("Could not determine ComfyUI installation path. Please ensure ComfyUI is properly configured."),
                    "ComfyUIPathNotFound",
                    ErrorCategory.InvalidOperation,
                    null);
                WriteError(errorRecord);
                return;
            }

            // Define paths
            var settingsPath = Path.Combine(comfyPath, "user", "default", "comfy.settings.json");
            var backgroundsDir = Path.Combine(comfyPath, "input", "backgrounds");

            WriteVerbose($"ComfyUI path: {comfyPath}");
            WriteVerbose($"Settings file: {settingsPath}");
            WriteVerbose($"Backgrounds directory: {backgroundsDir}");

            // Store in private fields for ProcessRecord
            this.comfyPath = comfyPath;
            this.settingsPath = settingsPath;
            this.backgroundsDir = backgroundsDir;
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Ensure settings file exists
            if (!File.Exists(this.settingsPath))
            {
                var errorRecord = new ErrorRecord(
                    new FileNotFoundException($"ComfyUI settings file not found at: {this.settingsPath}\nPlease ensure ComfyUI has been run at least once."),
                    "SettingsFileNotFound",
                    ErrorCategory.ObjectNotFound,
                    this.settingsPath);
                WriteError(errorRecord);
                return;
            }

            // Read current settings
            PSObject settingsContent;
            try
            {
                var jsonContent = File.ReadAllText(this.settingsPath);
                var jsonResult = ConvertFromJson(jsonContent);
                settingsContent = jsonResult.Length > 0 ? (PSObject)jsonResult[0] : new PSObject();
            }
            catch (Exception ex)
            {
                var errorRecord = new ErrorRecord(
                    new InvalidOperationException($"Failed to read ComfyUI settings file: {ex.Message}"),
                    "SettingsReadError",
                    ErrorCategory.ReadError,
                    this.settingsPath);
                WriteError(errorRecord);
                return;
            }

            if (Clear.ToBool())
            {
                // Remove background image setting
                if (settingsContent.Properties["Comfy.Canvas.BackgroundImage"] != null)
                {
                    settingsContent.Properties.Remove("Comfy.Canvas.BackgroundImage");
                    WriteVerbose("Removed background image setting from ComfyUI configuration");
                }
                else
                {
                    WriteVerbose("No background image was configured");
                }
            }
            else
            {
                // Validate ImagePath
                if (!File.Exists(ImagePath))
                {
                    var errorRecord = new ErrorRecord(
                        new FileNotFoundException($"Image file does not exist: {ImagePath}"),
                        "ImageFileNotFound",
                        ErrorCategory.ObjectNotFound,
                        ImagePath);
                    WriteError(errorRecord);
                    return;
                }

                var extension = Path.GetExtension(ImagePath).ToLower();
                var supportedFormats = new[] { ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp" };
                if (Array.IndexOf(supportedFormats, extension) == -1)
                {
                    var errorRecord = new ErrorRecord(
                        new ArgumentException($"Unsupported image format. Supported formats: {string.Join(", ", supportedFormats)}"),
                        "UnsupportedImageFormat",
                        ErrorCategory.InvalidArgument,
                        ImagePath);
                    WriteError(errorRecord);
                    return;
                }

                // Ensure backgrounds directory exists
                if (!Directory.Exists(this.backgroundsDir))
                {
                    Directory.CreateDirectory(this.backgroundsDir);
                    WriteVerbose($"Created backgrounds directory: {this.backgroundsDir}");
                }

                // Get image filename and copy to backgrounds directory
                var imageFileName = Path.GetFileName(ImagePath);
                var destinationPath = Path.Combine(this.backgroundsDir, imageFileName);

                try
                {
                    File.Copy(ImagePath, destinationPath, true);
                    WriteVerbose($"Copied background image to: {destinationPath}");
                }
                catch (Exception ex)
                {
                    var errorRecord = new ErrorRecord(
                        new IOException($"Failed to copy image file: {ex.Message}"),
                        "ImageCopyError",
                        ErrorCategory.WriteError,
                        ImagePath);
                    WriteError(errorRecord);
                    return;
                }

                // URL encode the filename for ComfyUI API
                var encodedFileName = HttpUtility.UrlEncode($"backgrounds/{imageFileName}");
                var backgroundUrl = $"/api/view?filename={encodedFileName}&type=input&subfolder=backgrounds";

                // Update settings with background image URL
                settingsContent.Properties.Add(new PSNoteProperty("Comfy.Canvas.BackgroundImage", backgroundUrl));
                WriteVerbose($"Set background image URL: {backgroundUrl}");
            }

            // Write updated settings back to file
            try
            {
                var jsonOutput = ConvertToJson(settingsContent, 10);
                File.WriteAllText(this.settingsPath, jsonOutput, System.Text.Encoding.UTF8);
                WriteVerbose("Updated ComfyUI settings file");
            }
            catch (Exception ex)
            {
                var errorRecord = new ErrorRecord(
                    new IOException($"Failed to update settings file: {ex.Message}"),
                    "SettingsWriteError",
                    ErrorCategory.WriteError,
                    this.settingsPath);
                WriteError(errorRecord);
                return;
            }

            // Output result
            if (Clear.ToBool())
            {
                var scriptBlock = ScriptBlock.Create("param($msg, $color) Write-Host $msg -ForegroundColor $color");
                Console.WriteLine("Background image cleared from ComfyUI configuration", "Green");
                Console.WriteLine("Restart ComfyUI for changes to take effect", "Yellow");
            }
            else
            {
                var imageFileName = Path.GetFileName(ImagePath);
                var scriptBlock = ScriptBlock.Create("param($msg, $color) Write-Host $msg -ForegroundColor $color");
                Console.WriteLine($"Background image set successfully: {imageFileName}", "Green");
                Console.WriteLine($"Image location: {Path.Combine(this.backgroundsDir, imageFileName)}", "Cyan");
                Console.WriteLine("Restart ComfyUI for changes to take effect", "Yellow");
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }

        private string comfyPath;
        private string settingsPath;
        private string backgroundsDir;
    }
}