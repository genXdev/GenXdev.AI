################################################################################
<#
.SYNOPSIS
Retrieves a list of all registered face identifiers from DeepStack.

.DESCRIPTION
This function connects to a local DeepStack face recognition API and retrieves all
registered face identifiers. It uses the /v1/vision/face/list endpoint.

.EXAMPLE
Get-RegisteredFaces

.EXAMPLE
Get-RegisteredFaces | Where-Object { $_ -like "John*" }

.NOTES
DeepStack API Documentation: POST /v1/vision/face/list endpoint
Example: curl -X POST http://localhost:5000/v1/vision/face/list
#>
function Get-RegisteredFaces {
    [CmdletBinding()]
    [Alias()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    param (
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip Docker initialization (used when already called by parent function)"
        )]
        [switch] $NoDockerInitialize,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force rebuild of Docker container and remove existing data"
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use GPU-accelerated version (requires NVIDIA GPU)"
        )]
        [switch] $UseGPU,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The name for the Docker volume for persistent storage"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum time in seconds to wait for service health check"
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Interval in seconds between health check attempts"
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom Docker image name to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The path inside the container where faces are stored"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FacesPath = "/datastore"
    )begin {

                # Use script-scoped variables set by EnsureDeepStack, with fallback defaults
                if (-not $script:ApiBaseUrl) {
                    $NoDockerInitialize = $false
                }        # Ensure the DeepStack face recognition module is loaded and available
        if (-not $NoDockerInitialize) {

            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'EnsureDeepStack' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose "Skipping Docker initialization as requested"
        }Microsoft.PowerShell.Utility\Write-Verbose "Connecting to DeepStack face recognition API at $script:ApiBaseUrl"

        <#
        .SYNOPSIS
        Processes the DeepStack API response and formats the results.
        #>
        function Format-FaceResult {
            param($ApiResponse)

            if (-not $ApiResponse) {
                Microsoft.PowerShell.Utility\Write-Verbose "No face data received from API"
                return @()
            }

            # Handle DeepStack response format
            if ($ApiResponse.success -and $ApiResponse.faces) {
                # DeepStack returns faces as an array of strings (face IDs/userids)
                $faceIds = $ApiResponse.faces
                Microsoft.PowerShell.Utility\Write-Verbose "Found $($faceIds.Count) registered faces"
                return $faceIds
            }
            elseif ($ApiResponse -is [array]) {
                Microsoft.PowerShell.Utility\Write-Verbose "Found $($ApiResponse.Count) registered faces"
                return $ApiResponse
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "Unexpected response format or no faces found"
                return @()
            }
        }
    }    process {
        try {
            # Construct the URI for retrieving registered faces from DeepStack
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/list"
            Microsoft.PowerShell.Utility\Write-Verbose "Requesting registered faces from: $uri"

            # Invoke the REST API to get registered faces (DeepStack uses POST for list operation)
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -ContentType "application/json" `
                -Body "{}" `
                -TimeoutSec 30 `
                -ErrorAction Stop

            # Format and return the results
            $formattedResults = Format-FaceResult -ApiResponse $response
            Microsoft.PowerShell.Utility\Write-Output $formattedResults
        }
        catch [System.Net.WebException] {

            $statusCode = $_.Exception.Response.StatusCode
            if ($statusCode -eq 404) {
                Microsoft.PowerShell.Utility\Write-Warning "DeepStack face recognition endpoint not found - service may not be running"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Error "Network error while retrieving registered faces: $_"
            }
        }
        catch [System.TimeoutException] {
            Microsoft.PowerShell.Utility\Write-Error "Timeout while retrieving registered faces from DeepStack API"
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to retrieve registered faces: $_"
        }
    }

    end {
        # No cleanup required
    }
}
################################################################################
