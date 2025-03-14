################################################################################
<#
.SYNOPSIS
Transcribes audio to text using various input methods and advanced configuration
options.

.DESCRIPTION
This function provides comprehensive audio transcription capabilities, supporting
both real-time recording and file-based transcription. It offers extensive
configuration options for language detection, audio processing, and output
formatting.

Key features:
- Multiple audio input sources (microphone, desktop audio, wav files)
- Automatic silence detection (VOX)
- Multi-language support
- Token timestamp generation
- CPU/GPU processing optimization
- Advanced audio processing parameters

.PARAMETER ModelFilePath
Path to store model files. Defaults to local GenXdev folder.

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
Sets the language to detect.

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
# Basic transcription using default settings
$text = Start-AudioTranscription
Write-Output $text

.EXAMPLE
# Advanced transcription with silence detection and desktop audio
$result = Start-AudioTranscription -VOX -UseDesktopAudioCapture `
    -Language "English" -WithTokenTimestamps
#>
function Start-AudioTranscription {

    [Alias("transcribe", "recordandtranscribe")]
    [CmdletBinding(SupportsShouldProcess = $true)]
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
        [object] $MaxDurationOfSilence,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Silence detect threshold (0..32767 defaults to 30)")]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Sets the language to detect")]
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

        Write-Verbose "Initializing audio transcription with selected options"

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
    }

    process {

        if ([string]::IsNullOrWhiteSpace($ModelFilePath) -or (-not ([IO.Directory]::Exists($ModelFilePath)))) {

            $ModelFilePath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\..\..\GenXdev.Local\" `
                -CreateDirectory
        }

        Write-Verbose "Using model path: $ModelFilePath"

        # add or update model path parameter
        if (-not $PSBoundParameters.ContainsKey("ModelFilePath")) {

            $PSBoundParameters.Add("ModelFilePath", $ModelFilePath) | Out-Null
        }
        else {
            $PSBoundParameters["ModelFilePath"] = $ModelFilePath
        }

        # configure voice activation detection (VOX) settings
        if ($VOX -eq $true) {
            Write-Verbose "Configuring VOX settings"

            if (-not $PSBoundParameters.ContainsKey("MaxDurationOfSilence")) {

                $PSBoundParameters.Add("MaxDurationOfSilence", [System.TimeSpan]::FromSeconds(4)) | Out-Null;
            }
            else {

                $PSBoundParameters["MaxDurationOfSilence"] = [System.TimeSpan]::FromSeconds(4);
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

        # ensure error action is set
        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {
            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null
        }

        # optimize for CPU when no capable GPU is present
        if (-not (Get-HasCapableGpu)) {
            Write-Verbose "No capable GPU detected, optimizing for CPU"

            if (-not $PSBoundParameters.ContainsKey("CpuThreads")) {
                $PSBoundParameters.Add("CpuThreads", (Get-NumberOfCpuCores)) `
                | Out-Null
            }
        }

        # clean up null parameters
        Write-Verbose "Cleaning up null parameters"
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            if ($null -eq $PSItem.Value -or ($PSItem.Value -eq -1)) {
                $PSBoundParameters.Remove($PSItem.Key) | Out-Null
            }
        }

        # preserve error handling state
        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Stop"

        try {
            Write-Verbose "Preparing transcription parameters"

            # prepare invocation arguments matching target function parameters
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.Helpers\Get-SpeechToText"

            # ensure language parameter is set
            if ($PSBoundParameters.ContainsKey("Language")) {

                $invocationArguments.Language = (Get-WebLanguageDictionary)[$Language]
            }

            # determine the appropriate target description based on input type
            $targetDescription = "audio transcription"
            if ($PSBoundParameters.ContainsKey("WaveFile") -and (-not [string]::IsNullOrWhiteSpace($WaveFile))) {
                $targetDescription = "transcription of file '$WaveFile'"
            }
            elseif ($PSBoundParameters.ContainsKey("UseDesktopAudioCapture") -and $UseDesktopAudioCapture) {
                $targetDescription = "desktop audio transcription"
            }
            else {
                $targetDescription = "microphone audio transcription"
            }

            Write-Verbose "Starting speech to text conversion"

            # add ShouldProcess check before executing the operation
            if ($PSCmdlet.ShouldProcess($targetDescription, "Start")) {

                Get-SpeechToText @invocationArguments
            }
        }
        finally {
            $ErrorActionPreference = $oldErrorActionPreference
        }
    }

    end {
    }
}
################################################################################