<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : UploadComfyImage.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.308.2025
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
Uploads image file to ComfyUI server for processing workflow integration.

.DESCRIPTION
Takes a local image file and uploads it to the ComfyUI server via the upload
API endpoint. This function handles the multipart form data upload required
by ComfyUI's image upload API and returns the server-side filename that can
be used in workflow node configurations.

The function validates the input file, provides upload progress feedback,
and handles errors gracefully. The returned filename is required for
image-to-image workflows and serves as the identifier for the uploaded
image in ComfyUI's internal storage system.

.PARAMETER ImagePath
Path to the local image file to upload. Must be a valid image file that
ComfyUI supports (JPEG, PNG, BMP, TIFF, etc.). The file will be validated
for existence before attempting upload.

.EXAMPLE
$serverImageName = UploadComfyImage -ImagePath "C:\temp\input.jpg"
Uploads an image and returns the server-side filename for workflow use.

.EXAMPLE
$imageName = UploadComfyImage "C:\temp\photo.png"
Upload using positional parameter syntax.

.EXAMPLE
"C:\images\source.jpg" | UploadComfyImage
Upload via pipeline input.

.NOTES
This function requires an active ComfyUI server connection and uses the
$script:comfyUIApiUrl variable to determine the upload endpoint. The
function is typically called internally by other ComfyUI workflow functions
but can be used standalone for manual image uploads.

The uploaded image becomes available to all ComfyUI workflows on the server
until the server is restarted or the image is manually deleted.
#>
function UploadComfyImage {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "Path to the local image file to upload"
        )]
        [Alias("Path", "FullName", "FilePath")]
        [string]$ImagePath
        ###############################################################################
    )

    begin {

        # verify image file exists before attempting upload operation
        # early validation prevents network calls with invalid file paths
        # and provides clear error messaging to the user
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $ImagePath)) {
            throw "Input image not found: ${ImagePath}"
        }

        # get file information for upload progress display and validation
        # extract just the filename for user-friendly progress messages
        $fileName = Microsoft.PowerShell.Management\Split-Path $ImagePath -Leaf

        # calculate file size for progress reporting and upload optimization
        # this helps users understand upload time for large images
        $fileSize = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $ImagePath).Length

        # convert file size to megabytes for human-readable display
        # provides meaningful size information in progress messages
        $fileSizeMB = [Math]::Round($fileSize / 1MB, 2)

        # display upload progress with file information
        # this gives users feedback during potentially long upload operations
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Generation" `
            -Status "Uploading ${fileName} (${fileSizeMB}MB)"

        # construct upload endpoint URL for API request
        # uses the globally available ComfyUI API URL from script scope
        # the /upload/image endpoint handles multipart form data uploads
        $uploadUrl = "${script:comfyUIApiUrl}/upload/image"
    }

    process {

        try {

            # create form data hashtable with image file for multipart upload
            # comfyUI's upload API expects the file in a form field named 'image'
            # get-Item creates a FileInfo object that invoke-RestMethod can handle
            $form = @{
                image = Microsoft.PowerShell.Management\Get-Item -LiteralPath $ImagePath
            }

            # send upload request to comfyUI server API using multipart form data
            # the -Form parameter automatically handles multipart/form-data encoding
            # which is required for file uploads to the comfyUI server
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $uploadUrl `
                -Method POST `
                -Form $form

            # log successful upload for debugging and user feedback
            Microsoft.PowerShell.Utility\Write-Verbose "Image uploaded successfully"

            # return the server-assigned filename for use in workflow nodes
            # this filename is how comfyUI identifies the uploaded image internally
            # and must be used in LoadImage nodes within workflows
            return $response.name
        }
        catch {

            # handle upload failures with detailed error information
            # this could happen due to network issues, server problems, or file format issues
            Microsoft.PowerShell.Utility\Write-Error ("Failed to upload image: " +
                "$($_.Exception.Message)")

            # re-throw to maintain error handling chain for calling functions
            # this ensures upstream functions can react appropriately to upload failures
            throw
        }
    }

    end {

        # upload operation completed successfully
        # server-side filename returned for workflow integration
        # progress indicator will be automatically cleared by calling function
    }
}
################################################################################