################################################################################
<#
.SYNOPSIS
Registers a new face with the DeepStack face recognition API.

.DESCRIPTION
This function registers a face image with the DeepStack face recognition API by
uploading the image to the local API endpoint. It ensures the DeepStack
service is running and validates the image file before upload. The function
includes retry logic, error handling, and cleanup on failure.

.PARAMETER Identifier
The unique identifier for the face (e.g., person's name). Cannot be empty or
contain special characters.

.PARAMETER ImagePath
Array of local paths to image files (png, jpg, jpeg, or gif). All files must
exist and be valid image formats. Multiple images can be registered for the
same identifier in a single API call.

.PARAMETER NoDockerInitialize
Skip Docker initialization (used when already called by parent function).

.PARAMETER Force
Force rebuild of Docker container and remove existing data.

.PARAMETER UseGPU
Use GPU-accelerated version (requires NVIDIA GPU).

.PARAMETER ContainerName
The name for the Docker container.

.PARAMETER VolumeName
The name for the Docker volume for persistent storage.

.PARAMETER ServicePort
The port number for the DeepStack service.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts.

.PARAMETER ImageName
Custom Docker image name to use.

.PARAMETER FacesPath
The path inside the container where faces are stored.

.EXAMPLE
Register-Face -Identifier "JohnDoe" -ImagePath @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")

.EXAMPLE
Register-Face "JohnDoe" @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")

.EXAMPLE
Register-Face -Identifier "JohnDoe" -ImagePath "C:\Users\YourName\faces\john.jpg"
#>
function Register-Face {

    [CmdletBinding()]

    param(
        ###################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = ("The unique identifier for the face " +
                          "(e.g., person's name)")
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Identifier,
        ###################################################################
        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = ("Array of local paths to image files " +
                          "(png, jpg, jpeg, or gif)")
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $ImagePath,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The name for the Docker container")
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The name for the Docker volume for persistent " +
                          "storage")
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Maximum time in seconds to wait for service " +
                          "health check")
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Interval in seconds between health check " +
                          "attempts")
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom Docker image name to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The path inside the container where faces " +
                          "are stored")
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FacesPath = "/datastore",
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Skip Docker initialization (used when already " +
                          "called by parent function)")
        )]
        [switch] $NoDockerInitialize,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Force rebuild of Docker container and remove " +
                          "existing data")
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use GPU-accelerated version (requires " +
                          "NVIDIA GPU)")
        )]
        [switch] $UseGPU
        ###################################################################
    )

    begin {

        # use script-scoped variables set by EnsureDeepStack with fallback defaults
        if (-not $script:ApiBaseUrl) {

            $noDockerInitialize = $false
        }

        # ensure deepstack face recognition service is running
        if (-not $NoDockerInitialize) {

            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        } else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Skipping Docker initialization as requested"
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting face registration process for $Identifier"

        <#
        .SYNOPSIS
        Validates the identifier format.
        #>
        function Test-IdentifierFormat {

            param([string]$identifier)

            if ([string]::IsNullOrWhiteSpace($identifier)) {

                throw "Identifier cannot be empty or whitespace"
            }

            if ($identifier.Length -gt 100) {

                throw "Identifier cannot be longer than 100 characters"
            }

            # check for invalid characters that might cause api issues
            $invalidChars = @('<', '>', '"', '/', '\', '|', '?', '*', ':')

            foreach ($char in $invalidChars) {

                if ($identifier.Contains($char)) {

                    Microsoft.PowerShell.Utility\Write-Warning `
                        ("Identifier contains potentially problematic " +
                         "character: $char")
                }
            }
        }
    }    process {

        try {            # validate identifier format
            Test-IdentifierFormat -identifier $Identifier

            # expand any relative paths to absolute paths and validate all images
            $validatedImagePaths = @()
            foreach ($path in $ImagePath) {
                $expandedPath = GenXdev.FileSystem\Expand-Path $path

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Processing image: $expandedPath"

                # validate that the file is a supported image format
                GenXdev.AI\Test-ImageFile -Path $expandedPath
                $validatedImagePaths += $expandedPath
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Registering $($validatedImagePaths.Count) images for: $Identifier"

            # construct the api endpoint uri for deepstack face registration
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/register"

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Registration endpoint: $uri"

            # create form data for deepstack api (expects multipart form data)
            $form = @{
                userid = $Identifier
            }

            # add each image to the form with sequential naming (image1, image2, etc.)
            for ($i = 0; $i -lt $validatedImagePaths.Count; $i++) {
                $imageKey = if ($validatedImagePaths.Count -eq 1) { "image" } else { "image$($i + 1)" }
                $form[$imageKey] = Microsoft.PowerShell.Management\Get-Item $validatedImagePaths[$i]
            }            # send the http request to the deepstack face recognition api
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Uploading $($validatedImagePaths.Count) face image(s) for: $Identifier"

            # add connection retry logic with exponential backoff
            $maxAttempts = 3

            $attempt = 1

            $baseDelay = 2

            while ($attempt -le $maxAttempts) {

                try {

                    $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                        -Uri $uri `
                        -Method Post `
                        -Form $form `
                        -TimeoutSec 60

                    # success - break out of retry loop
                    break
                }
                catch [System.Net.WebException] {

                    if ($attempt -eq $maxAttempts) {

                        # final attempt failed - re-throw the exception
                        throw
                    }

                    # calculate delay with exponential backoff (2, 4, 8 seconds)
                    $delay = $baseDelay * [Math]::Pow(2, $attempt - 1)

                    Microsoft.PowerShell.Utility\Write-Warning `
                        ("Connection attempt $attempt failed for $Identifier. " +
                         "Retrying in $delay seconds...")

                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds $delay

                    $attempt++
                }
            }

            Microsoft.PowerShell.Utility\Write-Output `
                "Face(s) registered successfully for $Identifier ($($validatedImagePaths.Count) image(s))"

            # return the response from deepstack
            return $response
        }
        catch [System.Net.WebException] {

            Microsoft.PowerShell.Utility\Write-Error `
               "Network error during face registration: $_"
        }
        catch [System.TimeoutException] {

            Microsoft.PowerShell.Utility\Write-Error `
                "Timeout during face registration for $Identifier"
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to register face for $Identifier`: $_"

            # attempt cleanup on any failure
            try {

                $null = GenXdev.AI\Unregister-Face `
                    -Identifier $Identifier `
                    -NoDockerInitialize `
                    -ErrorAction SilentlyContinue
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to cleanup partial registration for $Identifier"
            }
         }
    }

    end {

    }
}
################################################################################
