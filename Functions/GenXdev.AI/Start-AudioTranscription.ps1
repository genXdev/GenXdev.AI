################################################################################
<#
.SYNOPSIS
Transcribes audio to text using the default audio input device.

.DESCRIPTION
Records audio using the default audio input device and returns the detected text

.PARAMETER ModelFilePath
Path where model files are stored.

.PARAMETER WaveFile
Path to the 16Khz mono, .WAV file to process.

.PARAMETER PassThru
Returns objects instead of strings.

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input

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
Silence detect threshold (0..32767 defaults to 30).

.PARAMETER Language
Sets the language to detect, defaults to 'English'.

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for speech generation.

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

.EXAMPLE
$text = Start-AudioTranscription;
$text
#>
function Start-AudioTranscription {

    [Alias("transcribe", "recordandtranscribe")]

    param (
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Path where model files are stored")]
        [string] $ModelFilePath,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Path to the 16Khz mono, .WAV file to process")]
        [string] $WaveFile = $null,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use silence detection to automatically stop recording."
        )]
        [switch] $VOX,
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
        [Parameter(Mandatory = $false, HelpMessage = "Sets the language to detect, defaults to 'English'")]
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
        [string] $Language = "English",
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Number of CPU threads to use, defaults to 0 (auto)")]
        [int] $CpuThreads = 0,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Temperature for speech generation")]
        [ValidateRange(0, 100)]
        [float] $Temperature = 0.01,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        [float] $TemperatureInc,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to translate the output")]
        [switch] $WithTranslate,
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

        $ModelFilePath = Expand-Path "$PSScriptRoot\..\..\..\..\GenXdev.Local\" -CreateDirectory

        if (-not $PSBoundParameters.ContainsKey("ModelFilePath")) {

            $PSBoundParameters.Add("ModelFilePath", $ModelFilePath) | Out-Null;
        }
        else {

            $PSBoundParameters["ModelFilePath"] = $ModelFilePath;
        }

        if ($VOX -eq $true) {

            if (-not $PSBoundParameters.ContainsKey("MaxDurationOfSilence")) {

                $PSBoundParameters.Add("MaxDurationOfSilence", [timespan]::FromSeconds(4)) | Out-Null;
            }
            else {

                $PSBoundParameters["MaxDurationOfSilence"] = [timespan]::FromSeconds(4);
            }

            if (-not $PSBoundParameters.ContainsKey("IgnoreSilence")) {

                $PSBoundParameters.Add("IgnoreSilence", $true) | Out-Null;
            }
            else {

                $PSBoundParameters["IgnoreSilence"] = $true
            }

            if ($PSBoundParameters.ContainsKey("VOX")) {
                $PSBoundParameters.Remove("VOX") | Out-Null;
            }
        }

        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null;
        }

        if (-not (Get-HasCapableGpu)) {

            if (-not $PSBoundParameters.ContainsKey("CpuThreads")) {

                $PSBoundParameters.Add("CpuThreads", (Get-NumberOfCpuCores)) | Out-Null;
            }
        }
        if (-not $PSBoundParameters.ContainsKey("Language")) {

            $PSBoundParameters.Add("Language", $Language) | Out-Null;
        }

        # Remove any parameters with $null values
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            if ($null -eq $PSItem.Value) {
                $PSBoundParameters.Remove($PSItem.Key) | Out-Null
            }
        }

        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        try {

            Get-SpeechToText @PSBoundParameters
        }
        finally {

            $ErrorActionPreference = $oldErrorActionPreference
        }
    }
}
