################################################################################
<#
.SYNOPSIS
Transcribes an audio or video file to text..

.DESCRIPTION
Transcribes an audio or video file to text using the Whisper AI model

.PARAMETER FilePath
The file path of the audio or video file to transcribe.

.PARAMETER LanguageIn
The language to expect in the audio. E.g. "English", "French", "German", "Dutch"

.PARAMETER LanguageOut
The language to translate to. E.g. "french", "german", "dutch"

.PARAMETER SRT
Output in SRT format.

.PARAMETER PassThru
Returns objects instead of strings.

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input

.PARAMETER TranslateUsingLMStudioModel
The LM Studio model to use for translation.

.PARAMETER MaxSrtChars
The maximum number of characters per line in the SRT output.

.PARAMETER WithTokenTimestamps
Whether to include token timestamps in the output.

.PARAMETER TokenTimestampsSumThreshold
Sum threshold for token timestamps, defaults to 0.5.

.PARAMETER SplitOnWord
Whether to split on word boundaries.

.PARAMETER MaxTokensPerSegment
Maximum number of tokens per segment.

.PARAMETER MaxDurationOfSilence
Maximum duration of silence before automatically stopping recording.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30)

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for speech generation.

.PARAMETER TemperatureInc
Temperature increment.

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

.EXAMPLE
    Get-MediaFileAudioTranscription -FilePath "C:\path\to\audio.wav" -LanguageIn "English" -LanguageOut "French" -SRT
