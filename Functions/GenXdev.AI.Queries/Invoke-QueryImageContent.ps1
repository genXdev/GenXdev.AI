###############################################################################
<#
.SYNOPSIS
Analyzes image content using AI vision capabilities through the LM-Studio API.

.DESCRIPTION
Processes images using a specified model via the LM-Studio API to analyze
content and answer queries about the image. The function supports various
analysis parameters including temperature control for response randomness and
token limits for output length.

.PARAMETER Query
Specifies the question or prompt to analyze the image content. This drives the
AI's analysis focus and determines what aspects of the image to examine.

.PARAMETER ImagePath
The path to the image file for analysis. Supports both relative and absolute
paths. The file must exist and be accessible.

.PARAMETER Instructions
System instructions for the model to follow during the analysis.

.PARAMETER ResponseFormat
A JSON schema that specifies the requested output format for the response.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Lower values (closer
to 0) produce more focused and deterministic responses, while higher values
increase creativity and variability. Valid range: 0.0 to 1.0.

.PARAMETER ImageDetail
Sets the detail level for image analysis.
Valid values are "low", "medium", or "high".

.PARAMETER LLMQueryType
The type of LLM query to perform. Defaults to "Pictures" for image analysis.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
Specifies how much of the model to offload to the GPU.
- "off": Disables GPU offloading.
- "max": Offloads all layers to the GPU.
- 0 to 1: Offloads a fraction of layers to the GPU.
- -1: Lets LM Studio decide the offload amount.
- -2: Uses an automatic setting.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

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

.PARAMETER ShowWindow
If specified, the LM Studio window will be shown.

.PARAMETER Force
If specified, forces LM Studio to stop before initialization.

.PARAMETER IncludeThoughts
If specified, includes the model's thoughts in the output.

.EXAMPLE
Invoke-QueryImageContent `
    -Query "What objects are in this image?" `
    -ImagePath "C:\Images\sample.jpg" `
    -Temperature 0.01 `
    -MaxToken 100

Analyzes an image with specific temperature and token limits.

.EXAMPLE
Query-Image "Describe this image" "C:\Images\photo.jpg"

Simple image analysis using alias and positional parameters.
#>
###############################################################################
function Invoke-QueryImageContent {

    [CmdletBinding()]
    [Alias("Query-Image")]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The query string for analyzing the image"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Path to the image file for analysis"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "System instructions for the model"
        )]
        [string] $Instructions,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "A JSON schema for the requested output format"
        )]
        [string] $ResponseFormat = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Image detail level"
        )]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "high",
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
        [string] $LLMQueryType = "Pictures",
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
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                           "offloading is disabled. If 'max', all layers are " +
                           "offloaded to GPU. If a number between 0 and 1, " +
                           "that fraction of layers will be offloaded to the " +
                           "GPU. -1 = LM Studio will decide how much to " +
                           "offload to the GPU. -2 = Auto")
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
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
            HelpMessage = "Show the LM Studio window"
        )]
        [switch] $ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch] $Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
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

        # log the initiation of the image analysis process
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting image analysis with query: $Query"

        # convert any relative or partial path to a full, absolute path for
        # reliability
        $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath

        # ensure the specified image file exists before proceeding with the
        # analysis
        if (-not (Microsoft.PowerShell.Management\Test-Path $imagePath)) {

            # if the file doesn't exist, throw a terminating error
            throw "Image file not found: $imagePath"
        }
    }

    process {

        # log the start of the actual image processing step
        Microsoft.PowerShell.Utility\Write-Verbose ("Processing image: " +
                                                   "$imagePath")

        # construct a hashtable of parameters to be passed to the next function
        $parameters = GenXdev.Helpers\Copy-IdenticalParamValues `
           -BoundParameters $PSBoundParameters `
           -FunctionName "GenXdev.AI\Invoke-LLMQuery" `
           -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope "Local" `
                            -ErrorAction SilentlyContinue)

        # add the image path to the attachments array for the llm query
        $parameters.Attachments = @($imagePath)

        # invoke the ai model with the constructed parameters and image analysis
        # configuration
        GenXdev.AI\Invoke-LLMQuery @parameters
    }

    end {
    }
}
###############################################################################