################################################################################
# helper function to process AI command suggestions
function Set-AICommandSuggestion {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The PowerShell command to process"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Command
        ########################################################################
    )

    if ($PSCmdlet.ShouldProcess($Command, "Process AI command suggestion")) {

        # convert the command suggestion to json format
        return @{
            command = $Command.Trim()
            success = $true
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -WarningAction SilentlyContinue
    }
}

################################################################################
<#
.SYNOPSIS
Generates and executes PowerShell commands using AI assistance.

.DESCRIPTION
Uses LM-Studio to generate PowerShell commands based on natural language queries.
The function can either send commands directly to the PowerShell window or copy
them to the clipboard. It leverages AI models to interpret natural language and
convert it into executable PowerShell commands.

.PARAMETER Query
The natural language description of what you want to accomplish. The AI will
convert this into an appropriate PowerShell command.

.PARAMETER Model
The LM-Studio model to use for command generation. Can be a name or partial path.
Supports -like pattern matching for model selection.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Values range from 0.0
(more focused/deterministic) to 1.0 (more creative/random).

.PARAMETER Clipboard
When specified, copies the generated command to clipboard.

.EXAMPLE
Invoke-AIPowershellCommand -Query "list all running processes" -Model "qwen"

.EXAMPLE
hint "list files modified today"
#>
function Invoke-AIPowershellCommand {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    [Alias("hint")]
    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The natural language query to generate a command for"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the AI model"
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
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy command to clipboard"
        )]
        [switch] $Clipboard,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,
        ########################################################################
        [Alias("ttl")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API requests")]
        [int] $TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "GPU offloading control (-2=Auto, -1=LM Studio decides)"
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
            HelpMessage = "Api endpoint url")]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null,
        ########################################################################
        # Use alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose "Initializing AI command generation"

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
        Microsoft.PowerShell.Utility\Write-Verbose "Generating PowerShell command for query: $Query"

        # Copy matching parameters to invoke transformation
        $invocationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Invoke-LLMTextTransformation"

        $invocationParams.Text = $Query
        $invocationParams.Instructions = $commandInstructions
        $invocationParams.SetClipboard = $Clipboard

        # Get the command from the AI
        $command = GenXdev.AI\Invoke-LLMTextTransformation @invocationParams

        if ($Clipboard) {
            Microsoft.PowerShell.Utility\Write-Verbose "Command copied to clipboard"
        }
        else {
            if ($PSCmdlet.ShouldProcess("PowerShell window", "Send command")) {

                $mainWindow = GenXdev.Windows\Get-PowershellMainWindow
                if ($null -ne $mainWindow) {
                    $null = $mainWindow.SetForeground()
                }

                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard
                try {
                    ("$command".Trim().Replace("`n", " ```n")) | Microsoft.PowerShell.Management\Set-Clipboard

                    GenXdev.Windows\Send-Key "^v"

                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {

                    $oldClipboard | Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }
    }

    end {
    }
}
################################################################################