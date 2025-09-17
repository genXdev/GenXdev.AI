<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : SetComfyUIProcessPriority.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.274.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
################################################################################

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