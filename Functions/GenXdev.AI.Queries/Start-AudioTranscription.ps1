<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Start-AudioTranscription.ps1
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
Transcribes an audio file, video file, or a recording device to text

.DESCRIPTION
Transcribes an audio file, video file, or a recording device to text using
the Whisper AI model. The function can handle various audio and video formats,
convert them to the appropriate format for transcription, and optionally
translate the output to a different language. Supports SRT subtitle format
output and various audio processing parameters for fine-tuning the
transcription quality.

.PARAMETER Input
The file path of the audio or video file to transcribe. Accepts FileInfo
objects or file paths from pipeline. If not provided, records from microphone.

.PARAMETER AudioDevice
Audio device name or GUID (supports wildcards, picks first match).

.PARAMETER LanguageIn
The language to expect in the audio. E.g. "English", "French", "German",
"Dutch"

.PARAMETER LanguageOut
The language to translate to. E.g. "french", "german", "dutch"

.PARAMETER WithTokenTimestamps
Whether to include token timestamps in the output.

.PARAMETER TokenTimestampsSumThreshold
Sum threshold for token timestamps, defaults to 0.5.

.PARAMETER SplitOnWord
Whether to split on word boundaries.

.PARAMETER MaxTokensPerSegment
Maximum number of tokens per segment.

.PARAMETER IgnoreSilence
Whether to ignore silence (will mess up timestamps).

.PARAMETER MaxDurationOfSilence
Maximum duration of silence before automatically stopping recording.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30)

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

.PARAMETER WithProgress
Whether to show progress.

.PARAMETER AudioContextSize
Size of the audio context.

.PARAMETER DontSuppressBlank
Whether to NOT suppress blank lines.

.PARAMETER MaxDuration
Maximum duration of the audio.

.PARAMETER Offset
Offset for the audio.

.PARAMETER MaxLastTextTokens
Maximum number of last text tokens.

.PARAMETER SingleSegmentOnly
Whether to use single segment only.

.PARAMETER PrintSpecialTokens
Whether to print special tokens.

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

.PARAMETER NoContext
Don't use context.

.PARAMETER WithBeamSearchSamplingStrategy
Use beam search sampling strategy.

.PARAMETER ModelType
Whisper model type to use, defaults to LargeV3Turbo.

.PARAMETER SRT
Output in SRT format.

.PARAMETER PassThru
Returns objects instead of strings.

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input

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

.PARAMETER VOX
Use silence detection to automatically stop recording

