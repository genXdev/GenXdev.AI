<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-HasCapableGpu.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.272.2025
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