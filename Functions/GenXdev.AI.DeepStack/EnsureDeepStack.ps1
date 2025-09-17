<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : EnsureDeepStack.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.272.2025
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
Ensures DeepStack face recognition service is installed and running.

.DESCRIPTION
This function sets up and manages DeepStack face recognition service using
Docker. It ensures that Docker Desktop is installed, pulls the DeepStack Docker
image, and runs the service in a container with persistent storage for
registered faces.

DeepStack provides a simple REST API for face detection, registration, and
recognition that is well-documented and actively maintained.

.PARAMETER ContainerName
The name for the Docker container. Default: "deepstack_face_recognition"

.PARAMETER VolumeName
The name for the Docker volume for persistent storage.
Default: "deepstack_face_data"

.PARAMETER ServicePort
The port number for the DeepStack service. Default: 5000

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Default: 60

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Default: 3

.PARAMETER ImageName
Custom Docker image name to use. If not specified, uses
deepquestai/deepstack:latest or deepquestai/deepstack:gpu based on UseGPU
parameter.

.PARAMETER Force
If specified, forces rebuilding of Docker container and removes existing data.
This will remove existing containers and volumes, pull latest DeepStack image,
create a fresh container with clean data, and clear all registered faces.

.PARAMETER UseGPU
If specified, uses the GPU-accelerated version of DeepStack (requires NVIDIA
GPU).

.EXAMPLE
EnsureDeepStack -ContainerName "deepstack_face_recognition" `
                -VolumeName "deepstack_face_data" `
                -ServicePort 5000 `
                -HealthCheckTimeout 60 `
                -HealthCheckInterval 3

.EXAMPLE
EnsureDeepStack -Force -UseGPU

.NOTES
DeepStack Face Recognition API Endpoints:
- POST /v1/vision/face/register : Register known faces
- POST /v1/vision/face/list : List registered faces
- POST /v1/vision/face/recognize : Recognize faces in image
- POST /v1/vision/face/delete : Remove registered face

