<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Get-ComfyUIModelPath.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
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
Gets the correct ComfyUI models directory path for the current installation

.DESCRIPTION
Detects the actual ComfyUI installation path and returns the appropriate models
directory path. This function centralizes the logic for finding ComfyUI
installations across different installation methods (standard, Electron app,
portable, etc.) and provides a consistent way for other functions to locate
model storage directories.

The function checks multiple possible installation paths in order of preference
and returns the first existing path. If no installation is found, it returns
the most likely path where ComfyUI would be installed.

.PARAMETER Subfolder
The subfolder under the models directory (e.g., "checkpoints", "vae", "loras").
Defaults to "checkpoints" for standard diffusion models.

.PARAMETER ReturnAll
witch to return all possible model paths instead of just the first existing one.
Useful for functions that need to search across all possible locations.

.EXAMPLE
$modelPath = Get-ComfyUIModelPath
Returns the path to the checkpoints directory for the current ComfyUI installation.

.EXAMPLE
$vaePath = Get-ComfyUIModelPath -Subfolder "vae"
Returns the path to the VAE models directory.

.EXAMPLE
$allPaths = Get-ComfyUIModelPath -ReturnAll
Returns all possible model paths for comprehensive searching.
#>
function Get-ComfyUIModelPath {

    [CmdletBinding()]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Subfolder under models directory (e.g., checkpoints, vae, loras)"
        )]
        [string] $Subfolder = "checkpoints",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Return all possible paths instead of just the first existing one"
        )]
        [switch] $ReturnAll
        #######################################################################
    )

    begin {

        # get local application data environment variable
        $localappdata = $env:LOCALAPPDATA

        # define possible comfyui installation base paths
        $possiblebasepaths = @(
            (Microsoft.PowerShell.Management\Join-Path $localappdata `
                'Programs\@comfyorgcomfyui-electron\resources\ComfyUI')
        )

        # initialize array to store discovered model paths
        $modelpaths = @()

        # iterate through each potential comfyui installation path
        foreach ($basepath in $possiblebasepaths) {

            # construct path to the extra model paths yaml configuration file
            $yamlpath = Microsoft.PowerShell.Management\Join-Path `
                $basepath "extra_model_paths.yaml"

            # check if custom yaml configuration exists
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $yamlpath) {

                # read the entire yaml configuration file content
                $yamlcontent = Microsoft.PowerShell.Management\Get-Content `
                    -LiteralPath $yamlpath `
                    -Raw

                # check for custom section with base_path and subfolder configuration
                if ($yamlcontent -match ("(?ms)^custom:\s*\n.*?base_path:\s*" +
                    "(.+?)\s*\n.*?${Subfolder}:\s*(.+?)\s*(\n|$)")) {

                    # extract the custom base path from yaml
                    $custombasepath = $Matches[1].Trim()

                    # extract the subfolder path from yaml
                    $customsubfolder = $Matches[2].Trim()

                    # combine base path with subfolder to create full path
                    $customfullpath = Microsoft.PowerShell.Management\Join-Path `
                        $custombasepath $customsubfolder

                    # expand and add the custom path to model paths array
                    $modelpaths += GenXdev.FileSystem\Expand-Path $customfullpath

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        ("Custom path from yaml custom section: " +
                        "$customfullpath")

                    continue
                }

                # fallback check for direct subfolder mapping in legacy format
                if ($yamlcontent -match "${Subfolder}:\s*(.+?)\s*(\n|$)") {

                    # extract the custom subfolder path
                    $customsubpath = $Matches[1].Trim()

                    # expand and add the custom path to model paths array
                    $modelpaths += GenXdev.FileSystem\Expand-Path $customsubpath

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        ("Custom path from yaml direct mapping: " +
                        "$customsubpath")

                    continue
                }
            }

            # construct default model path for this installation
            $subpath = if ($Subfolder) { "models\$Subfolder" } else { "" }

            # combine base path with models subfolder
            $defaultmodelpath = Microsoft.PowerShell.Management\Join-Path `
                $basepath $subpath

            # add default path to model paths array
            $modelpaths += $defaultmodelpath
        }
    }

    process {

        # check if caller wants all possible paths returned
        if ($ReturnAll) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Returning all paths for subfolder: $Subfolder"

            return $modelpaths
        }

        # prioritize custom yaml configured paths even if they don't exist yet
        foreach ($modelpath in $modelpaths) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Checking: $modelpath"

            # if this is a custom path from yaml configuration, return it immediately
            # because it represents the user's explicit configuration choice
            if ($modelpath -match "^[A-Za-z]:\\" -and
                $modelpath -notmatch "\\Programs\\@comfyorgcomfyui-electron\\") {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Using custom configured path: $modelpath"

                return $modelpath
            }

            # for default paths, only return if they exist
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $modelpath) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Found existing path: $modelpath"

                return $modelpath
            }
        }        # initialize variable for preferred fallback path
        $preferredpath = $null

        # check for any existing comfyui installation as fallback
        foreach ($basepath in $possiblebasepaths) {

            # test if this base installation path exists
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $basepath) {

                # construct the expected model path for this installation
                $subpath = if ($Subfolder) { "models\$Subfolder" } else { "" }

                # combine base path with models subfolder
                $preferredpath = Microsoft.PowerShell.Management\Join-Path `
                    $basepath $subpath

                Microsoft.PowerShell.Utility\Write-Verbose `
                    ("Installation at: $basepath, preferred: " +
                    "$preferredpath")

                return $preferredpath
            }
        }

        # use ultimate fallback path when no installation found
        $fallbackpath = $modelpaths[0]

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Fallback: $fallbackpath"

        return $fallbackpath
    }

    end {

    }
}
###############################################################################