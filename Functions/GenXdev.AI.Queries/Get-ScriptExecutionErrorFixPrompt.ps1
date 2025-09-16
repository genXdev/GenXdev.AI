<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Get-ScriptExecutionErrorFixPrompt.ps1
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
Captures error messages from various streams and uses LLM to suggest fixes.

.DESCRIPTION
This cmdlet captures error messages from various PowerShell streams (pipeline
input, verbose, information, error, and warning) and formulates a structured
prompt for an LLM to analyze and suggest fixes. It then invokes the LLM query
and returns the suggested solution.

.PARAMETER Script
The script to execute and analyze for errors.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER ShowWindow
Show the LM Studio window.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER DontAddThoughtsToHistory
Include model's thoughts in output.

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

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If
'max', all layers are offloaded to GPU. If a number between 0 and 1, that
fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
how much to offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
$errorInfo = Get-ScriptExecutionErrorFixPrompt -Script {
    My-ScriptThatFails
} -Model "*70b*"

Write-Host $errorInfo

.EXAMPLE
getfixprompt { Get-ChildItem -NotExistingParameter }
###############################################################################>

###############################################################################
function Get-ScriptExecutionErrorFixPrompt {

    [CmdletBinding()]
    [Alias('getfixprompt')]
    [OutputType([System.Object[]])]

    param (
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'The script to execute and analyze for errors'
        )]
        [ScriptBlock] $Script,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        #######################################################################
        [Parameter(
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
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        #######################################################################
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
        [int]$Gpu = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of PowerShell command definitions to use as tools'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of command names that don't require confirmation"
        )]
        [Alias('NoConfirmationFor')]
        [string[]]
        $NoConfirmationToolFunctionNames = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the LM Studio window'
        )]
        [switch] $ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $DontAddThoughtsToHistory,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Attachments to include in the LLM query.'
        )]
        $Attachments,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Level of image detail for LLM query.'
        )]
        $ImageDetail,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Time-to-live in seconds for the LLM query.'
        )]
        $TTLSeconds,
        #######################################################################
        ###############################################################################
        [Alias('m','mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Monitor to use for LLM Studio window.'
        )]
        $Monitor,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Width of the LLM Studio window.'
        )]
        $Width,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Height of the LLM Studio window.'
        )]
        $Height,
        #######################################################################
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys.'
        )]
        $SendKeyDelayMilliSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Include model thoughts in the LLM response.'
        )]
        $IncludeThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Output only markup blocks from the LLM response.'
        )]
        $OutputMarkdownBlocksOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for markup block types in the LLM response.'
        )]
        $MarkupBlocksTypeFilter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Run chat only once for the LLM query.'
        )]
        $ChatOnce,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not initialize LM Studio.'
        )]
        $NoLMStudioInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unload LM Studio after operation.'
        )]
        $Unload,
        #######################################################################
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not show window borders.'
        )]
        $NoBorders,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: left.'
        )]
        $Left,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: right.'
        )]
        $Right,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: bottom.'
        )]
        $Bottom,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window.'
        )]
        $Centered,
        #######################################################################
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window to fullscreen.'
        )]
        $FullScreen,
        #######################################################################
        ###############################################################################
        [Alias('rf','bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to previous window.'
        )]
        $RestoreFocus,
        #######################################################################
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show LLM Studio and script side by side.'
        )]
        $SideBySide,
        #######################################################################
        ###############################################################################
        [Alias('fw','focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the LLM Studio window.'
        )]
        $FocusWindow,
        #######################################################################
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set LLM Studio window to foreground.'
        )]
        $SetForeground,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the LLM Studio window.'
        )]
        $Maximize,
        #######################################################################
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key to LLM Studio.'
        )]
        $SendKeyEscape,
        #######################################################################
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys.'
        )]
        $SendKeyHoldKeyboardFocus,
        #######################################################################
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys.'
        )]
        $SendKeyUseShiftEnter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum tool call back length for LLM query.'
        )]
        $MaxToolcallBackLength,
        #######################################################################

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio generation.'
        )]
        $AudioTemperature,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation.'
        )]
        $TemperatureResponse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language for LLM query.'
        )]
        $Language,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use.'
        )]
        $CpuThreads,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress output.'
        )]
        $SuppressRegex,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for LLM query.'
        )]
        $AudioContextSize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio processing.'
        )]
        $SilenceThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for LLM output.'
        )]
        $LengthPenalty,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for LLM output.'
        )]
        $EntropyThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for LLM output.'
        )]
        $LogProbThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio processing.'
        )]
        $NoSpeechThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not speak audio output.'
        )]
        $DontSpeak,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not speak model thoughts.'
        )]
        $DontSpeakThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX for audio output.'
        )]
        $NoVOX,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture.'
        )]
        $UseDesktopAudioCapture,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not use context for LLM query.'
        )]
        $NoContext,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy.'
        )]
        $WithBeamSearchSamplingStrategy,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses from LLM.'
        )]
        $OnlyResponses
        #######################################################################
    )

    begin {

        # initialize output capture builders for all powershell streams
        $verboseOutput = [System.Text.StringBuilder]::new()

        $errorOutput = [System.Text.StringBuilder]::new()

        $warningOutput = [System.Text.StringBuilder]::new()

        $informationOutput = [System.Text.StringBuilder]::new()

        $standardOutput = [System.Text.StringBuilder]::new()

        # store original preference variables for later restoration
        $oldPreferences = @{
            Verbose     = $VerbosePreference
            Error       = $ErrorActionPreference
            Warning     = $WarningPreference
            Information = $InformationPreference
        }

        # set all preferences to continue for capturing all output streams
        $VerbosePreference = 'Continue'

        $ErrorActionPreference = 'Stop'

        $WarningPreference = 'Continue'

        $InformationPreference = 'Continue'

        # register event handlers for capturing output from all streams
        $null = Microsoft.PowerShell.Utility\Register-EngineEvent `
            -SourceIdentifier 'Verbose' `
            -Action {
            param($Message)
            $null = $verboseOutput.AppendLine($Message)
        }

        $null = Microsoft.PowerShell.Utility\Register-EngineEvent `
            -SourceIdentifier 'Error' `
            -Action {
            param($Message)
            $null = $errorOutput.AppendLine($Message)
        }

        $null = Microsoft.PowerShell.Utility\Register-EngineEvent `
            -SourceIdentifier 'Warning' `
            -Action {
            param($Message)
            $null = $warningOutput.AppendLine($Message)
        }

        $null = Microsoft.PowerShell.Utility\Register-EngineEvent `
            -SourceIdentifier 'Information' `
            -Action {
            param($Message)
            $null = $informationOutput.AppendLine($Message)
        }

        # initialize response schema for structured LLM output
        $responseFormat = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'error_resolution_response'
                strict = $true
                schema = @{
                    type  = 'array'
                    items = @{
                        type       = 'object'
                        properties = @{
                            Files  = @{
                                type  = 'array'
                                items = @{
                                    type       = 'object'
                                    properties = @{
                                        Path       = @{ type = 'string' }
                                        LineNumber = @{ type = 'integer' }
                                    }
                                    required   = @('Path')
                                }
                            }
                            Prompt = @{ type = 'string' }
                        }
                        required   = @('Files', 'Prompt')
                    }
                }
            }
        } |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # initialize exposed cmdlets if not provided
        if (-not $ExposedCmdLets) {

            $ExposedCmdLets = @(
                @{
                    Name          = 'Microsoft.PowerShell.Management\Get-ChildItem'
                    AllowedParams = @('LiteralPath=string')
                    ForcedParams  = @(@{
                            Name  = 'Force'
                            Value = $true
                        })
                    OutputText    = $true
                    Confirm       = $false
                    JsonDepth     = 3
                },
                @{
                    Name          = 'Microsoft.PowerShell.Management\Get-Content'
                    AllowedParams = @('LiteralPath=string')
                    OutputText    = $true
                    Confirm       = $false
                    JsonDepth     = 2
                },
                @{
                    Name          = 'CimCmdlets\Get-CimInstance'
                    AllowedParams = @('Query=string', 'ClassName=string')
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 5
                },
                @{
                    Name          = 'Microsoft.PowerShell.Utility\Invoke-WebRequest'
                    AllowedParams = @(
                        'Uri=string',
                        'Method=string',
                        'Body',
                        'ContentType=string',
                        'Method=string',
                        'UserAgent=string'
                    )
                    OutputText    = $true
                    Confirm       = $false
                    JsonDepth     = 6
                },
                @{
                    Name          = ('Microsoft.PowerShell.Utility\' +
                        'Invoke-RestMethod')
                    AllowedParams = @('Uri=string', 'Method=string',
                        'Body', 'ContentType=string',
                        'Method=string', 'UserAgent=string')
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 10
                },
                @{
                    Name          = 'Microsoft.PowerShell.Management\Get-Clipboard'
                    AllowedParams = @()
                    OutputText    = $true
                    Confirm       = $false
                },
                @{
                    Name          = 'Microsoft.PowerShell.Utility\Get-Variable'
                    AllowedParams = @('Name=string', 'Scope=string',
                        'ValueOnly=boolean')
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 3
                }
            );
        }
    }

    process {

        # initialize object array to capture script output
        $object = @()

        try {

            # execute the provided script and capture its output
            $object = & $Script
        }
        catch {

            # capture exception details for error analysis
            $exception = $_.Exception

            $exceptionDetails = @()

            $exceptionDetails += ('Exception Type: ' +
                "$($exception.GetType().FullName)")

            $exceptionDetails += "Message: $($exception.Message)"

            # walk through inner exceptions to capture full error chain
            while ($exception.InnerException) {

                if ($exception.InnerException) {

                    $exceptionDetails += ('Inner Exception: ' +
                        "$($exception.InnerException.Message)")
                }

                if ($exception.StackTrace) {

                    $exceptionDetails += ('Stack Trace: ' +
                        "$($exception.StackTrace)")
                }

                $exception = $exception.InnerException
            }

            # append detailed exception information to error output
            $null = $errorOutput.AppendLine($exceptionDetails -join "`n")
        }

        # capture each output item as string for analysis
        foreach ($item in $object) {

            $null = $standardOutput.AppendLine(($item |
                        Microsoft.PowerShell.Utility\Out-String))
        }
    }

    end {

        try {

            # return successful output if no errors occurred
            if ($errorOutput.Length -eq 0) {

                Microsoft.PowerShell.Utility\Write-Verbose ('No errors ' +
                    'detected during script execution')

                return @(@{
                        StandardOutput = @($object)
                    });
            }

            try {

                # output verbose message about starting llm analysis
                Microsoft.PowerShell.Utility\Write-Verbose ('Analyzing ' +
                    'captured errors using LLM')

                # create instructions for the llm to analyze errors
                $instructions = @'
Your job is to analyze all output of a PowerShell script execution
and execute the following tasks:
- Identify the numbers of unique problems
- foreach unique problem:
  + Parse unique filenames with linenumber and output these so that these files can be
    changed to resolve the error
  + Generate a suffisticated highly efficient LLM prompt that describes
    the larger view of the problem.
    DONT COPY this prompt, but make a first line assesement of the problem
    and create a prompt for a larger model to use as instructions to resolve
    the problem.
    (the LLM will have access to the files which names you output)
- Ensure your response is concise and does not repeat information.
'@

                # append exposed cmdlets instructions if available
                if ($ExposedCmdLets -and $ExposedCmdLets.Count) {

                    $instructions += @"
- You are allowed to use the following PowerShell cmdlets:
    + $($ExposedCmdLets.Name -join ', ')
    If needed use these tools to turn assumptions into facts
    during your analyses of the problem in this Powershell
    environment you now have live access to and suggest fixes.
    Keep in mind you can inspect file contents, environment variables,
    websites and webapi's, clipboard contents, etc.
    You are an experienced senior debugger, so you know what to do.
"@
                }

                # construct comprehensive prompt with all captured output
                $prompt = @"
Current directory: $($PWD.Path)
--
Current time: $(Microsoft.PowerShell.Utility\Get-Date)
--
Powershell commandline that was executed:
$Script
--
Captured standardoutput:
--
$($standardOutput.ToString())
--
Captured verbose output:
--
$($verboseOutput.ToString())
--
Captured error output:
--
$($errorOutput.ToString())
--
Captured warning output:
--
$($warningOutput.ToString())
--
Captured information output:
--
$($informationOutput.ToString())
"@

                # copy parameters for llm invocation
                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\Invoke-LLMQuery'

                # set specific parameters for the llm query
                $invocationArgs.Query = $prompt

                $invocationArgs.ExposedCmdLets = $ExposedCmdLets

                $invocationArgs.Instructions = $instructions

                $invocationArgs.ResponseFormat = $responseFormat

                # output verbose message about invoking llm
                Microsoft.PowerShell.Utility\Write-Verbose ('Invoking LLM ' +
                    'query for error analysis')

                # invoke llm and convert response from json
                GenXdev.AI\Invoke-LLMQuery @invocationArgs |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json
            }
            catch {

                # log error during processing
                Microsoft.PowerShell.Utility\Write-Error ('Error while ' +
                    "processing: $_")

                throw "Error while processing: $_"
            }
        }
        finally {

            # cleanup event handlers to prevent memory leaks
            $null = Microsoft.PowerShell.Utility\Unregister-Event `
                -SourceIdentifier 'Verbose' `
                -ErrorAction SilentlyContinue

            $null = Microsoft.PowerShell.Utility\Unregister-Event `
                -SourceIdentifier 'Error' `
                -ErrorAction SilentlyContinue

            $null = Microsoft.PowerShell.Utility\Unregister-Event `
                -SourceIdentifier 'Warning' `
                -ErrorAction SilentlyContinue

            $null = Microsoft.PowerShell.Utility\Unregister-Event `
                -SourceIdentifier 'Information' `
                -ErrorAction SilentlyContinue

            # restore original preferences to avoid side effects
            $VerbosePreference = $oldPreferences.Verbose

            $ErrorActionPreference = $oldPreferences.Error

            $WarningPreference = $oldPreferences.Warning

            $InformationPreference = $oldPreferences.Information
        }
    }
}
###############################################################################