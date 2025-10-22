<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Get-AIDefaultLLMSettings.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.308.2025
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
################################################################################
<#
.SYNOPSIS
Gets all available default LLM settings configurations for AI operations in GenXdev.AI.

.DESCRIPTION
This function retrieves all available LLM (Large Language Model) configurations
from the default settings JSON file. It supports the same filtering and memory
selection logic as Get-AILLMSettings, but returns all matching configurations
instead of just one selected co                } else {
                    # use system RAM for memory checking
                    $memoryToCheck = [math]::Round(
                        (CimCmdlets\Get-CimInstance `
                            -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                    )
                    Microsoft.PowerShell.Utility\Write-Verbose "Using system RAM only: $memoryToCheck GB"
                }ion.

When used without -AutoSelect, it returns all configurations for the specified
query type with their complete properties including RequiredMemoryGB.

When used with -AutoSelect, it applies the same memory-based selection logic
as Get-AILLMSettings and returns only the best matching configuration.

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
Filter configurations by model identifier or pattern.

.PARAMETER HuggingFaceIdentifier
Filter configurations by LM Studio specific model identifier.

.PARAMETER MaxToken
Filter configurations by maximum number of tokens.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations. Used for memory selection strategy.

.PARAMETER Gpu
GPU offload level (-2=Auto through 1=Full). Used for memory selection strategy.

.PARAMETER TTLSeconds
Filter configurations by time-to-live in seconds for cached AI responses.

.PARAMETER ApiEndpoint
Filter configurations by API endpoint URL.

.PARAMETER ApiKey
Filter configurations by API key.

.PARAMETER TimeoutSeconds
Filter configurations by timeout in seconds.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER AutoSelect
When specified, applies memory-based auto-selection logic and returns only
the best matching configuration based on available system memory. This makes
the function behave like Get-AILLMSettings.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving.

.PARAMETER SkipSession
When specified, skips session settings and retrieves only from persistent
preferences or defaults.

.EXAMPLE
Get-AIDefaultLLMSettings -LLMQueryType "Coding"

Gets all available default configurations for Coding query type.

.EXAMPLE
Get-AIDefaultLLMSettings -LLMQueryType "Coding" -AutoSelect

Gets the best configuration for Coding query type based on available memory.

.EXAMPLE
Get-AIDefaultLLMSettings -LLMQueryType "Coding" -Cpu 8

Gets all Coding configurations, with memory strategy set for CPU-only.

.EXAMPLE
Get-AIDefaultLLMSettings -LLMQueryType "ToolUse" -AutoSelect -Gpu 2

Gets the best ToolUse configuration based on GPU memory with offload level 2.

#>
################################################################################
function Get-AIDefaultLLMSettings {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([hashtable[]])]
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
            HelpMessage = 'Filter configurations by model identifier or pattern'
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by maximum number of tokens'
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations (for memory strategy)'
        )]
        [int] $Cpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("GPU offload level for memory strategy. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                'offloaded to GPU. If a number between 0 and 1, ' +
                'that fraction of layers will be offloaded to the ' +
                'GPU. -1 = LM Studio will decide how much to ' +
                'offload to the GPU. -2 = Auto'))]
        [int] $Gpu,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by time-to-live in seconds'
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by API endpoint URL'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by API key'
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by timeout in seconds'
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Apply memory-based auto-selection and return only the best configuration'
        )]
        [switch] $AutoSelect,
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

        Microsoft.PowerShell.Utility\Write-Verbose '=== Get-AIDefaultLLMSettings Started ==='
        Microsoft.PowerShell.Utility\Write-Verbose "LLMQueryType: $LLMQueryType"
        Microsoft.PowerShell.Utility\Write-Verbose "AutoSelect: $AutoSelect"
        Microsoft.PowerShell.Utility\Write-Verbose "SessionOnly: $SessionOnly"
        Microsoft.PowerShell.Utility\Write-Verbose "SkipSession: $SkipSession"
        Microsoft.PowerShell.Utility\Write-Verbose "ClearSession: $ClearSession"

        # log provided parameter values for filtering
        $filterParams = @()
        if ($PSBoundParameters.ContainsKey('Model')) { $filterParams += "Model=$Model" }
        if ($PSBoundParameters.ContainsKey('HuggingFaceIdentifier')) { $filterParams += "HuggingFaceIdentifier=$HuggingFaceIdentifier" }
        if ($PSBoundParameters.ContainsKey('MaxToken')) { $filterParams += "MaxToken=$MaxToken" }
        if ($PSBoundParameters.ContainsKey('Cpu')) { $filterParams += "Cpu=$Cpu" }
        if ($PSBoundParameters.ContainsKey('Gpu')) { $filterParams += "Gpu=$Gpu" }
        if ($PSBoundParameters.ContainsKey('TTLSeconds')) { $filterParams += "TTLSeconds=$TTLSeconds" }
        if ($PSBoundParameters.ContainsKey('ApiEndpoint')) { $filterParams += "ApiEndpoint=$ApiEndpoint" }
        if ($PSBoundParameters.ContainsKey('ApiKey')) { $filterParams += 'ApiKey=(redacted)' }
        if ($PSBoundParameters.ContainsKey('TimeoutSeconds')) { $filterParams += "TimeoutSeconds=$TimeoutSeconds" }

        if ($filterParams.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose "Filter parameters: $($filterParams -join ', ')"
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose 'No filter parameters provided'
        }

        # determine memory selection strategy based on Gpu and Cpu parameters (only if AutoSelect is enabled)
        $selectByFreeRam = $false
        $selectByFreeGpuRam = $false
        $selectByCombinedMemory = $false

        if ($AutoSelect) {
            Microsoft.PowerShell.Utility\Write-Verbose '=== Memory Selection Strategy Analysis (AutoSelect enabled) ==='
            Microsoft.PowerShell.Utility\Write-Verbose "Gpu parameter provided: $($PSBoundParameters.ContainsKey('Gpu'))"
            Microsoft.PowerShell.Utility\Write-Verbose "Cpu parameter provided: $($PSBoundParameters.ContainsKey('Cpu'))"

            if ($PSBoundParameters.ContainsKey('Gpu') -and $PSBoundParameters.ContainsKey('Cpu')) {
                # both specified, use combined memory
                $selectByCombinedMemory = $true
                Microsoft.PowerShell.Utility\Write-Verbose 'Strategy: COMBINED MEMORY (both Gpu and Cpu parameters specified)'
                Microsoft.PowerShell.Utility\Write-Verbose 'Will use: System RAM + GPU RAM for configuration selection'
            } elseif ($PSBoundParameters.ContainsKey('Gpu')) {
                # only GPU specified, prefer GPU memory
                $selectByFreeGpuRam = $true
                Microsoft.PowerShell.Utility\Write-Verbose 'Strategy: GPU MEMORY (only Gpu parameter specified)'
                Microsoft.PowerShell.Utility\Write-Verbose 'Will use: GPU RAM with system RAM fallback for configuration selection'
            } elseif ($PSBoundParameters.ContainsKey('Cpu')) {
                # only CPU specified, use system RAM
                $selectByFreeRam = $true
                Microsoft.PowerShell.Utility\Write-Verbose 'Strategy: SYSTEM RAM (only Cpu parameter specified)'
                Microsoft.PowerShell.Utility\Write-Verbose 'Will use: System RAM only for configuration selection'
            } else {
                # neither specified, use combined memory as default
                $selectByCombinedMemory = $true
                Microsoft.PowerShell.Utility\Write-Verbose 'Strategy: COMBINED MEMORY (default - no Gpu/Cpu parameters specified)'
                Microsoft.PowerShell.Utility\Write-Verbose 'Will use: System RAM + GPU RAM for configuration selection'
            }
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose 'AutoSelect disabled - will return all matching configurations'
        }

        # handle clearing session variables first if requested
        if ($ClearSession) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Clearing session variables (ClearSession=true)'
            # Note: Session clearing logic would be similar to Get-AILLMSettings if needed
        }
    }

    process {

        try {
            Microsoft.PowerShell.Utility\Write-Verbose 'Loading defaults from JSON configuration...'

            # construct path to default settings JSON file
            $defaultsPath = Microsoft.PowerShell.Management\Join-Path `
                $PSScriptRoot 'defaultsettings.json'

            Microsoft.PowerShell.Utility\Write-Verbose "JSON path: $defaultsPath"

            # read and parse JSON content
            $jsonContent = Microsoft.PowerShell.Management\Get-Content `
                -LiteralPath $defaultsPath `
                -Raw `
                -ErrorAction Stop

            # convert JSON to PowerShell object
            $defaultsJson = $jsonContent | `
                    Microsoft.PowerShell.Utility\ConvertFrom-Json `
                    -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose 'JSON loaded successfully'

            # extract configurations for the specified query type
            $defaultConfigs = $null
            if ($defaultsJson.PSObject.Properties.Name -contains $LLMQueryType) {
                $defaultConfigs = $defaultsJson.$LLMQueryType
                Microsoft.PowerShell.Utility\Write-Verbose "Found $($defaultConfigs.Count) default configurations for query type: $LLMQueryType"
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "No configurations found for query type: $LLMQueryType"
                return [hashtable[]]@()
            }

            # return empty array if no configurations found
            if ($null -eq $defaultConfigs -or $defaultConfigs.Count -eq 0) {
                Microsoft.PowerShell.Utility\Write-Verbose 'No default configurations available'
                return [hashtable[]]@()
            }

            # convert configurations to hashtables and apply filters
            $results = @()
            foreach ($config in $defaultConfigs) {

                # convert to hashtable
                $configHash = @{}
                foreach ($property in $config.PSObject.Properties) {
                    $configHash[$property.Name] = $property.Value
                }

                # apply filters if specified - only filter if parameter has a non-null, non-empty value
                $includeConfig = $true

                if ($PSBoundParameters.ContainsKey('Model') -and -not [String]::IsNullOrWhiteSpace($Model) -and $configHash.Model -notlike $Model) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose "Config filtered out: Model '$($configHash.Model)' does not match filter '$Model'"
                }

                if ($includeConfig -and $PSBoundParameters.ContainsKey('HuggingFaceIdentifier') -and -not [String]::IsNullOrWhiteSpace($HuggingFaceIdentifier) -and $configHash.HuggingFaceIdentifier -ne $HuggingFaceIdentifier) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose "Config filtered out: HuggingFaceIdentifier '$($configHash.HuggingFaceIdentifier)' does not match filter '$HuggingFaceIdentifier'"
                }

                if ($includeConfig -and $PSBoundParameters.ContainsKey('MaxToken') -and $null -ne $MaxToken -and $MaxToken -ne 0 -and $null -ne $configHash.MaxToken -and $configHash.MaxToken -ne $MaxToken) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose "Config filtered out: MaxToken '$($configHash.MaxToken)' does not match filter '$MaxToken'"
                }

                if ($includeConfig -and $PSBoundParameters.ContainsKey('TTLSeconds') -and $null -ne $TTLSeconds -and $TTLSeconds -ne 0 -and $null -ne $configHash.TTLSeconds -and $configHash.TTLSeconds -ne $TTLSeconds) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose "Config filtered out: TTLSeconds '$($configHash.TTLSeconds)' does not match filter '$TTLSeconds'"
                }

                if ($includeConfig -and $PSBoundParameters.ContainsKey('ApiEndpoint') -and -not [String]::IsNullOrWhiteSpace($ApiEndpoint) -and $configHash.ApiEndpoint -ne $ApiEndpoint) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose "Config filtered out: ApiEndpoint '$($configHash.ApiEndpoint)' does not match filter '$ApiEndpoint'"
                }

                if ($includeConfig -and $PSBoundParameters.ContainsKey('ApiKey') -and -not [String]::IsNullOrWhiteSpace($ApiKey) -and $configHash.ApiKey -ne $ApiKey) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose 'Config filtered out: ApiKey does not match filter'
                }

                if ($includeConfig -and $PSBoundParameters.ContainsKey('TimeoutSeconds') -and $null -ne $TimeoutSeconds -and $TimeoutSeconds -ne 0 -and $null -ne $configHash.TimeoutSeconds -and $configHash.TimeoutSeconds -ne $TimeoutSeconds) {
                    $includeConfig = $false
                    Microsoft.PowerShell.Utility\Write-Verbose "Config filtered out: TimeoutSeconds '$($configHash.TimeoutSeconds)' does not match filter '$TimeoutSeconds'"
                }

                if ($includeConfig) {
                    $results += $configHash
                    Microsoft.PowerShell.Utility\Write-Verbose "Config included: Model='$($configHash.Model)' RequiredMemoryGB='$($configHash.RequiredMemoryGB)'"
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose "After filtering: $($results.Count) configurations remain"

            # apply auto-selection if requested
            if ($AutoSelect -and $results.Count -gt 0) {

                Microsoft.PowerShell.Utility\Write-Verbose '=== Applying AutoSelect Memory-Based Selection ==='

                $memoryToCheck = 0

                # determine memory to check based on selection type
                if ($selectByFreeGpuRam) {

                    Microsoft.PowerShell.Utility\Write-Verbose 'Checking GPU memory...'

                    try {
                        # query for NVIDIA CUDA-compatible GPUs
                        $cudaGpus = CimCmdlets\Get-CimInstance `
                            -Class Win32_VideoController | `
                                Microsoft.PowerShell.Core\Where-Object {
                                $_.AdapterRAM -gt 0 -and
                                ($_.Name -like '*NVIDIA*' -or $_.Description -like '*NVIDIA*')
                            }

                        # calculate total GPU memory if CUDA GPUs found
                        if ($cudaGpus) {
                            $memoryToCheck = [math]::Round(
                                ($cudaGpus | `
                                        Microsoft.PowerShell.Utility\Measure-Object `
                                        -Property AdapterRAM `
                                        -Sum).Sum / 1024 / 1024 / 1024, 2
                            )
                            Microsoft.PowerShell.Utility\Write-Verbose "Found $($cudaGpus.Count) CUDA GPU(s), total memory: $memoryToCheck GB"
                        } else {
                            # fallback to system RAM if no CUDA GPUs found
                            $memoryToCheck = [math]::Round(
                                (CimCmdlets\Get-CimInstance `
                                    -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                            )
                            Microsoft.PowerShell.Utility\Write-Verbose "No CUDA GPUs found, fallback to system RAM: $memoryToCheck GB"
                        }
                    }
                    catch {
                        # fallback to system RAM on error
                        $memoryToCheck = [math]::Round(
                            (CimCmdlets\Get-CimInstance `
                                -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                        )
                        Microsoft.PowerShell.Utility\Write-Verbose "Error checking GPU memory, fallback to system RAM: $memoryToCheck GB. Error: $($_.Exception.Message)"
                    }
                } elseif ($selectByCombinedMemory) {

                    Microsoft.PowerShell.Utility\Write-Verbose 'Checking combined CPU + GPU memory...'

                    try {
                        # get system RAM
                        $systemRam = [math]::Round(
                            (CimCmdlets\Get-CimInstance `
                                -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                        )
                        Microsoft.PowerShell.Utility\Write-Verbose "System RAM total: $systemRam GB"

                        # get GPU RAM
                        $gpuRam = 0
                        $cudaGpus = CimCmdlets\Get-CimInstance `
                            -Class Win32_VideoController | `
                                Microsoft.PowerShell.Core\Where-Object {
                                $_.AdapterRAM -gt 0 -and
                                ($_.Name -like '*NVIDIA*' -or $_.Description -like '*NVIDIA*')
                            }

                        if ($cudaGpus) {
                            $gpuRam = [math]::Round(
                                ($cudaGpus | `
                                        Microsoft.PowerShell.Utility\Measure-Object `
                                        -Property AdapterRAM `
                                        -Sum).Sum / 1024 / 1024 / 1024, 2
                            )
                            Microsoft.PowerShell.Utility\Write-Verbose "GPU RAM available: $gpuRam GB from $($cudaGpus.Count) CUDA GPU(s)"
                        } else {
                            Microsoft.PowerShell.Utility\Write-Verbose 'No CUDA GPUs found, GPU RAM: 0 GB'
                        }

                        # combine both memory types
                        $memoryToCheck = $systemRam + $gpuRam
                        Microsoft.PowerShell.Utility\Write-Verbose "Combined memory: $systemRam GB (RAM) + $gpuRam GB (GPU) = $memoryToCheck GB total"
                    }
                    catch {
                        # fallback to system RAM only on error
                        $memoryToCheck = [math]::Round(
                            (CimCmdlets\Get-CimInstance `
                                -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                        )
                        Microsoft.PowerShell.Utility\Write-Verbose "Error checking combined memory, fallback to system RAM only: $memoryToCheck GB. Error: $($_.Exception.Message)"
                    }
                } else {
                    # use system RAM for memory checking
                    $memoryToCheck = [math]::Round(
                        (CimCmdlets\Get-CimInstance `
                            -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                    )
                    Microsoft.PowerShell.Utility\Write-Verbose "Using system RAM only: $memoryToCheck GB"
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Total memory to check against requirements: $memoryToCheck GB"

                # find best configuration based on available memory
                Microsoft.PowerShell.Utility\Write-Verbose 'Evaluating configurations (checking from highest to lowest requirements)...'
                $selectedConfig = $null

                for ($i = $results.Count - 1; $i -ge 0; $i--) {

                    $config = $results[$i]
                    $configMemReq = if ($null -eq $config.RequiredMemoryGB) { 'None' } else { "$($config.RequiredMemoryGB) GB" }
                    Microsoft.PowerShell.Utility\Write-Verbose "Config $i - RequiredMemoryGB: $configMemReq"

                    # select config if no memory requirement or requirement is met
                    if ($null -eq $config.RequiredMemoryGB -or `
                            $config.RequiredMemoryGB -le $memoryToCheck) {

                        $selectedConfig = $config
                        Microsoft.PowerShell.Utility\Write-Verbose "SELECTED Config $i - Memory requirement met ($configMemReq is acceptable with $memoryToCheck GB available)"
                        break
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "Config $i - Memory requirement NOT met ($configMemReq exceeds $memoryToCheck GB available)"
                    }
                }

                if ($null -ne $selectedConfig) {
                    Microsoft.PowerShell.Utility\Write-Verbose 'AutoSelect result: 1 configuration selected'
                    return [hashtable[]]@($selectedConfig)
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose 'AutoSelect result: No configuration meets memory requirements'
                    return [hashtable[]]@()
                }
            }

            # return all matching configurations (no auto-selection)
            Microsoft.PowerShell.Utility\Write-Verbose "Returning all $($results.Count) matching configurations"
            return [hashtable[]]$results

        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Error loading default configurations: $($_.Exception.Message)"
            throw "Failed to load default LLM settings: $($_.Exception.Message)"
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose '=== Get-AIDefaultLLMSettings Completed ==='
    }
}
################################################################################