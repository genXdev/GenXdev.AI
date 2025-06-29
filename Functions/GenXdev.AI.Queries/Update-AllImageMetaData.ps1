################################################################################
<#
.SYNOPSIS
Batch updates image keywords, faces, objects, and scenes across multiple system
directories.

.DESCRIPTION
This function systematically processes images across various system directories
to update their keywords, face recognition data, object detection data, and
scene classification data using AI services. It covers media storage, system
files, downloads, OneDrive, and personal pictures folders.

The function automatically detects output redirection and adjusts its behavior:
- When run standalone: Uses parallel processing across directories for maximum performance
- When output is piped: Processes files individually and outputs structured objects
  compatible with Export-ImageDatabase

This allows for both high-performance batch processing and structured data output
for pipeline operations like: Update-AllImageMetaData | Export-ImageDatabase

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

.PARAMETER Model
Name or partial path of the model to initialize.

.PARAMETER ModelLMSGetIdentifier
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

.PARAMETER ShowWindow
Show Docker + LM Studio window during initialization.

.EXAMPLE
Update-AllImageMetaData -ImageDirectories @("C:\Pictures", "D:\Photos") `
    -ServicePort 5000

.EXAMPLE
Update-AllImageMetaData -RetryFailed -Force -Language "Spanish"

.EXAMPLE
updateallimages @("C:\MyImages") -ContainerName "custom_face_recognition"
#>
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
            Position = 1,
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The name for the Docker volume for persistent storage"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "Maximum time in seconds to wait for service health check"
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = "Interval in seconds between health check attempts"
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 6,
            HelpMessage = "Custom Docker image name to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 8,
            HelpMessage = "Minimum confidence threshold (0.0-1.0) for object detection"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $ConfidenceThreshold = 0.5,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 9,
            HelpMessage = "The language for generated descriptions and keywords"
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
            Position = 10,
            ValueFromPipeline = $true,
            HelpMessage = "Name or partial path of the model to initialize"
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string]$Model = "MiniCPM",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 11,
            HelpMessage = "The LM-Studio model to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ModelLMSGetIdentifier = ("lmstudio-community/MiniCPM-V-2_6-" +
        "GGUF/MiniCPM-V-2_6-Q4_K_M.gguf"),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 12,
            HelpMessage = ("Api endpoint url, defaults to " +
                "http://localhost:1234/v1/chat/completions")
        )]
        [string] $ApiEndpoint = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 13,
            HelpMessage = "The API key to use for the request"
        )]
        [string] $ApiKey = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 14,
            HelpMessage = "Timeout in seconds for the request, defaults to 24 hours"
        )]
        [int] $TimeoutSeconds = (3600 * 24),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 15,
            HelpMessage = "Maximum tokens in response (-1 for default)"
        )]
        [Alias("MaxTokens")]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$MaxToken = 8192,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 16,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API"
        )]
        [Alias("ttl")]
        [ValidateRange(-1, [int]::MaxValue)]
        [int]$TTLSeconds = -1,
        #######################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ("The directory containing face images organized by " +
                        "person folders. If not specified, uses the " +
                        "configured faces directory preference.")
        )]
        [string] $FacesDirectory,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will retry previously failed image keyword updates"
        )]
        [switch] $RetryFailed,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Redo all images regardless of previous processing"
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
            HelpMessage = "Use GPU-accelerated version (requires NVIDIA GPU)"
        )]
        [switch] $UseGPU,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show Docker + LM Studio window during initialization"
        )]
        [switch]$ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "PassThru to return structured objects instead of outputting to console"
        )]
        [switch] $PassThru,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Detects changes in the faces directory and re-registers faces if needed"
        )]
        [switch] $AutoUpdateFaces
        ################################################################################
    )

    begin {

        $FacesDirectory = GenXdev.AI\Get-AIKnownFacesRootpath -FacesDirectory $FacesDirectory
        $filecount = (
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\" -PassThru) +
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\*.jpeg" -PassThru) +
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\*.png" -PassThru) +
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*\*.gif" -PassThru)
        ).Count

        $dirCount = (
            @(GenXdev.FileSystem\Find-Item "$FacesDirectory\*" -Directory -PassThru |
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

        $count = 0
        try
        {
            # count total number of directories to process
            $count = @(GenXdev.AI\Get-RegisteredFaces).Count
        }
        catch {
            # if counting fails, default to 0
            $count = 0
        }

        $ForceFaceRegistrations = $ForceFaceRegistrations -or (
            $AutoUpdateFaces -and
            ($count -ne $dirCount)
        )

        if ((($count -eq 0) -or $ForceFaceRegistrations) -and ($filecount -gt 0)) {

            try
            {
                # count total number of directories to process
                $null = GenXdev.AI\UnRegister-AllFaces -Confirm:$false
            }
            catch {

            }
            try
            {
                # count total number of directories to process
                $null = GenXdev.AI\Register-AllFaces -FacesDirectory $FacesDirectory
            }
            catch {

            }
        }

        # log start of processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting systematic image keyword, faces, and objects update " +
            "across directories"
        )

        $Language = GenXdev.AI\Get-AIMetaLanguage -Language (
            [String]::IsNullOrWhiteSpace($Language) ?
            (GenXdev.Helpers\Get-DefaultWebLanguage) :
            $Language
        )

        # ensure lm studio is initialized with proper parameters
        try {

            # copy identical parameter values for invoke-queryimagecontent
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\EnsureLMStudio' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # ensure lm studio service is running
            $null = GenXdev.AI\EnsureLMStudio @params

            # show window positioning if requested
            if ($ShowWindow)  {

                # wait for services to stabilize
                Microsoft.PowerShell.Utility\Start-Sleep 2

                # copy parameters for getting loaded model list
                $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\Get-LMStudioLoadedModelList' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # get loaded model list and position windows
                $windowHelper = GenXdev.AI\Get-LMStudioLoadedModelList @params `
                    -ShowWindow:$ShowWindow

                if ($null -ne $windowHelper) {

                    # position lm studio window at top right of monitor 0
                    $null = GenXdev.Windows\Set-WindowPosition `
                        -WindowHelper $windowHelper `
                        -top `
                        -right `
                        -mon 0
                }

                # position current window to left side of monitor 0
                $null = GenXdev.Windows\Set-WindowPosition -left -mon 0
            }
        }
        catch {

        }

        # copy identical parameter values from bound parameters for deepstack setup
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

        # position docker windows appropriately
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

    process {

        # get configured directories and language using get-imagedirectories
        $directories = GenXdev.AI\Get-AIImageCollection -ImageDirectories $ImageDirectories

        # detect if output is being redirected/piped by checking MyInvocation

        # we want structured output if we're NOT the last command in the pipeline
        $isOutputRedirected = $PassThru -or $MyInvocation.PipelinePosition -lt $MyInvocation.PipelineLength

        if ($isOutputRedirected) {
            # output is redirected - process files individually and output structured objects
            Microsoft.PowerShell.Utility\Write-Verbose "Output redirection detected - processing files individually for structured output"

            # process each directory in parallel and stream results immediately
            $directories |
                Microsoft.PowerShell.Core\ForEach-Object -Parallel {

                    $dir = $_
                    $redoAll = $using:RedoAll
                    $retryFailed = $using:RetryFailed
                    $language = $using:Language
                    $confidenceThreshold = $using:ConfidenceThreshold
                    $myBoundParameters = $using:PSBoundParameters

                    Microsoft.PowerShell.Utility\Write-Verbose "Processing directory: $dir"

                    # get image files for this directory and process them one by one
                    Microsoft.PowerShell.Management\Get-ChildItem -Path $dir -Recurse -File |
                        Microsoft.PowerShell.Core\Where-Object {

                        $_.Extension -match '\.(jpg|jpeg|png)$'

                    } | Microsoft.PowerShell.Core\ForEach-Object {

                        $imageFile = $PSItem

                        Microsoft.PowerShell.Utility\Write-Verbose "Processing: $($imageFile.FullName)"

                        try {
                            # initialize result object with the expected structure
                            $result = [PSCustomObject]@{
                                path = $imageFile.FullName
                                keywords = @()
                                description = $null
                                people = $null
                                objects = $null
                                scenes = $null
                            }

                            # check if this is a onedrive folder for special handling
                            $isOneDriveFolder = $imageFile.FullName -like '*\OneDrive\*' -or
                                $imageFile.FullName -like '*/OneDrive/*'

                            # determine processing flags
                            $shouldProcessFile = if ($isOneDriveFolder) {
                                $true  # always process new for OneDrive
                            } else {
                                $redoAll -or $retryFailed
                            }

                            # process keywords/description
                            $keywordParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                                -BoundParameters $myBoundParameters `
                                -FunctionName "GenXdev.AI\Invoke-ImageKeywordUpdate" `
                                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                            $keywordParams.ImagePath = $imageFile.FullName
                            $keywordParams.Verbose = $false
                            $keywordParams.onlyNew = (-not $shouldProcessFile)
                            $keywordParams.retryFailed = $retryFailed
                            $keywordParams.Language = $language
                            $keywordParams.PassThru = $true

                            $keywordResult = GenXdev.AI\Invoke-ImageKeywordUpdate @keywordParams

                            if ($keywordResult) {
                                $result.keywords = $keywordResult.keywords
                                $result.description = $keywordResult.description
                            }

                            # process face recognition
                            $faceParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                                -BoundParameters $myBoundParameters `
                                -FunctionName "GenXdev.AI\Invoke-ImageFacesUpdate" `
                                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                            $faceParams.ImagePath = $imageFile.FullName
                            $faceParams.Verbose = $false
                            $faceParams.NoDockerInitialize = $true
                            $faceParams.onlyNew = (-not $shouldProcessFile)
                            $faceParams.retryFailed = $retryFailed
                            $faceParams.PassThru = $true

                            $faceResult = GenXdev.AI\Invoke-ImageFacesUpdate @faceParams

                            if ($faceResult) {
                                $result.people = $faceResult
                            }

                            # process object detection
                            $objectParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                                -BoundParameters $myBoundParameters `
                                -FunctionName "GenXdev.AI\Invoke-ImageObjectsUpdate" `
                                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                            $objectParams.ImagePath = $imageFile.FullName
                            $objectParams.Verbose = $false
                            $objectParams.NoDockerInitialize = $true
                            $objectParams.onlyNew = (-not $shouldProcessFile)
                            $objectParams.retryFailed = $retryFailed
                            $objectParams.ConfidenceThreshold = $confidenceThreshold
                            $objectParams.PassThru = $true

                            $objectResult = GenXdev.AI\Invoke-ImageObjectsUpdate @objectParams

                            if ($objectResult) {
                                $result.objects = $objectResult
                            }

                            # process scene classification
                            $sceneParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                                -BoundParameters $myBoundParameters `
                                -FunctionName "GenXdev.AI\Invoke-ImageScenesUpdate" `
                                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                            $sceneParams.ImagePath = $imageFile.FullName
                            $sceneParams.Verbose = $false
                            $sceneParams.NoDockerInitialize = $true
                            $sceneParams.onlyNew = (-not $shouldProcessFile)
                            $sceneParams.retryFailed = $retryFailed
                            $sceneParams.PassThru = $true

                            $sceneResult = GenXdev.AI\Invoke-ImageScenesUpdate @sceneParams

                            if ($sceneResult) {

                                $result.scenes = $sceneResult
                            }

                            # immediately output the structured result for streaming
                            Microsoft.PowerShell.Utility\Write-Output $result
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning "Failed to process $($imageFile.FullName): $($_.Exception.Message)"
                        }
                    }
                } -ThrottleLimit 20
        }
        else {
            # no output redirection - use parallel processing for performance
            Microsoft.PowerShell.Utility\Write-Verbose "No output redirection detected - using parallel directory processing"

            # process each directory in parallel for maximum efficiency
            $directories |
                Microsoft.PowerShell.Core\ForEach-Object -Parallel {

                    $dir = $_
                    $redoAll = $using:RedoAll
                    $retryFailed = $using:RetryFailed
                    $language = $using:Language
                    $confidenceThreshold = $using:ConfidenceThreshold

                    # check if this is a onedrive folder for special handling
                    $isOneDriveFolder = $dir -like '*\OneDrive\*' -or
                        $dir -like '*/OneDrive/*'

                    # log which directory is being processed
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Processing $dir (keywords, faces & objects)" +
                        $(if ($isOneDriveFolder) { " [OneDrive - only new]" }
                            else { "" })
                    )

                    # initialize job collection for parallel processing
                    $jobs = @()

                    # start thread job for keyword extraction processing
                    $jobs += ThreadJob\Start-ThreadJob -ScriptBlock {

                        param($dir, $isOneDriveFolder, $redoAll, $retryFailed,
                            $language)

                        # run image keyword update with appropriate flags
                        GenXdev.AI\Invoke-ImageKeywordUpdate `
                            -imageDirectory $dir `
                            -recurse `
                            -Verbose `
                            -onlyNew:($isOneDriveFolder ? $true : (-not $redoAll)) `
                            -retryFailed:$retryFailed `
                            -Language $language

                    } -ArgumentList $dir, $isOneDriveFolder, $redoAll,
                        $retryFailed, $language

                    # start thread job for face recognition processing
                    $jobs += ThreadJob\Start-ThreadJob -ScriptBlock {

                        param($dir, $isOneDriveFolder, $redoAll, $retryFailed)

                        # run image faces update with appropriate flags
                        GenXdev.AI\Invoke-ImageFacesUpdate `
                            -imageDirectory $dir `
                            -recurse `
                            -Verbose `
                            -NoDockerInitialize `
                            -onlyNew:($isOneDriveFolder ? $true : (-not $redoAll)) `
                            -retryFailed:$retryFailed

                    } -ArgumentList $dir, $isOneDriveFolder, $redoAll, $retryFailed

                    # start thread job for object detection processing
                    $jobs += ThreadJob\Start-ThreadJob -ScriptBlock {

                        param($dir, $isOneDriveFolder, $redoAll, $retryFailed,
                            $confidenceThreshold)

                        # run image objects update with appropriate flags
                        GenXdev.AI\Invoke-ImageObjectsUpdate `
                            -imageDirectory $dir `
                            -recurse `
                            -Verbose `
                            -NoDockerInitialize `
                            -onlyNew:($isOneDriveFolder ? $true : (-not $redoAll)) `
                            -retryFailed:$retryFailed `
                            -ConfidenceThreshold $confidenceThreshold

                    } -ArgumentList $dir, $isOneDriveFolder, $redoAll,
                        $retryFailed, $confidenceThreshold

                    # start thread job for scene classification processing
                    $jobs += ThreadJob\Start-ThreadJob -ScriptBlock {

                        param($dir, $isOneDriveFolder, $redoAll, $retryFailed)

                        # run image scenes update with appropriate flags
                        GenXdev.AI\Invoke-ImageScenesUpdate `
                            -imageDirectory $dir `
                            -recurse `
                            -Verbose `
                            -NoDockerInitialize `
                            -onlyNew:($isOneDriveFolder ? $true : (-not $redoAll)) `
                            -retryFailed:$retryFailed

                    } -ArgumentList $dir, $isOneDriveFolder, $redoAll, $retryFailed

                    # wait for all jobs to finish and collect results
                    $jobs |
                        Microsoft.PowerShell.Core\Wait-Job |
                        Microsoft.PowerShell.Core\Receive-Job

                    # clean up completed jobs
                    $jobs |
                        Microsoft.PowerShell.Core\Remove-Job

                } -ThrottleLimit 10
        }
    }

    end {

        # log completion of all directory processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed image keyword, faces, objects, and scenes updates across " +
            "all directories"
        )
    }
}
################################################################################
