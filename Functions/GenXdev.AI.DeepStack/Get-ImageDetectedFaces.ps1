################################################################################
<#
.SYNOPSIS
Recognizes faces in an uploaded image by comparing to known faces using
DeepStack.

.DESCRIPTION
This function analyzes an image file to identify faces by comparing them
against known faces in the database. It uses a local DeepStack face
recognition API running on a configurable port and returns face matches with
their confidence scores. The function supports GPU acceleration, custom
confidence thresholds, and Docker container management.

.PARAMETER ImagePath
The local path to the image file to analyze. This parameter accepts any valid
file path that can be resolved by the system.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. This is typically used
when already called by parent function to avoid duplicate initialization.

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for face recognition matches. Faces
with confidence below this threshold will be filtered out. Default is 0.5.

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
Get-ImageDetectedFaces -ImagePath "C:\Users\YourName\test.jpg"
Recognizes faces in the specified image using default settings.

.EXAMPLE
Get-ImageDetectedFaces -ImagePath "C:\photos\family.jpg" `
                         -ConfidenceThreshold 0.7 `
                         -UseGPU
Recognizes faces with higher confidence threshold using GPU acceleration.

.EXAMPLE
"C:\Users\YourName\test.jpg" | Get-ImageDetectedFaces

.NOTES
DeepStack API Documentation: POST /v1/vision/face/recognize endpoint for face
identification. Example: curl -X POST -F "image=@person1.jpg"
http://localhost:5000/v1/vision/face/recognize
#>
function Get-ImageDetectedFaces {

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
    )    begin {

        # use script-scoped variables set by EnsureDeepStack, with fallback
        # defaults
        if (-not $script:ApiBaseUrl) {
            $NoDockerInitialize = $false
        }

        # already a decimal from 0-1
        $script:ConfidenceThreshold = $ConfidenceThreshold

        # ensure that the DeepStack face recognition service is running
        if (-not $NoDockerInitialize) {
            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Ensuring DeepStack face recognition service is available")

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
            "Using DeepStack face recognition API at: $script:ApiBaseUrl"

        <#
        .SYNOPSIS
        Filters face recognition results based on confidence threshold.
        #>
        function Select-FaceResult {

            param($FaceData)

            # check if face data is valid and successful
            if (-not $FaceData -or -not $FaceData.success) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "No successful face data received"
                return @{ faces = @(); count = 0; predictions = @() }
            }

            # check if predictions are available
            if (-not $FaceData.predictions) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "No face predictions received"
                return @{ faces = @(); count = 0; predictions = @() }
            }

            # filter faces based on confidence threshold
            $filteredPredictions = @($FaceData.predictions |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.confidence -gt $script:ConfidenceThreshold
                })

            # extract just the face names for backward compatibility
            $faceNames = @($filteredPredictions |
                Microsoft.PowerShell.Core\ForEach-Object {
                    $_.userid
                })

            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Found $($filteredPredictions.Count) recognized face(s) " +
                 "with confidence > $script:ConfidenceThreshold")

            return @{
                faces = $faceNames
                count = $faceNames.Count
                # include full prediction data with positions and confidence
                predictions = $filteredPredictions
            }
        }
    }    process {

        try {

            # expand and validate the image path
            $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing image: $imagePath"

            # validate that the file is a valid image
            $null = GenXdev.AI\Test-ImageFile -Path $imagePath

            # construct the API endpoint URI for DeepStack face recognition
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/recognize"
            Microsoft.PowerShell.Utility\Write-Verbose "Sending request to: $uri"

            # create form data for DeepStack API (it expects multipart form
            # data, not JSON)
            $form = @{
                image = Microsoft.PowerShell.Management\Get-Item $imagePath
            }

            # send the request to the DeepStack face recognition API
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Sending image data to DeepStack face recognition API"
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 30

            # process the response from DeepStack
            $filteredResults = Select-FaceResult -FaceData $response
            Microsoft.PowerShell.Utility\Write-Output $filteredResults
        }
        catch [System.Net.WebException] {
            Microsoft.PowerShell.Utility\Write-Error `
                ("Network error while contacting DeepStack face recognition " +
                 "service: $_")
        }
        catch [System.TimeoutException] {
            Microsoft.PowerShell.Utility\Write-Error `
                ("Timeout while waiting for DeepStack face recognition " +
                 "response: $_")
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to recognize faces: $_"
        }
    }    end {

        # no cleanup required for this function
    }
}
################################################################################
