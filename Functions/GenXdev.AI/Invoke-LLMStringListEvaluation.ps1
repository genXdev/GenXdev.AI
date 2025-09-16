<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Invoke-LLMStringListEvaluation.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.264.2025
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
Extracts or generates a list of relevant strings from input text using AI
analysis.

.DESCRIPTION
This function uses AI models to analyze input text and extract or generate a
list of relevant strings. It can process text to identify key points, extract
items from lists, or generate related concepts. Input can be provided directly
through parameters, from the pipeline, or from the system clipboard. The
function returns a string array and optionally copies results to clipboard.

.PARAMETER Text
The text to analyze and extract strings from. If not provided, the function
will read from the system clipboard.

.PARAMETER Instructions
Optional instructions to guide the AI model in generating the string list. By
default, it will extract key points, items, or relevant concepts from the
input text.

.PARAMETER Attachments
Array of file paths to attach to the AI query. These files will be included
in the context for analysis.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0). Lower values produce more
deterministic responses, higher values increase creativity.

.PARAMETER ImageDetail
Image detail level for image processing. Valid values are "low", "medium",
or "high".

.PARAMETER Functions
Array of function definitions that can be called by the AI model during
processing.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools that the AI can
invoke.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation before execution.

.PARAMETER LLMQueryType
The type of LLM query to perform. Valid values are "SimpleIntelligence",
"Knowledge", "Pictures", "TextTranslation", "Coding", or "ToolUse".

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If
'max', all layers are offloaded to GPU. If a number between 0 and 1, that
fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
how much to offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SetClipboard
When specified, copies the resulting string list back to the system clipboard
after processing.

.PARAMETER ShowWindow
Show the LM Studio window.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER IncludeThoughts
Include model's thoughts in output.

.PARAMETER DontAddThoughtsToHistory
Don't add model's thoughts to conversation history.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER AllowDefaultTools
Enable default tools for the AI model.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
PS> Invoke-LLMStringListEvaluation -Text ("PowerShell features: object-based " +
    "pipeline, integrated scripting environment, backwards compatibility, " +
    "and enterprise management.")
Returns: @("Object-based pipeline", "Integrated scripting environment",
         "Backwards compatibility", "Enterprise management")

.EXAMPLE
PS> "Make a shopping list with: keyboard, mouse, monitor, headset" |
    Invoke-LLMStringListEvaluation
Returns: @("Keyboard", "Mouse", "Monitor", "Headset")

.EXAMPLE
PS> getlist "List common PowerShell commands for file operations" -SetClipboard
Returns and copies to clipboard: @("Get-ChildItem", "Copy-Item", "Move-Item",
                                  "Remove-Item", "Set-Content", "Get-Content")
