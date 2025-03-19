################################################################################
<#
.SYNOPSIS
Enhances text by adding contextually appropriate emoticons using AI.

.DESCRIPTION
This function processes input text to add emoticons that match the emotional
context. It can accept input directly through parameters, from the pipeline, or
from the system clipboard. The function leverages AI models to analyze the text
and select appropriate emoticons, making messages more expressive and engaging.

.PARAMETER Text
The input text to enhance with emoticons. If not provided, the function will
read from the system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Additional instructions to guide the AI model in selecting and placing emoticons.
These can help fine-tune the emotional context and style of added emoticons.

.PARAMETER Model
Specifies which AI model to use for emoticon selection and placement. Different
models may produce varying results in terms of emoticon selection and context
understanding. Defaults to "qwen".

.PARAMETER SetClipboard
When specified, copies the enhanced text back to the system clipboard after
processing is complete.

.EXAMPLE
Add-EmoticonsToText -Text "Hello, how are you today?" -Model "qwen" `
    -SetClipboard

.EXAMPLE
"Time to celebrate!" | emojify
#>
function Add-EmoticonsToText {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("emojify")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to enhance with emoticons"
        )]
        [string]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
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
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)")]
        [Alias("MaxTokens")]
        [int] $MaxToken = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the enhanced text to clipboard"
        )]
        [switch]$SetClipboard,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,
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
        [string] $ApiKey = $null
        ########################################################################
    )

    process {
        # construct instructions for emoticon enhancement
        $emotifyInstructions = (
            "Add funny or expressive emojii to the text provided as content " +
            "of the user-role message. Don't change the text otherwise. " +
            "$Instructions"
        )

        # invoke the language model with emoticon instructions
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
            -Instructions $emotifyInstructions
    }
}
################################################################################