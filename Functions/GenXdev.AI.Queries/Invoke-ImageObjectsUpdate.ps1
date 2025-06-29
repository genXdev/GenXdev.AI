################################################################################
<#
.SYNOPSIS
Updates object detection metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to detect objects using
artificial intelligence. It creates JSON metadata files containing detected
objects, their positions, confidence scores, and labels. The function supports
batch processing with configurable confidence thresholds and can optionally
skip existing metadata files or retry previously failed detections.

.PARAMETER AIImageCollectionDirectory
The directory path containing images to process. Can be relative or absolute
path. Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all
subdirectories recursively.

.PARAMETER OnlyNew
If specified, only processes images that don't already have object metadata
files or have empty metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images that have empty
metadata files or contain error indicators.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called
by parent function to avoid redundant container setup.

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for object detection. Objects detected
with confidence below this threshold will be filtered out. Default is 0.5.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This will recreate the entire detection environment.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU
with appropriate drivers and CUDA support.

.PARAMETER ContainerName
The name for the Docker container running the object detection service.
Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of detection models
and data. Default is "deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service to listen on. Must be between
1 and 65535. Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check before timing out.
Must be between 10 and 300 seconds. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts when waiting for service
startup. Must be between 1 and 10 seconds. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image.
Allows using alternative object detection models or configurations.

.EXAMPLE
Invoke-ImageObjectsUpdate -AIImageCollectionDirectory "C:\Photos" -Recurse

This example processes all images in C:\Photos and all subdirectories using
default settings with 0.5 confidence threshold.

.EXAMPLE
Invoke-ImageObjectsUpdate "C:\Photos" -RetryFailed -OnlyNew

This example processes only new images and retries previously failed ones
in the C:\Photos directory using positional parameter syntax.

