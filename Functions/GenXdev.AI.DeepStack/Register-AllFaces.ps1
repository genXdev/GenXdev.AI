<##############################################################################
Part of PowerShell module : GenXdev.AI.DeepStack
Original cmdlet filename  : Register-AllFaces.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.292.2025
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
Updates all face recognition profiles from image files in the faces directory.

.DESCRIPTION
This function updates the face recognition database with all images found in
the specified faces directory. The process involves:
1. Ensuring the face recognition service is running
2. Processing all images in each person's folder, registering all faces for
   that person with a single identifier (the folder name) in a batch operation
3. Supporting retry logic for failed registrations

Each person's folder can contain multiple images, and all images will be
registered under the same identifier (person name) in a single API call,
eliminating the need for _1, _2, etc. suffixes.

.PARAMETER FacesDirectory
The directory containing face images organized by person folders.
If not specified, uses the configured faces directory from Set-AIKnownFacesRootpath.
If no configuration exists, defaults to "b:\media\faces\"

.PARAMETER MaxRetries
Maximum number of retry attempts for failed registrations.
Default: 3

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

.PARAMETER NoDockerInitialize
Skip Docker Desktop initialization (used when already called by parent
function).

.PARAMETER Force
If specified, forces re-registration of all faces.

.PARAMETER RenameFailed
If specified, renames image files that fail with "400 Bad Request - Could not
find any face" by adding a ".failed" extension to the filename.

.PARAMETER ForceRebuild
Force rebuild of Docker container and remove existing data.

.PARAMETER UseGPU
Use GPU-accelerated version (requires NVIDIA GPU).

