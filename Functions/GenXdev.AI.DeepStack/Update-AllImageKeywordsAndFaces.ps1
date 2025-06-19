################################################################################
<#
.SYNOPSIS
Batch updates image keywords and faces across multiple system directories.

.DESCRIPTION
This function systematically processes images across various system directories
to update their keywords and face recognition data using AI services. It covers
media storage, system files, downloads, OneDrive, and personal pictures
folders. The function uses parallel processing to efficiently handle both
keyword extraction and face recognition tasks simultaneously across multiple
directories.

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

.PARAMETER FacesPath
The path inside the container where face recognition data is stored.

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

.PARAMETER UseGPU
Use GPU-accelerated version for faster processing (requires NVIDIA GPU).

.PARAMETER Language
Specifies the language for generated descriptions and keywords. Defaults to English.

.EXAMPLE
Update-AllImageKeywordsAndFaces -ImageDirectories @("C:\Pictures", "D:\Photos") -ServicePort 5000

.EXAMPLE
Update-AllImageKeywordsAndFaces -RetryFailed -Force -Language "Spanish"

.EXAMPLE
Update-AllImageKeywordsAndFaces @("C:\MyImages") -ContainerName "custom_face_recognition"
#>
function Update-AllImageKeywordsAndFaces {
    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [Alias("updateallimages")]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Array of directory paths to process for image updates"
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The name for the Docker container"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = "deepstack_face_recognition",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The name for the Docker volume for persistent storage"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = "deepstack_face_data",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "The port number for the DeepStack service"
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "Maximum time in seconds to wait for service health check"
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = "Interval in seconds between health check attempts"
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 6,
            HelpMessage = "Custom Docker image name to use"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 7,
            HelpMessage = "The path inside the container where faces are stored"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $FacesPath = "/datastore",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Retry previously failed image keyword updates"
        )]
        [switch] $RetryFailed,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Redo all images regardless of previous processing"
        )]
        [switch] $RedoAll,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip Docker initialization (used when already called by parent function)"
        )]
        [switch] $NoDockerInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force rebuild of Docker container and remove existing data"
        )]
        [Alias("ForceRebuild")]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use GPU-accelerated version (requires NVIDIA GPU)"
        )]
        [switch] $UseGPU,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
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
        [string] $Language = "English"
        ###############################################################################
    )
    begin {

        # log start of processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting systematic image keyword update across directories"
        )

        # copy identical parameter values from bound parameters for deepstack setup
        $ensureParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'EnsureDeepStack' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # check if force rebuild is requested and set appropriate flag
        if ($ForceRebuild) {

            $ensureParams.Force = $true
        }
        else {

            $ensureParams.Force = $PSBoundParameters.ContainsKey("ForceRebuild") ? $false : $null
        }

        # ensure deepstack service is running for face recognition
        $null = GenXdev.AI\EnsureDeepStack @ensureParams
    }

    process {

        # use provided directories or default system directories
        if ($ImageDirectories) {

            # convert provided directories to simple path array
            $directories = $ImageDirectories
        }
        else {
            $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
            try {
                # attempt to get known folder path for Pictures
                $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
            }
            catch {
                # fallback to default if known folder retrieval fails
                $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
            }

            # define default directories for processing
            $directories = @(
                (GenXdev.FileSystem\Expand-Path '~\downloads'),
                (GenXdev.FileSystem\Expand-Path '~\\onedrive'),
                $picturesPath
            )

        }

        # process each directory in parallel for maximum efficiency
        $directories |
            Microsoft.PowerShell.Core\ForEach-Object -Parallel {

                $dir = $_
                $redoAll = $using:RedoAll
                $retryFailed = $using:RetryFailed
                $language = $using:Language

                # check if this is a onedrive folder for special handling
                $isOneDriveFolder = $dir -like '*\OneDrive\*' -or $dir -like '*/OneDrive/*'

                # log which directory is being processed
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing $dir (keywords & faces)" +
                    $(if ($isOneDriveFolder) { " [OneDrive - only new]" } else { "" })
                )

                $jobs = @()

                # start thread job for keyword extraction processing
                $jobs += ThreadJob\Start-ThreadJob -ScriptBlock {
                    param($dir, $isOneDriveFolder, $redoAll, $retryFailed, $language)

                    # run image keyword update with appropriate flags
                    GenXdev.AI\Invoke-ImageKeywordUpdate `
                        -imageDirectory $dir `
                        -recurse `
                        -Verbose `
                        -onlyNew:($isOneDriveFolder ? $true : (-not $redoAll)) `
                        -retryFailed:$retryFailed `
                        -Language $language
                } -ArgumentList $dir, $isOneDriveFolder, $redoAll, $retryFailed, $language

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

                # wait for both jobs to finish and collect results
                $jobs |
                    Microsoft.PowerShell.Core\Wait-Job |
                    Microsoft.PowerShell.Core\Receive-Job

                # clean up completed jobs
                $jobs |
                    Microsoft.PowerShell.Core\Remove-Job
            } -ThrottleLimit 5
    }

    end {

        # log completion of all directory processing
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed image keyword and faces updates across all directories"
        )
    }
}
################################################################################
