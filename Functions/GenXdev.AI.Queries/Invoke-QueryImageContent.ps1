################################################################################
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

.PARAMETER Model
The LM-Studio model to use for the analysis.
Defaults to "qwen2.5-14b-instruct".

.PARAMETER ModelLMSGetIdentifier
Identifier used for getting a specific model from LM Studio.
Defaults to "qwen2.5-14b-instruct".

.PARAMETER Instructions
System instructions for the model to follow during the analysis.

.PARAMETER Attachments
An array of file paths to attach to the request.

.PARAMETER ResponseFormat
A JSON schema that specifies the requested output format for the response.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Lower values (closer
to 0) produce more focused and deterministic responses, while higher values
increase creativity and variability. Valid range: 0.0 to 1.0.

.PARAMETER MaxToken
Limits the length of the generated response by specifying the maximum number of
tokens. Use -1 for an unlimited response length.

.PARAMETER TTLSeconds
Sets a Time-To-Live (in seconds) for models loaded via API requests.

.PARAMETER Gpu
Specifies how much of the model to offload to the GPU.
- "off": Disables GPU offloading.
- "max": Offloads all layers to the GPU.
- 0 to 1: Offloads a fraction of layers to the GPU.
- -1: Lets LM Studio decide the offload amount.
- -2: Uses an automatic setting.

.PARAMETER ImageDetail
Sets the detail level for image analysis.
Valid values are "low", "medium", or "high".

.PARAMETER ApiEndpoint
The API endpoint URL. Defaults to '''http://localhost:1234/v1/chat/completions'''.

.PARAMETER ApiKey
The API key to use for the request.

.PARAMETER TimeoutSeconds
The timeout in seconds for the API request. Defaults to 24 hours.

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

.EXAMPLE
Query-Image "Describe this image" "C:\Images\photo.jpg"
#>
function Invoke-QueryImageContent {

    [CmdletBinding()]
    [Alias()]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The query string for analyzing the image"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Path to the image file for analysis"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model = "MiniCPM",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier = "lmstudio-community/MiniCPM-V-2_6-GGUF/MiniCPM-V-2_6-Q4_K_M.gguf",
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
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int] $MaxToken = -1,
        ########################################################################
        [Alias("ttl")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API requests"
        )]
        [int] $TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "How much to offload to the GPU. If 'off', GPU offloading is " +
                "disabled. If 'max', all layers are offloaded to GPU. If a " +
                "number between 0 and 1, that fraction of layers will be " +
                "offloaded to the GPU. -1 = LM Studio will decide how much " +
                "to offload to the GPU. -2 = Auto"
            )
        )]
        [int]$Gpu = -1,
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
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/chat/completions"
        )]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request"
        )]
        [string] $ApiKey = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Timeout in seconds for the request, defaults to 24 hours"
        )]
        [int] $TimeoutSeconds = (3600 * 24),
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
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts
    )

    begin {

        # log the initiation of the image analysis process
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting image analysis with query: $Query"

        # convert any relative or partial path to a full, absolute path for reliability
        $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath

        # ensure the specified image file exists before proceeding with the analysis
        if (-not (Microsoft.PowerShell.Management\Test-Path $imagePath)) {

            # if the file doesn't exist, throw a terminating error
            throw "Image file not found: $imagePath"
        }
    }

    process {

        # log the start of the actual image processing step
        Microsoft.PowerShell.Utility\Write-Verbose "Processing image: $imagePath"

        # construct a hashtable of parameters to be passed to the next function
        $parameters = GenXdev.Helpers\Copy-IdenticalParamValues `
           -BoundParameters $PSBoundParameters `
           -FunctionName "Invoke-LLMQuery" `
           -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope "Local" -ErrorAction SilentlyContinue)

        $parameters.Attachments = @($imagePath)

        # invoke the ai model with the constructed parameters and image analysis configuration
        GenXdev.AI\Invoke-LLMQuery @parameters
    }

    end {
    }
}
################################################################################