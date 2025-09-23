<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : ResizeComfyInputImage.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.284.2025
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
################################################################################
###############################################################################

<#
.SYNOPSIS
Resizes input image while preserving aspect ratio for optimal processing.

.DESCRIPTION
Intelligently resizes input images to fit within specified maximum dimensions
while maintaining the original aspect ratio and visual quality. This function
is essential for ComfyUI processing optimization, as it ensures images are
appropriately sized for AI model processing without causing memory issues or
performance degradation.

The function uses high-quality bicubic interpolation for resizing and creates
temporary files for processed images. It automatically detects when resizing
is unnecessary and returns the original path to avoid redundant operations.
The resizing algorithm intelligently determines scaling based on image
orientation (landscape vs portrait) for optimal dimension utilization.

.PARAMETER ImagePath
Path to the input image file to resize. Must be a valid image file that
System.Drawing can load. The original file is never modified; a temporary
resized copy is created when needed.

.PARAMETER MaxWidth
Maximum width in pixels for the resized image. The function ensures the
output image width does not exceed this value while maintaining aspect ratio.
Default value is optimized for balanced processing performance.

.PARAMETER MaxHeight
Maximum height in pixels for the resized image. The function ensures the
output image height does not exceed this value while maintaining aspect ratio.
Default value is optimized for balanced processing performance.

