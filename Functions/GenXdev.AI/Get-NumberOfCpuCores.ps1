################################################################################
<#
.SYNOPSIS
Returns the total number of logical CPU cores available in the system.

.DESCRIPTION
This function queries WMI to get the number of physical CPU cores and returns the
total number of logical cores (physical cores * 2 for hyperthreading).

.EXAMPLE
Get-NumberOfCpuCores
Returns the total number of logical CPU cores.
#>
function Get-NumberOfCpuCores {

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Initializing CPU core count calculation"
        $totalCores = 0
    }

    process {
        # query wmi for processor information
        $processors = Get-WmiObject -Class Win32_Processor

        # calculate total physical cores across all processors
        $processors |
            Select-Object -Property NumberOfCores |
            ForEach-Object {
                $totalCores += $PSItem.NumberOfCores
                Write-Verbose "Found processor with $($PSItem.NumberOfCores) cores"
            }

        # multiply by 2 to account for hyperthreading
        $logicalCores = $totalCores * 2
        Write-Verbose "Total logical cores: $logicalCores"
    }

    end {
        return $logicalCores
    }
}
################################################################################
