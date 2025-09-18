<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : ConvertFrom-CorporateSpeak.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.276.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Converts polite, professional corporate speak into direct, clear language using AI.

.DESCRIPTION
This function processes input text to transform diplomatic, corporate
communications into more direct and clear language. It can accept input directly
through parameters, from the pipeline, or from the system clipboard. The function
leverages AI models to analyze and rephrase text while preserving the original
intent.

.PARAMETER Text
The corporate speak text to convert to direct language. If not provided, the
function will read from the system clipboard. Multiple lines of text are
supported.

.PARAMETER Instructions
Additional instructions to guide the AI model in converting the text.
These can help fine-tune the tone and style of the direct language.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER SetClipboard
When specified, copies the transformed text back to the system clipboard.

.PARAMETER ShowWindow
Shows the LM Studio window during processing.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER LLMQueryType
The type of LLM query to use for processing the text transformation.

.PARAMETER Model
Specifies which AI model to use for text transformation. Different models may
produce varying results in terms of language style.

.PARAMETER HuggingFaceIdentifier
Identifier used for getting specific model from LM Studio.

.PARAMETER MaxToken
Maximum tokens in response (-1 for default).

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. -2=Auto, -1=LMStudio decides, 0=Off, 0-1=Layer
fraction.

.PARAMETER ApiEndpoint
Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
The API key to use for the request.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
ConvertFrom-CorporateSpeak -Text "I would greatly appreciate your timely response" -SetClipboard

.EXAMPLE
"We should circle back" | uncorporatize
###############################################################################
#>
function ConvertFrom-CorporateSpeak {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias('uncorporatize')]

        param (
            ###########################################################################
            [Parameter(
                Position = 0,
                Mandatory = $false,
                ValueFromPipeline = $true,
                HelpMessage = 'The text to convert from corporate speak'
            )]
            [string] $Text,
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
                HelpMessage = ('Array of PowerShell command definitions to use as tools')
            )]
            [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @(),
            ###########################################################################
            [Parameter(
                Mandatory = $false,
                HelpMessage = ("Array of command names that don't require confirmation")
            )]
            [Alias('NoConfirmationFor')]
            [string[]] $NoConfirmationToolFunctionNames = @(),
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
                HelpMessage = ('The model identifier or pattern to use for AI operations')
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
                HelpMessage = ('The number of CPU cores to dedicate to AI operations')
            )]
            [int] $Cpu,
            ###########################################################################
            [Parameter(
                Mandatory = $false,
                HelpMessage = ("How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max', all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto")
            )]
            [ValidateRange(-2, 1)]
            [int] $Gpu,
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
            [switch] $SetClipboard,
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
            [switch] $Force,
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
                HelpMessage = ('Use alternative settings stored in session for AI preferences')
            )]
            [switch] $SessionOnly,
            ###########################################################################
            [Parameter(
                Mandatory = $false,
                HelpMessage = ('Clear alternative settings stored in session for AI preferences')
            )]
            [switch] $ClearSession,
            ###########################################################################
            [Parameter(
                Mandatory = $false,
                HelpMessage = ('Store settings only in persistent preferences without affecting session')
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
            [int] $Monitor,
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

            # output verbose message for start
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Starting corporate speak conversion with model: $Model"
            )
        }

        process {

            # construct instructions for corporate speak transformation
            $corporateInstructions = @"
    Translate the users input from corporate jargon phrase into simple, everyday
    language that anyone can understand. The translation should reveal the true and
    real meaning of the phrase, making it clear and straightforward, even if the
    corporate speak is used to soften or obscure the actual intent.

    Examples:

    Corporate: 'Let's touch base.'
    Layman: 'Let's talk or meet.'

    Corporate: 'Think outside the box.'
    Layman: 'Be creative or innovative.'

    Corporate: 'We're optimizing our workforce.'
    Layman: 'We're laying off employees.'

    Corporate: 'Optimizing our workforce'
    Layman: 'Laying off employees.'

    Corporate: 'Rightsizing'
    Layman: 'Laying off employees.'

    Corporate: 'Performance improvement plan'
    Layman: 'Employee is at risk of being fired.'

    Corporate: 'Streamlining operations'
    'Can involve layoffs or unfavorable role changes.'

    Corporate: 'Attrition'
    Layman: 'Not replacing departing employees to reduce headcount.'

    Corporate: 'Workforce reduction'
    'Layoffs.'

    Corporate: 'Downsizing'
    Layman: 'Reducing employee numbers.'

    Corporate: 'Cost-saving measures'
    'Can include layoffs.'

    Corporate: 'Restructuring'
    Layman: 'Often includes layoffs.'

    Corporate: 'Trim the fat'
    'Reducing costs, often by cutting jobs or projects.'

    Corporate: 'Buy-in'
    Layman: 'Ensuring support to avoid wasted effort; implies potential resistance.'

    $Instructions
"@

            # output verbose message for transformation
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Transforming text with corporate speak instructions'
            )

            # invoke the language model with corporate speak instructions
            GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
                -Instructions $corporateInstructions
        }

        end {

            # output verbose message for completion
            Microsoft.PowerShell.Utility\Write-Verbose 'Completed corporate speak conversion'
        }
    }
    ###############################################################################