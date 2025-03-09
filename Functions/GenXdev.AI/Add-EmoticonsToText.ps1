################################################################################
<#
.SYNOPSIS
Enhances text by adding contextually appropriate emoticons using AI.

.DESCRIPTION
This function processes input text to add emoticons that match the emotional
context. It can accept input directly through parameters, from the pipeline, or
from the system clipboard. The function leverages AI models to analyze the text
and select appropriate emoticons, making messages more expressive and engaging.

.PARAMETER Text
The input text to enhance with emoticons. If not provided, the function will
read from the system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Additional instructions to guide the AI model in selecting and placing emoticons.
These can help fine-tune the emotional context and style of added emoticons.

.PARAMETER Model
Specifies which AI model to use for emoticon selection and placement. Different
models may produce varying results in terms of emoticon selection and context
understanding. Defaults to "qwen".

.PARAMETER SetClipboard
When specified, copies the enhanced text back to the system clipboard after
processing is complete.

.EXAMPLE
Add-EmoticonsToText -Text "Hello, how are you today?" -Model "qwen" `
    -SetClipboard

.EXAMPLE
"Time to celebrate!" | emojify
#>
function Add-EmoticonsToText {

    [CmdletBinding()]
    [OutputType([System.String])]
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
        [SupportsWildcards()]
        [string]$Model = "qwen",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the enhanced text to clipboard"
        )]
        [switch]$SetClipboard
        ########################################################################
    )

    begin {

        # create string builder for efficient text accumulation
        $resultBuilder = [System.Text.StringBuilder]::new()

        # construct ai model instructions with specific formatting requirements
        $modelPrompt = (
            "Add funny or expressive emojii to the text provided as content " +
            "of the user-role message. Don't change the text otherwise." +
            "`r`n$Instructions`r`nRespond only in json format, like: " +
            '{`"response`":`"Hello, how are you? 😊`"}'
        )

        Write-Verbose "Starting emoticon enhancement process with model: $Model"

        # show processing indicator
        [Console]::Write("emojifying..")
    }

    process {

        # check if we should read from clipboard
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            Write-Verbose "No direct text input, reading from clipboard"
            $Text = Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {
                Write-Warning "No text found in the clipboard."
                return
            }
        }

        try {
            Write-Verbose "Processing text block: `"$Text`""

            # send text to ai model and extract enhanced response
            $enhancedText = (Invoke-LLMQuery -Query $Text `
                    -Instructions $modelPrompt `
                    -Model $Model |
                ConvertFrom-Json).response

            $null = $resultBuilder.Append("$enhancedText`r`n")
        }
        catch {
            Write-Error "Failed to process text with AI model: $_"
        }
    }

    end {

        # get final combined result
        $finalResult = $resultBuilder.ToString()

        if ($SetClipboard) {
            Write-Verbose "Copying enhanced text to clipboard"
            Set-Clipboard -Value $finalResult
        }

        # return enhanced text
        $finalResult

        # clear processing indicator
        [Console]::Write("`e[1A`e[2K")
    }
}
################################################################################
