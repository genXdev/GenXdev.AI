################################################################################
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

.PARAMETER Model
Specifies which AI model to use for the analysis. Different models may produce
varying results. Supports wildcard patterns.

.PARAMETER ModelLMSGetIdentifier
Identifier used for getting specific model from LM Studio. Used for precise
model selection when multiple models are available.

.PARAMETER Attachments
Array of file paths to attach to the AI query. These files will be included
in the context for analysis.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0). Lower values produce more
deterministic responses, higher values increase creativity.

.PARAMETER MaxToken
Maximum tokens in response (-1 for default). Controls the length of the AI
response.

.PARAMETER TTLSeconds
Set a TTL (in seconds) for models loaded via API requests. Determines how long
the model stays loaded in memory.

.PARAMETER Gpu
How much to offload to the GPU. Options: "off" disables GPU, "max" uses all
GPU layers, 0-1 sets fraction, -1 lets LM Studio decide, -2 for auto.

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

.PARAMETER ApiEndpoint
API endpoint URL, defaults to http://localhost:1234/v1/chat/completions for
LM Studio.

.PARAMETER ApiKey
The API key to use for the request when connecting to external AI services.

.PARAMETER SetClipboard
When specified, copies the resulting string list back to the system clipboard
after processing.

.EXAMPLE
PS> Invoke-LLMStringListEvaluation -Text "PowerShell features: object-based pipeline, integrated scripting environment, backwards compatibility, and enterprise management."
Returns: @("Object-based pipeline", "Integrated scripting environment", "Backwards compatibility", "Enterprise management")

.EXAMPLE
PS> "Make a shopping list with: keyboard, mouse, monitor, headset" | Invoke-LLMStringListEvaluation
Returns: @("Keyboard", "Mouse", "Monitor", "Headset")

.EXAMPLE
PS> Invoke-LLMStringListEvaluation -Text "List common PowerShell commands for file operations" -SetClipboard
Returns and copies to clipboard: @("Get-ChildItem", "Copy-Item", "Move-Item", "Remove-Item", "Set-Content", "Get-Content")
#>
function Invoke-LLMStringListEvaluation {

    [CmdletBinding()]
    [OutputType([string[]])]
    [Alias("getlist")]
    [Alias("getstring")]

    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to analyze and extract strings from"
        )]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ("Instructions for the AI model on how to generate " +
                          "the string list")
        )]
        [string] $Instructions = "",
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Identifier used for getting specific model from " +
                          "LM Studio")
        )]
        [string] $ModelLMSGetIdentifier,
        ###############################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach"
        )]
        [string[]] $Attachments = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int] $MaxToken = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Set a TTL (in seconds) for models loaded via " +
                          "API requests")
        )]
        [Alias("ttl")]
        [int] $TTLSeconds = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                          "offloading is disabled. If 'max', all layers are " +
                          "offloaded to GPU. If a number between 0 and 1, " +
                          "that fraction of layers will be offloaded to the " +
                          "GPU. -1 = LM Studio will decide how much to " +
                          "offload to the GPU. -2 = Auto")
        )]
        [int] $Gpu = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Image detail level"
        )]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "low",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of function definitions"
        )]
        [hashtable[]] $Functions = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of PowerShell command definitions to use " +
                          "as tools")
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of command names that don't require " +
                          "confirmation")
        )]
        [Alias("NoConfirmationFor")]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("API endpoint URL, defaults to " +
                          "http://localhost:1234/v1/chat/completions")
        )]
        [string] $ApiEndpoint = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request"
        )]
        [string] $ApiKey = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the result to clipboard"
        )]
        [switch] $SetClipboard,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
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
            HelpMessage = "Continue from last conversation"
        )]
        [switch] $ContinueLast,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI responses"
        )]
        [switch] $Speak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI thought responses"
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
            HelpMessage = "Enable default tools for the AI model"
        )]
        [switch] $AllowDefaultTools,
        ########################################################################
        # Use alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # construct enhanced instructions for ai model to return structured data
        $Instructions = @"
Analyze the users prompt and return a list of relevant strings.
Respond with a JSON object containing 'items' (array of strings).
The returned items should be concise and relevant to the input text.
$Instructions
"@

        # define response format schema for string list to ensure structured output
        $responseSchema = @{
            type        = "json_schema"
            json_schema = @{
                name   = "string_list_response"
                strict = "true"
                schema = @{
                    type       = "object"
                    properties = @{
                        items = @{
                            type        = "array"
                            items       = @{
                                type = "string"
                            }
                            description = "Array of extracted or generated strings"
                        }
                    }
                    required   = @("items")
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
                "No direct text input, reading from clipboard"
            )

            # retrieve text content from system clipboard
            $Text = Microsoft.PowerShell.Management\Get-Clipboard

            # validate that clipboard contains text data
            if ([string]::IsNullOrWhiteSpace($Text)) {
                Microsoft.PowerShell.Utility\Write-Warning (
                    "No text found in the clipboard."
                )
                return
            }
        }

        try {

            # log the start of text processing for string extraction
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing text for string list extraction"
            )

            # copy matching parameters from current function to target function
            $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Invoke-LLMQuery"

            # set specific parameters for the llm query invocation
            $invocationParams.Query = $Text
            $invocationParams.Instructions = $Instructions
            $invocationParams.IncludeThoughts = $false
            $invocationParams.ResponseFormat = $responseSchema
            $invocationParams.Temperature = $Temperature

            # configure chat mode for tools when default tools are allowed
            if ($AllowDefaultTools) {
                $invocationParams.ChatMode = "textprompt"
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
                    "Copying result to clipboard"
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
################################################################################