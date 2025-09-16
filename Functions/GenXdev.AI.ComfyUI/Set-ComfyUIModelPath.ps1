<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Set-ComfyUIModelPath.ps1
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
Adds a custom model path to ComfyUI's extra_model_paths.yaml configuration

.DESCRIPTION
Configures ComfyUI to use an additional custom path for model storage alongside
the default ComfyUI models directory. This function creates or updates the
'custom' section in the extra_model_paths.yaml file, allowing ComfyUI to find
models in additional locations without affecting the default model discovery.

The function handles both creating new configuration files and updating existing
ones, ensuring that the custom model path is properly configured as a
supplementary model source. Can also clear the custom configuration when using
the -Clear parameter.

This does NOT replace ComfyUI's default model paths - it adds an additional
location where ComfyUI will search for models, VAEs, LoRAs, etc.

.PARAMETER ModelPath
The base path to add as an additional model directory. This should be the root
directory that contains subdirectories like checkpoints/, vae/, loras/, etc.
ComfyUI will search this location IN ADDITION to its default model directories.
For example, if you have models organized as:
E:\MyModels\checkpoints\
E:\MyModels\vae\
E:\MyModels\loras\
Then pass "E:\MyModels" as the ModelPath.

.PARAMETER Clear
Removes the custom section from the extra_model_paths.yaml configuration file.

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

.PARAMETER KeysToSend
Array of keys to send to the ComfyUI window after ready

.PARAMETER SendKeyDelayMilliSeconds
Delay in milliseconds between key send operations

.PARAMETER Timeout
Timeout in seconds to wait for ComfyUI server readiness

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

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys

.PARAMETER ShowWindow
Show the ComfyUI window during initialization process

.PARAMETER Force
Force stop any existing ComfyUI process before starting a new one

.PARAMETER MoveModels
Move models from old path to new path when changing model path

.EXAMPLE
Set-ComfyUIModelPath -ModelPath "E:\MyModels"

Adds E:\MyModels as an additional model search path. ComfyUI will search for:
- Checkpoints in E:\MyModels\checkpoints\
- VAEs in E:\MyModels\vae\
- LoRAs in E:\MyModels\loras\
- Plus all the default ComfyUI model directories

.EXAMPLE
Set-ComfyUIModelPath "D:\StableDiffusionModels"

Adds D:\StableDiffusionModels as a supplementary model path alongside ComfyUI's
default model locations. Models should be organized in subdirectories:
D:\StableDiffusionModels\checkpoints\
D:\StableDiffusionModels\vae\
etc.

.EXAMPLE
Set-ComfyUIModelPath -Clear

