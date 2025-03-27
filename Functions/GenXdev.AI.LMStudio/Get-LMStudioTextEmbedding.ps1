################################################################################
<#
.SYNOPSIS
Gets text embeddings from LM Studio model.

.DESCRIPTION
Gets text embeddings for the provided text using LM Studio's API. Can work with
both local and remote LM Studio instances. Handles model initialization and API
communication.

.PARAMETER Text
The text to get embeddings for. Can be a single string or an array of strings.

.PARAMETER Model
The LM Studio model to use for embeddings.

.PARAMETER ModelLMSGetIdentifier
Specific identifier used for getting model from LM Studio.

.PARAMETER ShowWindow
Shows the LM Studio window during processing.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests.

.PARAMETER Gpu
GPU offloading configuration:
-2 = Auto
-1 = LM Studio decides
0-1 = Fraction of layers to offload
"off" = Disabled
"max" = Maximum offloading

.PARAMETER Force
Forces LM Studio restart before processing.

.PARAMETER ApiEndpoint
API endpoint URL, defaults to http://localhost:1234/v1/embeddings.

.PARAMETER ApiKey
The API key to use for requests.

.EXAMPLE
Get-LMStudioTextEmbedding -Text "Hello world" -Model "llama2" -ShowWindow

.EXAMPLE
"Sample text" | embed-text -ttl 3600
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
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string]$Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier,
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
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/embeddings")]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null
        ########################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose ("Starting text embedding process " +
            "with model: $Model")

        # setup api configuration for local or remote endpoint
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains("localhost")) {

            # initialize local lm studio instance
            $initParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # handle force parameter separately
            if ($PSBoundParameters.ContainsKey("Force")) {
                $null = $PSBoundParameters.Remove("Force")
                $Force = $false
            }

            # initialize model and get identifier
            $modelInfo = GenXdev.AI\Initialize-LMStudioModel @initParams
            $Model = $modelInfo.identifier
        }

        # setup api endpoint and headers
        $apiUrl = [string]::IsNullOrWhiteSpace($ApiEndpoint) ?
            "http://localhost:1234/v1/embeddings" : $ApiEndpoint

        $headers = @{
            "Content-Type" = "application/json"
            "Authorization" = (-not [string]::IsNullOrWhiteSpace($ApiKey)) ?
                "Bearer $ApiKey" : $null
        }
    }

    process {

        Microsoft.PowerShell.Utility\Write-Verbose ("Processing embeddings request " +
            "for $($Text.Length) text items")

        # prepare request payload
        $payload = @{
            model = $Model
            input = $Text
        }

        # convert to json and encode
        $json = $payload |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 60 -Compress
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        # invoke api with extended timeouts
        $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
            -Uri $apiUrl `
            -Method Post `
            -Body $bytes `
            -Headers $headers `
            -OperationTimeoutSeconds (3600 * 24) `
            -ConnectionTimeoutSeconds (3600 * 24)

        # process and output embeddings
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
################################################################################