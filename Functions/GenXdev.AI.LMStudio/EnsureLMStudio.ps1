################################################################################
<#
.SYNOPSIS
Ensures LM Studio is properly initialized with the specified model.

.DESCRIPTION
Initializes or reinitializes LM Studio with a specified model. This function
handles process management, configuration settings, and ensures the proper model
is loaded. It can force a restart if needed and manages window visibility.

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

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER ShowWindow
Show LM Studio window during initialization.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER Unload
Unloads the specified model instead of loading it.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
EnsureLMStudio -LMSQueryType "TextTranslate" -MaxToken 8192 -ShowWindow

.EXAMPLE
EnsureLMStudio -Model "mistral-7b" -TTLSeconds 3600 -Force
#>
function EnsureLMStudio {

    [CmdletBinding()]
    param (
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The time-to-live in seconds for cached AI responses"
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
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
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show LM Studio window during initialization"
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Unloads the specified model instead of loading it"
        )]
        [switch] $Unload,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        # output verbose startup message with model information
        Microsoft.PowerShell.Utility\Write-Verbose ("Starting EnsureLMStudio " +
            "with Model: $Model")

        # ensure default model parameter is set if not provided
        if (-not $PSBoundParameters.ContainsKey("Model")) {

            $null = $PSBoundParameters.Add("Model", "qwen2.5-14b-instruct")
        }

        # ensure default model identifier is set if not provided
        if (-not $PSBoundParameters.ContainsKey("HuggingFaceIdentifier")) {

            $null = $PSBoundParameters.Add("HuggingFaceIdentifier",
                "qwen2.5-14b-instruct")
        }

        # ensure default max token value is set if not provided
        if (-not $PSBoundParameters.ContainsKey("MaxToken")) {

            $null = $PSBoundParameters.Add("MaxToken", 8192)
        }
    }

    process {

        # prepare parameters for model initialization by copying identical values
        $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Initialize-LMStudioModel" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -Name * -ErrorAction SilentlyContinue)

        # output verbose message before initializing the model
        Microsoft.PowerShell.Utility\Write-Verbose ("Initializing LM Studio " +
            "model with parameters")

        # initialize the model with the prepared parameter arguments
        $null = GenXdev.AI\Initialize-LMStudioModel @invocationArguments
    }

    end {

        # show window if requested by the user
        if ($ShowWindow) {

            try {

                # get the lm studio window handle by process name
                $windowHandle = (GenXDev.Windows\Get-Window `
                    -ProcessName "LM Studio")

                # exit if no window was found
                if ($null -eq $windowHandle) { return }

                # show the window if it was hidden
                $null = $windowHandle.Show()

                # restore the window if it was minimized
                $null = $windowHandle.Restore()

                # position the window on the right side of the primary monitor
                GenXDev.Windows\Set-WindowPosition -WindowHelper $windowHandle `
                    -Monitor 0 -Right

                # position another window on the left side of the primary monitor
                GenXDev.Windows\Set-WindowPosition -Left -Monitor 0 -Left
            }
            catch {

                # silently ignore any window positioning errors
            }
        }
    }
}
################################################################################