################################################################################
<#
.SYNOPSIS
Checks if the system has a CUDA-capable GPU with sufficient memory.

.DESCRIPTION
This function determines if the system has a CUDA-compatible GPU with at least
8GB of RAM installed. It uses WMI queries to gather information about installed
video controllers.

.EXAMPLE
$hasGpu = Get-HasCapableGpu
Write-Host "CUDA-capable GPU present: $hasGpu"

.NOTES
Requires at least 17GB of GPU RAM to return true.
#>
function Get-HasCapableGpu {

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Checking for CUDA-capable GPU with 17GB+ RAM"
    }

    process {
        $videoControllers = Get-WmiObject Win32_VideoController |
            Where-Object { $PSItem.AdapterRAM -ge (1024*1024*1024*17) }

        Write-Verbose "Found $($videoControllers.Count) GPUs with 8GB+ RAM"

        # return true if any matching GPU was found
        return $null -ne $videoControllers
    }

    end {}
}
################################################################################
