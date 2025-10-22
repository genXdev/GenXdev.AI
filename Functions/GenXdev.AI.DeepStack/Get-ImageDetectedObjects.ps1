<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : Get-ImageDetectedObjects.ps1
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
###############################################################################
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

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for object detection. Objects with
confidence below this threshold will be filtered out. Default is 0.5.

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

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. This is typically used
when already called by parent function to avoid duplicate initialization.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This is useful for troubleshooting or updating the DeepStack image.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. This requires an
NVIDIA GPU with proper Docker GPU support configured.

.EXAMPLE
Get-ImageDetectedObjects -ImagePath "C:\Users\YourName\test.jpg" `
                         -ConfidenceThreshold 0.5 `
                         -ServicePort 5000

Detects objects in the specified image with full parameter names.

.EXAMPLE
Get-ImageDetectedObjects "C:\photos\street.jpg"

Detects objects using positional parameter and default settings.

.NOTES
DeepStack API Documentation: POST /v1/vision/detection endpoint for object
detection. Example: curl -X POST -F "image=@street.jpg"
http://localhost:5000/v1/vision/detection

Supported object classes include: person, bicycle, car, motorcycle, airplane,
bus, train, truck, boat, traffic light, fire hydrant, stop sign, parking
meter, bench, bird, cat, dog, horse, sheep, cow, elephant, bear, zebra,
giraffe, backpack, umbrella, handbag, tie, suitcase, frisbee, skis, snowboard,
sports ball, kite, baseball bat, baseball glove, skateboard, surfboard, tennis
racket, bottle, wine glass, cup, fork, knife, spoon, bowl, banana, apple,
sandwich, orange, broccoli, carrot, hot dog, pizza, donut, cake, chair, couch,
potted plant, bed, dining table, toilet, tv, laptop, mouse, remote, keyboard,
cell phone, microwave, oven, toaster, sink, refrigerator, book, clock, vase,
scissors, teddy bear, hair drier, toothbrush.
#>
function Get-ImageDetectedObjects {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        #######################################################################
        [parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The local path to the image file to analyze'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImagePath,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Minimum confidence threshold (0.0-1.0). ' +
                'Default is 0.5')
        )]
        [ValidateRange(0.0, 1.0)]
        [double]
        $ConfidenceThreshold = 0.5,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ContainerName = 'deepstack_face_recognition',

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $VolumeName = 'deepstack_face_data',

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int]
        $ServicePort = 5000,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int]
        $HealthCheckTimeout = 60,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int]
        $HealthCheckInterval = 3,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string]
        $ImageName,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch]
        $NoDockerInitialize,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch]
        $Force,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Use GPU-accelerated version (requires NVIDIA ' +
                'GPU)')
        )]
        [switch]
        $UseGPU,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show Docker Desktop window during initialization'
        )]
        [Alias('sw')]
        [switch]$ShowWindow
        ###################################################################
    )

    begin {

        # use script-scoped variables set by ensuredeepstack, with fallback
        # defaults
        if (-not $ApiBaseUrl) {

            $NoDockerInitialize = $false
        }

        # store confidence threshold for filtering
        $script:ConfidenceThreshold = $ConfidenceThreshold

        # ensure that the deepstack object detection service is running
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose `
            ('Ensuring DeepStack object detection service is ' +
                'available')

            # copy parameter values for the ensuredeepstack function call
            $ensureParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # initialize deepstack docker container if needed
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
        ('Using DeepStack object detection API at: ' +
            "$script:ApiBaseUrl")        #######################################################################
        <#
        .SYNOPSIS
        Filters object detection results based on confidence threshold.

        .DESCRIPTION
        This function takes the raw output from the DeepStack API and filters
        the detected objects based on the configured confidence threshold. It
        also reshapes the data for easier consumption in PowerShell.

        .PARAMETER ObjectData
        The object data returned from the DeepStack API.

        .EXAMPLE
        Select-ObjectDetection -ObjectData $apiResponse
        #>
        function Select-ObjectDetection {

            param(
                ###############################################################
                [parameter(Mandatory = $true)]
                $ObjectData
                ###############################################################
            )

            # check if object data is valid and successful
            if (-not $ObjectData -or -not $ObjectData.success) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    'No successful object data received'

                return @{
                    objects     = @()
                    count       = 0
                    predictions = @()
                }
            }

            # check if predictions are available
            if (-not $ObjectData.predictions) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    'No object predictions received'

                return @{
                    objects     = @()
                    count       = 0
                    predictions = @()
                }
            }

            # filter objects based on confidence threshold
            $filteredPredictions = @(
                $ObjectData.predictions |
                    Microsoft.PowerShell.Core\Where-Object {
                        $_.confidence -gt $script:ConfidenceThreshold
                    }
            )

            # group objects by label for summary
            $objectCounts = @{}

            foreach ($prediction in $filteredPredictions) {

                if ($objectCounts.ContainsKey($prediction.label)) {

                    $objectCounts[$prediction.label]++
                }
                else {

                    $objectCounts[$prediction.label] = 1
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
            ("Found $($filteredPredictions.Count) objects above " +
                "confidence threshold $script:ConfidenceThreshold")

            return @{
                objects       = $filteredPredictions
                count         = $filteredPredictions.Count
                predictions   = $filteredPredictions
                object_counts = $objectCounts
                success       = $true
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
            $null = GenXdev.AI\Test-DeepLinkImageFile -Path $imagePath

            # construct the api endpoint uri for deepstack object detection
            $uri = "$($script:ApiBaseUrl)/v1/vision/detection"

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Sending request to: $uri"

            # create form data for deepstack api
            # Validate image file exists before processing
            if (-not [System.IO.File]::Exists($imagePath)) {
                Microsoft.PowerShell.Utility\Write-Warning "Image file not found: $imagePath"
                return @{
                    success = $false
                    error = "No valid image file found"
                    duration = 0
                } | Microsoft.PowerShell.Utility\ConvertTo-Json
            }

            # the 'min_confidence' parameter expects a value between 0.0 and 1.0
            $form = @{
                image          = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $imagePath
                min_confidence = $ConfidenceThreshold
            }

            # send the request to the deepstack object detection api
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Sending image data to DeepStack object detection API'

            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 30 `
                -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose `
            ('API Response: ' +
                (
                    $response |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3
                ))

            # process the response from deepstack
            $filteredResults = Select-ObjectDetection -ObjectData $response

            Microsoft.PowerShell.Utility\Write-Output $filteredResults
        }
        catch [System.Net.WebException] {

            Microsoft.PowerShell.Utility\Write-Warning `
                "Network error during object detection: $_"
        }
        catch [System.TimeoutException] {

            Microsoft.PowerShell.Utility\Write-Warning `
                "Timeout during object detection for $imagePath"
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Warning `
                "Failed to detect objects in $imagePath`: $_"
        }
    }

    end {
    }
}