.EXAMPLE
$resizedPath = ResizeComfyInputImage -ImagePath "large_photo.jpg" `
    -MaxWidth 1024 -MaxHeight 1024
Resize a large image to fit within 1024x1024 bounds for GPU processing.

.EXAMPLE
$tempImage = ResizeComfyInputImage "portrait.png" 800 600
Resize using positional parameters for CPU-optimized dimensions.

.EXAMPLE
"input.jpg" | ResizeComfyInputImage -MaxWidth 512 -MaxHeight 512
Resize via pipeline for smaller, faster processing.

.NOTES
This function uses System.Drawing.Graphics with HighQualityBicubic
interpolation to ensure the best possible image quality during resizing.
Temporary files are created in the system temp directory and should be
cleaned up by calling functions after use.

The function automatically detects when resizing is unnecessary based on
current image dimensions and returns the original path unchanged to optimize
performance and avoid redundant file operations.
#>
function ResizeComfyInputImage {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to the input image file to resize"
        )]
        [Alias("Path", "FullName", "FilePath")]
        [string]$ImagePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = ("Maximum width in pixels for the resized image " +
                          "(default: 800)")
        )]
        [ValidateRange(64, 8192)]
        [int]$MaxWidth = 800,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = ("Maximum height in pixels for the resized image " +
                          "(default: 600)")
        )]
        [ValidateRange(64, 8192)]
        [int]$MaxHeight = 600
    )

    begin {

        # display progress for image resizing operation
        # this provides user feedback during potentially time-consuming operations
        # especially important for large images that require significant processing
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Generation" `
            -Status ("Resizing input image to max ${MaxWidth}x${MaxHeight} " +
                    "pixels")

        # initialize image object variable for proper resource disposal
        # this ensures we can safely dispose of the image object even if errors occur
        # prevents memory leaks from System.Drawing.Image unmanaged resources
        $image = $null
    }

    process {

        try {
            # load image using System.Drawing for high-quality manipulation
            # fromFile method loads the complete image into memory for processing
            # this provides full access to image properties and pixel data
            $image = [System.Drawing.Image]::FromFile($ImagePath)
        }
        catch {
            # handle image loading failures gracefully with informative warning
            # common causes: corrupted files, unsupported formats, file locks
            Microsoft.PowerShell.Utility\Write-Warning `
                "Failed to load image for resizing: $_"

            # return original path when loading fails - allows pipeline to continue
            # calling functions can decide how to handle the unresized image
            return $ImagePath
        }

        try {
            # calculate maximum dimension of the current image for size comparison
            # this determines the largest axis (width or height) for scaling decisions
            $maxImageDimension = [Math]::Max($image.Width, $image.Height)

            # calculate target maximum dimension from function parameters
            # this represents the constraint boundary for the resizing operation
            $targetMaxDimension = [Math]::Max($MaxWidth, $MaxHeight)

            # check if resizing is actually needed for performance optimization
            # skip unnecessary operations when image already meets size requirements
            if ($maxImageDimension -le $targetMaxDimension) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    ("Image already within size constraints " +
                    "(${maxImageDimension}px max)")

                # dispose image object and return original path unchanged
                # this optimization avoids redundant file operations and processing time
                $image.Dispose()

                return $ImagePath
            }

            # calculate new dimensions while maintaining aspect ratio
            # start with current dimensions as base for proportional scaling
            $newWidth = $image.Width

            $newHeight = $image.Height

            # determine scaling approach based on image orientation
            # this ensures optimal dimension utilization within the constraints
            if ($image.Width -gt $image.Height) {

                # landscape orientation - scale based on width constraint
                # width becomes the limiting factor for proportional scaling
                $newWidth = $MaxWidth

                $newHeight = [math]::Round($image.Height * ($MaxWidth / $image.Width))
            }
            else {

                # portrait or square orientation - scale based on height constraint
                # height becomes the limiting factor for proportional scaling
                $newHeight = $MaxHeight

                $newWidth = [math]::Round($image.Width * ($MaxHeight / $image.Height))
            }

            # ensure dimensions are valid positive integers for bitmap creation
            # prevents invalid dimension errors during bitmap instantiation
            $newWidth = [Math]::Max(1, [int]$newWidth)

            $newHeight = [Math]::Max(1, [int]$newHeight)

            # display progress with detailed dimension information
            # this helps users understand the scaling operation being performed
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "ComfyUI Generation" `
                -Status ("Resizing from $($image.Width)x$($image.Height) to " +
                        "${newWidth}x${newHeight}")

            # create new bitmap with calculated dimensions for resized image
            # this allocates memory for the target image at the exact required size
            $scaledImage = Microsoft.PowerShell.Utility\New-Object `
                System.Drawing.Bitmap $newWidth, $newHeight

            # configure graphics object for high-quality scaling operations
            # graphics object provides the drawing surface for the resizing operation
            $graphics = [System.Drawing.Graphics]::FromImage($scaledImage)

            # set interpolation mode for best quality resizing
            # highQualityBicubic provides excellent quality for image scaling
            # this algorithm produces smooth, high-quality results for both upscaling and downscaling
            $graphics.InterpolationMode = `
                [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic

            # draw resized image to new bitmap with calculated dimensions
            # this performs the actual scaling operation using the configured interpolation
            # source image is stretched/shrunk to fit the target dimensions precisely
            $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)

            # dispose graphics object to free resources immediately
            # graphics objects hold unmanaged GDI+ resources that need explicit disposal
            $graphics.Dispose()

            # create temporary file path for resized image output
            # uses system temp directory with JPEG extension for broad compatibility
            $tempPath = [System.IO.Path]::GetTempFileName() + ".jpg"

            # save resized image in JPEG format for ComfyUI compatibility
            # jpeg provides good quality with reasonable file sizes for AI processing
            # most ComfyUI models work optimally with JPEG input format
            $scaledImage.Save($tempPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)

            # clean up image objects to free memory resources immediately
            # both source and target images hold significant memory that should be released
            $scaledImage.Dispose()

            $image.Dispose()

            # calculate and display file size information for user feedback
            # this helps users understand the impact of resizing on file size
            $newSize = (Microsoft.PowerShell.Management\Get-Item `
                -LiteralPath $tempPath).Length

            # convert file size to megabytes for human-readable display
            # provides meaningful size information for users monitoring disk usage
            $newSizeMB = [Math]::Round($newSize / 1MB, 2)

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Resized image saved: ${newSizeMB}MB"

            # return temporary file path for use in ComfyUI processing
            # this path points to the optimally-sized image ready for AI processing
            return $tempPath
        }
        catch {
            # handle image processing errors gracefully with informative warning
            # common issues: memory exhaustion, disk space, graphics subsystem problems
            Microsoft.PowerShell.Utility\Write-Warning "Failed to resize image: $_"

            # ensure image object is disposed even on error to prevent memory leaks
            # the null-conditional operator safely handles cases where image wasn't loaded
            $image?.Dispose()

            # return original path when resizing fails - allows pipeline to continue
            # calling functions can decide how to handle the unresized image
            return $ImagePath
        }
    }

    end {

        # image resizing operation completed successfully
        # temporary resized file created or original path returned
        # calling functions should clean up temporary files after use
    }
}
################################################################################