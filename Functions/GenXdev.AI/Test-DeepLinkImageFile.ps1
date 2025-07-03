###############################################################################
<#
.SYNOPSIS
Tests if the specified file path is a valid image file with a supported format.

.DESCRIPTION
This function validates that a file exists at the specified path and has a
supported image file extension. It checks for common image formats including
PNG, JPG, JPEG, and GIF files. The function throws exceptions for invalid
paths or unsupported file formats.

.PARAMETER Path
The file path to the image file to be tested. Must be a valid file system path.

.EXAMPLE
Test-DeepLinkImageFile -Path "C:\Images\photo.jpg"

.EXAMPLE
Test-DeepLinkImageFile "C:\Images\logo.png"
        ###############################################################################>
function Test-DeepLinkImageFile {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The file path to the image file to be tested"
        )]
        [string] $Path
        ###############################################################################
    )

    begin {

        # define supported image file extensions
        $validExtensions = @('.png', '.jpg', '.jpeg', '.gif')
    }

    process {

        # check if the file exists at the specified path
        if (-not (Microsoft.PowerShell.Management\Test-Path $Path)) {

            throw "Image file not found: $Path"
        }

        # get the file extension and convert to lowercase for comparison
        $fileExtension = [System.IO.Path]::GetExtension($Path).ToLower()

        # verify the file has a supported image format extension
        if ($validExtensions -notcontains $fileExtension) {

            throw ("Invalid image format. Supported formats: " +
                   "png, jpg, jpeg, gif")
        }

        # output verbose information about successful validation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Successfully validated image file: $Path"
        )
    }

    end {
    }
}
        ###############################################################################
