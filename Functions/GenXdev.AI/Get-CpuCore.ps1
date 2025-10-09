<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-CpuCore.ps1
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