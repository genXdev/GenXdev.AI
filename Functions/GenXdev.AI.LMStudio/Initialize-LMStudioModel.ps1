<##############################################################################
Part of PowerShell module : GenXdev.AI.LMStudio
Original cmdlet filename  : Initialize-LMStudioModel.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.304.2025
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
Initializes and loads an AI model in LM Studio.

.DESCRIPTION
Searches for and loads a specified AI model in LM Studio. Handles installation
verification, process management, and model loading with GPU support.

.PARAMETER Model
Name or partial path of the model to initialize. Searched against available models.

.PARAMETER HuggingFaceIdentifier
The specific LM-Studio model identifier to use for download/initialization.

.PARAMETER MaxToken
Maximum tokens allowed in response. -1 for default limit.

.PARAMETER TTLSeconds
Time-to-live in seconds for loaded models. -1 for no TTL.

.PARAMETER Gpu
GPU offloading level: -2=Auto, -1=LMStudio decides, 0=Off, 0-1=Layer fraction

.PARAMETER ShowWindow
Switch to show LM Studio window during initialization.

.PARAMETER Force
Switch to force stop LM Studio before initialization.

.PARAMETER Unload
Switch to unload the specified model instead of loading it.

.PARAMETER LLMQueryType
The type of LLM query to use for AI operations.

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

.PARAMETER SessionOnly
Switch to use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Switch to clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Switch to store settings only in persistent preferences without affecting
session.

.PARAMETER Unload
Unloads the specified model instead of loading it.

.PARAMETER NoLMStudioInitialize
Switch to skip LM-Studio initialization (used when already called by parent function).

.EXAMPLE
Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ShowWindow -MaxToken 2048

