################################################################################
<#
.SYNOPSIS
Translates text to another language using AI.

.DESCRIPTION
This function translates input text into a specified target language using AI
models. It can accept input directly through parameters, from the pipeline, or
from the system clipboard. The function preserves formatting and style while
translating.

.PARAMETER Text
The text to translate. Accepts pipeline input. If not provided, reads from system
clipboard.

.PARAMETER Instructions
Additional instructions to guide the AI model in translation style and context.

.PARAMETER Model
Specifies which AI model to use for translation. Supports wildcards.

.PARAMETER ModelLMSGetIdentifier
Identifier used for getting specific model from LM Studio.

.PARAMETER Temperature
Controls response randomness (0.0-1.0). Lower values are more deterministic.

.PARAMETER MaxToken
Maximum tokens in response. Use -1 for default model limits.

.PARAMETER SetClipboard
When specified, copies the translated text to system clipboard after translation.

.PARAMETER ShowWindow
Shows the LM Studio window during processing.

.PARAMETER TTLSeconds
Sets a Time-To-Live in seconds for models loaded via API requests.

.PARAMETER Gpu
Controls GPU layer offloading: -2=Auto, -1=LM Studio decides, 0-1=fraction of
layers, "off"=disabled, "max"=all layers.

.PARAMETER Force
Forces LM Studio to stop before initialization.

.PARAMETER ApiEndpoint
API endpoint URL. Defaults to http://localhost:1234/v1/chat/completions

.PARAMETER ApiKey
API key for authentication with the endpoint.

.PARAMETER Language
Target language for translation. Supports 140+ languages including major world
languages and variants.

.EXAMPLE
Get-TextTranslation -Text "Hello world" -Language "French" -Model "qwen"

.EXAMPLE
"Bonjour" | translate -Language "English"
#>
function Get-TextTranslation {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("translate")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to translate"
        )]
        [ValidateNotNull()]
        [string]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The target language for translation"
        )]
        [ValidateSet(
            "Afrikaans", "Akan", "Albanian", "Amharic", "Arabic", "Armenian",
            "Azerbaijani", "Basque", "Belarusian", "Bemba", "Bengali", "Bihari",
            "Bork, bork, bork!", "Bosnian", "Breton", "Bulgarian", "Cambodian",
            "Catalan", "Cherokee", "Chichewa", "Chinese (Simplified)",
            "Chinese (Traditional)", "Corsican", "Croatian", "Czech", "Danish",
            "Dutch", "Elmer Fudd", "English", "Esperanto", "Estonian", "Ewe",
            "Faroese", "Filipino", "Finnish", "French", "Frisian", "Ga",
            "Galician", "Georgian", "German", "Greek", "Guarani", "Gujarati",
            "Hacker", "Haitian Creole", "Hausa", "Hawaiian", "Hebrew", "Hindi",
            "Hungarian", "Icelandic", "Igbo", "Indonesian", "Interlingua",
            "Irish", "Italian", "Japanese", "Javanese", "Kannada", "Kazakh",
            "Kinyarwanda", "Kirundi", "Klingon", "Kongo", "Korean",
            "Krio (Sierra Leone)", "Kurdish", "Kurdish (Soranî)", "Kyrgyz",
            "Laothian", "Latin", "Latvian", "Lingala", "Lithuanian", "Lozi",
            "Luganda", "Luo", "Macedonian", "Malagasy", "Malay", "Malayalam",
            "Maltese", "Maori", "Marathi", "Mauritian Creole", "Moldavian",
            "Mongolian", "Montenegrin", "Nepali", "Nigerian Pidgin",
            "Northern Sotho", "Norwegian", "Norwegian (Nynorsk)", "Occitan",
            "Oriya", "Oromo", "Pashto", "Persian", "Pirate", "Polish",
            "Portuguese (Brazil)", "Portuguese (Portugal)", "Punjabi", "Quechua",
            "Romanian", "Romansh", "Runyakitara", "Russian", "Scots Gaelic",
            "Serbian", "Serbo-Croatian", "Sesotho", "Setswana",
            "Seychellois Creole", "Shona", "Sindhi", "Sinhalese", "Slovak",
            "Slovenian", "Somali", "Spanish", "Spanish (Latin American)",
            "Sundanese", "Swahili", "Swedish", "Tajik", "Tamil", "Tatar",
            "Telugu", "Thai", "Tigrinya", "Tonga", "Tshiluba", "Tumbuka",
            "Turkish", "Turkmen", "Twi", "Uighur", "Ukrainian", "Urdu", "Uzbek",
            "Vietnamese", "Welsh", "Wolof", "Xhosa", "Yiddish", "Yoruba", "Zulu"
        )]
        [string] $Language = "",
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
        )]
        [string]$Instructions = "",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
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
        [double] $Temperature = 0.2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)")]
        [Alias("MaxTokens")]
        [int] $MaxToken = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the translated text to clipboard"
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

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose ("Starting translation " +
            "process to target language: $Language")

        if ([string]::IsNullOrWhiteSpace($Language)) {

            # get system default language when none specified
            $Language = GenXdev.Helpers\Get-DefaultWebLanguage
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Using system default language: $Language")
        }
    }

    process {
# construct translation instructions with smart format preservation
        $translationInstructions = (
            "Translate the following text into $Language. " +
            "IMPORTANT TRANSLATION RULES:" +
            "`n1. Analyze the input format first - it could be code, markup, " +
            "structured data, or plain text." +
            "`n2. Preserve all syntax, structure, and technical elements like " +
            "programming keywords, tags, or data format specific elements." +
            "`n3. Only translate human-readable text portions like comments, " +
            "string values, documentation, or natural language content." +
            "`n4. Maintain exact formatting, indentation, and line breaks." +
            "`n5. Never translate identifiers, function names, variables, or " +
            "technical keywords." +
            " $Instructions")

        Microsoft.PowerShell.Utility\Write-Verbose "Preparing translation request"

        # copy matching parameters for invocation
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Invoke-LLMTextTransformation"

        Microsoft.PowerShell.Utility\Write-Verbose "Invoking LLM translation"

        # perform the translation
        GenXdev.AI\Invoke-LLMTextTransformation @invocationParams `
            -Instructions $translationInstructions
    }

    end {
    }
}
################################################################################