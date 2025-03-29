################################################################################
<#
.SYNOPSIS
Parses error messages and fixes them using Github Copilot in VSCode.

.DESCRIPTION
This function analyzes error messages from any input source, identifies
files that need attention, and opens them in Visual Studio Code with appropriate
Github Copilot prompts to assist in fixing the issues.

.PARAMETER Object
The input to analyze for errors. This can be error messages, log entries, or
any text containing error information.

.PARAMETER Model
The LM-Studio model to use for error analysis. Defaults to "qwen2.5-14b-instruct".

.PARAMETER ModelLMSGetIdentifier
Identifier used for getting specific model from LM Studio.

.PARAMETER Temperature
Temperature setting for response randomness (0.0-1.0).

.PARAMETER MaxToken
Maximum tokens allowed in response (-1 for default).

.PARAMETER ShowWindow
If specified, shows the LM Studio window during processing.

.PARAMETER TTLSeconds
Set a TTL (in seconds) for models loaded via API requests.

.PARAMETER Gpu
GPU offloading configuration:
- "off": GPU offloading disabled
- "max": All layers offloaded to GPU
- 0-1: Fraction of layers offloaded
- -1: LM Studio decides offloading
- -2: Auto configure

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER DontAddThoughtsToHistory
Skip including model's thoughts in output.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER Functions
Array of function definitions.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER ApiEndpoint
Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
The API key for authentication.

.EXAMPLE
Show-GenXdevScriptErrorFixInIde -Model "qwen2.5-14b-instruct" -Script {

    Run-ErrorousScript
}

.EXAMPLE
$errorOutput | letsfixthis
#>
function Show-GenXdevScriptErrorFixInIde {

    [CmdletBinding()]
    [Alias("letsfixthis")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "The script to execute and analyze for errors"
        )]
        [ScriptBlock] $Script,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
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
        $ExposedCmdLets = $null,
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
        [string] $ApiKey = $null
    )

    begin {

        $llmPromptInfo = GenXdev.AI\Get-ScriptExecutionErrorFixPrompt @PSBoundParameters
    }

    process {

        # define function to process each issue identified by the LLM
        function processIssue($issue) {

            # copy parameters from this function to the LLM prompt function
            $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-ScriptExecutionErrorFixPrompt"

            $null = GenXdev.Coding\AssureVSCodeInstallation

            code (GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\..\..\..\")

            # wait for VSCode to open
            Microsoft.PowerShell.Utility\Start-Sleep 2

            # send keystrokes to paste and execute the prompt in VSCode
            GenXdev.Windows\Send-Key -KeysToSend @("^``", "^``", "^+i", "^l", "^a", "{DELETE}")

            if ((-not $issue.Files) -or ($issue.Files.Count -eq 0)) {

                # preserve current clipboard content
                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard

                try {
                    # copy the AI prompt to clipboard
                    $issue.Prompt | Microsoft.PowerShell.Management\Set-Clipboard

                    # send keystrokes to paste and execute the prompt in VSCode
                    GenXdev.Windows\Send-Key -KeysToSend @("^v", "{ENTER}", "^{ENTER}")

                    # wait for VSCode to process the command
                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {
                    # restore the original clipboard content
                    $oldClipboard | Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
            else {

                # iterate through each file mentioned in the issue
                $issue.Files | Microsoft.PowerShell.Core\ForEach-Object {

                    # copy parameters for opening files in IDE
                    $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev.Coding\Open-SourceFileInIde"

                    # set the path to the current file
                    $invocationArgs.Path = $PSItem.Path

                    # if line number is provided, include it in arguments
                    if ($PSItem.LineNumber -is [int]) {

                        $invocationArgs.LineNo = $PSItem.LineNumber
                    }

                    # enable code mode for IDE
                    $invocationArgs.Code = $true

                    # prepare key sequences for opening files in VSCode
                    # first file gets different key sequence than subsequent files
                    $invocationArgs.KeysToSend = @(
                        @("{ESCAPE}", "^+%{F12}")
                    )

                    # open the source file in the IDE with the given parameters
                    GenXdev.Coding\Open-SourceFileInIde @invocationArgs
                }

                # preserve current clipboard content
                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard

                try
                {
                    # copy the AI prompt to clipboard
                    $issue.Prompt | Microsoft.PowerShell.Management\Set-Clipboard

                    # send keystrokes to paste and execute the prompt in VSCode
                    GenXdev.Windows\Send-Key -KeysToSend @("^v", "{ENTER}", "^{ENTER}")

                    # wait for VSCode to process the command
                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {
                    # restore the original clipboard content
                    $oldClipboard | Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }

        # process each issue identified by the LLM
        $null = $llmpromptInfo | Microsoft.PowerShell.Core\ForEach-Object {

            if ($PSItem.StandardOutput -and ($PSItem.StandardOutput.Count -gt 0)) {

                return $PSItem.StandardOutput
            }

            # loop until user chooses to stop
            while ($true) {

                # process the current issue
                processIssue -issue $PSItem

                # prompt user for next action
                switch ($host.ui.PromptForChoice(
                        "Make a choice",
                        "What to do next?",
                        @("&Stop", "Redo &Last"),
                        0)) {
                    0 { throw "Stopped"; return }
                }
            }
        }
    }

    end {
    }
}
################################################################################
