################################################################################
<#
.SYNOPSIS
Ensures LM Studio is properly initialized with the specified model.

.DESCRIPTION
Initializes or reinitializes LM Studio with a specified model, handling process
management and configuration settings.

.PARAMETER Model
Name or partial path of the model to initialize, detects and excepts -like 'patterns*' for search
Defaults to "*-tool-use".

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier to use.

.PARAMETER MaxToken
Maximum number of tokens in response. Use -1 for default setting.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests.

.PARAMETER ShowWindow
Shows the LM Studio window during initialization when specified.

.PARAMETER Force
Forces LM Studio to stop before initialization when specified.

.EXAMPLE
AssureLMStudio -Model "llama-3-groq-8b-tool-use" -MaxToken 8192 -ShowWindow

.EXAMPLE
AssureLMStudio "llama-3-groq-8b-tool-use" -ttl 3600 -Force
#>
function AssureLMStudio {

    [CmdletBinding()]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]$Model = "*-tool-use",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [string]$ModelLMSGetIdentifier = "llama-3-groq-8b-tool-use",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int]$MaxToken = 8192,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API"
        )]
        [Alias("ttl")]
        [int]$TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show LM Studio window during initialization"
        )]
        [switch]$ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force
        ########################################################################
    )

    begin {

        Write-Verbose "Starting AssureLMStudio with Model: $Model"

        # ensure default model parameter is set
        if (-not $PSBoundParameters.ContainsKey("Model")) {
            $null = $PSBoundParameters.Add("Model", "*-tool-use")
        }

        # ensure default model identifier is set
        if (-not $PSBoundParameters.ContainsKey("ModelLMSGetIdentifier")) {
            $null = $PSBoundParameters.Add("ModelLMSGetIdentifier", `
                    "llama-3-groq-8b-tool-use")
        }

        # ensure default max token is set
        if (-not $PSBoundParameters.ContainsKey("MaxToken")) {
            $null = $PSBoundParameters.Add("MaxToken", 8192)
        }
    }

    process {

        $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "Initialize-LMStudioModel" `
            -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

        Write-Verbose "Initializing LM Studio model with parameters"
        $null = Initialize-LMStudioModel @invocationArguments
    }

    end {
    }
}
################################################################################
