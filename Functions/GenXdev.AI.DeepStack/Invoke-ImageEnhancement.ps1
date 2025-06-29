################################################################################
<#
.SYNOPSIS
Enhances an image by enlarging it 4X while improving quality using DeepStack.

.DESCRIPTION
This function enhances an image by enlarging it to 4 times the original width
and height while simultaneously increasing the quality of the image. It uses
a local DeepStack image enhancement API running on a configurable port and
returns the enhanced image as base64 data or saves it to a file. The function
supports GPU acceleration and Docker container management.

.PARAMETER ImagePath
The local path to the image file to enhance. This parameter accepts any valid
file path that can be resolved by the system.

.PARAMETER OutputPath
Optional path where the enhanced image should be saved. If not specified,
the function returns the base64 encoded image data.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. This is typically used
when already called by parent function to avoid duplicate initialization.

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
Invoke-ImageEnhancement -ImagePath "C:\Users\YourName\small_photo.jpg" `
                        -OutputPath "C:\Users\YourName\enhanced_photo.jpg"
Enhances the image and saves it to the specified output path.

.EXAMPLE
enhanceimage "C:\photos\low_quality.jpg"
Enhances the image and returns the base64 data and dimensions using alias.

.EXAMPLE
Invoke-ImageEnhancement -ImagePath "C:\photos\image.jpg" -UseGPU
Enhances the image using GPU acceleration for faster processing.

.NOTES
DeepStack API Documentation: POST /v1/vision/enhance endpoint for image
enhancement. Example: curl -X POST -F "image=@low_quality.jpg"
http://localhost:5000/v1/vision/enhance

The enhanced image will be 4 times larger (2x width, 2x height) than the
original.
#>
###############################################################################
function Invoke-ImageEnhancement {

    [CmdletBinding()]
    [Alias("enhanceimage")]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "The local path to the image file to enhance"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("path", "FullName", "ImageFile", "ImageFilePath")]
        [string] $ImagePath,
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ("Optional path where the enhanced image should be " +
                          "saved")
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("outfile", "OutputFile", "EnhancedImagePath")]
        [string] $OutputPath,
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
            HelpMessage = ("The name for the Docker volume for persistent " +
                          "storage")
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
            HelpMessage = ("Maximum time in seconds to wait for service " +
                          "health check")
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Interval in seconds between health check " +
                          "attempts")
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom Docker image name to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName
        #######################################################################
    )

    begin {

        # use script-scoped variables set by EnsureDeepStack, with fallback
        # defaults
        if (-not $ApiBaseUrl) {

            $NoDockerInitialize = $false
        }

        # ensure that the DeepStack image enhancement service is running
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                ("Ensuring DeepStack image enhancement service is " +
                 "available")

            # copy parameter values for the EnsureDeepStack function call
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack docker container if needed
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Skipping Docker initialization as requested"
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using DeepStack image enhancement API at: $script:ApiBaseUrl"

        #######################################################################
        <#
        .SYNOPSIS
        Processes the image enhancement result from DeepStack API.

        .DESCRIPTION
        This helper function processes the response from the DeepStack image
        enhancement API and formats it into a consistent result object. It
        handles saving the enhanced image to a file if an output path is
        provided and returns structured data about the enhancement results.

        .PARAMETER EnhanceData
        The response data from the DeepStack API containing the enhanced image
        information including base64 data and dimensions.

        .PARAMETER OutputPath
        Optional path where the enhanced image should be saved to disk.
        #>
        function Format-EnhancementResult {

            param(
                $EnhanceData,
                $OutputPath
            )

            # check if enhancement data is valid and successful
            if (-not $EnhanceData -or -not $EnhanceData.success) {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "No successful enhancement data received"

                return @{
                    success = $false
                    message = "Image enhancement failed"
                }
            }

            # extract enhancement results
            $base64Data = $EnhanceData.base64

            $width = $EnhanceData.width

            $height = $EnhanceData.height

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Enhanced image dimensions: ${width}x${height}"

            $result = @{
                success = $true
                base64 = $base64Data
                width = $width
                height = $height
                size_multiplier = 4
            }

            # save to file if output path is specified
            if ($OutputPath -and $base64Data) {

                try {

                    # expand the output path
                    $expandedOutputPath = GenXdev.FileSystem\Expand-Path `
                        $OutputPath

                    # ensure output directory exists
                    $outputDir = Microsoft.PowerShell.Management\Split-Path `
                        $expandedOutputPath `
                        -Parent

                    if (-not (Microsoft.PowerShell.Management\Test-Path `
                        $outputDir)) {

                        $null = Microsoft.PowerShell.Management\New-Item `
                            -Path $outputDir `
                            -ItemType Directory `
                            -Force
                    }

                    # convert base64 to bytes and save to file
                    $imageBytes = [System.Convert]::FromBase64String(`
                        $base64Data)

                    [System.IO.File]::WriteAllBytes(`
                        $expandedOutputPath, `
                        $imageBytes)

                    $result.output_path = $expandedOutputPath

                    $result.file_size_bytes = $imageBytes.Length

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Enhanced image saved to: $expandedOutputPath"
                }
                catch {

                    Microsoft.PowerShell.Utility\Write-Warning `
                        ("Failed to save enhanced image to " +
                         "$OutputPath`: $_")

                    $result.save_error = $_.Exception.Message
                }
            }

            return $result
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

            # construct the API endpoint URI for DeepStack image enhancement
            $uri = "$($script:ApiBaseUrl)/v1/vision/enhance"

            Microsoft.PowerShell.Utility\Write-Verbose "Sending request to: $uri"

            # create form data for DeepStack API (it expects multipart form data)
            $form = @{
                image = Microsoft.PowerShell.Management\Get-Item $imagePath
            }

            # send the request to the DeepStack image enhancement API
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Sending image data to DeepStack image enhancement API"

            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 120 `
                -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Enhancement completed successfully"

            # process the response from DeepStack
            $enhancementResult = Format-EnhancementResult `
                -EnhanceData $response `
                -OutputPath $OutputPath

            Microsoft.PowerShell.Utility\Write-Output $enhancementResult
        }
        catch [System.Net.WebException] {

            Microsoft.PowerShell.Utility\Write-Error `
                "Network error during image enhancement: $_"
        }
        catch [System.TimeoutException] {

            Microsoft.PowerShell.Utility\Write-Error `
                ("Timeout during image enhancement for $imagePath " +
                 "(enhancement can take longer for large images)")
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to enhance image $imagePath`: $_"
        }
    }

    end {

        # no cleanup required for this function
    }
}
################################################################################
