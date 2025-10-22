// ################################################################################
// Part of PowerShell module : GenXdev.AI.LMStudio
// Original cmdlet filename  : Install-LMStudioApplication.cs
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
using System.Management.Automation;

namespace GenXdev.AI.LMStudio
{
    /// <summary>
    /// <para type="synopsis">
    /// Installs LM Studio application using WinGet package manager.
    /// </para>
    ///
    /// <para type="description">
    /// Ensures LM Studio is installed on the system by checking WinGet dependencies and
    /// installing LM Studio if not already present. Uses WinGet module with CLI fallback.
    /// </para>
    ///
    /// <example>
    /// <para>Install LM Studio application</para>
    /// <para>This example installs LM Studio if it is not already installed on the system.</para>
    /// <code>
    /// Install-LMStudioApplication
    /// </code>
    /// </example>
    /// </summary>
    [Cmdlet(VerbsLifecycle.Install, "LMStudioApplication")]
    [OutputType(typeof(void))]
    public class InstallLMStudioApplicationCommand : PSGenXdevCmdlet
    {
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
            try
            {
                // Ensure winget module is available
                InstallWingetDependency();

                // Package identifier for lm studio
                string lmStudioId = "ElementLabs.LMStudio";

                // Check if already installed
                WriteVerbose("Checking if LM Studio is already installed...");
                var installed = InvokeCommand.InvokeScript($"Microsoft.WinGet.Client\\Get-WinGetPackage -Id '{lmStudioId}' -ErrorAction Stop");

                if (installed == null || installed.Count == 0)
                {
                    // Request consent before installing lm studio
                    bool consent = ConfirmInstallationConsent("LM Studio", "WinGet", "Local AI model management and inference platform", "Element Labs", false, false);

                    if (!consent)
                    {
                        WriteWarning("Installation consent denied for LM Studio");
                        return;
                    }

                    WriteVerbose("Installing LM Studio...");

                    try
                    {
                        // Attempt install via powershell module
                        InvokeCommand.InvokeScript($"Microsoft.WinGet.Client\\Install-WinGetPackage -Id '{lmStudioId}' -Force -ErrorAction Stop");
                    }
                    catch
                    {
                        // Fallback to winget cli
                        WriteVerbose("Falling back to WinGet CLI...");
                        var wingetResult = InvokeCommand.InvokeScript($"winget install {lmStudioId}");
                        if (wingetResult == null || wingetResult.Count == 0 || ((PSObject)wingetResult[0]).Properties["LastExitCode"] == null || (int)((PSObject)wingetResult[0]).Properties["LastExitCode"].Value != 0)
                        {
                            throw new Exception("WinGet CLI installation failed");
                        }
                    }

                    // Reset cached paths after install
                    InvokeCommand.InvokeScript("$script:LMStudioExe = $null; $script:LMSExe = $null");
                    InvokeCommand.InvokeScript("GenXdev.AI\\Get-LMStudioPaths");

                    // Stop any running LM Studio process
                    InvokeCommand.InvokeScript("Microsoft.PowerShell.Management\\Get-Process 'LM Studio' -ErrorAction SilentlyContinue | Microsoft.PowerShell.Management\\Stop-Process -Force");

                    // Start LM Studio maximized
                    InvokeCommand.InvokeScript("param($exe) Microsoft.PowerShell.Management\\Start-Process -FilePath $exe -WindowStyle Maximized", new object[] { "$script:LMStudioExe" });
                }
                else
                {
                    WriteVerbose("LM Studio is already installed");
                }
            }
            catch (Exception ex)
            {
                throw new Exception($"Failed to install LM Studio: {ex.Message}", ex);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }

        /// <summary>
        /// Helper method to install winget dependency
        /// </summary>
        private void InstallWingetDependency()
        {
            try
            {
                InvokeCommand.InvokeScript("Microsoft.PowerShell.Core\\Import-Module 'Microsoft.WinGet.Client' -ErrorAction Stop");
            }
            catch
            {
                // Request consent before installing winget module
                bool consent = ConfirmInstallationConsent("Microsoft.WinGet.Client PowerShell Module", "PowerShell Gallery", "Required for managing Windows software packages programmatically", "Microsoft", false, false);

                if (!consent)
                {
                    throw new Exception("Installation consent denied for WinGet PowerShell module");
                }

                WriteVerbose("Installing WinGet PowerShell module...");
                InvokeCommand.InvokeScript("PowerShellGet\\Install-Module 'Microsoft.WinGet.Client' -Force -AllowClobber -ErrorAction Stop");
                InvokeCommand.InvokeScript("Microsoft.PowerShell.Core\\Import-Module 'Microsoft.WinGet.Client' -ErrorAction Stop");
            }
        }
    }
}