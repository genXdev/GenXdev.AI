################################################################################
<#
.SYNOPSIS
Converts direct or blunt text into polite, professional corporate speak using AI.

.DESCRIPTION
This function processes input text to transform direct or potentially harsh language
into diplomatic, professional corporate communications. It can accept input directly
through parameters, from the pipeline, or from the system clipboard. The function
leverages AI models to analyze and rephrase text while preserving the original intent.

.PARAMETER Text
The input text to convert to corporate speak. If not provided, the function will
read from the system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Additional instructions to guide the AI model in converting the text.
These can help fine-tune the tone and style of the corporate language.

.PARAMETER Model
Specifies which AI model to use for text transformation. Different models may
produce varying results in terms of corporate language style. Defaults to "qwen".

.PARAMETER SetClipboard
When specified, copies the transformed text back to the system clipboard after
processing is complete.

.EXAMPLE
ConvertTo-CorporateSpeak -Text "That's a terrible idea" -Model "qwen" -SetClipboard

.EXAMPLE
"This makes no sense" | corporatize
#>
function ConvertTo-CorporateSpeak {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("corporatize")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to convert to corporate speak"
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
            HelpMessage = "Copy the transformed text to clipboard"
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
        $corporateInstructions = @"
Translate users input from the a brutal or direct phrase into polite, professional corporate speak while preserving the original intent. The translation should sound diplomatic and suitable for a corporate environment, even if the original phrase is blunt or harsh.
Examples:

Original: 'That makes no sense.'
Translation: 'Can you please elaborate on your thinking here?'

Original: 'I’ve told you this 5,000 times.'
Translation: 'I have provided this information previously.'

Original: 'Stop micromanaging me.'
Translation: 'I feel that I am at my most productive when I have more autonomy.'

$Instructions
"@
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters -Instructions $corporateInstructions
    }
}
################################################################################