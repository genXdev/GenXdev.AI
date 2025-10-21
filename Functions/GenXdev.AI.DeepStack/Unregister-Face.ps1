<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : Unregister-Face.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.304.2025
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
Deletes a registered face by its identifier from DeepStack.

.DESCRIPTION
This function deletes a face from the DeepStack face recognition system using
its unique identifier. It communicates with the API endpoint to remove the
registered face data from the system permanently.

.PARAMETER Identifier
The unique identifier of the face to delete from the DeepStack system.

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

.EXAMPLE
Unregister-Face -Identifier "JohnDoe" -NoDockerInitialize $false `
    -ContainerName "deepstack_face_recognition" -ServicePort 5000

.EXAMPLE
rface "JohnDoe"

.NOTES
DeepStack API Documentation: POST /v1/vision/face/delete endpoint
This endpoint is used to remove a previously registered face from the system.
#>
function Unregister-Face {

    [CmdletBinding(SupportsShouldProcess)]
    [OutputType([System.Boolean])]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = ('The unique identifier of the face to delete from ' +
                'the DeepStack system'),
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Identifier,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        ###############################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###############################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###############################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###############################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoDockerInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use GPU-accelerated version (requires NVIDIA GPU)'
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

        # use script-scoped variables set by ensuredeepstack, with fallback
        # defaults
        if (-not $ApiBaseUrl) {
            $NoDockerInitialize = $false
        }

        # ensure the deepstack face recognition service is running
        if (-not $NoDockerInitialize) {
            Microsoft.PowerShell.Utility\Write-Verbose ('Ensuring DeepStack ' +
                'face recognition service is available')

            # copy matching parameters to pass to ensuredeepstack function
            $ensureParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -ErrorAction SilentlyContinue)

            # initialize deepstack service with specified parameters
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose ('Skipping Docker ' +
                'initialization as requested')
        }

        # define internal helper function to validate face existence
        function Test-FaceExistence {

            param([string]$identifier)

            try {
                # retrieve all registered faces from deepstack service
                $registeredFaces = GenXdev.AI\Get-RegisteredFaces `
                    -NoDockerInitialize -ErrorAction Stop

                # check if the specified identifier exists in registered faces
                return $registeredFaces -contains $identifier
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose ('Unable to ' +
                    "verify if face exists: $_")

                # proceed with deletion attempt if we cannot verify existence
                return $true
            }
        }
    }    process {

        try {
            # validate identifier is not empty or whitespace
            if ([string]::IsNullOrWhiteSpace($Identifier)) {
                Microsoft.PowerShell.Utility\Write-Error ('Identifier ' +
                    'cannot be empty or whitespace')
                return
            }

            # check if we should proceed with deletion using whatif support
            if ($PSCmdlet.ShouldProcess($Identifier,
                    'Remove face registration')) {

                # verify face exists in system before attempting deletion
                if (-not (Test-FaceExistence -Identifier $Identifier)) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Face with ' +
                        "identifier '$Identifier' may not exist")
                }

                # construct the uri for the delete request with deepstack api
                $uri = "$($script:ApiBaseUrl)/v1/vision/face/delete"

                Microsoft.PowerShell.Utility\Write-Verbose ('Sending delete ' +
                    "request to: $uri")

                # create form data for deepstack api endpoint (like
                # register-face)
                $form = @{
                    userid = $Identifier
                }

                Microsoft.PowerShell.Utility\Write-Verbose ('Form data - ' +
                    "userid: '$Identifier'")

                # send delete request to the deepstack api endpoint using form
                # data
                $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                    -Verbose:$false `
                    -ProgressAction Continue `
                    -Uri $uri `
                    -Method Post `
                    -Form $form `
                    -TimeoutSec 30 `
                    -ErrorAction Stop

                Microsoft.PowerShell.Utility\Write-Verbose ('API Response: ' +
                    "$($response | Microsoft.PowerShell.Utility\ConvertTo-Json ' +
                    '-Depth 3)")

                # check if the response indicates success
                if ($response.PSObject.Properties['success'] -and
                    $response.success -eq $true) {
                    return $true
                }
                elseif ($response.PSObject.Properties['success'] -and
                    $response.success -eq $false) {
                    # deepstack returned an error in the response
                    $errorMessage = if ($response.error) {
                        $response.error
                    }
                    else {
                        'Unknown error'
                    }
                    Microsoft.PowerShell.Utility\Write-Error ('DeepStack ' +
                        "API error: $errorMessage")
                    return $false
                }
                else {
                    # no success property, assume failure
                    Microsoft.PowerShell.Utility\Write-Error ('Unexpected ' +
                        'API response format')
                    return $false
                }
            }
        }
        catch [System.Net.WebException] {
            # handle specific http error codes for better user feedback
            $statusCode = $_.Exception.Response.StatusCode

            # try to read the response content for more details
            try {
                $responseStream = $_.Exception.Response.GetResponseStream()
                $reader = Microsoft.PowerShell.Utility\New-Object `
                    System.IO.StreamReader($responseStream)
                $responseContent = $reader.ReadToEnd()
                $reader.Close()
                $responseStream.Close()

                Microsoft.PowerShell.Utility\Write-Verbose ('API Response: ' +
                    "$responseContent")

                # try to parse json response for error details
                try {
                    $errorResponse = $responseContent |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                    if ($errorResponse.error) {
                        Microsoft.PowerShell.Utility\Write-Error ('DeepStack ' +
                            "API error: $($errorResponse.error)")
                        return
                    }
                }
                catch {
                    # if json parsing fails, just show the raw response
                    Microsoft.PowerShell.Utility\Write-Error ('DeepStack ' +
                        "API response: $responseContent")
                    return
                }
            }
            catch {
                # if we can't read the response, fall back to generic error
                # handling
            }

            if ($statusCode -eq 404) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Face with ' +
                    "identifier '$Identifier' was not found")
                return $false
            }
            else {
                Microsoft.PowerShell.Utility\Write-Error ('Network error ' +
                    "while deleting face '$Identifier': $_")
                return $false
            }
        }
        catch [System.TimeoutException] {
            Microsoft.PowerShell.Utility\Write-Error ('Timeout while ' +
                "deleting face '$Identifier'")
            return $false
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error ('Failed to delete ' +
                "face '$Identifier': $_")            return $false
        }
    }

    end {
    }
}