################################################################################
<#
.SYNOPSIS
Gets a window helper for the LM Studio application.

.DESCRIPTION
Gets a window helper for the LM Studio application. If LM Studio is not running,
it will be started automatically unless prevented by NoAutoStart switch.
The function handles process management and window positioning.

.PARAMETER Model
Name or partial path of the model to initialize.

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier to use.

.PARAMETER MaxToken
Maximum tokens in response. Use -1 for default value.

.PARAMETER TTLSeconds
Set a Time To Live (in seconds) for models loaded via API.

.PARAMETER ShowWindow
Switch to show LM Studio window during initialization.

.PARAMETER Force
Switch to force stop LM Studio before initialization.

.PARAMETER NoAutoStart
Switch to prevent automatic start of LM Studio if not running.

.EXAMPLE
Get-LMStudioWindow -Model "llama-2" -MaxToken 4096 -ShowWindow

.EXAMPLE
Get-LMStudioWindow "qwen2.5-14b-instruct" -ttl 3600
#>
function Get-LMStudioWindow {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseUsingScopeModifierInNewRunspaces", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        "PSUseDeclaredVarsMoreThanAssignments", "")]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]$Model = "qwen2.5-14b-instruct",
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
        [int]$MaxToken = 8192,
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
        ########################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose ("Attempting to locate or start " +
            "LM Studio window")

        # get required paths for LM Studio operation
        $paths = GenXdev.AI\Get-LMStudioPaths

        # handle force restart if requested and auto-start is enabled
        if ($Force -and (-not $NoAutoStart)) {

            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\AssureLMStudio" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            $null = GenXdev.AI\AssureLMStudio @invocationArguments
        }

        # attempt to find existing LM Studio window
        $process = Microsoft.PowerShell.Management\Get-Process "LM Studio" `
            -ErrorAction SilentlyContinue |
        Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
        Microsoft.PowerShell.Utility\Select-Object -First 1
    }

    process {

        # define helper function to check for running instances
        function CheckRunningInstances {

            # get all running LM Studio processes
            $others = @(Microsoft.PowerShell.Management\Get-Process "LM Studio" `
                    -ErrorAction SilentlyContinue)

            if ($others.Count -gt 0) {

                # try to initialize window via background job
                $null = Microsoft.PowerShell.Core\Start-Job -ScriptBlock {

                    param($paths)

                    # start primary instance
                    $null = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle "Normal"

                    Microsoft.PowerShell.Utility\Start-Sleep 3

                    # start secondary instance
                    $null = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle "Normal"

                } -ArgumentList $paths | Microsoft.PowerShell.Core\Wait-Job

                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 3

                # locate process with main window
                $process = Microsoft.PowerShell.Management\Get-Process "LM Studio" |
                Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
                Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }

        # initialize process if not found
        if ($null -eq $process) {
            CheckRunningInstances
        }

        # handle auto-start scenario
        if ($null -eq $process) {

            if ($NoAutoStart) {
                Microsoft.PowerShell.Utility\Write-Error "No running LM Studio found"
                return
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Initializing new LM Studio instance"

            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\AssureLMStudio" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            $null = GenXdev.AI\AssureLMStudio @invocationArguments

            $process = Microsoft.PowerShell.Management\Get-Process "LM Studio" |
            Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
            Microsoft.PowerShell.Utility\Select-Object -First 1
        }

        # final attempt to initialize
        if ($null -eq $process) {
            CheckRunningInstances
        }

        # handle successful process initialization
        if ($process) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Found LM Studio process " +
                "(PID: $($process.Id))")

            $result = GenXdev.Windows\Get-Window -ProcessId ($process.Id)

            if ($ShowWindow -and $null -ne $result) {

                # set window positions and focus
                $null = GenXdev.Windows\Set-WindowPosition -Left -Monitor 0
                $null = GenXdev.Windows\Set-WindowPosition `
                    -WindowHelper $result -Right -Monitor 0

                # setup window state
                $null = $result.Show()
                $null = $result.Restore()
                $null = $result.SetForeground()

                # send required keystrokes
                $null = GenXdev.Windows\Send-Key "^2" -WindowHandle ($result.handle)

                Microsoft.PowerShell.Utility\Start-Sleep 1

                # restore powershell window focus
                $null = (GenXdev.Windows\Get-PowershellMainWindow).SetForeground()
            }

            Microsoft.PowerShell.Utility\Write-Output $result
            return
        }

        Microsoft.PowerShell.Utility\Write-Error "Failed to initialize LM Studio"
    }

    end {
    }
}
################################################################################