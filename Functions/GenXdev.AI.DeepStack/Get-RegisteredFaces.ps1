################################################################################
<#
.SYNOPSIS
Retrieves a list of all registered face identifiers from DeepStack.

.DESCRIPTION
This function connects to a local DeepStack face recognition API and retrieves
all registered face identifiers. It uses the /v1/vision/face/list endpoint to
query the DeepStack service and returns an array of face identifier strings. The
function handles Docker container initialization, API communication, and error
handling for various failure scenarios.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this parameter is specified. This is used when
the function is called by a parent function that has already initialized the
DeepStack service.

.PARAMETER Force
Force rebuild of the Docker container and remove existing data. This will
recreate the container from scratch and clear all stored face data.

.PARAMETER UseGPU
Use GPU-accelerated version of DeepStack. This requires an NVIDIA GPU and
appropriate drivers to be installed on the system.

.PARAMETER ContainerName
The name for the Docker container running DeepStack. Defaults to
"deepstack_face_recognition" if not specified.

.PARAMETER VolumeName
The name for the Docker volume used for persistent storage of face data.
Defaults to "deepstack_face_data" if not specified.

.PARAMETER ServicePort
The port number for the DeepStack service. Must be between 1 and 65535.
Defaults to 5000 if not specified.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check to complete. Must be
between 10 and 300 seconds. Defaults to 60 seconds if not specified.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Must be between 1 and 10
seconds. Defaults to 3 seconds if not specified.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image. This
allows using custom or modified DeepStack images.

.PARAMETER FacesPath
The path inside the container where faces are stored. Defaults to "/datastore"
if not specified.

.EXAMPLE
Get-RegisteredFaces

This example retrieves all registered faces using default parameters.

.EXAMPLE
Get-RegisteredFaces -Force -UseGPU

This example forces a rebuild of the container and uses GPU acceleration.

.EXAMPLE
Get-RegisteredFaces -ContainerName "my_deepstack" -ServicePort 8080

This example uses a custom container name and port number.

.EXAMPLE
Get-RegisteredFaces |
Where-Object { $_ -like "John*" }

This example retrieves all faces and filters for those starting with "John".

.NOTES
DeepStack API Documentation: POST /v1/vision/face/list endpoint
#>
function Get-RegisteredFaces {

    [CmdletBinding()]
    [Alias()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]

    param (
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip Docker initialization (used when already called by parent function)"
        )]
        [switch] $NoDockerInitialize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force rebuild of Docker container and remove existing data"
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use GPU-accelerated version (requires NVIDIA GPU)"
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
            HelpMessage = "The name for the Docker volume for persistent storage"
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
            HelpMessage = "Maximum time in seconds to wait for service health check"
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Interval in seconds between health check attempts"
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
            HelpMessage = "The path inside the container where faces are stored"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FacesPath = "/datastore"
        ###########################################################################
    )    begin {

        # check if api base url is available from script scope
        if (-not $ApiBaseUrl) {

            $NoDockerInitialize = $false
        }

        # ensure deepstack face recognition module is loaded and available
        if (-not $NoDockerInitialize) {

            # copy matching parameters for the ensure deepstack function
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack service with provided parameters
            $null = GenXdev.AI\EnsureDeepStack @ensureParams

        } else {

            # output verbose message when skipping docker initialization
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Skipping Docker initialization as requested"
            )
        }

        # output verbose information about the api connection
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Connecting to DeepStack face recognition API at $script:ApiBaseUrl"
        )

        # define helper function to process api response and format results
        function Format-FaceResult {

            param($ApiResponse)

            # check if api response contains data
            if (-not $ApiResponse) {

                # output verbose message when no face data received
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "No face data received from API"
                )

                return @()
            }

            # handle deepstack response format with success property and faces array
            if ($ApiResponse.success -and $ApiResponse.faces) {

                # extract face ids from the deepstack response
                $faceIds = $ApiResponse.faces

                # output verbose information about found faces
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found $($faceIds.Count) registered faces"
                )

                return $faceIds

            }
            # handle alternative response format where response is directly an array
            elseif ($ApiResponse -is [array]) {

                # output verbose information about found faces
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found $($ApiResponse.Count) registered faces"
                )

                return $ApiResponse

            }
            else {

                # output verbose message for unexpected response format
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Unexpected response format or no faces found"
                )

                return @()
            }
        }
    }

    process {

        try {

            # construct the uri for retrieving registered faces from deepstack
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/list"

            # output verbose information about the api request
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Requesting registered faces from: $uri"
            )

            # invoke the rest api to get registered faces using post method
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -ContentType "application/json" `
                -Body "{}" `
                -TimeoutSec 30 `
                -ErrorAction Stop

            # format and return the results using helper function
            $formattedResults = Format-FaceResult -ApiResponse $response

            # output the formatted results to the pipeline
            Microsoft.PowerShell.Utility\Write-Output $formattedResults

        }
        catch [System.Net.WebException] {

            # extract status code from web exception for specific error handling
            $statusCode = $_.Exception.Response.StatusCode

            # handle 404 error specifically for service not running
            if ($statusCode -eq 404) {

                # output warning for service not found
                Microsoft.PowerShell.Utility\Write-Warning (
                    "DeepStack face recognition endpoint not found - service may not be running"
                )

            }
            else {

                # output error for other network related issues
                Microsoft.PowerShell.Utility\Write-Error (
                    "Network error while retrieving registered faces: $_"
                )
            }
        }
        catch [System.TimeoutException] {

            # output error for timeout scenarios
            Microsoft.PowerShell.Utility\Write-Error (
                "Timeout while retrieving registered faces from DeepStack API"
            )
        }
        catch {

            # output error for all other unexpected exceptions
            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to retrieve registered faces: $_"
            )
        }
    }

    end {
    }
}
################################################################################
