<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Get-LMStudioWindow.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.280.2025
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
################################################################################
<#
.SYNOPSIS
Gets a window helper for the LM Studio application.

.DESCRIPTION
Gets a window helper for the LM Studio application. If LM Studio is not running,
it will be started automatically unless prevented by NoAutoStart switch.
The function handles process management and window positioning, model loading,
and configuration. Provides comprehensive window manipulation capabilities
including positioning, sizing, focusing, and keyboard input automation.

.PARAMETER LLMQueryType
The type of LLM query to use for AI operations. Valid values include
SimpleIntelligence, Knowledge, Pictures, TextTranslation, Coding, and ToolUse.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier for loading specific AI models.

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

.PARAMETER Unload
Switch to unload the specified model instead of loading it.

.PARAMETER ShowWindow
Switch to show LM Studio window during initialization.

.PARAMETER Force
Switch to force stop LM Studio before initialization.

.PARAMETER NoAutoStart
Switch to prevent automatic start of LM Studio if not running.

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard.

.PARAMETER NoBorders
Removes the borders of the LM Studio window.

.PARAMETER Width
The initial width of the LM Studio window.

.PARAMETER Height
The initial height of the LM Studio window.

.PARAMETER X
The initial X position of the LM Studio window.

.PARAMETER Y
The initial Y position of the LM Studio window.

.PARAMETER Left
Place LM Studio window on the left side of the screen.

.PARAMETER Right
Place LM Studio window on the right side of the screen.

.PARAMETER Top
Place LM Studio window on the top side of the screen.

.PARAMETER Bottom
Place LM Studio window on the bottom side of the screen.

.PARAMETER Centered
Place LM Studio window in the center of the screen.

.PARAMETER Fullscreen
Maximize the LM Studio window.

.PARAMETER RestoreFocus
Restore PowerShell window focus after positioning.

.PARAMETER PassThru
Returns the window helper for each process.

.PARAMETER SideBySide
Will either set the LM Studio window fullscreen on a different monitor than
Powershell, or side by side with Powershell on the same monitor.

.PARAMETER FocusWindow
Focus the LM Studio window after opening.

.PARAMETER SetForeground
Set the LM Studio window to foreground after opening.

.PARAMETER Maximize
Maximize the LM Studio window after positioning.

.PARAMETER KeysToSend
Keystrokes to send to the LM Studio Window, see documentation for cmdlet
GenXdev.Windows\Send-Key.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys to LM Studio window.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target LM Studio window when sending keys.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys to LM Studio window.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys to
LM Studio window.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Get-LMStudioWindow -Model "llama-2" -MaxToken 4096 -ShowWindow

