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
order and outputs structured objects compatible with Export-ImageDatabase.

This allows for structured data output for pipeline operations like:
Update-AllImageMetaData | Export-ImageDatabase

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

.PARAMETER RetryFailed
Specifies whether to retry previously failed image keyword updates. When
enabled, the function will attempt to process images that failed in previous
runs.

.PARAMETER RedoAll
Forces reprocessing of all images regardless of previous processing status.

.PARAMETER NoDockerInitialize
Skip Docker initialization when already called by parent function to avoid
duplicate container setup.

.PARAMETER Force
Force rebuild of Docker container and remove existing data for clean start.
And force restart of LMStudio

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

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

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
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [Alias("updateallimages")]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Array of directory paths to process for image updates"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [string[]] $ImageDirectories,
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
            HelpMessage = "The name for the Docker volume for persistent storage"
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
        [string] $ImageName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Minimum confidence threshold (0.0-1.0) for " +
                "object detection")
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.7,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The language for generated descriptions and " +
                "keywords")
        )]
        [PSDefaultValue(Value = "English")]
        [ValidateSet(
            "Afrikaans",
            "Akan",
            "Albanian",
            "Amharic",
            "Arabic",
            "Armenian",
            "Azerbaijani",
            "Basque",
            "Belarusian",
            "Bemba",
            "Bengali",
            "Bihari",
            "Bosnian",
            "Breton",
            "Bulgarian",
            "Cambodian",
            "Catalan",
            "Cherokee",
            "Chichewa",
            "Chinese (Simplified)",
            "Chinese (Traditional)",
            "Corsican",
            "Croatian",
            "Czech",
            "Danish",
            "Dutch",
            "English",
            "Esperanto",
            "Estonian",
            "Ewe",
            "Faroese",
            "Filipino",
            "Finnish",
            "French",
            "Frisian",
            "Ga",
            "Galician",
            "Georgian",
            "German",
            "Greek",
            "Guarani",
            "Gujarati",
            "Haitian Creole",
            "Hausa",
            "Hawaiian",
            "Hebrew",
            "Hindi",
            "Hungarian",
            "Icelandic",
            "Igbo",
            "Indonesian",
            "Interlingua",
            "Irish",
            "Italian",
            "Japanese",
            "Javanese",
            "Kannada",
            "Kazakh",
            "Kinyarwanda",
            "Kirundi",
            "Kongo",
            "Korean",
            "Krio (Sierra Leone)",
            "Kurdish",
            "Kurdish (Soranî)",
            "Kyrgyz",
            "Laothian",
            "Latin",
            "Latvian",
            "Lingala",
            "Lithuanian",
            "Lozi",
            "Luganda",
            "Luo",
            "Macedonian",
            "Malagasy",
            "Malay",
            "Malayalam",
            "Maltese",
            "Maori",
            "Marathi",
            "Mauritian Creole",
            "Moldavian",
            "Mongolian",
            "Montenegrin",
            "Nepali",
            "Nigerian Pidgin",
            "Northern Sotho",
            "Norwegian",
            "Norwegian (Nynorsk)",
            "Occitan",
            "Oriya",
            "Oromo",
            "Pashto",
            "Persian",
            "Polish",
            "Portuguese (Brazil)",
            "Portuguese (Portugal)",
            "Punjabi",
            "Quechua",
            "Romanian",
            "Romansh",
            "Runyakitara",
            "Russian",
            "Scots Gaelic",
            "Serbian",
            "Serbo-Croatian",
            "Sesotho",
            "Setswana",
            "Seychellois Creole",
            "Shona",
            "Sindhi",
            "Sinhalese",
            "Slovak",
            "Slovenian",
            "Somali",
            "Spanish",
            "Spanish (Latin American)",
            "Sundanese",
            "Swahili",
            "Swedish",
            "Tajik",
            "Tamil",
            "Tatar",
            "Telugu",
            "Thai",
            "Tigrinya",
            "Tonga",
            "Tshiluba",
            "Tumbuka",
            "Turkish",
            "Turkmen",
            "Twi",
            "Uighur",
            "Ukrainian",
            "Urdu",
            "Uzbek",
            "Vietnamese",
            "Welsh",
            "Wolof",
            "Xhosa",
            "Yiddish",
            "Yoruba",
            "Zulu")]
        [string] $Language,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]$Model,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$HuggingFaceIdentifier,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Api endpoint url, defaults to " +
                "http://localhost:1234/v1/chat/completions")
        )]
        [string] $ApiEndpoint = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request"
        )]
        [string] $ApiKey = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Timeout in seconds for the request, defaults to " +
                "24 hours")
        )]
        [int] $TimeoutSecond,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$MaxToken, # = 8192,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API"
        )]
        [Alias("ttl")]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$TTLSeconds,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ("The directory containing face images organized " +
                "by person folders. If not specified, uses the configured " +
                "faces directory preference.")
        )]
        [string] $FacesDirectory,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Will retry previously failed image keyword " +
                "updates")
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
            HelpMessage = ("Redo all images regardless of previous " +
                "processing")
        )]
        [switch] $RedoAll,
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
            HelpMessage = ("Show Docker + LM Studio window during " +
                "initialization")
        )]
        [switch]$ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("PassThru to return structured objects instead " +
                "of outputting to console")
        )]
        [switch] $PassThru,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Detects changes in the faces directory and " +
                "re-registers faces if needed")
        )]
        [switch] $AutoUpdateFaces,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for " +
                "AI preferences like Language, Image collections, etc")
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session " +
                "for AI preferences like Language, Image collections, etc")
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Dont use alternative settings stored in " +
                "session for AI preferences like Language, Image " +
                "collections, etc")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        $OnlyNew = -not $RedoAll
        $Recurse = -not $NoRecurse

        if (-not $NoDockerInitialize) {

            # copy parameter values for deepstack service initialization
            $params = Genxdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack service with window display
            $null = GenXdev.AI\EnsureDeepStack @params
        }


        if ($ShowWindow) {
            try {

                # get docker desktop window handle
                $a = (GenXDev.Windows\Get-Window -ProcessName "Docker Desktop")

                if ($null -eq $a) { return }

                # show and restore docker desktop window
                $null = $a.Show()

                $null = $a.Restore()

                # position docker desktop window to right bottom of monitor 0
                GenXDev.Windows\Set-WindowPosition `
                    -WindowHelper $a `
                    -Monitor 0 `
                    -Right `
                    -Bottom

                # position current terminal window to left side of monitor 0
                GenXDev.Windows\Set-WindowPosition -Left -Monitor 0 -Left
            }
            catch {
                # ignore window positioning errors
            }
        }

        # copy parameter values for faces directory retrieval
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIKnownFacesRootpath" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get the configured faces directory path
        $FacesDirectory = GenXdev.AI\Get-AIKnownFacesRootpath @params

        # count total files in faces directory including subdirectories
        $filecount = (
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\" -PassThru) +
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\*.jpeg" `
                -PassThru) +
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\*.png" `
                -PassThru) +
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\*.gif" `
                -PassThru)
        ).Count

        # count directories that contain image files for face recognition
        $dirCount = (
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*" `
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
        )

        # initialize registered faces count
        $count = 0

        try {

            # count total number of registered faces in the system
            $count = @(GenXdev.AI\Get-RegisteredFaces).Count
        }
        catch {

            # if counting fails, default to 0
            $count = 0
        }

        # determine if face registrations need to be forced
        $ForceFaceRegistrations = $ForceFaceRegistrations -or (
            $AutoUpdateFaces -and
            ($count -ne $dirCount)
        )

        # register faces if needed and files exist
        if ((($count -eq 0) -or $ForceFaceRegistrations) -and
            ($filecount -gt 0)) {

            try {

                # copy parameter values for face unregistration
                $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\UnRegister-AllFaces' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # unregister all existing faces before re-registration
                $null = GenXdev.AI\UnRegister-AllFaces @params -Confirm:$false
            }
            catch {
                # ignore unregistration errors
            }

            try {

                # copy parameter values for face registration
                $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\Register-AllFaces' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # register all faces from the faces directory
                $null = GenXdev.AI\Register-AllFaces @params -Confirm:$false
            }
            catch {
                # ignore registration errors
            }
        }

        # log start of processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting systematic image keyword, faces, and objects update " +
            "across directories"
        )

        # copy parameter values for language preference retrieval
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get the configured language for ai processing
        $Language = GenXdev.AI\Get-AIMetaLanguage @params

        # ensure lm studio is initialized with proper parameters
        try {

            # copy identical parameter values for lm studio initialization
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureLMStudio' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # ensure lm studio service is running
            $null = GenXdev.AI\EnsureLMStudio @params
            if ($ShowWindow) {
                try {

                    # get lm studio window handle
                    $a = (GenXDev.Windows\Get-Window -ProcessName "LM Studio")

                    if ($null -eq $a) { return }

                    # show and restore lm studio window
                    $null = $a.Show()

                    $null = $a.Restore()

                    # position lm studio window to right top of monitor 0
                    GenXDev.Windows\Set-WindowPosition `
                        -WindowHelper $a `
                        -Monitor 0 `
                        -Right `
                        -Top

                    # position current terminal window to left side of monitor 0
                    GenXDev.Windows\Set-WindowPosition -Left -Monitor 0 -Left
                }
                catch {
                    # ignore window positioning errors
                }
            }
            # wait for services to stabilize
            Microsoft.PowerShell.Utility\Start-Sleep 2
        }
        catch {
            # ignore lm studio initialization errors
        }

        if (-not $NoDockerInitialize) {

            # copy identical parameter values for deepstack service initialization
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # ensure deepstack service is running for face recognition
            $null = GenXdev.AI\EnsureDeepStack @ensureParams

            # copy identical parameter values from bound parameters for deepstack
            $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # check if force rebuild is requested and set appropriate flag
            if ($ForceRebuild) {

                $ensureParams.Force = $true
            }
            else {

                $ensureParams.Force = $PSBoundParameters.ContainsKey("ForceRebuild") ?
                    $false : $null
            }

            # ensure deepstack service is running for face recognition
            $null = GenXdev.AI\EnsureDeepStack @ensureParams
        }

        # position docker windows appropriately
        if ($ShowWindow) {
            try {

                # find docker processes with main windows
                Microsoft.PowerShell.Management\Get-Process *docker* |
                Microsoft.PowerShell.Core\Where-Object `
                    -Property MainWindowHandle `
                    -ne 0 |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # set window position for docker ui
                    $null = GenXdev.Windows\Set-WindowPosition `
                        -Process $_ `
                        -top `
                        -bottom `
                        -mon 0
                }

                # position current window to left side
                $null = GenXdev.Windows\Set-WindowPosition -left -mon 0
            }
            catch {

                # fallback positioning if docker window positioning fails
                $null = GenXdev.Windows\Set-WindowPosition -left -mon 0
            }
        }
    }

    process {
        # get configured directories using parameter values
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIImageCollection" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # retrieve image directories from configuration
        $directories = GenXdev.AI\Get-AIImageCollection @params

        # process each directory and file individually for structured output
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing files individually for structured output"
        )

        # process each directory and stream results immediately
        $directories | Microsoft.PowerShell.Core\ForEach-Object -ThrottleLimit 20 -Parallel{

            $dir = $_

            $faceParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                    "GenXdev.AI\Invoke-ImageFacesUpdate"
                ) `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue
                )

             $null = GenXdev.AI\Invoke-ImageFacesUpdate @faceParams -ImageDirectories $dir -NoDockerInitialize -Recurse:$using:Recurse -OnlyNew:$using:OnlyNew -RetryFailed:$using:RetryFailed

            $objectParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName (
                    "GenXdev.AI\Invoke-ImageObjectsUpdate"
                ) `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue
                )

            $null = GenXdev.AI\Invoke-ImageObjectsUpdate @objectParams -ImageDirectories $dir -NoDockerInitialize -Recurse:$using:Recurse -OnlyNew:$using:OnlyNew -RetryFailed:$using:RetryFailed

            $sceneParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName (
                "GenXdev.AI\Invoke-ImageScenesUpdate"
            ) `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            $null = GenXdev.AI\Invoke-ImageScenesUpdate @sceneParams -ImageDirectories $dir -NoDockerInitialize -Recurse:$using:Recurse -OnlyNew:$using:OnlyNew -RetryFailed:$using:RetryFailed

            $keywordParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName (
                "GenXdev.AI\Invoke-ImageKeywordUpdate"
            ) `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            $null = GenXdev.AI\Invoke-ImageKeywordUpdate @keywordParams -ImageDirectories $dir -Recurse:$using:Recurse -OnlyNew:$using:OnlyNew -RetryFailed:$using:RetryFailed
        }
    }

    end {

        # log completion of all directory processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed image processing with DeepStack functions first, " +
            "then keywords across all directories"
        )
    }
}
###############################################################################
