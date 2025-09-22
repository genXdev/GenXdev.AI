<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Save-Transcriptions.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
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
Generates subtitle files for audio and video files using OpenAI Whisper.

.DESCRIPTION
Recursively searches for media files in the specified directory and uses a local
OpenAI Whisper model to generate subtitle files in SRT format. The function
supports multiple audio/video formats and can optionally translate subtitles to
a different language using LM Studio. File naming follows a standardized pattern
with language codes (e.g., video.mp4.en.srt).

.PARAMETER DirectoryPath
The root directory to search for media files. Defaults to the current directory.
Will recursively process all supported media files in subfolders.

.PARAMETER LanguageIn
The expected source language of the audio content. Used to improve transcription
accuracy. Defaults to English. Supports 150+ languages.

.PARAMETER LanguageOut
Optional target language for translation. If specified, the generated subtitles
will be translated from LanguageIn to this language using LM Studio.

.PARAMETER TokenTimestampsSumThreshold
Sum threshold for token timestamps, defaults to 0.5.

.PARAMETER MaxTokensPerSegment
Maximum number of tokens per segment.

.PARAMETER MaxDurationOfSilence
Maximum duration of silence before automatically stopping recording.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30).

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for speech recognition.

.PARAMETER TemperatureInc
Temperature increment.

.PARAMETER Prompt
Prompt to use for the model.

.PARAMETER SuppressRegex
Regex to suppress tokens from the output.

.PARAMETER AudioContextSize
Size of the audio context.

.PARAMETER MaxDuration
Maximum duration of the audio.

.PARAMETER Offset
Offset for the audio.

.PARAMETER MaxLastTextTokens
Maximum number of last text tokens.

.PARAMETER MaxSegmentLength
Maximum segment length.

.PARAMETER MaxInitialTimestamp
Start timestamps at this moment.

.PARAMETER LengthPenalty
Length penalty.

.PARAMETER EntropyThreshold
Entropy threshold.

.PARAMETER LogProbThreshold
Log probability threshold.

.PARAMETER NoSpeechThreshold
No speech threshold.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER WithTokenTimestamps
Whether to include token timestamps in the output.

.PARAMETER SplitOnWord
Whether to split on word boundaries.

.PARAMETER IgnoreSilence
Whether to ignore silence (will mess up timestamps).

.PARAMETER WithProgress
Whether to show progress.

.PARAMETER DontSuppressBlank
Whether to NOT suppress blank lines.

.PARAMETER SingleSegmentOnly
Whether to use single segment only.

.PARAMETER PrintSpecialTokens
Whether to print special tokens.

.PARAMETER NoContext
Don't use context.

.PARAMETER WithBeamSearchSamplingStrategy
Use beam search sampling strategy.

.PARAMETER ModelType
Whisper model type to use, defaults to LargeV3Turbo.

.PARAMETER PassThru
Returns objects instead of strings.

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Save-Transcriptions -DirectoryPath "C:\Videos" -LanguageIn "English"

