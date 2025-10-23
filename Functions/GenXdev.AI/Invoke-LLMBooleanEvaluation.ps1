<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Invoke-LLMBooleanEvaluation.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
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
###############################################################################
<#
.SYNOPSIS
Evaluates a statement using AI to determine if it's true or false.

.DESCRIPTION
This function uses AI models to evaluate statements and determine their truth
value. It can accept input directly through parameters, from the pipeline, or
from the system clipboard. The function returns a boolean result along with
confidence level and reasoning from the AI model.

.PARAMETER Text
The statement to evaluate. If not provided, the function will read from the
system clipboard.

.PARAMETER Instructions
Instructions to guide the AI model in evaluating the statement. By default, it
will determine if the statement is true or false.

.PARAMETER Attachments
Array of file paths to attach to the AI query for additional context.

.PARAMETER SetClipboard
When specified, copies the result back to the system clipboard after processing.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0). Controls creativity vs
determinism in AI responses.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER ImageDetail
Image detail level for visual processing. Valid values are low, medium, or high.

.PARAMETER IncludeThoughts
Include model's thoughts in output for debugging and transparency.

.PARAMETER DontAddThoughtsToHistory
Prevent model thoughts from being added to conversation history.

.PARAMETER ContinueLast
Continue from last conversation instead of starting fresh.

.PARAMETER Functions
Array of function definitions for AI tool use capabilities.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools in AI operations.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation before execution.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER NoSessionCaching
Don't store session in session cache for privacy or debugging.

.PARAMETER AllowDefaultTools
Allow the AI to use default tools and capabilities.

.PARAMETER LLMQueryType
The type of LLM query to optimize for specific use cases.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier from Hugging Face.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

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
Invoke-LLMBooleanEvaluation -Text "The Earth is flat" -Model "gpt-4"

.EXAMPLE
"Humans need oxygen to survive" | Invoke-LLMBooleanEvaluation

.EXAMPLE
equalstrue "2 + 2 = 4"
###############################################################################>
function Invoke-LLMBooleanEvaluation {

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [Alias('equalstrue')]
    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'The statement to evaluate'
        )]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Instructions for the AI model on how to evaluate ' +
                'the statement')
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
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
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
            HelpMessage = "Don't add model thoughts to conversation history"
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
            HelpMessage = 'Allow AI to use default tools and capabilities'
        )]
        [switch] $AllowDefaultTools,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session ' +
                'for AI preferences')
        )]
        [switch] $ClearSession,
        ###############################################################################
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
            HelpMessage = 'Time-to-live in seconds for the query or session'
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Alias('m','mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Monitor index or identifier for display operations'
        )]
        [int] $Monitor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Width for display or rendering operations'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Height for display or rendering operations'
        )]
        [int] $Height,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only markup blocks in the output'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for specific types of markup blocks'
        )]
        [string[]] $MarkupBlocksTypeFilter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio response randomness'
        )]
        [double] $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation'
        )]
        [double] $TemperatureResponse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language code or name for the response'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use for processing'
        )]
        [int] $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress from output'
        )]
        [string] $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing'
        )]
        [int] $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio detection'
        )]
        [double] $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation'
        )]
        [double] $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering'
        )]
        [double] $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering'
        )]
        [double] $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection'
        )]
        [double] $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output'
        )]
        [switch] $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output for thoughts'
        )]
        [switch] $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation)'
        )]
        [switch] $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture for input'
        )]
        [switch] $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not use context in the query'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses from the model'
        )]
        [switch] $OnlyResponses,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not initialize LM Studio during operation'
        )]
        [switch] $NoLMStudioInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unload resources after operation'
        )]
        [switch] $Unload,
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable window borders for display operations'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Align window to the left side of the screen'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Align window to the right side of the screen'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Align window to the bottom of the screen'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window on the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Display window in full screen mode'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Alias('rf','bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to the previous window after operation'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Display side by side with other windows'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw','focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after display'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after display'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after display'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key after operation'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [int] $MaxToolcallBackLength
        ###############################################################################
    )

    begin {

        # prepend evaluation instructions to user instructions
        $Instructions = @"
Evaluate if the following statement is true or false.
Respond with a JSON object containing 'result' (boolean), 'confidence' (0.0 - 1.0) and 'reason' (string).
The returned 'reason' should explain as short as possible, why the statement was evaluated as true or false.
Only pure facts should have high confidence.
$Instructions
"@

        # define response format schema for boolean evaluation
        $responseSchema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'boolean_evaluation_response'
                strict = 'true'
                schema = @{
                    type       = 'object'
                    properties = @{
                        result     = @{
                            type        = 'boolean'
                            description = ('The evaluation result: true if ' +
                                "the statement is true, false if it's false")
                        }
                        confidence = @{
                            type        = 'number'
                            minimum     = 0
                            maximum     = 1
                            description = ('Confidence level in the ' +
                                'evaluation (0-1)')
                        }
                        reason     = @{
                            type        = 'string'
                            description = ('Explanation for why the statement ' +
                                'was evaluated as true or false')
                        }
                    }
                    required   = @('result', 'confidence', 'reason')
                }
            }
        } |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # log initialization information
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting boolean evaluation with model: $Model"
        )

        # initialize result variables
        $script:result = $false
        $response = $null
    }


    process {

        # check if we should read from clipboard
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            # log clipboard reading operation
            Microsoft.PowerShell.Utility\Write-Verbose (
                'No direct text input, reading from clipboard'
            )

            # get text from system clipboard
            $Text = Microsoft.PowerShell.Management\Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'No text found in the clipboard.'
                )
                return
            }
        }

        try {

            # log processing start
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Processing statement for evaluation'
            )

            # copy parameters from current function to invoke-llmquery
            $invocationParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Invoke-LLMQuery'

            # configure query parameters for boolean evaluation
            $invocationParams.Query = $Text
            $invocationParams.Instructions = $Instructions
            $invocationParams.IncludeThoughts = $false
            $invocationParams.ResponseFormat = $responseSchema
            $invocationParams.Temperature = $Temperature

            if ($AllowDefaultTools) {

                # enable text prompt mode for tool usage
                $invocationParams.ChatMode = 'textprompt'
                $invocationParams.ChatOnce = $true
            }

            # get evaluation result from ai model
            $response = GenXdev.AI\Invoke-LLMQuery @invocationParams |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

            # extract boolean result from response
            $script:result = [bool]$response.result

            # create summary for verbose output
            $summary = ("`r`n`"$Text`"`r`n`r`nevaluates to be: " +
                "$($response.result)`r`nconfidence: $($response.confidence) " +
                "confidence.`r`nReason: $($response.reason)`r`n")

            # log evaluation summary
            Microsoft.PowerShell.Utility\Write-Verbose $summary
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to evaluate statement with AI model: $_"
            )
        }
    }

    end {

        if ($null -ne $response) {

            if ($SetClipboard) {

                # log clipboard operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Copying result to clipboard'
                )

                if ($IncludeThoughts) {

                    # create detailed summary with thoughts
                    $summary = ("`r`n`"$Text`"`r`n`r`nevaluates to be: " +
                        "$($response.result)`r`nconfidence: " +
                        "$($response.confidence) confidence.`r`nReason: " +
                        "$($response.reason)`r`n")

                    # copy summary to clipboard instead of piping
                    $null = Microsoft.PowerShell.Management\Set-Clipboard `
                        -Value $summary
                }
                else {

                    # copy boolean result to clipboard
                    $null = Microsoft.PowerShell.Management\Set-Clipboard `
                        -Value $script:result
                }
            }
        }

        # return the boolean result
        $script:result
    }
}
###############################################################################