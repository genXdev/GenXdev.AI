################################################################################

<#
.SYNOPSIS
Sends an image to the LM-Studio API and returns the response.

.DESCRIPTION
The `Invoke-QueryImageContent` function sends an image to the LM-Studio API and returns the response.

.PARAMETER Query
The query string for the LLM.

.PARAMETER ImagePath
The file path of the image to send with the query.

.PARAMETER Temperature
The temperature parameter for controlling the randomness of the response.

.PARAMETER Max_token
The maximum number of tokens to generate in the response.

.EXAMPLE
Invoke-QueryImageContent -Query "Analyze this image." -ImagePath "C:\path\to\image.jpg" -Temperature 0.01 -Max_token 100

.EXAMPLE
Invoke-QueryImageContent "Analyze this image." "C:\path\to\image.jpg"
#>
function Invoke-QueryImageContent {

    [CmdletBinding()]

    param (
        ################################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The query string for the LLM."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Query,

        ################################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "The file path of the image to send with the query."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePath,

        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double]$Temperature = 0.01,

        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "The maximum number of tokens to generate in the response."
        )]
        [int]$Max_token = -1
    )

    begin {
        # expand the image path to its full path
        $ImagePath = Expand-Path $ImagePath
    }

    process {
        # invoke the query to get image content analysis
        Invoke-LMStudioQuery `
            -Model "MiniCPM" `
            -Query $Query `
            -Instructions "You are an AI assistant that analyzes images." `
            -Attachments $ImagePath `
            -Temperature $Temperature `
            -Max_token $Max_token
    }

    end {
    }
}
