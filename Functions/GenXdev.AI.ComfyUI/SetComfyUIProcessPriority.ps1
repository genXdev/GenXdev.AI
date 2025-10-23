<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : SetComfyUIProcessPriority.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################

<#
.SYNOPSIS
Sets ComfyUI processes to IDLE priority for CPU mode processing optimization.

.DESCRIPTION
Intelligently locates ComfyUI-related processes and sets their priority to IDLE
to prevent system performance impact during CPU-based image generation. This
function is essential for maintaining system responsiveness during long-running
AI generation tasks that can otherwise consume all available CPU resources.

The function uses multiple detection strategies to identify ComfyUI processes,
including direct process name matching, Python processes with ComfyUI window
titles, and command-line analysis. It only operates in CPU mode to avoid
interfering with GPU-optimized processing where maximum CPU priority may be
beneficial for coordination tasks.

.PARAMETER UseGPU
Flag indicating GPU processing mode. When true, the function returns
immediately without modifying process priorities since GPU mode typically
benefits from normal CPU priority for coordination and data transfer tasks.

.EXAMPLE
SetComfyUIProcessPriority
Sets all ComfyUI processes to IDLE priority for CPU-friendly processing.

.EXAMPLE
SetComfyUIProcessPriority -UseGPU
Skips priority adjustment since GPU mode is active.

.NOTES
This function requires appropriate permissions to modify process priorities.
The IDLE priority class allows ComfyUI to run in the background without
impacting interactive applications or system responsiveness.

The function silently continues if any process priority cannot be modified,
ensuring robust operation even with permission limitations or process
access restrictions.
#>
function SetComfyUIProcessPriority {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("GPU mode flag - skips priority setting if " +
                          "true")
        )]
        [switch]$UseGPU
        ###############################################################################
    )

    begin {

        # skip priority adjustment when running in gpu mode
        # gpu processing typically benefits from normal cpu priority for
        # coordination tasks, data transfer, and system interaction
        # idle priority could interfere with gpu-cpu communication efficiency
        if ($UseGPU) { return }
    }

    process {

        # find all comfyui-related processes using multiple detection strategies
        # this comprehensive approach ensures we catch all comfyui instances
        # regardless of how they were started or what python environment they use
        $comfyProcesses = Microsoft.PowerShell.Management\Get-Process |
            Microsoft.PowerShell.Core\Where-Object {
                # strategy 1: direct process name matching for comfyui executables
                # catches standalone comfyui installations and bundled versions
                $_.ProcessName -like "*ComfyUI*" -or

                # strategy 2: python processes with comfyui in window title
                # identifies python-based comfyui instances with visible windows
                ($_.ProcessName -eq "python" -and
                 $_.MainWindowTitle -like "*ComfyUI*") -or

                # strategy 3: python processes with comfyui in command line
                # detects headless comfyui instances running via python scripts
                ($_.ProcessName -eq "python" -and
                 $_.CommandLine -like "*ComfyUI*")
            } -ErrorAction SilentlyContinue

        # set each found process to idle priority for system responsiveness
        # idle priority allows comfyui to run without impacting user experience
        # or other applications during intensive cpu-based generation tasks
        foreach ($process in $comfyProcesses) {
            try {
                # assign idle priority class to minimize system impact
                # this ensures comfyui runs as a true background task
                # system and interactive applications maintain full responsiveness
                $process.PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle

                Microsoft.PowerShell.Utility\Write-Verbose ("Set process " +
                    "$($process.ProcessName) (PID: $($process.Id)) to " +
                    "IDLE priority")
            }
            catch {
                # silently continue if priority cannot be set
                # common causes: insufficient permissions, process already terminated
                # robust operation continues even with individual process failures
                Microsoft.PowerShell.Utility\Write-Verbose ("Failed to set " +
                    "priority for process $($process.ProcessName) " +
                    "(PID: $($process.Id)): $_")
            }
        }

        # report the number of processes that were processed
        # provides feedback about the scope of the priority adjustment operation
        if ($comfyProcesses.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose ("Processed " +
                "$($comfyProcesses.Count) ComfyUI-related process(es) for " +
                "priority adjustment")
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose ("No ComfyUI processes " +
                "found for priority adjustment")
        }
    }

    end {

        # priority adjustment operation completed
        # comfyui processes now run at idle priority for optimal system performance
        # this ensures cpu-intensive ai generation tasks remain background operations
        # system responsiveness is preserved for interactive applications and services
    }
}

################################################################################