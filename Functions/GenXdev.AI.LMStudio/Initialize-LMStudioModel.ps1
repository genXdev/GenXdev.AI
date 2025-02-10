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
Initialize-LMStudioModel -Model "qwen-7b" -ShowWindow -MaxToken 2048

.EXAMPLE
o "vicuna" -ttl 3600
#>
function Initialize-LMStudioModel {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
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
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [int]$MaxToken = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API"
        )]
        [Alias("ttl")]
        [int]$TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show LM Studio window during initialization"
        )]
        [switch]$ShowWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "List of preferred models to try if specified not found"
        )]
        [string[]]$PreferredModels = @(
            "qwen-7b", "vicuna", "alpaca", "gpt", "mistral", "falcon", "mpt",
            "koala", "wizard", "guanaco", "bloom", "rwkv", "camel", "pythia",
            "baichuan"
        )
        ########################################################################
    )

    begin {

        # get lm studio installation paths
        $paths = Get-LMStudioPaths

        # attempt to start the server asynchronously
        $null = Start-Job -ScriptBlock {
            param($paths)
            & $paths.LMSExe server start
        } -ArgumentList $paths |
        Wait-Job -Timeout 10 -ErrorAction SilentlyContinue

        # verify installation and process status
        $installationOk = Test-LMStudioInstallation
        $processOk = Test-LMStudioProcess

        # handle installation and process initialization if needed
        if (-not $installationOk -or -not $processOk) {

            if (-not $installationOk) {
                $null = Install-LMStudioApplication
                $installationOk = Test-LMStudioInstallation

                if (-not $installationOk) {
                    throw "LM Studio not found or properly installed"
                }
            }

            $null = Start-LMStudioApplication
        }

        Write-Verbose "Using LM Studio CLI executable: $($paths.LMSExe)"
    }

    process {

        # get current model list and search for requested model
        $modelList = Get-LMStudioModelList
        $foundModel = $modelList |
        Where-Object { $_.path -like "*$Model*" } |
        Select-Object -First 1

        # attempt to download model if not found and identifier provided
        if (-not $foundModel) {
            if (-not [string]::IsNullOrWhiteSpace($ModelLMSGetIdentifier)) {
                $null = & "$($paths.LMSExe)" get $ModelLMSGetIdentifier

                # refresh model list after download
                $modelList = Get-LMStudioModelList
                $foundModel = $modelList |
                Where-Object { $_.path -like "*$Model*" } |
                Select-Object -First 1
            }
        }

        # try preferred models if still not found
        if (-not $foundModel) {
            Write-Verbose "Model '$Model' not found, trying preferred models"

            foreach ($preferredModel in $PreferredModels) {
                $foundModel = $modelList |
                Where-Object { $_.path -like "*$preferredModel*" } |
                Select-Object -First 1

                if ($foundModel) {
                    Write-Verbose "Found preferred model: $($foundModel.path)"
                    break
                }
            }
        }

        if (-not $foundModel) {
            throw "Model '$Model' not found"
        }

        Write-Verbose "Selected model: $($foundModel.path)"

        # check if model is already loaded
        $loadedModels = Get-LMStudioLoadedModelList
        $modelLoaded = $loadedModels |
        Where-Object { $_.path -eq $foundModel.path } |
        Select-Object -First 1

        # load model if not already active
        if ($null -eq $modelLoaded) {

            Write-Verbose "Loading model..."
            $params = [System.Collections.Generic.List[string]]::new()
            $params.Add("load")
            $params.Add($foundModel.path)
            $params.Add("--exact")

            if ($TTLSeconds -gt 0) {
                $null = $params.Add("--ttl")
                $null = $params.Add($TTLSeconds)
            }

            if (Get-HasCapableGpu) {

                $null = $params.Add("--gpu")
            }

            if ($maxToken -gt 0) {

                $null = $params.Add("--context-length")
                $null = $params.Add($maxToken)
            }

            Write-Verbose "Loading model: $modelPath with parameters: $($params|ConvertTo-Json -Compress)"

            $success = Start-Job -ArgumentList @($paths, $params) -ScriptBlock {
                param($paths, $params)

                Start-Process $paths.LMSExe -ArgumentList $params -Wait -NoNewWindow
                $LASTEXITCODE -eq 0
            } |
            Wait-Job -Timeout 1800 |
            Receive-Job

            # retry after unloading all models if load failed
            if (-not $success -and $loadedModels.Count -gt 0) {
                $null = Start-Job -ArgumentList $paths -ScriptBlock {
                    param($paths)
                    Start-Process $paths.LMSExe -ArgumentList @("unload", "--all") `
                        -Wait -NoNewWindow
                    $LASTEXITCODE -eq 0
                } |
                Wait-Job -Timeout 10 |
                Receive-Job

                return Initialize-LMStudioModel @PSBoundParameters
            }
        }

        # verify successful model load
        $loadedModels = Get-LMStudioLoadedModelList
        $modelLoaded = $loadedModels |
        Where-Object { $_.path -eq $foundModel.path } |
        Select-Object -First 1

        if ($null -eq $modelLoaded) {
            $null = Test-LMStudioProcess
            throw "Model failed to load. Check LM-Studio configuration."
        }

        return $modelLoaded
    }

    end {
    }
}
################################################################################
