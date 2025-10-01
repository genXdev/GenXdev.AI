<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-AILLMSettings.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.290.2025
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
<#
.SYNOPSIS
Gets the LLM settings for AI operations in GenXdev.AI.

.DESCRIPTION
This function retrieves the LLM (Large Language Model) settings used by the
GenXdev.AI module for various AI operations. Settings are retrieved from
session variables, persistent preferences, or default settings JSON file, in
that order of precedence. The function supports automatic configuration
selection based on available system memory resources.

Memory selection strategy is determined automatically based on the Gpu and Cpu
parameters provided:
- If both Gpu and Cpu parameters are specified: Uses combined CPU + GPU memory
- If only Gpu parameter is specified: Prefers GPU memory (with system RAM fallback)
- If only Cpu parameter is specified: Uses system RAM only
- If neither parameter is specified: Uses combined CPU + GPU memory (default)

.PARAMETER LLMQueryType
The type of LLM query to get settings for. This determines which default
settings to use when no custom settings are found. Valid values include
SimpleIntelligence, Knowledge, Pictures, TextTranslation, Coding, and ToolUse.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

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

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving.

.PARAMETER SkipSession
When specified, skips session settings and retrieves only from persistent
preferences or defaults. This is useful when you want to ignore any temporary
session-level overrides.

.EXAMPLE
Get-AILLMSettings

Gets the LLM settings for SimpleIntelligence query type (default).

.EXAMPLE
Get-AILLMSettings -LLMQueryType "Coding"

Gets the LLM settings for Coding query type.

.EXAMPLE
Get-AILLMSettings -Model "*custom*model*" -MaxToken 8192

Gets LLM settings with specific model and token override parameters.

.EXAMPLE
Get-AILLMSettings -Cpu 8 -Gpu 2 -TimeoutSeconds 300

Gets LLM settings with specific CPU and GPU core counts and timeout override.

.EXAMPLE
Get-AILLMSettings -LLMQueryType "ToolUse" -Cpu 8

Gets the LLM settings for ToolUse query type with 8 CPU cores specified.
This will select the best configuration based on available system RAM.

.EXAMPLE
Get-AILLMSettings -LLMQueryType "Coding" -Gpu 2

Gets the LLM settings for Coding query type with GPU offload level 2.
This will select the best configuration based on available GPU RAM.

.EXAMPLE
Get-AILLMSettings -LLMQueryType "Pictures" -Cpu 4 -Gpu 1

Gets the LLM settings for Pictures query type with both CPU and GPU specified.
This will select the best configuration based on combined CPU + GPU memory.

.EXAMPLE
Get-AILLMSettings -SkipSession

Gets the LLM settings from preferences or defaults only, ignoring session
settings.

.EXAMPLE
Get-AILLMSettings "Knowledge"

