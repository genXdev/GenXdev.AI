###############################################################################
<#
.SYNOPSIS
Transcribes an audio or video file to text.

.DESCRIPTION
Transcribes an audio or video file to text using the Whisper AI model. The
function can handle various audio and video formats, convert them to the
appropriate format for transcription, and optionally translate the output
to a different language. Supports SRT subtitle format output and various
audio processing parameters for fine-tuning the transcription quality.

.PARAMETER FilePath
The file path of the audio or video file to transcribe.

.PARAMETER LanguageIn
The language to expect in the audio. E.g. "English", "French", "German", "Dutch"

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

.EXAMPLE
Get-MediaFileAudioTranscription -FilePath "C:\path\to\audio.wav" `
    -LanguageIn "English" -LanguageOut "French" -SRT

.EXAMPLE
transcribefile "C:\video.mp4" "English"
###############################################################################>
function Get-MediaFileAudioTranscription {

    [CmdletBinding()]
    [Alias('transcribefile')]

    param(
        ###########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The file path of the audio or video file to transcribe.'
        )]
        [string] $FilePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'The language to expect in the audio.'
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
        [ValidateRange(0, 100)]
        [float] $Temperature = 0.01,
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
        ###########################################################################
    )

    begin {

        # store PSBoundParameters in a variable to avoid nested function issues
        $MyPSBoundParameters = $PSBoundParameters

        # copy identical parameter values for ai meta language helper function
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $MyPSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -ErrorAction SilentlyContinue)

        # resolve the input language to a standard format
        $LanguageIn = GenXdev.AI\Get-AIMetaLanguage @params -Language $LanguageIn

        # resolve the output language to a standard format
        $LanguageOut = GenXdev.AI\Get-AIMetaLanguage @params -Language $LanguageOut

        # convert maxdurationofsilence to timespan if it's not already
        if ($MyPSBoundParameters.ContainsKey('MaxDurationOfSilence') -and `
            (-not ($MaxDurationOfSilence -is [System.TimeSpan]))) {

            $MaxDurationOfSilence = [System.TimeSpan]::FromSeconds(`
                    $MaxDurationOfSilence)
            $MyPSBoundParameters['MaxDurationOfSilence'] = $MaxDurationOfSilence
        }

        # convert maxduration to timespan if it's not already
        if ($MyPSBoundParameters.ContainsKey('MaxDuration') -and `
            (-not ($MaxDuration -is [System.TimeSpan]))) {

            $MaxDuration = [System.TimeSpan]::FromSeconds($MaxDuration)
            $MyPSBoundParameters['MaxDuration'] = $MaxDuration
        }

        # convert offset to timespan if it's not already
        if ($MyPSBoundParameters.ContainsKey('Offset') -and `
            (-not ($Offset -is [System.TimeSpan]))) {

            $Offset = [System.TimeSpan]::FromSeconds($Offset)
            $MyPSBoundParameters['Offset'] = $Offset
        }

        # convert maxinitialtimestamp to timespan if it's not already
        if ($MyPSBoundParameters.ContainsKey('MaxInitialTimestamp') -and `
            (-not ($MaxInitialTimestamp -is [System.TimeSpan]))) {

            $MaxInitialTimestamp = [System.TimeSpan]::FromSeconds(`
                    $MaxInitialTimestamp)
            $MyPSBoundParameters['MaxInitialTimestamp'] = $MaxInitialTimestamp
        }

        # locate the ffmpeg executable path in winget installation directory
        $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" `
                -File -rec -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Utility\Select-Object -First 1 |
                Microsoft.PowerShell.Core\ForEach-Object FullName)
    }

    process {

        # helper function to check if winget powershell client is installed
        function IsWinGetInstalled {

            # try to import the winget client module
            Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client' `
                -ErrorAction SilentlyContinue

            # check if the module was successfully loaded
            $module = Microsoft.PowerShell.Core\Get-Module `
                'Microsoft.WinGet.Client' -ErrorAction SilentlyContinue

            if ($null -eq $module) {

                return $false
            }

            return $true
        }

        # helper function to install winget powershell client
        function InstallWinGet {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Installing WinGet PowerShell client..'

            # install the winget client module
            PowerShellGet\Install-Module 'Microsoft.WinGet.Client' `
                -Force -AllowClobber

            # import the newly installed module
            Microsoft.PowerShell.Core\Import-Module 'Microsoft.WinGet.Client'
        }

        # helper function to install ffmpeg using winget
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

                Microsoft.PowerShell.Utility\Write-Verbose 'Installing ffmpeg..'

                try {

                    # attempt to install using winget client module
                    Microsoft.WinGet.Client\Install-WinGetPackage -Id $ffmpeg `
                        -Force
                }
                catch {

                    # fallback to winget command line tool
                    winget install $ffmpeg
                }

                # update the ffmpeg path after installation
                $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem `
                        -LiteralPath "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" `
                        -File -rec -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Utility\Select-Object -First 1).FullName
            }
        }

        # ensure ffmpeg is installed before proceeding
        $null = InstallFFmpeg

        # expand the input file path to absolute path
        $inputFile = GenXdev.FileSystem\Expand-Path $FilePath

        # create a temporary wav file for conversion
        $outputFile = [System.IO.Path]::GetTempFileName() + '.wav'

        # inform user about the conversion process
        Microsoft.PowerShell.Utility\Write-Verbose `
        ("Converting the file '$inputFile' to WAV format..")

        # start background job to convert media file to wav format
        $job = Microsoft.PowerShell.Core\Start-Job `
            -ArgumentList $ffmpegPath, $inputFile, $outputFile -ScriptBlock {

            param($ffmpegPath, $inputFile, $outputFile)

            # locate ffmpeg path in case it's not passed correctly
            $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem `
                    -LiteralPath "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" `
                    -File -rec -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Select-Object -First 1 |
                    Microsoft.PowerShell.Core\ForEach-Object FullName)

            try {

                # convert file to wav with specific audio parameters for whisper
                & $ffmpegPath -i "$inputFile" -ac 1 -ar 16000 `
                    -sample_fmt s16 "$outputFile" -loglevel quiet -y
            }
            finally {

                # clear the terminal line to remove ffmpeg output
                [System.Console]::Write("`e[1A`e[2K")
            }

            # return the exit code for success/failure checking
            return $LASTEXITCODE
        }

        # wait for the conversion job to complete
        $null = $job |
            Microsoft.PowerShell.Core\Wait-Job

        # check if the conversion was successful
        $success = ($job |
                Microsoft.PowerShell.Core\Receive-Job) -eq 0

        # clean up the completed job
        $null = Microsoft.PowerShell.Core\Remove-Job -Job $job

        # handle conversion failure
        if (-not $success) {

            Microsoft.PowerShell.Utility\Write-Verbose `
            ("Failed to convert the file '$inputFile' to WAV format.")

            # clean up the temporary file if it exists
            if ([System.IO.File]::Exists($outputFile)) {

                $null = Microsoft.PowerShell.Management\Remove-Item `
                    -LiteralPath $outputFile -Force
            }

            return
        }

        # inform user about the transcription process
        Microsoft.PowerShell.Utility\Write-Verbose `
        ("Transcribing the audio file '$inputFile'..")

        # add language parameter if languagein was specified
        if ($MyPSBoundParameters.ContainsKey('LanguageIn')) {

            $null = $MyPSBoundParameters.Add('Language', $LanguageIn)
        }

        # remove withtranslate parameter if it exists (legacy cleanup)
        if ($MyPSBoundParameters.ContainsKey('WithTranslate')) {

            $null = $MyPSBoundParameters.Remove('WithTranslate', $true)
        }

        # handle srt format parameter dependencies
        if (($SRT -eq $true) -and `
            (-not $MyPSBoundParameters.ContainsKey('PassThru'))) {

            $null = $MyPSBoundParameters.Add('PassThru', $true)
        }
        else {

            if ((-not $SRT) -and $MyPSBoundParameters.ContainsKey('PassThru')) {

                $null = $MyPSBoundParameters.Remove('PassThru')
            }
        }

        # add the converted wav file path to parameters
        if (-not $MyPSBoundParameters.ContainsKey('WaveFile')) {

            $null = $MyPSBoundParameters.Add('WaveFile', $outputFile)
        }

        # ensure error action is set to stop for proper error handling
        if (-not $MyPSBoundParameters.ContainsKey('ErrorAction')) {

            $null = $MyPSBoundParameters.Add('ErrorAction', 'Stop')
        }

        # handle model file path parameter
        if (-not $MyPSBoundParameters.ContainsKey('ModelFilePath')) {

            $null = $MyPSBoundParameters.Add('ModelFilePath', $ModelFilePath)
        }
        else {

            $MyPSBoundParameters['ModelFilePath'] = $ModelFilePath
        }

        # optimize cpu thread usage based on gpu availability
        if (-not (GenXdev.AI\Get-HasCapableGpu)) {

            if (-not $MyPSBoundParameters.ContainsKey('CpuThreads')) {

                $null = $MyPSBoundParameters.Add('CpuThreads', `
                    (GenXdev.AI\Get-NumberOfCpuCores))
            }
        }

        try {

            # check if output should be in srt subtitle format
            if ($SRT) {

                # initialize subtitle counter for srt format
                $i = 1

                # copy parameters for audio transcription function
                $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $MyPSBoundParameters `
                    -FunctionName 'GenXdev.AI\Start-AudioTranscription'

                # process each transcription segment for srt output
                GenXdev.AI\Start-AudioTranscription @invocationArguments |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        $result = $PSItem

                        # check if translation to output language is required
                        if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                            Microsoft.PowerShell.Utility\Write-Verbose `
                            ("Translating text to $LanguageOut for: " +
                                "`"$($result.Text)`"..")

                            try {

                                # prepare parameters for text translation
                                $translateParams = `
                                    GenXdev.Helpers\Copy-IdenticalParamValues `
                                    -BoundParameters $MyPSBoundParameters `
                                    -FunctionName 'GenXdev.AI\Get-TextTranslation' `
                                    -DefaultValues `
                                (Microsoft.PowerShell.Utility\Get-Variable `
                                        -Scope Local -ErrorAction SilentlyContinue)

                                # create new result with translated text
                                $result = @{
                                    Text      = (GenXdev.AI\Get-TextTranslation `
                                            @translateParams -Text:($result.Text) `
                                            -Language:$LanguageOut `
                                            -Instructions ('Translate this partial ' +
                                            'subtitle text, into the [Language] ' +
                                            'language. ommit only the translation ' +
                                            'no yapping or chatting. return in ' +
                                            'json format like so: ' +
                                            "{`"Translation`":`"Translated text " +
                                            "here`"}") |
                                            Microsoft.PowerShell.Utility\ConvertFrom-Json).Translation
                                        Start = $result.Start
                                        End   = $result.End
                                    }

                                    Microsoft.PowerShell.Utility\Write-Verbose `
                                    ("Text translated to: `"$($result.Text)`"..")
                                }
                                catch {

                                    Microsoft.PowerShell.Utility\Write-Verbose `
                                    ("Translating text to $LanguageOut, " +
                                        "failed: $PSItem")
                                }
                            }

                            # format timestamps for srt output
                            $start = $result.Start.ToString('hh\:mm\:ss\,fff', `
                                    [System.Globalization.CultureInfo]::InvariantCulture)
                            $end = $result.end.ToString('hh\:mm\:ss\,fff', `
                                    [System.Globalization.CultureInfo]::InvariantCulture)

                            # output srt formatted subtitle entry
                            "$i`r`n$start --> $end`r`n$($result.Text)`r`n`r`n"

                            # increment subtitle counter
                            $i++
                        }

                # exit early for srt format processing
                return
            }

            # check if translation is needed for non-srt output
            if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                # copy parameters for audio transcription function
                $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $MyPSBoundParameters `
                    -FunctionName 'GenXdev.AI\Start-AudioTranscription'

                # transcribe the audio file to get raw text
                $results = GenXdev.AI\Start-AudioTranscription `
                    @invocationArguments

                # prepare parameters for text translation
                $translateParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $MyPSBoundParameters `
                    -FunctionName 'GenXdev.AI\Get-TextTranslation' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local -ErrorAction SilentlyContinue)

                # translate the complete transcribed text
                GenXdev.AI\Get-TextTranslation @translateParams `
                    -Text "$results" -Language $LanguageOut

                # exit early for translation processing
                return
            }

            # handle standard transcription without translation
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $MyPSBoundParameters `
                -FunctionName 'GenXdev.AI\Start-AudioTranscription'

            # return transcribed text without translation
            GenXdev.AI\Start-AudioTranscription @invocationArguments
        }
        catch {

            # only show error if it's not a user abort
            if ("$PSItem" -notlike '*aborted*') {

                Microsoft.PowerShell.Utility\Write-Error $PSItem
            }
        }
        finally {

            # always clean up temporary files
            if ([System.IO.File]::Exists($outputFile)) {

                $null = Microsoft.PowerShell.Management\Remove-Item `
                    -LiteralPath $outputFile -Force
            }
        }
    }

    end {
    }
}
###############################################################################