<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioTextEmbedding.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Gets text embeddings from LM Studio model.

.DESCRIPTION
Gets text embeddings for the provided text using LM Studio's API. Can work with
both local and remote LM Studio instances. Handles model initialization and API
communication for converting text into numerical vector representations.

.PARAMETER Text
The text to get embeddings for. Can be a single string or an array of strings.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER TTLSeconds
The time-to-live in seconds for cached AI responses.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER LLMQueryType
The type of LLM query for optimal model selection.

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard.

.PARAMETER Width
The initial width of the window.

.PARAMETER Height
The initial height of the window.

.PARAMETER X
The initial X position of the window.

.PARAMETER Y
The initial Y position of the window.

.PARAMETER KeysToSend
Keystrokes to send to the Window, see documentation for cmdlet
GenXdev.Windows\Send-Key.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER Force
Force LM Studio restart before processing.

.PARAMETER Unload
Unload the specified model instead of loading it.

.PARAMETER NoBorders
Remove the borders of the window.

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
Set the window fullscreen on a different monitor than Powershell, or side by
side with Powershell on the same monitor.

.PARAMETER FocusWindow
Focus the window after opening.

.PARAMETER SetForeground
Set the window to foreground after opening.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.PARAMETER NoLMStudioInitialize
Switch to skip LM-Studio initialization (used when already called by parent function).

.EXAMPLE
Get-LMStudioTextEmbedding -Text "Hello world" -Model "llama2" -ShowWindow

.EXAMPLE
"Sample text" | embed-text -TTLSeconds 3600
#>
function Get-LMStudioTextEmbedding {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Text to get embeddings for',
            ValueFromPipeline = $true
        )]
        [object] $InputObject,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The time-to-live in seconds for cached AI responses'
        )]
        [int] $TTLSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
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
        [string] $LLMQueryType = 'SimpleIntelligence',
        ########################################################################
        [Alias('m', 'mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [int] $Monitor,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the LM Studio window')]
        [switch] $ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unloads the specified model instead of loading it'
        )]
        [switch]$Unload,
        ########################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [switch] $NoBorders,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [Alias('fs')]
        [switch]$FullScreen,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a different ' +
                'monitor than Powershell, or side by side with Powershell on the ' +
                'same monitor')
        )]
        [Alias('sbs')]
        [switch]$SideBySide,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore the window to normal state after positioning'
        )]
        [switch] $SetRestored,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
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
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds
        ###################################################################
    )

    begin {

        # write verbose message about starting embedding process
        Microsoft.PowerShell.Utility\Write-Verbose ('Starting text embedding ' +
            "process with model: $Model")

        # check if using local endpoint configuration
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains('localhost') -or $ApiEndpoint.Contains('127.0.0.1')) {

            # prepare parameters for model initialization
            $initParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # handle force parameter to avoid conflicts during initialization
            if ($PSBoundParameters.ContainsKey('Force')) {

                $null = $PSBoundParameters.Remove('Force')

                $Force = $false
            }

            # initialize the lm studio model and retrieve identifier
            $modelInfo = GenXdev.AI\Initialize-LMStudioModel @initParams

            # store the model identifier for api requests
            $Model = $modelInfo.identifier
        }

        # configure api endpoint with local default fallback
        $apiUrl = [string]::IsNullOrWhiteSpace($ApiEndpoint) ?
        'http://localhost:1234/v1/embeddings' : $ApiEndpoint

        # create request headers with optional authentication
        $headers = @{
            'Content-Type'  = 'application/json'
            'Authorization' = (-not [string]::IsNullOrWhiteSpace($ApiKey)) ?
            "Bearer $ApiKey" : $null
        }
    }

    process {

        $InputObject | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {
            $text = "$PSItem";
            if ([string]::IsNullOrWhiteSpace($text)) { return }

            # write verbose message about processing text items
            Microsoft.PowerShell.Utility\Write-Verbose ('Processing embeddings ' +
                "request for $($Text.Length) text items")

            # create api request payload with model and input text
            $payload = @{
                model = $Model
                input = $Text
            }

            # convert payload to compressed json with deep nesting support
            $json = $payload |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 60 -Compress

            # encode json string to utf8 bytes for api transmission
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

            # invoke embeddings api with extended timeout for large requests
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $apiUrl `
                -Method Post `
                -Body $bytes `
                -Headers $headers `
                -OperationTimeoutSeconds (3600 * 24) `
                -ConnectionTimeoutSeconds (3600 * 24)

            # process each embedding result and create output objects
            foreach ($embedding in $response.data) {

                # create custom object with embedding data and context
                [PSCustomObject]@{
                    embedding = $embedding.embedding
                    index     = $embedding.index
                    text      = $Text[$embedding.index]
                }
            }
        }
    }

    end {
    }
}
###############################################################################