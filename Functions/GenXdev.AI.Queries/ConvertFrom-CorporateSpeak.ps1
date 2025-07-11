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
ConvertFrom-CorporateSpeak -Text "I would greatly appreciate your timely
response" -SetClipboard

.EXAMPLE
"We should circle back" | uncorporatize
###############################################################################>
function ConvertFrom-CorporateSpeak {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("uncorporatize")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to convert from corporate speak"
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
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double]$Temperature = 0.0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The type of LLM query"
        )]
        [ValidateSet(
            "SimpleIntelligence",
            "Knowledge",
            "Pictures",
            "TextTranslation",
            "Coding",
            "ToolUse"
        )]
        [string] $LLMQueryType = "Knowledge",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                           "offloading is disabled. If 'max', all layers are " +
                           "offloaded to GPU. If a number between 0 and 1, " +
                           "that fraction of layers will be offloaded to the " +
                           "GPU. -1 = LM Studio will decide how much to " +
                           "offload to the GPU. -2 = Auto")
        )]
        [ValidateRange(-2, 1)]
        [int]$Gpu = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
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
        [switch]$ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

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
Layman: 'Cutting costs, often through layoffs.'

Corporate: 'Reorganization'
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

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Transforming text with corporate speak instructions"
        )

        # invoke the language model with corporate speak instructions
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
            -Instructions $corporateInstructions
    }

    end {

        Microsoft.PowerShell.Utility\Write-Verbose "Completed corporate speak conversion"
    }
}
###############################################################################