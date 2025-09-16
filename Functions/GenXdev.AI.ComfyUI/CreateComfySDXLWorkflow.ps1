<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : CreateComfySDXLWorkflow.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.270.2025
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
Creates comprehensive ComfyUI SDXL workflow configuration supporting all parameters

.DESCRIPTION
Generates a complete SDXL workflow definition for ComfyUI processing that supports
both text-to-image and image-to-image generation with SDXL-specific optimizations.
SDXL models require different loaders, conditioning, and resolution handling
compared to SD 1.5 models.

This function creates workflows optimized for SDXL's dual-stage architecture
using the CheckpointLoaderSimple node but with SDXL-appropriate conditioning
and resolution settings. Supports all standard SDXL features including proper
aspect ratio handling and SDXL-specific prompt conditioning.

Returns a hashtable representing the SDXL workflow nodes and connections.

.PARAMETER PromptText
The positive text prompt for image generation

.PARAMETER NegativePromptText
The negative text prompt to exclude unwanted elements

.PARAMETER ImageName
Server-side image filename for image-to-image processing (optional)

.PARAMETER Steps
Number of denoising steps for the sampling process (recommended: 20-40 for SDXL)

.PARAMETER Width
Output image width in pixels (SDXL optimal: 1024, 1152, 1216, 1344, 1536)

.PARAMETER Height
Output image height in pixels (SDXL optimal: 1024, 896, 832, 768, 640)

.PARAMETER CfgScale
CFG Scale value for prompt adherence control (SDXL recommended: 3.5-8.0)

.PARAMETER Strength
Denoising strength for image-to-image processing

.PARAMETER Seed
Random seed for reproducible generation

.PARAMETER BatchSize
Number of images to generate in batch

.PARAMETER Model
SDXL model checkpoint filename to use

.PARAMETER Sampler
Sampling method name (SDXL recommended: dpmpp_2m, euler, dpmpp_sde)

.PARAMETER Scheduler
Scheduler type name (SDXL recommended: karras, normal)

.PARAMETER OutputFileName
Custom output filename to determine image format (optional)

.PARAMETER FilenamePrefix
Custom filename prefix for generated images (optional). When provided by the
calling function, this prefix will be used instead of generating a new
timestamp-based prefix. This eliminates duplicate date generation between
the calling function and workflow creation.

.EXAMPLE
CreateComfySDXLWorkflow -PromptText "majestic dragon, highly detailed" `
    -NegativePromptText "blurry, low quality" -Steps 25 -Width 1024 -Height 1024 `
    -CfgScale 6.0 -Seed 12345 -BatchSize 1 -Model "sdxl_model.safetensors" `
    -Sampler "dpmpp_2m" -Scheduler "karras" -OutputFileName "dragon_sdxl.jpg"

.EXAMPLE
CreateComfySDXLWorkflow "portrait of a woman" "blurry" -ImageName "input.png" `
    -Steps 30 -Width 1152 -Height 896 -CfgScale 7.0 -Strength 0.8 `
    -Seed 54321 -BatchSize 1 -Model "juggernaut_xl.safetensors" `
    -Sampler "dpmpp_sde" -Scheduler "karras" -FilenamePrefix "20250907_123456_portrait"
