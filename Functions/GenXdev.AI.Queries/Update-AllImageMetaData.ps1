<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Update-AllImageMetaData.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
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
Batch updates image keywords, faces, objects, and scenes across multiple system
directories.

.DESCRIPTION
This function systematically processes images across various system directories
to update their keywords, face recognition data, object detection data, and
scene classification data using AI services. It covers media storage, system
files, downloads, OneDrive, and personal pictures folders.

The function processes images by going through each directory and processing files
individually. DeepStack functions (faces, objects, scenes) are performed first,
followed by keyword and description generation. This ensures optimal processing
order and outputs structured objects compatible with Export-ImageIndex.

This allows for structured data output for pipeline operations like:
Update-AllImageMetaData | Export-ImageIndex

.PARAMETER ImageDirectories
Array of directory paths to process for image keyword and face recognition
updates. If not specified, uses default system directories.

.PARAMETER ContainerName
The name for the Docker container used for face recognition processing.

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of face recognition data.

.PARAMETER ServicePort
The port number for the DeepStack face recognition service.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check during startup.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts during service startup.

.PARAMETER ImageName
Custom Docker image name to use for face recognition processing.

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for object detection. Objects with
confidence below this threshold will be filtered out. Default is 0.5.

.PARAMETER Language
Specifies the language for generated descriptions and keywords. Defaults to
English.

.PARAMETER Model
Name or partial path of the model to initialize.

.PARAMETER HuggingFaceIdentifier
The LM-Studio model to use.

.PARAMETER ApiEndpoint
Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
The API key to use for the request.

.PARAMETER TimeoutSeconds
Timeout in seconds for the request, defaults to 24 hours.

.PARAMETER MaxToken
Maximum tokens in response (-1 for default).

.PARAMETER TTLSeconds
Set a TTL (in seconds) for models loaded via API.

.PARAMETER FacesDirectory
The directory containing face images organized by person folders. If not
specified, uses the configured faces directory preference.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER RetryFailed
Specifies whether to retry previously failed image keyword updates. When
enabled, the function will attempt to process images that failed in previous
runs.

.PARAMETER NoRecurse
Dont't recurse into subdirectories when processing images.

.PARAMETER RedoAll
Forces reprocessing of all images regardless of previous processing status.

.PARAMETER NoLMStudioInitialize
Skip LM-Studio initialization when already called by parent function to avoid
duplicate container setup.

.PARAMETER NoDockerInitialize
Skip Docker initialization when already called by parent function to avoid
duplicate container setup.

.PARAMETER Force
Force rebuild of Docker container and remove existing data for clean start.
And force restart of LMStudio.

.PARAMETER UseGPU
Use GPU-accelerated version for faster processing (requires NVIDIA GPU).

.PARAMETER ShowWindow
Show Docker + LM Studio window during initialization.

.PARAMETER PassThru
PassThru to return structured objects instead of outputting to console.

.PARAMETER AutoUpdateFaces
Detects changes in the faces directory and re-registers faces if needed.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.PARAMETER Monitor
Monitor selection for window positioning: 0=primary, 1+=specific monitor,
-1=current, -2=secondary.

.PARAMETER NoBorders
Removes window borders and title bar for a cleaner appearance.

.PARAMETER Width
Window width in pixels for positioning applications.

.PARAMETER Height
Window height in pixels for positioning applications.

.PARAMETER X
Window horizontal position for positioning applications.

.PARAMETER Y
Window vertical position for positioning applications.

.PARAMETER Left
Places window on left half of screen.

.PARAMETER Right
Places window on right half of screen.

.PARAMETER Top
Places window on top half of screen.

.PARAMETER Bottom
Places window on bottom half of screen.

.PARAMETER Centered
Centers window on screen.

.PARAMETER Fullscreen
Maximizes window to fill entire screen.

.PARAMETER RestoreFocus
Returns focus to PowerShell window after positioning.

.PARAMETER SideBySide
Places windows side by side with PowerShell on the same monitor.

.PARAMETER FocusWindow
Focus the window after positioning.