.EXAMPLE
lmstudiowindow "qwen2.5-14b-instruct" -TTLSeconds 3600
#>
function Get-LMStudioWindow {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseUsingScopeModifierInNewRunspaces', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('lmstudiowindow', 'setlmstudiowindow')]
    param(
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
            HelpMessage = 'Unloads the specified model instead of loading it'
        )]
        [switch] $Unload,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show LM Studio window during initialization'
        )]
        [switch] $ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch] $Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No auto start LM Studio if not running'
        )]
        [switch] $NoAutoStart,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevents LM Studio initialization when passed through to EnsureLMStudio.'
        )]
        [switch] $NoLMStudioInitialize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y = -1,
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
            HelpMessage = 'Maximize the window'
        )]
        [Alias('fs')]
        [switch] $FullScreen,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the window helper for each process'
        )]
        [Alias('pt')]
        [switch] $PassThru,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a different ' +
                'monitor than Powershell, or side by side with Powershell on the ' +
                'same monitor')
        )]
        [Alias('sbs')]
        [switch] $SideBySide,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw', 'focus')]
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
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        ########################################################################
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
            HelpMessage = 'Delay between different input strings in milliseconds when sending keys'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
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
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'API key for authenticating with LM Studio or related services'
        )]
        [string] $ApiKey
        ########################################################################
    )

    begin {

        # output verbose message about attempting to locate or start lm studio
        Microsoft.PowerShell.Utility\Write-Verbose ('Attempting to locate or start ' +
            'LM Studio window')

        # get required paths for lm studio operation
        $paths = GenXdev.AI\Get-LMStudioPaths

        # handle force restart if requested and auto-start is enabled
        if ($Force -and (-not $NoAutoStart)) {

            # copy identical parameter values for the EnsureLMStudio function call
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureLMStudio' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # ensure lm studio is running with the specified parameters
            $null = GenXdev.AI\EnsureLMStudio @invocationArguments
        }

        # attempt to find existing lm studio window with main window handle
        $process = Microsoft.PowerShell.Management\Get-Process 'LM Studio' `
            -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
            Microsoft.PowerShell.Utility\Select-Object -First 1
    }

    process {

        # define helper function to check for running instances
        function CheckRunningInstances {

            # get all running lm studio processes
            $others = @(Microsoft.PowerShell.Management\Get-Process 'LM Studio' `
                    -ErrorAction SilentlyContinue)

            # check if any lm studio processes are running
            if ($others.Count -gt 0) {

                # try to initialize window via background job
                $null = Microsoft.PowerShell.Core\Start-Job -ScriptBlock {

                    param($paths)

                    # start primary instance
                    $null = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle 'Minimized'

                    # wait for primary instance to initialize
                    Microsoft.PowerShell.Utility\Start-Sleep 3

                    # start secondary instance
                    $null = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath ($paths.LMStudioExe) `
                        -WindowStyle 'Minimized'

                } -ArgumentList $paths |
                    Microsoft.PowerShell.Core\Wait-Job

                # wait for instances to stabilize
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 3

                # locate process with main window handle
                $process = Microsoft.PowerShell.Management\Get-Process 'LM Studio' |
                    Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
                    Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }

        # initialize process if not found
        if ($null -eq $process) {
            CheckRunningInstances
        }

        # handle auto-start scenario when no process is found
        if ($null -eq $process) {

            # check if auto-start is disabled
            if ($NoAutoStart) {
                Microsoft.PowerShell.Utility\Write-Error 'No running LM Studio found'
                return
            }

            # output verbose message about initializing new instance
            Microsoft.PowerShell.Utility\Write-Verbose 'Initializing new LM Studio instance'

            # copy identical parameter values for the EnsureLMStudio function call
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureLMStudio' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -Name * -ErrorAction SilentlyContinue)

            # ensure lm studio is running with the specified parameters
            $null = GenXdev.AI\EnsureLMStudio @invocationArguments

            # attempt to find the newly started process with main window handle
            $process = Microsoft.PowerShell.Management\Get-Process 'LM Studio' |
                Microsoft.PowerShell.Core\Where-Object { $_.MainWindowHandle -ne 0 } |
                Microsoft.PowerShell.Utility\Select-Object -First 1
        }

        # final attempt to initialize if still no process found
        if ($null -eq $process) {
            CheckRunningInstances
        }

        if (-not $ShowWindow) { return }

        # output verbose message about found process
        Microsoft.PowerShell.Utility\Write-Verbose ('Found LM Studio process ' +
            "(PID: $($process.Id))")

        # get window helper for the found process
        $WindowHelper = GenXdev.Windows\Get-Window -ProcessName "LM Studio"

        # handle window positioning and display if requested
        if ($null -ne $WindowHelper) {

            # copy identical parameter values for the Set-WindowPosition function call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.Windows\Set-WindowPosition'
            $params.KeysToSend = @("^2")
            $params.RestoreFocus = $true
            if (-not $params.ContainsKey('Monitor')) {
                $params['Monitor'] = -2
            }

            # set window positions and focus using the window helper
            $null = GenXdev.Windows\Set-WindowPosition @params -WindowHelper $WindowHelper
        }

        # return the window helper object
        Microsoft.PowerShell.Utility\Write-Output $WindowHelper
    }

    end {
    }
}
################################################################################