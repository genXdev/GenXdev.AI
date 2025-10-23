// ################################################################################
// Part of PowerShell module : GenXdev.AI
// Original cmdlet filename  : Get-VectorSimilarity.cs
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
using System.Management.Automation;

namespace GenXdev.AI
{
    /// <summary>
    /// <para type="synopsis">
    /// Calculates the cosine similarity between two vectors, returning a value between 0 and 1.
    /// </para>
    ///
    /// <para type="description">
    /// This function takes two numerical vectors (arrays) as input and computes their cosine similarity.
    /// The result indicates how closely related the vectors are, with 0 meaning completely dissimilar and 1 meaning identical.
    /// </para>
    ///
    /// <para type="description">
    /// PARAMETERS
    /// </para>
    ///
    /// <para type="description">
    /// -Vector1 &lt;double[]&gt;<br/>
    /// The first vector as an array of numbers (e.g., [0.12, -0.45, 0.89]). Must be the same length as Vector2.<br/>
    /// - <b>Position</b>: 0<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <para type="description">
    /// -Vector2 &lt;double[]&gt;<br/>
    /// The second vector as an array of numbers (e.g., [0.15, -0.40, 0.92]). Must be the same length as Vector1.<br/>
    /// - <b>Position</b>: 1<br/>
    /// - <b>Mandatory</b>: true<br/>
    /// </para>
    ///
    /// <example>
    /// <para>Calculate similarity between two example vectors</para>
    /// <para>This example demonstrates calculating the cosine similarity between two 3-dimensional vectors.</para>
    /// <code>
    /// $v1 = @(0.12, -0.45, 0.89)
    /// $v2 = @(0.15, -0.40, 0.92)
    /// Get-VectorSimilarity -Vector1 $v1 -Vector2 $v2
    /// </code>
    /// <para>Returns approximately 0.998, indicating high similarity</para>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsCommon.Get, "VectorSimilarity")]
    [OutputType(typeof(double))]
    public class GetVectorSimilarityCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The first vector as an array of numbers (e.g., [0.12, -0.45, 0.89]). Must be the same length as Vector2.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "First vector array of numbers")]
        public double[] Vector1 { get; set; }

        /// <summary>
        /// The second vector as an array of numbers (e.g., [0.15, -0.40, 0.92]). Must be the same length as Vector1.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Second vector array of numbers")]
        public double[] Vector2 { get; set; }

        /// <summary>
        /// Begin processing - validate input vectors
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Validating input vectors...");

            // Check for null vectors
            if (Vector1 == null || Vector2 == null)
            {
                WriteError(new ErrorRecord(
                    new ArgumentException("Both Vector1 and Vector2 must contain values."),
                    "NullVector",
                    ErrorCategory.InvalidArgument,
                    null));
                return;
            }

            // Verify vectors have matching lengths
            if (Vector1.Length != Vector2.Length)
            {
                WriteError(new ErrorRecord(
                    new ArgumentException("Vector1 and Vector2 must have the same length."),
                    "LengthMismatch",
                    ErrorCategory.InvalidArgument,
                    null));
                return;
            }

            // Ensure vectors are not empty
            if (Vector1.Length == 0)
            {
                WriteError(new ErrorRecord(
                    new ArgumentException("Vectors cannot be empty."),
                    "EmptyVector",
                    ErrorCategory.InvalidArgument,
                    null));
                return;
            }
        }

        /// <summary>
        /// Process record - calculate vector similarity
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                WriteVerbose("Calculating vector similarity...");

                // Compute the dot product of the two vectors
                double dotProduct = 0.0;
                for (int i = 0; i < Vector1.Length; i++)
                {
                    dotProduct += Vector1[i] * Vector2[i];
                }

                // Calculate the magnitude (euclidean norm) of each vector
                double magnitude1 = 0.0;
                double magnitude2 = 0.0;
                for (int i = 0; i < Vector1.Length; i++)
                {
                    magnitude1 += Math.Pow(Vector1[i], 2);
                    magnitude2 += Math.Pow(Vector2[i], 2);
                }
                magnitude1 = Math.Sqrt(magnitude1);
                magnitude2 = Math.Sqrt(magnitude2);

                // Prevent division by zero for zero-magnitude vectors
                if (magnitude1 == 0 || magnitude2 == 0)
                {
                    WriteVerbose("One or both vectors have zero magnitude. Similarity is undefined.");
                    WriteObject(0.0);
                    return;
                }

                // Calculate final cosine similarity
                double similarity = dotProduct / (magnitude1 * magnitude2);

                // Normalize result to 0-1 range
                double normalizedSimilarity = Math.Min(Math.Max(similarity, -1), 1);
                normalizedSimilarity = (normalizedSimilarity + 1) / 2;

                WriteVerbose("Similarity calculation complete");
                WriteObject(Math.Round(normalizedSimilarity, 6));
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "SimilarityCalculationError",
                    ErrorCategory.InvalidOperation,
                    null));
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}