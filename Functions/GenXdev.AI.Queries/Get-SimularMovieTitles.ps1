################################################################################
<#
.SYNOPSIS
Finds similar movie titles based on common properties.

.DESCRIPTION
Analyzes the provided movies to find common properties and returns a list of 10
similar movie titles. Uses AI to identify patterns and themes across the input
movies to suggest relevant recommendations.

.PARAMETER Movies
Array of movie titles to analyze for similarities.

.PARAMETER Model
The LM-Studio model to use for analysis.

.PARAMETER ModelLMSGetIdentifier
Identifier used for getting specific model from LM Studio.

.PARAMETER OpenInImdb
Opens IMDB searches for each result in default browser.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER MaxToken
Maximum tokens in response (-1 for default).

.PARAMETER TTLSeconds
Set a TTL (in seconds) for models loaded via API requests.

.PARAMETER Gpu
GPU offload configuration (-2=Auto, -1=LMStudio decides, 0-1=fraction, off=CPU).

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER ApiEndpoint
Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
The API key to use for the request.

.EXAMPLE
Get-SimularMovieTitles -Movies "The Matrix","Inception" -OpenInImdb

.EXAMPLE
moremovietitles "The Matrix","Inception" -imdb
#>
################################################################################
function Get-SimularMovieTitles {

    ############################################################################
    [CmdletBinding()]
    [Alias("moremovietitles")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Array of movie titles to analyze for similarities"
        )]
        [string[]]$Movies,

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
            HelpMessage = "Opens IMDB searches for each result"
        )]
        [Alias("imdb")]
        [switch]$OpenInImdb,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,

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
    )

    ############################################################################
    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Starting movie analysis for: $($Movies -join ', ')"

        if ($Movies.Count -lt 2) {
            throw "Please provide at least 2 movies for comparison"
        }

        [string[]] $results = @()
    }

    ############################################################################
    process {

        # construct the prompt for movie analysis
        $prompt = @"
Analyze with high precision what the following movies have in common,
and provide me a list of 10 more movie titles that have closest match
based on the properties you found in your analyses.

$(($Movies | Microsoft.PowerShell.Core\ForEach-Object { "- $_`r`n" }))
"@

        Microsoft.PowerShell.Utility\Write-Verbose "Preparing LLM invocation parameters"

        # copy matching parameters to the LLM invocation
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Invoke-LLMStringListEvaluation"

        $invocationParams.Text = $prompt

        Microsoft.PowerShell.Utility\Write-Verbose "Invoking AI analysis"

        # get movie recommendations from AI
        $results = GenXdev.AI\Invoke-LLMStringListEvaluation @invocationParams

        if ($OpenInImdb) {
            Microsoft.PowerShell.Utility\Write-Verbose "Opening results in IMDB"
            GenXdev.Queries\Open-IMDBQuery -Query $results
        }
    }

    ############################################################################
    end {

        Microsoft.PowerShell.Utility\Write-Output $results
    }
}
################################################################################
