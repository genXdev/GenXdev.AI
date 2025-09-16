<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Show-GenXdevScriptErrorFixInIde.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.270.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Executes a script block and analyzes errors using AI to generate fixes in IDE.

.DESCRIPTION
This function executes a provided script block, captures any errors that occur,
and analyzes them using AI language models to generate intelligent fix prompts.
The function then opens Visual Studio Code with the identified problematic files
and provides AI-generated suggestions through GitHub Copilot to assist in
resolving the issues.

.PARAMETER Script
The script block to execute and analyze for errors.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER LLMQueryType
The type of LLM query to perform for error analysis.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER Functions
Array of function definitions.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER DontAddThoughtsToHistory
Include model's thoughts in output.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys.

.EXAMPLE
Show-GenXdevScriptErrorFixInIde -Script { Get-ChildItem -Path "NonExistentPath" }

.EXAMPLE
letsfixthis { Import-Module "NonExistentModule" }
###############################################################################>
function Show-GenXdevScriptErrorFixInIde {

    [CmdletBinding()]
    [Alias('letsfixthis')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'The script to execute and analyze for errors'
        )]
        [ScriptBlock] $Script,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The type of LLM query'
        )]
        [ValidateSet(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )]
        [string] $LLMQueryType = 'Coding',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                'offloaded to GPU. If a number between 0 and 1, ' +
                'that fraction of layers will be offloaded to the ' +
                'GPU. -1 = LM Studio will decide how much to ' +
                'offload to the GPU. -2 = Auto')
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use as ' +
                'tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false
        )]
        [Alias('NoConfirmationFor')]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the LM Studio window'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $DontAddThoughtsToHistory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds
        ###############################################################################
    )

    begin {

        # get ai prompt information for script execution error analysis
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Retrieving AI prompt information for script error analysis'
        )

        $llmPromptInfo = GenXdev.AI\Get-ScriptExecutionErrorFixPrompt `
            @PSBoundParameters
    }

    process {

        # define function to process each issue identified by the ai
        function processIssue($issue) {

            # copy parameters from this function to the llm prompt function
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Copying parameters for LLM prompt function'
            )

            $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Get-ScriptExecutionErrorFixPrompt'

            # ensure visual studio code is installed before proceeding
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Ensuring Visual Studio Code installation'
            )

            $null = GenXdev.Coding\EnsureVSCodeInstallation

            # open vscode with the root module directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Opening Visual Studio Code with root module directory'
            )

            code (GenXdev.FileSystem\Expand-Path `
                    "$PSScriptRoot\..\..\..\..\..\")

            # wait for vscode to fully load and become responsive
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Waiting for Visual Studio Code to fully load'
            )

            Microsoft.PowerShell.Utility\Start-Sleep 2

            # copy identical parameters between functions
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Copying identical parameters for Send-Key function'
            )

            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -FunctionName 'GenXdev.Windows\Send-Key' `
                -BoundParameters $PSBoundParameters `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -ErrorAction SilentlyContinue)

            # send keystrokes to open copilot chat and clear any existing content
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Sending keystrokes to open Copilot chat and clear content'
            )

            GenXdev.Windows\Send-Key @params -KeysToSend @(
                "^``", "^``", '^+i', '^n', '^a', '{DELETE}'
            )

            # check if issue has specific files to open or general error handling
            if ((-not $issue.Files) -or ($issue.Files.Count -eq 0)) {

                # preserve current clipboard content to restore later
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Preserving current clipboard content'
                )

                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard

                try {

                    # copy the ai-generated prompt to system clipboard
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Copying AI-generated prompt to system clipboard'
                    )

                    $issue.Prompt | `
                            Microsoft.PowerShell.Management\Set-Clipboard

                    # copy identical parameters between functions
                    $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -FunctionName 'GenXdev.Windows\Send-Key' `
                        -BoundParameters $PSBoundParameters `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local -ErrorAction SilentlyContinue)

                    # paste prompt into copilot chat and execute
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Pasting prompt into Copilot chat and executing'
                    )

                    GenXdev.Windows\Send-Key @params -KeysToSend @(
                        "^``", "^``", '^+i', '^n','^a', '{DELETE}', '^%b',
                        '^+%{F12}', '{ENTER}', '^v', '{ENTER}', '^{ENTER}', "^``"
                    )

                    # allow time for copilot to process the request
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Waiting for Copilot to process the request'
                    )

                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {

                    # restore the original clipboard content
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Restoring original clipboard content'
                    )

                    $oldClipboard | `
                            Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
            else {

                # iterate through each file mentioned in the issue
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing $($issue.Files.Count) files mentioned in issue"
                )

                $issue.Files | `
                        Microsoft.PowerShell.Core\ForEach-Object {

                        # copy parameters for opening files in ide
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Copying parameters for opening file: $($PSItem.Path)"
                        )

                        $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                            -BoundParameters $PSBoundParameters `
                            -FunctionName 'GenXdev.Coding\Open-SourceFileInIde'

                        # set the path to the current problematic file
                        $invocationArgs.Path = $PSItem.Path

                        # if line number is provided include it in arguments
                        if ($PSItem.LineNumber -is [int]) {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Setting line number: $($PSItem.LineNumber)"
                            )

                            $invocationArgs.LineNo = $PSItem.LineNumber
                        }

                        # enable code mode for ide integration
                        $invocationArgs.Code = $true

                        # prepare key sequences for opening files in vscode
                        $invocationArgs.KeysToSend = @(
                            @('{ESCAPE}', '^+%{F12}')
                        )

                        # open the source file in the ide with specified parameters
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Opening source file in IDE'
                        )

                        GenXdev.Coding\Open-SourceFileInIde @invocationArgs
                    }

                # preserve current clipboard content to restore later
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Preserving current clipboard content'
                )

                $oldClipboard = Microsoft.PowerShell.Management\Get-Clipboard

                try {

                    # copy the ai-generated prompt to system clipboard
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Copying AI-generated prompt to system clipboard'
                    )

                    $issue.Prompt | `
                            Microsoft.PowerShell.Management\Set-Clipboard

                    # copy identical parameters between functions
                    $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -FunctionName 'GenXdev.Windows\Send-Key' `
                        -BoundParameters $PSBoundParameters `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local -ErrorAction SilentlyContinue)

                    # paste prompt into copilot chat and execute
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Pasting prompt into Copilot chat and executing'
                    )

                    GenXdev.Windows\Send-Key @params -KeysToSend @(
                        '^v', '{ENTER}', '^{ENTER}',"^``"
                    )

                    # allow time for copilot to process the request
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Waiting for Copilot to process the request'
                    )

                    Microsoft.PowerShell.Utility\Start-Sleep 2
                }
                finally {

                    # restore the original clipboard content
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Restoring original clipboard content'
                    )

                    $oldClipboard | `
                            Microsoft.PowerShell.Management\Set-Clipboard
                }
            }
        }

        # process each issue identified by the ai language model
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Processing issues identified by AI language model'
        )

        $null = $llmpromptInfo | `
                Microsoft.PowerShell.Core\ForEach-Object {

                # check if there is standard output to return immediately
                if ($PSItem.StandardOutput -and
                ($PSItem.StandardOutput.Count -gt 0)) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Returning standard output immediately'
                    )

                    return $PSItem.StandardOutput
                }

                # loop until user chooses to stop processing issues
                while ($true) {

                    # process the current issue with ai assistance
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Processing current issue with AI assistance'
                    )

                    processIssue -issue $PSItem

                    # prompt user for next action using choice dialog
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Prompting user for next action'
                    )

                    switch ($host.ui.PromptForChoice(
                            'Make a choice',
                            'What to do next?',
                            @('&Stop', 'Redo &Last'),
                            0)) {

                        # user chose to stop processing
                        0 {
                            Microsoft.PowerShell.Utility\Write-Verbose (
                                'User chose to stop processing'
                            )

                            throw 'Stopped'
                            return
                        }
                    }
                }
            }
    }

    end {

    }
}
###############################################################################