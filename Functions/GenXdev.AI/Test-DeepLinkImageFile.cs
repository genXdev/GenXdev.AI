// ################################################################################
// Part of PowerShell module : GenXdev.AI
// Original cmdlet filename  : Test-DeepLinkImageFile.cs
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



using System.IO;
using System.Management.Automation;

namespace GenXdev.AI
{
    /// <summary>
    /// <para type="synopsis">
    /// Tests if the specified file path is a valid image file with a supported format.
    /// </para>
    ///
    /// <para type="description">
    /// This function validates that a file exists at the specified path and has a
    /// supported image file extension. It checks for common image formats including
    /// PNG, JPG, JPEG, GIF, BMP, WebP, TIFF, and TIF files. The function throws
    /// exceptions for invalid paths or unsupported file formats.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Path &lt;string&gt;<br/>
    /// The file path to the image file to be tested. Must be a valid file system path.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Test if a JPG file is valid</para>
    /// <para>This example tests whether the specified JPG file exists and has a supported image format.</para>
    /// <code>
    /// Test-DeepLinkImageFile -Path "C:\Images\photo.jpg"
    /// </code>
    /// </example>
    ///
    /// <example>
    /// <para>Test if a PNG file is valid using positional parameter</para>
    /// <para>This example demonstrates using the Path parameter positionally.</para>
    /// <code>
    /// Test-DeepLinkImageFile "C:\Images\logo.png"
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsDiagnostic.Test, "DeepLinkImageFile")]
    [OutputType(typeof(void))]
    public class TestDeepLinkImageFileCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The file path to the image file to be tested
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The file path to the image file to be tested")]
        public string Path { get; set; }

        private string[] validExtensions = { ".png", ".jpg", ".jpeg", ".gif", ".bmp", ".webp", ".tiff", ".tif" };

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
            // Check if the file exists at the specified path
            if (!File.Exists(Path))
            {
                throw new FileNotFoundException($"Image file not found: {Path}");
            }

            // Get the file extension and convert to lowercase for comparison
            string fileExtension = System.IO.Path.GetExtension(Path).ToLower();

            // Verify the file has a supported image format extension
            if (!((System.Collections.Generic.IList<string>)validExtensions).Contains(fileExtension))
            {
                throw new ArgumentException("Invalid image format. Supported formats: png, jpg, jpeg, gif, bmp, webp, tiff, tif");
            }

            // Output verbose information about successful validation
            WriteVerbose($"Successfully validated image file: {Path}");
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}