################################################################################
<#
.SYNOPSIS
Converts direct or blunt text into polite, professional corporate speak using AI.

.DESCRIPTION
This function processes input text to transform direct or potentially harsh
language into diplomatic, professional corporate communications. It can accept
input directly through parameters, from the pipeline, or from the system
clipboard. The function leverages AI models to analyze and rephrase text while
preserving the original intent.

.PARAMETER Text
The input text to convert to corporate speak. If not provided, the function will
read from the system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Additional instructions to guide the AI model in converting the text.
These can help fine-tune the tone and style of the corporate language.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SetClipboard
When specified, copies the transformed text back to the system clipboard.

.PARAMETER ShowWindow
Shows the LM Studio window during processing.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
ConvertTo-CorporateSpeak -Text "That's a terrible idea" -Model "qwen" -SetClipboard

.EXAMPLE
"This makes no sense" | corporatize
#>
################################################################################
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
        [ValidateNotNull()]
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
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
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
        [string]$LLMQueryType = "Knowledge",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string]$Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string]$HuggingFaceIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int]$MaxToken,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int]$Cpu,
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
        [string]$ApiEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string]$ApiKey,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int]$TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string]$PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the transformed text to clipboard"
        )]
        [switch]$SetClipboard,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
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
        [switch]$SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch]$ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch]$SkipSession
        ########################################################################
    )

    begin {

        # output verbose message about starting the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting corporate speak conversion"
        )
    }

    process {

        # setup corporate language transformation instructions
        $corporateInstructions = @"
Translate users input from the a brutal or direct phrase into polite,
professional corporate speak while preserving the original intent. The
translation should sound diplomatic and suitable for a corporate environment,
even if the original phrase is blunt or harsh.

Examples:

Original: 'That makes no sense.'
Translation: 'Can you please elaborate on your thinking here?'

Original: 'I've told you this 5,000 times.'
Translation: 'I have provided this information previously.'

Original: 'Stop micromanaging me.'
Translation: 'I feel that I am at my most productive when I have more autonomy.'

$Instructions
"@

        # output verbose message about the transformation process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing text transformation"
        )

        # invoke the language model with corporate instructions
        GenXdev.AI\Invoke-LLMTextTransformation @PSBoundParameters `
            -Instructions $corporateInstructions
    }

    end {

        # output verbose message about completion of the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed corporate speak conversion"
        )
    }
}
################################################################################