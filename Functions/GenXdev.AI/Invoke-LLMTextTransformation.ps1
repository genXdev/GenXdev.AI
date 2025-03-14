################################################################################
<#
.SYNOPSIS
Transforms text using AI-powered processing.

.DESCRIPTION
This function processes input text using AI models to perform various transformations
such as spell checking, adding emoticons, or any other text enhancement specified
through instructions. It can accept input directly through parameters, from the
pipeline, or from the system clipboard.

.PARAMETER Text
The input text to transform. If not provided, the function will read from the
system clipboard. Multiple lines of text are supported.

.PARAMETER Instructions
Instructions to guide the AI model in transforming the text. By default, it will
perform spell checking and grammar correction.

.PARAMETER Model
Specifies which AI model to use for the text transformation. Different models
may produce varying results. Defaults to "qwen".

.PARAMETER SetClipboard
When specified, copies the transformed text back to the system clipboard after
processing is complete.

.EXAMPLE
Invoke-LLMTextTransformation -Text "Hello, hwo are you todey?"

.EXAMPLE
"Time to celerbate!" | Invoke-LLMTextTransformation -Instructions "Add celebratory emoticons"
#>
function Invoke-LLMTextTransformation {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias("spellcheck")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to transform"
        )]
        [string]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Instructions for the AI model on how to transform the text"
        )]
        [string]$Instructions = "Check and correct any spelling or grammar errors in the text. Return the corrected text without any additional comments or explanations.",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
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
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach")]
        [string[]] $Attachments = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy the enhanced text to clipboard"
        )]
        [switch]$SetClipboard,
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
        [double] $Temperature = 0.01,
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
            HelpMessage = "Image detail level")]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "low",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output")]
        [switch] $DontAddThoughtsToHistory,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Continue from last conversation")]
        [switch] $ContinueLast,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of function definitions")]
        [hashtable[]] $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools")]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        # Array of command names that don't require confirmation
        [Parameter(Mandatory = $false)]
        [string[]]
        [Alias("NoConfirmationFor")]
        $NoConfirmationToolFunctionNames = @(),
        ###########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI responses",
            Mandatory = $false
        )]
        [switch] $Speak,
        ###########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI thought responses",
            Mandatory = $false
        )]
        [switch] $SpeakThoughts,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache")]
        [switch] $NoSessionCaching,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/chat/completions")]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null,
        ########################################################################
        [switch] $AllowDefaultTools
    )

    begin {

        # create string builder for efficient text accumulation
        $resultBuilder = [System.Text.StringBuilder]::new()

        # Define response format schema
        $responseSchema = @{
            type        = "json_schema"
            json_schema = @{
                name   = "text_transformation_response"
                strict = "true"
                schema = @{
                    type       = "object"
                    properties = @{
                        response = @{
                            type        = "string"
                            description = "The transformed text output"
                        }
                    }
                    required   = @("response")
                }
            }
        } | ConvertTo-Json -Depth 10

        Write-Verbose "Starting text transformation with model: $Model"
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
            Write-Verbose "Processing text block for transformation"

            $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "Invoke-LLMQuery"

            $invocationParams.Query = $Text
            $invocationParams.Instructions = $Instructions
            $invocationParams.IncludeThoughts = $false
            $invocationParams.ResponseFormat = $responseSchema
            $invocationParams.Temperature = $Temperature

            if ($AllowDefaultTools) {
                $invocationParams.ChatMode = "textprompt"
                $invocationParams.ChatOnce = $true
            }
            $enhancedText = (Invoke-LLMQuery @invocationParams |
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
    }
}
################################################################################