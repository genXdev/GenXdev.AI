<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : CreateComfyUniversalWorkflow.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
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
Creates comprehensive ComfyUI workflow configuration supporting all parameters

.DESCRIPTION
Generates a complete workflow definition for ComfyUI processing that supports
both text-to-image and image-to-image generation with all customization
parameters. For image-to-image workflows, uses high-strength denoising to
enable background modifications based on prompt instructions.

Note: True precision background replacement requires additional ComfyUI
custom nodes for masking/segmentation. This workflow uses prompt-guided
image-to-image processing which can modify backgrounds effectively with
appropriate prompts and strength settings.

Returns a hashtable representing the workflow nodes and connections.

.PARAMETER PromptText
The positive text prompt for image generation

.PARAMETER NegativePromptText
The negative text prompt to exclude unwanted elements

.PARAMETER ImageName
Server-side image filename for image-to-image processing (optional)

.PARAMETER Steps
Number of denoising steps for the sampling process

.PARAMETER Width
Output image width in pixels

.PARAMETER Height
Output image height in pixels

.PARAMETER CfgScale
CFG Scale value for prompt adherence control

.PARAMETER Strength
Denoising strength for image-to-image processing

.PARAMETER Seed
Random seed for reproducible generation

.PARAMETER BatchSize
Number of images to generate in batch

.PARAMETER Model
Model checkpoint filename to use

.PARAMETER Sampler
Sampling method name

.PARAMETER Scheduler
Scheduler type name

.PARAMETER OutputFileName
Custom output filename to determine image format (optional)

.PARAMETER FilenamePrefix
Custom filename prefix for generated images (optional). When provided by the
calling function, this prefix will be used instead of generating a new
timestamp-based prefix. This eliminates duplicate date generation between
the calling function and workflow creation.

.EXAMPLE
CreateComfyUniversalWorkflow -PromptText "dragon" -NegativePromptText "blurry" `
    -Steps 20 -Width 1024 -Height 1024 -CfgScale 7.0 -Seed 12345 `
    -BatchSize 1 -Model "model.safetensors" -Sampler "euler" `
    -Scheduler "normal" -OutputFileName "dragon.jpg"

.EXAMPLE
CreateComfyUniversalWorkflow "dragon" "blurry" -ImageName "input.png" `
    -Steps 20 -Width 1024 -Height 1024 -CfgScale 7.0 -Strength 0.75 `
    -Seed 12345 -BatchSize 1 -Model "model.safetensors" -Sampler "euler" `
    -Scheduler "normal" -FilenamePrefix "20250907_123456_dragon"
#>
function CreateComfyUniversalWorkflow {

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
            HelpMessage = "Model checkpoint filename to use"
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

        # ensure model has extension
        if (-not ($Model -match '\.(safetensors|ckpt|bin)$')) {

            $Model += '.safetensors'
        }

        # determine the actual filename prefix to use in SaveImage node
        $actualFilenamePrefix = if ($FilenamePrefix) {
            $FilenamePrefix
        } elseif ($OutputFileName) {
            [System.IO.Path]::GetFileNameWithoutExtension($OutputFileName)
        } else {
            ("ComfyUI_" +
             "$(Microsoft.PowerShell.Utility\Get-Date -Format 'yyyyMMdd_HHmmss')")
        }

        # progress for creation
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Workflow Creation" `
            -Status "Preparing workflow" `
            -PercentComplete 10
    }

    process {

        if ($ImageName) {

            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "ComfyUI Workflow Creation" `
                -Status "Creating background replacement workflow" `
                -PercentComplete 30

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Creating image-to-image workflow with ${ImageName}"

            return @{
                "1" = @{
                    "inputs" = @{
                        "ckpt_name" = $Model
                    }
                    "class_type" = "CheckpointLoaderSimple"
                }
                "2" = @{
                    "inputs" = @{
                        "text" = "keep the people unchanged, " + $PromptText
                        "clip" = @("1", 1)
                    }
                    "class_type" = "CLIPTextEncode"
                }
                "3" = @{
                    "inputs" = @{
                        "text" = ($NegativePromptText +
                                 ", changing people, removing people, different people")
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
                        "denoise" = [Math]::Min($Strength * 0.6, 0.5)
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
                -Activity "ComfyUI Workflow Creation" `
                -Status "Creating text-to-image workflow" `
                -PercentComplete 30

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Creating text-to-image workflow"

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
            -Activity "ComfyUI Workflow Creation" `
            -Status "Workflow configuration completed" `
            -PercentComplete 90
    }

    end {

        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Workflow Creation" `
            -Completed
    }
}
###############################################################################