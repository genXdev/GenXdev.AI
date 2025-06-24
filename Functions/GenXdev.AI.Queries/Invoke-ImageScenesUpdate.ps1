################################################################################
<#
.SYNOPSIS
Updates scene classification metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to classify scenes using
artificial intelligence. It creates JSON metadata files containing scene
classifications, confidence scores, and labels. The function supports batch
processing with configurable confidence thresholds and can optionally skip
existing metadata files or retry previously failed classifications.

.PARAMETER ImageDirectory
The directory path containing images to process. Can be relative or absolute
path. Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all
subdirectories recursively.

.PARAMETER OnlyNew
If specified, only processes images that don't already have scene metadata
files or have empty metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images that have empty
metadata files or contain error indicators.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called
by parent function to avoid redundant container setup.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This will recreate the entire scene classification environment.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU
with appropriate drivers and CUDA support.

.PARAMETER ContainerName
The name for the Docker container running the scene classification service.
Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of classification models
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
Allows using alternative scene classification models or configurations.

.PARAMETER FacesPath
The path inside the container where face data is stored. This should match
the DeepStack configuration. Default is "/datastore".

.EXAMPLE
Invoke-ImageScenesUpdate -ImageDirectory "C:\Photos" -Recurse

Processes all images in C:\Photos and subdirectories for scene classification.

.EXAMPLE
scenerecognition "C:\Photos" -RetryFailed -OnlyNew

Uses alias to retry failed classifications and only process new images.

.EXAMPLE
Invoke-ImageScenesUpdate -ImageDirectory ".\MyImages" -Force -UseGPU

Forces container rebuild and uses GPU acceleration for faster processing.

.EXAMPLE
Invoke-ImageScenesUpdate -ImageDirectory "C:\Photos" -ConfidenceThreshold 0.6 -Recurse

Processes all images recursively and only stores scene classifications with confidence >= 60%.

