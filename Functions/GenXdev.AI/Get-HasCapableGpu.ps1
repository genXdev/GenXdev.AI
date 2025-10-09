<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-HasCapableGpu.ps1
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
###############################################################################
<#
.SYNOPSIS
Determines if a CUDA-capable GPU with sufficient memory is present.

.DESCRIPTION
This function checks the system for CUDA-compatible GPUs with at least 4GB of
video RAM. It uses Windows Management Instrumentation (WMI) to query installed
video controllers and verify their memory capacity. This check is essential for
AI workloads that require significant GPU memory.

.OUTPUTS
[bool] Returns true if a capable GPU is found, false otherwise.

.EXAMPLE
$hasGpu = Get-HasCapableGpu
Write-Host "System has capable GPU: $hasGpu"
#>
function Get-HasCapableGpu {

    [CmdletBinding()]
    [OutputType([bool])]
    param()

    begin {
        # inform user that gpu check is starting
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting GPU capability verification'
    }


    process {
        # define minimum required gpu memory (4GB in bytes)
        $requiredMemory = 1024 * 1024 * 1024 * 4

        # query system for video controllers meeting memory requirement
        $videoControllers = CimCmdlets\Get-CimInstance `
            -Class Win32_VideoController |
            Microsoft.PowerShell.Core\Where-Object { $_.AdapterRAM -ge $requiredMemory }

        # output number of capable gpus found for debugging
        Microsoft.PowerShell.Utility\Write-Verbose "Detected $($videoControllers.Count) GPUs with 4GB+ RAM"

        # return true if at least one capable gpu was found
        return $null -ne $videoControllers
    }

    end {
    }
}