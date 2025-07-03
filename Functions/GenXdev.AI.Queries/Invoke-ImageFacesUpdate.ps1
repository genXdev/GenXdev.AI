###############################################################################
<#
.SYNOPSIS
Updates face recognition metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to identify and analyze
faces using AI recognition technology. It creates or updates metadata files
containing face information for each image. The metadata is stored in a
separate file with the same name as the image but with a ':people.json' suffix.

.PARAMETER ImageDirectories
The directory path containing images to process. Can be relative or absolute.
Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all subdirectories.

.PARAMETER OnlyNew
If specified, only processes images that don't already have face metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images (empty metadata files).

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called by
parent function.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch is
used.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU.

.PARAMETER ContainerName
The name for the Docker container. Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage. Default is
"deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service. Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image.

.EXAMPLE
Invoke-ImageFacesUpdate -ImageDirectories "C:\Photos" -Recurse

.EXAMPLE
facerecognition "C:\Photos" -RetryFailed -OnlyNew
###############################################################################>
function Invoke-ImageFacesUpdate {

    [CmdletBinding()]
    [Alias("facerecognition")]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The directory path containing images to process"
        )]
        [string] $ImageDirectories = ".\",
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Custom Docker image name to use instead of default"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "The name for the Docker volume for persistent storage"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        #######################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = ("Maximum time in seconds to wait for service " +
                          "health check")
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = "Interval in seconds between health check attempts"
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Process images in specified directory and all " +
                          "subdirectories")
        )]
        [switch] $Recurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only process images that don't already have face " +
                          "metadata files")
        )]
        [switch] $OnlyNew,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Retry processing previously failed images with " +
                          "empty metadata files")
        )]
        [switch] $RetryFailed,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Skip Docker initialization when already called by " +
                          "parent function")
        )]
        [switch] $NoDockerInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Force rebuild of Docker container and remove " +
                          "existing data")
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use GPU-accelerated version which requires an " +
                          "NVIDIA GPU")
        )]
        [switch] $UseGPU
        #######################################################################
    )
    begin {

        # convert the possibly relative path to an absolute path for reliable access
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectories

        # ensure the target directory exists before proceeding with any operations
        if (-not [System.IO.Directory]::Exists($path)) {

            Microsoft.PowerShell.Utility\Write-Host ("The directory '$path' " +
                                                     "does not exist.")
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose ("Processing images in " +
                                                    "directory: $path")
    }

    process {

        # retrieve all supported image files from the specified directory
        # applying recursion only if the -Recurse switch was provided
        Microsoft.PowerShell.Management\Get-ChildItem `
            -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.gif", "$path\*.png" `
            -Recurse:$Recurse `
            -File `
            -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                # store the full path to the current image for better readability
                $image = $PSItem.FullName
                $metadataFilePath = "$($image):people.json"

                # check if a metadata file already exists for this image
                $fileExists = [System.IO.File]::Exists($metadataFilePath)

                # check if we have valid existing content
                $hasValidContent = $false
                if ($fileExists) {
                    try {
                        $content = [System.IO.File]::ReadAllText($metadataFilePath)
                        $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                        $hasValidContent = $existingData.predictions -and $existingData.predictions.Count -gt 0
                    }
                    catch {
                        # If JSON parsing fails, treat as invalid content
                        $hasValidContent = $false
                    }
                }

                # determine if image should be processed based on options
                Microsoft.PowerShell.Utility\Write-Verbose `
                    ("OnlyNew: $OnlyNew, FileExists: $fileExists, " +
                     "HasValidContent: $hasValidContent")

                $shouldProcess = (-not $OnlyNew) -or (-not $fileExists) -or (-not $hasValidContent)

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Should process '$image': $shouldProcess"

                if ($shouldProcess) {

                    # obtain face recognition data using ai recognition technology
                    $faceData = GenXdev.AI\Get-ImageDetectedFaces `
                        -ImagePath $image `
                        -NoDockerInitialize:$NoDockerInitialize `
                        -ConfidenceThreshold 0.6

                    # process the returned face data into standardized format
                    $processedData = if ($faceData -and
                                         $faceData.success -and
                                         $faceData.predictions) {

                        $predictions = $faceData.predictions

                        # extract unique face names from predictions data
                        $faceNames = $predictions |
                            Microsoft.PowerShell.Core\ForEach-Object {

                                $name = $_.userid
                                $lastUnderscoreIndex = $name.LastIndexOf("_")

                                # remove timestamp suffix if present in face name
                                if ($lastUnderscoreIndex -gt 0) {
                                    $name.Substring(0, $lastUnderscoreIndex)
                                } else {
                                    $name
                                }
                            } |
                            Microsoft.PowerShell.Utility\Sort-Object -Unique

                        # create standardized data structure for face metadata
                        @{
                            success     = $true
                            count       = $faceNames.Count
                            faces       = $faceNames
                            predictions = $predictions
                        }
                    } else {

                        # create empty structure when no faces are detected
                        @{
                            success = $true
                            count = 0
                            faces = @()
                            predictions = @()
                        }
                    }

                    # convert processed data to json format for storage
                    $faces = $processedData |
                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                            -Depth 20 `
                            -WarningAction SilentlyContinue

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Received face analysis for: $image")

                    try {

                        # reformat json to ensure consistent compressed format
                        $newContent = ($faces |
                            Microsoft.PowerShell.Utility\ConvertFrom-Json |
                            Microsoft.PowerShell.Utility\ConvertTo-Json `
                                -Compress `
                                -Depth 20 `
                                -WarningAction SilentlyContinue)

                        # save the processed face data to metadata file
                        [System.IO.File]::WriteAllText($metadataFilePath,
                                                       $newContent)

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Successfully saved face metadata for: $image")
                    }
                    catch {

                        # log any errors that occur during metadata processing
                        Microsoft.PowerShell.Utility\Write-Warning (
                            "$PSItem`r`n$faces")
                    }
                }
            }
    }

    end {
    }
}
        ###############################################################################