<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : New-LLMTextChat.ps1
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
Starts an interactive text chat session with AI capabilities.

.DESCRIPTION
Initiates an interactive chat session with AI capabilities, allowing users to add
or remove PowerShell functions during the conversation and execute PowerShell
commands. This function provides a comprehensive interface for AI-powered
conversations with extensive tool integration and customization options.

.PARAMETER Query
Initial text to send to the model.

.PARAMETER Instructions
System instructions to provide context to the AI model.

.PARAMETER Attachments
Array of file paths to attach to the conversation.

.PARAMETER Temperature
Controls randomness in responses (0.0-1.0). Lower values are more deterministic.

.PARAMETER ImageDetail
Level of detail for image generation (low, medium, high).

.PARAMETER ResponseFormat
A JSON schema for the requested output format.

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

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools.

.PARAMETER MarkupBlocksTypeFilter
Will only output markup blocks of the specified types.

.PARAMETER IncludeThoughts
Include model's thoughts in output.

.PARAMETER DontAddThoughtsToHistory
Include model's thoughts in output.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER NoShowWindow
Switch to not show the LM Studio window.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER OutputMarkdownBlocksOnly
Will only output markup block responses.

.PARAMETER ChatOnce
Used internally, to only invoke chat mode once after the llm invocation.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.PARAMETER NoLMStudioInitialize
Switch to skip LM-Studio initialization (used when already called by parent function).

.PARAMETER Unload
Unloads the specified model instead of loading it.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests.

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard.

.PARAMETER NoBorders
Removes the borders of the window.

.PARAMETER Width
The initial width of the window.

.PARAMETER Height
The initial height of the window.

.PARAMETER X
The initial X position of the window.

.PARAMETER Y
The initial Y position of the window.

.PARAMETER Left
Place window on the left side of the screen.

.PARAMETER Right
Place window on the right side of the screen.

.PARAMETER Top
Place window on the top side of the screen.

.PARAMETER Bottom
Place window on the bottom side of the screen.

.PARAMETER Centered
Place window in the center of the screen.

.PARAMETER Fullscreen
Maximize the window.

.PARAMETER RestoreFocus
Restore PowerShell window focus.

.PARAMETER SideBySide
Will either set the window fullscreen on a different monitor than Powershell, or
side by side with Powershell on the same monitor.

.PARAMETER FocusWindow
Focus the window after opening.

.PARAMETER SetForeground
Set the window to foreground after opening.

.PARAMETER Maximize
Maximize the window after positioning.

.PARAMETER KeysToSend
Keystrokes to send to the Window, see documentation for cmdlet
GenXdev.Windows\Send-Key.

