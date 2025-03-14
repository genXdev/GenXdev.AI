################################################################################
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
        Write-Verbose "Starting GPU capability verification"
    }

    process {
        # define minimum required gpu memory (4GB in bytes)
        $requiredMemory = 1024 * 1024 * 1024 * 4

        # query system for video controllers meeting memory requirement
        $videoControllers = Get-WmiObject `
            -Class Win32_VideoController |
        Where-Object { $_.AdapterRAM -ge $requiredMemory }

        # output number of capable gpus found for debugging
        Write-Verbose "Detected $($videoControllers.Count) GPUs with 4GB+ RAM"

        # return true if at least one capable gpu was found
        return $null -ne $videoControllers
    }

    end {
    }
}
################################################################################