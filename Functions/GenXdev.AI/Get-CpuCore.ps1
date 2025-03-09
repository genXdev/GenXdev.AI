################################################################################
<#
.SYNOPSIS
Calculates and returns the total number of logical CPU cores in the system.

.DESCRIPTION
Queries the system hardware through Windows Management Instrumentation (WMI) to
determine the total number of logical CPU cores. The function accounts for
hyperthreading by multiplying the physical core count by 2.

.EXAMPLE
# Get the total number of logical CPU cores
$cores = Get-CpuCore
Write-Host "System has $cores logical CPU cores available"
#>
function Get-CpuCore {

    [CmdletBinding(DefaultParameterSetName = "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param()

    begin {

        # initialize counter for tracking total physical cores
        $totalPhysicalCores = 0
        Write-Verbose "Initializing CPU core count calculation"
    }

    process {

        # query physical processors through WMI
        $processors = Get-WmiObject -Class Win32_Processor
        Write-Verbose "Retrieved $($processors.Count) physical processors"

        # sum cores from each processor
        $processors |
        Select-Object -Property NumberOfCores |
        ForEach-Object {

            $totalPhysicalCores += $_.NumberOfCores
            Write-Verbose "Added $($_.NumberOfCores) cores from processor"
        }

        # account for hyperthreading
        $logicalCores = $totalPhysicalCores * 2
        Write-Verbose "Final count: $logicalCores logical cores"
    }

    end {

        return $logicalCores
    }
}
################################################################################
