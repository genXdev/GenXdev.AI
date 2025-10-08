<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Invoke-ComfyUIImageGeneration.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.298.2025
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
Comprehensive ComfyUI CLI for all image generation scenarios with automatic
model management and multi-model batch processing

.DESCRIPTION
Advanced unified CLI wrapper for ComfyUI that handles all text-to-image and
image-to-image workflows with intelligent model management and multi-model
generation capabilities. Automatically detects, downloads, and installs
required models, and supports batch generation across multiple models for
comprehensive comparison workflows.

KEY FEATURES:
- Automatic model discovery and installation from supported list
- Multi-model batch generation with the -UseAllModels parameter
- Intelligent architecture detection (SD1.5 vs SDXL) with optimized settings
- Robust error handling and recovery for uninterrupted batch processing
- GPU and CPU optimization with architecture-specific defaults
- Advanced image format conversion and organized output management

MODEL MANAGEMENT:
The function automatically ensures model availability by searching local
ComfyUI installations and downloading from supported list when needed.
The -UseAllModels switch enables comparison generation across
all compatible installed models.

MULTI-MODEL GENERATION:
When -UseAllModels is specified, generates images using every compatible
model found locally. Creates organized output directories with model-specific
naming for easy comparison. Continues processing even if individual models
fail, providing comprehensive batch generation with error resilience.

Based on the proven CPU-optimized version with GPU support added. Automatically
detects and connects to running ComfyUI instances, manages image processing,
handles format conversions, and provides detailed progress feedback for both
single and multi-model generation workflows.

.PARAMETER Prompt
The text prompt for image generation

