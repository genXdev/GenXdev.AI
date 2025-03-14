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
        [string[]] $Text,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
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
        Write-Verbose "Starting text embedding process..."

        # initialize lm studio if using localhost
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains("localhost")) {

            $initParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Get-Variable -Scope Local -Name * `
                    -ErrorAction SilentlyContinue)

            if ($PSBoundParameters.ContainsKey("Force")) {
                $null = $PSBoundParameters.Remove("Force")
                $Force = $false
            }

            $modelInfo = Initialize-LMStudioModel @initParams
            $Model = $modelInfo.identifier
        }

        # prepare api endpoint
        $apiUrl = "http://localhost:1234/v1/embeddings"

        if (-not [string]::IsNullOrWhiteSpace($ApiEndpoint)) {
            $apiUrl = $ApiEndpoint
        }

        $headers = @{ "Content-Type" = "application/json" }
        if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {
            $headers."Authorization" = "Bearer $ApiKey"
        }
    }

    process {
        Write-Verbose "Getting embeddings for text with model: $Model"

        # prepare api payload
        $payload = @{
            model = $Model
            input = $Text
        }

        # convert payload to json
        $json = $payload | ConvertTo-Json -Depth 60 -Compress
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        Write-Verbose "Requesting embeddings from LM-Studio model '$Model'"

        # send request with long timeouts
        $response = Invoke-RestMethod -Uri $apiUrl `
            -Method Post `
            -Body $bytes `
            -Headers $headers `
            -OperationTimeoutSeconds (3600 * 24) `
            -ConnectionTimeoutSeconds (3600 * 24)

        # Output embedding data
        foreach ($embedding in $response.data) {
            [PSCustomObject]@{
                embedding = $embedding.embedding
                index     = $embedding.index
                text      = $Text[$embedding.index]
            }
        }
    }
}