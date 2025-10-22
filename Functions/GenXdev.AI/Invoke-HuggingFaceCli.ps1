<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Invoke-HuggingFaceCli.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.308.2025
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
# Don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Invokes the Hugging Face CLI with the specified arguments.

.DESCRIPTION
Calls EnsureHuggingFace to ensure the CLI is installed, then executes the
Hugging Face CLI with the provided arguments. Reads the CLI path from
$ENV:LOCALAPPDATA\GenXdev.PowerShell\hfclilocation.json. Returns the command
output as a string; throws Write-Error on failure.

.PARAMETER Arguments
The arguments to pass to the Hugging Face CLI.

.PARAMETER Timeout
Timeout in seconds for CLI execution and dependency installation.

.PARAMETER Force
Forces reinstallation of the Hugging Face CLI.

.EXAMPLE
Invoke-HuggingFaceCli -Arguments @("login") -Timeout 600 -Force

Invokes the CLI with the "login" command, forcing reinstallation.

.EXAMPLE
Invoke-HuggingFaceCli @("whoami") 300

Invokes the CLI with the "whoami" command and a 300-second timeout.
#>
function Invoke-HuggingFaceCli {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The arguments to pass to the Hugging Face CLI"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $Arguments,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Timeout in seconds for CLI execution and dependency installation"
        )]
        [ValidateRange(60, 3600)]
        [int] $Timeout = 36000,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces reinstallation of the Hugging Face CLI"
        )]
        [switch] $Force
        #######################################################################
    )

    begin {
        # initialize variables
        $clipath = $null
        $clioutput = $null
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # show initial progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Hugging Face CLI Execution" `
            -Status "Ensuring CLI is installed..."
    }

    process {
        # ensure huggingface cli is installed
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Ensuring Hugging Face CLI is installed"

        $null = GenXdev.AI\EnsureHuggingFace `
            -Timeout $Timeout `
            -Force:$Force

        # read cli path from json
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Reading CLI path from JSON file"

        $jsonpath = GenXdev.FileSystem\Expand-Path `
            "$ENV:LOCALAPPDATA\GenXdev.PowerShell\hfclilocation.json"

        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $jsonpath)) {
            Microsoft.PowerShell.Utility\Write-Error `
                "CLI path JSON file not found at: ${jsonpath}"
            return
        }

        $clipath = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath $jsonpath `
            -Raw | Microsoft.PowerShell.Utility\ConvertFrom-Json

        # Handle both executable path and module command approach
        $isModuleCommand = $clipath -like "*python -m*"

        if (-not $isModuleCommand -and -not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $clipath)) {
            Microsoft.PowerShell.Utility\Write-Error `
                "Hugging Face CLI not found at: ${clipath}"
            return
        }

        # execute cli with arguments
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Hugging Face CLI Execution" `
            -Status "Executing CLI command..." `
            -PercentComplete 50

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Executing CLI at: ${clipath} with arguments: $($Arguments -join ' ')"

        try {
            if ($isModuleCommand) {
                # Execute via PowerShell with Python module command
                $allArgs = ($clipath.Split(' ') + $Arguments) -join ' '

                Microsoft.PowerShell.Utility\Write-Verbose "Executing: $allArgs"

                $clioutput = & cmd /c $allArgs 2>&1

                if ($LASTEXITCODE -ne 0) {
                    Microsoft.PowerShell.Utility\Write-Error `
                        "CLI execution failed with exit code ${LASTEXITCODE}: ${clioutput}"
                    return
                }
            }
            else {
                # Execute via Start-Process with executable
                $process = Microsoft.PowerShell.Management\Start-Process `
                    -FilePath $clipath `
                    -ArgumentList $Arguments `
                    -NoNewWindow `
                    -RedirectStandardOutput "$env:TEMP\hfcli_output.txt" `
                    -RedirectStandardError "$env:TEMP\hfcli_error.txt" `
                    -WindowStyle Hidden `
                    -PassThru `
                    -ErrorAction Stop

                $null = $process.WaitForExit($Timeout * 1000)

                if ($process.ExitCode -ne 0) {
                    $erroroutput = Microsoft.PowerShell.Management\Get-Content `
                        -LiteralPath "$env:TEMP\hfcli_error.txt" `
                        -ErrorAction SilentlyContinue
                    Microsoft.PowerShell.Utility\Write-Error `
                    ("CLI execution failed with exit code $($process.ExitCode): " + `
                            "${erroroutput}")
                    return
                }

                $clioutput = Microsoft.PowerShell.Management\Get-Content `
                    -LiteralPath "$env:TEMP\hfcli_output.txt" `
                    -Raw `
                    -ErrorAction SilentlyContinue
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to execute Hugging Face CLI: $($_.Exception.Message)"
            return
        }
        finally {
            # clean up temp files (only for Start-Process approach)
            if (-not $isModuleCommand) {
                $null = Microsoft.PowerShell.Management\Remove-Item `
                    -LiteralPath "$env:TEMP\hfcli_output.txt" `
                    -Force `
                    -ErrorAction SilentlyContinue

                $null = Microsoft.PowerShell.Management\Remove-Item `
                    -LiteralPath "$env:TEMP\hfcli_error.txt" `
                    -Force `
                    -ErrorAction SilentlyContinue
            }
        }

        # check timeout
        if ($stopwatch.Elapsed.TotalSeconds -gt $Timeout) {
            Microsoft.PowerShell.Utility\Write-Error `
                "CLI execution timed out after ${Timeout} seconds."
            return
        }

        # complete progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Hugging Face CLI Execution" `
            -Status "Execution completed" `
            -PercentComplete 100

        return $clioutput
    }

    end {
    }
}
###############################################################################