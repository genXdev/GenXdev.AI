<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Set-AILLMSettings.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.276.2025
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
Sets the LLM settings for AI operations in GenXdev.AI.

.DESCRIPTION
This f        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support json_schema response format'
        )]
        [switch] $NoSupportForJsonSchema,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support image upload functionality'
        )]
        [switch] $NoSupportForImageUpload,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support tool calling functionality'
        )]
        [switch] $NoSupportForToolCalls,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store the settings only in the current session without ' +
                'persisting')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,res the LLM (Large Language Model) settings used by the
GenXdev.AI module for various AI operations. Settings can be stored persistently
in preferences (default), only in the current session (using -SessionOnly), or
cleared from the session (using -ClearSession). The function validates that at
least one setting parameter is provided unless clearing session settings.

.PARAMETER LLMQueryType
The type of LLM query to set settings for. This determines which configuration
to store or modify. Valid values are SimpleIntelligence, Knowledge, Pictures,
TextTranslation, Coding, and ToolUse.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier to use for retrieving the model.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
GPU offload level (-2=Auto through 1=Full).

.PARAMETER TTLSeconds
The time-to-live in seconds for cached AI responses.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER NoSupportForJsonSchema
When specified, indicates that the endpoint does not support json_schema
response format. This enables fallback behavior using prompt-based instructions.

.PARAMETER NoSupportForImageUpload
When specified, indicates that the endpoint does not support image upload
functionality.

.PARAMETER NoSupportForToolCalls
When specified, indicates that the endpoint does not support tool calling
functionality.

.PARAMETER SessionOnly
When specified, stores the settings only in the current session (Global
variables) without persisting to preferences. Settings will be lost when the
session ends.

.PARAMETER ClearSession
When specified, clears only the session settings (Global variables) without
affecting persistent preferences.

.PARAMETER SkipSession
When specified, stores the settings only in persistent preferences without
affecting the current session settings.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "Coding" -Model "*Qwen*14B*" -MaxToken 32768

Sets the LLM settings for Coding query type persistently in preferences.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "maziyarpanahi/llama-3-groq-8b-tool-use" -TimeoutSeconds 7200 -SessionOnly

Sets the LLM settings for SimpleIntelligence only for the current
session.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "Pictures" -ClearSession

Clears the session LLM settings for Pictures query type without affecting
persistent preferences.

.EXAMPLE
Set-AILLMSettings "Coding" "*Qwen*14B*" -MaxToken 32768

Sets the LLM settings for Coding query type using positional parameters.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "Coding" -Cpu 8 -Gpu 2 -MaxToken 16384

