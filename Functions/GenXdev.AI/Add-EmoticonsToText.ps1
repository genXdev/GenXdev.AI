################################################################################
<#
.SYNOPSIS
Enhances text by adding contextually appropriate emoticons using AI.

.DESCRIPTION
This function processes input text to add emoticons that match the emotional
context. It can accept input from parameters, pipeline, or clipboard. The function
leverages AI models to analyze the text and select appropriate emoticons, making
the text more expressive and engaging.

.PARAMETER Text
The input text to enhance with emoticons. If not provided, the function will read
from the system clipboard.

.PARAMETER Instructions
Optional instructions to guide the AI model in selecting emoticons. These can help
fine-tune the emotional context and style of added emoticons.

.PARAMETER Model
The AI model to use for emoticon selection. Defaults to "qwen". Different models
may produce varying results in emoticon selection and placement.

.PARAMETER SetClipboard
When specified, the enhanced text will be copied back to the system clipboard
after processing.

.EXAMPLE
Add-EmoticonsToText -Text "Hello, how are you today?" -Model "qwen" -SetClipboard

.EXAMPLE
"Time to celebrate!" | emojify
#>
function Add-EmoticonsToText {


    [CmdletBinding()]
    [Alias("emojify")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to enhance with emoticons"
        )]
        [string]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
        )]
        [string]$Instructions = "",
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The AI model to use for text processing"
        )]
        [PSDefaultValue(Value = "qwen")]
        [string]$Model = "qwen",
        ########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Copy the enhanced text to clipboard"
        )]
        [switch]$SetClipboard
    )


    begin {

        # initialize StringBuilder to collect all processed results
        $resultBuilder = [System.Text.StringBuilder]::new()

        # prepare instructions for the AI model with specific formatting requirements
        $modelPrompt = "Add funny or expressive emojii to the text " + `
            "provided as content of the user-role message. Don't change the " + `
            "text otherwise.`r`n$Instructions`r`nRespond only in json format," + `
            " like: {`"response`":`"Hello, how are you? 😊`"}"

        # display processing indicator to user
        [Console]::Write("emojifying..")
    }


    process {

        # check if we need to read from clipboard (no text input provided)
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            # retrieve text content from system clipboard
            $Text = Get-Clipboard

            # validate clipboard content
            if ([string]::IsNullOrWhiteSpace($Text)) {
                Write-Warning "No text found in the clipboard."
                return
            }
        }

        try {
            # log the text being processed
            Write-Verbose "Processing text for emoticon enhancement: `"$Text`""

            # send text to AI model and process response
            $enhancedText = (qlms -Query $Text `
                    -Instructions $modelPrompt `
                    -Model $Model |
                ConvertFrom-Json).response

            # append processed text to result collection
            $null = $resultBuilder.Append("$enhancedText`r`n")
        }
        catch {
            Write-Error "Failed to process text with AI model: $_"
        }
    }


    end {

        # get final combined result
        $finalResult = $resultBuilder.ToString()

        # update clipboard if requested
        if ($SetClipboard) {
            Set-Clipboard -Value $finalResult
        }

        # output the enhanced text
        $finalResult

        # clear the processing indicator
        [Console]::Write("`e[1A`e[2K")
    }
}
################################################################################
