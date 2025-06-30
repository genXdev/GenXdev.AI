################################################################################
<#
.SYNOPSIS
Analyzes text to identify logical fallacies using AI-powered detection.

.DESCRIPTION
This function analyzes provided text to detect logical fallacies using an AI
model trained on Wikipedia's List of Fallacies. It returns detailed information
about each fallacy found, including the specific quote, fallacy name,
description, explanation, and formal classification. The function uses a
structured response format to ensure consistent output.

.PARAMETER Text
The text content to analyze for logical fallacies. Can accept multiple text
inputs through pipeline or array.

.PARAMETER Instructions
Additional instructions for the AI model on how to analyze the text or focus
on specific types of fallacies.

.PARAMETER Model
The specific LM-Studio model to use for fallacy detection. Supports wildcard
patterns for model selection.

.PARAMETER ModelLMSGetIdentifier
Identifier used to retrieve a specific model from LM Studio when multiple
models are available.

.PARAMETER OpenInImdb
Switch to open IMDB searches for each detected fallacy result (legacy parameter
from inherited function structure).

.PARAMETER ShowWindow
Switch to display the LM Studio window during processing for monitoring
purposes.

.PARAMETER Temperature
Controls the randomness of the AI response. Lower values (0.0-0.3) provide
more focused analysis, higher values (0.7-1.0) allow more creative
interpretation.

.PARAMETER MaxToken
Maximum number of tokens allowed in the AI response. Use -1 for model default
settings.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests. Use -1 for no
expiration.

.PARAMETER Gpu
Controls GPU offloading for model processing. -1 lets LM Studio decide, -2 for
auto, 0-1 for fractional offloading, "off" disables GPU, "max" uses full GPU.

.PARAMETER Force
Forces LM Studio to stop and restart before initializing the model for
analysis.

.PARAMETER ApiEndpoint
Custom API endpoint URL for the language model service. Defaults to
http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
API key for authentication when using external language model services.

.PARAMETER Attachments
Array of file paths to attach to the analysis request for additional context.

.PARAMETER ImageDetail
Detail level for image processing when attachments include images. Options are
low, medium, or high.

.PARAMETER IncludeThoughts
Switch to include the model's reasoning process in the output alongside the
final analysis.

.PARAMETER ContinueLast
Switch to continue from the last conversation context instead of starting a
new analysis session.

.PARAMETER Functions
Array of custom function definitions to make available to the AI model during
analysis.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions that the AI model can use as tools
during analysis.

.PARAMETER NoConfirmationToolFunctionNames
Array of function names that don't require user confirmation before execution
when used by the AI model.

.PARAMETER Speak
Switch to enable text-to-speech output for the AI analysis results.

.PARAMETER SpeakThoughts
Switch to enable text-to-speech output for the AI model's reasoning process
when IncludeThoughts is enabled.

.PARAMETER NoSessionCaching
Switch to disable storing the analysis session in the session cache for
privacy or performance reasons.

.EXAMPLE
Get-Fallacy -Text "All politicians are corrupt because John was corrupt and he was a politician"

Analyzes the provided text for logical fallacies and returns structured
information about any fallacies detected.

.EXAMPLE
"This product is the best because everyone uses it" | Get-Fallacy -Temperature 0.1