.PARAMETER NegativePrompt
Negative prompt to exclude unwanted elements (default: "blurry, low quality,
distorted")

.PARAMETER InputImage
Path to input image for img2img processing (optional - if not provided, does
text-to-image)

.PARAMETER OutFile
Path to save the generated image (e.g., C:\temp\output.png). Defaults to
'.\<input_filename>.out.jpg' for img2img or a prompt-based name for txt2img

.PARAMETER Steps
Number of denoising steps (default: 15 for CPU, 20 for GPU)

.PARAMETER ImageWidth
Output image width in pixels (default: 1024)

.PARAMETER ImageHeight
Output image height in pixels (default: 1024)

.PARAMETER CfgScale
CFG Scale for prompt adherence (default: 7.0, range: 1-20)

.PARAMETER Strength
Denoising strength for img2img (default: 0.75, range: 0.1-1.0)

.PARAMETER Seed
Random seed for reproducible results (default: random)

.PARAMETER BatchSize
Number of images to generate (default: 1, max: 4)

.PARAMETER Model
Model checkpoint(s) to use. Can specify a single model name or an array of
multiple models. When multiple models are provided, they are combined with
any models discovered through -UseAllModels. Default: Stable Diffusion 2.1
(improved quality over v1-5 with high downloads)

.PARAMETER Sampler
Sampling method (default: "euler", options: euler, dpmpp_2m, dpmpp_sde,
ddim, etc.)

.PARAMETER Scheduler
Scheduler type (default: "normal", options: normal, karras, exponential,
sgm_uniform)

.PARAMETER CpuThreads
Number of CPU threads to use (default: auto-detect, only used when UseGPU
is false)

.PARAMETER Timeout
Timeout in seconds for ComfyUI operations (default: 600)

.PARAMETER UseGPU
Enable GPU acceleration (default: CPU-only for server-friendly operation)

.PARAMETER NoResizeComfyInputImage
Skip automatic resizing of input images to optimal dimensions

.PARAMETER NoShowWindow
Switch to not show the ComfyUI window

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard

.PARAMETER NoBorders
Removes the borders of the window

.PARAMETER Width
The initial width of the window

.PARAMETER Height
The initial height of the window

.PARAMETER X
The initial X position of the window

.PARAMETER Y
The initial Y position of the window

.PARAMETER Left
Place window on the left side of the screen

.PARAMETER Right
Place window on the right side of the screen

.PARAMETER Top
Place window on the top side of the screen

.PARAMETER Bottom
Place window on the bottom side of the screen

.PARAMETER Centered
Place window in the center of the screen

.PARAMETER FullScreen
Sends F11 to the window

.PARAMETER RestoreFocus
Restore PowerShell window focus

.PARAMETER SideBySide
Position windows side by side

.PARAMETER FocusWindow
Focus the window after opening

.PARAMETER SetForeground
Set the window to foreground after opening

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER KeysToSend
Keys to send to the ComfyUI window

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys

.PARAMETER SendKeyDelayMilliSeconds
Delay in milliseconds between key sends

.PARAMETER Force
Force shutdown of any existing ComfyUI processes before starting

.PARAMETER NoShutdown
Keep ComfyUI running after image generation

.PARAMETER UseAllModels
Generate images using all compatible installed models instead of just
the specified one. Uses all supported models from the hardcoded list.

.PARAMETER ModelPath
Optional custom path to set as the base path in extra_model_paths.yaml for the
specified model(s). If provided, updates the ComfyUI configuration to use this
path for checkpoints.

.EXAMPLE
Invoke-ComfyUIImageGeneration -Prompt "a cat in space" -OutFile "cat.jpg"

Generates an image using the default model (Stable Diffusion 2.1).

.EXAMPLE
Invoke-ComfyUIImageGeneration "a dragon" "blurry" -Model "Juggernaut XL" `
    -UseGPU -Steps 25

Uses the specified SDXL model with GPU acceleration.

.EXAMPLE
generateimage "beautiful landscape" -Model "DreamShaper", `
    -UseAllModels

Generates images with multiple models plus all others.
#>
function Invoke-ComfyUIImageGeneration {

    [CmdletBinding()]
    [Alias("generateimage")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The text prompt for image generation"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Prompt,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Negative prompt to exclude unwanted elements"
        )]
        [string] $NegativePrompt = "blurry, low quality, distorted",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Path to input image for img2img processing"
        )]
        [string] $InputImage,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Path to save the generated image"
        )]
        [string] $OutFile,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Number of denoising steps (default: 15 for CPU, 20 for GPU)"
        )]
        [ValidateRange(1, 100)]
        [int] $Steps,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Output image width in pixels (default: 1024)"
        )]
        [ValidateRange(256, 2048)]
        [int] $ImageWidth,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Output image height in pixels (default: 1024)"
        )]
        [ValidateRange(256, 2048)]
        [int] $ImageHeight,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "CFG Scale for prompt adherence"
        )]
        [ValidateRange(1.0, 20.0)]
        [float] $CfgScale = 7.0,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Denoising strength for img2img"
        )]
        [ValidateRange(0.1, 1.0)]
        [float] $Strength = 0.75,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Random seed for reproducible results"
        )]
        [long] $Seed = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Number of images to generate"
        )]
        [ValidateRange(1, 4)]
        [int] $BatchSize = 1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Model checkpoint(s) to use"
        )]
        [ValidateSet("Stable Diffusion 1.5", "Stable Diffusion 2.1", "Analog Diffusion",
                     "OpenJourney", "DreamShaper", "Protogen", "Juggernaut XL",
                     "SDXL Base 1.0", "SDXL Turbo",
                     "AbyssOrangeMix3")]
        [string[]] $Model = "Stable Diffusion 2.1",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Sampling method"
        )]
        [string] $Sampler = "euler",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Scheduler type"
        )]
        [string] $Scheduler = "normal",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Number of CPU threads to use"
        )]
        [int] $CpuThreads,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Timeout in seconds for ComfyUI operations"
        )]
        [int] $Timeout = 360000,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable GPU acceleration"
        )]
        [switch] $UseGPU,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip automatic resizing of input images"
        )]
        [switch] $NoResizeComfyInputImage,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Do not show the ComfyUI window"
        )]
        [switch] $NoShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The monitor to use"
        )]
        [int] $Monitor = -2,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Removes the borders of the window"
        )]
        [switch] $NoBorders,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the window"
        )]
        [int] $Width,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the window"
        )]
        [int] $Height,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the window"
        )]
        [int] $X,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the window"
        )]
        [int] $Y,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on the left side of the screen"
        )]
        [switch] $Left,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on the right side of the screen"
        )]
        [switch] $Right,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on the top side of the screen"
        )]
        [switch] $Top,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on the bottom side of the screen"
        )]
        [switch] $Bottom,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window in the center of the screen"
        )]
        [switch] $Centered,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Sends F11 to the window"
        )]
        [switch] $FullScreen,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [switch] $RestoreFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Position windows side by side"
        )]
        [switch] $SideBySide,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Focus the window after opening"
        )]
        [switch] $FocusWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set the window to foreground after opening"
        )]
        [switch] $SetForeground,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximize the window after positioning"
        )]
        [switch] $Maximize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Keys to send to the ComfyUI window"
        )]
        [string[]] $KeysToSend,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Escape control characters and modifiers when sending keys"
        )]
        [switch] $SendKeyEscape,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hold keyboard focus on target window when sending keys"
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use Shift+Enter instead of Enter when sending keys"
        )]
        [switch] $SendKeyUseShiftEnter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Delay in milliseconds between key sends"
        )]
        [int] $SendKeyDelayMilliSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force shutdown of any existing ComfyUI processes before starting"
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Keep ComfyUI running after image generation"
        )]
        [Alias('KeepComfyUIRunning')]
        [switch] $NoShutdown,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Generate images using all compatible installed models"
        )]
        [switch] $UseAllModels,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom path to set as the base path in extra_model_paths.yaml for the specified model(s)"
        )]
        [string] $ModelPath
        #######################################################################

    )

    begin {
        $ShowWindow = (-not $NoShowWindow) -and (-not (GenXdev.Helpers\Test-UnattendedMode -CallersInvocation $MyInvocation))

        $callerInvocation = $MyInvocation

        # update extra_model_paths.yaml if modelpath provided
        if (-not [string]::IsNullOrWhiteSpace($ModelPath)) {

            $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Set-ComfyUIModelPath"
            $params.ModelPath = $ModelPath
            GenXdev.AI\Set-ComfyUIModelPath @params
        }

        # determine defaults based on gpu
        $isgpu = $UseGPU.IsPresent

        if (-not $Steps) { $Steps = if ($isgpu) { 20 } else { 15 } }

        if (-not $ImageWidth) { $ImageWidth = 1024 }

        if (-not $ImageHeight) { $ImageHeight = 1024 }

        # validate seed
        if ($Seed -eq -1) { $Seed = Microsoft.PowerShell.Utility\Get-Random -Minimum 0 -Maximum ([long]::MaxValue) }

        # determine cpu threads if not specified
        if (-not $CpuThreads -and -not $UseGPU) {

            $CpuThreads = GenXdev.AI\Get-CPUCore
        }

        $comfyParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'EnsureComfyUI' `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            )

        # ensure comfyui is running
        GenXdev.AI\EnsureComfyUI @comfyParams

        # prepare output
        $allresults = @()

        # determine output path
        $baseoutputdir = $PWD.Path
        $utcTimestamp = "$(Microsoft.PowerShell.Utility\Get-Date -Format 'yyyyMMdd')_$(([System.DateTime]::UtcNow).Ticks)"
        $promptPart = $Prompt -replace '[^a-zA-Z0-9]', '_'
        if ($promptPart.Length -gt 20) { $promptPart = $promptPart.Substring(0, 20) }
        $basefilename = [GenXdev.Helpers.SecurityHelper]::SanitizeFileName("${utcTimestamp}_${promptPart}")
        $baseext = ".png"

        if ($OutFile) {

            $baseoutputdir = [System.IO.Path]::GetDirectoryName($OutFile)

            $basefilename = [System.IO.Path]::GetFileNameWithoutExtension($OutFile)

            $baseext = [System.IO.Path]::GetExtension($OutFile)
        }

        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $baseoutputdir)) {

            $null = Microsoft.PowerShell.Management\New-Item `
                -Path $baseoutputdir `
                -ItemType Directory `
                -Force
        }

        # prepare input image
        $processedimagepath = $InputImage

        if ($InputImage) {

            if (-not $NoResizeComfyInputImage) {

                $processedimagepath = GenXdev.AI\ResizeComfyInputImage -ImagePath $InputImage
            }
        }

        # load supported models from json
        $jsonpath = Microsoft.PowerShell.Management\Join-Path `
            -Path $PSScriptRoot `
            -ChildPath "SupportedComfyUIModels.json"
        $supportedModels = Microsoft.PowerShell.Management\Get-Content -LiteralPath $jsonpath -Raw | Microsoft.PowerShell.Utility\ConvertFrom-Json

        # first, detect which models are actually available in ComfyUI
        $availableModelFiles = @()
        try {
            $availableModelsResponse = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri "${script:comfyUIApiUrl}/object_info" `
                -Method GET `
                -TimeoutSec 5

            if ($availableModelsResponse.CheckpointLoaderSimple -and
                $availableModelsResponse.CheckpointLoaderSimple.input -and
                $availableModelsResponse.CheckpointLoaderSimple.input.required -and
                $availableModelsResponse.CheckpointLoaderSimple.input.required.ckpt_name) {

                $availableModelFiles = $availableModelsResponse.CheckpointLoaderSimple.input.required.ckpt_name[0]
                Microsoft.PowerShell.Utility\Write-Verbose "Available model files in ComfyUI: $($availableModelFiles -join ', ')"
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning "Could not detect available models from ComfyUI: $_"
        }

        # determine models to use
        $modelstouse = @()

        if ($UseAllModels) {

            # when UseAllModels is specified, ensure all compatible supported models are available
            Microsoft.PowerShell.Utility\Write-Verbose "UseAllModels specified - ensuring all compatible models are available"

            # get all compatible supported models
            $allSupportedModels = $supportedModels | Microsoft.PowerShell.Core\Where-Object { $_.Compatible -eq $true } | Microsoft.PowerShell.Core\ForEach-Object { $_.Name }

            if ($allSupportedModels.Count -eq 0) {
                throw "No compatible models found in supported models list."
            }

            # ensure each model is available (download if needed)
            foreach ($modelName in $allSupportedModels) {
                try {
                    Microsoft.PowerShell.Utility\Write-Verbose "Ensuring model '$modelName' is available..."
                    if ($ModelPath) {
                        $ensuredModel = GenXdev.AI\EnsureComfyUIModel -ModelName $modelName -ModelPath $ModelPath -ErrorAction Stop
                    } else {
                        $ensuredModel = GenXdev.AI\EnsureComfyUIModel -ModelName $modelName -ErrorAction Stop
                    }
                    if ($ensuredModel) {
                        $modelstouse += $modelName
                        Microsoft.PowerShell.Utility\Write-Verbose "Successfully ensured model: $modelName"
                    }
                } catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Could not ensure model '$modelName' is available: $_"
                    # Continue with other models instead of failing completely
                }
            }

            if ($modelstouse.Count -eq 0) {

                throw "Could not ensure any compatible models are available. Please check your internet connection and ComfyUI installation."
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Successfully ensured $($modelstouse.Count) model(s) for UseAllModels"

            # Set multimodel flag for UseAllModels case
            $multimodel = $modelstouse.Count -gt 1
        }
        else
        {
            # handle specific model selection or wildcards
            $filteredModels = @()
            foreach ($m in $Model) {
                if ($m -match '[\*\?]') {
                    $filteredModels += $supportedModels.Name | Microsoft.PowerShell.Core\Where-Object { $_ -like $m }
                } else {
                    $filteredModels += $m
                }
            }
            $modelstouse = $filteredModels | Microsoft.PowerShell.Utility\Select-Object -Unique

            # validate that specified models are available if we have that information
            if ($availableModelFiles.Count -gt 0) {
                $validatedModels = @()
                foreach ($modelName in $modelstouse) {
                    $modelInfo = $supportedModels | Microsoft.PowerShell.Core\Where-Object { $_.Name -eq $modelName }
                    if ($modelInfo -and $availableModelFiles -contains $modelInfo.FileName) {
                        $validatedModels += $modelName
                    } elseif ($modelInfo) {
                        Microsoft.PowerShell.Utility\Write-Warning "Model '$modelName' (file: $($modelInfo.FileName)) is not available in ComfyUI. Skipping."
                    }
                }

                if (($validatedModels.Count -eq 0) -and ($modelstouse.Count -gt 0)) {
                    throw "None of the specified models are available in ComfyUI. Please ensure the models are installed."
                }
                $modelstouse = $validatedModels
            }

            $multimodel = $modelstouse.Count -gt 1

            if ($modelstouse.Count -eq 0) {
                throw "No valid models available for generation."
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Using models: $($modelstouse -join ', ')"
        }
    }

    process {

        # process each model
        foreach ($currentmodel in $modelstouse) {

            $modelInfo = $supportedModels | Microsoft.PowerShell.Core\Where-Object { $_.Name -eq $currentmodel }

            if (-not $modelInfo) {
                Microsoft.PowerShell.Utility\Write-Warning "Unsupported model: ${currentmodel}"
                continue
            }

            $modelstarttime = Microsoft.PowerShell.Utility\Get-Date

            # handle models that are already available or need to be ensured
            if ($UseAllModels) {
                # when UseAllModels was used, models were already ensured in begin block
                # just ensure the model by calling EnsureComfyUIModel again to get the correct file path
                try {
                    if ($ModelPath) {
                        $ensuredmodel = GenXdev.AI\EnsureComfyUIModel -ModelName $currentmodel -ModelPath $ModelPath -ErrorAction Stop
                    } else {
                        $ensuredmodel = GenXdev.AI\EnsureComfyUIModel -ModelName $currentmodel -ErrorAction Stop
                    }
                    Microsoft.PowerShell.Utility\Write-Verbose "Using pre-ensured model: $ensuredmodel"
                } catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Could not get model path for pre-ensured model '${currentmodel}': $_"
                    continue
                }
            } else {
                # ensure the model is available (download if needed)
                try {
                    if ($ModelPath) {
                        $ensuredmodel = GenXdev.AI\EnsureComfyUIModel -ModelName $currentmodel -ModelPath $ModelPath -ErrorAction Stop
                    } else {
                        $ensuredmodel = GenXdev.AI\EnsureComfyUIModel -ModelName $currentmodel -ErrorAction Stop
                    }
                } catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Could not ensure model '${currentmodel}' is available: $_"
                    continue
                }
            }

            if ((-not $ensuredmodel) -or [string]::IsNullOrWhiteSpace($ensuredmodel)) {
                Microsoft.PowerShell.Utility\Write-Warning "Could not ensure model '${currentmodel}' is available"
                continue
            }

            # extract just the filename for ComfyUI
            $currentModelFileName = [System.IO.Path]::GetFileName($ensuredmodel)

            # validate model filename is not empty
            if ([string]::IsNullOrWhiteSpace($currentModelFileName)) {

                Microsoft.PowerShell.Utility\Write-Warning "Invalid model filename for '${currentmodel}', skipping to prevent fallback behavior"
                continue
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Using model file: $currentModelFileName"

            # determine architecture for workflow creation from JSON data
            $workflowcreator = if ($modelInfo.Architecture -eq 'SDXL') { 'CreateComfySDXLWorkflow' } else { 'CreateComfyUniversalWorkflow' }

            $workflow = & "GenXdev.AI\$workflowcreator" `
                        -PromptText $Prompt `
                        -NegativePromptText $NegativePrompt `
                        -ImageName ([System.IO.Path]::GetFileName($processedimagepath)) `
                        -Steps $Steps `
                        -Width $ImageWidth `
                        -Height $ImageHeight `
                        -CfgScale $CfgScale `
                        -Strength $Strength `
                        -Seed $Seed `
                        -BatchSize $BatchSize `
                        -Model $currentModelFileName `
                        -Sampler $Sampler `
                        -Scheduler $Scheduler `
                        -FilenamePrefix $basefilename

            # queue workflow
            $promptid = GenXdev.AI\QueueComfyWorkflow -Workflow $workflow

            # wait for completion
            $results = GenXdev.AI\WaitForComfyCompletion `
                -PromptId $promptid `
                -Verbose:$false

            if ($results) {

                # download generated images
                $downloadedfiles = @(GenXdev.AI\DownloadComfyResults `
                    -HistoryData $results `
                    -OutputDirectory $env:TEMP)

                for ($i = 0; $i -lt $downloadedfiles.Count; $i++) {

                    $originalfile = $downloadedfiles[$i]

                    # use display name for file naming (clean up auto-detected names)
                    $displayName = $currentmodel -replace '^(Available|Auto-Detected):\s*', ''
                    $modelsuffix = if ($multimodel) { "_$($displayName -replace '\.[^\.]+$', '')" } else { '' }

                    $indexsuffix = if ($downloadedfiles.Count -gt 1) { "_$i" } else { '' }

                    $suffix = if ($modelsuffix -and $indexsuffix) { "${modelsuffix}${indexsuffix}" } `
                        elseif ($modelsuffix) { $modelsuffix } `
                        elseif ($indexsuffix) { $indexsuffix } `
                        else { '' }

                    $currentoutfile = Microsoft.PowerShell.Management\Join-Path `
                        $baseoutputdir "${basefilename}${suffix}${baseext}"

                    $targetext = [System.IO.Path]::GetExtension($currentoutfile)

                    if ($targetext -ne [System.IO.Path]::GetExtension($originalfile)) {

                        $targetformat = switch ($targetext) {

                            ".jpg"  { "Jpeg" }
                            ".jpeg" { "Jpeg" }
                            ".png"  { "Png" }
                            ".bmp"  { "Bmp" }
                            ".tiff" { "Tiff" }
                            ".gif"  { "Gif" }
                            default { "Jpeg" }
                        }

                        $convertedfile = GenXdev.AI\ConvertComfyImageFormat `
                            -ImagePath $originalfile `
                            -OutputPath $currentoutfile `
                            -Format $targetformat

                        if ($convertedfile -ne $originalfile) {

                            $null = Microsoft.PowerShell.Management\Remove-Item `
                                -LiteralPath $originalfile `
                                -Force `
                                -ErrorAction SilentlyContinue
                        }
                } else {

                        Microsoft.PowerShell.Management\Move-Item `
                            -LiteralPath $originalfile `
                            -Destination $currentoutfile `
                            -Force
                    }

                    $allresults += $currentoutfile

                    # Add metadata in the formats expected by Find-Image
                    try {
                        $displayModelName = $currentmodel -replace '^(Available|Auto-Detected):\s*', ''

                        # Get file info for EXIF metadata
                        $fileInfo = [System.IO.FileInfo]::new($currentoutfile)
                        $fileExtension = $fileInfo.Extension.ToLowerInvariant()

                        # Create EXIF metadata structure (for technical metadata like Invoke-ImageMetadataUpdate)
                        $exifMetadata = @{
                            success = $true
                            has_metadata = $true
                            Basic = @{
                                Width = $ImageWidth
                                Height = $ImageHeight
                                Format = $fileExtension -replace '\.', ''
                                FileName = $fileInfo.Name
                                FileExtension = $fileExtension
                                FileSizeBytes = $fileInfo.Length
                                PixelFormat = ""
                                HorizontalResolution = 96.0
                                VerticalResolution = 96.0
                            }
                            Camera = @{
                                Make = "ComfyUI"
                                Model = $displayModelName
                                Software = "ComfyUI"
                            }
                            Other = @{
                                Software = "ComfyUI"
                                ColorSpace = "sRGB"
                                ResolutionUnit = "inch"
                            }
                            Author = @{
                                Artist = "ComfyUI AI Generation"
                                Copyright = ""
                            }
                            DateTime = @{
                                DateTimeOriginal = (Microsoft.PowerShell.Utility\Get-Date).ToString("yyyy:MM:dd HH:mm:ss")
                                DateTimeDigitized = (Microsoft.PowerShell.Utility\Get-Date).ToString("yyyy:MM:dd HH:mm:ss")
                            }
                            GPS = @{
                                Latitude = $null
                                Longitude = $null
                                Altitude = $null
                                LatitudeDMS = ""
                                LongitudeDMS = ""
                                LatitudeError = ""
                                LongitudeError = ""
                                AltitudeError = ""
                            }
                            Exposure = @{
                                FNumber = $null
                                ExposureTime = $null
                                ISOSpeedRatings = $null
                                FocalLength = $null
                                ExposureProgram = $null
                                MeteringMode = $null
                                Flash = $null
                            }
                        }

                        # Save EXIF metadata to EXIF.json stream
                        $exifStream = GenXdev.FileSystem\Expand-Path "${currentoutfile}:EXIF.json"
                        $exifJson = $exifMetadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress
                        [System.IO.File]::WriteAllText($exifStream, $exifJson)

                        # Create description metadata structure matching Invoke-ImageKeywordUpdate format
                        $descriptionMetadata = @{
                            success = $true
                            short_description = "AI-generated image: $Prompt"
                            long_description = "Generated using ComfyUI with model '$displayModelName'. Prompt: '$Prompt'. Negative prompt: '$NegativePrompt'"
                            keywords = @("AI-generated", "ComfyUI", ($displayModelName -replace '\s+', '-'))
                            picture_type = if ($InputImage) { "img2img" } else { "txt2img" }
                            style_type = "AI-generated"
                            overall_mood_of_image = "AI-created"
                            has_nudity = $false
                            has_explicit_content = $false
                        }

                        # Save description metadata to description.json stream
                        $descriptionStream = GenXdev.FileSystem\Expand-Path "${currentoutfile}:description.json"
                        $descriptionJson = $descriptionMetadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 5 -Compress
                        [System.IO.File]::WriteAllText($descriptionStream, $descriptionJson)

                        # Create empty people metadata structure
                        $peopleMetadata = @{
                            count = 0
                            faces = @()
                            success = $false
                            predictions = @()
                        }

                        # Save people metadata to people.json stream
                        $peopleStream = GenXdev.FileSystem\Expand-Path "${currentoutfile}:people.json"
                        $peopleJson = $peopleMetadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 5 -Compress
                        [System.IO.File]::WriteAllText($peopleStream, $peopleJson)

                        # Create empty objects metadata structure
                        $objectsMetadata = @{
                            objects = @()
                            object_counts = @{}
                            count = 0
                        }

                        # Save objects metadata to objects.json stream
                        $objectsStream = GenXdev.FileSystem\Expand-Path "${currentoutfile}:objects.json"
                        $objectsJson = $objectsMetadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 5 -Compress
                        [System.IO.File]::WriteAllText($objectsStream, $objectsJson)

                        Microsoft.PowerShell.Utility\Write-Verbose "Added complete Find-Image compatible metadata to: $currentoutfile"
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Warning "Failed to write metadata for ${currentoutfile}: $($_.Exception.Message)"
                    }
                }

                $modeltime = (Microsoft.PowerShell.Utility\Get-Date) - $modelstarttime

                $displayName = $currentmodel -replace '^(Available|Auto-Detected):\s*', ''
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "${displayName} completed in $([Math]::Round($modeltime.TotalSeconds)) seconds"
            } else {

                    $displayName = $currentmodel -replace '^(Available|Auto-Detected):\s*', ''
                    Microsoft.PowerShell.Utility\Write-Warning `
                    "Generation failed for $displayName"
            }
        }
    }

    end {

        # clean temp image
        if ($processedimagepath -and $processedimagepath -ne $InputImage) {

            $null = Microsoft.PowerShell.Management\Remove-Item `
                -LiteralPath $processedimagepath `
                -Force `
                -ErrorAction SilentlyContinue
        }

        # output results
        $allresults | GenXdev.FileSystem\WriteFileOutput `
                -CallerInvocation $callerInvocation `
                -Prefix "Generated: "

        # shutdown if not noshutdown and queue is empty
        if (-not $NoShutdown) {

            # check if the ComfyUI queue is empty before shutting down
            $queueEmpty = GenXdev.AI\Test-ComfyUIQueueEmpty

            if ($queueEmpty) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "ComfyUI queue is empty, proceeding with shutdown"

                GenXdev.AI\Stop-ComfyUI -ErrorAction SilentlyContinue
            } else {

                Microsoft.PowerShell.Utility\Write-Warning `
                    "ComfyUI queue has pending tasks, skipping shutdown to avoid interrupting other workflows"

                Microsoft.PowerShell.Utility\Write-Warning `
                    "Use -NoShutdown parameter or stop ComfyUI manually when all tasks complete"
            }
        }
    }
}

###############################################################################