.EXAMPLE
Invoke-ImageObjectsUpdate -AIImageCollectionDirectory "C:\Photos" -UseGPU `
    -ConfidenceThreshold 0.7

This example uses GPU acceleration with higher confidence threshold of 0.7
for more accurate but fewer object detections.
#>
function Invoke-ImageObjectsUpdate {

    [CmdletBinding()]
    [Alias("objectdetection")]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The directory path containing images to process"
        )]
        [string] $AIImageCollectionDirectory = ".\",
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Minimum confidence threshold for object detection"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.5,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Recurse through subdirectories"
        )]
        [switch] $Recurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip images that already have metadata files"
        )]
        [switch] $OnlyNew,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Retry processing previously failed images"
        )]
        [switch] $RetryFailed,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip Docker initialization for parent function calls"
        )]
        [switch] $NoDockerInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force rebuild Docker container and remove data"
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use GPU-accelerated version requiring NVIDIA GPU"
        )]
        [switch] $UseGPU,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The name for Docker volume for persistent storage"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum seconds to wait for service health check"
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Interval in seconds between health check attempts"
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom Docker image name to use for detection"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName
        #######################################################################
    )
    begin {

        # convert the possibly relative path to an absolute path for reliable access
        $path = GenXdev.FileSystem\Expand-Path $AIImageCollectionDirectory

        # ensure the target directory exists before proceeding with any operations
        if (-not [System.IO.Directory]::Exists($path)) {

            Microsoft.PowerShell.Utility\Write-Host (
                "The directory '$path' does not exist."
            )
            return
        }

        # output verbose information about the processing directory
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing images for object detection in directory: $path"
        )
    }

    process {

        # retrieve all supported image files from the specified directory
        # applying recursion only if the recurse switch was provided
        Microsoft.PowerShell.Management\Get-ChildItem `
            -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
            -Recurse:$Recurse `
            -File `
            -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

            try {

                # store the full path to the current image for better readability
                $image = $PSItem.FullName

                # handle retry mode for previously failed images
                if ($RetryFailed) {

                    if ([System.IO.File]::Exists("$($image):objects.json")) {

                        # read existing metadata file content
                        $content = [System.IO.File]::ReadAllText(
                            "$($image):objects.json"
                        )

                        # check if file is empty or contains failure indicators
                        if ($content.StartsWith("{}") -or
                            $content -eq (
                                '{"predictions":null,"count":0,"objects":[]}'
                            )) {

                            # reset content to empty for reprocessing
                            $content = "{}"
                        }
                    }
                }

                # output verbose information about current image being processed
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing image for object detection: $image"
                )

                # remove read-only attribute if present to ensure file modification
                if ($PSItem.Attributes -band
                    [System.IO.FileAttributes]::ReadOnly) {

                    $PSItem.Attributes = $PSItem.Attributes -bxor
                        [System.IO.FileAttributes]::ReadOnly
                }

                # construct path for the metadata file
                $metadataFilePath = "$($image):objects.json"

                # check if a metadata file already exists for this image
                $fileExists = [System.IO.File]::Exists($metadataFilePath)

                # read existing content or use empty object as default
                $content = if ($fileExists) {
                    [System.IO.File]::ReadAllText($metadataFilePath)
                } else {
                    "{}"
                }

                # determine if we should process this image based on conditions
                if ((-not $OnlyNew) -or
                    (-not $fileExists) -or
                    ($content -eq "{}") -or
                    (-not $content.Contains("predictions"))) {

                    # create an empty metadata file as placeholder if missing
                    if (-not $fileExists) {

                        $null = [System.IO.File]::WriteAllText(
                            $metadataFilePath,
                            "{}"
                        )

                        # output verbose confirmation of metadata file creation
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Created new object metadata file for: $image"
                        )
                    }

                    # obtain object detection data using ai detection technology
                    $objectData = GenXdev.AI\Get-ImageDetectedObjects `
                        -ImagePath $image `
                        -NoDockerInitialize:$NoDockerInitialize `
                        -ConfidenceThreshold $ConfidenceThreshold

                    # process the detection results into structured data format
                    $processedData = if ($objectData -and
                        $objectData.success -and
                        $objectData.predictions) {

                        # extract predictions array from detection results
                        $predictions = $objectData.predictions

                        # create array of object labels from predictions
                        $objectLabels = $predictions |
                            Microsoft.PowerShell.Core\ForEach-Object {
                                $_.label
                            }

                        # group objects by label to get counts
                        $objectCounts = $objectLabels |
                            Microsoft.PowerShell.Utility\Group-Object `
                                -NoElement

                        # construct structured data object with all metadata
                        $data = @{
                            success = $true
                            count = $predictions.Count
                            objects = $objectLabels
                            predictions = $predictions
                            object_counts = @{}
                        }

                        # populate object counts from grouped results
                        $objectCounts |
                            Microsoft.PowerShell.Core\ForEach-Object {
                                $data.object_counts[$_.Name] = $_.Count
                            }

                        $data
                    } else {

                        # create empty structure if no objects are detected
                        @{
                            success = $true
                            count = 0
                            objects = @()
                            predictions = @()
                            object_counts = @{}
                        }
                    }

                    # convert processed data to json format for storage
                    $objects = $processedData |
                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                            -Depth 20 `
                            -WarningAction SilentlyContinue

                    # output verbose confirmation of detection analysis completion
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Received object detection analysis for: $image"
                    )

                    try {

                        # re-parse and compress json for consistent formatting
                        $newContent = ($objects |
                            Microsoft.PowerShell.Utility\ConvertFrom-Json |
                            Microsoft.PowerShell.Utility\ConvertTo-Json `
                                -Compress `
                                -Depth 20 `
                                -WarningAction SilentlyContinue)

                        # ensure proper empty structure format
                        if ($newContent -eq (
                            '{"predictions":null,"count":0,"objects":[]}'
                        )) {

                            $newContent = (
                                '{"success":true,"count":0,"objects":[],' +
                                '"predictions":[],"object_counts":{}}'
                            )
                        }

                        # save the processed object data to metadata file
                        [System.IO.File]::WriteAllText(
                            $metadataFilePath,
                            $newContent
                        )

                        # output verbose confirmation of successful save
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Successfully saved object metadata for: $image"
                        )
                    }
                    catch {

                        # log any errors that occur during metadata processing
                        Microsoft.PowerShell.Utility\Write-Warning (
                            "$PSItem`r`n$objects"
                        )
                    }
                }
            }
            catch {

                # log any errors that occur during image processing
                Microsoft.PowerShell.Utility\Write-Warning (
                    "Error processing image '$image': " +
                    "$($_.Exception.Message)"
                )
            }
        }
    }    end {
    }
}
################################################################################
