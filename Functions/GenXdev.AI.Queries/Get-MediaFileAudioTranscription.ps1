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
    [Alias("transcribefile")]
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
            HelpMessage = "The language to expect in the audio."
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
        [SupportsWildcards()]
        [string] $TranslateUsingLMStudioModel = "qwen",
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
        [object] $MaxDurationOfSilence,
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
        [object] $MaxDuration,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Offset for the audio")]
        [object] $Offset,
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
        [object] $MaxInitialTimestamp,
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

    begin {

        if ([string]::IsNullOrWhiteSpace($LanguageIn)) {

            # get default language from system settings
            $LanguageIn = GenXdev.Helpers\Get-DefaultWebLanguage
        }

        if ($PSBoundParameters.ContainsKey("MaxDurationOfSilence") -and (-not ($MaxDurationOfSilence -is [System.TimeSpan]))) {

            $MaxDurationOfSilence = [System.TimeSpan]::FromSeconds($MaxDurationOfSilence)
            $PSBoundParameters["MaxDurationOfSilence"] = $MaxDurationOfSilence
        }

        if ($PSBoundParameters.ContainsKey("MaxDuration") -and (-not ($MaxDuration -is [System.TimeSpan]))) {

            $MaxDuration = [System.TimeSpan]::FromSeconds($MaxDuration)
            $PSBoundParameters["MaxDuration"] = $MaxDuration
        }

        if ($PSBoundParameters.ContainsKey("Offset") -and (-not ($Offset -is [System.TimeSpan]))) {

            $Offset = [System.TimeSpan]::FromSeconds($Offset)
            $PSBoundParameters["Offset"] = $Offset
        }

        if ($PSBoundParameters.ContainsKey("MaxInitialTimestamp") -and (-not ($MaxInitialTimestamp -is [System.TimeSpan]))) {

            $MaxInitialTimestamp = [System.TimeSpan]::FromSeconds($MaxInitialTimestamp)
            $PSBoundParameters["MaxInitialTimestamp"] = $MaxInitialTimestamp
        }

        $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object -First 1 | Microsoft.PowerShell.Core\ForEach-Object FullName)
    }


