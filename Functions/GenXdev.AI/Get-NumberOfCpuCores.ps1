<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-NumberOfCpuCores.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.274.2025
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
hyperthreading by multiplying the physical core count by 2. This information is
useful for optimizing parallel processing tasks and understanding system
capabilities.

The calculation process:
1. Queries WMI for all physical processors
2. Sums up the number of physical cores across all processors
3. Multiplies by 2 to account for hyperthreading
4. Returns the total logical core count

.EXAMPLE
Get the total number of logical CPU cores
$cores = Get-NumberOfCpuCores
Write-Host "System has $cores logical CPU cores available"

.NOTES
- Assumes all processors support hyperthreading
- Requires WMI access permissions
- Works on Windows systems only
##############################################################################
#>

function Get-NumberOfCpuCores {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param(
        
    )

    begin {

        # initialize counter for tracking total physical cores across all CPUs
        $totalPhysicalCores = 0
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting CPU core count calculation'
    }


    process {

        # query all physical processors through WMI
        $processors = CimCmdlets\Get-CimInstance -Class Win32_Processor
        Microsoft.PowerShell.Utility\Write-Verbose "Found $($processors.Count) physical processors"

        # sum up the number of cores from each physical processor
        $processors |
            Microsoft.PowerShell.Utility\Select-Object -Property NumberOfCores |
            Microsoft.PowerShell.Core\ForEach-Object {

                $totalPhysicalCores += $_.NumberOfCores
                Microsoft.PowerShell.Utility\Write-Verbose "Added $($_.NumberOfCores) cores from processor"
            }

        # calculate logical cores (assuming hyperthreading doubles the count)
        $logicalCores = $totalPhysicalCores * 2
        Microsoft.PowerShell.Utility\Write-Verbose "Calculated $logicalCores total logical cores"
    }

    end {

        return $logicalCores
    }
}