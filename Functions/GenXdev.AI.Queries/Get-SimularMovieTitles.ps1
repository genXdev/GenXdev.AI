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

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER OpenInImdb
Opens IMDB searches for each result in default browser.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Get-SimularMovieTitles -Movies "The Matrix","Inception" -OpenInImdb

.EXAMPLE
moremovietitles "The Matrix","Inception" -imdb
#>
function Get-SimularMovieTitles {

    ################################################################################
    [CmdletBinding()]
    [Alias("moremovietitles")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param (
        ################################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Array of movie titles to analyze for similarities"
        )]
        [string[]]$Movies,
        ################################################################################
        [Parameter(
            Position = 1,
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
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string] $Model,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        ################################################################################
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
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens IMDB searches for each result"
        )]
        [Alias("imdb")]
        [switch]$OpenInImdb,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
        [switch] $ShowWindow,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ################################################################################
    )

    ################################################################################
    begin {

        # output verbose message about starting movie analysis
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting movie analysis for: $($Movies -join ', ')")

        # validate minimum number of movies required for comparison
        if ($Movies.Count -lt 2) {
            throw "Please provide at least 2 movies for comparison"
        }

        # initialize empty array to store AI generated movie recommendations
        [string[]] $results = @()
    }

    ################################################################################
    process {

        # construct the AI prompt for movie analysis with input movies listed
        $prompt = @"
Analyze with high precision what the following movies have in common,
and provide me a list of 10 more movie titles that have closest match
based on the properties you found in your analyses.

$(($Movies |
    Microsoft.PowerShell.Core\ForEach-Object { "- $_`r`n" }))
"@

        # output verbose message about parameter preparation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Preparing LLM invocation parameters")

        # copy matching parameters from current function to target function
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Invoke-LLMStringListEvaluation"

        # set the constructed prompt as the text parameter for AI evaluation
        $invocationParams.Text = $prompt

        # output verbose message about AI invocation
        Microsoft.PowerShell.Utility\Write-Verbose "Invoking AI analysis"

        # invoke AI to get movie recommendations based on input analysis
        $results = GenXdev.AI\Invoke-LLMStringListEvaluation @invocationParams

        # open IMDB searches for results if requested by user
        if ($OpenInImdb) {

            # output verbose message about opening IMDB
            Microsoft.PowerShell.Utility\Write-Verbose "Opening results in IMDB"

            # open IMDB query for each recommended movie title
            GenXdev.Queries\Open-IMDBQuery -Query $results
        }
    }

    ################################################################################
    end {

        # output the final array of recommended movie titles
        Microsoft.PowerShell.Utility\Write-Output $results
    }
}
################################################################################