#>
function Get-MediaFileAudioTranscription {
    [CmdletBinding()]
    param (
        ################################################################################
        [Parameter(
            Mandatory,
            Position = 0,
            HelpMessage = "The file path of the audio or video file to transcribe."
        )]
        [string] $FilePath,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The language to expect in the audio, defaults to 'English'."
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
            "Bork, bork, bork!",
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
            "Elmer Fudd",
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
            "Hacker",
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
            "Klingon",
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
            "Pirate",
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
        [string] $LanguageIn = "English",
        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Sets the language to translate to."
        )]
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
            "Bork, bork, bork!",
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
            "Elmer Fudd",
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
            "Hacker",
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
            "Klingon",
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
            "Pirate",
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
        [string]$LanguageOut = $null,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio model to use for translation."
        )]
        [string] $TranslateUsingLMStudioModel = "llama",
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Output in SRT format."
        )]
        [switch] $SRT,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Returns objects instead of strings")]
        [switch] $PassThru,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to use desktop audio capture instead of microphone input")]
        [switch] $UseDesktopAudioCapture,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to include token timestamps in the output")]
        [switch] $WithTokenTimestamps,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Sum threshold for token timestamps, defaults to 0.5")]
        [float] $TokenTimestampsSumThreshold = 0.5,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to split on word boundaries")]
        [switch] $SplitOnWord,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum number of tokens per segment")]
        [int] $MaxTokensPerSegment,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to ignore silence (will mess up timestamps)")]
        [switch] $IgnoreSilence,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of silence before automatically stopping recording")]
        [timespan] $MaxDurationOfSilence,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Silence detect threshold (0..32767 defaults to 30)")]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Number of CPU threads to use, defaults to 0 (auto)")]
        [int] $CpuThreads = 0,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Temperature for speech recognition")]
        [ValidateRange(0, 100)]
        [float] $Temperature = 0.01,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        [float] $TemperatureInc,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Prompt to use for the model")]
        [string] $Prompt,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Regex to suppress tokens from the output")]
        [string] $SuppressRegex = $null,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to show progress")]
        [switch] $WithProgress,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Size of the audio context")]
        [int] $AudioContextSize,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to NOT suppress blank lines")]
        [switch] $DontSuppressBlank,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of the audio")]
        [timespan] $MaxDuration,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Offset for the audio")]
        [timespan] $Offset,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum number of last text tokens")]
        [int] $MaxLastTextTokens,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to use single segment only")]
        [switch] $SingleSegmentOnly,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to print special tokens")]
        [switch] $PrintSpecialTokens,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum segment length")]
        [int] $MaxSegmentLength,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Start timestamps at this moment")]
        [timespan] $MaxInitialTimestamp,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Length penalty")]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Entropy threshold")]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Log probability threshold")]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "No speech threshold")]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Don't use context")]
        [switch] $NoContext,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Use beam search sampling strategy")]
        [switch] $WithBeamSearchSamplingStrategy
    )

    process {

        $MaxSrtChars = [System.Math]::Min(200, [System.Math]::Max(20, $MaxSrtChars))

        $lmsPath = (Get-ChildItem "${env:LOCALAPPDATA}\LM-Studio\lms.exe", "${env:LOCALAPPDATA}\Programs\LM Studio\lms.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

        function IsLMStudioInstalled {

            return Test-Path -Path $lmsPath -ErrorAction SilentlyContinue
        }

        # Function to check if LMStudio is running
        function IsLMStudioRunning {

            $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue
            return $null -ne $process
        }

        function IsWinGetInstalled {

            Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            $module = Get-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue

            if ($null -eq $module) {

                return $false
            }

            return $true
        }

        function InstallWinGet {

            Write-Verbose "Installing WinGet PowerShell client.."
            Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
            Import-Module "Microsoft.WinGet.Client"
        }

        $ffmpegPath = (Get-ChildItem "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object FullName)

        function Installffmpeg {

            if ($null -ne $ffmpegPath) { return }

            if (-not (IsWinGetInstalled)) {

                InstallWinGet
            }

            $ffmpeg = "Gyan.FFmpeg"
            $ffmpegPackage = Get-WinGetPackage -Id $ffmpeg

            if ($null -ne $ffmpegPackage) {

                Write-Verbose "Installing ffmpeg.."
                try {
                    Install-WinGetPackage -Id $ffmpeg -Force
                }
                catch {
                    winget install $ffmpeg
                }
                $ffmpegPath = (Get-ChildItem "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
            }
        }

        # Make sure ffmpeg is installed
        Installffmpeg | Out-Null

        # Replace these paths with your actual file paths
        $inputFile = Expand-Path $FilePath
        $outputFile = [IO.Path]::GetTempFileName() + ".wav";

        # Construct and execute the ffmpeg command
        $job = Start-Job -ArgumentList $ffmpegPath, $inputFile, $outputFile -ScriptBlock {

            param($ffmpegPath, $inputFile, $outputFile)

            try {
                [System.Console]::WriteLine("Converting the file '$inputFile' to WAV format..");
                # Convert the file to WAV format
                & $ffmpegPath -i "$inputFile" -ac 1 -ar 16000 -sample_fmt s16 "$outputFile" -loglevel quiet -y | Out-Null
            }
            finally {
                [System.Console]::Write("`e[1A`e[2K")
            }

            return $LASTEXITCODE
        }

        # Wait for the job to complete and check the result
        $job | Wait-Job | Out-Null
        $success = ($job | Receive-Job) -eq 0
        Remove-Job -Job $job | Out-Null

        if (-not $success) {

            Write-Warning "Failed to convert the file '$inputFile' to WAV format."

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Remove-Item -Path $outputFile -Force | Out-Null
            }

            return
        }

        if (-not $PSBoundParameters.ContainsKey("Language")) {

            $PSBoundParameters.Add("Language", $LanguageIn) | Out-Null;
        }
        else {

            $PSBoundParameters["Language"] = $LanguageIn;
        }

        if ($PSBoundParameters.ContainsKey("WithTranslate")) {

            $PSBoundParameters.Remove("WithTranslate", $true) | Out-Null;
        }

        if (($SRT -eq $true) -and (-not $PSBoundParameters.ContainsKey("PassThru"))) {

            $PSBoundParameters.Add("PassThru", $true) | Out-Null;
        }
        else {

            if ((-not $SRT) -and $PSBoundParameters.ContainsKey("PassThru")) {

                $PSBoundParameters.Remove("PassThru") | Out-Null
            }
        }

        if ($PSBoundParameters.ContainsKey("FilePath")) {

            $PSBoundParameters.Remove("FilePath") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("LanguageIn")) {

            $PSBoundParameters.Remove("LanguageIn") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("LanguageOut")) {

            $PSBoundParameters.Remove("LanguageOut") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("SRT")) {

            $PSBoundParameters.Remove("SRT") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("TranslateUsingLMStudioModel")) {

            $PSBoundParameters.Remove("TranslateUsingLMStudioModel") | Out-Null
        }

        if (-not $PSBoundParameters.ContainsKey("WaveFile")) {

            $PSBoundParameters.Add("WaveFile", $outputFile) | Out-Null;
        }

        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null;
        }

        if (-not $PSBoundParameters.ContainsKey("ModelFilePath")) {

            $PSBoundParameters.Add("ModelFilePath", $ModelFilePath) | Out-Null;
        }
        else {

            $PSBoundParameters["ModelFilePath"] = $ModelFilePath;
        }

        if ([string]::IsNullOrWhiteSpace($LanguageIn)) {

            $LanguageIn = "English"
        }

        if (-not $PSBoundParameters.ContainsKey("Language")) {

            $PSBoundParameters.Add("Language", $LanguageIn) | Out-Null;
        }
        else {

            $PSBoundParameters["Language"] = $LanguageIn;
        }

        if (-not (Get-HasCapableGpu)) {

            if (-not $PSBoundParameters.ContainsKey("CpuThreads")) {

                $PSBoundParameters.Add("CpuThreads", (Get-NumberOfCpuCores)) | Out-Null;
            }
        }

        try {

            # outputting in SRT format?
            if ($SRT) {

                # initialize srt counter
                $i = 1

                Start-AudioTranscription @PSBoundParameters | ForEach-Object {

                    $result = $PSItem;

                    # needs translation?
                    if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                        Write-Verbose "Translating text to $LanguageOut for: `"$($result.Text)`".."

                        try {
                            # translate the text
                            $result = @{
                                Text  = (Get-TextTranslation -Text:($result.Text) -Language:$LanguageOut -Model:$TranslateUsingLMStudioModel -Instructions "Translate this partial subtitle text, into the [Language] language. ommit only the translation no yapping or chatting. return in json format like so: {`"Translation`":`"Translated text here`"}" | ConvertFrom-Json).Translation;
                                Start = $result.Start;
                                End   = $result.End;
                            }

                            Write-Verbose "Text translated to: `"$($result.Text)`".."
                        }
                        catch {

                            Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
                        }
                    }

                    $start = $result.Start.ToString("hh\:mm\:ss\,fff", [CultureInfo]::InvariantCulture);
                    $end = $result.end.ToString("hh\:mm\:ss\,fff", [CultureInfo]::InvariantCulture);

                    "$i`r`n$start --> $end`r`n$($result.Text)`r`n`r`n"

                    # increment the counter
                    $i++
                }

                # end of SRT format
                return;
            }

            #  needs translation?
            if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                # transcribe the audio file to text
                $results = Start-AudioTranscription @PSBoundParameters

                # delegate
                Get-TextTranslation -Text "$results" -Language $LanguageOut -Model $TranslateUsingLMStudioModel

                # end of translation
                return;
            }

            # return the text results without translation
            Start-AudioTranscription @PSBoundParameters
        }
        catch {

            if ("$PSItem" -notlike "*aborted*") {

                Write-Error $PSItem
            }
        }
        finally {

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Remove-Item -Path $outputFile -Force
            }
        }
    }
}