.NOTES
This function stores scene classification data in NTFS alternative data streams
as 'ImageFile.jpg:scenes.json' files. Each metadata file contains scene
classification results with confidence scores and scene labels from DeepStack's
365 scene categories including places like: abbey, airplane_cabin, beach,
forest, kitchen, office, etc.
#>
###############################################################################
function Invoke-ImageScenesUpdate {

    [CmdletBinding()]
    [Alias("scenerecognition")]

    param(
        #######################################################################
        [Parameter(
            HelpMessage = "The directory path containing images to process"
        )]
        [string] $ImageDirectory = ".\",
        #######################################################################
        [Parameter(
            HelpMessage = "Custom Docker image name to use instead of default"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        #######################################################################
        [Parameter(
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        #######################################################################
        [Parameter(
            HelpMessage = "The name for the Docker volume for persistent storage"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        #######################################################################
        [Parameter(
            HelpMessage = "The path inside the container where faces are stored"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FacesPath = "/datastore",
        #######################################################################
        [Parameter(
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [Parameter(
            HelpMessage = ("Maximum time in seconds to wait for service " +
                          "health check")
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            HelpMessage = "Interval in seconds between health check attempts"
        )]        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Minimum confidence threshold (0.0-1.0) for scene " +
                          "classification. Default is 0.0")
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.0,
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
            HelpMessage = ("Only process images that don't already have scene " +
                          "metadata files")
        )]
        [switch] $OnlyNew,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Retry processing previously failed images that " +
                          "have empty metadata files")
        )]
        [switch] $RetryFailed,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Skip Docker initialization (used when already " +
                          "called by parent function)")
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
            HelpMessage = ("Use GPU-accelerated version (requires NVIDIA " +
                          "GPU)")
        )]
        [switch] $UseGPU
        #######################################################################
    )

    begin {

        # resolve the absolute path for the image directory
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectory

        # check if the specified directory exists
        if (-not (Microsoft.PowerShell.Management\Test-Path $path -PathType Container)) {

            throw "Directory not found: $path"
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing images in directory: $path"
        )

        # ensure that the DeepStack scene classification service is available
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Ensuring DeepStack scene classification service is available"
            )

            # copy parameter values for the EnsureDeepStack function call
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack docker container if needed
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        }
    }

    process {

        # discover all image files in the specified directory path, selectively
        # applying recursion only if the -Recurse switch was provided
        Microsoft.PowerShell.Management\Get-ChildItem `
            -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
            -Recurse:$Recurse `
            -File `
            -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                # store the full path to the current image for better readability
                $image = $PSItem.FullName

                # if retry mode is active, handle previously failed images
                if ($RetryFailed) {

                    if ([System.IO.File]::Exists("$($image):scenes.json")) {

                        # read existing metadata to check for empty or invalid content
                        $content = [System.IO.File]::ReadAllText(
                            "$($image):scenes.json")

                        # check if metadata file contains no scenes or invalid data
                        if ($content.StartsWith("{}") -or
                            $content -eq ('{"success":false,"scene":"unknown",' +
                                         '"confidence":0.0}')) {

                            $content = "{}"
                        }
                    }
                }

                Microsoft.PowerShell.Utility\Write-Verbose ("Processing image: " +
                                                            "$image")

                # remove read-only attribute if present to ensure file modification
                if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

                    $PSItem.Attributes = $PSItem.Attributes -bxor
                    [System.IO.FileAttributes]::ReadOnly
                }

                # check if a metadata file already exists for this image
                $metadataFilePath = "$($image):scenes.json"
                $fileExists = [System.IO.File]::Exists($metadataFilePath)

                # read existing content or use empty JSON object as default
                $content = if ($fileExists) {
                    [System.IO.File]::ReadAllText($metadataFilePath)
                } else {
                    "{}"
                }

                # determine if image should be processed based on options
                $shouldProcess = (
                    (-not $OnlyNew) -or
                    (-not $fileExists) -or
                    ($content -eq "{}") -or
                    (-not $content.Contains("scene"))
                )

                if ($shouldProcess) {

                    # create an empty metadata file as placeholder if needed
                    if (-not $fileExists) {

                        $null = [System.IO.File]::WriteAllText($metadataFilePath,
                                                               "{}")

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Created new metadata file for: $image")
                    }                    # obtain scene classification data using ai recognition technology
                    $sceneData = GenXdev.AI\Get-ImageDetectedScenes `
                        -ImagePath $image `
                        -ConfidenceThreshold $ConfidenceThreshold `
                        -NoDockerInitialize:$NoDockerInitialize

                    # process the returned scene data into standardized format
                    $processedData = if ($sceneData -and
                                         $sceneData.success -and
                                         $sceneData.scene) {

                        # create standardized data structure for scene metadata
                        @{
                            success = $sceneData.success
                            scene = $sceneData.scene
                            label = $sceneData.label
                            confidence = $sceneData.confidence
                            confidence_percentage = $sceneData.confidence_percentage
                            processed_at = (Microsoft.PowerShell.Utility\Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                        }

                    } else {

                        # create error data structure when scene detection fails
                        @{
                            success = $false
                            scene = "unknown"
                            label = "unknown"
                            confidence = 0.0
                            confidence_percentage = 0.0
                            processed_at = (Microsoft.PowerShell.Utility\Get-Date).ToString("yyyy-MM-dd HH:mm:ss")
                            error = "Scene classification failed"
                        }
                    }

                    # convert the processed data to json format for storage
                    $jsonData = $processedData |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

                    # save the scene metadata to the alternative data stream
                    $null = [System.IO.File]::WriteAllText($metadataFilePath,
                                                           $jsonData)

                    # provide feedback on processing completion
                    if ($processedData.success) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Scene classification completed for: $image - " +
                            "Scene: $($processedData.scene) " +
                            "(Confidence: $($processedData.confidence_percentage)%)")

                    } else {

                        Microsoft.PowerShell.Utility\Write-Warning (
                            "Scene classification failed for: $image")
                    }

                } else {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Skipping already processed image: $image")
                }
            }
    }

    end {
    }
}
################################################################################
