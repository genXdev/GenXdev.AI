###############################################################################
<#
.SYNOPSIS
Converts AI command suggestions to JSON format for processing.

.DESCRIPTION
This helper function takes a PowerShell command suggestion from an AI model
and converts it to a standardized JSON format that can be consumed by other
parts of the GenXdev AI system. The function validates the command and
ensures proper formatting before conversion.

.PARAMETER Command
The PowerShell command to process and convert to JSON format.

.EXAMPLE
Set-AICommandSuggestion -Command "Get-Process | Where-Object CPU -gt 100"

Returns a JSON object containing the command and success status.
#>
function Set-AICommandSuggestion {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The PowerShell command to process'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Command
        ###########################################################################
    )

    begin {

        # validate that shouldprocess is enabled for command processing
        Microsoft.PowerShell.Utility\Write-Verbose ('Processing AI command ' +
            'suggestion for JSON conversion')
    }

    process {

        # check if we should proceed with processing the command
        if ($PSCmdlet.ShouldProcess($Command, 'Process AI command suggestion')) {

            # convert the command suggestion to json format
            return @{
                command = $Command.Trim()
                success = $true
            } | Microsoft.PowerShell.Utility\ConvertTo-Json `
                -WarningAction SilentlyContinue
        }
    }

    end {
    }
}

###############################################################################
<#
.SYNOPSIS
Generates and executes PowerShell commands using AI assistance.

.DESCRIPTION
Uses LM-Studio or other AI models to generate PowerShell commands based on
natural language queries. The function can either send commands directly to
the PowerShell window or copy them to the clipboard. It leverages AI models
to interpret natural language and convert it into executable PowerShell
commands with comprehensive parameter support for various AI backends.

.PARAMETER Query
The natural language description of what you want to accomplish. The AI will
convert this into an appropriate PowerShell command.

.PARAMETER Instructions
Additional instructions for the AI model to customize command generation
behavior and provide context-specific guidance.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Values range from
0.0 (more focused/deterministic) to 1.0 (more creative/random).

.PARAMETER LLMQueryType
The type of LLM query to perform. Determines the AI model's behavior and
response style for different use cases.

.PARAMETER Model
The model identifier or pattern to use for AI operations. Can be a name or
partial path with support for pattern matching.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier for Hugging Face models.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations to control response
length and processing time.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations for performance
optimization.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If
'max', all layers are offloaded to GPU. If a number between 0 and 1, that
fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
how much to offload to the GPU. -2 = Auto

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations when using external AI services.

.PARAMETER ApiKey
The API key for authenticated AI operations with external services.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations to prevent hanging requests.

.PARAMETER PreferencesDatabasePath
Database path for preference data files to store AI configuration settings.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys to the PowerShell
window.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys to the PowerShell
window.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys to the PowerShell window.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys to
the PowerShell window.

.PARAMETER Clipboard
When specified, copies the generated command to clipboard instead of
executing it directly.

.PARAMETER ShowWindow
Show the LM Studio window during AI command generation for monitoring
purposes.

.PARAMETER Force
Force stop LM Studio before initialization to ensure clean startup state.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences instead of
persistent configuration.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences and reset
to defaults.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session
state.

.EXAMPLE
Invoke-AIPowershellCommand -Query "list all running processes" -Model "qwen"

Generates a PowerShell command to list running processes using the qwen model.

.EXAMPLE
hint "list files modified today"

Uses the alias to generate a command for finding files modified today.

.EXAMPLE
Invoke-AIPowershellCommand -Query "stop service" -Clipboard

Generates a command to stop a service and copies it to clipboard.
#>
function Invoke-AIPowershellCommand {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    [Alias('hint')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The natural language query to generate a command for'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use ' +
                'as tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of command names that don't require " +
                'confirmation')
        )]
        [Alias('NoConfirmationFor')]
        [string[]]
        $NoConfirmationToolFunctionNames = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The type of LLM query'
        )]
        [ValidateSet(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )]
        [string] $LLMQueryType = 'SimpleIntelligence',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
        )]
        [string] $Model,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The number of CPU cores to dedicate to AI ' +
                'operations')
        )]
        [int] $Cpu,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                'offloaded to GPU. If a number between 0 and 1, ' +
                'that fraction of layers will be offloaded to the ' +
                'GPU. -1 = LM Studio will decide how much to ' +
                'offload to the GPU. -2 = Auto')
        )]
        [ValidateRange(-2, 1)]
        [int]$Gpu,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Copy the enhanced text to clipboard'
        )]
        [switch]$SetClipboard,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the LM Studio window'
        )]
        [switch] $ShowWindow,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch]$Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $DontAddThoughtsToHistory,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow the use of default AI tools during processing'
        )]
        [switch] $AllowDefaultTools,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $ClearSession,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum number of tokens to generate (passed to LLMQuery)'
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Time-to-live in seconds for the request (passed to LLMQuery)'
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Alias('m','mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Monitor index or name for window display (passed to LLMQuery)'
        )]
        [string] $Monitor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Width of the window or image (passed to LLMQuery)'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Height of the window or image (passed to LLMQuery)'
        )]
        [int] $Height,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio response randomness (passed to LLMQuery)'
        )]
        [double] $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation (passed to LLMQuery)'
        )]
        [double] $TemperatureResponse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language code or name for processing (passed to LLMQuery)'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use (passed to LLMQuery)'
        )]
        [int] $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress output (passed to LLMQuery)'
        )]
        [string] $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing (passed to LLMQuery)'
        )]
        [int] $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio detection (passed to LLMQuery)'
        )]
        [double] $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation (passed to LLMQuery)'
        )]
        [double] $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering (passed to LLMQuery)'
        )]
        [double] $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering (passed to LLMQuery)'
        )]
        [double] $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection (passed to LLMQuery)'
        )]
        [double] $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output (passed to LLMQuery)'
        )]
        [switch] $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output for thoughts (passed to LLMQuery)'
        )]
        [switch] $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation) (passed to LLMQuery)'
        )]
        [switch] $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture (passed to LLMQuery)'
        )]
        [switch] $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable context usage (passed to LLMQuery)'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable beam search sampling strategy (passed to LLMQuery)'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses (passed to LLMQuery)'
        )]
        [switch] $OnlyResponses,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys (passed to LLMQuery)'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Output only markup blocks (passed to LLMQuery)'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for markup block types (passed to LLMQuery)'
        )]
        [string[]] $MarkupBlocksTypeFilter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not initialize LM Studio (passed to LLMQuery)'
        )]
        [switch] $NoLMStudioInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unload model or resources after operation (passed to LLMQuery)'
        )]
        [switch] $Unload,
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not show window borders (passed to LLMQuery)'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: left (passed to LLMQuery)'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: right (passed to LLMQuery)'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: bottom (passed to LLMQuery)'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window (passed to LLMQuery)'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show window in fullscreen mode (passed to LLMQuery)'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Alias('rf','bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to previous window (passed to LLMQuery)'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show side-by-side view (passed to LLMQuery)'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw','focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after showing (passed to LLMQuery)'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window to foreground (passed to LLMQuery)'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window (passed to LLMQuery)'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key after operation (passed to LLMQuery)'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys (passed to LLMQuery)'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys (passed to LLMQuery)'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum tool callback length (passed to LLMQuery)'
        )]
        [int] $MaxToolcallBackLength
        ###########################################################################
    )

    begin {

        # initialize verbose logging for ai command generation
        Microsoft.PowerShell.Utility\Write-Verbose ('Initializing AI command ' +
            'generation')

        # build comprehensive instruction template for the ai model
        $commandInstructions = @"
You are a PowerShell expert.
Although you only have access to a limited set of tool functions to execute
in your suggested powershell commandline script, you are not limited
and have access to everything Powershell has to offer.
Analyze the user's request and suggest a PowerShell command that accomplishes
their goal.
First try basic powershell commands, if that does not solve it then try to use
the Get-GenXDevCmdlet, Get-Help and the Get-Command cmdlets to find the right
commands to use.
Return only the suggested command without any explanation or commentary.
$Instructions
"@
    }

    process {

        # log the query being processed for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose ('Generating PowerShell ' +
            "command for query: $Query")

        # copy matching parameters to invoke transformation function
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Invoke-LLMTextTransformation'

        # set the text parameter to the user's query
        $invocationParams.Text = $Query

        # apply the instruction template to guide ai behavior
        $invocationParams.Instructions = $commandInstructions

        # configure clipboard setting for output handling
        $invocationParams.SetClipboard = $Clipboard

        # get the command from the ai using configured parameters
        $command = GenXdev.AI\Invoke-LLMTextTransformation @invocationParams

        # handle clipboard output mode
        if ($Clipboard) {

            # log successful clipboard operation
            Microsoft.PowerShell.Utility\Write-Verbose ('Command copied to ' +
                'clipboard')
        }
        else {

            # handle direct execution mode with powershell window
            if ($PSCmdlet.ShouldProcess('PowerShell window', 'Send command')) {

                # get the main powershell window for command injection
                $mainWindow = GenXdev.Windows\Get-PowershellMainWindow

                # bring the powershell window to foreground if found
                if ($null -ne $mainWindow) {

                    $null = $mainWindow.SetForeground()
                }

                # preserve current clipboard contents
                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard

                try {

                    # prepare command for clipboard injection with newline handling
                    ($command.Trim().Replace("`n", " ```n")) |
                        Microsoft.PowerShell.Management\Set-Clipboard

                    # copy identical parameters between functions
                    $sendKeyParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev.Windows\Send-Key'

                    # send paste keyboard shortcut to active window
                    GenXdev.Windows\Send-Key -KeysToSend '^v' @sendKeyParams

                    # wait for paste operation to complete
                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {

                    # restore original clipboard contents
                    $oldClipboard |
                        Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }
    }

    end {
    }
}
###############################################################################