.PARAMETER SetForeground
Set the window to foreground after positioning.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER KeysToSend
Keystrokes to send to the window after positioning.

.EXAMPLE
Update-AllImageMetaData -ImageDirectories @("C:\Pictures", "D:\Photos") `
    -ServicePort 5000

.EXAMPLE
Update-AllImageMetaData -RetryFailed -Force -Language "Spanish"

.EXAMPLE
updateallimages @("C:\MyImages") -ContainerName "custom_face_recognition"
###############################################################################>
function Update-AllImageMetaData {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('updateallimages')]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Array of directory paths to process for image updates'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker volume for persistent storage'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Minimum confidence threshold (0.0-1.0) for ' +
                'object detection')
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.7,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The language for generated descriptions and ' +
                'keywords')
        )]
        [PSDefaultValue(Value = 'English')]
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu')]
        [string] $Language,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'Name or partial path of the model to initialize'
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]$Model,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM-Studio model to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$HuggingFaceIdentifier,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Api endpoint url, defaults to ' +
                'http://localhost:1234/v1/chat/completions')
        )]
        [string] $ApiEndpoint = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key to use for the request'
        )]
        [string] $ApiKey = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Timeout in seconds for the request, defaults to ' +
                '24 hours')
        )]
        [int] $TimeoutSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum tokens in response (-1 for default)'
        )]
        [Alias('MaxTokens')]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$MaxToken, # = 8192,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set a TTL (in seconds) for models loaded via API'
        )]
        [Alias('ttl')]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$TTLSeconds,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized ' +
                'by person folders. If not specified, uses the configured ' +
                'faces directory preference.')
        )]
        [string] $FacesDirectory,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will retry previously failed image keyword ' +
                'updates')
        )]
        [switch] $RetryFailed,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont't recurse into subdirectories when processing images")
        ]
        [switch] $NoRecurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Redo all images regardless of previous ' +
                'processing')
        )]
        [switch] $RedoAll,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip LM-Studio initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoLMStudioInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoDockerInitialize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use GPU-accelerated version (requires NVIDIA ' +
                'GPU)')
        )]
        [switch] $UseGPU,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Show Docker + LM Studio window during ' +
                'initialization')
        )]
        [switch]$ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('PassThru to return structured objects instead ' +
                'of outputting to console')
        )]
        [Alias('pt')]
        [switch]$PassThru,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Detects changes in the faces directory and ' +
                're-registers faces if needed')
        )]
        [switch] $AutoUpdateFaces,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in ' +
                'session for AI preferences like Language, Image ' +
                'collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        # prepare processing variables to track current state
        $onlyNew = -not $RedoAll

        $recurse = -not $NoRecurse

        # initialize lm studio service if not skipped
        if (-not $NoLMStudioInitialize) {

            # ensure lm studio is initialized with proper parameters
            try {

                # copy identical parameter values for lm studio initialization
                $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                    -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue
                )

                # ensure lm studio service is running with picture query type
                $null = GenXdev.AI\Initialize-LMStudioModel @params `
                    -LLMQueryType Pictures

                # position lm studio window if show window is requested
                if ($ShowWindow) {
                    if ($params.ContainsKey('ShowWindow')) {

                        $null = $params.Remove('ShowWindow')
                    }

                    try {

                        # get lm studio window handle
                        $lmStudioWindow = (GenXdev.Windows\Get-Window `
                            -ProcessName 'LM Studio')

                        # skip if no window found
                        if ($null -eq $lmStudioWindow) { return }

                        # position lm studio window to right top of monitor 0
                        $null = GenXdev.Windows\Set-WindowPosition `
                            -WindowHelper $lmStudioWindow `
                            -KeysToSend @("^2") `
                            -RestoreFocus `
                            -SetForeground `
                            -Monitor 0 `
                            -Right `
                            -Top

                        # position current terminal window to left side of monitor 0
                        $null = GenXdev.Windows\Set-WindowPosition `
                            -Left `
                            -Monitor 0 `
                            -Left
                    }
                    catch {
                        # ignore window positioning errors
                    }
                }

                # wait for services to stabilize
                Microsoft.PowerShell.Utility\Start-Sleep 2
            }
            catch {
                # ignore lm studio initialization errors and continue processing
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'LM Studio initialization failed, continuing without it'
                )
            }
        }

        # initialize docker services if not skipped
        if (-not $NoDockerInitialize) {

            # copy identical parameter values from bound parameters for deepstack
            $ensureParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # check if force rebuild is requested and set appropriate flag
            if ($ForceRebuild) {

                $ensureParams.Force = $true
            }
            else {

                $ensureParams.Force = $PSBoundParameters.ContainsKey(
                    'ForceRebuild') ? $false : $null
            }

            # ensure deepstack service is running for face recognition
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Initializing DeepStack service for face recognition'
            )

            $null = GenXdev.AI\EnsureDeepStack @ensureParams

            # position docker windows appropriately if show window is requested
            if ($ShowWindow) {

                if (-not $PSBoundParameters.ContainsKey('Monitor')) {
                    $ensureParams['Monitor'] = -2
                }

                try {

                    # find docker processes with main windows
                    Microsoft.PowerShell.Management\Get-Process *docker* |
                        Microsoft.PowerShell.Core\Where-Object `
                            -Property MainWindowHandle `
                            -NE 0 |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # set window position for docker ui
                            $null = GenXdev.Windows\Set-WindowPosition `
                                -Process $_ `
                                -Right `
                                -Bottom `
                                -mon 0
                        }

                    # position current window to left side
                    $null = GenXdev.Windows\Set-WindowPosition -Left -mon 0
                }
                catch {

                    # fallback positioning if docker window positioning fails
                    $null = GenXdev.Windows\Set-WindowPosition -Left -mon 0
                }
            }
        }

        # copy parameter values for faces directory retrieval
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIKnownFacesRootpath' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # get the configured faces directory path
        $facesDirectory = GenXdev.AI\Get-AIKnownFacesRootpath @params

        # count total files in faces directory including subdirectories
        $filecount = $AutoUpdateFaces ?(
            @(GenXdev.FileSystem\Find-Item "${facesDirectory}\*\" -PassThru) +
            @(GenXdev.FileSystem\Find-Item "${facesDirectory}\*\*.jpeg" `
                    -PassThru) +
            @(GenXdev.FileSystem\Find-Item "${facesDirectory}\*\*.png" `
                    -PassThru) +
            @(GenXdev.FileSystem\Find-Item "${facesDirectory}\*\*.gif" `
                    -PassThru)
        ).Count : 0

        # count directories that contain image files for face recognition
        $dirCount = $AutoUpdateFaces ? (
            @(GenXdev.FileSystem\Find-Item "${facesDirectory}\*" `
                    -Directory `
                    -PassThru |
                    Microsoft.PowerShell.Core\Where-Object {

                        (
                            @(GenXdev.FileSystem\Find-Item "$_\*.jpg" -PassThru) +
                            @(GenXdev.FileSystem\Find-Item "$_\*.jpeg" -PassThru) +
                            @(GenXdev.FileSystem\Find-Item "$_\*.png" -PassThru) +
                            @(GenXdev.FileSystem\Find-Item "$_\*.gif" -PassThru)
                        ).Count -gt 0
                    }
            ).Count
        ) : 0

        # initialize registered faces count
        $registeredFacesCount = 0

        try {

            # count total number of registered faces in the system
            $registeredFacesCount = $AutoUpdateFaces  ? @(GenXdev.AI\Get-RegisteredFaces).Count : 0

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Found ${registeredFacesCount} registered faces"
            )
        }
        catch {

            # if counting fails, default to 0
            $registeredFacesCount = 0

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Unable to count registered faces, defaulting to 0'
            )
        }

        # determine if face registrations need to be forced
        $forceFaceRegistrations = $forceFaceRegistrations -or (
            $AutoUpdateFaces -and
            ($registeredFacesCount -ne $dirCount)
        )

        # register faces if needed and files exist
        if ($forceFaceRegistrations) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Face registration mismatch detected, re-registering all faces'
            )

            try {

                # copy parameter values for face unregistration
                $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\UnRegister-AllFaces' `
                    -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue
                )

                # unregister all existing faces before re-registration
                $null = GenXdev.AI\Unregister-AllFaces @params -Confirm:$false

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Successfully unregistered all existing faces'
                )
            }
            catch {
                # ignore unregistration errors but log them
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Face unregistration failed, continuing with registration'
                )
            }

            try {

                # copy parameter values for face registration
                $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\Register-AllFaces' `
                    -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue
                )

                # register all faces from the faces directory
                $null = GenXdev.AI\Register-AllFaces @params -Confirm:$false

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Successfully registered all faces from directory'
                )
            }
            catch {
                # ignore registration errors but log them
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Face registration failed, continuing without face recognition'
                )
            }
        }

        # log start of processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Starting systematic image keyword, faces, and objects update ' +
            'across directories'
        )

        # copy parameter values for language preference retrieval
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # get the configured language for ai processing
        $language = GenXdev.AI\Get-AIMetaLanguage @params

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using language '${language}' for AI processing"
        )

        # prevent duplicate service initialization in child processes
        $noDockerInitialize = $true

        $noLMStudioInitialize = $true
    }

    process {

        # get configured directories using parameter values
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIImageCollection' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # retrieve image directories from configuration
        $directories = GenXdev.AI\Get-AIImageCollection @params

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing ${directories.Count} directories for image metadata updates"
        )

        # process each directory and file individually for structured output
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Processing files individually for structured output'
        )

        # process each directory and stream results immediately
        $directories | Microsoft.PowerShell.Core\ForEach-Object {

            $currentDirectory = $_

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Starting processing of directory: ${currentDirectory}"
            )

            # copy parameter values for metadata update processing
            $metadataParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                'GenXdev.AI\Invoke-ImageMetadataUpdate'
            ) `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # update exif metadata for images in current directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Updating EXIF metadata for directory: ${currentDirectory}"
            )

            $null = GenXdev.AI\Invoke-ImageMetadataUpdate @metadataParams `
                -ImageDirectories $currentDirectory

            # copy parameter values for face update processing
            $faceParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                'GenXdev.AI\Invoke-ImageFacesUpdate'
            ) `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # update face recognition data for images in current directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Updating face recognition data for directory: ${currentDirectory}"
            )

            $null = GenXdev.AI\Invoke-ImageFacesUpdate @faceParams `
                -ImageDirectories $currentDirectory `
                -NoDockerInitialize

            # copy parameter values for object detection processing
            $objectParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                'GenXdev.AI\Invoke-ImageObjectsUpdate'
            ) `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # update object detection data for images in current directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Updating object detection data for directory: ${currentDirectory}"
            )

            $null = GenXdev.AI\Invoke-ImageObjectsUpdate @objectParams `
                -ImageDirectories $currentDirectory `
                -NoLMStudioInitialize

            # copy parameter values for scene classification processing
            $sceneParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                'GenXdev.AI\Invoke-ImageScenesUpdate'
            ) `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # update scene classification data for images in current directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Updating scene classification data for directory: ${currentDirectory}"
            )

            $null = GenXdev.AI\Invoke-ImageScenesUpdate @sceneParams `
                -ImageDirectories $currentDirectory `
                -NoDockerInitialize

            # copy parameter values for keyword generation processing
            $keywordParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                'GenXdev.AI\Invoke-ImageKeywordUpdate'
            ) `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # update keyword and description data for images in current directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Updating keywords and descriptions for directory: ${currentDirectory}"
            )

            $null = GenXdev.AI\Invoke-ImageKeywordUpdate @keywordParams `
                -ImageDirectories $currentDirectory -NoLMStudioInitialize

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Completed processing of directory: ${currentDirectory}"
            )
        }
    }

    end {

        # log completion of all directory processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Completed image processing with DeepStack functions first, ' +
            'then keywords across all directories'
        )
    }
}
###############################################################################