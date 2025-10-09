<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Stop-ComfyUI.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
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
################################################################################
<#
.SYNOPSIS
Terminates all running ComfyUI processes and releases associated resources.

.DESCRIPTION
Safely stops all processes related to ComfyUI by identifying processes with
the name 'comfyui'. This function is used to clean up ComfyUI processes after
image generation or when a forced shutdown is requested. It provides verbose
feedback for debugging and handles cases where no ComfyUI processes are
running.

.EXAMPLE
Stop-ComfyUI -Verbose
Terminates ComfyUI processes with detailed output for debugging.

.NOTES
This function is designed to be called by other ComfyUI-related cmdlets, such
as Invoke-ComfyUIImageGeneration, particularly when the -Force parameter is used or
when -KeepComfyUIRunning is not specified. It uses PowerShell's process
management to ensure clean termination without leaving orphaned processes.
#>
function Stop-ComfyUI {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]

    param()

    begin {

        # display progress indicator to inform user of operation status
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Termination" `
            -Status "Stopping ComfyUI processes..."
    }

    process {

        try {

            # search for all running processes with the name 'comfyui'
            $comfyProcesses = Microsoft.PowerShell.Management\Get-Process `
                -Name 'comfyui' `
                -ErrorAction SilentlyContinue

            # evaluate if any comfyui processes were discovered
            if ($comfyProcesses) {

                # inform user about the number of processes found
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found $($comfyProcesses.Count) ComfyUI process(es) to " +
                    "terminate."
                )

                # iterate through each discovered process for termination
                foreach ($process in $comfyProcesses) {

                    # inform user about the specific process being terminated
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Terminating process ID $($process.Id)..."
                    )

                    # forcefully terminate the process to ensure cleanup
                    Microsoft.PowerShell.Management\Stop-Process `
                        -Id $process.Id `
                        -Force `
                        -ErrorAction Stop
                }

                # pause briefly to allow system to complete process termination
                Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500

                # check if any comfyui processes are still running after termination
                $remainingProcesses = Microsoft.PowerShell.Management\Get-Process `
                    -Name 'comfyui' `
                    -ErrorAction SilentlyContinue

                # verify successful termination of all processes
                if (-not $remainingProcesses) {

                    # confirm successful termination to user
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "All ComfyUI processes successfully terminated."
                    )
                } else {

                    # warn user about processes that could not be terminated
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Some ComfyUI processes could not be terminated."
                    )
                }
            } else {

                # inform user that no comfyui processes were found
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "No ComfyUI processes found running."
                )
            }
        }
        catch {

            # handle and report any errors during process termination
            Microsoft.PowerShell.Utility\Write-Warning (
                "Failed to stop ComfyUI processes: $($_.Exception.Message)"
            )
        }
    }

    end {

        # complete the progress indicator to signal operation completion
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Termination" `
            -Completed
    }
}
################################################################################