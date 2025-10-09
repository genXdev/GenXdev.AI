<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Test-LMStudioProcess.ps1
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
Tests if LM Studio process is running and configures its window state.

.DESCRIPTION
Checks if LM Studio is running, and if so, returns true. If not running, it
returns false.

.EXAMPLE
[bool] $lmStudioRunning = Test-LMStudioProcess
#>
function Test-LMStudioProcess {

    [CmdletBinding()]
    [OutputType([bool])]
    param (
        [Parameter(Mandatory = $false)]
        [Alias('sw')]
        [switch] $ShowWindow
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Searching for LM Studio process...'
    }

    process {

        # get lm studio process with a valid window handle
        $process = Microsoft.PowerShell.Management\Get-Process -Name 'LM Studio' -ErrorAction SilentlyContinue | Microsoft.PowerShell.Core\ForEach-Object {

            if ($ShowWindow) {

                if ($PSItem.MainWindowHandle -ne 0) {

                    $PSItem
                }
            }
            else {

                $PSItem
            }
        }

        # return true if process exists, false otherwise
        $exists = $null -ne $process

        return $exists
    }

    end {
    }
}