<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : Unregister-AllFaces.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.270.2025
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
Removes all registered faces from the DeepStack face recognition system.

.DESCRIPTION
This function clears all registered faces from the DeepStack face recognition
database by removing all face files from the datastore directory and restarting
the service to reload an empty face registry. This is a destructive operation
that cannot be undone and will permanently remove all registered face data.

.PARAMETER Force
Bypasses confirmation prompts when removing all registered faces.

.PARAMETER NoDockerInitialize
Skip Docker Desktop initialization. Used when already called by parent function
to avoid duplicate initialization overhead.

.PARAMETER ForceRebuild
Force rebuild of Docker container and remove existing data. This will recreate
the entire DeepStack container from scratch.

.PARAMETER UseGPU
Use GPU-accelerated version of DeepStack. Requires NVIDIA GPU with proper
Docker GPU support configured.

.PARAMETER ContainerName
The name for the Docker container running DeepStack face recognition service.

.PARAMETER VolumeName
The name for the Docker volume used for persistent storage of face data.

.PARAMETER ServicePort
The port number for the DeepStack face recognition service HTTP API.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check to pass after
container operations.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts when verifying service
availability.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image.

.EXAMPLE
Unregister-AllFaces

Removes all registered faces with confirmation prompt.

.EXAMPLE
Unregister-AllFaces -Force

Removes all registered faces without confirmation prompt.

.EXAMPLE
unregall -Force

