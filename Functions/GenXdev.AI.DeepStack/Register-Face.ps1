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

.PARAMETER NoDockerInitialize
Skip Docker initialization (used when already called by parent function).

.PARAMETER Force
Force rebuild of Docker container and remove existing data.

.PARAMETER UseGPU
Use GPU-accelerated version (requires NVIDIA GPU).

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
    )    begin {

        # use script-scoped variables set by ensuredeepstack with fallback defaults
        if (-not $ApiBaseUrl) {

            $noDockerInitialize = $false
        }

        # ensure deepstack face recognition service is running if not skipped
        if (-not $NoDockerInitialize) {

            # copy parameters that match ensuredeepstack function
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack service with matching parameters
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        } else {

            # log that docker initialization was skipped
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Skipping Docker initialization as requested"
        }

        # log the start of face registration process
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting face registration process for $Identifier"

        # validate the identifier format for api compatibility
        function Test-IdentifierFormat {

            param([string]$identifier)

            # check for empty or whitespace identifier
            if ([string]::IsNullOrWhiteSpace($identifier)) {

                throw "Identifier cannot be empty or whitespace"
            }

            # check for excessively long identifier
            if ($identifier.Length -gt 100) {

                throw "Identifier cannot be longer than 100 characters"
            }

            # check for invalid characters that might cause api issues
            $invalidChars = @('<', '>', '"', '/', '\', '|', '?', '*', ':')

            foreach ($char in $invalidChars) {

                # warn about potentially problematic characters
                if ($identifier.Contains($char)) {

                    Microsoft.PowerShell.Utility\Write-Warning `
                        ("Identifier contains potentially problematic " +
                         "character: $char")
                }
            }
        }
    }    process {

        try {

            # validate identifier format before proceeding with registration
            Test-IdentifierFormat -identifier $Identifier

            # expand any relative paths to absolute paths and validate all images
            $validatedImagePaths = @()

            foreach ($path in $ImagePath) {

                # expand relative path to absolute path for api compatibility
                $expandedPath = GenXdev.FileSystem\Expand-Path $path

                # log the image being processed
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Processing image: $expandedPath"

                # validate that the file is a supported image format
                GenXdev.AI\Test-DeepLinkImageFile -Path $expandedPath

                # add validated path to array for registration
                $validatedImagePaths += $expandedPath
            }

            # log the number of images being registered
            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Registering $($validatedImagePaths.Count) images for: " +
                 "$Identifier")

            # construct the api endpoint uri for deepstack face registration
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/register"

            # log the registration endpoint being used
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Registration endpoint: $uri"

            # create form data for deepstack api (expects multipart form data)
            $form = @{
                userid = $Identifier
            }

            # add each image to the form with sequential naming (image1, image2, etc.)
            for ($i = 0; $i -lt $validatedImagePaths.Count; $i++) {

                # use 'image' for single image, 'image1', 'image2' for multiple
                $imageKey = if ($validatedImagePaths.Count -eq 1) {
                    "image"
                } else {
                    "image$($i + 1)"
                }

                # add image file to form data
                $form[$imageKey] = Microsoft.PowerShell.Management\Get-Item `
                    $validatedImagePaths[$i]
            }

            # send the http request to the deepstack face recognition api
            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Uploading $($validatedImagePaths.Count) face image(s) " +
                 "for: $Identifier")

            # add connection retry logic with exponential backoff
            $maxAttempts = 3

            $attempt = 1

            $baseDelay = 2

            while ($attempt -le $maxAttempts) {

                try {

                    # attempt to upload face images to deepstack api
                    $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                        -Uri $uri `
                        -Method Post `
                        -Form $form `
                        -TimeoutSec 60

                    # success - break out of retry loop
                    break
                }
                catch [System.Net.WebException] {

                    # check if this is the final attempt
                    if ($attempt -eq $maxAttempts) {

                        # final attempt failed - re-throw the exception
                        throw
                    }

                    # calculate delay with exponential backoff (2, 4, 8 seconds)
                    $delay = $baseDelay * [Math]::Pow(2, $attempt - 1)

                    # log retry attempt with delay information
                    Microsoft.PowerShell.Utility\Write-Warning `
                        ("Connection attempt $attempt failed for $Identifier. " +
                         "Retrying in $delay seconds...")

                    # wait before retrying with exponential backoff
                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds $delay

                    # increment attempt counter for next iteration
                    $attempt++
                }
            }

            # log successful face registration
            Microsoft.PowerShell.Utility\Write-Output `
                ("Face(s) registered successfully for $Identifier " +
                 "($($validatedImagePaths.Count) image(s))")

            # return the response from deepstack
            return $response
        }
        catch [System.Net.WebException] {

            # handle network-related errors during registration
            Microsoft.PowerShell.Utility\Write-Error `
               "Network error during face registration: $_"
        }
        catch [System.TimeoutException] {

            # handle timeout errors during registration
            Microsoft.PowerShell.Utility\Write-Error `
                "Timeout during face registration for $Identifier"
        }
        catch {

            # handle any other errors during registration
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to register face for $Identifier`: $_"

            # attempt cleanup on any failure
            try {

                # try to remove partial registration data
                $null = GenXdev.AI\Unregister-Face `
                    -Identifier $Identifier `
                    -NoDockerInitialize `
                    -ErrorAction SilentlyContinue
            }
            catch {

                # warn if cleanup also failed
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to cleanup partial registration for $Identifier"
            }
         }
    }

    end {

    }
}
################################################################################
