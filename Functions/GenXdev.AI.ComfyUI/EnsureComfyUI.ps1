<##############################################################################
Part of PowerShell module : GenXdev.AI.ComfyUI
Original cmdlet filename  : EnsureComfyUI.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.298.2025
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
################################################################################
<#
.SYNOPSIS
Ensures ComfyUI is installed and running with optional window positioning.

.DESCRIPTION
This function verifies that ComfyUI is installed on the system and ensures it's
running with a responsive server. If ComfyUI is not installed, it attempts to
install it using winget. The function provides comprehensive window positioning
options and waits for the ComfyUI server to become available before returning.

The function handles ComfyUI installation, process management, server readiness
verification, and window positioning in a single operation.

.PARAMETER Monitor
The monitor to use for window positioning. 0 = default monitor, -1 = discard
positioning, -2 = auto-detect best monitor.

.PARAMETER NoBorders
Removes the window borders for a borderless display mode.

.PARAMETER Width
The initial width of the ComfyUI window in pixels.

.PARAMETER Height
The initial height of the ComfyUI window in pixels.

.PARAMETER X
The initial X coordinate position of the window.

.PARAMETER Y
The initial Y coordinate position of the window.

.PARAMETER Left
Place the window on the left side of the screen.

.PARAMETER Right
Place the window on the right side of the screen.

.PARAMETER Top
Place the window on the top side of the screen.

.PARAMETER Bottom
Place the window on the bottom side of the screen.

.PARAMETER Centered
Place the window in the center of the screen.

.PARAMETER FullScreen
Sends F11 to the window to enable fullscreen mode.

.PARAMETER RestoreFocus
Restore PowerShell window focus after ComfyUI operations.

.PARAMETER SideBySide
Position the window in side-by-side mode with other applications.

.PARAMETER FocusWindow
Focus the ComfyUI window after opening and positioning.

.PARAMETER SetForeground
Set the ComfyUI window to foreground after opening.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER KeysToSend
Array of keys to send to the ComfyUI window after it's ready.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay in milliseconds between key send operations.

.PARAMETER ShowWindow
Show the ComfyUI window during initialization process.

.PARAMETER Force
Force stop any existing ComfyUI process before starting a new one.

.PARAMETER Timeout
Timeout in seconds to wait for ComfyUI server to become responsive.

.EXAMPLE
EnsureComfyUI
Ensures ComfyUI is running with default settings.

.EXAMPLE
EnsureComfyUI -Monitor 1 -Centered -Width 1200 -Height 800
Ensures ComfyUI is running on monitor 1, centered with specific dimensions.

.EXAMPLE
EnsureComfyUI -Force -ShowWindow -Timeout 120
Force restarts ComfyUI, shows the window, and waits up to 2 minutes for server.