.EXAMPLE
New-LLMTextChat -Model "qwen2.5-14b-instruct" -Temperature 0.7 -MaxToken 4096 `
    -Instructions "You are a helpful AI assistant"

.EXAMPLE
llmchat "Tell me a joke" -Speak -IncludeThoughts
#>
###############################################################################
# store exposed cmdlets at module level instead of global scope
$script:LMStudioExposedCmdlets = $null

###############################################################################
function New-LLMTextChat {

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('llmchat')]

    param(
        #######################################################################
        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipeline = $true,
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Query text to send to the model'
        )]
        [AllowEmptyString()]
        [string] $Query = '',
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'System instructions for the model'
        )]
        [string] $Instructions,
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'A JSON schema for the requested output format'
        )]
        [string] $ResponseFormat = $null,
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
        [string] $LLMQueryType = 'ToolUse',
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
        [int] $Gpu = -1,
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
            HelpMessage = 'Array of PowerShell command definitions to use as tools'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will only output markup blocks of the specified types'
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @('json', 'powershell', 'C#', 'python', 'javascript', 'typescript', 'html', 'css', 'yaml', 'xml', 'bash'),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Time-to-live in seconds for models loaded via API requests'
        )]
        [int] $TTLSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
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
            HelpMessage = 'Switch to not show the LM Studio window.'
        )]
        [switch] $NoShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch] $Force,
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
            HelpMessage = 'Will only output markup block responses'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        #######################################################################
        [Parameter(
            DontShow = $true,
            Mandatory = $false,
            HelpMessage = 'Used internally, to only invoke chat mode once after the llm invocation'
        )]
        [switch] $ChatOnce,
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
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip LM-Studio initialization (used when ' +
                'already called by parent function)')
        )]
        [switch] $NoLMStudioInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unloads the specified model instead of loading it'
        )]
        [switch] $Unload,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [Alias('fs')]
        [switch]$FullScreen,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a different ' +
                'monitor than Powershell, or side by side with Powershell on the ' +
                'same monitor')
        )]
        [Alias('sbs')]
        [switch]$SideBySide,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Alias('NoConfirmationFor')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Names of tool functions that should not require confirmation')]
        [string[]] $NoConfirmationToolFunctionNames,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum length for tool callback responses')]
        [int] $MaxToolcallBackLength,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio generation'
        )]
        $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation'
        )]
        $TemperatureResponse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language for the model or output'
        )]
        $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use'
        )]
        $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress output'
        )]
        $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing'
        )]
        $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio processing'
        )]
        $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation'
        )]
        $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering'
        )]
        $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering'
        )]
        $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection'
        )]
        $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output'
        )]
        $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output for thoughts'
        )]
        $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation)'
        )]
        $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture'
        )]
        $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable context usage'
        )]
        $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy'
        )]
        $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses'
        )]
        $OnlyResponses
        #######################################################################
    )

    begin {

        $ShowWindow = (-not $NoShowWindow) -and (-not (GenXdev.Helpers\Test-UnattendedMode -CallersInvocation $MyInvocation))

        # determine if instructions need updating
        $updateInstructions = [string]::IsNullOrWhiteSpace($Instructions)

        # initialize exposed cmdlets if not provided
        if ($null -eq $ExposedCmdLets) {

            # use cached cmdlets if continuing last session
            if ($ContinueLast -and $script:LMStudioExposedCmdlets) {

                $ExposedCmdLets = $script:LMStudioExposedCmdlets
            }
            else {

                # flag that instructions need updating
                $updateInstructions = $true

                # initialize default allowed PowerShell cmdlets
                $ExposedCmdLets = @(
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Get-ChildItem'
                        AllowedParams = @('LiteralPath=string', 'Recurse=boolean', 'Filter=array', 'Include=array', 'Exclude=array', 'Force')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = 'GenXdev.FileSystem\Find-Item'
                        AllowedParams = @('SearchMask', 'Pattern', 'PassThru')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Get-Content'
                        AllowedParams = @('LiteralPath=string')
                        OutputText    = $false
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
                        Name                                 = 'GenXdev.AI\Approve-NewTextFileContent'
                        AllowedParams                        = @('ContentPath', 'NewContent')
                        OutputText                           = $false
                        Confirm                              = $true
                        JsonDepth                            = 2
                        DontShowDuringConfirmationParamNames = @('NewContent')
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
                        Name          = 'Microsoft.PowerShell.Utility\Invoke-RestMethod'
                        AllowedParams = @('Uri=string', 'Method=string', 'Body', 'ContentType=string', 'Method=string', 'UserAgent=string')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    },
                    @{
                        Name          = 'GenXdev.Console\Start-TextToSpeech'
                        AllowedParams = @('Lines=string')
                        OutputText    = $true
                        Confirm       = $false
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Utility\Invoke-Expression'
                        AllowedParams = @('Command=string')
                        Confirm       = $true
                        JsonDepth     = 40
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Get-Clipboard'
                        AllowedParams = @()
                        OutputText    = $true
                        Confirm       = $false
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Set-Clipboard'
                        AllowedParams = @('Value=string')
                        OutputText    = $true
                        Confirm       = $false
                    }
                );

                # convert cmdlets to function definition objects
                $functionInfoObj = (GenXdev.AI\ConvertTo-LMStudioFunctionDefinition -ExposedCmdLets:$ExposedCmdLets)

                # remove callback functions from each function definition
                $functionInfoObj |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        $null = $_.function.Remove('callback')
                    }
            }
        }

        # update instructions with ai assistant context if needed
        if ($updateInstructions) {

            # ensure instructions string is not null
            if ([string]::IsNullOrWhiteSpace($Instructions)) {

                $Instructions = ''
            }

            # append comprehensive ai assistant instructions
            $Instructions = @"
$Instructions

**You are an interactive AI assistant. Your primary functions are to:**
1. **Ask and Answer Questions:** Engage with users to understand their queries and provide relevant responses.
2. **Invoke Tools:** Proactively suggest the use of tools or directly invoke them if you are confident they can accomplish a task.

**Key Guidelines:**
- **Tool Usage:** You don't need to use all available tool parameters, and some parameters might be mutually exclusive. Determine the best parameters to use based on the task at hand.
- **PowerShell Constraints:**
  - **Avoid PowerShell Features:** Do not rely on PowerShell features like expanding string embeddings (e.g., `$()`) or any similar methods. Invoke-Expression being the exception of course. Parameter checking is strict.
  - **No Variables/Expressions:** Do not use PowerShell variables or expressions under any circumstances.

**Multiple Tool Invocations:**
- Feel free to invoke multiple tools within a single response if necessary.

**Safety Measures:**
- Do not worry about potential harm when invoking these tools. They are either unable to make changes or will prompt the user to confirm any actions. Users are aware of the possible consequences due to the nature of the PowerShell environment and the ability to enforce confirmation for any exposed tool.
"@;

            # trim any excess whitespace from instructions
            $Instructions = $Instructions.Trim()
        }

        # cache exposed cmdlets if session caching is enabled
        if (-not $NoSessionCaching) {

            $script:LMStudioExposedCmdlets = $ExposedCmdLets
        }

        # output verbose message about initialized cmdlets
        Microsoft.PowerShell.Utility\Write-Verbose "Initialized with $($ExposedCmdLets.Count) exposed cmdlets"

        # clean up force parameter from bound parameters
        if ($PSBoundParameters.ContainsKey('Force')) {

            $null = $PSBoundParameters.Remove('Force')
            $Force = $false
        }


        # ensure maxtoken parameter is present in bound parameters
        if (-not $PSBoundParameters.ContainsKey('MaxToken')) {

            $null = $PSBoundParameters.Add('MaxToken', $MaxToken)
        }

        # clean up chatonce parameter from bound parameters
        if ($PSBoundParameters.ContainsKey('ChatOnce')) {

            $null = $PSBoundParameters.Remove('ChatOnce')
        }

        # ensure exposedcmdlets parameter is present in bound parameters
        if (-not $PSBoundParameters.ContainsKey('ExposedCmdLets')) {

            $null = $PSBoundParameters.Add('ExposedCmdLets', $ExposedCmdLets);
        }
    }


    process {

        # output verbose message about starting chat interaction
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting chat interaction loop'

        # helper function to display available tool functions
        function Show-ToolFunction {

            # internal function to extract cmdlet name from full name
            function FixName([string] $Name) {

                # find the backslash separator index
                $index = $Name.IndexOf('\')

                # return substring after backslash if found, otherwise return original
                if ($index -gt 0) {
                    return $Name.Substring($index + 1)
                }
                return $Name;
            }

            # internal function to build parameter string for display
            function GetParamString([object] $Cmdlet) {

                # return empty string if no allowed parameters
                if ($null -eq $Cmdlet.AllowedParams) { return '' }

                # extract parameter names from allowed parameters array
                $params = $Cmdlet.AllowedParams |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        $a = $_

                        # extract parameter name before equals sign if present
                        if ($a -match '^(.+?)=') {
                            $a = $matches[1]
                        }
                        $a
                    }

                # return formatted parameter list
                return "($(($params -join ',')))"
            }

            # display tool functions if any are available
            if ($ExposedCmdLets.Count -gt 0) {

                # output header message for active tool functions
                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                    "Tool functions now active ($($ExposedCmdLets.Count)) ->"

                # format and display each exposed cmdlet with parameters
                $( ($ExposedCmdLets |
                            Microsoft.PowerShell.Core\ForEach-Object {

                                # get simplified name and parameter string
                                $Name = FixName($_.Name)
                                $params = GetParamString($_)

                                # add asterisk for functions requiring confirmation
                                if ($_.Confirm) {
                                    "$Name$params"
                                }
                                else {
                                    "$Name*$params"
                                }
                            } |
                            Microsoft.PowerShell.Utility\Select-Object -Unique) -join ', ') |
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green
            }
        }

        # initialize chat state variable
        $script:isFirst = -not $ContinueLast

        # display available tools to user
        Show-ToolFunction

        # main chat loop initialization
        $shouldStop = $false

        # enter main chat interaction loop
        while (-not $shouldStop) {

            # initialize question variable
            $question = ''

            # get user input if not in chat-once mode and no query provided
            if (-not $ChatOnce -and [string]::IsNullOrWhiteSpace($Query)) {

                # display prompt character to user
                [Console]::Write('> ');

                # configure psreadline for history prediction
                try {
                    $null = PSReadLine\Set-PSReadLineOption -PredictionSource History
                } catch { }

                # read user input line using psreadline
                $question = PSReadLine\PSConsoleHostReadLine

                # ensure question is not null
                if ($null -eq $question) {
                    $question = [string]::Empty
                }
            }
            else {

                # use provided query if available
                if (-not [string]::IsNullOrWhiteSpace($Query)) {

                    # set question to query and clear query variable
                    $question = $Query
                    $Query = [string]::Empty

                    # echo the question to console
                    [Console]::WriteLine("> $question");
                }
            }

            # output verbose message about processing query
            Microsoft.PowerShell.Utility\Write-Verbose "Processing query: $question"

            # update bound parameters for llm invocation
            $PSBoundParameters['ContinueLast'] = (-not $script:isFirst);
            $PSBoundParameters['Query'] = $question;
            $PSBoundParameters['ExposedCmdLets'] = $ExposedCmdLets;

            # copy parameters for llm query invocation
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Invoke-LLMQuery' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            # ensure chatonce is disabled for recursive calls
            $invocationArguments.ChatOnce = $false
            $invocationArguments.ErrorAction = 'SilentlyContinue'
            $invocationArguments.NoLMStudioInitialize = (-not $script:IsFirst) -and (-not $NoLMStudioInitialize)
            $invocationArguments.ShowWindow = ($script:IsFirst) -and (-not $NoShowWindow)
            if (-not $PSBoundParameters.ContainsKey('Monitor')) {
                $invocationArguments.Monitor = -2
            }

            # invoke llm query and process each result (suppress verbose output)
            @(GenXdev.AI\Invoke-LLMQuery @invocationArguments 4>$null) |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # store current result
                    $result = $_

                    # skip empty or null results
                    if (($null -eq $result) -or ([string]::IsNullOrEmpty("$result".trim()))) {
                        return
                    }

                    # mark that this is no longer the first interaction
                    $script:isFirst = $false

                    # output result based on mode
                    if ($ChatOnce) {

                        # return result object for chat-once mode
                        Microsoft.PowerShell.Utility\Write-Output $result
                    }
                    else {

                        # display result as host output for interactive mode
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow "$result"
                    }
                }

            # determine if chat loop should stop
            $shouldStop = $ChatOnce
        }
    }

    end {

        # output verbose message about chat session completion
        Microsoft.PowerShell.Utility\Write-Verbose 'Chat session completed'
    }
}
###############################################################################