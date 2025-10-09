<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Test-DeepLinkImageFile.ps1
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