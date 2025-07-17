################################################################################
<#
.SYNOPSIS
Converts direct or blunt text into polite, professional corporate speak using AI.

.DESCRIPTION
This function processes input text to transform direct or potentially harsh
language into diplomatic, professional corporate communications. It can accept
input directly through parameters, from the pipeline, or from the system
clipboard. The function leverages AI models to analyze and rephrase text while
preserving the original intent.

.PARAMETER Text
The input text to convert to corporate speak. If not provided, the function will
read from the system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Additional instructions to guide the AI model in converting the text.
These can help fine-tune the tone and style of the corporate language.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SetClipboard
When specified, copies the transformed text back to the system clipboard.

.PARAMETER ShowWindow
Shows the LM Studio window during processing.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
ConvertTo-CorporateSpeak -Text "That's a terrible idea" -Model "qwen" -SetClipboard

.EXAMPLE
"This makes no sense" | corporatize
#>
################################################################################
function ConvertTo-CorporateSpeak {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias('corporatize')]

    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'The text to convert to corporate speak'
        )]
        [ValidateNotNull()]
        [string]$Text,
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
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
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

        # output verbose message about starting the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Starting corporate speak conversion'
        )
    }

    process {

        # setup corporate language transformation instructions
        $corporateInstructions = @"
Translate users input from the a brutal or direct phrase into polite,
professional corporate speak while preserving the original intent. The
translation should sound diplomatic and suitable for a corporate environment,
even if the original phrase is blunt or harsh.

Examples:

Original: 'That makes no sense.'
Translation: 'Can you please elaborate on your thinking here?'

Original: 'I've told you this 5,000 times.'
Translation: 'I have provided this information previously.'

Original: 'Stop micromanaging me.'
Translation: 'I feel that I am at my most productive when I have more autonomy.'

$Instructions
"@

        # output verbose message about the transformation process
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Processing text transformation'
        )

        # invoke the language model with corporate instructions
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
            -Instructions $corporateInstructions
    }

    end {

        # output verbose message about completion of the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Completed corporate speak conversion'
        )
    }
}
################################################################################