#>
function CreateComfySDXLWorkflow {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The positive text prompt for image generation"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PromptText,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "The negative text prompt to exclude unwanted elements"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $NegativePromptText,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Server-side image filename for image-to-image " +
                          "processing (optional)"
        )]
        [string] $ImageName,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 3,
            HelpMessage = "Number of denoising steps for the sampling process"
        )]
        [ValidateRange(1, 100)]
        [int] $Steps,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 4,
            HelpMessage = "Output image width in pixels"
        )]
        [ValidateRange(256, 2048)]
        [int] $Width,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 5,
            HelpMessage = "Output image height in pixels"
        )]
        [ValidateRange(256, 2048)]
        [int] $Height,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 6,
            HelpMessage = "CFG Scale value for prompt adherence control"
        )]
        [ValidateRange(1.0, 20.0)]
        [float] $CfgScale,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 7,
            HelpMessage = "Denoising strength for image-to-image processing"
        )]
        [ValidateRange(0.1, 1.0)]
        [float] $Strength,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 8,
            HelpMessage = "Random seed for reproducible generation"
        )]
        [long] $Seed,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 9,
            HelpMessage = "Number of images to generate in batch"
        )]
        [ValidateRange(1, 4)]
        [int] $BatchSize,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 10,
            HelpMessage = "SDXL model checkpoint filename to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Model,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 11,
            HelpMessage = "Sampling method name"
        )]
        [string] $Sampler,
        #######################################################################
        [Parameter(
            Mandatory = $true,
            Position = 12,
            HelpMessage = "Scheduler type name"
        )]
        [string] $Scheduler,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 13,
            HelpMessage = "Custom output filename to determine image format"
        )]
        [string] $OutputFileName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 14,
            HelpMessage = "Custom filename prefix for generated images"
        )]
        [string] $FilenamePrefix
        #######################################################################
    )

    begin {

        # determine output format
        $outputformat = "PNG"

        if ($OutputFileName) {

            $extension = [System.IO.Path]::GetExtension($OutputFileName).ToLowerInvariant()

            $outputformat = switch ($extension) {

                ".jpg"  { "JPEG" }
                ".jpeg" { "JPEG" }
                ".png"  { "PNG" }
                ".bmp"  { "BMP" }
                ".tiff" { "TIFF" }
                ".gif"  { "GIF" }
                default { "PNG" }
            }
        }

        # ensure model extension
        if (-not ($Model -match '\.(safetensors|ckpt|bin)$')) {

            $Model += '.safetensors'
        }

        # determine the actual filename prefix to use in SaveImage node
        $actualFilenamePrefix = if ($FilenamePrefix) {
            $FilenamePrefix
        } elseif ($OutputFileName) {
            [System.IO.Path]::GetFileNameWithoutExtension($OutputFileName)
        } else {
            ("ComfyUI_SDXL_" +
             "$(Microsoft.PowerShell.Utility\Get-Date -Format 'yyyyMMdd_HHmmss')")
        }

        # progress
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI SDXL Workflow Creation" `
            -Status "Preparing SDXL workflow" `
            -PercentComplete 10

        # provide verbose feedback about format selection
        Microsoft.PowerShell.Utility\Write-Verbose `
            "SDXL workflow output format determined: ${outputFormat}"

        # validate SDXL-appropriate dimensions and provide warnings
        $sdxlOptimalDimensions = @(
            @{W=1024; H=1024}, @{W=1152; H=896}, @{W=1216; H=832},
            @{W=1344; H=768}, @{W=1536; H=640}, @{W=896; H=1152},
            @{W=832; H=1216}, @{W=768; H=1344}, @{W=640; H=1536}
        )

        $isOptimalDimension = $sdxlOptimalDimensions | Microsoft.PowerShell.Core\Where-Object {
            $_.W -eq $Width -and $_.H -eq $Height
        }

        if (-not $isOptimalDimension) {
            Microsoft.PowerShell.Utility\Write-Warning ("SDXL works best with " +
                "specific aspect ratios. Consider using: 1024x1024, 1152x896, " +
                "1216x832, 1344x768, or 1536x640")
        }
    }

    process {

        if ($ImageName) {

            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "ComfyUI SDXL Workflow Creation" `
                -Status "Creating SDXL image-to-image workflow" `
                -PercentComplete 30

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Creating SDXL image-to-image with ${ImageName}"

            return @{
                "1" = @{
                    "inputs" = @{
                        "ckpt_name" = $Model
                    }
                    "class_type" = "CheckpointLoaderSimple"
                }
                "2" = @{
                    "inputs" = @{
                        "text" = $PromptText
                        "clip" = @("1", 1)
                    }
                    "class_type" = "CLIPTextEncode"
                }
                "3" = @{
                    "inputs" = @{
                        "text" = $NegativePromptText
                        "clip" = @("1", 1)
                    }
                    "widgets_values" = @(
                        "$PromptText"
                    )
                    "class_type" = "CLIPTextEncode"
                }
                "4" = @{
                    "inputs" = @{
                        "image" = $ImageName
                    }
                    "class_type" = "LoadImage"
                }
                "5" = @{
                    "inputs" = @{
                        "pixels" = @("4", 0)
                        "vae" = @("1", 2)
                    }
                    "class_type" = "VAEEncode"
                }
                "6" = @{
                    "inputs" = @{
                        "seed" = $Seed
                        "steps" = $Steps
                        "cfg" = $CfgScale
                        "sampler_name" = $Sampler
                        "scheduler" = $Scheduler
                        "denoise" = $Strength
                        "model" = @("1", 0)
                        "positive" = @("2", 0)
                        "negative" = @("3", 0)
                        "latent_image" = @("5", 0)
                    }
                    "class_type" = "KSampler"
                }
                "7" = @{
                    "inputs" = @{
                        "samples" = @("6", 0)
                        "vae" = @("1", 2)
                    }
                    "class_type" = "VAEDecode"
                }
                "8" = @{
                    "inputs" = @{
                        "filename_prefix" = $actualFilenamePrefix
                        "images" = @("7", 0)
                    }
                    "class_type" = "SaveImage"
                }
            }
        } else {

            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "ComfyUI SDXL Workflow Creation" `
                -Status "Creating SDXL text-to-image workflow" `
                -PercentComplete 30

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Creating SDXL text-to-image workflow"

            return @{
                "1" = @{
                    "inputs" = @{
                        "ckpt_name" = $Model
                    }
                    "class_type" = "CheckpointLoaderSimple"
                }
                "2" = @{
                    "inputs" = @{
                        "text" = $PromptText
                        "clip" = @("1", 1)
                    }
                    "class_type" = "CLIPTextEncode"
                }
                "3" = @{
                    "inputs" = @{
                        "text" = $NegativePromptText
                        "clip" = @("1", 1)
                    }
                    "class_type" = "CLIPTextEncode"
                }
                "4" = @{
                    "inputs" = @{
                        "width" = $Width
                        "height" = $Height
                        "batch_size" = $BatchSize
                    }
                    "class_type" = "EmptyLatentImage"
                }
                "5" = @{
                    "inputs" = @{
                        "seed" = $Seed
                        "steps" = $Steps
                        "cfg" = $CfgScale
                        "sampler_name" = $Sampler
                        "scheduler" = $Scheduler
                        "denoise" = 1.0
                        "model" = @("1", 0)
                        "positive" = @("2", 0)
                        "negative" = @("3", 0)
                        "latent_image" = @("4", 0)
                    }
                    "class_type" = "KSampler"
                }
                "6" = @{
                    "inputs" = @{
                        "samples" = @("5", 0)
                        "vae" = @("1", 2)
                    }
                    "class_type" = "VAEDecode"
                }
                "7" = @{
                    "inputs" = @{
                        "filename_prefix" = $actualFilenamePrefix
                        "images" = @("6", 0)
                    }
                    "class_type" = "SaveImage"
                }
            }
        }

        # report workflow configuration completion
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI SDXL Workflow Creation" `
            -Status "SDXL workflow configuration completed" `
            -PercentComplete 90
    }

    end {

        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI SDXL Workflow Creation" `
            -Completed
    }
}
###############################################################################