################################################################################
<#
.SYNOPSIS
Extracts or generates a list of relevant strings from input text using AI analysis.

.DESCRIPTION
This function uses AI models to analyze input text and extract or generate a list of relevant strings.
It can process text to identify key points, extract items from lists, or generate related concepts.
Input can be provided directly through parameters, from the pipeline, or from the system clipboard.

.PARAMETER Text
The text to analyze and extract strings from. If not provided, the function will read from the
system clipboard.

.PARAMETER Instructions
Optional instructions to guide the AI model in generating the string list. By default, it will
extract key points, items, or relevant concepts from the input text.

.PARAMETER Model
Specifies which AI model to use for the analysis. Different models may produce varying results.

.PARAMETER SetClipboard
When specified, copies the resulting string list back to the system clipboard after processing.

.EXAMPLE
PS> Invoke-LLMStringListEvaluation -Text "PowerShell features: object-based pipeline, integrated scripting environment, backwards compatibility, and enterprise management."
Returns: @("Object-based pipeline", "Integrated scripting environment", "Backwards compatibility", "Enterprise management")

.EXAMPLE
PS> "Make a shopping list with: keyboard, mouse, monitor, headset" | Invoke-LLMStringListEvaluation
Returns: @("Keyboard", "Mouse", "Monitor", "Headset")

.EXAMPLE
PS> Invoke-LLMStringListEvaluation -Text "List common PowerShell commands for file operations" -SetClipboard
Returns and copies to clipboard: @("Get-ChildItem", "Copy-Item", "Move-Item", "Remove-Item", "Set-Content", "Get-Content")
#>
function Invoke-LLMStringListEvaluation {

    [CmdletBinding()]
    [OutputType([string[]])]
    [Alias("getlist")]
    [Alias("getstring")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "The text to analyze"
        )]
        [string]$Text,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Instructions for the AI model on how to generate the string list"
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
        [double] $Temperature = 0.2,
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
        [Alias("NoConfirmationFor")]
        [string[]]
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
Analyze the users prompt and return a list of relevant strings.
Respond with a JSON object containing 'items' (array of strings).
The returned items should be concise and relevant to the input text.
$Instructions
"@

        # Define response format schema for string list
        $responseSchema = @{
            type        = "json_schema"
            json_schema = @{
                name   = "string_list_response"
                strict = "true"
                schema = @{
                    type       = "object"
                    properties = @{
                        items = @{
                            type        = "array"
                            items       = @{
                                type = "string"
                            }
                            description = "Array of extracted or generated strings"
                        }
                    }
                    required   = @("items")
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        Microsoft.PowerShell.Utility\Write-Verbose "Starting string list evaluation with model: $Model"
        $script:result = @()
        $response = $null
    }


process {
        # check if we should read from clipboard
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            Microsoft.PowerShell.Utility\Write-Verbose "No direct text input, reading from clipboard"
            $Text = Microsoft.PowerShell.Management\Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {
                Microsoft.PowerShell.Utility\Write-Warning "No text found in the clipboard."
                return
            }
        }

        try {
            Microsoft.PowerShell.Utility\Write-Verbose "Processing text for string list extraction"

            $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Invoke-LLMQuery"

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
            $response = GenXdev.AI\Invoke-LLMQuery @invocationParams | Microsoft.PowerShell.Utility\ConvertFrom-Json

            # Store result
            $script:result = $response.items
            $summary = "`r`n`"$Text`"`r`n`r`nExtracted items:`r`n" + ($response.items -join "`r`n")

            Microsoft.PowerShell.Utility\Write-Verbose $summary
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to extract string list with AI model: $_"
        }
    }

    end {
        if ($null -ne $response) {
            if ($SetClipboard) {
                Microsoft.PowerShell.Utility\Write-Verbose "Copying result to clipboard"
                if ($IncludeThoughts) {
                    $summary | Microsoft.PowerShell.Management\Set-Clipboard
                }
                else {
                    $script:result | Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }

        # Return the string array
        $script:result
    }
}
################################################################################