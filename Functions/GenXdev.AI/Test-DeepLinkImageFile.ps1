<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Test-DeepLinkImageFile.ps1
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
Tests if the specified file path is a valid image file with a supported format.

.DESCRIPTION
This function validates that a file exists at the specified path and has a
supported image file extension. It checks for common image formats including
PNG, JPG, JPEG, GIF, BMP, WebP, TIFF, and TIF files. The function throws
exceptions for invalid paths or unsupported file formats.

.PARAMETER Path
The file path to the image file to be tested. Must be a valid file system path.

.EXAMPLE
Test-DeepLinkImageFile -Path "C:\Images\photo.jpg"

.EXAMPLE
Test-DeepLinkImageFile "C:\Images\logo.png"
#>
function Test-DeepLinkImageFile {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The file path to the image file to be tested'
        )]
        [string] $Path
        ###############################################################################
    )

    begin {

        # define supported image file extensions
        $validExtensions = @('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '.tiff', '.tif')
    }

    process {

        # check if the file exists at the specified path
        if (-not ([IO.File]::Exists($Path))) {

            throw "Image file not found: $Path"
        }

        # get the file extension and convert to lowercase for comparison
        $fileExtension = [System.IO.Path]::GetExtension($Path).ToLower()

        # verify the file has a supported image format extension
        if ($validExtensions -notcontains $fileExtension) {

            throw ('Invalid image format. Supported formats: ' +
                'png, jpg, jpeg, gif, bmp, webp, tiff, tif')
        }

        # output verbose information about successful validation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Successfully validated image file: $Path"
        )
    }

    end {
    }
}