###############################################################################>
function Initialize-LMStudioModel {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseUsingScopeModifierInNewRunspaces', ''
    )]
    [Alias('initlmstudio')]
    param(

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
            HelpMessage = 'Show LM Studio window during initialization'
        )]
        [switch]$ShowWindow,
        ########################################################################
        [Alias('m', 'mon')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [int] $Monitor = -2,
        ########################################################################

        [Alias('nb')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [switch] $NoBorders,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ########################################################################

        [parameter(
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

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the window helper for each process'
        )]
        [Alias('pt')]
        [switch]$PassThru,

        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Will either set the window fullscreen on a different monitor than Powershell, or ' +
            'side by side with Powershell on the same monitor'
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'API key for authentication with LM Studio or related services'
        )]
        [string] $ApiKey,
        ###############################################################################
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
        ###########################################################################
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
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
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
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip LM-Studio initialization (used when ' +
                'already called by parent function)')
        )]
        [switch] $NoLMStudioInitialize
        ###################################################################
    )

    begin {

        $NoLMStudioInitialize = $NoLMStudioInitialize -or (
            (-not [string]::IsNullOrWhiteSpace($ApiEndpoint)) -and (
            ($ApiEndpoint.Contains('localhost') -or $ApiEndpoint.Contains('127.0.0.1'))
            )
        )

        # Initialize variables that may be used across blocks
        $paths = $null
        $installationOk = $false
        $processOk = $false

        $llmConfigParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AILLMSettings' `
            -DefaultValues  (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $llmConfig = GenXdev.AI\Get-AILLMSettings @llmConfigParams

        foreach ($param in $llmConfig.Keys) {
            if (($null -ne $llmConfig[$param]) -and (
                    Microsoft.PowerShell.Utility\Get-Variable -Name $param `
                        -Scope Local -ErrorAction SilentlyContinue)) {

                Microsoft.PowerShell.Utility\Set-Variable -Name $param -Value ($llmConfig[$param]) -Scope Local -Force
            }
        }

        # force stop LM Studio processes if requested
        if ($Force) {

            if ($PSBoundParameters.ContainsKey('Force')) {

                $null = $PSBoundParameters.Remove('Force')
            }
            $Force = $false

            Microsoft.PowerShell.Utility\Write-Verbose 'Force parameter specified, stopping LM Studio processes'
            $null = Microsoft.PowerShell.Management\Get-Process 'LM Studio', 'LMS' -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Management\Stop-Process -Force
        }

        # get lm studio installation paths
        $paths = GenXdev.AI\Get-LMStudioPaths

        # verify installation and process status
        $installationOk = GenXdev.AI\Test-LMStudioInstallation
        $processOk = GenXdev.AI\Test-LMStudioProcess -ShowWindow:$ShowWindow

        # handle installation and process initialization if needed
        if (-not $installationOk -or -not $processOk) {

            if (-not $installationOk) {

                $null = GenXdev.AI\Install-LMStudioApplication
                $installationOk = GenXdev.AI\Test-LMStudioInstallation

                if (-not $installationOk) {
                    throw 'LM Studio not found or properly installed'
                }

                Microsoft.PowerShell.Utility\Start-Sleep 15
                Microsoft.PowerShell.Management\Get-Process 'LM Studio' -ErrorAction SilentlyContinue | Microsoft.PowerShell.Management\Stop-Process -Force
                $processOk = GenXdev.AI\Test-LMStudioProcess -ShowWindow:$ShowWindow
            }

            $paths = GenXdev.AI\Get-LMStudioPaths

            if (-not $processOk) {

                # attempt to start the server asynchronously
                $null = GenXdev.AI\Start-LMStudioApplication -ShowWindow:$ShowWindow
            }
        }

        if ($ShowWindow) {

            $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Get-LMStudioWindow' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            $params.KeysToSend = @("^2")
            $params.RestoreFocus = $true
            $null = GenXdev.AI\Get-LMStudioWindow @params -NoAutoStart -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Using LM Studio CLI executable: $($paths.LMSExe)"
    }

    process {

        # get current model list and search for requested model
        $modelList = GenXdev.AI\Get-LMStudioModelList
        $foundModel = $modelList |
            Microsoft.PowerShell.Core\Where-Object {
                ($_.path -like "*$Model*") -or
                ($_.path -like "*$HuggingFaceIdentifier*") -or
                ($_.modelKey -eq $Model) -or
                ($_.displayName -like "*$Model*")
            } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        # attempt to download model if not found and identifier provided
        if (-not $foundModel) {
            if (-not [string]::IsNullOrWhiteSpace($HuggingFaceIdentifier)) {
                # Determine if HuggingFaceIdentifier is a full artifact (repo/model or repo/model/filename)
                $isFullArtifact = $false
                if ($HuggingFaceIdentifier -match '^[^/]+/[^/]+(/[^"]+)?$') {
                    $isFullArtifact = $true
                }
                $lmsModelName = $HuggingFaceIdentifier
                if (-not $lmsModelName.ToLowerInvariant().StartsWith('https://huggingface.co/')) {
                    if ($HuggingFaceIdentifier.StartsWith("/")) {
                        $lmsModelName = "https://huggingface.co$HuggingFaceIdentifier"
                    } else {
                        $lmsModelName = "https://huggingface.co/$HuggingFaceIdentifier"
                    }
                }
                $lmsArgs = @('get', $lmsModelName, '--yes')
                # Only add --gguf if not passing a full artifact name
                if (-not $isFullArtifact) { $lmsArgs += '--gguf' }
                & "$($paths.LMSExe)" @lmsArgs

                # refresh model list after download
                $modelList = GenXdev.AI\Get-LMStudioModelList
                $foundModel = $modelList |
                    Microsoft.PowerShell.Core\Where-Object {
                        ($_.path -like "*$Model*") -or
                        ($Model -like "*/$($_.path)") -or
                        ($_.path -like "*$HuggingFaceIdentifier*") -or
                        ($_.modelKey -eq $Model) -or
                        ($_.displayName -like "*$Model*")
                    } |
                    Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }


        if (-not $foundModel) {
            throw "Model '$Model' not found"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Selected model: $($foundModel.path)"

        if ($NoLMStudioInitialize) {
            return $foundModel;
        }

        # check if model is already loaded
        $loadedModels = GenXdev.AI\Get-LMStudioLoadedModelList
        $modelLoaded = $loadedModels |
            Microsoft.PowerShell.Core\Where-Object { $_.path -eq $foundModel.path } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        # handle unload request if specified
        if ($Unload) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Unload parameter specified, unloading model...'

            if ($null -eq $modelLoaded) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Model is not currently loaded, nothing to unload'
                return $null
            }

            $params = @('unload', $foundModel.path, '--exact')

            Microsoft.PowerShell.Utility\Write-Verbose ('Unloading model with params: ' +
                "$($params | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue)")

            # Execute the unload command but don't store the unused result
            Microsoft.PowerShell.Management\Start-Process `
                -FilePath $paths.LMSExe `
                -ArgumentList $params `
                -Wait `
                -NoNewWindow `
                -PassThru `
                -ErrorAction SilentlyContinue | Microsoft.PowerShell.Core\Out-Null

            # verify unload success
            $loadedModels = GenXdev.AI\Get-LMStudioLoadedModelList
            $stillLoaded = $loadedModels |
                Microsoft.PowerShell.Core\Where-Object { $_.path -eq $foundModel.path } |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            if ($null -eq $stillLoaded) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Model successfully unloaded'
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose 'Failed to unload model'
            }
            return
        }

        # load model if not already active
        if ($null -eq $modelLoaded) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Loading model...'
            $params = [System.Collections.Generic.List[string]]::new()
            $null = $params.Add('load')
            $null = $params.Add($foundModel.path)
            $null = $params.Add('--exact')

            if ($TTLSeconds -gt 0) {
                $null = $params.Add('--ttl')
                $null = $params.Add($TTLSeconds)
            }

            switch ($Gpu) {

                -2 {
                    if (GenXdev.AI\Get-HasCapableGpu) {

                        $null = $params.Add('--gpu 1')
                    }
                    else {

                        $null = $params.Add('--gpu 0')
                    }
                    break;
                }
                default {
                    if ($Gpu -lt 0) { break; }
                    if (($Gpu -eq 0) -and ($Gpu -le 1)) {

                        $null = $params.Add("--gpu $([Math]::Round($Gpu, 2))")
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Verbose 'Invalid GPU value. Use -2 for autodetect, or 0..1'
                    }
                }
            }

            if ($maxToken -gt 0) {

                $null = $params.Add('--context-length')
                $null = $params.Add($maxToken)
            }

            # log the model loading parameters
            Microsoft.PowerShell.Utility\Write-Verbose ('Loading model with params: ' +
                "$($params | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress `
                -WarningAction SilentlyContinue)")

            # attempt to load the model in a background job
            $null = Microsoft.PowerShell.Core\Start-Job `
                -ArgumentList @($paths, $params) `
                -ScriptBlock {
                param($lmstudiopaths, $params)

                try {
                    # start lmstudio process and wait for completion
                    $process = Microsoft.PowerShell.Management\Start-Process `
                        -FilePath $lmstudiopaths.LMSExe `
                        -ArgumentList $params `
                        -Wait `
                        -NoNewWindow `
                        -PassThru `
                        -ErrorAction SilentlyContinue

                    # check if model loaded successfully
                    return ($process.ExitCode -eq 0) -or (
                        GenXdev.AI\Get-LMStudioLoadedModelList |
                            Microsoft.PowerShell.Core\Where-Object {
                                $_.path -like $params[1]
                            }
                        )
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Error during model load: $_"
                        )
                        return $false
                    }
                }.GetNewClosure() |
                    Microsoft.PowerShell.Core\Wait-Job |
                    Microsoft.PowerShell.Core\Remove-Job

            # Add waiting loop to ensure model is fully loaded
            $timeout = 1800 # 30 minutes in seconds
            $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
            $modelLoaded = $null
            $errorOccurred = $false

            Microsoft.PowerShell.Utility\Write-Verbose 'Waiting for model to be fully loaded...'

            while ($stopwatch.Elapsed.TotalSeconds -lt $timeout -and $null -eq $modelLoaded -and -not $errorOccurred) {
                try {
                    # Check every 5 seconds
                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5

                    # Check if model is loaded
                    $loadedModels = GenXdev.AI\Get-LMStudioLoadedModelList
                    $modelLoaded = $loadedModels |
                        Microsoft.PowerShell.Core\Where-Object { $_.path -eq $foundModel.path } |
                        Microsoft.PowerShell.Utility\Select-Object -First 1

                    # Status update every 30 seconds
                    if ($stopwatch.Elapsed.TotalSeconds % 30 -lt 5) {
                        $elapsedTime = [math]::Floor($stopwatch.Elapsed.TotalSeconds)
                        Microsoft.PowerShell.Utility\Write-Verbose "Still waiting for model to load... ($elapsedTime seconds elapsed)"
                    }
                }
                catch {
                    $errorOccurred = $true
                    Microsoft.PowerShell.Utility\Write-Verbose "Error while waiting for model to load: $_"
                }
            }

            $stopwatch.Stop()

            if ($null -eq $modelLoaded) {
                if ($stopwatch.Elapsed.TotalSeconds -ge $timeout) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Timeout reached after waiting $timeout seconds for model to load"
                }

                if ($loadedModels.Count -gt 0 -and -not $errorOccurred) {
                    # retry after unloading if initial load failed
                    Microsoft.PowerShell.Utility\Write-Verbose 'Timeout or error occurred. Attempting to unload all models and retry...'

                    # unload all models
                    $null = Microsoft.PowerShell.Core\Start-Job `
                        -ArgumentList $paths `
                        -ScriptBlock {
                        param($lmstudiopaths)

                        $null = Microsoft.PowerShell.Management\Start-Process `
                            -FilePath $lmstudiopaths.LMSExe `
                            -ArgumentList @('unload', '--all') `
                            -Wait `
                            -NoNewWindow

                        return $LASTEXITCODE -eq 0
                    } |
                        Microsoft.PowerShell.Core\Wait-Job |
                        Microsoft.PowerShell.Core\Receive-Job

                    # retry model initialization
                    return GenXdev.AI\Initialize-LMStudioModel @PSBoundParameters
                }
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "Model successfully loaded after $([math]::Floor($stopwatch.Elapsed.TotalSeconds)) seconds"
            }
        }

        # verify successful model load
        $loadedModels = GenXdev.AI\Get-LMStudioLoadedModelList
        $modelLoaded = $loadedModels |
            Microsoft.PowerShell.Core\Where-Object { $_.path -eq $foundModel.path } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        if ($null -eq $modelLoaded) {
            $null = GenXdev.AI\Test-LMStudioProcess -ShowWindow
            throw 'Model failed to load. Check LM-Studio configuration.'
        }

        return $modelLoaded
    }
}