process {

        $MaxSrtChars = [System.Math]::Min(200, [System.Math]::Max(20, $MaxSrtChars))

        function IsWinGetInstalled {
            Microsoft.PowerShell.Core\Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            $module = Microsoft.PowerShell.Core\Get-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            if ($null -eq $module) {
                return $false
            }
            return $true
        }

        function InstallWinGet {

            Microsoft.PowerShell.Utility\Write-Verbose "Installing WinGet PowerShell client.."
            PowerShellGet\Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
            Microsoft.PowerShell.Core\Import-Module "Microsoft.WinGet.Client"
        }

        function Installffmpeg {

            if ([IO.File]::Exists($ffmpegPath)) { return }

            if (-not (IsWinGetInstalled)) {

                InstallWinGet
            }

            $ffmpeg = "Gyan.FFmpeg"
            $ffmpegPackage = Microsoft.WinGet.Client\Get-WinGetPackage -Id $ffmpeg

            if ($null -eq $ffmpegPackage) {

                Microsoft.PowerShell.Utility\Write-Verbose "Installing ffmpeg.."
                try {
                    Microsoft.WinGet.Client\Install-WinGetPackage -Id $ffmpeg -Force
                }
                catch {
                    winget install $ffmpeg
                }
                $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object -First 1).FullName
            }
        }

        # Make sure ffmpeg is installed
        Installffmpeg | Microsoft.PowerShell.Core\Out-Null

        # Replace these paths with your actual file paths
        $inputFile = GenXdev.FileSystem\Expand-Path $FilePath
        $outputFile = [IO.Path]::GetTempFileName() + ".wav";

        # Construct and execute the ffmpeg command
        Microsoft.PowerShell.Utility\Write-Verbose "Converting the file '$inputFile' to WAV format.."

        $job = Microsoft.PowerShell.Core\Start-Job -ArgumentList $ffmpegPath, $inputFile, $outputFile -ScriptBlock {

            param($ffmpegPath, $inputFile, $outputFile)

            $ffmpegPath = (Microsoft.PowerShell.Management\Get-ChildItem "${env:LOCALAPPDATA}\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object -First 1 | Microsoft.PowerShell.Core\ForEach-Object FullName)
            try {
                # Convert the file to WAV format
                & $ffmpegPath -i "$inputFile" -ac 1 -ar 16000 -sample_fmt s16 "$outputFile" -loglevel quiet -y | Microsoft.PowerShell.Core\Out-Null
            }
            finally {
                [System.Console]::Write("`e[1A`e[2K")
            }

            return $LASTEXITCODE
        }

        # Wait for the job to complete and check the result
        $job | Microsoft.PowerShell.Core\Wait-Job | Microsoft.PowerShell.Core\Out-Null
        $success = ($job | Microsoft.PowerShell.Core\Receive-Job) -eq 0
        Microsoft.PowerShell.Core\Remove-Job -Job $job | Microsoft.PowerShell.Core\Out-Null

        if (-not $success) {

            Microsoft.PowerShell.Utility\Write-Warning "Failed to convert the file '$inputFile' to WAV format."

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Microsoft.PowerShell.Management\Remove-Item -Path $outputFile -Force | Microsoft.PowerShell.Core\Out-Null
            }

            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Transcribing the audio file '$inputFile'.."

        if ($PSBoundParameters.ContainsKey("LanguageIn")) {

            $null = $PSBoundParameters.Add("Language", $LanguageIn) | Microsoft.PowerShell.Core\Out-Null;
        }

        if ($PSBoundParameters.ContainsKey("WithTranslate")) {

            $null = $PSBoundParameters.Remove("WithTranslate", $true) | Microsoft.PowerShell.Core\Out-Null;
        }

        if (($SRT -eq $true) -and (-not $PSBoundParameters.ContainsKey("PassThru"))) {

            $null = $PSBoundParameters.Add("PassThru", $true) | Microsoft.PowerShell.Core\Out-Null;
        }
        else {

            if ((-not $SRT) -and $PSBoundParameters.ContainsKey("PassThru")) {

                $null = $PSBoundParameters.Remove("PassThru") | Microsoft.PowerShell.Core\Out-Null
            }
        }

        if (-not $PSBoundParameters.ContainsKey("WaveFile")) {

            $null = $PSBoundParameters.Add("WaveFile", $outputFile) | Microsoft.PowerShell.Core\Out-Null;
        }

        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $null = $PSBoundParameters.Add("ErrorAction", "Stop") | Microsoft.PowerShell.Core\Out-Null;
        }

        if (-not $PSBoundParameters.ContainsKey("ModelFilePath")) {

            $null = $PSBoundParameters.Add("ModelFilePath", $ModelFilePath) | Microsoft.PowerShell.Core\Out-Null;
        }
        else {

            $PSBoundParameters["ModelFilePath"] = $ModelFilePath;
        }

        if (-not (GenXdev.AI\Get-HasCapableGpu)) {

            if (-not $PSBoundParameters.ContainsKey("CpuThreads")) {

                $null = $PSBoundParameters.Add("CpuThreads", (GenXdev.AI\Get-NumberOfCpuCores)) | Microsoft.PowerShell.Core\Out-Null;
            }
        }

        try {

            # outputting in SRT format?
            if ($SRT) {

                # initialize srt counter
                $i = 1
                $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Start-AudioTranscription"

                GenXdev.AI\Start-AudioTranscription @invocationArguments | Microsoft.PowerShell.Core\ForEach-Object {

                    $result = $PSItem;

                    # needs translation?
                    if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                        Microsoft.PowerShell.Utility\Write-Verbose "Translating text to $LanguageOut for: `"$($result.Text)`".."

                        try {
                            # translate the text
                            $result = @{
                                Text  = (GenXdev.AI\Get-TextTranslation -Text:($result.Text) -Language:$LanguageOut -Model:$TranslateUsingLMStudioModel -Instructions "Translate this partial subtitle text, into the [Language] language. ommit only the translation no yapping or chatting. return in json format like so: {`"Translation`":`"Translated text here`"}" | Microsoft.PowerShell.Utility\ConvertFrom-Json).Translation;
                                Start = $result.Start;
                                End   = $result.End;
                            }

                            Microsoft.PowerShell.Utility\Write-Verbose "Text translated to: `"$($result.Text)`".."
                        }
                        catch {

                            Microsoft.PowerShell.Utility\Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
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

                $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Start-AudioTranscription"

                # transcribe the audio file to text
                $results = GenXdev.AI\Start-AudioTranscription @invocationArguments

                # delegate
                GenXdev.AI\Get-TextTranslation -Text "$results" -Language $LanguageOut -Model $TranslateUsingLMStudioModel

                # end of translation
                return;
            }

            # return the text results without translation
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Start-AudioTranscription"

            GenXdev.AI\Start-AudioTranscription @invocationArguments
        }
        catch {

            if ("$PSItem" -notlike "*aborted*") {

                Microsoft.PowerShell.Utility\Write-Error $PSItem
            }
        }
        finally {

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Microsoft.PowerShell.Management\Remove-Item -Path $outputFile -Force
            }
        }
    }
}