Uses alias to remove all faces without confirmation.
#>
function Unregister-AllFaces {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Bypass confirmation prompts when removing all ' +
            'registered faces'
        )]
        [switch] $Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip Docker Desktop initialization (used when ' +
            'already called by parent function)'
        )]
        [switch] $NoDockerInitialize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuild of Docker container and remove ' +
            'existing data'
        )]
        [switch] $ForceRebuild,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use GPU-accelerated version (requires NVIDIA GPU)'
        )]
        [switch] $UseGPU,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'The name for the Docker volume for persistent ' +
            'storage'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = 'Maximum time in seconds to wait for service health ' +
            'check'
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = 'Interval in seconds between health check attempts'
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
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

        # use script-scoped variables set by ensuredeepstack with fallback
        # defaults
        if (-not $ApiBaseUrl) {

            $NoDockerInitialize = $false
        }

        # initialize container name from script scope if not already set
        if (-not $script:ContainerName) {

            $script:ContainerName = 'deepstack_face_recognition'
        }

        # ensure the deepstack face recognition service is running
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Ensuring DeepStack face recognition service is available'
            )

            # copy matching parameters from current function to ensure function
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # handle force rebuild parameter with null coalescing
            if ($ForceRebuild) {

                $ensureParams.Force = $true
            }
            else {

                $ensureParams.Force = $PSBoundParameters.ContainsKey('ForceRebuild') ? $false : $null
            }

            # ensure deepstack service is running and accessible
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Skipping Docker initialization as requested'
            )
        }

        ###########################################################################
        <#
        .SYNOPSIS
        Verifies that the container is running and the service is accessible.
        #>
        function Test-ContainerHealth {

            try {

                # first check if container is running
                $containerId = docker ps `
                    --filter "name=^$script:ContainerName$" `
                    --format '{{.ID}}' 2>$null

                # return false if container is not running
                if ([string]::IsNullOrWhiteSpace($containerId)) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Container $script:ContainerName is not running"
                    )

                    return $false
                }

                # test http service accessibility using same approach as
                # ensureFaceRecognition
                try {

                    # construct the uri for retrieving registered faces from deepstack
                    $uri = "$($script:ApiBaseUrl)/v1/vision/face/list"

                    # output verbose information about the api request
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Requesting registered faces from: $uri"
                    )

                    # invoke the rest api to get registered faces using post method
                    $null = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                        -Verbose:$false `
                        -ProgressAction Continue `
                        -Uri $uri `
                        -Method Post `
                        -ContentType 'application/json' `
                        -Body '{}' `
                        -TimeoutSec 30 `
                        -ErrorAction Stop

                    return $true
                }
                catch {

                    # fallback to root endpoint if /faces fails
                    try {

                        $null = Microsoft.PowerShell.Utility\Invoke-WebRequest `
                            -Uri "$script:ApiBaseUrl/" `
                            -Method Get `
                            -TimeoutSec 5 `
                            -ErrorAction Stop

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Service health check passed using root endpoint'
                        )

                        return $true
                    }
                    catch {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Service health check failed on both /faces and ' +
                            'root endpoints'
                        )

                        return $false
                    }
                }
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Container health check failed: $_"
                )

                return $false
            }
        }

        ###########################################################################
        <#
        .SYNOPSIS
        Recreates the faces directory structure in the container.
        #>
        function Initialize-FacesDirectory {

            try {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Ensuring faces directory structure exists'
                )

                # ensure the faces directory exists with proper permissions
                $null = docker exec $script:ContainerName `
                    mkdir -p /datastore 2>$null

                # throw error if directory creation failed
                if ($LASTEXITCODE -ne 0) {

                    throw 'Failed to create faces directory'
                }

                # set proper permissions
                $null = docker exec $script:ContainerName `
                    chmod 755 /datastore 2>$null

                # warn if permission setting failed but continue
                if ($LASTEXITCODE -ne 0) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Failed to set directory permissions'
                    )
                }

                # verify the directory is accessible and empty
                $null = docker exec $script:ContainerName `
                    test -d /datastore 2>$null

                # throw error if directory verification failed
                if ($LASTEXITCODE -ne 0) {

                    throw 'Faces directory verification failed'
                }

                # test write permissions
                $null = docker exec $script:ContainerName `
                    touch /datastore/.test_write 2>$null

                # verify write permissions and clean up test file
                if ($LASTEXITCODE -eq 0) {

                    $null = docker exec $script:ContainerName `
                        rm -f /datastore/.test_write 2>$null

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Directory is writable and ready'
                    )
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Directory write test failed'
                    )
                }

                return $true
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Error (
                    "Failed to initialize faces directory: $_"
                )

                return $false
            }
        }
    }    process {

        try {

            # check if we should proceed with face removal
            $confirmMessage = (
                'This will remove ALL registered faces from the system. ' +
                'This action cannot be undone.'
            )

            # proceed only if force is used or user confirms the action
            if ($Force -or $PSCmdlet.ShouldProcess('All registered faces', $confirmMessage)) {

                # verify container health before proceeding with operations
                if (-not (Test-ContainerHealth)) {

                    # handle case where docker initialization was skipped
                    if ($NoDockerInitialize) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Container is not accessible and Docker ' +
                            'initialization was skipped. Cannot proceed with ' +
                            'face cleanup.'
                        )

                        Microsoft.PowerShell.Utility\Write-Output (
                            'Face cleanup skipped - container not accessible'
                        )

                        return
                    }
                    else {

                        throw 'Container is not healthy or accessible'
                    }
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Removing all faces from: /datastore'
                )

                # remove all contents of faces directory using comprehensive
                # approach first try to remove all image files specifically
                $removeFilesResult = docker exec $script:ContainerName bash -c (
                    'find /datastore -type f \( ' +
                    "-name '*.jpg' -o -name '*.jpeg' -o -name '*.png' -o " +
                    "-name '*.gif' \) -delete"
                ) 2>&1

                # warn if specific image file removal failed but continue
                if ($LASTEXITCODE -ne 0) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to remove image files: $removeFilesResult"
                    )
                }

                # then remove any remaining files and subdirectories
                $removeAllResult = docker exec $script:ContainerName bash -c (
                    'rm -rf /datastore/* /datastore/.*'
                ) 2>&1

                # note if some hidden files could not be removed
                if ($LASTEXITCODE -ne 0) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Note: Some hidden files may not have been removed: ' +
                        "$removeAllResult"
                    )
                }

                # verify the directory is empty after cleanup
                $null = docker exec $script:ContainerName bash -c (
                    'ls -la /datastore'
                ) 2>&1

                # count remaining files to verify cleanup success
                $remainingFiles = docker exec $script:ContainerName bash -c (
                    'find /datastore -type f | wc -l'
                ) 2>&1

                # verify all files were successfully removed
                if ($LASTEXITCODE -eq 0 -and $remainingFiles -match '^\s*0\s*$') {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        '✅ All files successfully removed from faces directory'
                    )
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Some files may still remain in faces directory: ' +
                        "$remainingFiles files found"
                    )
                }

                # recreate the directory structure for clean state
                if (Initialize-FacesDirectory) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Faces directory structure recreated'
                    )

                    # restart container to reload face recognition service this
                    # ensures in-memory faces_dict is cleared and reloaded from
                    # empty directory
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Restarting face recognition service to reload empty ' +
                        'faces directory...'
                    )

                    # restart the docker container
                    $restartResult = docker restart $script:ContainerName 2>&1

                    # verify restart was successful
                    if ($LASTEXITCODE -eq 0) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Service restarted successfully'
                        )

                        # wait for service to be ready after restart
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5

                        # verify service is responding after restart
                        $maxRetries = 10
                        $retryCount = 0
                        $serviceReady = $false

                        # wait for service to become ready with retry logic
                        while ($retryCount -lt $maxRetries -and -not $serviceReady) {

                            # test if service is responsive
                            if (Test-ContainerHealth) {

                                $serviceReady = $true

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    'Service is ready after restart'
                                )
                            }
                            else {

                                $retryCount++

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    'Waiting for service to be ready... ' +
                                    "($retryCount/$maxRetries)"
                                )

                                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2
                            }
                        }

                        # warn if service is not ready after all retries
                        if (-not $serviceReady) {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                'Service may not be fully ready after restart'
                            )
                        }
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Failed to restart service: $restartResult"
                        )
                    }

                    Microsoft.PowerShell.Utility\Write-Output (
                        'All faces unregistered successfully.'
                    )
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Directory cleanup completed but structure recreation ' +
                        'failed'
                    )
                }

                # optional verification by checking if any faces remain
                # registered
                try {

                    # get list of remaining registered faces
                    $remainingFaces = GenXdev.AI\Get-RegisteredFaces `
                        -NoDockerInitialize `
                        -ErrorAction SilentlyContinue

                    # warn if some faces are still registered after cleanup
                    if ($remainingFaces -and $remainingFaces.Count -gt 0) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Some faces may still be registered after cleanup'
                        )
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Verified: No faces remain registered'
                        )
                    }
                }
                catch {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Could not verify cleanup completion: $_"
                    )
                }
            }
            else {

                Microsoft.PowerShell.Utility\Write-Output (
                    'Operation cancelled by user'
                )
            }
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to unregister all faces: $_"
            )
        }
    }    end {

    }
}