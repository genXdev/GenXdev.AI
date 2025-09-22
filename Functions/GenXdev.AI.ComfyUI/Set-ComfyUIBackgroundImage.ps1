<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : Set-ComfyUIBackgroundImage.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.280.2025
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
Sets or clears the background image for ComfyUI's canvas interface

.DESCRIPTION
Configures ComfyUI to display a custom background image in the canvas area by
updating the comfy.settings.json file. The function handles copying the image
to the appropriate ComfyUI directory and updating the configuration settings.

The background image is displayed behind the workflow nodes in ComfyUI's main
canvas area, providing visual customization of the interface. Images are
automatically copied to ComfyUI's input/backgrounds/ directory structure.

.PARAMETER ImagePath
Path to the image file to use as the background. Supported formats include
PNG, JPG, JPEG, GIF, BMP, and WEBP. The image will be copied to ComfyUI's
backgrounds directory and referenced in the settings.

.PARAMETER Clear
Removes the background image configuration from ComfyUI, returning the canvas
to its default appearance without a background image.

.EXAMPLE
Set-ComfyUIBackgroundImage -ImagePath "C:\Pictures\my-background.png"

Sets the specified image as ComfyUI's canvas background. The image will be
copied to the ComfyUI backgrounds directory and configured in settings.

.EXAMPLE
Set-ComfyUIBackgroundImage "D:\Images\abstract-art.jpg"

Sets abstract-art.jpg as the background image for ComfyUI's canvas interface.

.EXAMPLE
Set-ComfyUIBackgroundImage -Clear

Removes the current background image configuration, restoring ComfyUI's
default canvas appearance without a background image.

.NOTES
- ComfyUI must be restarted for background changes to take effect
- The function creates the backgrounds directory if it doesn't exist
- Original image files are copied, not moved, so source files remain intact
- Only one background image can be active at a time
#>
function Set-ComfyUIBackgroundImage {

    [CmdletBinding(DefaultParameterSetName = 'SetImage')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'SetImage',
            HelpMessage = "Path to the image file to set as background"
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({
            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $_ -PathType Leaf)) {
                throw "Image file does not exist: $_"
            }
            $extension = [System.IO.Path]::GetExtension($_).ToLower()
            $supportedFormats = @('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp')
            if ($extension -notin $supportedFormats) {
                throw "Unsupported image format. Supported formats: $($supportedFormats -join ', ')"
            }
            return $true
        })]
        [string] $ImagePath,
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Clear',
            HelpMessage = "Remove the background image configuration"
        )]
        [switch] $Clear
    )

    begin {
        # Get ComfyUI base path
        $comfyPath = GenXdev.AI\Get-ComfyUIModelPath -Verbose:$false
        if (-not $comfyPath) {
            throw "Could not determine ComfyUI installation path. Please ensure ComfyUI is properly configured."
        }

        # Define paths
        $settingsPath = Microsoft.PowerShell.Management\Join-Path $comfyPath "user\default\comfy.settings.json"
        $backgroundsDir = Microsoft.PowerShell.Management\Join-Path $comfyPath "input\backgrounds"

        Microsoft.PowerShell.Utility\Write-Verbose "ComfyUI path: $comfyPath"
        Microsoft.PowerShell.Utility\Write-Verbose "Settings file: $settingsPath"
        Microsoft.PowerShell.Utility\Write-Verbose "Backgrounds directory: $backgroundsDir"
    }

    process {
        # Ensure settings file exists
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $settingsPath)) {
            throw "ComfyUI settings file not found at: $settingsPath`nPlease ensure ComfyUI has been run at least once."
        }

        # Read current settings
        try {
            $settingsContent = Microsoft.PowerShell.Management\Get-Content -LiteralPath $settingsPath -Raw | Microsoft.PowerShell.Utility\ConvertFrom-Json
        }
        catch {
            throw "Failed to read ComfyUI settings file: $_"
        }

        if ($Clear) {
            # Remove background image setting
            if ($settingsContent.PSObject.Properties['Comfy.Canvas.BackgroundImage']) {
                $settingsContent.PSObject.Properties.Remove('Comfy.Canvas.BackgroundImage')
                Microsoft.PowerShell.Utility\Write-Verbose "Removed background image setting from ComfyUI configuration"
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "No background image was configured"
            }
        } else {
            # Set background image
            # Ensure backgrounds directory exists
            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $backgroundsDir)) {
                $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $backgroundsDir -Force
                Microsoft.PowerShell.Utility\Write-Verbose "Created backgrounds directory: $backgroundsDir"
            }

            # Get image filename and copy to backgrounds directory
            $imageFileName = [System.IO.Path]::GetFileName($ImagePath)
            $destinationPath = Microsoft.PowerShell.Management\Join-Path $backgroundsDir $imageFileName

            try {
                Microsoft.PowerShell.Management\Copy-Item -LiteralPath $ImagePath -Destination $destinationPath -Force
                Microsoft.PowerShell.Utility\Write-Verbose "Copied background image to: $destinationPath"
            }
            catch {
                throw "Failed to copy image file: $_"
            }

            # URL encode the filename for ComfyUI API
            $encodedFileName = [System.Web.HttpUtility]::UrlEncode("backgrounds/$imageFileName")
            $backgroundUrl = "/api/view?filename=$encodedFileName&type=input&subfolder=backgrounds"

            # Update settings with background image URL
            $settingsContent | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName 'Comfy.Canvas.BackgroundImage' -NotePropertyValue $backgroundUrl -Force
            Microsoft.PowerShell.Utility\Write-Verbose "Set background image URL: $backgroundUrl"
        }

        # Write updated settings back to file
        try {
            $settingsContent | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 | Microsoft.PowerShell.Management\Set-Content $settingsPath -Encoding UTF8
            Microsoft.PowerShell.Utility\Write-Verbose "Updated ComfyUI settings file"
        }
        catch {
            throw "Failed to update settings file: $_"
        }

        # Output result
        if ($Clear) {
            Microsoft.PowerShell.Utility\Write-Host "Background image cleared from ComfyUI configuration" -ForegroundColor Green
            Microsoft.PowerShell.Utility\Write-Host "Restart ComfyUI for changes to take effect" -ForegroundColor Yellow
        } else {
            Microsoft.PowerShell.Utility\Write-Host "Background image set successfully: $imageFileName" -ForegroundColor Green
            Microsoft.PowerShell.Utility\Write-Host "Image location: $destinationPath" -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host "Restart ComfyUI for changes to take effect" -ForegroundColor Yellow
        }
    }
}