################################################################################
<#
.SYNOPSIS
Ensures LM Studio is properly initialized with the specified model.

.DESCRIPTION
Initializes or reinitializes LM Studio with a specified model. This function
handles process management, configuration settings, and ensures the proper model
is loaded. It can force a restart if needed and manages window visibility.

.PARAMETER Model
Name or partial path of the model to initialize. Supports wildcard patterns.
Defaults to "qwen2.5-14b-instruct".

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier to use. This should match an available
model in LM Studio.

.PARAMETER MaxToken
Maximum number of tokens allowed in responses. Use -1 for default setting.
Default is 8192.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests. Use -1 for no TTL.

.PARAMETER ShowWindow
Shows the LM Studio window during initialization when specified.

.PARAMETER Force
Forces LM Studio to stop before initialization when specified.

.EXAMPLE
EnsureLMStudio -Model "qwen2.5-14b-instruct" -MaxToken 8192 -ShowWindow

.EXAMPLE
EnsureLMStudio "mistral-7b" -ttl 3600 -Force
#>
function EnsureLMStudio {

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
        [string]$Model = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$MaxToken = 8192,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API"
        )]
        [Alias("ttl")]
        [ValidateRange(-1, [int]::MaxValue)]
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

        Microsoft.PowerShell.Utility\Write-Verbose "Starting EnsureLMStudio with Model: $Model"

        # ensure default model parameter is set
        if (-not $PSBoundParameters.ContainsKey("Model")) {
            $null = $PSBoundParameters.Add("Model", "qwen2.5-14b-instruct")
        }

        # ensure default model identifier is set
        if (-not $PSBoundParameters.ContainsKey("ModelLMSGetIdentifier")) {
            $null = $PSBoundParameters.Add("ModelLMSGetIdentifier",
                "qwen2.5-14b-instruct")
        }

        # ensure default max token is set
            if (-not $PSBoundParameters.ContainsKey("MaxToken")) {
                $null = $PSBoundParameters.Add("MaxToken", 8192)
        }
    }

    process {

        # prepare parameters for model initialization
        $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Initialize-LMStudioModel" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -Name * -ErrorAction SilentlyContinue)

        Microsoft.PowerShell.Utility\Write-Verbose ("Initializing LM Studio model " +
            "with parameters")

        # initialize the model with prepared parameters
        $null = GenXdev.AI\Initialize-LMStudioModel @invocationArguments
    }

    end {
        if ($ShowWindow) {

            try {
                $a = (GenXDev.Windows\Get-Window -ProcessName "LM Studio") ;
                if ($null -eq $a) { return }
                $null = $a.Show()
                $null = $a.Restore()
                GenXDev.Windows\Set-WindowPosition -WindowHelper $a -Monitor 0 -Right
                GenXDev.Windows\Set-WindowPosition -Left -Monitor 0 -Left
            }
            catch {

            }
        }
    }
}
################################################################################