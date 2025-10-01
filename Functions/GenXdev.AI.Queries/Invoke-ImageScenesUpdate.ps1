<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Invoke-ImageScenesUpdate.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.290.2025
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
Updates scene classification metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to classify scenes using
artificial intelligence. It creates JSON metadata files containing scene
classifications, confidence scores, and labels. The function supports batch
processing with configurable confidence thresholds and can optionally skip
existing metadata files or retry previously failed classifications.

.PARAMETER ImageDirectories
Array of directory paths containing images to process. Can be relative or
absolute paths. Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all
subdirectories recursively.

.PARAMETER OnlyNew
If specified, only processes images that don't already have scene metadata
files or have empty metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images that have empty
metadata files or contain error indicators.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called
by parent function to avoid redundant container setup.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This will recreate the entire scene classification environment.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU
with appropriate drivers and CUDA support.

.PARAMETER ContainerName
The name for the Docker container running the scene classification service.
Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of classification models
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
Allows using alternative scene classification models or configurations.

.EXAMPLE
Invoke-ImageScenesUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Recurse

Processes all images in C:\Photos and D:\Pictures and subdirectories for scene
classification.

.EXAMPLE
scenerecognition @("C:\Photos", "C:\Archive") -RetryFailed -OnlyNew

Uses alias to retry failed classifications and only process new images in
multiple directories.

.EXAMPLE
Invoke-ImageScenesUpdate -ImageDirectories ".\MyImages" -Force -UseGPU

Forces container rebuild and uses GPU acceleration for faster processing.

.EXAMPLE
Invoke-ImageScenesUpdate -ImageDirectories "C:\Photos" -ConfidenceThreshold 0.6 -Recurse

Processes all images recursively and only stores scene classifications with confidence >= 60%.

.NOTES
This function stores scene classification data in NTFS alternative data streams
as 'ImageFile.jpg:scenes.json' files. Each metadata file contains scene
classification results with confidence scores and scene labels from DeepStack's
365 scene categories including places like: abbey, airplane_cabin, beach,
forest, kitchen, office, etc.
###############################################################################>
function Invoke-ImageScenesUpdate {

    [CmdletBinding()]
    [Alias('imagescenedetection')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The directory paths containing images to process'
        )]
        [string[]] $ImageDirectories = @('.\'),

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
        [int] $TimeoutSecond,
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
        [string] $PreferencesDatabasePath,
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

        # process each directory provided
        $processedDirectories = @()
        foreach ($directory in $ImageDirectories) {
            # resolve the absolute path for the image directory
            $path = GenXdev.FileSystem\Expand-Path $directory

            # check if the specified directory exists
            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $path -PathType Container)) {
                Microsoft.PowerShell.Utility\Write-Warning "Directory not found: $path - skipping"
                continue
            }

            $processedDirectories += $path
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing images in directory: $path"
            )
        }

        if ($processedDirectories.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Warning "No valid directories found to process"
            return
        }
    }

    process {

        # process each validated directory
        foreach ($path in $processedDirectories) {
            Microsoft.PowerShell.Utility\Write-Verbose "Processing directory: $path"

            # discover all image files in the specified directory path, selectively
            # applying recursion only if the -Recurse switch was provided
            # get all supported image files from the specified directory
            $imageTypes = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tif")
            $findParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.FileSystem\Find-Item" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            # Add NoRecurse parameter if Recurse was not specified
            if (-not $Recurse) {
                $findParams['NoRecurse'] = $true
            }

            # Get all image files matching the criteria
            GenXdev.FileSystem\Find-Item @findParams -PassThru -SearchMask "$path\*" -Directory:$false | Microsoft.PowerShell.Core\Where-Object {
                $imageTypes.IndexOf(([IO.Path]::GetExtension($_.FullName).ToLowerInvariant())) -ge 0
            } | Microsoft.PowerShell.Core\ForEach-Object {
                try {
                    # store the full path to the current image for better readability
                    $image = $PSItem.FullName
                    $metadataFilePath = "$($PSItem.FullName):scenes.json"
                    # check if metadata file exists
                    $fileExists = [System.IO.File]::Exists($metadataFilePath)
                    # check if we have valid existing content
                    $hasValidContent = $false
                    if ($fileExists) {
                        try {
                            $content = [System.IO.File]::ReadAllText($metadataFilePath)
                            $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            # Valid content means successful processing OR explicitly marked as unknown scene
                            $hasValidContent = ($existingData.success -eq $true) -or ($existingData.scene -eq 'unknown')
                        }
                        catch {
                            # If JSON parsing fails, treat as invalid content
                            $hasValidContent = $false
                        }
                    }

                    # determine if image should be processed based on options
                    # Process if: not OnlyNew OR file doesn't exist OR (RetryFailed and no valid content)
                    $shouldProcess = (-not $OnlyNew) -or
                                    (-not $fileExists) -or
                                    ($RetryFailed -and (-not $hasValidContent))

                    if ($shouldProcess) {

                        # obtain scene classification data using ai recognition technology
                        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                            -FunctionName 'GenXdev.AI\Get-ImageDetectedScenes' `
                            -BoundParameters $PSBoundParameters `
                            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                        $sceneData = GenXdev.AI\Get-ImageDetectedScenes `
                            @params `
                            -ImagePath $image

                        $NoDockerInitialize = $true;

                        # process the returned scene data into standardized format
                        $processedData = if ($sceneData -and
                            $sceneData.success -and
                            $sceneData.scene) {

                            # create standardized data structure for scene metadata
                            @{
                                success               = $sceneData.success
                                scene                 = $sceneData.scene
                                label                 = $sceneData.label
                                confidence            = $sceneData.confidence
                                confidence_percentage = $sceneData.confidence_percentage
                            }

                        } else {

                            # create error data structure when scene detection fails
                            @{
                                success               = $false
                                scene                 = 'unknown'
                                label                 = 'unknown'
                                confidence            = 0.0
                                confidence_percentage = 0.0
                                error                 = 'Scene classification failed'
                            }
                        }

                        # convert the processed data to json format for storage
                        $jsonData = $processedData |
                            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

                        # save the scene metadata to the alternative data stream
                        $null = [System.IO.File]::WriteAllText($metadataFilePath,
                            $jsonData)

                        # provide feedback on processing completion
                        if ($processedData.success) {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Scene classification completed for: $image - " +
                                "Scene: $($processedData.scene) " +
                                "(Confidence: $($processedData.confidence_percentage)%)")

                        } else {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Scene classification failed for: $image")
                        }

                    } else {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Skipping already processed image: $image")
                    }
                }
                catch {
                    # Handle any errors in scene processing for individual images
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Failed to process scenes for $image : $($_.Exception.Message)")
                }
            }
        }
    }

    end {
    }
}