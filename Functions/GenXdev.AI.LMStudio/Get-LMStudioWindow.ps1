################################################################################
<#
.SYNOPSIS
Gets a window helper for the LM Studio application.

.DESCRIPTION
Gets a window helper for the LM Studio application. If LM Studio is not running,
it will be started automatically unless prevented by NoAutoStart switch.
The function handles process management and window positioning.

.PARAMETER ShowWindow
Switch to show LM Studio window during initialization.

.PARAMETER Force
Switch to force stop LM Studio before initialization.

.PARAMETER NoAutoStart
Switch to prevent automatic start of LM Studio if not running.

.PARAMETER Unload
Switch to unload the specified model instead of loading it.

.PARAMETER LLMQueryType
The type of LLM query to use for AI operations.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER TTLSeconds
The time-to-live in seconds for cached AI responses.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER SessionOnly
Switch to use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Switch to clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Switch to store settings only in persistent preferences without affecting
session.

.EXAMPLE
Get-LMStudioWindow -Model "llama-2" -MaxToken 4096 -ShowWindow

.EXAMPLE
Get-LMStudioWindow "qwen2.5-14b-instruct" -TTLSeconds 3600
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
            HelpMessage = "The type of LLM query"
        )]
        [ValidateSet(
            "SimpleIntelligence",
            "Knowledge",
            "Pictures",
            "TextTranslation",
            "Coding",
            "ToolUse"
        )]
        [string] $LLMQueryType = "SimpleIntelligence",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The time-to-live in seconds for cached AI responses"
        )]
        [int] $TTLSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Unloads the specified model instead of loading it"
        )]
        [switch]$Unload,
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
        [switch]$NoAutoStart,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # output verbose message about attempting to locate or start lm studio
        Microsoft.PowerShell.Utility\Write-Verbose ("Attempting to locate or start " +
            "LM Studio window")

        # get required paths for LM Studio operation
        $paths = GenXdev.AI\Get-LMStudioPaths

        # handle force restart if requested and auto-start is enabled
        if ($Force -and (-not $NoAutoStart)) {

            # copy identical parameter values for the EnsureLMStudio function call
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\EnsureLMStudio" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # ensure lm studio is running with the specified parameters
            $null = GenXdev.AI\EnsureLMStudio @invocationArguments
        }

        # attempt to find existing LM Studio window with main window handle
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

            # check if any lm studio processes are running
            if ($others.Count -gt 0) {

                # try to initialize window via background job
                $null = Microsoft.PowerShell.Core\Start-Job -ScriptBlock {

                    param($paths)

                    # start primary instance
                    $null = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle "Normal"

                    # wait for primary instance to initialize
                    Microsoft.PowerShell.Utility\Start-Sleep 3

                    # start secondary instance
                    $null = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle "Normal"

                } -ArgumentList $paths |
                Microsoft.PowerShell.Core\Wait-Job

                # wait for instances to stabilize
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 3

                # locate process with main window handle
                $process = Microsoft.PowerShell.Management\Get-Process "LM Studio" |
                Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
                Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }

        # initialize process if not found
        if ($null -eq $process) {
            CheckRunningInstances
        }

        # handle auto-start scenario when no process is found
        if ($null -eq $process) {

            # check if auto-start is disabled
            if ($NoAutoStart) {
                Microsoft.PowerShell.Utility\Write-Error "No running LM Studio found"
                return
            }

            # output verbose message about initializing new instance
            Microsoft.PowerShell.Utility\Write-Verbose "Initializing new LM Studio instance"

            # copy identical parameter values for the EnsureLMStudio function call
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\EnsureLMStudio" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # ensure lm studio is running with the specified parameters
            $null = GenXdev.AI\EnsureLMStudio @invocationArguments

            # attempt to find the newly started process with main window handle
            $process = Microsoft.PowerShell.Management\Get-Process "LM Studio" |
            Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
            Microsoft.PowerShell.Utility\Select-Object -First 1
        }

        # final attempt to initialize if still no process found
        if ($null -eq $process) {
            CheckRunningInstances
        }

        # handle successful process initialization
        if ($process) {

            # output verbose message about found process
            Microsoft.PowerShell.Utility\Write-Verbose ("Found LM Studio process " +
                "(PID: $($process.Id))")

            # get window helper for the found process
            $result = GenXdev.Windows\Get-Window -ProcessId ($process.Id)

            # handle window positioning and display if requested
            if ($ShowWindow -and $null -ne $result) {

                # set window positions and focus on monitor 0
                $null = GenXdev.Windows\Set-WindowPosition -Left -Monitor 0

                $null = GenXdev.Windows\Set-WindowPosition `
                    -WindowHelper $result -Right -Monitor 0

                # setup window state for display
                $null = $result.Show()

                $null = $result.Restore()

                $null = $result.SetForeground()

                # send required keystroke to switch to second tab
                $null = GenXdev.Windows\Send-Key "^2" -WindowHandle ($result.handle)

                # wait for tab switch to complete
                Microsoft.PowerShell.Utility\Start-Sleep 1

                # restore powershell window focus
                $null = (GenXdev.Windows\Get-PowershellMainWindow).SetForeground()
            }

            # return the window helper object
            Microsoft.PowerShell.Utility\Write-Output $result
            return
        }

        # output error if initialization failed
        Microsoft.PowerShell.Utility\Write-Error "Failed to initialize LM Studio"
    }

    end {
    }
}
################################################################################