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
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Model = "qwen*-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [string]$ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int]$MaxToken = 32768,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API"
        )]
        [Alias("ttl")]
        [int]$TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show LM Studio window during initialization"
        )]
        [switch]$ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "No auto start LM Studio if not running"
        )]
        [switch]$NoAutoStart
    )

    begin {

        Write-Verbose "Starting to look for LM Studio window"

        if ($Force -and (-not $NoAutoStart)) {

            $null = AssureLMStudio @PSBoundParameters
        }

        $process = Get-Process "LM Studio" |
        Where-Object { $_.MainWindowHandle -ne 0 } |
        Select-Object -First 1
    }

    process {

        function checkOthers {

            $others = @(Get-Process "LM Studio" -ErrorAction SilentlyContinue)

            if ($others.Count -gt 0) {

                $null = Start-Job -ScriptBlock {

                    param($paths)

                    $null = Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle "Normal"

                    Start-Sleep 3

                    $null = Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle "Normal"

                } -ArgumentList $paths | Wait-Job

                Start-Sleep -Seconds 3

                $process = Get-Process "LM Studio" |
                Where-Object { $_.MainWindowHandle -ne 0 } |
                Select-Object -First 1
            }
        }

        # try to find running LM Studio process with a main window
        if ($null -eq $process) {

            checkOthers
        }

        if ($null -eq $process) {

            if ($NoAutoStart) {

                Write-Error "No running LM Studio found"
                return;
            }

            Write-Verbose "No running LM Studio found, starting new instance"
            # start LM Studio and try again
            $null = AssureLMStudio @PSBoundParameters

            $process = Get-Process "LM Studio" |
            Where-Object { $_.MainWindowHandle -ne 0 } |
            Select-Object -First 1
        }

        if ($null -eq $process) {

            checkOthers
        }

        if ($process) {

            Write-Verbose "Found running LM Studio process with ID: $($process.Id)"

            # return a window helper for the found process
            $result = Get-Window -ProcessId ($process.Id)

            if ($ShowWindow -and $null -ne $result) {

                $null = Set-WindowPosition -Left -Monitor 0
                Get-Process "LM Studio" -ErrorAction SilentlyContinue | Where-Object -Property MainWindowHandle -NE 0 | ForEach-Object {

                    $null = Set-WindowPosition -Process $PSItem -Right -Monitor 0
                }
                $result.SetForeground();
                Send-Keys "^2";
                (Get-PowershellMainWindow).SetForeground();
            }

            Write-Output $result
            return;
        }

        Write-Error "Failed to start LM Studio"
    }

    end {

    }
}
################################################################################
