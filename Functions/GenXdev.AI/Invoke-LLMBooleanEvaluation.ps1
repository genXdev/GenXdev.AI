################################################################################
<#
.SYNOPSIS
Evaluates a statement using AI to determine if it's true or false.

.DESCRIPTION
This function uses AI models to evaluate statements and determine their truth value.
It can accept input directly through parameters, from the pipeline, or from the
system clipboard.

.PARAMETER Text
The statement to evaluate. If not provided, the function will read from the
system clipboard.

.PARAMETER Instructions
Instructions to guide the AI model in evaluating the statement. By default, it will
determine if the statement is true or false.

.PARAMETER Model
Specifies which AI model to use for the evaluation. Different models
may produce varying results.

.PARAMETER SetClipboard
When specified, copies the result back to the system clipboard after processing.

.EXAMPLE
Invoke-LLMBooleanEvaluation -Text "The Earth is flat"

.EXAMPLE
"Humans need oxygen to survive" | Invoke-LLMBooleanEvaluation
#>
function Invoke-LLMBooleanEvaluation {

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [Alias("equalstrue")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The statement to evaluate"
        )]
        [string]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Instructions for the AI model on how to evaluate the statement"
        )]
        [string]$Instructions = "",
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
            HelpMessage = "Copy the result to clipboard"
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
        [switch] $IncludeThoughts,
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

        $Instructions = @"
Evaluate if the following statement is true or false.
Respond with a JSON object containing 'result' (boolean), 'confidence' (0.0 - 1.0) and 'reason' (string).
The returned 'reason' should explain as short as possible, why the statement was evaluated as true or false.
Only pure facts should have high confidence.
$Instructions
"@

        # Define response format schema for boolean evaluation
        $responseSchema = @{
            type        = "json_schema"
            json_schema = @{
                name   = "boolean_evaluation_response"
                strict = "true"
                schema = @{
                    type       = "object"
                    properties = @{
                        result     = @{
                            type        = "boolean"
                            description = "The evaluation result: true if the statement is true, false if it's false"
                        }
                        confidence = @{
                            type        = "number"
                            minimum     = 0
                            maximum     = 1
                            description = "Confidence level in the evaluation (0-1)"
                        }
                        reason     = @{
                            type        = "string"
                            description = "Explanation for why the statement was evaluated as true or false"
                        }
                    }
                    required   = @("result", "confidence", "reason")
                }
            }
        } | ConvertTo-Json -Depth 10

        Write-Verbose "Starting boolean evaluation with model: $Model"

        $script:result = $false
        $response = $null
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
            Write-Verbose "Processing statement for evaluation"

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

            # Get evaluation result
            $response = Invoke-LLMQuery @invocationParams | ConvertFrom-Json

            # Store result
            $script:result = [bool]$response.result
            $summary = "`r`n`"$Text`"`r`n`r`nevaluates to be: $($response.result)`r`nconfidence: $($response.confidence) confidence.`r`nReason: $($response.reason)`r`n"

            Write-Verbose $summary
        }
        catch {
            Write-Error "Failed to evaluate statement with AI model: $_"
        }
    }

    end {
        if ($null -ne $response) {

            if ($SetClipboard) {

                Write-Verbose "Copying result to clipboard"

                if ($IncludeThoughts) {

                    $summary = "`r`n`"$Text`"`r`n`r`nevaluates to be: $($response.result)`r`nconfidence: $($response.confidence) confidence.`r`nReason: $($response.reason)`r`n"
                    $summary | Set-Clipboard
                }
                else {

                    Set-Clipboard -Value $script:result
                }
            }
        }

        # Return the boolean result
        $script:result
    }
}
################################################################################