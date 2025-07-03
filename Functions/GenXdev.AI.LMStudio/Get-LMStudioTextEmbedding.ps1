###############################################################################
<#
.SYNOPSIS
Gets text embeddings from LM Studio model.

.DESCRIPTION
Gets text embeddings for the provided text using LM Studio's API. Can work with
both local and remote LM Studio instances. Handles model initialization and API
communication for converting text into numerical vector representations.

.PARAMETER Text
The text to get embeddings for. Can be a single string or an array of strings.

.PARAMETER ShowWindow
Shows the LM Studio window during processing.

.PARAMETER Force
Forces LM Studio restart before processing.

.PARAMETER Unload
Unloads the specified model instead of loading it.

.PARAMETER LLMQueryType
The type of LLM query for optimal model selection.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER TTLSeconds
The time-to-live in seconds for cached AI responses.

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
Get-LMStudioTextEmbedding -Text "Hello world" -Model "llama2" -ShowWindow

.EXAMPLE
"Sample text" | embed-text -TTLSeconds 3600
#>
function Get-LMStudioTextEmbedding {

    [CmdletBinding()]
    [Alias("embed-text", "Get-TextEmbedding")]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Text to get embeddings for",
            ValueFromPipeline = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string[]]$Text,
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
            HelpMessage = "The time-to-live in seconds for cached AI responses"
        )]
        [int] $TTLSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
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
        [string] $LLMQueryType = "SimpleIntelligence",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Unloads the specified model instead of loading it"
        )]
        [switch]$Unload,
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
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose ("Starting text embedding " +
            "process with model: $Model")

        # setup api configuration for local or remote endpoint
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains("localhost")) {

            # initialize local lm studio instance
            $initParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # handle force parameter separately to avoid conflicts
            if ($PSBoundParameters.ContainsKey("Force")) {

                $null = $PSBoundParameters.Remove("Force")

                $Force = $false
            }

            # initialize model and get identifier for api requests
            $modelInfo = GenXdev.AI\Initialize-LMStudioModel @initParams

            $Model = $modelInfo.identifier
        }

        # setup api endpoint url with default fallback
        $apiUrl = [string]::IsNullOrWhiteSpace($ApiEndpoint) ?
            "http://localhost:1234/v1/embeddings" : $ApiEndpoint

        # create headers with optional authentication
        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = (-not [string]::IsNullOrWhiteSpace($ApiKey)) ?
                "Bearer $ApiKey" : $null
        }
    }

    process {

        Microsoft.PowerShell.Utility\Write-Verbose ("Processing embeddings " +
            "request for $($Text.Length) text items")

        # prepare request payload with model and input text
        $payload = @{
            model = $Model
            input = $Text
        }

        # convert payload to json with deep nesting support
        $json = $payload |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 60 -Compress

        # encode json string to utf8 bytes for api transmission
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        # invoke api with extended timeouts for large embedding requests
        $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
            -Uri $apiUrl `
            -Method Post `
            -Body $bytes `
            -Headers $headers `
            -OperationTimeoutSeconds (3600 * 24) `
            -ConnectionTimeoutSeconds (3600 * 24)

        # process and output embeddings with original text context
        foreach ($embedding in $response.data) {

            [PSCustomObject]@{
                embedding = $embedding.embedding
                index     = $embedding.index
                text      = $Text[$embedding.index]
            }
        }
    }

    end {
    }
}
###############################################################################