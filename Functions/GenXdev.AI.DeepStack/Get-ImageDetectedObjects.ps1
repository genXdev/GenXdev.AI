################################################################################
<#
.SYNOPSIS
Detects and classifies objects in an uploaded image using DeepStack.

.DESCRIPTION
This function analyzes an image file to detect and classify up to 80 different
kinds of objects. It uses a local DeepStack object detection API running on a
configurable port and returns object classifications with their bounding box
coordinates and confidence scores. The function supports GPU acceleration,
custom confidence thresholds, and Docker container management.

.PARAMETER ImagePath
The local path to the image file to analyze. This parameter accepts any valid
file path that can be resolved by the system.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. This is typically used
when already called by parent function to avoid duplicate initialization.

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for object detection. Objects with
confidence below this threshold will be filtered out. Default is 0.5.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This is useful for troubleshooting or updating the DeepStack image.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. This requires an
NVIDIA GPU with proper Docker GPU support configured.

.PARAMETER ContainerName
The name for the Docker container. This allows multiple DeepStack instances
or custom naming conventions. Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage. This ensures face data
persists between container restarts. Default is "deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service. Must be between 1 and 65535.
Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Must be between 10
and 300 seconds. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Must be between 1 and 10
seconds. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image. This
allows using custom or updated DeepStack images.

.PARAMETER FacesPath
The path inside the container where faces are stored. This should match the
DeepStack configuration. Default is "/datastore".

.EXAMPLE
Get-ImageDetectedObjects -ImagePath "C:\Users\YourName\test.jpg"
Detects objects in the specified image using default settings.

.EXAMPLE
Get-ImageDetectedObjects -ImagePath "C:\photos\street.jpg" `
                         -ConfidenceThreshold 0.7 `
                         -UseGPU
Detects objects with higher confidence threshold using GPU acceleration.

.EXAMPLE
"C:\Users\YourName\test.jpg" | Get-ImageDetectedObjects

.NOTES
DeepStack API Documentation: POST /v1/vision/detection endpoint for object detection.
Example: curl -X POST -F "image=@street.jpg"
http://localhost:5000/v1/vision/detection

Supported object classes include: person, bicycle, car, motorcycle, airplane, bus,
train, truck, boat, traffic light, fire hydrant, stop sign, parking meter, bench,
bird, cat, dog, horse, sheep, cow, elephant, bear, zebra, giraffe, backpack,
umbrella, handbag, tie, suitcase, frisbee, skis, snowboard, sports ball, kite,
baseball bat, baseball glove, skateboard, surfboard, tennis racket, bottle,
wine glass, cup, fork, knife, spoon, bowl, banana, apple, sandwich, orange,
broccoli, carrot, hot dog, pizza, donut, cake, chair, couch, potted plant, bed,
dining table, toilet, tv, laptop, mouse, remote, keyboard, cell phone, microwave,
oven, toaster, sink, refrigerator, book, clock, vase, scissors, teddy bear,
hair drier, toothbrush.
#>
function Get-ImageDetectedObjects {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]

    param(
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The local path to the image file to analyze"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Skip Docker initialization (used when already " +
                          "called by parent function)")
        )]
        [switch] $NoDockerInitialize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Minimum confidence threshold (0.0-1.0). " +
                          "Default is 0.5")
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.5,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Force rebuild of Docker container and remove " +
                          "existing data")
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use GPU-accelerated version (requires NVIDIA " +
                          "GPU)")
        )]
        [switch] $UseGPU,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The name for the Docker volume for persistent " +
                          "storage")
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Maximum time in seconds to wait for service " +
                          "health check")
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Interval in seconds between health check " +
                          "attempts")
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom Docker image name to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The path inside the container where faces are " +
                          "stored")
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FacesPath = "/datastore"
        ###########################################################################
    )

    begin {

        # use script-scoped variables set by EnsureDeepStack, with fallback
        # defaults
        if (-not $script:ApiBaseUrl) {
            $NoDockerInitialize = $false
        }

        # store confidence threshold for filtering
        $script:ConfidenceThreshold = $ConfidenceThreshold

        # ensure that the DeepStack object detection service is running
        if (-not $NoDockerInitialize) {
            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Ensuring DeepStack object detection service is available")

            # copy parameter values for the EnsureDeepStack function call
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack docker container if needed
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Skipping Docker initialization as requested"
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using DeepStack object detection API at: $script:ApiBaseUrl"

        <#
        .SYNOPSIS
        Filters object detection results based on confidence threshold.
        #>
        function Select-ObjectDetection {

            param($ObjectData)

            # check if object data is valid and successful
            if (-not $ObjectData -or -not $ObjectData.success) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "No successful object data received"
                return @{ objects = @(); count = 0; predictions = @() }
            }

            # check if predictions are available
            if (-not $ObjectData.predictions) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "No object predictions received"
                return @{ objects = @(); count = 0; predictions = @() }
            }

            # filter objects based on confidence threshold
            # note: API returns confidence as percentage (0-99), convert to 0-1 scale
            $filteredPredictions = @($ObjectData.predictions |
                Microsoft.PowerShell.Core\Where-Object {
                    ($_.confidence / 100.0) -gt $script:ConfidenceThreshold
                })

            # group objects by label for summary
            $objectCounts = @{}
            foreach ($prediction in $filteredPredictions) {
                if ($objectCounts.ContainsKey($prediction.label)) {
                    $objectCounts[$prediction.label]++
                } else {
                    $objectCounts[$prediction.label] = 1
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Found $($filteredPredictions.Count) objects above " +
                 "confidence threshold $script:ConfidenceThreshold")

            return @{
                objects = $filteredPredictions
                count = $filteredPredictions.Count
                predictions = $filteredPredictions
                object_counts = $objectCounts
                success = $true
            }
        }
    }

    process {

        try {

            # expand and validate the image path
            $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing image: $imagePath"

            # validate that the file is a valid image
            $null = GenXdev.AI\Test-ImageFile -Path $imagePath

            # construct the API endpoint URI for DeepStack object detection
            $uri = "$($script:ApiBaseUrl)/v1/vision/detection"
            Microsoft.PowerShell.Utility\Write-Verbose "Sending request to: $uri"

            # create form data for DeepStack API (it expects multipart form data)
            $form = @{
                image = Microsoft.PowerShell.Management\Get-Item $imagePath
                min_confidence = [math]::Round($ConfidenceThreshold * 100, 0)
            }

            # send the request to the DeepStack object detection API
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Sending image data to DeepStack object detection API"
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 30 `
                -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose `
                ("API Response: " +
                 "$($response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3)")

            # process the response from DeepStack
            $filteredResults = Select-ObjectDetection -ObjectData $response
            Microsoft.PowerShell.Utility\Write-Output $filteredResults
        }
        catch [System.Net.WebException] {
            Microsoft.PowerShell.Utility\Write-Error `
                "Network error during object detection: $_"
        }
        catch [System.TimeoutException] {
            Microsoft.PowerShell.Utility\Write-Error `
                "Timeout during object detection for $imagePath"
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to detect objects in $imagePath`: $_"
        }
    }

    end {

        # no cleanup required for this function
    }
}
################################################################################
