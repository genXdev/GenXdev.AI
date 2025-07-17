###############################################################################
<#
.SYNOPSIS
Updates object detection metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to detect objects using
artificial intelligence. It creates JSON metadata files containing detected
objects, their positions, confidence scores, and labels. The function supports
batch processing with configurable confidence thresholds and can optionally
skip existing metadata files or retry previously failed detections.

.PARAMETER ImageDirectories
The directory path containing images to process. Can be relative or absolute
path. Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all
subdirectories recursively.

.PARAMETER OnlyNew
If specified, only processes images that don't already have object metadata
files or have empty metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images that have empty
metadata files or contain error indicators.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called
by parent function to avoid redundant container setup.

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for object detection. Objects detected
with confidence below this threshold will be filtered out. Default is 0.5.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This will recreate the entire detection environment.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU
with appropriate drivers and CUDA support.

.PARAMETER ContainerName
The name for the Docker container running the object detection service.
Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of detection models
and data. Default is "deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service to listen on. Must be between
1 and 65535. Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check before timing out.
Must be between 10 and 300 seconds. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts when waiting for service
startup. Must be between 1 and 10 seconds. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image.
Allows using alternative object detection models or configurations.

.EXAMPLE
Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -Recurse

This example processes all images in C:\Photos and all subdirectories using
default settings with 0.5 confidence threshold.

.EXAMPLE
Invoke-ImageObjectsUpdate "C:\Photos" -RetryFailed -OnlyNew

This example processes only new images and retries previously failed ones
in the C:\Photos directory using positional parameter syntax.

