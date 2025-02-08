################################################################################
<#
.SYNOPSIS
Gets the a window helper for the LM Studio application.

.DESCRIPTION
Gets the a window helper for the LM Studio application. If LM Studio is not
running, it will be started automatically.

.EXAMPLE
Get-LMStudioWindow
#>
function Get-LMStudioWindow {

    [CmdletBinding()]
    param()

    begin {

        Write-Verbose "Starting to look for LM Studio window"
    }

    process {

        # try to find running LM Studio process with a main window
        $process = Get-Process "LM Studio" |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Select-Object -First 1

        if ($process) {

            Write-Verbose "Found running LM Studio process with ID: $($process.Id)"
            # return a window helper for the found process
            Get-Window -ProcessId ($process.Id)
        }
        else {

            Write-Verbose "No running LM Studio found, starting new instance"
            # start LM Studio and try again
            $null = AssureLMStudio -Force

            # look for the newly started process
            $process = Get-Process "LM Studio" |
            Where-Object { $_.MainWindowHandle -ne 0 } |
            Select-Object -First 1

            if ($process) {

                Write-Verbose "Successfully started LM Studio with ID: $($process.Id)"
                # return the window handle for the new process
                Get-Window -ProcessId ($process.Id)
            }
        }
    }

    end {}
}
################################################################################
