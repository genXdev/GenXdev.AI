################################################################################
<#
.SYNOPSIS
Ensures LM Studio is properly initialized with the specified model.

.DESCRIPTION
Initializes or reinitializes LM Studio with a specified model, handling process
management and configuration settings.

.PARAMETER Model
Name or partial path of the model to initialize.

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
AssureLMStudio -Model "qwen2.5-14b-instruct" -MaxToken 32768 -ShowWindow

.EXAMPLE
AssureLMStudio "qwen2.5-14b-instruct" -ttl 3600 -Force
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
        [string]$Model = "qwen*-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [string]$ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int]$MaxToken = 32768,
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

        # remove force parameter if present as it's handled separately
        if ($PSBoundParameters.ContainsKey("Force")) {
            $null = $PSBoundParameters.Remove("Force")
        }

        # ensure default model parameter is set
        if (-not $PSBoundParameters.ContainsKey("Model")) {
            $null = $PSBoundParameters.Add("Model", "qwen*-instruct")
        }

        # ensure default model identifier is set
        if (-not $PSBoundParameters.ContainsKey("ModelLMSGetIdentifier")) {
            $null = $PSBoundParameters.Add("ModelLMSGetIdentifier", `
                "qwen2.5-14b-instruct")
        }

        # ensure default max token is set
        if (-not $PSBoundParameters.ContainsKey("MaxToken")) {
            $null = $PSBoundParameters.Add("MaxToken", 32768)
        }

        # force stop LM Studio processes if requested
        if ($Force) {
            Write-Verbose "Force parameter specified, stopping LM Studio processes"
            $null = Get-Process "LM Studio", "LMS" -ErrorAction SilentlyContinue |
                Stop-Process -Force
        }
    }

    process {

        Write-Verbose "Initializing LM Studio model with parameters"
        Initialize-LMStudioModel @PSBoundParameters
    }

    end {
    }
}
################################################################################
