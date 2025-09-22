<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : Get-ImageDetectedFaces.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.280.2025
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

.EXAMPLE
Get-ImageDetectedFaces -ImagePath "C:\Users\YourName\test.jpg" `
                       -ConfidenceThreshold 0.5 `
                       -ContainerName "deepstack_face_recognition" `
                       -VolumeName "deepstack_face_data" `
                       -ServicePort 5000 `
                       -HealthCheckTimeout 60 `
                       -HealthCheckInterval 3
Recognizes faces in the specified image using full parameter names.

.EXAMPLE
Get-ImageDetectedFaces "C:\photos\family.jpg" -Force -UseGPU
Recognizes faces using positional parameter and aliases.

.EXAMPLE
"C:\Users\YourName\test.jpg" | Get-ImageDetectedFaces
Recognizes faces using pipeline input.

.NOTES
DeepStack API Documentation: POST /v1/vision/face/recognize endpoint for face
identification. Example: curl -X POST -F "image=@person1.jpg"
http://localhost:5000/v1/vision/face/recognize
###############################################################################>
function Get-ImageDetectedFaces {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The local path to the image file to analyze'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Minimum confidence threshold (0.0-1.0). ' +
                'Default is 0.5')
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.5,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoDockerInitialize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use GPU-accelerated version (requires NVIDIA ' +
                'GPU)')
        )]
        [switch] $UseGPU,
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

        # use script-scoped variables set by EnsureDeepStack, with fallback
        # defaults
        if (-not $ApiBaseUrl) {
            $NoDockerInitialize = $false
        }

        # set the confidence threshold for filtering face recognition results
        $script:ConfidenceThreshold = $ConfidenceThreshold

        # ensure that the DeepStack face recognition service is running
        if (-not $NoDockerInitialize) {
            Microsoft.PowerShell.Utility\Write-Verbose `
            ('Ensuring DeepStack face recognition service is ' +
                'available')

            # copy parameter values for the EnsureDeepStack function call
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack docker container if needed
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using DeepStack face recognition API at: $script:ApiBaseUrl"
    }

    process {

        try {

            # expand and validate the image path
            $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing image: $imagePath"

            # validate that the file is a valid image
            $null = GenXdev.AI\Test-DeepLinkImageFile -Path $imagePath

            # construct the API endpoint URI for DeepStack face recognition
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/recognize"

            Microsoft.PowerShell.Utility\Write-Verbose "Sending request to: $uri"

            # Validate image file exists before processing
            if (-not [System.IO.File]::Exists($imagePath)) {
                Microsoft.PowerShell.Utility\Write-Warning "Image file not found: $imagePath"
                return @{
                    success = $false
                    error = "No valid image file found"
                    duration = 0
                } | Microsoft.PowerShell.Utility\ConvertTo-Json
            }

            # create form data for DeepStack API (it expects multipart form
            # data, not JSON)
            $form = @{
                image = Microsoft.PowerShell.Management\Get-Item -LiteralPath $imagePath
            }

            # send the request to the DeepStack face recognition API
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Sending image data to DeepStack face recognition API'

            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 30

            # process the response from DeepStack
            if ($response.success -and $response.predictions) {
                $originalPredictionCount = $response.predictions.Count

                $filteredPredictions = @($response.predictions |
                        Microsoft.PowerShell.Core\Where-Object {
                            $_.confidence -gt $script:ConfidenceThreshold
                        })

                Microsoft.PowerShell.Utility\Write-Verbose `
                ("Found $($filteredPredictions.Count) recognized " +
                    "face(s) out of $originalPredictionCount with " +
                    "confidence > $script:ConfidenceThreshold")

                $response.predictions = $filteredPredictions
            }

            Microsoft.PowerShell.Utility\Write-Output $response
        }
        catch [System.Net.WebException] {
            Microsoft.PowerShell.Utility\Write-Warning `
            ('Network error while contacting DeepStack face recognition ' +
                "service: $_")
        }
        catch [System.TimeoutException] {
            Microsoft.PowerShell.Utility\Write-Warning `
            ('Timeout while waiting for DeepStack face recognition ' +
                "response: $_")
        }
        catch {
            # Check if this is a file access issue vs actual processing failure
            if ($_.Exception.Message -like "*Could not find item*" -or
                $_.Exception.Message -like "*No valid image file found*") {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Face detection skipped - file not accessible: $imagePath"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Face detection failed for $imagePath`: $($_.Exception.Message)"
            }
        }
    }

    end {

    }
}