.EXAMPLE
Start-AudioTranscription -Input "C:\path\to\audio.wav" `
    -LanguageIn "English" -LanguageOut "French" -SRT

.EXAMPLE
transcribefile "C:\video.mp4" "English"

.EXAMPLE
Get-ChildItem "*.mp4" | Start-AudioTranscription -LanguageIn "English"

.EXAMPLE
Start-AudioTranscription  # Records from microphone when no file specified
###############################################################################>
function Start-AudioTranscription {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('transcribefile', 'transcribe')]

    param(
        ###########################################################################
        [Alias("WaveFile", "FilePath", "MediaFile")]
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'The file path of the audio or video file to transcribe. If not provided, records from microphone.'
        )]
        [object] $Input,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio device name or GUID (supports wildcards, picks first match)'
        )]
        [string] $AudioDevice,
        ###########################################################################
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
        [string] $LanguageOut = $null,
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
        [int] $MaxTokensPerSegment,
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
            HelpMessage = 'Output in SRT format.'
        )]
        [switch] $SRT,
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
            HelpMessage = "Use both desktop and recording device"
        )]
        [switch] $UseDesktopAndRecordingDevice,
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
        [switch] $SkipSession,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use silence detection to automatically stop recording'
        )]
        [switch] $VOX
    )

    begin {

        # store PSBoundParameters in a variable to avoid nested function issues
        $myPSBoundParameters = $PSBoundParameters

        # configure voice activation detection (VOX) settings
        if ($VOX -eq $true) {

            # output vox configuration message for verbose logging
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Configuring VOX settings'
            )

            # set default max duration of silence for vox
            if (-not $myPSBoundParameters.ContainsKey('MaxDurationOfSilence')) {

                $null = $myPSBoundParameters.Add(
                    'MaxDurationOfSilence',
                    [System.TimeSpan]::FromSeconds(4)
                )
            }
            else {
                $myPSBoundParameters['MaxDurationOfSilence'] = (
                    [System.TimeSpan]::FromSeconds(4)
                )
            }

            # # enable ignore silence for vox mode
            # if (-not $myPSBoundParameters.ContainsKey('IgnoreSilence')) {

            #     $null = $myPSBoundParameters.Add('IgnoreSilence', $true)
            # }
            # else {
            #     $myPSBoundParameters['IgnoreSilence'] = $true
            # }

            # remove vox parameter as it's processed
            if ($myPSBoundParameters.ContainsKey('VOX')) {

                $null = $myPSBoundParameters.Remove('VOX')
            }
        }

        # determine if translation should be performed based on user intent
        # only translate when languageout parameter is explicitly provided by user
        # and it's different from languagein
        if ($PSBoundParameters.ContainsKey('LanguageOut') -and `
            ($LanguageIn -ne $LanguageOut)) {

            $skipTranslation = $false
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Translation enabled: LanguageOut parameter provided and ' +
                'differs from LanguageIn'
            )
        }
        else {

            $skipTranslation = $true
            if ($PSBoundParameters.ContainsKey('LanguageOut')) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Translation skipped: LanguageIn and LanguageOut are " +
                    "identical ('${LanguageIn}')"
                )
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Translation skipped: LanguageOut parameter not provided'
                )
            }
        }

        # copy identical parameter values for ai meta language helper function
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $myPSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -ErrorAction SilentlyContinue)

        # resolve the input language to a standard format
        if (-not [string]::IsNullOrWhiteSpace($LanguageIn)) {

            $LanguageIn = GenXdev.AI\Get-AIMetaLanguage @params `
                -Language $LanguageIn
        }
        else {

            $LanguageIn = GenXdev.AI\Get-AIMetaLanguage @params
        }

        # resolve the output language to a standard format (only if translation is needed)
        if (-not $skipTranslation) {

            if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                try {

                    $LanguageOut = GenXdev.AI\Get-AIMetaLanguage @params `
                        -Language $LanguageOut
                }
                catch {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to resolve LanguageOut '$LanguageOut': $PSItem"
                    )
                    $skipTranslation = $true
                }
            }
        }

        # convert maxdurationofsilence to timespan if it's not already
        if ($myPSBoundParameters.ContainsKey('MaxDurationOfSilence') -and `
            (-not ($MaxDurationOfSilence -is [System.TimeSpan]))) {

            $MaxDurationOfSilence = [System.TimeSpan]::FromSeconds(
                $MaxDurationOfSilence
            )
            $myPSBoundParameters['MaxDurationOfSilence'] = $MaxDurationOfSilence
        }

        # convert maxduration to timespan if it's not already
        if ($myPSBoundParameters.ContainsKey('MaxDuration') -and `
            (-not ($MaxDuration -is [System.TimeSpan]))) {

            $MaxDuration = [System.TimeSpan]::FromSeconds($MaxDuration)
            $myPSBoundParameters['MaxDuration'] = $MaxDuration
        }

        # convert offset to timespan if it's not already
        if ($myPSBoundParameters.ContainsKey('Offset') -and `
            (-not ($Offset -is [System.TimeSpan]))) {

            $Offset = [System.TimeSpan]::FromSeconds($Offset)
            $myPSBoundParameters['Offset'] = $Offset
        }

        # convert maxinitialtimestamp to timespan if it's not already
        if ($myPSBoundParameters.ContainsKey('MaxInitialTimestamp') -and `
            (-not ($MaxInitialTimestamp -is [System.TimeSpan]))) {

            $MaxInitialTimestamp = [System.TimeSpan]::FromSeconds(
                $MaxInitialTimestamp
            )
            $myPSBoundParameters['MaxInitialTimestamp'] = $MaxInitialTimestamp
        }

        # locate the ffmpeg executable path in winget installation directory
        # try multiple possible locations for ffmpeg
        $ffmpegPath = $null

        # first try the symlink location (fastest approach)
        $symlinkPath = "${env:LOCALAPPDATA}\Microsoft\WinGet\Links\ffmpeg.exe"
        if ([System.IO.File]::Exists($symlinkPath)) {

            $ffmpegPath = $symlinkPath
        }

        # fallback to recursive search in winget directory
        if ([string]::IsNullOrEmpty($ffmpegPath)) {

            $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem `
                    -LiteralPath "${env:LOCALAPPDATA}\Microsoft\WinGet" `
                    -Filter "ffmpeg.exe" `
                    -Recurse -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Select-Object -First 1 |
                    Microsoft.PowerShell.Core\ForEach-Object FullName)
        }

        # initialize script-scope variables for input tracking
        $script:InputProvided = $false

        # add language parameter if languagein was specified
        if ($myPSBoundParameters.ContainsKey('LanguageIn')) {

            $null = $myPSBoundParameters.Add('Language', $LanguageIn)
        }

        # remove withtranslate parameter if it exists (legacy cleanup)
        if ($myPSBoundParameters.ContainsKey('WithTranslate')) {

            $null = $myPSBoundParameters.Remove('WithTranslate', $true)
        }

        # handle srt format parameter dependencies
        if (($SRT -eq $true) -and `
            (-not $myPSBoundParameters.ContainsKey('PassThru'))) {

            $null = $myPSBoundParameters.Add('PassThru', $true)
        }
        else {

            if ((-not $SRT) -and $myPSBoundParameters.ContainsKey('PassThru')) {

                $null = $myPSBoundParameters.Remove('PassThru')
            }
        }

        # ensure error action is set to stop for proper error handling
        # if (-not $myPSBoundParameters.ContainsKey('ErrorAction')) {

        #     $null = $myPSBoundParameters.Add('ErrorAction', 'Stop')
        # }

        # set cpu threads if not specified by user
        if (-not $myPSBoundParameters.ContainsKey('CpuThreads')) {

            $null = $myPSBoundParameters.Add('CpuThreads', `
                (GenXdev.AI\Get-NumberOfCpuCores))
        }
    }

    process {

        # collect input items from both parameter and pipeline
        $inputItems = @()

        # first, check if input parameter was provided
        if ($myPSBoundParameters.ContainsKey('Input')) {

            $inputItems += $myPSBoundParameters['Input']
        }

        # then, collect any pipeline input
        $Input |
            Microsoft.PowerShell.Core\ForEach-Object {

                $inputItems += $PSItem
            }

        # process each input item
        $inputItems |
            Microsoft.PowerShell.Core\ForEach-Object {

                $currentInput = $PSItem

                # convert input to file path based on object type
                $filePathString = if ($currentInput -is [string] -and `
                    -not [string]::IsNullOrWhiteSpace($currentInput)) {

                    GenXdev.FileSystem\Expand-Path $currentInput
                }
                elseif ($currentInput -is [System.IO.FileInfo]) {

                    $currentInput.FullName
                }
                elseif ($currentInput -and `
                    $currentInput.PSObject.Properties['FullName']) {

                    $currentInput.FullName
                }
                elseif ($currentInput -and `
                    $currentInput.PSObject.Properties['Path']) {

                    GenXdev.FileSystem\Expand-Path $currentInput.Path
                }
                else {

                    $null
                }

                # skip if no valid file path
                if ([string]::IsNullOrWhiteSpace($filePathString)) {

                    return
                }

                # mark that we have input, user does not want to record
                $script:InputProvided = $true

                # check if file exists
                if (-not [System.IO.File]::Exists($filePathString)) {

                    Microsoft.PowerShell.Utility\Write-Warning (
                        "File not found: '${filePathString}'"
                    )
                    return
                }

                # define helper function to check if winget powershell client is installed
                function IsWinGetInstalled {

                    # try to import the winget client module
                    Microsoft.PowerShell.Core\Import-Module `
                        'Microsoft.WinGet.Client' `
                        -ErrorAction SilentlyContinue

                    # check if the module was successfully loaded
                    $moduleObj = Microsoft.PowerShell.Core\Get-Module `
                        'Microsoft.WinGet.Client' -ErrorAction SilentlyContinue

                    if ($null -eq $moduleObj) {

                        return $false
                    }

                    return $true
                }

                # define helper function to install winget powershell client
                function InstallWinGet {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'Installing WinGet PowerShell client..'

                    # check for installation consent before proceeding
                    $consent = GenXdev.FileSystem\Confirm-InstallationConsent `
                        -ApplicationName 'Microsoft.WinGet.Client' `
                        -Source 'PowerShell Gallery' `
                        -Description 'PowerShell module for WinGet package management, required for automated FFmpeg installation' `
                        -Publisher 'Microsoft'

                    if (-not $consent) {
                        throw 'Installation consent denied for Microsoft.WinGet.Client module. Cannot proceed with automatic package installation.'
                    }

                    # install the winget client module
                    PowerShellGet\Install-Module 'Microsoft.WinGet.Client' `
                        -Force -AllowClobber

                    # import the newly installed module
                    Microsoft.PowerShell.Core\Import-Module `
                        'Microsoft.WinGet.Client'
                }

                # define helper function to install ffmpeg using winget
                function InstallFFmpeg {

                    # check if ffmpeg is already installed
                    if ([System.IO.File]::Exists($ffmpegPath)) {

                        return
                    }

                    # ensure winget is installed before proceeding
                    if (-not (IsWinGetInstalled)) {

                        InstallWinGet
                    }

                    # define the ffmpeg package identifier
                    $ffmpeg = 'Gyan.FFmpeg'

                    # check if ffmpeg package is available
                    $ffmpegPackage = Microsoft.WinGet.Client\Get-WinGetPackage `
                        -Id $ffmpeg

                    # install ffmpeg if not found
                    if ($null -eq $ffmpegPackage) {

                        Microsoft.PowerShell.Utility\Write-Verbose `
                            'Installing ffmpeg..'

                        # check for installation consent before proceeding
                        $consent = GenXdev.FileSystem\Confirm-InstallationConsent `
                            -ApplicationName 'FFmpeg' `
                            -Source 'WinGet' `
                            -Description 'Audio/video processing library required for converting media files to formats compatible with speech recognition' `
                            -Publisher 'Gyan'

                        if (-not $consent) {
                            throw 'Installation consent denied for FFmpeg. Cannot proceed with media file conversion for transcription.'
                        }

                        try {

                            # attempt to install using winget client module
                            Microsoft.WinGet.Client\Install-WinGetPackage `
                                -Id $ffmpeg `
                                -Force
                        }
                        catch {

                            # fallback to winget command line tool
                            winget install $ffmpeg
                        }

                        # update the ffmpeg path after installation
                        # try multiple possible locations for ffmpeg
                        $ffmpegPath = $null

                        # first try the symlink location (fastest)
                        $symlinkPath = (
                            "${env:LOCALAPPDATA}\Microsoft\WinGet\Links\ffmpeg.exe"
                        )
                        if ([System.IO.File]::Exists($symlinkPath)) {

                            $ffmpegPath = $symlinkPath
                        }

                        # fallback to recursive search in winget directory
                        if ([string]::IsNullOrEmpty($ffmpegPath)) {

                            $ffmpegPath = (
                                Microsoft.PowerShell.Management\Get-ChildItem `
                                    -Path "${env:LOCALAPPDATA}\Microsoft\WinGet" `
                                    -Filter "ffmpeg.exe" `
                                    -Recurse -ErrorAction SilentlyContinue |
                                    Microsoft.PowerShell.Utility\Select-Object `
                                        -First 1 |
                                    Microsoft.PowerShell.Core\ForEach-Object `
                                        FullName
                            )
                        }
                    }
                }

                # ensure ffmpeg is installed before proceeding
                $null = InstallFFmpeg

                # expand the input file path to absolute path
                $inputFile = GenXdev.FileSystem\Expand-Path $filePathString

                # create a temporary wav file for conversion
                $outputFile = [System.IO.Path]::GetTempFileName() + '.wav'

                # inform user about the conversion process
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Converting the file '$inputFile' to WAV format.."
                )

                # locate ffmpeg path in case it's not passed correctly
                # try multiple possible locations for ffmpeg
                if ([string]::IsNullOrEmpty($ffmpegPath)) {

                    # first try the symlink location (fastest)
                    $symlinkPath = (
                        "${env:LOCALAPPDATA}\Microsoft\WinGet\Links\ffmpeg.exe"
                    )
                    if ([System.IO.File]::Exists($symlinkPath)) {

                        $ffmpegPath = $symlinkPath
                    }

                    # fallback to recursive search in winget directory
                    if ([string]::IsNullOrEmpty($ffmpegPath)) {

                        $ffmpegPath = (
                            Microsoft.PowerShell.Management\Get-ChildItem `
                                -Path "${env:LOCALAPPDATA}\Microsoft\WinGet" `
                                -Filter "ffmpeg.exe" `
                                -Recurse -ErrorAction SilentlyContinue |
                                Microsoft.PowerShell.Utility\Select-Object `
                                    -First 1 |
                                Microsoft.PowerShell.Core\ForEach-Object `
                                    FullName
                        )
                    }
                }

                # convert file to wav with specific audio parameters for whisper
                & $ffmpegPath -i "$inputFile" -ac 1 -ar 16000 `
                    -sample_fmt s16 "$outputFile" -loglevel quiet -y

                # check if the conversion was successful
                $success = $LASTEXITCODE -eq 0

                # handle conversion failure
                if (-not $success) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to convert the file '$inputFile' to WAV format."
                    )

                    # clean up the temporary file if it exists
                    if ([System.IO.File]::Exists($outputFile)) {

                        $null = Microsoft.PowerShell.Management\Remove-Item `
                            -LiteralPath $outputFile -Force
                    }

                    return
                }

                # inform user about the transcription process
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing audio file: " +
                    "$(GenXdev.FileSystem\Find-Item $inputFile -NoRecurse)"
                )

                # check if modeltype was not explicitly set by user
                if (-not $myPSBoundParameters.ContainsKey("ModelType")) {

                    # use most accurate model for batch processing
                    $ModelType = 'LargeV3Turbo'

                    # add modeltype to bound parameters for downstream functions
                    $null = $myPSBoundParameters.Add('ModelType', $ModelType)
                }

                # set the input file for the transcription engine
                $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $myPSBoundParameters `
                    -FunctionName  'GenXdev.Helpers\Get-SpeechToText'

                # set language using the resolved language format
                if ($PSBoundParameters.ContainsKey("LanguageIn")) {
                    $invocationArguments.LanguageIn = (
                        GenXdev.Helpers\Get-WebLanguageDictionary
                    )[$LanguageIn]
                } else {
                    if ($invocationArguments.ContainsKey("LanguageIn")) {
                        $null = $invocationArguments.Remove("LanguageIn")
                    }
                }

                if ($LanguageOut -eq "English") {

                    $invocationArguments.WithTranslate = $true;
                    $skipTranslation = $true;
                }

                $invocationArguments.Input = $outputFile

                try {
                    # add shouldprocess check before executing the operation
                    if (-not $PSCmdlet.ShouldProcess(
                            "Start processing file '$outputFile'", 'Start'
                        )) {

                        continue
                    }

                    # check if output should be in srt subtitle format
                    if ($SRT) {

                        # initialize subtitle counter for srt format
                        $i = 1

                        GenXdev.Helpers\Get-SpeechToText `
                            @invocationArguments |
                            Microsoft.PowerShell.Core\ForEach-Object  {

                                $result = $PSItem

                                # check if translation to output language is required
                                if (-not [string]::IsNullOrWhiteSpace($LanguageOut) `
                                    -and -not $skipTranslation) {

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Translating text to $LanguageOut for: " +
                                        "`"$($result.Text)`".."
                                    )

                                    try {

                                        # prepare parameters for text translation
                                        $translateParams = `
                                            GenXdev.Helpers\Copy-IdenticalParamValues `
                                            -BoundParameters $myPSBoundParameters `
                                            -FunctionName `
                                                'GenXdev.AI\Get-TextTranslation'

                                        if ($translateParams.ContainsKey('Prompt')) {
                                            $null = $translateParams.Remove('Prompt')
                                        }
                                        if ($translateParams.ContainsKey('Instructions')) {
                                            $null = $translateParams.Remove('Instructions')
                                        }

                                        # create new result with translated text
                                        $result = @{
                                            Text = (GenXdev.AI\Get-TextTranslation `
                                                    @translateParams `
                                                    -Text:($result.Text) `
                                                    -Language:$LanguageOut
                                                )
                                            Start = $result.Start
                                            End   = $result.End
                                        }

                                        Microsoft.PowerShell.Utility\Write-Verbose (
                                            "Text translated to: " +
                                            "`"$($result.Text)`".."
                                        )
                                    }
                                    catch {

                                        Microsoft.PowerShell.Utility\Write-Verbose (
                                            "Translating text to $LanguageOut, " +
                                            "failed: $PSItem"
                                        )
                                    }
                                }

                                # format timestamps for srt output
                                $start = $result.Start.ToString(
                                    'hh\:mm\:ss\,fff',
                                    [System.Globalization.CultureInfo]::InvariantCulture
                                )
                                $end = $result.end.ToString(
                                    'hh\:mm\:ss\,fff',
                                    [System.Globalization.CultureInfo]::InvariantCulture
                                )

                                # return srt formatted subtitle entry to pipeline
                                Microsoft.PowerShell.Utility\Write-Output "$i`r`n$start --> $end`r`n$($result.Text)`r`n`r`n"

                                # increment subtitle counter
                                $i++
                            }

                        # exit early for srt format processing
                        return
                    }

                    # check if translation is needed for non-srt output
                    if (-not [string]::IsNullOrWhiteSpace($LanguageOut) `
                        -and -not $skipTranslation) {

                        # transcribe the audio file to get raw text
                        $results =  GenXdev.Helpers\Get-SpeechToText @invocationArguments

                        # prepare parameters for text translation
                        $translateParams = `
                            GenXdev.Helpers\Copy-IdenticalParamValues `
                            -BoundParameters $myPSBoundParameters `
                            -FunctionName 'GenXdev.AI\Get-TextTranslation'

                        if ($translateParams.ContainsKey('Prompt')) {
                            $null = $translateParams.Remove('Prompt')
                        }
                        if ($translateParams.ContainsKey('Instructions')) {
                            $null = $translateParams.Remove('Instructions')
                        }

                        # translate the complete transcribed text and return result
                        $translationResult = GenXdev.AI\Get-TextTranslation `
                            @translateParams `
                            -Text "$results" -Language $LanguageOut

                        # return the translation result
                        return $translationResult
                    }

                    GenXdev.Helpers\Get-SpeechToText @invocationArguments
                }
                catch {

                    # only show error if it's not a user abort
                    if ($PSItem.Exception.Message -notlike '*aborted*') {

                        Microsoft.PowerShell.Utility\Write-Error $PSItem
                    }
                }
                finally {

                    # always clean up temporary files
                    if ([System.IO.File]::Exists($outputFile)) {

                        $null = Microsoft.PowerShell.Management\Remove-Item `
                            -LiteralPath $outputFile -Force -ErrorAction SilentlyContinue
                    }
                }
            }
    }

    end {

        # if no input was provided, start recording from microphone
        if (-not $script:InputProvided) {

            # add shouldprocess check before executing the operation
            if (-not $PSCmdlet.ShouldProcess(
                    "Start recording", 'Start'
                )) {

                continue
            }

            if (-not $myPSBoundParameters.ContainsKey("ModelType")) {

                # use most accurate model for batch processing
                $ModelType = 'tiny'

                # add modeltype to bound parameters for downstream functions
                $null = $myPSBoundParameters.Add('ModelType', $ModelType)
            }

            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $myPSBoundParameters `
                -FunctionName 'GenXdev.Helpers\Receive-RealTimeSpeechToText'

            # set language using the resolved language format
            if ($PSBoundParameters.ContainsKey("LanguageIn")) {
                $invocationArguments.LanguageIn = (
                        GenXdev.Helpers\Get-WebLanguageDictionary
                    )[$LanguageIn]
            } else {
                if ($invocationArguments.ContainsKey("LanguageIn")) {
                    $null = $invocationArguments.Remove("LanguageIn")
                }
            }

            if ($LanguageOut -eq "English") {

                $invocationArguments.WithTranslate = $true;
                $skipTranslation = $true;
            }

            # check if output should be in srt subtitle format
            if ($SRT) {

                # initialize subtitle counter for srt format
                $i = 1

                GenXdev.Helpers\Receive-RealTimeSpeechToText `
                    @invocationArguments |
                    Microsoft.PowerShell.Core\ForEach-Object  {

                        $result = $PSItem

                        # check if translation to output language is required
                        if (-not [string]::IsNullOrWhiteSpace($LanguageOut) `
                            -and -not $skipTranslation) {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Translating text to $LanguageOut for: " +
                                "`"$($result.Text)`".."
                            )

                            try {

                                # prepare parameters for text translation
                                $translateParams = `
                                    GenXdev.Helpers\Copy-IdenticalParamValues `
                                    -BoundParameters $myPSBoundParameters `
                                    -FunctionName `
                                        'GenXdev.AI\Get-TextTranslation'

                                if ($translateParams.ContainsKey('Prompt')) {
                                    $null = $translateParams.Remove('Prompt')
                                }
                                if ($translateParams.ContainsKey('Instructions')) {
                                    $null = $translateParams.Remove('Instructions')
                                }

                                # create new result with translated text
                                $result = @{
                                    Text = (GenXdev.AI\Get-TextTranslation `
                                            @translateParams `
                                            -Text:($result.Text) `
                                            -Language:$LanguageOut
                                        )
                                    Start = $result.Start
                                    End   = $result.End
                                }

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "Text translated to: " +
                                    "`"$($result.Text)`".."
                                )
                            }
                            catch {

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "Translating text to $LanguageOut, " +
                                    "failed: $PSItem"
                                )
                            }
                        }

                        # format timestamps for srt output
                        $start = $result.Start.ToString(
                            'hh\:mm\:ss\,fff',
                            [System.Globalization.CultureInfo]::InvariantCulture
                        )
                        $end = $result.end.ToString(
                            'hh\:mm\:ss\,fff',
                            [System.Globalization.CultureInfo]::InvariantCulture
                        )

                        # return srt formatted subtitle entry to pipeline
                        Microsoft.PowerShell.Utility\Write-Output "$i`r`n$start --> $end`r`n$($result.Text)`r`n`r`n"

                        # increment subtitle counter
                        $i++
                    }

                # exit early for srt format processing
                return
            }

            # check if translation is needed for microphone recording output
            if (-not [string]::IsNullOrWhiteSpace($LanguageOut) `
                -and -not $skipTranslation) {

                # prepare parameters for text translation
                $translateParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $myPSBoundParameters `
                    -FunctionName 'GenXdev.AI\Get-TextTranslation'

                if ($translateParams.ContainsKey('Prompt')) {
                    $null = $translateParams.Remove('Prompt')
                }
                if ($translateParams.ContainsKey('Instructions')) {
                    $null = $translateParams.Remove('Instructions')
                }

                # transcribe the microphone recording to get raw text
                GenXdev.Helpers\Receive-RealTimeSpeechToText @invocationArguments | Microsoft.PowerShell.Core\ForEach-Object {

                    # translate the complete transcribed text and return result
                    GenXdev.AI\Get-TextTranslation `
                        @translateParams `
                        -Text "$PSItem" -Language $LanguageOut
                }
                return
            }

            GenXdev.Helpers\Receive-RealTimeSpeechToText @invocationArguments
        }
    }
}
###############################################################################