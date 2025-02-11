################################################################################
<#
.SYNOPSIS
Add suitable emoticons to a text.

.DESCRIPTION
Add suitable emoticons to a text, which can come from pipeline or parameter or clipboard.

.PARAMETER Text
Optionally the text to outfit with emoticons, if not specified, will read and set the clipboard.

.PARAMETER Instructions
Addiitional instructions for the model.

.PARAMETER Model
Name or partial path of the model to initialize, detects and excepts -like 'patterns*' for search
.PARAMETER SetClipboard
Force the result to be set to the clipboard.

.EXAMPLE
    Add-EmoticonsToText -Text "Hello, how are you?"

.EXAMPLE
    or just get emojify the clipboard text:

    emojify

.EXAMPLE
    "This is lion, this is a dog, this is a sheep" | emojify

#>
function Add-EmoticonsToText {

    [CmdletBinding()]
    [Alias("emojify")]

    param (
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The text to emojify.",
            ValueFromPipeline
        )]
        [string] $Text,
        ################################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the LLM."
        )]
        $Instructions = "",
        ################################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response."
        )]
        [PSDefaultValue(Value = "qwen")]
        [string]$Model = "qwen",
        ################################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Whether to set the clipboard with the result."
        )]
        [switch] $SetClipboard
    )

    begin {
        [System.Text.StringBuilder] $allResults = New-Object System.Text.StringBuilder;
        $Instructions = "Add funny or expressive emojii to the text provided as content of the user-role message. Don't change the text otherwise.`r`n$Instructions `r`nRespond only in json format, like: {`"response`":`"Hello, how are you? 😊`"}"

        [Console]::Write("emojifying..")
    }

    process {

        $isFromClipboard = [string]::IsNullOrWhiteSpace($Text)
        $Text = "$Text"

        if ($isFromClipboard) {

            $Text = Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {

                Write-Warning "No text found in the clipboard."
                return;
            }
        }

        try {
            Write-Verbose "Emojifying text: `"$Text`".."

            # translate the text
            $Text = (qlms -Query "$Text" -Instructions $Instructions -Model $Model | ConvertFrom-Json).response
        }
        finally {


            $allResults.Append("$Text`r`n") | Out-Null
        }
    }

    end {
        $result = $allResults.ToString();

        if ($SetClipboard) {

            Set-Clipboard -Value $result
        }

        $result

        [Console]::Write("`e[1A`e[2K");
    }
}