.NOTES
This function requires winget to be available for automatic ComfyUI installation.
The function polls ComfyUI server ports 8000 and 8188 to verify readiness.
Window positioning parameters are passed through to Set-WindowPosition.
#>
function EnsureComfyUI {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height,
        ###############################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X,
        ###############################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y,
        ###############################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = 'Array of keys to send to the ComfyUI window after ready'
        )]
        [string[]] $KeysToSend,
        ###############################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between key send operations'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Timeout in seconds to wait for ComfyUI server readiness'
        )]
        [int] $Timeout = 600,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Position windows side by side'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore the window to normal state after positioning'
        )]
        [switch] $SetRestored,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the ComfyUI window during initialization process'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop any existing ComfyUI process before starting'
        )]
        [switch] $Force
    )

    begin {

        # copy window positioning parameters for later use
        $showWindowParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.Windows\Set-WindowPosition' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

        # set default restore focus behavior if not explicitly provided
        $showWindowParams.RestoreFocus = ($PSBoundParameters.ContainsKey("RestoreFocus") ? `
            $RestoreFocus : $true)

        # initialize tracking variables for installation and server state
        $serverReady = $false

        # check for currently running comfyui processes
        $comfyProcesses = Microsoft.PowerShell.Management\Get-Process `
            -Name 'comfyui' `
            -ErrorAction SilentlyContinue

        # determine if comfyui is currently running
        $comfyRunning = $null -ne $comfyProcesses
        $wasAlreadyRunning = $comfyRunning

        # log current comfyui running status
        Microsoft.PowerShell.Utility\Write-Verbose `
            ("ComfyUI is $(if ($comfyRunning) { 'already ' } else { 'not ' })" +
             "running.")

        # force shutdown existing processes if requested
        if ($Force -and $comfyRunning) {

            # stop all running comfyui instances
            GenXdev.AI\Stop-ComfyUI

            # mark as not previously running since we stopped it
            $wasAlreadyRunning = $false
        }

        # start comfyui if not running or force restart was requested
        if (-not $comfyRunning -or $Force) {

            # check if comfyui is installed via winget package manager
            $installedOutput = & winget list --id Comfy.ComfyUI-Desktop `
                --exact --source winget 2>$null

            # determine installation status from winget output
            $comfyInstalled = -not ($installedOutput -match `
                'No installed package found matching input criteria.')

            # install comfyui if not currently installed
            if (-not $comfyInstalled) {

                # request user consent before installing third-party software
                $installConsent = GenXdev.FileSystem\Confirm-InstallationConsent `
                    -ApplicationName "ComfyUI Desktop" `
                    -Source "Winget" `
                    -Description "ComfyUI is required for AI image generation workflows. This desktop application provides a graphical interface for creating and managing ComfyUI workflows." `
                    -Publisher "Comfy Org"

                # handle installation consent response
                if (-not $installConsent) {
                    Microsoft.PowerShell.Utility\Write-Error `
                        "Installation consent denied. ComfyUI Desktop is required for this operation to continue."
                    return
                }

                # install comfyui desktop application via winget
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Installing ComfyUI via winget..."

                # execute winget install with user scope and automatic agreements
                $null = & winget install --id Comfy.ComfyUI-Desktop --exact `
                    --scope user --accept-package-agreements `
                    --accept-source-agreements

                # allow time for installation to complete and files to settle
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5

                # configure initial settings for newly installed comfyui
                try {
                    # log configuration attempt
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        ("Configuring initial ComfyUI settings for new " +
                         "installation...")

                    # get comfyui base path and construct settings file path
                    $comfyPath = GenXdev.AI\Get-ComfyUIModelPath -Verbose:$false
                    $settingsPath = Microsoft.PowerShell.Management\Join-Path `
                        $comfyPath "user\default\comfy.settings.json"

                    # ensure settings directory exists before creating file
                    $settingsDir = [System.IO.Path]::GetDirectoryName($settingsPath)

                    if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $settingsDir)) {

                        # create settings directory structure
                        $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $settingsDir `
                            -Force
                    }

                    # create initial settings configuration object
                    $initialSettings = @{
                        "Comfy.DevMode" = $true
                        "Comfy.ModelLibrary.AutoLoadAll" = $true
                    }

                    # write initial settings to configuration file
                    $initialSettings | `
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 | `
                        Microsoft.PowerShell.Management\Set-Content $settingsPath -Encoding UTF8

                    # log successful settings creation
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Created initial settings file with DevMode and AutoLoadAll"

                    # set background image for comfyui interface
                    $backgroundImagePath = GenXdev.FileSystem\Expand-Path `
                        "$PSScriptRoot\..\..\GenXdev.AI.png"

                    # configure background image if available
                    if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $backgroundImagePath) {

                        # ensure backgrounds directory exists
                        $backgroundsDir = Microsoft.PowerShell.Management\Join-Path `
                            $comfyPath "input\backgrounds"

                        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $backgroundsDir)) {

                            # create backgrounds directory
                            $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory `
                                -Path $backgroundsDir -Force
                        }

                        # copy background image to comfyui input directory
                        $imageFileName = [System.IO.Path]::GetFileName($backgroundImagePath)
                        $destinationPath = Microsoft.PowerShell.Management\Join-Path `
                            $backgroundsDir $imageFileName

                        Microsoft.PowerShell.Management\Copy-Item -Path $backgroundImagePath `
                            -Destination $destinationPath -Force

                        # add background setting to configuration
                        $encodedFileName = [System.Web.HttpUtility]::UrlEncode(`
                            "backgrounds/$imageFileName")
                        $backgroundUrl = ("/api/view?filename=$encodedFileName" +
                            "&type=input&subfolder=backgrounds")
                        $initialSettings["Comfy.Canvas.BackgroundImage"] = $backgroundUrl

                        # update settings file with background configuration
                        $initialSettings | `
                            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 | `
                            Microsoft.PowerShell.Management\Set-Content $settingsPath -Encoding UTF8

                        # log background image configuration success
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Set GenXdev.AI background image"
                    } else {

                        # log missing background image
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Background image not found at: $backgroundImagePath"
                    }
                }
                catch {
                    # log configuration failure without stopping execution
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Failed to configure initial ComfyUI settings: $_"
                }
            }

            # construct the correct comfyui executable path
            # comfyui.exe is located directly in the @comfyorgcomfyui-electron folder
            $localAppData = $env:LOCALAPPDATA
            $comfyAppDir = Microsoft.PowerShell.Management\Join-Path `
                $localAppData "Programs\@comfyorgcomfyui-electron"
            $exePath = Microsoft.PowerShell.Management\Join-Path `
                $comfyAppDir "ComfyUI.exe"

            # log the executable path being used
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Starting ComfyUI executable at: $exePath"

            # create temporary file for process output redirection
            $tmpFile = [IO.Path]::GetTempFileName();

            # start comfyui process with minimized window
            $null = Microsoft.PowerShell.Management\Start-Process `
                -FilePath $exePath `
                -WindowStyle Minimized `
                -UseNewEnvironment `
                -RedirectStandardOutput $tmpFile

            # allow initial startup time for process to initialize
            Microsoft.PowerShell.Utility\Start-Sleep 4

            # wait for comfyui window to become available
            $i = 0;
            while (($i -lt 20) -and -not (Microsoft.PowerShell.Management\Get-Process `
                -ProcessName 'ComfyUI' `
                -ErrorAction SilentlyContinue | Microsoft.PowerShell.Core\Where-Object {
                    $_.MainWindowHandle -gt 0
                })) {

                # update progress while waiting for window handle
                Microsoft.PowerShell.Utility\Write-Progress `
                    -Activity "Waiting for ComfyUI window" `
                    -Status "Checking for window handle..." `
                    -PercentComplete (($i / 20) * 100)

                # wait before next check
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 1
                $i++
            }

            # complete window waiting progress
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Waiting for ComfyUI window" `
                -Status "Checking for window handle..." `
                -PercentComplete 100 `
                -Completed

            # apply window positioning based on startup conditions
            if ((-not $wasAlreadyRunning) -or $ShowWindow) {

                if ($ShowWindow) {

                    # apply positioning immediately when showing window
                    GenXdev.Windows\Set-WindowPosition @showWindowParams `
                        -ProcessName 'ComfyUI' -ErrorAction SilentlyContinue
                }
                else {

                    # apply positioning with minimize when not showing window
                    GenXdev.Windows\Set-WindowPosition @showWindowParams `
                        -Minimize -ProcessName 'ComfyUI' `
                        -ErrorAction SilentlyContinue
                }
            }
        }
    }

    process {

        # define comfyui server ports to check for readiness
        $ports = 8188, 8000

        # initialize stopwatch for timeout tracking during server polling
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()

        # display initial progress indicator for server availability check
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "ComfyUI Initialization" `
            -Status ("Waiting for ComfyUI server to become available " +
                     "(timeout: ${Timeout}s)")

        # poll comfyui server endpoints until ready or timeout reached
        # this loop continuously checks server responsiveness on known ports
        while ($stopwatch.Elapsed.TotalSeconds -lt $Timeout) {

            # test each known comfyui port for server availability
            foreach ($port in $ports) {

                try {
                    # test server availability using the /queue endpoint
                    # this endpoint is reliable for determining if comfyui api is ready
                    # to accept workflow submissions and process requests
                    $testUrl = "http://127.0.0.1:${port}/queue"

                    # attempt connection to comfyui api endpoint
                    $response = Microsoft.PowerShell.Utility\Invoke-WebRequest `
                        -Uri $testUrl `
                        -Method Get `
                        -TimeoutSec 1 `
                        -ErrorAction Stop

                    # check for successful http response indicating server readiness
                    if ($response.StatusCode -eq 200) {

                        # server is ready - complete progress indicator and log success
                        Microsoft.PowerShell.Utility\Write-Progress `
                            -Activity "ComfyUI Initialization" `
                            -Completed

                        # log successful server connection
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "ComfyUI server is ready on port ${port}."

                        # store the working api url for later use
                        $script:comfyUIApiUrl = "http://127.0.0.1:${port}"

                        # mark server as ready and exit polling
                        $serverReady = $true
                        break
                    }
                }
                catch {
                    # ignore connection failures and continue polling
                    # server may not be ready yet, this is expected during startup
                }
            }

            # exit polling loop if server responded successfully
            if ($serverReady) { break }

            # update progress bar with current status and remaining time
            # calculate completion percentage based on elapsed time vs timeout
            $elapsed = [int]$stopwatch.Elapsed.TotalSeconds
            $percent = [Math]::Min(100, ($elapsed / $Timeout) * 100)

            # display current polling status with time remaining
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "ComfyUI Initialization" `
                -Status "Waiting for server to respond..." `
                -PercentComplete $percent `
                -SecondsRemaining ($Timeout - $elapsed)

            # wait before next polling attempt to avoid overwhelming the server
            # 2-second intervals provide responsive feedback without excessive requests
            Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2
        }

        # clean up progress tracking and stopwatch resources
        $stopwatch.Stop()

        # handle timeout scenario - server failed to become ready within time limit
        if (-not $serverReady) {

            # complete progress indicator and report timeout error
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "ComfyUI Initialization" `
                -Completed

            # report timeout error to user with troubleshooting guidance
            Microsoft.PowerShell.Utility\Write-Error `
                ("ComfyUI server did not become available within the " +
                 "${Timeout}-second timeout. Please check the ComfyUI logs " +
                 "for errors.")
            return
        }
    }

    end {

        # apply window positioning only under specific conditions:
        # 1. comfyui was newly started (not already running), or
        # 2. comfyui was already running and showwindow parameter is set
        if ((-not $wasAlreadyRunning) -or $ShowWindow) {

            if ($ShowWindow) {

                # apply positioning immediately when showing window explicitly
                GenXdev.Windows\Set-WindowPosition @showWindowParams `
                    -ProcessName 'ComfyUI' -ErrorAction SilentlyContinue -RestoreFocus
            }
            else {

                # apply positioning with minimize when not explicitly showing window
                GenXdev.Windows\Set-WindowPosition @showWindowParams `
                    -Minimize -ProcessName 'ComfyUI' -ErrorAction SilentlyContinue -RestoreFocus
            }
        }
    }
}
################################################################################