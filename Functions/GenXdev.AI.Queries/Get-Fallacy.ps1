################################################################################
function Get-Fallacy {

    ############################################################################
    [CmdletBinding()]
    [OutputType([object[]])]
    [Alias("moremovietitles")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param (
        ########################################################################
        [Parameter(
            ValueFromPipeline = $true,
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Text to parse to find Fallacies in"
        )]
        [string[]]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Instructions for the AI model on how to generate the string list"
        )]
        [string]$Instructions = "",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens IMDB searches for each result"
        )]
        [Alias("imdb")]
        [switch]$OpenInImdb,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)")]
        [Alias("MaxTokens")]
        [int] $MaxToken = -1,

        ########################################################################
        [Alias("ttl")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API requests")]
        [int] $TTLSeconds = -1,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "How much to offload to the GPU. If `"off`", GPU offloading is disabled. If `"max`", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto "
        )]
        [int]$Gpu = -1,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/chat/completions")]
        [string] $ApiEndpoint = $null,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null,

        ########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach")]
        [string[]] $Attachments = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Image detail level")]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "low",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output")]
        [switch] $IncludeThoughts,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Continue from last conversation")]
        [switch] $ContinueLast,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of function definitions")]
        [hashtable[]] $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools")]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of command names that don't require confirmation")]
        [Alias("NoConfirmationFor")]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI responses",
            Mandatory = $false
        )]
        [switch] $Speak,
        ########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI thought responses",
            Mandatory = $false
        )]
        [switch] $SpeakThoughts,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache")]
        [switch] $NoSessionCaching
    )

    ############################################################################
    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Starting fallacy analysis for provided text"

        [object[]] $results = @()

        $instructions = @"
You are an expert in logical reasoning and fallacy detection, trained on the Wikipedia `"List of Fallacies`" page (as provided). Your task is to analyze a given text for logical fallacies and return each occurrence with the following details:
Partial Quote: The specific segment of the text where the fallacy occurs.

Fallacy Name: The formal name of the fallacy as listed in the Wikipedia `"List of Fallacies`".

Description: A brief description of the fallacy based on its definition from the Wikipedia page.

Explanation: An explanation of why this instance qualifies as the identified fallacy, tailored to the context of the text.

Formal Classification: The category under which the fallacy falls (e.g., Formal Fallacies, Informal Fallacies > Faulty Generalizations, etc.), as per the Wikipedia structure.

Instructions:

$Instructions

Analyze the entire text provided by the user.

Identify every instance of a logical fallacy, even if multiple fallacies occur in the same sentence or paragraph.

If no fallacies are present, return a fallacies property holding an empty array.

Use the Wikipedia `"List of Fallacies`" page as the sole reference for fallacy definitions and classifications.

Do not invent fallacies or use external sources beyond the provided Wikipedia content.

Present the results in a clear, structured format (e.g., numbered list or table).

If the text is ambiguous, make a reasonable interpretation and explain your reasoning.

Input Format:
The user will provide a text sample (e.g., a paragraph, argument, or statement) for analysis.
Output Format:
For each detected fallacy:

Fallacy Occurrence #X:
- Partial Quote: `"[quote from text]`"
- Fallacy Name: [name of fallacy]
- Description: [brief description from Wikipedia]
- Explanation: [context-specific explanation]
- Formal Classification: [e.g., Informal Fallacies > Relevance Fallacies]

If no fallacies are found:

Return nothing.
"@

        # Define response format schema for custom objects
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
                                    PartialQuote       = @{ type = "string" }
                                    FallacyName        = @{ type = "string" }
                                    Description        = @{ type = "string" }
                                    Explanation        = @{ type = "string" }
                                    FormalClassification = @{ type = "string" }
                                }
                                required = @("PartialQuote", "FallacyName", "Description", "Explanation", "FormalClassification")
                            }
                        }
                    }
                    required = @("fallacies")
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        Microsoft.PowerShell.Utility\Write-Verbose "Initialized response schema for fallacy detection"
    }

    ############################################################################
    process {

        foreach ($textPart in $Text) {

            Microsoft.PowerShell.Utility\Write-Verbose "Preparing LLM invocation parameters"

            try {
                $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Invoke-LLMQuery"

                $invocationParams.Query = $textPart
                $invocationParams.Instructions = $instructions
                $invocationParams.IncludeThoughts = $false
                $invocationParams.ResponseFormat = $responseSchema
                $invocationParams.Temperature = $Temperature

                if ($AllowDefaultTools) {
                    $invocationParams.ChatMode = "textprompt"
                    $invocationParams.ChatOnce = $true
                }

                # Get evaluation result
                $response = GenXdev.AI\Invoke-LLMQuery @invocationParams | Microsoft.PowerShell.Utility\ConvertFrom-Json

                # Parse and store results
                if ($response.fallacies) {

                    $results += $response.fallacies
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose "No fallacies detected in the provided text"
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Error "Failed to analyze text for fallacies: $_"
            }
        }
    }

    ############################################################################
    end {
        if ($results.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose "Returning detected fallacies"
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "No fallacies detected in any provided text"
        }

        $results
    }
}
################################################################################
