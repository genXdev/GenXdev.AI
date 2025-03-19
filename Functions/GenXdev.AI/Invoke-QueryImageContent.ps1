################################################################################
<#
.SYNOPSIS
Analyzes image content using AI vision capabilities through the LM-Studio API.

.DESCRIPTION
Processes images using the MiniCPM model via LM-Studio API to analyze content and
answer queries about the image. The function supports various analysis parameters
including temperature control for response randomness and token limits for output
length.

.PARAMETER Query
Specifies the question or prompt to analyze the image content. This drives the
AI's analysis focus and determines what aspects of the image to examine.

.PARAMETER ImagePath
The path to the image file for analysis. Supports both relative and absolute
paths. The file must exist and be accessible.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Lower values (closer
to 0) produce more focused and deterministic responses, while higher values
increase creativity and variability. Valid range: 0.0 to 1.0.

.PARAMETER MaxToken
Limits the length of the generated response by specifying maximum tokens.
Use -1 for unlimited response length. Valid range: -1 to MaxInt.

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
    [Alias("Query-Image", "Analyze-Image")]

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
            Position = 2,
            HelpMessage = "Temperature for controlling response randomness"
        )]
        [ValidateRange(0.0, 1.0)]
        [double]$Temperature = 0.01,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "A JSON schema for the requested output format")]
        [string] $ResponseFormat = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Maximum tokens in the generated response"
        )]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$MaxToken = -1
    )

    begin {

        # log the initiation of image analysis process
        Microsoft.PowerShell.Utility\Write-Verbose "Starting image analysis with query: $Query"

        # convert any relative or partial path to full path for reliability
        $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath

        # ensure the specified image file exists before proceeding
        if (-not (Microsoft.PowerShell.Management\Test-Path $imagePath)) {
            throw "Image file not found: $imagePath"
        }
    }

    process {

        # log the start of actual image processing
        Microsoft.PowerShell.Utility\Write-Verbose "Processing image: $imagePath"

        # invoke the ai model with image analysis configuration
        GenXdev.AI\Invoke-LLMQuery `
            -Model "MiniCPM" `
            -ModelLMSGetIdentifier "minicpm-v-2_6" `
            -Query $Query `
            -ResponseFormat $ResponseFormat `
            -Instructions "You are an AI assistant that analyzes images." `
            -Attachments $imagePath `
            -Temperature $Temperature `
            -MaxToken $MaxToken
    }

    end {
    }
}
################################################################################