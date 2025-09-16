<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-CpuCore.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.270.2025
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