Sets the LLM settings for Coding query type with specific CPU and GPU core counts.
###############################################################################>
function Set-AILLMSettings {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
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
        [string] $LLMQueryType,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        ###############################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                'offloaded to GPU. If a number between 0 and 1, ' +
                'that fraction of layers will be offloaded to the ' +
                'GPU. -1 = LM Studio will decide how much to ' +
                'offload to the GPU. -2 = Auto')
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu,
        ###############################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'The time-to-live in seconds for cached AI responses'
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Position = 8,
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Position = 9,
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support json_schema response format'
        )]
        [switch] $NoSupportForJsonSchema,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support image upload functionality'
        )]
        [switch] $NoSupportForImageUpload,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support tool calling functionality'
        )]
        [switch] $NoSupportForToolCalls,
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
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        # validate that at least one setting parameter is provided unless clearing
        # session
        if (-not $ClearSession) {

            # define all settable parameters for validation
            $settingParams = @(
                'Model',
                'HuggingFaceIdentifier',
                'MaxToken',
                'Cpu',
                'Gpu',
                'TTLSeconds',
                'ApiEndpoint',
                'ApiKey',
                'TimeoutSeconds',
                'NoSupportForJsonSchema',
                'NoSupportForImageUpload',
                'NoSupportForToolCalls'
            )

            # filter to only parameters that were actually provided
            $providedSettings = $settingParams |
                Microsoft.PowerShell.Core\Where-Object {
                    $PSBoundParameters.ContainsKey($_)
                }

            # ensure at least one setting parameter was provided
            if ($providedSettings.Count -eq 0) {

                throw ('At least one LLM setting parameter must be provided ' +
                    'when not using -ClearSession')
            }
        }

        # validate parameter dependencies when not using session-only mode
        if ((-not $SessionOnly) -or ($SkipSession)) {

            # check if model is provided without lm studio identifier
            if ($PSBoundParameters.ContainsKey('Model') -and
                -not $PSBoundParameters.ContainsKey('HuggingFaceIdentifier')) {

                throw ('HuggingFaceIdentifier must be provided when Model is ' +
                    'specified for persistent storage')
            }

            # check if api endpoint is provided without api key
            if ($PSBoundParameters.ContainsKey('ApiEndpoint') -and
                -not $PSBoundParameters.ContainsKey('ApiKey')) {

                throw ('ApiKey must be provided when ApiEndpoint is ' +
                    'specified for persistent storage')
            }
        }

        # output informational message about the operation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Setting LLM settings for query type: $LLMQueryType"
        )
    }

    process {

        # handle clearing session variables when requested
        if ($ClearSession) {

            # create descriptive message for whatif processing
            $clearMessage = 'Clear session LLM settings for all properties (Global variables)'

            # check if user confirmed the operation or whatif mode
            if ($PSCmdlet.ShouldProcess(
                    'GenXdev.AI Module Configuration',
                    $clearMessage
                )) {

                # clear individual session variables for each property
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_Model') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_HuggingFaceIdentifier') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_MaxToken') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_Cpu') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_Gpu') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_TTLSeconds') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_ApiEndpoint') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_ApiKey') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_TimeoutSeconds') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForJsonSchema') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForImageUpload') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForToolCalls') -Value $null -Scope Global

                # output confirmation of the clearing operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Cleared session LLM settings for all properties'
                )
            }
            return
        }

        # create hashtable to store only the provided settings
        $settings = @{}

        # define all possible setting parameters for iteration
        $settingParams = @(
            'Model',
            'HuggingFaceIdentifier',
            'MaxToken',
            'Cpu',
            'Gpu',
            'TTLSeconds',
            'ApiEndpoint',
            'ApiKey',
            'TimeoutSeconds',
            'NoSupportForJsonSchema',
            'NoSupportForImageUpload',
            'NoSupportForToolCalls'
        )

        # iterate through all possible parameters and add provided ones to
        # settings
        $preferencesToRemove = @()
        foreach ($param in $settingParams) {

            # check if this parameter was actually provided by the user
            if ($PSBoundParameters.ContainsKey($param)) {

                # if SessionOnly, allow null values to clear individual session variables
                if ($SessionOnly) {
                    # add the parameter value to our settings hashtable (including null)
                    $settings[$param] = $PSBoundParameters[$param]
                }
                else {
                    # for persistent storage, handle null values by marking for deletion
                    if ($null -eq $PSBoundParameters[$param]) {
                        # mark this preference for deletion
                        $preferenceKey = "AILLMSettings_$($LLMQueryType)_$param"
                        $preferencesToRemove += $preferenceKey
                        Microsoft.PowerShell.Utility\Write-Verbose "Marking preference for deletion: $preferenceKey"
                    }
                    else {
                        # for string parameters, also check that they're not empty
                        $isStringParam = $param -in @('Model', 'HuggingFaceIdentifier', 'ApiEndpoint', 'ApiKey')
                        if ($isStringParam -and [string]::IsNullOrWhiteSpace($PSBoundParameters[$param])) {
                            # mark empty string values for deletion too
                            $preferenceKey = "AILLMSettings_$($LLMQueryType)_$param"
                            $preferencesToRemove += $preferenceKey
                            Microsoft.PowerShell.Utility\Write-Verbose "Marking preference for deletion (empty string): $preferenceKey"
                        }
                        else {
                            # add the parameter value to our settings hashtable
                            $settings[$param] = $PSBoundParameters[$param]
                        }
                    }
                }
            }
        }

        # handle session-only storage when requested
        if ($SessionOnly) {

            # create human-readable description of settings for logging
            $settingsDescription = ($settings.GetEnumerator() |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        "$($_.Key): $($_.Value)"
                    }) -join ', '

            # check if user confirmed the operation or whatif mode
            if ($PSCmdlet.ShouldProcess(
                    'GenXdev.AI Module Configuration',
                ("Set session-only LLM settings: [$settingsDescription]")
                )) {

                # set individual session variables for each provided setting
                foreach ($key in $settings.Keys) {
                    $sessionVarName = "AILLMSettings_$($LLMQueryType)_$key"
                    Microsoft.PowerShell.Utility\Set-Variable `
                        -Name $sessionVarName `
                        -Value $settings[$key] `
                        -Scope Global
                }

                # output confirmation of the session-only storage operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only LLM settings: [$settingsDescription]"
                )
            }
            return
        }

        # handle persistent storage (default behavior)
        # create human-readable description of settings for logging
        $settingsDescription = ($settings.GetEnumerator() |
                Microsoft.PowerShell.Core\ForEach-Object {
                    "$($_.Key): $($_.Value)"
                }) -join ', '

        # check if user confirmed the operation or whatif mode
        if ($PSCmdlet.ShouldProcess(
                'GenXdev.AI Module Configuration',
            ("Set LLM settings for ${LLMQueryType}: [$settingsDescription]")
            )) {

            # store each setting individually in preferences
            foreach ($key in $settings.Keys) {
                $preferenceKey = "AILLMSettings_$($LLMQueryType)_$key"
                $null = GenXdev.Data\Set-GenXdevPreference `
                    -PreferencesDatabasePath $PreferencesDatabasePath `
                    -Name $preferenceKey `
                    -Value $settings[$key]
            }

            # remove preferences that were marked for deletion (null values)
            foreach ($preferenceKey in $preferencesToRemove) {
                try {
                    $null = GenXdev.Data\Remove-GenXdevPreference `
                        -PreferencesDatabasePath $PreferencesDatabasePath `
                        -Name $preferenceKey `
                        -ErrorAction SilentlyContinue
                    Microsoft.PowerShell.Utility\Write-Verbose "Deleted preference: $preferenceKey"
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose "Could not delete preference: $preferenceKey (may not exist)"
                }
            }

            # output confirmation of the persistent storage operation
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Set persistent LLM settings for ${LLMQueryType}: [$settingsDescription]"
            )
        }
    }

    end {
    }
}
###############################################################################