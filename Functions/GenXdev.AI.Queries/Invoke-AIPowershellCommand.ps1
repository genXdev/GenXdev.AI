###############################################################################
<#
.SYNOPSIS
Converts AI command suggestions to JSON format for processing.

.DESCRIPTION
This helper function takes a PowerShell command suggestion from an AI model
and converts it to a standardized JSON format that can be consumed by other
parts of the GenXdev AI system. The function validates the command and
ensures proper formatting before conversion.

.PARAMETER Command
The PowerShell command to process and convert to JSON format.

.EXAMPLE
Set-AICommandSuggestion -Command "Get-Process | Where-Object CPU -gt 100"

Returns a JSON object containing the command and success status.
#>
function Set-AICommandSuggestion {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The PowerShell command to process"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Command
        ###########################################################################
    )

    begin {

        # validate that shouldprocess is enabled for command processing
        Microsoft.PowerShell.Utility\Write-Verbose ("Processing AI command " +
            "suggestion for JSON conversion")
    }

    process {

        # check if we should proceed with processing the command
        if ($PSCmdlet.ShouldProcess($Command, "Process AI command suggestion")) {

            # convert the command suggestion to json format
            return @{
                command = $Command.Trim()
                success = $true
            } | Microsoft.PowerShell.Utility\ConvertTo-Json `
                -WarningAction SilentlyContinue
        }
    }

    end {
    }
}

###############################################################################
<#
.SYNOPSIS
Generates and executes PowerShell commands using AI assistance.

.DESCRIPTION
Uses LM-Studio or other AI models to generate PowerShell commands based on
natural language queries. The function can either send commands directly to
the PowerShell window or copy them to the clipboard. It leverages AI models
to interpret natural language and convert it into executable PowerShell
commands with comprehensive parameter support for various AI backends.

.PARAMETER Query
The natural language description of what you want to accomplish. The AI will
convert this into an appropriate PowerShell command.

.PARAMETER Instructions
Additional instructions for the AI model to customize command generation
behavior and provide context-specific guidance.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Values range from
0.0 (more focused/deterministic) to 1.0 (more creative/random).

.PARAMETER LLMQueryType
The type of LLM query to perform. Determines the AI model's behavior and
response style for different use cases.

.PARAMETER Model
The model identifier or pattern to use for AI operations. Can be a name or
partial path with support for pattern matching.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier for Hugging Face models.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations to control response
length and processing time.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations for performance
optimization.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If
'max', all layers are offloaded to GPU. If a number between 0 and 1, that
fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
how much to offload to the GPU. -2 = Auto

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations when using external AI services.

.PARAMETER ApiKey
The API key for authenticated AI operations with external services.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations to prevent hanging requests.

.PARAMETER PreferencesDatabasePath
Database path for preference data files to store AI configuration settings.

.PARAMETER Clipboard
When specified, copies the generated command to clipboard instead of
executing it directly.

.PARAMETER ShowWindow
Show the LM Studio window during AI command generation for monitoring
purposes.

.PARAMETER Force
Force stop LM Studio before initialization to ensure clean startup state.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences instead of
persistent configuration.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences and reset
to defaults.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session
state.

.EXAMPLE
Invoke-AIPowershellCommand -Query "list all running processes" -Model "qwen"

Generates a PowerShell command to list running processes using the qwen model.

.EXAMPLE
hint "list files modified today"

Uses the alias to generate a command for finding files modified today.

.EXAMPLE
Invoke-AIPowershellCommand -Query "stop service" -Clipboard

Generates a command to stop a service and copies it to clipboard.
#>
function Invoke-AIPowershellCommand {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    [Alias("hint")]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The natural language query to generate a command for"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
        )]
        [string] $Instructions = "",
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        ###########################################################################
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
        [string] $LLMQueryType = "Coding",
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string] $Model,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        ###########################################################################
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
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy command to clipboard"
        )]
        [switch] $Clipboard,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
        [switch] $ShowWindow,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch] $Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences " +
                "without affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###########################################################################
    )

    begin {

        # initialize verbose logging for ai command generation
        Microsoft.PowerShell.Utility\Write-Verbose ("Initializing AI command " +
            "generation")

        # build comprehensive instruction template for the ai model
        $commandInstructions = @"
You are a PowerShell expert.
Although you only have access to a limited set of tool functions to execute
in your suggested powershell commandline script, you are not limited
and have access to everything Powershell has to offer.
Analyze the user's request and suggest a PowerShell command that accomplishes
their goal.
First try basic powershell commands, if that does not solve it then try to use
the Get-GenXDevCmdlets, Get-Help and the Get-Command cmdlets to find the right
commands to use.
Return only the suggested command without any explanation or commentary.
$Instructions
"@
    }

    process {

        # log the query being processed for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose ("Generating PowerShell " +
            "command for query: $Query")

        # copy matching parameters to invoke transformation function
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Invoke-LLMTextTransformation"

        # set the text parameter to the user's query
        $invocationParams.Text = $Query

        # apply the instruction template to guide ai behavior
        $invocationParams.Instructions = $commandInstructions

        # configure clipboard setting for output handling
        $invocationParams.SetClipboard = $Clipboard

        # get the command from the ai using configured parameters
        $command = GenXdev.AI\Invoke-LLMTextTransformation @invocationParams

        # handle clipboard output mode
        if ($Clipboard) {

            # log successful clipboard operation
            Microsoft.PowerShell.Utility\Write-Verbose ("Command copied to " +
                "clipboard")
        }
        else {

            # handle direct execution mode with powershell window
            if ($PSCmdlet.ShouldProcess("PowerShell window", "Send command")) {

                # get the main powershell window for command injection
                $mainWindow = GenXdev.Windows\Get-PowershellMainWindow

                # bring the powershell window to foreground if found
                if ($null -ne $mainWindow) {

                    $null = $mainWindow.SetForeground()
                }

                # preserve current clipboard contents
                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard

                try {

                    # prepare command for clipboard injection with newline handling
                    ($command.Trim().Replace("`n", " ```n")) |
                        Microsoft.PowerShell.Management\Set-Clipboard

                    # send paste keyboard shortcut to active window
                    GenXdev.Windows\Send-Key "^v"

                    # wait for paste operation to complete
                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {

                    # restore original clipboard contents
                    $oldClipboard |
                        Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }
    }

    end {
    }
}
###############################################################################