For more information, see: https://docs.deepstack.cc/face-recognition/
#>
function EnsureDeepStack {

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param(
        ###################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        ###################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        ###################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        ###################################################################
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
        [switch]$ShowWindow,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int]$Width,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int]$Height,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch]$Left,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch]$Right,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch]$Bottom,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch]$Centered,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window'
        )]
        [Alias('fs')]
        [switch]$Fullscreen,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a ' +
                'different monitor than Powershell, or side by side with ' +
                'Powershell on the same monitor')
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch]$FocusWindow,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch]$SetForeground,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch]$SessionOnly,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch]$ClearSession,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch]$SkipSession
        ###################################################################
    )

    begin {

        # ensure graphics assembly is loaded for image processing
        if (-not [System.Drawing.Rectangle]) {

            Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Drawing
        }

        # set script-scoped variables from parameters for container management
        $script:containerName = $ContainerName

        # determine appropriate docker image based on gpu usage preference
        $script:imageName = if ($ImageName) {

            $ImageName

        } elseif ($UseGPU) {

            'deepquestai/deepstack:gpu'

        } else {

            'deepquestai/deepstack:latest'
        }

        # set script-scoped variables for docker volume and networking
        $script:volumeName = $VolumeName

        # construct base api url for service health checks
        $script:apiBaseUrl = "http://127.0.0.1:$ServicePort"

        # set script-scoped variables for service configuration
        $script:servicePort = $ServicePort

        # set script-scoped variables for health monitoring
        $script:healthCheckTimeout = $HealthCheckTimeout

        $script:healthCheckInterval = $HealthCheckInterval

        # store original location for cleanup at the end of the function
        $script:originalLocation = `
        (Microsoft.PowerShell.Management\Get-Location).Path

        ###################################################################
        <#
        .SYNOPSIS
        Tests if Docker is available and responsive.

        .DESCRIPTION
        Verifies that Docker Desktop is running and accessible by attempting to
        query the Docker version. Returns true if Docker responds properly.
        #>
        function Test-DockerAvailability {

            try {

                # attempt to get docker version to verify docker is running
                $null = docker version --format '{{.Server.Version}}' 2>$null

                # check if command succeeded
                if ($LASTEXITCODE -eq 0) {

                    # docker is responding, check if there are any login issues
                    $dockerInfo = docker info 2>&1

                    if ($dockerInfo -match 'not logged in' -or
                        $dockerInfo -match 'Please log in') {

                        Microsoft.PowerShell.Utility\Write-Verbose `
                        ('Docker engine is running but user is not ' +
                            'logged in. Some operations may require ' +
                            'authentication via Docker Desktop.')
                    }

                    return $true
                }

                return $false

            } catch {

                return $false
            }
        }
        ###################################################################
        <#
        .SYNOPSIS
        Tests if a Docker image exists.

        .DESCRIPTION
        Checks if a specified Docker image exists locally by querying the
        Docker image registry. Returns true if the image is found.
        #>
        function Test-DockerImage {

            param([string]$ImageName)

            try {

                # query docker for existing images matching the specified name
                $images = docker images $ImageName --format '{{.Repository}}' `
                    2>$null

                return -not [string]::IsNullOrWhiteSpace($images)

            } catch {

                return $false
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Tests if a Docker container exists (running or stopped).

        .DESCRIPTION
        Searches for a Docker container with the specified name, regardless of
        its current state. Returns true if a container with the name is found.
        #>
        function Test-DockerContainer {

            param([string]$ContainerName)

            try {

                # search for containers with exact name match including stopped ones
                $containers = docker ps -a --filter "name=^${ContainerName}$" `
                    --format '{{.ID}}' 2>$null

                return -not [string]::IsNullOrWhiteSpace($containers)

            } catch {

                return $false
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Tests if a Docker container is running.

        .DESCRIPTION
        Checks if a Docker container with the specified name is currently in a
        running state. Returns true only if the container is actively running.
        #>
        function Test-DockerContainerRunning {

            param([string]$ContainerName)

            try {

                # search for running containers with exact name match
                $containers = docker ps --filter "name=^${ContainerName}$" `
                    --format '{{.ID}}' 2>$null

                return -not [string]::IsNullOrWhiteSpace($containers)

            } catch {

                return $false
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Safely removes a Docker container.

        .DESCRIPTION
        Stops and removes a Docker container if it exists. Uses ShouldProcess
        to confirm the action before proceeding with container removal.
        #>
        function Remove-DockerContainer {

            [CmdletBinding(SupportsShouldProcess)]
            param([string]$ContainerName)

            try {

                # check if container exists before attempting removal
                if (Test-DockerContainer $ContainerName) {

                    if ($PSCmdlet.ShouldProcess($ContainerName,
                            'Stop and remove Docker container')) {

                        # output verbose information about container removal
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Stopping and removing container: $ContainerName"

                        # stop the container gracefully
                        $null = docker stop $ContainerName 2>$null

                        # remove the container completely
                        $null = docker rm $ContainerName 2>$null
                    }
                }

            } catch {

                # warn about container removal failures
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Failed to remove container ${ContainerName}: $_"
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Safely removes a Docker volume.

        .DESCRIPTION
        Removes a Docker volume by name using ShouldProcess to confirm the
        action before proceeding with volume deletion.
        #>
        function Remove-DockerVolume {

            [CmdletBinding(SupportsShouldProcess)]
            param([string]$VolumeName)

            try {

                if ($PSCmdlet.ShouldProcess($VolumeName,
                        'Remove Docker volume')) {

                    # output verbose information about volume removal
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Removing Docker volume: $VolumeName"

                    # remove the docker volume and discard output
                    $null = docker volume rm $VolumeName 2>$null
                }

            } catch {

                # warn about volume removal failures
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Failed to remove volume ${VolumeName}: $_"
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Tests if the DeepStack service is healthy by checking the API endpoint.

        .DESCRIPTION
        Performs a health check by making an HTTP request to the DeepStack
        service root endpoint. Returns true if the service responds successfully.
        #>
        function Test-ServiceHealth {

            try {

                # test the health endpoint with timeout to verify service responsiveness
                $null = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                    -Verbose:$false `
                    -ProgressAction Continue `
                    -Uri "$script:apiBaseUrl/" `
                    -TimeoutSec 10 `
                    -ErrorAction Stop

                # log successful health check for debugging
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'DeepStack service health check passed'

                return $true

            } catch {

                # log failed health check with error details for debugging
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "DeepStack service health check failed: $_"

                return $false
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Waits for the service to become healthy.

        .DESCRIPTION
        Continuously checks the DeepStack service health until it becomes ready
        or the timeout period expires. Uses configurable retry intervals.
        #>
        function Wait-ServiceReady {

            # output verbose information about waiting for service readiness
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Waiting for DeepStack service to become ready...'

            # initialize retry counter
            $retryCount = 0

            # calculate maximum retry attempts based on timeout and interval
            $maxRetries = [math]::Floor($script:healthCheckTimeout / `
                    $script:healthCheckInterval)

            while ($retryCount -lt $maxRetries) {

                # test service health and return success if ready
                if (Test-ServiceHealth) {

                    # log successful service readiness
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'DeepStack service is ready and responding'

                    return $true
                }

                # increment retry counter for next attempt
                $retryCount++

                # output verbose information about retry attempt
                Microsoft.PowerShell.Utility\Write-Verbose `
                ('Service not ready yet, attempt ' +
                    "$retryCount/$maxRetries...")

                # wait between health check attempts
                Microsoft.PowerShell.Utility\Start-Sleep `
                    -Seconds $script:healthCheckInterval
            }

            # warn about service readiness timeout
            Microsoft.PowerShell.Utility\Write-Verbose `
            ('DeepStack service did not become ready within ' +
                "$script:healthCheckTimeout seconds")

            return $false
        }

        ###################################################################
        <#
        .SYNOPSIS
        Pulls the latest DeepStack Docker image.

        .DESCRIPTION
        Downloads the specified DeepStack Docker image from the registry. Handles
        both standard and GPU-accelerated versions based on configuration.
        #>
        function Get-DeepStackImage {

            try {

                # output verbose information about docker image pull operation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Pulling DeepStack image: $script:imageName"

                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan `
                    "Pulling DeepStack image: $script:imageName"

                # pull the specified docker image
                $pullResult = docker pull $script:imageName 2>&1

                # check if docker pull command failed
                if ($LASTEXITCODE -ne 0) {

                    # check if the error is related to authentication
                    if ($pullResult -match 'authentication required' -or
                        $pullResult -match 'unauthorized' -or
                        $pullResult -match 'not logged in') {

                        Microsoft.PowerShell.Utility\Write-Verbose `
                        ('Docker pull failed due to authentication. ' +
                            'Please log in to Docker Desktop first. ' +
                            "Error: $pullResult")

                        # try to open docker desktop for user to log in
                        try {

                            $dockerDesktopPath = `
                                Microsoft.PowerShell.Core\Get-Command `
                                'Docker Desktop.exe' -ErrorAction SilentlyContinue

                            if ($dockerDesktopPath) {

                                Microsoft.PowerShell.Utility\Write-Host `
                                ('Opening Docker Desktop for ' +
                                    'authentication...') -ForegroundColor Yellow

                                Microsoft.PowerShell.Management\Start-Process `
                                    $dockerDesktopPath.Source -WindowStyle Normal
                            }

                        } catch {
                            # ignore errors opening docker desktop
                        }
                    }

                    throw "Failed to pull DeepStack image: $pullResult"
                }

                # log successful image pull
                Microsoft.PowerShell.Utility\Write-Verbose `
                    '✅ DeepStack image pulled successfully'

                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan `
                    '✅ DeepStack image pulled successfully'

                return $true

            } catch {

                # log error details for image pull failure
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to pull DeepStack image: $_"

                return $false
            }
        }

        ###################################################################
        <#
        .SYNOPSIS
        Creates and starts a new DeepStack container.

        .DESCRIPTION
        Creates a new Docker container with the DeepStack image, configures
        networking, volume mounts, and environment variables for face recognition.
        #>
        function New-DeepStackContainer {

            [CmdletBinding(SupportsShouldProcess)]
            param()

            try {

                # output verbose information about container creation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Creating DeepStack container...'

                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan `
                    "Creating DeepStack container: $script:containerName"

                # check if docker volume already exists
                $volumeExists = docker volume ls `
                    --filter "name=^$($script:volumeName)$" `
                    --format '{{.Name}}' 2>$null

                # create docker volume if it doesn't exist
                if ([string]::IsNullOrWhiteSpace($volumeExists)) {

                    # use shouldprocess to confirm volume creation
                    if ($PSCmdlet.ShouldProcess("$script:volumeName",
                            'Create Docker volume')) {

                        # output verbose information about volume creation
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Creating Docker volume: $script:volumeName"

                        # create the docker volume for persistent storage
                        $volumeResult = docker volume create $script:volumeName `
                            2>&1

                        # check if volume creation failed
                        if ($LASTEXITCODE -ne 0) {

                            throw ('Failed to create Docker volume ' +
                                "$script:volumeName`: $volumeResult")
                        }
                    }
                }

                # prepare docker run arguments for container creation
                $dockerArgs = @(
                    'run', '-d'
                    '--name', $script:containerName
                    '-p', "$($script:servicePort):5000"
                    '-v', "$($script:volumeName):/datastore"
                    '-e', 'VISION-FACE=True'
                    '-e', 'VISION-DETECTION=True'
                    '-e', 'VISION-SCENE=True'
                    '--restart', 'unless-stopped'
                )

                # add gpu support if requested
                if ($UseGPU) {

                    $dockerArgs += '--gpus', 'all'
                }

                # add the docker image name as final argument
                $dockerArgs += $script:imageName

                # output verbose information about docker command
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Docker command: docker $($dockerArgs -join ' ')"

                # use shouldprocess to confirm container creation
                if ($PSCmdlet.ShouldProcess("$script:containerName",
                        'Create DeepStack container')) {

                    # execute docker run command to create container
                    $result = & docker @dockerArgs 2>&1

                    # check if container creation failed
                    if ($LASTEXITCODE -ne 0) {

                        throw "Failed to create container: $result"
                    }
                }

                # wait for container to initialize properly
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5

                # log successful container creation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    '✅ DeepStack container created successfully'

                return $true

            } catch {

                # log error details for container creation failure
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to create DeepStack container: $_"

                return $false
            }
        }
        ###################################################################
    }

    process {

        try {

            # ensure docker desktop is available and running
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Ensuring Docker Desktop is available...'

            # Copy identical parameters between functions
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -FunctionName 'GenXdev.Windows\EnsureDockerDesktop' `
                -BoundParameters $PSBoundParameters `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            GenXdev.Windows\EnsureDockerDesktop @params

            # verify docker is responding to commands
            if (-not (Test-DockerAvailability)) {

                throw 'Docker is not available or not responding'
            }

            # handle force cleanup if requested by user
            if ($Force) {

                # output verbose information about forced cleanup
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Force flag specified - cleaning up existing resources...'

                # remove existing container and volume for clean slate
                Remove-DockerContainer $script:containerName

                Remove-DockerVolume $script:volumeName
            }

            # ensure we have the latest deepstack image available
            if (-not (Test-DockerImage $script:imageName) -or $Force) {

                # pull the docker image if not present or force specified
                if (-not (Get-DeepStackImage)) {

                    throw 'Failed to obtain DeepStack Docker image'
                }

            } else {

                # log that image is already available
                Microsoft.PowerShell.Utility\Write-Verbose `
                    '✅ DeepStack image already available'
            }

            # check current container state
            $containerExists = Test-DockerContainer $script:containerName

            $containerRunning = Test-DockerContainerRunning $script:containerName

            # handle existing container scenarios
            if ($containerExists) {

                # check if container is currently running
                if ($containerRunning) {

                    # verify container health for running container
                    if (Test-ServiceHealth) {

                        # log successful health check
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            '✅ DeepStack container is healthy and responding'

                    } else {

                        # restart unhealthy running container
                        Microsoft.PowerShell.Utility\Write-Verbose `
                        ('Container is running but not responding - ' +
                            'restarting...')

                        # restart the container to fix health issues
                        $null = docker restart $script:containerName 2>$null

                        # wait for container to restart properly
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 10

                        # wait for service to become ready after restart
                        $serviceReady = Wait-ServiceReady

                        # warn if service is not ready after restart
                        if (-not $serviceReady) {

                            Microsoft.PowerShell.Utility\Write-Verbose `
                            ('DeepStack service may not be fully ready ' +
                                'after restart')
                        }
                    }

                } else {

                    # start existing stopped container
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'Starting existing container...'

                    # start the stopped container
                    $null = docker start $script:containerName 2>$null

                    # wait for container to start properly
                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds 10

                    # wait for service to become ready after start
                    $serviceReady = Wait-ServiceReady

                    # log or warn about service readiness after start
                    if ($serviceReady) {

                        Microsoft.PowerShell.Utility\Write-Verbose `
                        ('✅ DeepStack service is ready after ' +
                            'container start')

                    } else {

                        Microsoft.PowerShell.Utility\Write-Verbose `
                        ('DeepStack service may not be fully ready ' +
                            'after start')
                    }
                }

            } else {

                # create and start new container when none exists
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Creating and starting DeepStack container...'

                # attempt to create new deepstack container
                if (-not (New-DeepStackContainer)) {

                    throw 'Failed to create DeepStack container'
                }

                # wait for service to be ready after creation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Waiting for DeepStack service to be ready...'

                $serviceReady = Wait-ServiceReady

                # log or warn about service readiness after creation
                if ($serviceReady) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "✅ DeepStack service is ready at $script:apiBaseUrl"

                } else {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                    ('DeepStack service may not be fully ready ' +
                        'after creation')
                }
            }

            # perform final validation of service state
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Performing final validation...'

            # check if container is running and service is healthy
            if ((Test-DockerContainerRunning $script:containerName) -and `
                (Test-ServiceHealth)) {

                # log successful service operation
                Microsoft.PowerShell.Utility\Write-Verbose `
                ('✅ DeepStack face recognition service is fully ' +
                    "operational at $script:apiBaseUrl")

                return $true

            } else {

                # warn about potential service issues
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'DeepStack service may not be fully operational'

                return $false
            }

        } catch {

            # log error details for any failures
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to ensure DeepStack service: $_"

            throw
        }
    }

    end {

        # restore original location for cleanup
        Microsoft.PowerShell.Management\Set-Location $script:originalLocation
    }
}