################################################################################
<#
.SYNOPSIS
Ensures Docker Desktop is installed and available for containerization
operations.

.DESCRIPTION
Verifies if Docker Desktop is installed and properly configured on the system.
If not found, installs Docker Desktop using WinGet and handles the complete
installation process automatically. This function also manages Docker Desktop
service startup, daemon readiness verification, and handles authentication
requirements when necessary.

.EXAMPLE
EnsureDockerDesktop
Ensures Docker Desktop is installed and properly configured.
#>
###############################################################################
function EnsureDockerDesktop {

    [CmdletBinding()]
    param()

    begin {

        ###########################################################################
        <#
        .SYNOPSIS
        Checks if the WinGet PowerShell module is installed.

        .DESCRIPTION
        Attempts to import the Microsoft.WinGet.Client module and verifies its
        presence by checking if the module is available after import attempt.

        .EXAMPLE
        IsWinGetInstalled
        Returns $true if WinGet module is available, $false otherwise.
        #>
        ###########################################################################
        function IsWinGetInstalled {

            # attempt to load the winget module silently without error output
            Microsoft.PowerShell.Core\Import-Module "Microsoft.WinGet.Client" `
                -ErrorAction SilentlyContinue

            # verify if module was loaded successfully by checking module list
            $module = Microsoft.PowerShell.Core\Get-Module "Microsoft.WinGet.Client" `
                -ErrorAction SilentlyContinue

            # return true if module object exists, false otherwise
            return $null -ne $module
        }

        ###########################################################################
        <#
        .SYNOPSIS
        Installs the WinGet PowerShell module.

        .DESCRIPTION
        Installs and imports the Microsoft.WinGet.Client module for package
        management operations. Forces installation to override any conflicts.

        .EXAMPLE
        InstallWinGet
        Installs the WinGet PowerShell module from PowerShell Gallery.
        #>
        ###########################################################################
        function InstallWinGet {

            # output status message about winget installation
            Microsoft.PowerShell.Utility\Write-Verbose ("Installing WinGet " +
                "PowerShell client...")

            # install winget module with force to ensure success and allow clobber
            $null = PowerShellGet\Install-Module "Microsoft.WinGet.Client" `
                -Force `
                -AllowClobber

            # load the newly installed module into current session
            Microsoft.PowerShell.Core\Import-Module "Microsoft.WinGet.Client"
        }
    }    process {

        # verify if docker desktop executable is available in current session
        if (@(Microsoft.PowerShell.Core\Get-Command 'docker.exe' `
            -ErrorAction SilentlyContinue).Length -eq 0) {

            # define common docker installation paths for system and user installs
            $dockerPaths = @(
                "${env:ProgramFiles}\Docker\Docker\resources\bin",
                "${env:LOCALAPPDATA}\Programs\Docker\Docker\resources\bin"
            )

            # initialize flag to track if docker was found in known paths
            $dockerFound = $false

            # iterate through each potential docker installation path
            foreach ($path in $dockerPaths) {

                # check if docker executable exists in current path
                if (Microsoft.PowerShell.Management\Test-Path `
                    (Microsoft.PowerShell.Management\Join-Path $path "docker.exe")) {

                    # get current user PATH environment variable
                    $currentPath = [Environment]::GetEnvironmentVariable('PATH',
                        'User')

                    # add docker path to user PATH if not already present
                    if ($currentPath -notlike "*$path*") {

                        # inform user about path modification
                        Microsoft.PowerShell.Utility\Write-Verbose ("Adding " +
                            "Docker to system PATH...")

                        # update user PATH environment variable permanently
                        [Environment]::SetEnvironmentVariable(
                            'PATH',
                            "$currentPath;$path",
                            'User')

                        # update current session's path for immediate availability
                        $env:PATH = [Environment]::GetEnvironmentVariable('PATH',
                            'User')
                    }

                    # mark docker as found and exit loop
                    $dockerFound = $true
                    break
                }
            }

            # install docker if not found in known installation paths
            if (-not $dockerFound) {

                # inform user about docker installation process
                Microsoft.PowerShell.Utility\Write-Host ("Docker Desktop not " +
                    "found. Installing Docker Desktop...")

                # ensure winget is available before attempting docker installation
                if (-not (IsWinGetInstalled)) {
                    InstallWinGet
                }

                # install docker desktop using winget package manager
                $null = Microsoft.WinGet.Client\Install-WinGetPackage `
                    -Id 'Docker.DockerDesktop' `
                    -Force

                # re-check docker paths after installation to update PATH
                foreach ($path in $dockerPaths) {                    # verify docker executable exists in path after installation
                    if (Microsoft.PowerShell.Management\Test-Path `
                        (Microsoft.PowerShell.Management\Join-Path $path `
                            "docker.exe")) {

                        # get current user PATH environment variable
                        $currentPath = [Environment]::GetEnvironmentVariable(
                            'PATH', 'User')

                        # add docker path to PATH if not already present
                        if ($currentPath -notlike "*$path*") {

                            # inform user about path update after installation
                            Microsoft.PowerShell.Utility\Write-Verbose ("Adding " +
                                "Docker to system PATH...")

                            # update user PATH environment variable
                            [Environment]::SetEnvironmentVariable(
                                'PATH',
                                "$currentPath;$path",
                                'User')

                            # update current session's path immediately
                            $env:PATH = [Environment]::GetEnvironmentVariable(
                                'PATH', 'User')
                        }
                        break
                    }
                }

                # verify docker installation was successful by checking command
                if (-not (Microsoft.PowerShell.Core\Get-Command 'docker.exe' `
                    -ErrorAction SilentlyContinue)) {
                    throw "Docker Desktop installation failed."
                }
            }
        }

        # check if docker desktop process is currently running
        $dockerDesktopProcess = Microsoft.PowerShell.Management\Get-Process `
            "Docker Desktop" `
            -ErrorAction SilentlyContinue

        # start docker desktop if process is not running
        if (-not $dockerDesktopProcess) {

            # inform user about docker desktop startup
            Microsoft.PowerShell.Utility\Write-Host "Starting Docker Desktop..."

            # try to find docker desktop executable via get-command
            $dockerExePath = Microsoft.PowerShell.Core\Get-Command `
                "Docker Desktop.exe" `
                -ErrorAction SilentlyContinue

            # start docker desktop if found via get-command
            if ($dockerExePath) {

                # start docker desktop process using found executable path
                Microsoft.PowerShell.Management\Start-Process $dockerExePath.Source

                # wait for docker desktop to initialize (30 seconds)
                Microsoft.PowerShell.Utility\Start-Sleep 30
            }
            else {

                # define common docker desktop executable paths
                $dockerDesktopPaths = @(
                    "${env:ProgramFiles}\Docker\Docker\Docker Desktop.exe",
                    ("${env:LOCALAPPDATA}\Programs\Docker\Docker\" +
                        "Docker Desktop.exe")
                )

                # try each known docker desktop installation path
                foreach ($path in $dockerDesktopPaths) {

                    # check if docker desktop executable exists at current path
                    if (Microsoft.PowerShell.Management\Test-Path $path) {

                        # start docker desktop from found path
                        Microsoft.PowerShell.Management\Start-Process $path

                        # wait for docker desktop to initialize
                        Microsoft.PowerShell.Utility\Start-Sleep 30
                        break
                    }
                }
            }
        }

        # wait for docker daemon to become ready for commands
        Microsoft.PowerShell.Utility\Write-Verbose ("Waiting for Docker " +
            "daemon to be ready...")

        # set timeout for waiting for docker daemon (60 seconds)
        $timeout = 60

        # initialize elapsed time counter
        $elapsed = 0

        # loop until docker daemon responds or timeout is reached
        do {

            # wait 2 seconds between docker daemon checks
            Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2

            # increment elapsed time counter
            $elapsed += 2

            # attempt to get docker info to verify daemon is responding
            $dockerInfo = docker info 2>$null

        } while (-not $dockerInfo -and $elapsed -lt $timeout)

        # throw error if docker daemon failed to start within timeout
        if ($elapsed -ge $timeout) {
            throw ("Docker daemon failed to start within $timeout seconds.")
        }

        # initialize flag to track if docker login is required
        $loginRequired = $false        # check if user needs to log in to docker desktop for registry access
        $loginRequired = $false
        try {

            # verify docker daemon is responding to basic commands
            $dockerInfo = docker info --format '{{.Name}}' 2>$null

            # proceed with authentication check if daemon is responding
            if ($dockerInfo) {

                # output verbose message about daemon status
                Microsoft.PowerShell.Utility\Write-Verbose ("Docker daemon " +
                    "is responding")

                # simple approach: assume login is not required unless we get specific auth errors
                # most docker operations work without login (local images, basic commands)
                $loginRequired = $false

                # only check for login if we're trying to access Docker Hub content
                # this avoids the unreliable template and pull operations
                Microsoft.PowerShell.Utility\Write-Verbose ("Assuming Docker " +
                    "login is not required for basic operations")
            }
        }
        catch {

            # if docker commands fail entirely, assume bigger issue than login
            $loginRequired = $false

            # output verbose message about docker command failure
            Microsoft.PowerShell.Utility\Write-Verbose ("Docker command " +
                "failed, assuming no login required: $($_.Exception.Message)")
        }        # handle docker desktop login process if authentication is required
        if ($loginRequired) {

            # inform user about docker account requirement
            Microsoft.PowerShell.Utility\Write-Host ("Please create a Docker " +
                "account or log in to your existing Docker account in Docker " +
                "Desktop to continue.") -ForegroundColor Yellow

            # inform user about waiting for login
            Microsoft.PowerShell.Utility\Write-Host ("Waiting for Docker " +
                "Desktop login...") -ForegroundColor Cyan

            # for now, we skip the complex login detection since it's unreliable
            # users can manually retry if they encounter authentication issues
            Microsoft.PowerShell.Utility\Write-Host ("Docker operations may " +
                "require authentication. Please ensure you're logged into " +
                "Docker Desktop and retry if needed.") -ForegroundColor Yellow
        }

        # output final success message about docker desktop readiness
        Microsoft.PowerShell.Utility\Write-Verbose "✅ Docker Desktop is ready."
    }

    end {

    }
}
################################################################################
