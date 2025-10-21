<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Invoke-ImageFacesUpdate.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.304.2025
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
Updates face recognition metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to identify and analyze
faces using AI recognition technology. It creates or updates metadata files
containing face information for each image. The metadata is stored in a
separate file with
.PARAMETER ImageDirectories
Array of directory paths containing images to process. Can be relative or
absolute. Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all subdirectories.

.PARAMETER OnlyNew
If specified, only processes images that don't already have face metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images (empty metadata files).

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called by
parent function.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch is
used.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU.

.PARAMETER ContainerName
The name for the Docker container. Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage. Default is
"deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service. Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image.

.EXAMPLE
Invoke-ImageFacesUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Recurse

.EXAMPLE
facerecognition @("C:\Photos", "C:\Archive") -RetryFailed -OnlyNew
###############################################################################>
function Invoke-ImageFacesUpdate {

    [CmdletBinding()]
    [Alias('imagepeopledetection')]
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
        [Alias('DatabasePath')]
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
            # convert the possibly relative path to an absolute path for reliable access
            $path = GenXdev.FileSystem\Expand-Path $directory

            # ensure the target directory exists before proceeding with any operations
            if (-not [System.IO.Directory]::Exists($path)) {
                Microsoft.PowerShell.Utility\Write-Warning "Directory not found: $path - skipping"
                continue
            }

            $processedDirectories += $path
            Microsoft.PowerShell.Utility\Write-Verbose ('Processing images in ' +
                "directory: $path")
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

            # retrieve all supported image files from the specified directory
            # applying recursion only if the -Recurse switch was provided
            # get all supported image files from the specified directory
            $imageTypes = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tif")
            $findParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
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

                # store the full path to the current image for better readability
                $image = $PSItem.FullName
                $metadataFilePath = "$($image):people.json"

                # check if a metadata file already exists for this image
                $fileExists = [System.IO.File]::Exists($metadataFilePath)

                # check if we have valid existing content
                $hasValidContent = $false
                if ($fileExists) {
                    try {
                        $content = [System.IO.File]::ReadAllText($metadataFilePath)
                        $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                        # Content is valid if success is true (successful processing)
                        $hasValidContent = $existingData.success -eq $true
                    }
                    catch {
                        # If JSON parsing fails, treat as invalid content
                        $hasValidContent = $false
                    }
                }

                # determine if image should be processed based on options
                Microsoft.PowerShell.Utility\Write-Verbose `
                ("OnlyNew: $OnlyNew, FileExists: $fileExists, " +
                    "HasValidContent: $hasValidContent, RetryFailed: $RetryFailed")

                # Process if: not OnlyNew OR file doesn't exist OR (RetryFailed and no valid content)
                $shouldProcess = (-not $OnlyNew) -or
                                (-not $fileExists) -or
                                ($RetryFailed -and (-not $hasValidContent))

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Should process '$image': $shouldProcess"

                if ($shouldProcess) {

                    try {
                        # obtain face recognition data using ai recognition technology
                        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                            -FunctionName 'GenXdev.AI\Get-ImageDetectedFaces' `
                            -BoundParameters $PSBoundParameters `
                            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                        # Set NoDockerInitialize for the first image,
                        # then pass it as a parameter for subsequent images
                        $faceData = GenXdev.AI\Get-ImageDetectedFaces `
                            @params `
                            -ImagePath $image

                        $NoDockerInitialize = $true;

                        # process the returned face data into standardized format
                        $processedData = if ($faceData -and
                            $faceData.success -and
                            $faceData.predictions) {

                            $predictions = $faceData.predictions

                            # extract unique face names from predictions data
                            $faceNames = $predictions |
                                Microsoft.PowerShell.Core\ForEach-Object {

                                    $name = $_.userid
                                    $lastUnderscoreIndex = $name.LastIndexOf('_')

                                    # remove timestamp suffix if present in face name
                                    if ($lastUnderscoreIndex -gt 0) {
                                        $name.Substring(0, $lastUnderscoreIndex)
                                    } else {
                                        $name
                                    }
                                } |
                                Microsoft.PowerShell.Utility\Sort-Object -Unique

                                # create standardized data structure for face metadata
                                @{
                                    success     = $true
                                    count       = $faceNames.Count
                                    faces       = $faceNames
                                    predictions = $predictions
                                }
                        } else {

                            # create empty structure when no faces are detected
                            @{
                                success     = $true
                                count       = 0
                                faces       = @()
                                predictions = @()
                            }
                        }

                        # convert processed data to json format for storage
                        $faces = $processedData |
                            Microsoft.PowerShell.Utility\ConvertTo-Json `
                                -Depth 20 `
                                -WarningAction SilentlyContinue

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Received face analysis for: $image")

                        # reformat json to ensure consistent compressed format
                        $newContent = ($faces |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json |
                                Microsoft.PowerShell.Utility\ConvertTo-Json `
                                    -Compress `
                                    -Depth 20 `
                                    -WarningAction SilentlyContinue)

                        # save the processed face data to metadata file
                        [System.IO.File]::WriteAllText($metadataFilePath, $newContent)

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Successfully saved face metadata for: $image")
                    }
                    catch {
                        # write failure JSON to prevent infinite retries without -RetryFailed
                        try {
                            $failureData = @{
                                success = $false
                                count = 0
                                faces = @()
                                predictions = @()
                                error = "Face detection failed: $($_.Exception.Message)"
                            }

                            $failureJson = $failureData | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10
                            [System.IO.File]::WriteAllText($metadataFilePath, $failureJson)
                        }
                        catch {
                            # If we can't even write the failure JSON, just log it
                            Microsoft.PowerShell.Utility\Write-Verbose "Failed to write error metadata for ${image}: $($_.Exception.Message)"
                        }

                        Microsoft.PowerShell.Utility\Write-Warning (
                            "Failed to process faces for $image : $($_.Exception.Message)")
                    }
                }
            }
        }
    }

    end {
    }
}