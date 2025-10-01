<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : EnsureComfyUIModel.ps1
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
###############################################################################
<#
.SYNOPSIS
Ensures specified ComfyUI models are available locally with automatic download

.DESCRIPTION
Verifies that specified ComfyUI models exist in the local models directory.
If models are not found locally, downloads them from predefined URLs.
When called without parameters, downloads all supported models one-by-one.
The function supports all models listed in SupportedComfyUIModels.json.

This function handles the complete model lifecycle: verification, download,
and placement in the correct ComfyUI models directory. It provides progress
feedback during downloads and validates file integrity after completion.

SUPPORTED MODELS:
The function uses a ValidateSet to ensure only supported models are accepted.
Each model has predefined download URLs from trusted sources like Hugging Face.
Models include popular checkpoints like DreamShaper,
Juggernaut XL, and others commonly used for AI image generation.

.PARAMETER ModelName
The name of the model from the supported list. Must be one of the predefined
model names that have associated download URLs. If not specified, all supported
models will be downloaded. The ValidateSet attribute ensures only valid model
names are accepted.

.PARAMETER Folder
Subfolder under models/ where the model should be stored. Common values include
checkpoints, text_encoders, vae, loras, etc. Defaults to "checkpoints" for
standard diffusion models.

.PARAMETER Force
Forces re-download of the model even if it already exists locally. Useful for
updating corrupted files or ensuring you have the latest version of a model.
When not specified, existing local models are returned without downloading.

.PARAMETER ModelPath
Optional custom path to set as the base path in extra_model_paths.yaml for this
model. If provided, updates the ComfyUI configuration to use this path for
checkpoints.

.EXAMPLE
EnsureComfyUIModel

Downloads all supported models: Downloads every model from the supported list
one-by-one if they don't already exist locally. Useful for initial setup.

.EXAMPLE
EnsureComfyUIModel -ModelName "Stable Diffusion 2.1"

Basic usage: Ensures the Stable Diffusion 2.1 model is available locally.
If not found, downloads it from the predefined Hugging Face URL.

.EXAMPLE
EnsureComfyUIModel "DreamShaper"

Short usage: Ensures the DreamShaper model is available locally using
positional parameter.

.EXAMPLE
EnsureComfyUIModel -ModelName "Juggernaut XL" -Force -Verbose

Force re-download: Downloads the model even if it already exists locally.
Provides detailed progress information during the download process.

.EXAMPLE
EnsureComfyUIModel -ModelName "Stable Diffusion 2.1" -ModelPath "D:\CustomModels"

