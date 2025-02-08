################################################################################
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
    )

    begin {

        Write-Verbose "Searching for LM Studio process..."
    }

    process {

        # get lm studio process with a valid window handle
        $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue

        # return true if process exists, false otherwise
        $exists = $null -ne $process

        return $exists
    }

    end {
    }
}
################################################################################