.EXAMPLE
Save-Transcriptions "C:\Media" "Japanese" "English"
#>
function Save-Transcriptions {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        #######################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The directory path to search for media files'
        )]
        [string] $DirectoryPath = '.\',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'The language to expect in the audio.'
        )]
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
            'Bork, bork, bork!',
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
            'Elmer Fudd',
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
            'Hacker',
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
            'Klingon',
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
            'Pirate',
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
            'Zulu'
        )]
        [string] $LanguageIn,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Sets the language to translate to.'
        )]
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
            'Bork, bork, bork!',
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
            'Elmer Fudd',
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
            'Hacker',
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
            'Klingon',
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
            'Pirate',
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
            'Zulu'
        )]
        [string] $LanguageOut,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sum threshold for token timestamps, defaults to 0.5'
        )]
        [float] $TokenTimestampsSumThreshold = 0.5,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum number of tokens per segment'
        )]
        [int] $MaxTokensPerSegment = 20,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Maximum duration of silence before automatically ' +
                'stopping recording')
        )]
        [object] $MaxDurationOfSilence,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence detect threshold (0..32767 defaults to 30)'
        )]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use, defaults to 0 (auto)'
        )]
        [int] $CpuThreads = 0,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for speech recognition'
        )]
        [ValidateRange(0, 1)]
        [float] $Temperature = 0.5,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature increment'
        )]
        [ValidateRange(0, 1)]
        [float] $TemperatureInc,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prompt to use for the model'
        )]
        [string] $Prompt,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regex to suppress tokens from the output'
        )]
        [string] $SuppressRegex = $null,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Size of the audio context'
        )]
        [int] $AudioContextSize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum duration of the audio'
        )]
        [object] $MaxDuration,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Offset for the audio'
        )]
        [object] $Offset,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum number of last text tokens'
        )]
        [int] $MaxLastTextTokens,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum segment length'
        )]
        [int] $MaxSegmentLength,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Start timestamps at this moment'
        )]
        [object] $MaxInitialTimestamp,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty'
        )]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold'
        )]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold'
        )]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold'
        )]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to include token timestamps in the output'
        )]
        [switch] $WithTokenTimestamps,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to split on word boundaries'
        )]
        [switch] $SplitOnWord,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to ignore silence (will mess up timestamps)'
        )]
        [switch] $IgnoreSilence,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to show progress'
        )]
        [switch] $WithProgress,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to NOT suppress blank lines'
        )]
        [switch] $DontSuppressBlank,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to use single segment only'
        )]
        [switch] $SingleSegmentOnly,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to print special tokens'
        )]
        [switch] $PrintSpecialTokens,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't use context"
        )]
        [switch] $NoContext,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whisper model type to use, defaults to LargeV3Turbo'
        )]
        [ValidateSet('Tiny', 'TinyEn', 'Base', 'BaseEn', 'Small', 'SmallEn',
            'Medium', 'MediumEn', 'Large', 'LargeV1', 'LargeV2', 'LargeV3', 'LargeV3Turbo')]
        [string] $ModelType,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns objects instead of strings'
        )]
        [Alias('pt')]
        [switch]$PassThru,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Whether to use desktop audio capture instead of ' +
                'microphone input')
        )]
        [switch] $UseDesktopAudioCapture,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image ' +
                'collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        # copy identical parameter values for meta language processing
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get resolved language using meta language processing
        $params.Language = $LanguageIn
        if ([string]::IsNullOrWhiteSpace($LanguageIn)) {
            $null = $params.Remove('Language')
        }
        $languageIn = GenXdev.AI\Get-AIMetaLanguage @params
        $params.Language = $LanguageOut
        if ([string]::IsNullOrWhiteSpace($LanguageOut)) {
            $null = $params.Remove('Language')
        }
        $languageOut = GenXdev.AI\Get-AIMetaLanguage @params

        # define array of supported media file extensions for processing
        $extensions = @(
            '.3gp',
            '.a52',
            '.aac',
            '.ac3',
            '.amr',
            '.mp3',
            '.adp',
            '.aiff',
            '.amr',
            '.ape',
            '.asf',
            '.avi',
            '.avif',
            '.avs',
            '.bink',
            '.bmp',
            '.caf',
            '.cavs',
            '.cgm',
            '.clpi',
            '.cpx',
            '.dds',
            '.dcm',
            '.dcr',
            '.dpx',
            '.dsic',
            '.dts',
            '.dtshd',
            '.dv',
            '.dvh',
            '.dvr',
            '.dxa',
            '.eac3',
            '.exr',
            '.ffm',
            '.ffmetadata',
            '.flac',
            '.flv',
            '.fmp4',
            '.gif',
            '.gsm',
            '.h261',
            '.h263',
            '.h264',
            '.h265',
            '.hevc',
            '.hls',
            '.ico',
            '.iff',
            '.ilbc',
            '.image2',
            '.imgut',
            '.ircam',
            '.j2k',
            '.jpeg',
            '.jpg',
            '.jps',
            '.jp2',
            '.jxr',
            '.lcov',
            '.ljpg',
            '.m1v',
            '.m2v',
            '.m4a',
            '.m4v',
            '.matroska',
            '.mgm',
            '.mkv',
            '.mlp',
            '.mmf',
            '.mov',
            '.mp1',
            '.mp2',
            '.mp3',
            '.mp4',
            '.mpc',
            '.mpeg',
            '.mpg',
            '.mpp',
            '.mrs',
            '.msf',
            '.msr',
            '.mvi',
            '.mxf',
            '.nut',
            '.ogg',
            '.ogv',
            '.oma',
            '.opus',
            '.paf',
            '.pbm',
            '.pcx',
            '.pgm',
            '.png',
            '.ps',
            '.psd',
            '.pva',
            '.qcif',
            '.qdm2',
            '.rawvideo',
            '.rc',
            '.redspark',
            '.rl2',
            '.rm',
            '.rmvb',
            '.rso',
            '.rtp',
            '.s24be',
            '.s3m',
            '.sbg',
            '.sdp',
            '.sgi',
            '.smk',
            '.sox',
            '.spx',
            '.sub',
            '.swf',
            '.tak',
            '.tap',
            '.tga',
            '.thp',
            '.tif',
            '.tiff',
            '.trp',
            '.ts',
            '.tta',
            '.txd',
            '.u8',
            '.uyvy',
            '.vc1',
            '.vob',
            '.wav',
            '.webm',
            '.webp',
            '.wma',
            '.wmv',
            '.wtv',
            '.x-flv',
            '.x-matroska',
            '.x-mkv',
            '.x-wav',
            '.xvag',
            '.yuv4mpegpipe'
        )

        # store current location to restore at end of processing
        Microsoft.PowerShell.Management\Push-Location

        Microsoft.PowerShell.Utility\Write-Verbose ('Current working ' +
            'directory stored for later restoration')
    }

    process {

        # validate and expand the directory path
        $expandedPath = GenXdev.FileSystem\Expand-Path "$DirectoryPath\"

        # check if directory exists
        if (-not [System.IO.Directory]::Exists($expandedPath)) {

            Microsoft.PowerShell.Utility\Write-Warning ('Directory not found: ' +
                "'${DirectoryPath}'")

            return
        }

        # change to target directory for file processing
        Microsoft.PowerShell.Management\Set-Location -LiteralPath $expandedPath

        Microsoft.PowerShell.Utility\Write-Verbose ('Changed working ' +
            "directory to: $DirectoryPath")

        # recursively process each file in directory and subdirectories
        Microsoft.PowerShell.Management\Get-ChildItem -File -Recurse |
            Microsoft.PowerShell.Core\ForEach-Object {

                # skip files that don't have a supported media extension
                if ($extensions -notcontains $PSItem.Extension.ToLower()) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Skipping file ' +
                        "with unsupported extension: $($PSItem.Name)")

                    return
                }

                # verify file still exists and is accessible
                if (-not [System.IO.File]::Exists($PSItem.FullName)) {

                    Microsoft.PowerShell.Utility\Write-Warning ('File not found ' +
                        "or not accessible: '$($PSItem.FullName)'")

                    return
                }

                # display file being processed
                Microsoft.PowerShell.Utility\Write-Host ('Processing: ' +
                    "$($PSItem.FullName)") -ForegroundColor Cyan

                # construct paths for old and new subtitle file naming patterns
                $enPathOld = "$($PSItem.FullName).en.srt"

                $nlPathOld = "$($PSItem.FullName).nl.srt"

                $nlPath = [IO.Path]::ChangeExtension($PSItem.FullName, '.nl.srt')

                $enPath = [IO.Path]::ChangeExtension($PSItem.FullName, '.en.srt')

                # determine target language and output path for new subtitle file
                $targetLanguage = [string]::IsNullOrWhiteSpace($languageOut) ?
                    $languageIn : $languageOut

                $langCode = (GenXdev.Helpers\Get-WebLanguageDictionary)[$targetLanguage]

                if ($null -ne $langCode) {

                    $targetLanguage = $langCode
                }

                $newPath = [IO.Path]::ChangeExtension($PSItem.FullName,
                    ".$targetLanguage.srt")

                Microsoft.PowerShell.Utility\Write-Verbose "Target language: '$targetLanguage'"
                Microsoft.PowerShell.Utility\Write-Verbose "Target file path: '$newPath'"

                # handle legacy Dutch subtitle file naming convention
                if ([io.file]::Exists($nlPathOld)) {

                    if ([io.file]::Exists($nlPath)) {

                        $null = Microsoft.PowerShell.Management\Remove-Item `
                            -LiteralPath $nlPathOld `
                            -Force
                    }
                    else {

                        $null = Microsoft.PowerShell.Management\Move-Item `
                            -LiteralPath $nlPathOld `
                            -Destination $nlPath `
                            -Force
                    }
                }

                # handle legacy English subtitle file naming convention
                if ([io.file]::Exists($enPathOld)) {

                    if ([io.file]::Exists($enPath)) {

                        $null = Microsoft.PowerShell.Management\Remove-Item `
                            -LiteralPath $enPathOld `
                            -Force
                    }
                    else {

                        $null = Microsoft.PowerShell.Management\Move-Item `
                            -LiteralPath $enPathOld `
                            -Destination $enPath `
                            -Force
                    }
                }

                # skip if subtitle file already exists for target language
                if ([io.file]::Exists($newPath)) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Subtitle file ' +
                        "already exists: $newPath")

                    return
                }

                try {

                    # reduce CPU priority to minimize system impact during processing
                    [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass =
                        [System.Diagnostics.ProcessPriorityClass]::Idle

                    try {

                        Microsoft.PowerShell.Utility\Write-Verbose ('Generating ' +
                            "transcription for: $($PSItem.FullName)")

                        # prepare parameters for transcription generation
                        $transcriptionParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                            -BoundParameters $PSBoundParameters `
                            -FunctionName 'GenXdev.AI\Start-AudioTranscription'

                        # Add required parameters for SRT generation
                        $transcriptionParams.Input = $PSItem.FullName
                        $transcriptionParams.Srt = $true
                        $transcriptionParams.LanguageIn = $languageIn
                        $transcriptionParams.LanguageOut = $languageOut

                        Microsoft.PowerShell.Utility\Write-Host "  Starting transcription..." -ForegroundColor Yellow
                        Microsoft.PowerShell.Utility\Write-Verbose "Parameters: $($transcriptionParams.Keys -join ', ')"

                        # generate transcription using whisper model
                        $transcription = GenXdev.AI\Start-AudioTranscription @transcriptionParams | Microsoft.PowerShell.Utility\Out-String

                        if ($null -eq $transcription -or [string]::IsNullOrWhiteSpace($transcription)) {
                            Microsoft.PowerShell.Utility\Write-Warning "No transcription generated for $($PSItem.Name)"
                            return
                        }

                        Microsoft.PowerShell.Utility\Write-Host "  Transcription completed successfully" -ForegroundColor Green
                        Microsoft.PowerShell.Utility\Write-Verbose "Transcription length: $($transcription.Length) characters"
                    }
                    finally {

                        # restore normal CPU priority after processing
                        [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass =
                            [System.Diagnostics.ProcessPriorityClass]::Normal
                    }
                }
                catch {

                    Microsoft.PowerShell.Utility\Write-Error "Failed to process file: $($PSItem.FullName)"
                    Microsoft.PowerShell.Utility\Write-Error "Error details: $($_.Exception.Message)"
                    Microsoft.PowerShell.Utility\Write-Verbose "Full error: $_"

                    return
                }

                # save generated transcription to subtitle file
                try {
                    $null = $transcription |
                        Microsoft.PowerShell.Utility\Out-File $newPath -Force -Encoding UTF8

                    Microsoft.PowerShell.Utility\Write-Host "  Saved: $([System.IO.Path]::GetFileName($newPath))" -ForegroundColor Green
                    Microsoft.PowerShell.Utility\Write-Verbose ('Transcription saved ' +
                        "to: $newPath")
                } catch {
                    Microsoft.PowerShell.Utility\Write-Error "Failed to save transcription to: $newPath"
                    Microsoft.PowerShell.Utility\Write-Error "Save error: $($_.Exception.Message)"
                    return
                }
            }
    }

    end {

        # restore original working directory
        Microsoft.PowerShell.Management\Pop-Location

        Microsoft.PowerShell.Utility\Write-Verbose ('Original working ' +
            'directory restored')
    }
}
###############################################################################