Removes the custom model path configuration from ComfyUI.
#>
function Set-ComfyUIModelPath {

    [CmdletBinding(DefaultParameterSetName = 'SetPath')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'SetPath',
            HelpMessage = "The base path to set as the model directory"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ModelPath,
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Clear',
            HelpMessage = "Remove the custom model path configuration"
        )]
        [switch] $Clear,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height,
        ###############################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X,
        ###############################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y,
        ###############################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'Array of keys to send to the ComfyUI window after ready'
        )]
        [string[]] $KeysToSend,
        ###############################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between key send operations'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Position = 8,
            Mandatory = $false,
            HelpMessage = 'Timeout in seconds to wait for ComfyUI server readiness'
        )]
        [int] $Timeout = 600,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Position windows side by side'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the ComfyUI window during initialization process'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop any existing ComfyUI process before starting a new one'
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Move models from old path to new path when changing model path'
        )]
        [switch] $MoveModels
        ###############################################################################
    )

    begin {

        # get the current configured model path
        $current = GenXdev.AI\Get-ComfyUIModelPath

        # only process model path expansion when not clearing
        if (-not $Clear) {

            # expand the model path to full path
            $modelPathExpanded = GenXdev.FileSystem\Expand-Path $ModelPath

            # check if the path is already configured
            if ($current -eq $modelPathExpanded) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "The specified model path is already configured: " +
                    "${modelPathExpanded}"
                )
                return
            }

            # move existing models if requested and source path exists
            if ($MoveModels -and
                (Microsoft.PowerShell.Management\Test-Path -LiteralPath $current)) {

                # copy models from old to new location using robocopy
                GenXdev.FileSystem\Start-RoboCopy "${current}\*" (
                    GenXdev.FileSystem\Expand-Path "${modelPathExpanded}\" `
                        -CreateDirectory
                ) -Move
            }
        }

        # define the yaml configuration file path
        $yamlPath = Microsoft.PowerShell.Management\Join-Path `
            $env:LOCALAPPDATA (
                "Programs\@comfyorgcomfyui-electron\resources\ComfyUI\" +
                "extra_model_paths.yaml"
            )

        # ensure the yaml directory structure exists
        $yamlDir = [System.IO.Path]::GetDirectoryName($yamlPath)
        if (-not [System.IO.Directory]::Exists($yamlDir)) {

            $null = [System.IO.Directory]::CreateDirectory($yamlDir)
        }

        # check if comfyui is currently running
        $wasRunning = $false

        if (-not $Clear) {

            $currentExpanded = GenXdev.FileSystem\Expand-Path $current

            if ($modelPathExpanded -ne $currentExpanded) {

                $wasRunning = Microsoft.PowerShell.Management\Get-Process `
                    -Name "ComfyUI" `
                    -ErrorAction SilentlyContinue

                # stop comfyui if it's running to apply changes
                if ($wasRunning) {

                    GenXdev.AI\Stop-ComfyUI
                }
            }
        }
    }

    process {

        # read existing yaml content or initialize empty string
        $yamlContent = if ([System.IO.File]::Exists($yamlPath)) {

            [System.IO.File]::ReadAllText($yamlPath)
        } else {

            ""
        }

        if ($Clear) {

            # remove custom section if it exists in the yaml
            if ($yamlContent -match "custom:") {

                # remove the entire custom section including sub-properties
                $yamlContent = $yamlContent -replace (
                    "(?ms)^custom:.*?(?=^[a-zA-Z_]|\z)"
                ), ""

                # clean up any excessive newlines
                $yamlContent = $yamlContent -replace "\r?\n\r?\n+", "`r`n`r`n"
                $yamlContent = $yamlContent.Trim()

                # delete file if content is now empty
                if ([string]::IsNullOrWhiteSpace($yamlContent)) {

                    if ([System.IO.File]::Exists($yamlPath)) {

                        [System.IO.File]::Delete($yamlPath)
                    }

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Removed custom section and deleted empty " +
                        "extra_model_paths.yaml"
                    )
                } else {

                    [System.IO.File]::WriteAllText($yamlPath, $yamlContent)

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Removed custom section from extra_model_paths.yaml"
                    )
                }
            } else {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "No custom section found in extra_model_paths.yaml"
                )
            }
        } else {

            # create the custom section yaml configuration
            $customSection = (
                "custom:`n" +
                "    base_path: ${modelPathExpanded}`n" +
                "    checkpoints: checkpoints/`n" +
                "    vae: vae/`n" +
                "    loras: loras/`n" +
                "    upscale_models: upscale_models/`n" +
                "    embeddings: embeddings/`n" +
                "    controlnet: controlnet/"
            )

            if ($yamlContent -notmatch "custom:") {

                # append custom section to existing content
                $yamlContent += "`n${customSection}"

                [System.IO.File]::WriteAllText($yamlPath, $yamlContent)

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Added custom model path to extra_model_paths.yaml: " +
                    "${modelPathExpanded}"
                )
            } else {

                # update base_path in existing custom section
                $yamlContent = $yamlContent -replace (
                    "(?<=custom:\n\s*)base_path:\s*.+"
                ), "base_path: ${modelPathExpanded}"

                [System.IO.File]::WriteAllText($yamlPath, $yamlContent)

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Updated existing custom model path in " +
                    "extra_model_paths.yaml: ${modelPathExpanded}"
                )
             | Microsoft.PowerShell.Core\ForEach-Object fulln}
        }
    }

    end {

        # restart comfyui if it was running before the change
        if ($wasRunning) {

            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\EnsureComfyUI"

            GenXdev.AI\EnsureComfyUI @params
        }
    }
}

###############################################################################