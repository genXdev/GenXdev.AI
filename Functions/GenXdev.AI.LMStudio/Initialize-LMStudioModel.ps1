################################################################################
<#
.SYNOPSIS
Initializes and loads an AI model in LM Studio.

.DESCRIPTION
Searches for and loads a specified AI model in LM Studio. The function handles
installation verification, process management, and model loading with GPU
support when available.

.PARAMETER Model
Name or partial path of the model to initialize. Searched against available
models.

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier to use for download/initialization.

.PARAMETER MaxToken
Maximum number of tokens allowed in the response. Use -1 for default limit.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests. Use -1 for no TTL.

.PARAMETER ShowWindow
Shows the LM Studio window during initialization if specified.

.PARAMETER PreferredModels
Array of model names to try if specified model is not found.

.EXAMPLE
Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ShowWindow -MaxToken 2048

.EXAMPLE
o "vicuna" -ttl 3600
#>
function Initialize-LMStudioModel {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseUsingScopeModifierInNewRunspaces", "")]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]$Model = [string]::Empty,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [string]$ModelLMSGetIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The number of tokens to consider as context when generating text. If not provided, the default value will be used."
        )]
        [Alias("MaxTokens")]
        [int]$MaxToken = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "TTL (seconds): If provided, when the model is not used for this number of seconds, it will be unloaded."
        )]
        [Alias("ttl")]
        [int]$TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "How much to offload to the GPU. If `"off`", GPU offloading is disabled. If `"max`", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto "
        )]
        [int]$Gpu = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show LM Studio window during initialization"
        )]
        [switch]$ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
        ################1################################################################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "List of preferred models to try if specified not found"
        )]
        [string[]]$PreferredModels = @(
            "qwen2.5-14b-instruct", "vicuna", "alpaca", "gpt", "mistral", "falcon", "mpt",
            "koala", "wizard", "guanaco", "bloom", "rwkv", "camel", "pythia",
            "baichuan"
        )
        ########################################################################
    )

    begin {
        # force stop LM Studio processes if requested
        if ($Force) {

            if ($PSBoundParameters.ContainsKey("Force")) {

                $null = $PSBoundParameters.Remove("Force")
            }
            $Force = $false

            Microsoft.PowerShell.Utility\Write-Verbose "Force parameter specified, stopping LM Studio processes"
            $null = Microsoft.PowerShell.Management\Get-Process "LM Studio", "LMS" -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Management\Stop-Process -Force
        }

        # no model specified?
        if ([string]::IsNullOrWhiteSpace($Model)) {

            # but we do have a model get identifier?
            if (-not [string]::IsNullOrWhiteSpace($ModelLMSGetIdentifier)) {

                # extract model name from get identifier
                if ($ModelLMSGetIdentifier.ToLowerInvariant() -like "https://huggingface.co/lmstudio-community/*-GGUF") {

                    $Model = $ModelLMSGetIdentifier.Substring($ModelLMSGetIdentifier.LastIndexOf("/") + 1).ToLowerInvariant();
                }
                else {

                    $Model = $ModelLMSGetIdentifier
                }
            }

            if ([string]::IsNullOrWhiteSpace($Model)) {

                if (-not $PSBoundParameters.ContainsKey("Model")) {

                    $null = $PSBoundParameters.Add("Model", $Model)
                }
                else {

                    $PSBoundParameters["Model"] = $Model
                }

                if (-not $PSBoundParameters.ContainsKey("ModelLMSGetIdentifier")) {

                    $null = $PSBoundParameters.Add("ModelLMSGetIdentifier", $ModelLMSGetIdentifier)
                }
                else {

                    $null = $PSBoundParameters["ModelLMSGetIdentifier"] = $ModelLMSGetIdentifier
                }

                if (-not $PSBoundParameters.ContainsKey("MaxToken")) {

                    $null = $PSBoundParameters.Add("MaxToken", $ModelLMSGetIdentifier)
                }
                else {

                    $null = $PSBoundParameters["MaxToken"] = $ModelLMSGetIdentifier
                }
            }
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
                    throw "LM Studio not found or properly installed"
                }
            }

            $paths = GenXdev.AI\Get-LMStudioPaths

            if (-not $processOk) {

                # attempt to start the server asynchronously
                $null = GenXdev.AI\Start-LMStudioApplication -WithVisibleWindow:$ShowWindow
            }
        }

        if ($ShowWindow) {

            $null = GenXdev.AI\Get-LMStudioWindow -NoAutoStart -ShowWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Using LM Studio CLI executable: $($paths.LMSExe)"
    }

    process {

        # get current model list and search for requested model
        $modelList = GenXdev.AI\Get-LMStudioModelList
        $foundModel = $modelList |
        Microsoft.PowerShell.Core\Where-Object { $_.path -like "*$Model*" } |
        Microsoft.PowerShell.Utility\Select-Object -First 1

        # attempt to download model if not found and identifier provided
        if (-not $foundModel) {
            if (-not [string]::IsNullOrWhiteSpace($ModelLMSGetIdentifier)) {
                $null = & "$($paths.LMSExe)" get $ModelLMSGetIdentifier

                # refresh model list after download
                $modelList = GenXdev.AI\Get-LMStudioModelList
                $foundModel = $modelList |
                Microsoft.PowerShell.Core\Where-Object { $_.path -like "*$Model*" } |
                Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }

        # try preferred models if still not found
        if (-not $foundModel) {
            Microsoft.PowerShell.Utility\Write-Verbose "Model '$Model' not found, trying preferred models"

            foreach ($preferredModel in $PreferredModels) {
                $foundModel = $modelList |
                Microsoft.PowerShell.Core\Where-Object { $_.path -like "*$preferredModel*" } |
                Microsoft.PowerShell.Utility\Select-Object -First 1

                if ($foundModel) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Found preferred model: $($foundModel.path)"
                    break
                }
            }
        }

        if (-not $foundModel) {
            throw "Model '$Model' not found"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Selected model: $($foundModel.path)"

        # check if model is already loaded
        $loadedModels = GenXdev.AI\Get-LMStudioLoadedModelList
        $modelLoaded = $loadedModels |
        Microsoft.PowerShell.Core\Where-Object { $_.path -eq $foundModel.path } |
        Microsoft.PowerShell.Utility\Select-Object -First 1

        # load model if not already active
        if ($null -eq $modelLoaded) {

            Microsoft.PowerShell.Utility\Write-Verbose "Loading model..."
            $params = [System.Collections.Generic.List[string]]::new()
            $null = $params.Add("load")
            $null = $params.Add($foundModel.path)
            $null = $params.Add("--exact")

            if ($TTLSeconds -gt 0) {
                $null = $params.Add("--ttl")
                $null = $params.Add($TTLSeconds)
            }

            switch ($Gpu) {

                -2 {
                    if (GenXdev.AI\Get-HasCapableGpu) {

                        $null = $params.Add("--gpu 1")
                    }
                    else {

                        $null = $params.Add("--gpu 0")
                    }
                    break;
                }
                default {
                    if ($Gpu -lt 0) { break; }
                    if (($Gpu -eq 0) -and ($Gpu -le 1)) {

                        $null = $params.Add("--gpu $([Math]::Round($Gpu, 2))")
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Warning "Invalid GPU value. Use -2 for autodetect, or 0..1"
                    }
                }
            }

            if ($maxToken -gt 0) {

                $null = $params.Add("--context-length")
                $null = $params.Add($maxToken)
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Loading modeMicrosoft.PowerShell.Utility\ConvertTo-Jsoners: $($params|Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue)"

            $success = Microsoft.PowerShell.Core\Start-Job -ArgumentList @($paths, $params) -ScriptBlock {
                param($lmstudiopaths, $params)

                try {
                    # Redirect stderr to stdout to capture all output
                    $process = Microsoft.PowerShell.Management\Start-Process ($lmstudiopaths.LMSExe) -ArgumentList $params -Wait -NoNewWindow -PassThru `
                        -RedirectStandardOutput $true

                    # Consider success if process exits with code 0 or if we detect the model is actually loaded
                    return ($process.ExitCode -eq 0) -or (GenXdev.AI\Get-LMStudioLoadedMMicrosoft.PowerShell.Core\Where-Objecticrosoft.PowerShell.Core\Where-Object { $_.path -like $params[1] })
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Error during model load: $_"
                    return $false
                }
            }.GetNewClosure() |
            Microsoft.PowerShell.Core\Wait-Job -Timeout 1800 |
            Microsoft.PowerShell.Core\Receive-Job

            # retry after unloading all models if load failed
            if (-not $success -and $loadedModels.Count -gt 0) {
                $null = Microsoft.PowerShell.Core\Start-Job -ArgumentList $paths -ScriptBlock {
                    param($lmstudiopaths)
                    $null = Microsoft.PowerShell.Management\Start-Process ($lmstudiopaths.LMSExe) -ArgumentList @("unload", "--all") `
                        -Wait -NoNewWindow
                    $LASTEXITCODE -eq 0
                } |
                Microsoft.PowerShell.Core\Wait-Job -Timeout 10 |
                Microsoft.PowerShell.Core\Receive-Job

                return GenXdev.AI\Initialize-LMStudioModel @PSBoundParameters
            }
        }

        # verify successful model load
        $loadedModels = GenXdev.AI\Get-LMStudioLoadedModelList
        $modelLoaded = $loadedModels |
        Microsoft.PowerShell.Core\Where-Object { $_.path -eq $foundModel.path } |
        Microsoft.PowerShell.Utility\Select-Object -First 1

        if ($null -eq $modelLoaded) {

            $null = GenXdev.AI\Test-LMStudioProcess -ShowWindow
            throw "Model failed to load. Check LM-Studio configuration."
        }

        return $modelLoaded
    }

    end {
        if ($ShowWindow) {

            $null = GenXdev.AI\Get-LMStudioWindow -NoAutoStart -ShowWindow -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
        }
    }
}
################################################################################