.EXAMPLE
Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -UseGPU `
    -ConfidenceThreshold 0.7

This example uses GPU acceleration with higher confidence threshold of 0.7
for more accurate but fewer object detections.
#>
function Invoke-ImageObjectsUpdate {

    [CmdletBinding()]
    [Alias('objectdetection')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The directory path containing images to process'
        )]
        [string] $ImageDirectories = '.\',

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Process images in specified directory and all ' +
                'subdirectories')
        )]
        [switch] $Recurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only process images that don't already have face " +
                'metadata files')
        )]
        [switch] $OnlyNew,
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
            HelpMessage = ('Skip LM-Studio initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoLMStudioInitialize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch]$Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The type of LLM query'
        )]
        [ValidateSet(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )]
        [string] $LLMQueryType = 'SimpleIntelligence',
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The time-to-live in seconds for cached AI responses'
        )]
        [int] $TTLSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show LM Studio window during initialization'
        )]
        [switch]$ShowWindow,
        ########################################################################
        [Alias('m', 'mon')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [int] $Monitor = -1,
        ########################################################################

        [Alias('nb')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [switch] $NoBorders,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y = -1,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ########################################################################

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [Alias('fs')]
        [switch]$FullScreen,

        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the window helper for each process'
        )]
        [Alias('pt')]
        [switch]$PassThru,

        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Will either set the window fullscreen on a different monitor than Powershell, or ' +
            'side by side with Powershell on the same monitor'
        )]
        [Alias('sbs')]
        [switch]$SideBySide,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [ValidateNotNullOrEmpty()]
        [string[]] $KeysToSend,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ########################################################################

    )
    begin {

        # convert the possibly relative path to an absolute path for reliable access
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectories

        # ensure the target directory exists before proceeding with any operations
        if (-not [System.IO.Directory]::Exists($path)) {

            Microsoft.PowerShell.Utility\Write-Host (
                "The directory '$path' does not exist."
            )
            return
        }

        # output verbose information about the processing directory
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing images for object detection in directory: $path"
        )
    }

    process {

        # retrieve all supported image files from the specified directory
        # applying recursion only if the recurse switch was provided
        Microsoft.PowerShell.Management\Get-ChildItem `
            -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.gif","$path\*.png" `
            -Recurse:$Recurse `
            -File `
            -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                try {

                    # store the full path to the current image for better readability
                    $image = $PSItem.FullName

                    # output verbose information about current image being processed
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Processing image for object detection: $image"
                    )

                    # construct path for the metadata file
                    $metadataFilePath = "$($image):objects.json"

                    # check if a metadata file already exists for this image
                    $fileExists = [System.IO.File]::Exists($metadataFilePath)

                    # check if we have valid existing content
                    $hasValidContent = $false
                    if ($fileExists) {
                        try {
                            $content = [System.IO.File]::ReadAllText($metadataFilePath)
                            $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            $hasValidContent = $existingData.success
                        }
                        catch {
                            # If JSON parsing fails, treat as invalid content
                            $hasValidContent = $false
                        }
                    }

                    # determine if we should process this image based on conditions
                    if ((-not $OnlyNew) -or (-not $fileExists) -or (-not $hasValidContent)) {

                        # obtain object detection data using ai detection technology
                        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                            -BoundParameters $PSBoundParameters `
                            -FunctionName 'GenXdev.AI\Get-ImageDetectedObjects' `
                            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                                -Scope Local -ErrorAction SilentlyContinue)

                        $objectData = Get-ImageDetectedObjects `
                            @params `
                            -ImagePath $image

                        $NoDockerInitialize = $true;
                        # process the detection results into structured data format
                        $processedData = if ($objectData -and
                            $objectData.success -and
                            $objectData.predictions) {

                            # extract predictions array from detection results
                            $predictions = $objectData.predictions

                            # create array of object labels from predictions
                            $objectLabels = $predictions |
                                Microsoft.PowerShell.Core\ForEach-Object {
                                    $_.label
                                }

                                # group objects by label to get counts
                                $objectCounts = $objectLabels |
                                    Microsoft.PowerShell.Utility\Group-Object `
                                        -NoElement

                                    # construct structured data object with all metadata
                                    $data = @{
                                        success       = $true
                                        count         = $predictions.Count
                                        objects       = $objectLabels
                                        predictions   = $predictions
                                        object_counts = @{}
                                    }

                                    # populate object counts from grouped results
                                    $objectCounts |
                                        Microsoft.PowerShell.Core\ForEach-Object {
                                            $data.object_counts[$_.Name] = $_.Count
                                        }

                                        $data
                                    } else {

                                        # create empty structure if no objects are detected
                                        @{
                                            success       = $true
                                            count         = 0
                                            objects       = @()
                                            predictions   = @()
                                            object_counts = @{}
                                        }
                                    }

                                    # convert processed data to json format for storage
                                    $objects = $processedData |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                                            -Depth 20 `
                                            -WarningAction SilentlyContinue

                                        # output verbose confirmation of detection analysis completion
                                        Microsoft.PowerShell.Utility\Write-Verbose (
                                            "Received object detection analysis for: $image"
                                        )

                                        try {

                                            # re-parse and compress json for consistent formatting
                                            $newContent = ($objects |
                                                    Microsoft.PowerShell.Utility\ConvertFrom-Json |
                                                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                                                        -Compress `
                                                        -Depth 20 `
                                                        -WarningAction SilentlyContinue)

                                                # ensure proper empty structure format
                                                if ($newContent -eq (
                                                        '{"predictions":null,"count":0,"objects":[]}'
                                                    )) {

                                                    $newContent = (
                                                        '{"success":true,"count":0,"objects":[],' +
                                                        '"predictions":[],"object_counts":{}}'
                                                    )
                                                }

                                                # save the processed object data to metadata file
                                                [System.IO.File]::WriteAllText(
                                                    $metadataFilePath,
                                                    $newContent
                                                )

                                                # output verbose confirmation of successful save
                                                Microsoft.PowerShell.Utility\Write-Verbose (
                                                    "Successfully saved object metadata for: $image"
                                                )
                                            }
                                            catch {

                                                # log any errors that occur during metadata processing
                                                Microsoft.PowerShell.Utility\Write-Verbose (
                                                    "$PSItem`r`n$objects"
                                                )
                                            }
                                        }
                                    }
                                    catch {

                                        # log any errors that occur during image processing
                                        Microsoft.PowerShell.Utility\Write-Verbose (
                                            "Error processing image '$image': " +
                                            "$($_.Exception.Message)"
                                        )
                                    }
                                }
    }    end {
    }
}