#>
################################################################################
function Get-AILLMSettings {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The type of LLM query to get settings for'
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
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
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
                'offload to the GPU. -2 = Auto'))]
        [int] $Gpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The time-to-live in seconds for cached AI responses'
        )]
        [int] $TTLSeconds,
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
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear the session setting (Global variable) before retrieving'
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
            HelpMessage = ('Skip session settings and get from preferences ' +
                'or defaults only')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose '=== Get-AILLMSettings Started ==='
        Microsoft.PowerShell.Utility\Write-Verbose "LLMQueryType: $LLMQueryType"
        Microsoft.PowerShell.Utility\Write-Verbose "SessionOnly: $SessionOnly"
        Microsoft.PowerShell.Utility\Write-Verbose "SkipSession: $SkipSession"
        Microsoft.PowerShell.Utility\Write-Verbose "ClearSession: $ClearSession"

        # log provided parameter values
        $providedParams = @()
        if ($PSBoundParameters.ContainsKey('Model')) { $providedParams += "Model=$Model" }
        if ($PSBoundParameters.ContainsKey('HuggingFaceIdentifier')) { $providedParams += "HuggingFaceIdentifier=$HuggingFaceIdentifier" }
        if ($PSBoundParameters.ContainsKey('MaxToken')) { $providedParams += "MaxToken=$MaxToken" }
        if ($PSBoundParameters.ContainsKey('Cpu')) { $providedParams += "Cpu=$Cpu" }
        if ($PSBoundParameters.ContainsKey('Gpu')) { $providedParams += "Gpu=$Gpu" }
        if ($PSBoundParameters.ContainsKey('TTLSeconds')) { $providedParams += "TTLSeconds=$TTLSeconds" }
        if ($PSBoundParameters.ContainsKey('ApiEndpoint')) { $providedParams += "ApiEndpoint=$ApiEndpoint" }
        if ($PSBoundParameters.ContainsKey('ApiKey')) { $providedParams += 'ApiKey=(redacted)' }
        if ($PSBoundParameters.ContainsKey('TimeoutSeconds')) { $providedParams += "TimeoutSeconds=$TimeoutSeconds" }
        if ($PSBoundParameters.ContainsKey('NoSupportForJsonSchema')) { $providedParams += "NoSupportForJsonSchema=$NoSupportForJsonSchema" }
        if ($PSBoundParameters.ContainsKey('NoSupportForImageUpload')) { $providedParams += "NoSupportForImageUpload=$NoSupportForImageUpload" }
        if ($PSBoundParameters.ContainsKey('NoSupportForToolCalls')) { $providedParams += "NoSupportForToolCalls=$NoSupportForToolCalls" }

        if ($providedParams.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose "Provided parameters: $($providedParams -join ', ')"
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose 'No explicit parameter values provided'
        }

        # handle clearing session variables first if requested
        if ($ClearSession) {

            # clear all global session variables for llm settings
            # These variables are used dynamically via Get-Variable, so suppress PSScriptAnalyzer warnings

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

            # inform user that session variables have been cleared
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Cleared session LLM settings for all properties'
            )
        }

        # initialize the result hashtable with all possible setting properties
        $result = @{
            Model                     = $null
            HuggingFaceIdentifier     = $null
            MaxToken                  = $null
            Cpu                       = $null
            Gpu                       = $null
            TTLSeconds                = $null
            ApiEndpoint               = $null
            ApiKey                    = $null
            TimeoutSeconds            = $null
            NoSupportForJsonSchema    = $null
            NoSupportForImageUpload   = $null
            NoSupportForToolCalls     = $null
        }
    }

    process {

        # define helper function to retrieve individual setting values
        function Get-SettingValue {

            param(
                [string]$propertyName,
                [object]$parameterValue,
                [bool]$parameterExplicitlyProvided,
                [string]$llmQueryType,
                [switch]$sessionOnly,
                [switch]$skipSession,
                [hashtable]$defaultConfig
            )

            # check if parameter was explicitly provided and has a meaningful value
            if ($parameterExplicitlyProvided) {
                # for string parameters, check if the value is meaningful (not null/empty/whitespace)
                $isStringParam = $propertyName -in @('Model', 'HuggingFaceIdentifier', 'ApiEndpoint', 'ApiKey')
                if ($isStringParam) {
                    if (-not [String]::IsNullOrWhiteSpace($parameterValue)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Using explicitly provided parameter value: $parameterValue"
                        return $parameterValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Parameter explicitly provided but is null/empty, checking other sources..."
                    }
                } else {
                    # for numeric parameters, check if not null and not zero
                    if ($null -ne $parameterValue -and $parameterValue -ne 0) {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Using explicitly provided parameter value: $parameterValue"
                        return $parameterValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Parameter explicitly provided but is null/zero, checking other sources..."
                    }
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No parameter value provided, checking other sources..."
            }

            # check session variables unless SkipSession is specified
            if (-not $skipSession) {

                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Checking session variables..."

                # construct session variable name
                $sessionVarName = "AILLMSettings_$($llmQueryType)_$propertyName"

                # attempt to retrieve session variable value
                if (Microsoft.PowerShell.Utility\Get-Variable `
                        -Name $sessionVarName `
                        -Scope Global `
                        -ErrorAction SilentlyContinue) {

                    # get the actual variable value
                    $sessionValue = (Microsoft.PowerShell.Utility\Get-Variable `
                            -Name $sessionVarName `
                            -Scope Global).Value

                    # return session value if it exists and is not empty
                    if ($null -ne $sessionValue -and $sessionValue -ne '') {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Found session value: $sessionValue"
                        return $sessionValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Session variable exists but is null/empty"
                    }
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No session variable found: $sessionVarName"
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Skipping session variables (SkipSession=true)"
            }

            # return null if SessionOnly is specified and no session value found
            if ($sessionOnly) {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] SessionOnly=true and no session value found, returning null"
                return $null
            }

            # check preference storage unless SessionOnly is specified
            if (-not $sessionOnly) {

                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Checking preference storage..."

                try {
                    # construct preference key using query type and property name
                    $preferenceKey = "AILLMSettings_$($llmQueryType)_$propertyName"

                    # attempt to retrieve preference value
                    $preferenceValue = GenXdev.Data\Get-GenXdevPreference `
                        -PreferencesDatabasePath $PreferencesDatabasePath `
                        -Name $preferenceKey `
                        -ErrorAction SilentlyContinue

                    # return preference value if it exists and is not empty
                    if ($null -ne $preferenceValue -and $preferenceValue -ne '') {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Found preference value: $preferenceValue"
                        return $preferenceValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No preference value found for key: $preferenceKey"
                    }
                }
                catch {
                    # preference not found, continue to defaults
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Error accessing preferences: $($_.Exception.Message)"
                }

                # use the auto-selected default configuration if available
                if ($null -ne $defaultConfig -and $defaultConfig.ContainsKey($propertyName)) {
                    $finalValue = $defaultConfig[$propertyName]
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Found in auto-selected default configuration: $finalValue"
                    return $finalValue
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Property not found in auto-selected default configuration"
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Skipping defaults (SessionOnly=true)"
            }

            Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No value found from any source, returning null"
            return $null
        }

        # retrieve each setting value using the helper function or from defaults

        # create parameter hashtable for Get-AIDefaultLLMSettings
        $defaultSettingsParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIDefaultLLMSettings'
        # -DefaultValues (Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        Microsoft.PowerShell.Utility\Write-Verbose '=== Using Get-AIDefaultLLMSettings for auto-selection ==='

        $defaultConfig = GenXdev.AI\Get-AIDefaultLLMSettings @defaultSettingsParams -AutoSelect

        if ($defaultConfig) {
            # Check if it's an array or a single hashtable
            if ($defaultConfig -is [array] -and $defaultConfig.Count -gt 0) {
                $selectedDefaultConfig = $defaultConfig[0] | GenXdev.Helpers\ConvertTo-HashTable
                Microsoft.PowerShell.Utility\Write-Verbose 'Auto-selected default configuration found (from array)'
            } elseif ($defaultConfig -is [hashtable]) {
                # Single hashtable returned
                $selectedDefaultConfig = $defaultConfig
                Microsoft.PowerShell.Utility\Write-Verbose 'Auto-selected default configuration found (single hashtable)'
            } else {
                $selectedDefaultConfig = $null
                Microsoft.PowerShell.Utility\Write-Verbose "Default configuration has unexpected type: $($defaultConfig.GetType().FullName)"
            }
        } else {
            $selectedDefaultConfig = $null
            Microsoft.PowerShell.Utility\Write-Verbose 'No suitable default configuration found'
        }

        # Debug: Log the structure of the selected default configuration
        if ($null -ne $selectedDefaultConfig) {
            Microsoft.PowerShell.Utility\Write-Verbose '=== DEBUG: Selected Default Configuration ==='
            if ($selectedDefaultConfig -is [hashtable]) {
                Microsoft.PowerShell.Utility\Write-Verbose "Configuration is a hashtable with keys: $($selectedDefaultConfig.Keys -join ', ')"
                foreach ($key in $selectedDefaultConfig.Keys) {
                    $value = if ($null -eq $selectedDefaultConfig[$key]) { '(null)' } else { $selectedDefaultConfig[$key] }
                    Microsoft.PowerShell.Utility\Write-Verbose "  $key = $value"
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "Configuration type: $($selectedDefaultConfig.GetType().FullName)"
            }
            Microsoft.PowerShell.Utility\Write-Verbose '=== END DEBUG ==='
        }

        # for each property, use the priority: parameter > session > preferences > auto-selected default
        foreach ($propertyName in @('Model', 'HuggingFaceIdentifier', 'MaxToken', 'Cpu', 'Gpu', 'TTLSeconds', 'ApiEndpoint', 'ApiKey', 'TimeoutSeconds', 'NoSupportForJsonSchema', 'NoSupportForImageUpload', 'NoSupportForToolCalls')) {

            $parameterValue = $null
            $parameterExplicitlyProvided = $false
            switch ($propertyName) {
                'Model' {
                    $parameterValue = $Model
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('Model')
                }
                'HuggingFaceIdentifier' {
                    $parameterValue = $HuggingFaceIdentifier
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('HuggingFaceIdentifier')
                }
                'MaxToken' {
                    $parameterValue = $MaxToken
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('MaxToken')
                }
                'Cpu' {
                    $parameterValue = $Cpu
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('Cpu')
                }
                'Gpu' {
                    $parameterValue = $Gpu
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('Gpu')
                }
                'TTLSeconds' {
                    $parameterValue = $TTLSeconds
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('TTLSeconds')
                }
                'ApiEndpoint' {
                    $parameterValue = $ApiEndpoint
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('ApiEndpoint')
                }
                'ApiKey' {
                    $parameterValue = $ApiKey
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('ApiKey')
                }
                'TimeoutSeconds' {
                    $parameterValue = $TimeoutSeconds
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('TimeoutSeconds')
                }
                'NoSupportForJsonSchema' {
                    $parameterValue = $NoSupportForJsonSchema
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('NoSupportForJsonSchema')
                }
                'NoSupportForImageUpload' {
                    $parameterValue = $NoSupportForImageUpload
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('NoSupportForImageUpload')
                }
                'NoSupportForToolCalls' {
                    $parameterValue = $NoSupportForToolCalls
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('NoSupportForToolCalls')
                }
            }

            # get the final value using priority logic
            $finalValue = Get-SettingValue `
                -propertyName $propertyName `
                -parameterValue $parameterValue `
                -parameterExplicitlyProvided $parameterExplicitlyProvided `
                -llmQueryType $LLMQueryType `
                -sessionOnly:$SessionOnly `
                -skipSession:$SkipSession `
                -defaultConfig $selectedDefaultConfig

            $result[$propertyName] = $finalValue
        }
    }

    end {

        # log final result summary
        Microsoft.PowerShell.Utility\Write-Verbose '=== Final LLM Settings Summary ==='
        Microsoft.PowerShell.Utility\Write-Verbose "LLMQueryType: $LLMQueryType"
        foreach ($key in $result.Keys) {
            $value = if ($null -eq $result[$key]) { '(null)' } else { $result[$key] }
            Microsoft.PowerShell.Utility\Write-Verbose "$key = $value"
        }
        Microsoft.PowerShell.Utility\Write-Verbose '=== End Summary ==='

        # return the completed settings hashtable to the caller
        return $result
    }
}
################################################################################