###############################################################################>
function Invoke-LLMStringListEvaluation {

    [CmdletBinding()]
    [OutputType([string[]])]
    [Alias('getlist')]
    [Alias('getstring')]

    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'The text to analyze and extract strings from'
        )]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Instructions for the AI model on how to generate ' +
                'the string list')
        )]
        [string] $Instructions = '',
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use ' +
                'as tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of command names that don't require " +
                'confirmation')
        )]
        [Alias('NoConfirmationFor')]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ###############################################################################
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
        [string] $LLMQueryType = 'Knowledge',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        ###############################################################################
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
        [int] $Gpu = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Copy the result to clipboard'
        )]
        [switch] $SetClipboard,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the LM Studio window'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't add model's thoughts to conversation history"
        )]
        [switch] $DontAddThoughtsToHistory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable default tools for the AI model'
        )]
        [switch] $AllowDefaultTools,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The time-to-live in seconds for the AI operation.'
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Alias('m','mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor index or identifier for display output.'
        )]
        [int] $Monitor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The width for display or image output.'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The height for display or image output.'
        )]
        [int] $Height,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys.'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only markup blocks in the output.'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for specific types of markup blocks.'
        )]
        [string[]] $MarkupBlocksTypeFilter,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Temperature for audio response randomness.'
        )]
        [double] $AudioTemperature,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Temperature for text response randomness.'
        )]
        [double] $TemperatureResponse,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Language code or identifier for the response.'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Number of CPU threads to use.'
        )]
        [int] $CpuThreads,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Regular expression to suppress certain outputs.'
        )]
        [string] $SuppressRegex,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Audio context size for processing.'
        )]
        [int] $AudioContextSize,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Silence threshold for audio detection.'
        )]
        [double] $SilenceThreshold,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Length penalty for sequence generation.'
        )]
        [double] $LengthPenalty,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Entropy threshold for output filtering.'
        )]
        [double] $EntropyThreshold,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Log probability threshold for output filtering.'
        )]
        [double] $LogProbThreshold,
        ###############################################################################
        [Parameter(
            HelpMessage = 'No speech threshold for audio detection.'
        )]
        [double] $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Disable speech output.'
        )]
        [switch] $DontSpeak,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Disable speech output for thoughts.'
        )]
        [switch] $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Disable VOX (voice activation).'
        )]
        [switch] $NoVOX,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Use desktop audio capture.'
        )]
        [switch] $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Disable context usage.'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Use beam search sampling strategy.'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Return only responses.'
        )]
        [switch] $OnlyResponses,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not initialize LM Studio.'
        )]
        [switch] $NoLMStudioInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unload the model or session after completion.'
        )]
        [switch] $Unload,
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not show borders in the display output.'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the left position for display output.'
        )]
        [int] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the right position for display output.'
        )]
        [int] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the bottom position for display output.'
        )]
        [int] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the display output.'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the display output in full screen.'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Alias('rf','bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to the previous window after completion.'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show output side by side.'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw','focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the output window.'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the output window to foreground.'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the output window.'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key to the output window.'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys.'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys.'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum callback length for tool calls.'
        )]
        [int] $MaxToolcallBackLength
        ###############################################################################
    )

    begin {

        # construct enhanced instructions for ai model to return structured data
        $instructions = @"
Analyze the users prompt and return a list of relevant strings.
Respond with a JSON object containing 'items' (array of strings).
The returned items should be concise and relevant to the input text.
$Instructions
"@

        # define response format schema for string list to ensure structured output
        $responseSchema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'string_list_response'
                strict = 'true'
                schema = @{
                    type       = 'object'
                    properties = @{
                        items = @{
                            type        = 'array'
                            items       = @{
                                type = 'string'
                            }
                            description = 'Array of extracted or generated strings'
                        }
                    }
                    required   = @('items')
                }
            }
        } |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # log the start of string list evaluation process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting string list evaluation with model: $Model"
        )

        # initialize script-scoped variables for storing results
        $script:result = @()

        $response = $null
    }

    process {

        # check if we should read from clipboard when no text parameter provided
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            # log that we're reading from clipboard due to no direct text input
            Microsoft.PowerShell.Utility\Write-Verbose (
                'No direct text input, reading from clipboard'
            )

            # retrieve text content from system clipboard
            $Text = Microsoft.PowerShell.Management\Get-Clipboard

            # validate that clipboard contains text data
            if ([string]::IsNullOrWhiteSpace($Text)) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'No text found in the clipboard.'
                )

                return
            }
        }

        try {

            # log the start of text processing for string extraction
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Processing text for string list extraction'
            )

            # copy matching parameters from current function to target function
            $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Invoke-LLMQuery'

            # set specific parameters for the llm query invocation
            $invocationParams.Query = $Text

            $invocationParams.Instructions = $instructions

            $invocationParams.IncludeThoughts = $false

            $invocationParams.ResponseFormat = $responseSchema

            $invocationParams.Temperature = $Temperature

            # configure chat mode for tools when default tools are allowed
            if ($AllowDefaultTools) {

                $invocationParams.ChatMode = 'textprompt'

                $invocationParams.ChatOnce = $true
            }

            # invoke ai model to get evaluation result and parse json response
            $response = GenXdev.AI\Invoke-LLMQuery @invocationParams |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

            # store the extracted items array in script scope for return
            $script:result = $response.items

            # construct summary text for verbose logging
            $summary = ("`r`n`"$Text`"`r`n`r`nExtracted items:`r`n" +
                       ($response.items -join "`r`n"))

            # log the processing summary with extracted items
            Microsoft.PowerShell.Utility\Write-Verbose $summary
        }
        catch {

            # log error when ai model fails to extract string list
            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to extract string list with AI model: $_"
            )
        }
    }

    end {

        # check if we have a valid response before processing clipboard operations
        if ($null -ne $response) {

            # copy results to clipboard if requested by user
            if ($SetClipboard) {

                # log clipboard copy operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Copying result to clipboard'
                )

                # copy summary with thoughts or just results based on preference
                if ($IncludeThoughts) {

                    $null = $summary |
                        Microsoft.PowerShell.Management\Set-Clipboard
                }
                else {

                    $null = $script:result |
                        Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }

        # return the extracted string array to the pipeline
        $script:result
    }
}
###############################################################################