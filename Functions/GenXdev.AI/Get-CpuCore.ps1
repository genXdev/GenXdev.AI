﻿###############################################################################
<#
.SYNOPSIS
Calculates and returns the total number of logical CPU cores in the system.

.DESCRIPTION
Queries the system hardware through Windows Management Instrumentation (WMI) to
determine the total number of logical CPU cores. The function accounts for
hyperthreading by multiplying the physical core count by 2.

.EXAMPLE
Get the total number of logical CPU cores
$cores = Get-CpuCore
Write-Host "System has $cores logical CPU cores available"
#>
function Get-CpuCore {

    [CmdletBinding(DefaultParameterSetName = '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param()

    begin {

        # initialize counter for tracking total physical cores
        $totalPhysicalCores = 0
        Microsoft.PowerShell.Utility\Write-Verbose 'Initializing CPU core count calculation'
    }


    process {

        # query physical processors through WMI
        $processors = CimCmdlets\Get-CimInstance -Class Win32_Processor
        Microsoft.PowerShell.Utility\Write-Verbose "Retrieved $($processors.Count) physical processors"

        # sum cores from each processor
        $processors |
            Microsoft.PowerShell.Utility\Select-Object -Property NumberOfCores |
            Microsoft.PowerShell.Core\ForEach-Object {

                $totalPhysicalCores += $_.NumberOfCores
                Microsoft.PowerShell.Utility\Write-Verbose "Added $($_.NumberOfCores) cores from processor"
            }

        # account for hyperthreading
        $logicalCores = $totalPhysicalCores * 2
        Microsoft.PowerShell.Utility\Write-Verbose "Final count: $logicalCores logical cores"
    }

    end {

        return $logicalCores
    }
}