.EXAMPLE
Register-AllFaces -FacesDirectory "b:\media\faces\" -MaxRetries 3 `
    -ContainerName "deepstack_face_recognition" -VolumeName "deepstack_face_data" `
    -ServicePort 5000 -HealthCheckTimeout 60 -HealthCheckInterval 3

.EXAMPLE
Register-AllFaces
Uses the configured faces directory from Set-AIKnownFacesRootpath or defaults to "b:\media\faces\"

.EXAMPLE
updatefaces -RenameFailed
###############################################################################>
function Register-AllFaces {

    [CmdletBinding()]
    [Alias('UpdateFaces')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        #######################################################################
        [parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized by ' +
                'person folders. If not specified, uses the ' +
                'configured faces directory preference.')
        )]
        [string] $FacesDirectory,
        #######################################################################
        [parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Maximum number of retry attempts for failed registrations'
        )]
        [int] $MaxRetries = 3,
        #######################################################################
        [parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        #######################################################################
        [parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker volume for persistent storage'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        #######################################################################
        [parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'Interval in seconds between health check attempts'
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,

        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker Desktop initialization (used when ' +
                'already called by parent function)')
        )]
        [switch] $NoDockerInitialize,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Force re-registration of all faces'
        )]
        [switch] $Force,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Rename failed image files that could not be ' +
                'processed due to no face found')
        )]
        [switch] $RenameFailed,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuild of Docker container and remove existing data'
        )]
        [switch] $ForceRebuild,
        #######################################################################
        [parameter(
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
        [switch]$ShowWindow,
        ###############################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'If specified, only use the session (do not persist changes to preferences database).')]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'If specified, clear the current session preferences before use.')]
        [switch] $ClearSession,
        ###############################################################################
        ###############################################################################
        [Alias('DatabasePath')]
        [Parameter(Mandatory = $false, HelpMessage = 'Path to the preferences database to use for known faces root path.')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        ###############################################################################
        [Alias('FromPreferences')]
        [Parameter(Mandatory = $false, HelpMessage = 'If specified, skip session logic when retrieving known faces root path.')]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIKnownFacesRootpath' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)
        $FacesDirectory = GenXdev.AI\Get-AIKnownFacesRootpath @params

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using provided faces directory: $FacesDirectory"

        # initialize script-level tracking variables for registration results
        $script:RegistrationErrors = @()
        $script:SuccessfulRegistrations = 0
        $script:SkippedRegistrations = 0

        # validate that the faces directory exists before proceeding
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $FacesDirectory `
                    -PathType Container)) {

            throw "Faces directory does not exist: $FacesDirectory"
        }

        # output verbose information about the faces directory being processed
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Processing faces from directory: $FacesDirectory"

        #######################################################################
        <#
        .SYNOPSIS
        Ensures the face recognition service is properly initialized.

        .DESCRIPTION
        This nested function handles the initialization of the DeepStack face
        recognition service with retry logic and proper error handling.

        .PARAMETER None
        Uses parent function parameters through scope inheritance.
        #>
        #######################################################################

        function Initialize-FaceRecognitionService {

            # set maximum initialization attempts and current attempt counter
            $maxAttempts = 3
            $attempt = 1

            # retry loop for service initialization
            while ($attempt -le $maxAttempts) {

                try {

                    # output verbose information about current initialization attempt
                    Microsoft.PowerShell.Utility\Write-Verbose `
                    ("Attempt $attempt to initialize DeepStack face " +
                        'recognition service')

                    # copy parameters for the EnsureDeepStack function call
                    $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local `
                            -ErrorAction SilentlyContinue)

                    # configure force rebuild parameter based on ForceRebuild switch
                    if ($ForceRebuild) {

                        $ensureParams.Force = $true
                    }
                    else {

                        $ensureParams.Force = if ($PSBoundParameters.ContainsKey(
                                'ForceRebuild')) {
                            $false
                        }
                        else {
                            $null
                        }
                    }

                    # ensure deepstack service is running
                    $null = GenXdev.AI\EnsureDeepStack @ensureParams

                    # verify service is responding by performing health check
                    $null = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                        -Verbose:$false `
                        -ProgressAction Continue `
                        -Uri "http://127.0.0.1:$ServicePort/" `
                        -TimeoutSec 10 `
                        -ErrorAction Stop

                    # output success message for service initialization
                    Microsoft.PowerShell.Utility\Write-Verbose `
                    ('DeepStack face recognition service initialized ' +
                        'successfully')

                    return $true
                }
                catch {

                    # output warning about failed initialization attempt
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Attempt $attempt failed: $_"

                    # wait before retry if not the last attempt
                    if ($attempt -lt $maxAttempts) {

                        # output verbose information about retry delay
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            'Waiting 30 seconds before retry...'

                        # pause before next attempt
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 30
                    }

                    # increment attempt counter
                    $attempt++
                }
            }

            # throw error if all attempts failed
            throw ('Failed to initialize DeepStack face recognition service ' +
                "after $maxAttempts attempts")
        }

        #######################################################################
        <#
        .SYNOPSIS
        Registers a single face with retry logic.

        .DESCRIPTION
        This nested function handles the registration of face images for a
        specific person with retry logic and error handling including support
        for renaming failed image files.

        .PARAMETER Identifier
        The name identifier for the person to register.

        .PARAMETER ImagePaths
        Array of image file paths to register for this person.

        .PARAMETER MaxRetries
        Maximum number of retry attempts for failed registrations.
        #>
        #######################################################################
        function Register-FaceWithRetry {

            param(
                [string] $Identifier,
                [string[]] $ImagePaths,
                [int] $MaxRetries
            )

            # initialize attempt counter
            $attempt = 1

            # retry loop for face registration
            while ($attempt -le $MaxRetries) {

                try {

                    # output verbose information about registration attempt
                    Microsoft.PowerShell.Utility\Write-Verbose `
                    ("Registering face: $Identifier with " +
                        "$($ImagePaths.Count) image(s) (attempt $attempt)")

                    # copy parameters for the Register-Face function call
                    $registerParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev.AI\Register-Face' `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local `
                            -ErrorAction SilentlyContinue)

                    # override ImagePath parameter with array of paths
                    $registerParams.ImagePath = $ImagePaths
                    $registerParams.Identifier = $Identifier

                    # register the face using the deepstack service
                    $null = GenXdev.AI\Register-Face @registerParams `
                        -NoDockerInitialize -ErrorAction Stop

                    # add delay between successful registrations to prevent service overload
                    Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500

                    return $true
                }
                catch {

                    # capture error message for analysis
                    $errorMessage = $_.Exception.Message

                    # output warning about failed registration attempt
                    Microsoft.PowerShell.Utility\Write-Verbose `
                    ("Registration attempt $attempt failed for " +
                        "$Identifier`: $errorMessage")

                    # check if this is a "no face found" error and handle accordingly
                    if ($RenameFailed -and ($errorMessage -like '*400*' -and
                            $errorMessage -like '*Bad Request*' -and
                            $errorMessage -like '*Could not find any face*')) {

                        # output verbose information about detected no face error
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Detected 'no face found' error for $Identifier"

                        try {

                            # rename all failed image files
                            foreach ($imagePath in $ImagePaths) {

                                # create new filename with failed extension
                                $newPath = "$imagePath.failed"

                                # rename the failed image file
                                Microsoft.PowerShell.Management\Rename-Item `
                                    -LiteralPath $imagePath `
                                    -NewName $newPath `
                                    -ErrorAction Stop

                                # output information about renamed file
                                Microsoft.PowerShell.Utility\Write-Output `
                                ("Renamed failed image: $imagePath -> " +
                                    "$newPath")
                            }

                            # add error to tracking collection
                            $script:RegistrationErrors += @{
                                Identifier = $Identifier
                                ImagePaths = $ImagePaths
                                Error      = ('No face found - files renamed to ' +
                                    '.failed')
                            }

                            return $false
                        }
                        catch {

                            # output warning if file rename failed
                            Microsoft.PowerShell.Utility\Write-Verbose `
                                "Failed to rename files for $Identifier`: $_"
                        }
                    }

                    # wait before retry if not the last attempt
                    if ($attempt -lt $MaxRetries) {

                        # calculate retry delay with exponential backoff
                        $retryDelay = 3 + ($attempt * 2)  # 5, 7 seconds

                        # output verbose information about retry delay
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Waiting $retryDelay seconds before retry..."

                        # pause before next attempt
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds $retryDelay
                    }

                    # increment attempt counter
                    $attempt++
                }
            }

            # add final error to tracking collection after all retries failed
            $script:RegistrationErrors += @{
                Identifier = $Identifier
                ImagePaths = $ImagePaths
                Error      = "Failed after $MaxRetries attempts"
            }

            return $false
        }

        #######################################################################
        <#
        .SYNOPSIS
        Processes images in a person's directory.

        .DESCRIPTION
        This nested function processes all valid image files in a person's
        directory and registers them as a batch for face recognition.

        .PARAMETER PersonDirectory
        The directory containing images for a specific person.

        .PARAMETER ForceUpdate
        Whether to force re-registration even if already registered.
        #>
        #######################################################################

        function ProcessPersonDirectory {

            param(
                [System.IO.DirectoryInfo] $PersonDirectory,
                [bool] $ForceUpdate
            )

            # extract person name from directory name (no _1, _2 suffixes needed)
            $personName = $PersonDirectory.Name
            $processedCount = 0

            # output verbose information about person being processed
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing person: $personName"

            # get all image files in the person's directory excluding failed files
            $imageFiles = Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $PersonDirectory.FullName `
                -File |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.Extension -match '\.(jpg|jpeg|png|gif)$' -and
                    -not $_.Name.EndsWith('.failed')
                }

            # check if any image files were found
            if ($imageFiles.Count -eq 0) {

                # output warning if no images found for person
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "No image files found for person: $personName"

                return
            }

            # check if face is already registered unless forcing update
            if (-not $ForceUpdate) {

                # get list of existing registered faces
                $existingFaces = GenXdev.AI\Get-RegisteredFaces `
                    -NoDockerInitialize `
                    -ErrorAction SilentlyContinue

                # skip if face already registered
                if ($existingFaces -contains $personName) {

                    # output verbose information about skipped registration
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Face already registered, skipping: $personName"

                    # increment skip counter and return
                    $script:SkippedRegistrations++
                    return
                }
            }

            # collect all image paths for batch registration
            $imagePaths = $imageFiles |
                Microsoft.PowerShell.Core\ForEach-Object { $_.FullName }

            try {

                # attempt to register all faces for this person in a single call
                if (Register-FaceWithRetry -Identifier $personName `
                        -ImagePaths $imagePaths `
                        -MaxRetries $MaxRetries) {

                    # increment success counters
                    $script:SuccessfulRegistrations++
                    $processedCount = $imageFiles.Count
                }
            }
            catch {

                # output warning for unexpected processing errors
                Microsoft.PowerShell.Utility\Write-Verbose `
                ('Unexpected error processing images for ' +
                    "$personName`: $_")
            }

            # output verbose information about processing results for person
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processed $processedCount images for $personName"
        }
    }    process {

        try {

            # initialize the face recognition service unless explicitly skipped
            if (-not $NoDockerInitialize) {

                # call the service initialization function
                Initialize-FaceRecognitionService
            }
            else {

                # output verbose information about skipped initialization
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Skipping Docker initialization as requested'
            }

            # clear existing faces if force flag is specified
            if ($Force) {

                # output verbose information about force clearing
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Force flag specified - clearing existing faces'

                # copy parameters for the Unregister-AllFaces function call
                $unregisterParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\Unregister-AllFaces' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # unregister all existing faces
                $null = GenXdev.AI\Unregister-AllFaces @unregisterParams

                # pause to allow service to process the clearing operation
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5
            }

            # save current location to restore later
            $originalLocation = Microsoft.PowerShell.Management\Get-Location

            try {

                # change to the faces directory for processing
                Microsoft.PowerShell.Management\Set-Location -LiteralPath $FacesDirectory

                # get all person directories from the faces directory
                $personDirectories = @(Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath "$FacesDirectory" -Filter "*" `
                        -Directory)

                # check if any person directories were found
                if ($personDirectories.Count -eq 0) {
                    # output warning if no person directories found
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "No person directories found in: $FacesDirectory"

                    return
                }

                # output verbose information about found directories
                Microsoft.PowerShell.Utility\Write-Verbose `
                ("Found $($personDirectories.Count) person directories " +
                    'to process')

                # process each person directory
                foreach ($personDir in $personDirectories) {

                    # call function to process individual person directory
                    ProcessPersonDirectory -PersonDirectory $personDir `
                        -ForceUpdate $Force
                }
            }
            finally {

                # restore original location regardless of success or failure
                Microsoft.PowerShell.Management\Set-Location -LiteralPath $originalLocation
            }

            # report final results to user
            Microsoft.PowerShell.Utility\Write-Output 'Face registration completed:'

            Microsoft.PowerShell.Utility\Write-Output `
            ("  Successful registrations: $script:SuccessfulRegistrations")

            Microsoft.PowerShell.Utility\Write-Output `
                "  Skipped registrations: $script:SkippedRegistrations"

            Microsoft.PowerShell.Utility\Write-Output `
                "  Failed registrations: $($script:RegistrationErrors.Count)"

            # report detailed error information if any errors occurred
            if ($script:RegistrationErrors.Count -gt 0) {

                # output warning header for failed registrations
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'The following registrations failed:'

                # output each individual error
                foreach ($errorInfo in $script:RegistrationErrors) {

                    # output specific error information
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "  $($errorInfo.Identifier): $($errorInfo.Error)"
                }
            }
        }
        catch {

            # output error for any unexpected failures in main process
            Microsoft.PowerShell.Utility\Write-Error "Failed to update faces: $_"
        }
    }

    end {

        # output verbose information about process completion
        Microsoft.PowerShell.Utility\Write-Verbose `
            'Face registration process completed'
    }
}