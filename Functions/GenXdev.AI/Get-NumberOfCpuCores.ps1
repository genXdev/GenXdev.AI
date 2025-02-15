################################################################################
<#
.SYNOPSIS
Calculates and returns the total number of logical CPU cores in the system.

.DESCRIPTION
Queries the system hardware through Windows Management Instrumentation (WMI) to
determine the total number of logical CPU cores. The function accounts for
hyperthreading by multiplying the physical core count by 2. This information is
useful for optimizing parallel processing tasks and understanding system
capabilities.

The calculation process:
1. Queries WMI for all physical processors
2. Sums up the number of physical cores across all processors
3. Multiplies by 2 to account for hyperthreading
4. Returns the total logical core count

.EXAMPLE
# Get the total number of logical CPU cores
$cores = Get-NumberOfCpuCores
Write-Host "System has $cores logical CPU cores available"

.NOTES
- Assumes all processors support hyperthreading
- Requires WMI access permissions
- Works on Windows systems only
#>
function Get-NumberOfCpuCores {

    [CmdletBinding()]
    param()

    begin {

        # initialize counter for tracking total physical cores across all CPUs
        $totalPhysicalCores = 0
        Write-Verbose "Starting CPU core count calculation"
    }

    process {

        # query all physical processors through WMI
        $processors = Get-WmiObject -Class Win32_Processor
        Write-Verbose "Found $($processors.Count) physical processors"

        # sum up the number of cores from each physical processor
        $processors |
        Select-Object -Property NumberOfCores |
        ForEach-Object {

            $totalPhysicalCores += $_.NumberOfCores
            Write-Verbose "Added $($_.NumberOfCores) cores from processor"
        }

        # calculate logical cores (assuming hyperthreading doubles the count)
        $logicalCores = $totalPhysicalCores * 2
        Write-Verbose "Calculated $logicalCores total logical cores"
    }

    end {

        return $logicalCores
    }
}
################################################################################
