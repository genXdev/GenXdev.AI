<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : ConvertComfyImageFormat.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
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
###############################################################################

<#
.SYNOPSIS
Converts image file format while preserving maximum quality.

.DESCRIPTION
Loads an image file using System.Drawing and saves it in a different format
with optimized quality settings. The function supports all major image formats
including JPEG, PNG, BMP, TIFF, and GIF with special handling for JPEG quality
optimization to maintain visual fidelity during conversion.

The function automatically determines the target format from the provided format
parameter and applies appropriate encoding settings. For JPEG output, it uses
95% quality to balance file size with visual quality. For other formats, it
uses lossless conversion where possible.

This function is particularly useful in ComfyUI workflows where generated images
need to be converted to specific formats based on user requirements or
compatibility needs.

.PARAMETER ImagePath
Path to the input image file to convert. Must be a valid image file that
System.Drawing can load (JPEG, PNG, BMP, TIFF, GIF, etc.). The file will
be validated for existence and readability.

.PARAMETER OutputPath
Path where the converted image should be saved. The directory will be created
if it doesn't exist. If the file already exists, it will be overwritten.

.PARAMETER Format
Target image format as a string (e.g., "Jpeg", "Png", "Bmp", "Tiff", "Gif").
Case-insensitive. For JPEG format, high-quality encoding parameters are
automatically applied.

.EXAMPLE
$convertedPath = ConvertComfyImageFormat -ImagePath "input.png" `
    -OutputPath "output.jpg" -Format "Jpeg"
Converts a PNG image to high-quality JPEG format.

.EXAMPLE
ConvertComfyImageFormat "image.bmp" "image.png" "Png"
Convert BMP to PNG using positional parameters.

.EXAMPLE
$result = ConvertComfyImageFormat -ImagePath "source.tiff" `
    -OutputPath "result.gif" -Format "Gif"
Convert TIFF to GIF format with quality preservation.

.NOTES
This function requires System.Drawing to be available in the PowerShell session.
The function handles resource disposal properly to prevent memory leaks and
provides detailed progress feedback during conversion operations.

For JPEG output, the function uses 95% quality encoding to maintain visual
fidelity while achieving reasonable file sizes. Other formats use their
default quality settings optimized for the format characteristics.
#>
function ConvertComfyImageFormat {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Path to the input image file to convert"
        )]
        [string]$ImagePath,
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "Path where the converted image should be saved"
        )]
        [string]$OutputPath,
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 2,
            HelpMessage = "Target image format (Jpeg, Png, Bmp, Tiff, etc.)"
        )]
        [ValidateSet("Jpeg", "Jpg", "Png", "Bmp", "Tiff", "Gif")]
        [string]$Format
    )

    begin {

        # display progress for image format conversion operation
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Generation" `
            -Status "Converting image format to ${Format}"

        # initialize image object variable for proper resource disposal
        $image = $null
    }

    process {

        try {

            # load image using system.drawing for high-quality format conversion
            $image = [System.Drawing.Image]::FromFile($ImagePath)

            # determine target image format based on format parameter
            $imageFormat = switch ($Format.ToLower()) {
                "jpeg" { [System.Drawing.Imaging.ImageFormat]::Jpeg }
                "jpg"  { [System.Drawing.Imaging.ImageFormat]::Jpeg }
                "png"  { [System.Drawing.Imaging.ImageFormat]::Png }
                "bmp"  { [System.Drawing.Imaging.ImageFormat]::Bmp }
                "tiff" { [System.Drawing.Imaging.ImageFormat]::Tiff }
                "gif"  { [System.Drawing.Imaging.ImageFormat]::Gif }
                default { [System.Drawing.Imaging.ImageFormat]::Jpeg }
            }

            # apply format-specific encoding with quality optimization
            if ($imageFormat -eq [System.Drawing.Imaging.ImageFormat]::Jpeg) {

                # configure jpeg encoder parameters for high-quality output
                $encoder = [System.Drawing.Imaging.Encoder]::Quality

                # create encoder parameters object with single quality parameter
                $encoderParameters = Microsoft.PowerShell.Utility\New-Object `
                    System.Drawing.Imaging.EncoderParameters(1)

                # set quality parameter to 95% for high-quality jpeg output
                $encoderParameters.Param[0] = Microsoft.PowerShell.Utility\New-Object `
                    System.Drawing.Imaging.EncoderParameter($encoder, 95L)

                # get jpeg codec information for encoding
                $jpegCodec = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders() |
                    Microsoft.PowerShell.Core\Where-Object {
                        $_.FormatID -eq [System.Drawing.Imaging.ImageFormat]::Jpeg.Guid
                    }

                # save image with high-quality jpeg encoding settings
                $image.Save($OutputPath, $jpegCodec, $encoderParameters)
            } else {

                # save in other formats with their optimal default quality settings
                $image.Save($OutputPath, $imageFormat)
            }

            # clean up image object to free memory resources immediately
            $image.Dispose()

            # get file information for size reporting and validation
            $fileInfo = Microsoft.PowerShell.Management\Get-Item -LiteralPath $OutputPath

            # calculate file size in megabytes for user-friendly feedback
            $fileSizeMB = [Math]::Round($fileInfo.Length / 1MB, 2)

            Microsoft.PowerShell.Utility\Write-Verbose ("Converted to ${Format}: " +
                "${fileSizeMB}MB")

            # return the output path for pipeline continuation
            return $OutputPath
        }
        catch {

            # handle conversion errors gracefully with informative warnings
            Microsoft.PowerShell.Utility\Write-Warning "Failed to convert image format: $_"

            # ensure image object is disposed even on error to prevent memory leaks
            if ($image) { $image.Dispose() }

            # return original path when conversion fails
            return $ImagePath
        }
    }

    end {
    }
}
################################################################################