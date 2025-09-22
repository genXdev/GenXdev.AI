<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Invoke-LLMTextTransformation.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
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
Transforms text using AI-powered processing.

.DESCRIPTION
This function processes input text using AI models to perform various
transformations such as spell checking, adding emoticons, or any other text
enhancement specified through instructions. It can accept input directly
through parameters, from the pipeline, or from the system clipboard.

.PARAMETER Text
The input text to transform. If not provided, the function will read from the
system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Instructions to guide the AI model in transforming the text. By default, it
will perform spell checking and grammar correction.

.PARAMETER Attachments
Array of file paths to attach to the AI processing request.

.PARAMETER SetClipboard
When specified, copies the transformed text back to the system clipboard after
processing is complete.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER Temperature
Temperature for response randomness, ranging from 0.0 to 1.0.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER ImageDetail
Image detail level for image processing operations.

.PARAMETER DontAddThoughtsToHistory
Include model's thoughts in output history.

.PARAMETER ContinueLast
Continue from last conversation in the AI session.

.PARAMETER Functions
Array of function definitions for AI tool usage.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER AllowDefaultTools
Allow the use of default AI tools during processing.

.PARAMETER LLMQueryType
The type of LLM query to perform.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU for AI processing.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

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
Invoke-LLMTextTransformation -Text "Hello, hwo are you todey?" `
    -Instructions "Fix spelling errors" -SetClipboard

.EXAMPLE
"Time to celerbate!" | Invoke-LLMTextTransformation `
    -Instructions "Add celebratory emoticons"

.EXAMPLE
spellcheck "This is a sentance with erors"
#>
function Invoke-LLMTextTransformation {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias('spellcheck')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'The text to transform'
        )]
        [string]$Text,
        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Instructions for the AI model on how to transform ' +
                'the text')
        )]
        [string]$Instructions = ('Check and correct any spelling or grammar ' +
            'errors in the text. Return the corrected text without any ' +
            'additional comments or explanations.'),
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

        # create string builder for efficient text accumulation
        $resultBuilder = [System.Text.StringBuilder]::new()

        # define response format schema for structured AI output
        $responseSchema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'text_transformation_response'
                strict = $true
                schema = @{
                    type       = 'object'
                    properties = @{
                        response = @{
                            type        = 'string'
                            description = 'The transformed text output'
                        }
                    }
                    required   = @('response')
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # log the start of transformation process with model information
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting text transformation with model: $Model"
    }


    process {

        # check if we should read from clipboard when no text is provided
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            # log that we are reading from clipboard
            Microsoft.PowerShell.Utility\Write-Verbose `
                'No direct text input, reading from clipboard'

            # read text content from system clipboard
            $Text = Microsoft.PowerShell.Management\Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {

                # warn user when clipboard is empty
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'No text found in the clipboard.'
                return
            }
        }

        try {

            # log start of text processing
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Processing text block for transformation'

            # copy matching parameters to invoke ai query function
            $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Invoke-LLMQuery'

            # set required parameters for ai query invocation
            $invocationParams.Query = $Text

            $invocationParams.Instructions = $Instructions

            $invocationParams.IncludeThoughts = $false

            $invocationParams.ResponseFormat = $responseSchema

            $invocationParams.Temperature = $Temperature

            if ($AllowDefaultTools) {

                # configure chat mode for tool usage
                $invocationParams.ChatMode = 'textprompt'

                $invocationParams.ChatOnce = $true
            }

            # invoke ai query and extract response from json
            $enhancedText = (GenXdev.AI\Invoke-LLMQuery @invocationParams |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json).response

            # append enhanced text to result builder with line break
            $null = $resultBuilder.Append("$enhancedText`r`n")
        }
        catch {

            # log error when ai processing fails
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to process text with AI model: $_"
        }
    }

    end {

        # get final combined result from string builder
        $finalResult = $resultBuilder.ToString()

        if ($SetClipboard) {

            # log clipboard operation
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Copying enhanced text to clipboard'

            # copy transformed text to system clipboard
            Microsoft.PowerShell.Management\Set-Clipboard -Value $finalResult
        }

        # return enhanced text to pipeline
        $finalResult
    }
}
###############################################################################