Sets a custom model path in extra_model_paths.yaml and ensures the model.
#>
function EnsureComfyUIModel {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Model name from the supported list. If not specified, all models will be downloaded"
        )]
        [ValidateSet("Stable Diffusion 1.5", "Stable Diffusion 2.1", "Analog Diffusion",
                     "OpenJourney", "DreamShaper", "Protogen", "Juggernaut XL",
                     "SDXL Base 1.0", "SDXL Turbo",
                     "AbyssOrangeMix3")]
        [string] $ModelName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Subfolder under models/ where the model should be stored"
        )]
        [Alias("Subfolder")]
        [string] $Folder = "checkpoints",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces re-download of the model even if it already exists locally"
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom path to set as the base path in extra_model_paths.yaml for this model"
        )]
        [string] $ModelPath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width,
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height,
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X,
        #######################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y,
        #######################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = 'Array of keys to send to the ComfyUI window after ready'
        )]
        [string[]] $KeysToSend,
        #######################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between key send operations'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        #######################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Timeout in seconds to wait for ComfyUI server readiness'
        )]
        [int] $Timeout = 600,
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
        [switch] $FullScreen,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [switch] $RestoreFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Position windows side by side'
        )]
        [switch] $SideBySide,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [switch] $FocusWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
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
        [switch] $SendKeyEscape,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [switch] $SendKeyUseShiftEnter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the ComfyUI window during initialization process'
        )]
        [switch] $ShowWindow
        #######################################################################
    )

    begin {

        # initialize collections
        $restartAfterModelDownload = $false
        $ensuredModels = @()

        # update extra_model_paths.yaml if modelpath provided
        if (-not [string]::IsNullOrWhiteSpace($ModelPath)) {

            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Set-ComfyUIModelPath"
            $params.ModelPath = $ModelPath
            GenXdev.AI\Set-ComfyUIModelPath @params
        }
        else {

            # get model path from comfyui configuration
            $modelPath = GenXdev.AI\Get-ComfyUIModelPath -Subfolder $Folder
        }

        $modelPath = GenXdev.FileSystem\Expand-Path $modelPath -CreateDirectory

        if (-not $modelPath) {

            $modelPath = Microsoft.PowerShell.Management\Join-Path `
                $env:LOCALAPPDATA `
                "Programs\@comfyorgcomfyui-electron\resources\ComfyUI\models\$Folder"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Models path: ${modelPath}"

        # create directory if needed
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $modelPath)) {

            $null = Microsoft.PowerShell.Management\New-Item `
                -Path $modelPath `
                -ItemType Directory `
                -Force
        }

        # load supported models from json configuration file
        $jsonPath = Microsoft.PowerShell.Management\Join-Path `
            $PSScriptRoot "SupportedComfyUIModels.json"

        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $jsonPath)) {

            throw "SupportedComfyUIModels.json not found at: ${jsonPath}"
        }

        $supportedModels = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath $jsonPath `
            | Microsoft.PowerShell.Utility\ConvertFrom-Json

        # filter models if specific modelname provided
        if ($ModelName) {
            $modelsToProcess = @($supportedModels | Microsoft.PowerShell.Core\Where-Object { $_.Name -eq $ModelName })
        } else {
            $modelsToProcess = $supportedModels
        }

        $isUnattended = GenXdev.Helpers\Test-UnattendedMode -CallersInvocation $MyInvocation
        $ensureparams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\EnsureComfyUI"
    }

    process {

        foreach ($model in $modelsToProcess) {

            # get model details
            $actualModelName = $model.FileName
            $modelDownloadUrl = $model.DownloadUrl
            $huggingFaceRepo = $model.HuggingFaceRepo

            # construct path to check if model exists
            $existingFile = Microsoft.PowerShell.Management\Join-Path `
                $modelPath $actualModelName

            # check if model exists locally
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $existingFile) {

                if (-not $Force) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Model found: ${existingFile}"

                    $ensuredModels += $existingFile

                    Microsoft.PowerShell.Utility\Write-Output $existingFile

                    continue
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing model: ${actualModelName}"

            # show progress for download operation
            if ($Force -or -not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $existingFile)) {

                Microsoft.PowerShell.Utility\Write-Progress `
                    -Activity "Ensuring ComfyUI Model" `
                    -Status "Downloading: ${actualModelName}"
            }

            # set target path for downloaded file
            $targetPath = Microsoft.PowerShell.Management\Join-Path `
                $modelPath $actualModelName

            # perform download if forced or file doesn't exist
            if ($Force -or -not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $existingFile)) {

                try {

                    # create temporary file for download
                    $tempFile = [System.IO.Path]::GetTempFileName()

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Downloading from: ${modelDownloadUrl} to ${tempFile}"

                    # download file from url to temporary location
                    Microsoft.PowerShell.Utility\Invoke-WebRequest `
                        -Uri $modelDownloadUrl `
                        -OutFile $tempFile `
                        -ErrorAction Stop

                    # get downloaded file information
                    $downloadedFile = Microsoft.PowerShell.Management\Get-Item `
                        -LiteralPath $tempFile

                    # verify file was downloaded successfully
                    if ($downloadedFile.Length -eq 0) {

                        throw "Downloaded file is empty"
                    }

                    # move file from temporary location to target path
                    Microsoft.PowerShell.Management\Move-Item `
                        -LiteralPath $tempFile `
                        -Destination $targetPath `
                        -Force

                    # get final file information for logging
                    $fileInfo = Microsoft.PowerShell.Management\Get-Item `
                        -LiteralPath $targetPath

                    $fileSizeMb = [Math]::Round($fileInfo.Length / 1MB, 2)

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Downloaded '${actualModelName}' to ${targetPath} (${fileSizeMb} MB)"

                    if ($restartAfterModelDownload) {

                        GenXdev.AI\Stop-ComfyUI
                    }
                    else {
                        GenXdev.AI\EnsureComfyUI @ensureparams

                        # refresh ComfyUI's model list after successful download
                        try {
                            Microsoft.PowerShell.Utility\Write-Verbose "Refreshing ComfyUI model list..."
                            $null = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                                -Uri "${script:comfyUIApiUrl}/object_info" `
                                -Method GET `
                                -TimeoutSec 10 `
                                -ErrorAction Stop
                            Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI model list refreshed successfully"
                        } catch {
                            Microsoft.PowerShell.Utility\Write-Warning "Could not refresh ComfyUI model list: $_"
                            Microsoft.PowerShell.Utility\Write-Warning "You may need to restart ComfyUI for the new model to be detected"
                        }
                    }

                    $ensuredModels += $targetPath

                    Microsoft.PowerShell.Utility\Write-Output $targetPath
                }
                catch {

                    # cleanup temporary file if it exists
                    if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $tempFile) {

                        $null = Microsoft.PowerShell.Management\Remove-Item `
                            -LiteralPath $tempFile `
                            -Force `
                            -ErrorAction SilentlyContinue
                    }

                    if ($isUnattended) {

                        Microsoft.PowerShell.Utility\Write-Error `
                            "Failed to download '${actualModelName}': $_"
                    }
                    else {
                        # open huggingface repo in browser
                        $repoUrl = $huggingFaceRepo
                        Microsoft.PowerShell.Utility\Write-Host `
                            "Opening HuggingFace repository for manual download: ${repoUrl}"
                        GenXdev.Webbrowser\Open-Webbrowser $repoUrl -SideBySide

                        # display instructions for manual placement
                        Microsoft.PowerShell.Utility\Write-Host `
                            "Please download '${actualModelName}' and place it at: ${targetPath}"
                        Microsoft.PowerShell.Utility\Write-Host `
                            "After placing the file, press Enter to continue..."

                        # pause for user action
                        $null = Microsoft.PowerShell.Utility\Read-Host

                        # check if file was placed manually
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $targetPath) {
                            $ensuredModels += $targetPath
                            Microsoft.PowerShell.Utility\Write-Output $targetPath
                            Microsoft.PowerShell.Utility\Write-Verbose `
                                "Model found after manual placement: ${targetPath}"
                        } else {
                            throw "Model '${actualModelName}' not found at ${targetPath} after manual download"
                        }
                    }
                }
                finally {

                    # clear progress indicator
                    Microsoft.PowerShell.Utility\Write-Progress `
                        -Activity "Ensuring ComfyUI Model" `
                        -Completed
                }
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Model exists: ${targetPath}"

                $ensuredModels += $targetPath

                Microsoft.PowerShell.Utility\Write-Output $targetPath
            }
        }
    }

    end {

        GenXdev.AI\EnsureComfyUI @ensureparams

        if ($ensuredModels.Count -gt 0) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Ensured $($ensuredModels.Count) model(s)."
        }

    }
}
###############################################################################