Uses pipeline input to analyze text with low temperature for focused analysis.
#>
function Get-Fallacy {

    [CmdletBinding()]
    [OutputType([object[]])]
    [Alias("dispicetext")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]

    param(
        ###########################################################################
        [Parameter(
            ValueFromPipeline = $true,
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Text to parse to find Fallacies in"
        )]
        [string[]]$Text,
        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ("Instructions for the AI model on how to generate " +
                           "the string list")
        )]
        [string]$Instructions = "",
        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string]$Model,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Identifier used for getting specific model from " +
                           "LM Studio")
        )]
        [string]$ModelLMSGetIdentifier,
        ###########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach"
        )]
        [string[]]$Attachments = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request"
        )]
        [string]$ApiKey = $null,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Api endpoint url, defaults to " +
                           "http://localhost:1234/v1/chat/completions")
        )]
        [string]$ApiEndpoint = $null,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of function definitions"
        )]
        [hashtable[]]$Functions = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                           "offloading is disabled. If 'max', all layers are " +
                           "offloaded to GPU. If a number between 0 and 1, " +
                           "that fraction of layers will be offloaded to the " +
                           "GPU. -1 = LM Studio will decide how much to " +
                           "offload to the GPU. -2 = Auto")
        )]
        [int]$Gpu = -1,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Image detail level"
        )]
        [ValidateSet("low", "medium", "high")]
        [string]$ImageDetail = "low",
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int]$MaxToken = -1,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of command names that don't require " +
                           "confirmation")
        )]
        [Alias("NoConfirmationFor")]
        [string[]]$NoConfirmationToolFunctionNames = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of PowerShell command definitions to use " +
                           "as tools")
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]$ExposedCmdLets = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double]$Temperature = 0.2,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Set a TTL (in seconds) for models loaded via " +
                           "API requests")
        )]
        [Alias("ttl")]
        [int]$TTLSeconds = -1,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Continue from last conversation"
        )]
        [switch]$ContinueLast,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch]$IncludeThoughts,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch]$NoSessionCaching,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens IMDB searches for each result"
        )]
        [Alias("imdb")]
        [switch]$OpenInImdb,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
        [switch]$ShowWindow,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI responses"
        )]
        [switch]$Speak,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI thought responses"
        )]
        [switch]$SpeakThoughts,
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

    ###########################################################################
    begin {

        # output verbose information about starting fallacy analysis
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting fallacy analysis for provided text"

        # initialize results array to store detected fallacies
        [object[]]$results = @()

        # create comprehensive instructions for ai model fallacy detection
        $instructions = @"
You are an expert in logical reasoning and fallacy detection, trained on the Wikipedia "List of Fallacies" page (as provided). Your task is to analyze a given text for logical fallacies and return each occurrence with the following details:
Partial Quote: The specific segment of the text where the fallacy occurs.

Fallacy Name: The formal name of the fallacy as listed in the Wikipedia "List of Fallacies".

Description: A brief description of the fallacy based on its definition from the Wikipedia page.

Explanation: An explanation of why this instance qualifies as the identified fallacy, tailored to the context of the text.

Formal Classification: The category under which the fallacy falls (e.g., Formal Fallacies, Informal Fallacies > Faulty Generalizations, etc.), as per the Wikipedia structure.

Instructions:

$Instructions

Analyze the entire text provided by the user.

Identify every instance of a logical fallacy, even if multiple fallacies occur in the same sentence or paragraph.

If no fallacies are present, return a fallacies property holding an empty array.

Use the Wikipedia "List of Fallacies" page as the sole reference for fallacy definitions and classifications.

Do not invent fallacies or use external sources beyond the provided Wikipedia content.

Present the results in a clear, structured format (e.g., numbered list or table).

If the text is ambiguous, make a reasonable interpretation and explain your reasoning.

Input Format:
The user will provide a text sample (e.g., a paragraph, argument, or statement) for analysis.
Output Format:
For each detected fallacy:

Fallacy Occurrence #X:
- Partial Quote: "[quote from text]"
- Fallacy Name: [name of fallacy]
- Description: [brief description from Wikipedia]
- Explanation: [context-specific explanation]
- Formal Classification: [e.g., Informal Fallacies > Relevance Fallacies]

If no fallacies are found:

Return nothing.
"@

        # define json schema for structured fallacy detection response
        $responseSchema = @{
            type        = "json_schema"
            json_schema = @{
                name   = "fallacy_detection_response"
                strict = "true"
                schema = @{
                    type       = "object"
                    properties = @{
                        fallacies = @{
                            type  = "array"
                            items = @{
                                type       = "object"
                                properties = @{
                                    PartialQuote         = @{ type = "string" }
                                    FallacyName          = @{ type = "string" }
                                    Description          = @{ type = "string" }
                                    Explanation          = @{ type = "string" }
                                    FormalClassification = @{ type = "string" }
                                }
                                required = @("PartialQuote", "FallacyName",
                                             "Description", "Explanation",
                                             "FormalClassification")
                            }
                        }
                    }
                    required = @("fallacies")
                }
            }
        } |
        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # output verbose confirmation of schema initialization
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Initialized response schema for fallacy detection"
    }

    ###########################################################################
    process {

        # iterate through each text part provided for analysis
        foreach ($textPart in $Text) {

            # output verbose information about parameter preparation
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Preparing LLM invocation parameters"

            try {
                # copy matching parameters from bound parameters to invocation
                $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Invoke-LLMQuery"

                # set specific parameters for fallacy detection analysis
                $invocationParams.Query = $textPart
                $invocationParams.Instructions = $instructions
                $invocationParams.IncludeThoughts = $false
                $invocationParams.ResponseFormat = $responseSchema
                $invocationParams.Temperature = $Temperature

                # configure chat mode if default tools are allowed
                if ($AllowDefaultTools) {
                    $invocationParams.ChatMode = "textprompt"
                    $invocationParams.ChatOnce = $true
                }

                # invoke language model query for fallacy detection
                $response = GenXdev.AI\Invoke-LLMQuery @invocationParams |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

                # process and store fallacy detection results
                if ($response.fallacies) {

                    # add detected fallacies to results collection
                    $results += $response.fallacies
                }
                else {
                    # output verbose message when no fallacies are detected
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "No fallacies detected in the provided text"
                }
            }
            catch {
                # output error message if fallacy analysis fails
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to analyze text for fallacies: $_"
            }
        }
    }

    ###########################################################################
    end {

        # output appropriate verbose message based on results
        if ($results.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Returning detected fallacies"
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose `
                "No fallacies detected in any provided text"
        }

        # return the collected fallacy detection results
        $results
    }
}
################################################################################
