################################################################################
<#
.SYNOPSIS
Starts a rudimentary audio chat session.

.DESCRIPTION
Starts a rudimentary audio chat session using Whisper and the LM-Studio API.

.PARAMETER Instructions
The system instructions for the responding LLM.
Default value: "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice."

.PARAMETER Model
The LM-Studio model to use for generating the response.
Default value: "llama"

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input.

.PARAMETER TemperatureResponse
The temperature parameter for controlling the randomness of the response.

.PARAMETER Language
Sets the language to detect, defaults to 'English'.

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for response generation.

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

.PARAMETER OnlyResponses
Whether to suppress reconized text in the output.

.PARAMETER NoTextToSpeech
Whether to suppress text to speech.

#>
function Start-AudioChat {

    [Alias("llmchat")]

    param(
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The system instructions for the responding LLM.")]
        [PSDefaultValue(Value = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.")]
        [string]$Instructions = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.",
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "llama")]
        [string]$Model = "llama",
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to use desktop audio capture instead of microphone input")]
        [switch] $UseDesktopAudioCapture,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $TemperatureResponse = 0.01,
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
        [Parameter(Mandatory = $false, HelpMessage = "Temperature for response generation")]
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
        [Parameter(Mandatory = $false, HelpMessage = "Size of the audio context")]
        [int] $AudioContextSize,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of the audio")]
        [timespan] $MaxDuration,
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
        [switch] $WithBeamSearchSamplingStrategy,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to suppress reconized text in the output")]
        [switch] $OnlyResponses,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to suppress text to speech")]
        [switch] $NoTextToSpeech
    )

    begin {

    }

    process {
        if (-not $PSBoundParameters.ContainsKey("Language")) {

            $PSBoundParameters.Add("Language", $Language) | Out-Null;
        }
        else {

            $PSBoundParameters["Language"] = $Language;
        }

        if (-not $PSBoundParameters.ContainsKey("VOX")) {

            $PSBoundParameters.Add("VOX", $true) | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("OnlyResponses")) {

            $PSBoundParameters.Remove("OnlyResponses") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("NoTextToSpeech")) {

            $PSBoundParameters.Remove("NoTextToSpeech") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("instructions")) {

            $PSBoundParameters.Remove("instructions") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("model")) {

            $PSBoundParameters.Remove("model") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("TemperatureResponse")) {

            $PSBoundParameters.Remove("TemperatureResponse") | Out-Null;
        }
        if (-not $PSBoundParameters.ContainsKey("Language")) {

            $PSBoundParameters.Add("Language", $Language) | Out-Null;
        }
        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null;
        }

        [string] $session = "";

        while ($true) {

            try {

                $text = Start-AudioTranscription @PSBoundParameters
            }
            catch {

                if ("$PSItem" -notlike "*aborted*") {

                    Write-Error $PSItem
                }
                return;
            }

            if (-not [string]::IsNullOrWhiteSpace($text)) {

                $question = $text
                $session += "<< $text`r`n`r`n"

                if (-not $OnlyResponses) {

                    $a = [System.Console]::ForegroundColor
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
                    Write-Host "<< $text"
                    [System.Console]::ForegroundColor = $a;
                }

                $answer = (qlms -Query $session -Instructions:$Instructions -Model:$Model -Temperature:$TemperatureResponse)
                $session = ">> $question`r`n`r`n<< `r`n$answer`r`n`r`n"

                $a = [System.Console]::ForegroundColor
                [System.Console]::ForegroundColor = [System.ConsoleColor]::Green

                if ($OnlyResponses) {

                    Write-Host "$answer"
                }
                else {
                    Write-Host "<< $answer"
                }
                [System.Console]::ForegroundColor = $a;

                if (-not ($true -eq $NoTextToSpeech)) {

                    Start-TextToSpeech $answer
                }

                Write-Host "Press any key to interrupt and start recording or Q to quit"
            }
            else {

                Write-Host "Only silence recorded";
            }

            # should we wait until a key is pressed?
            while ((Get-IsSpeaking)) {

                while ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey().Key
                    [System.Console]::Write("`e[1G`e[2K")

                    if ($key -eq [ConsoleKey]::Q) {

                        sst;
                        Write-Host "---------------"
                        throw "aborted";
                        return;
                    }
                    else {

                        break
                    }
                }

                Start-Sleep -Milliseconds 100 | Out-Null
            }

            # ansi for cursor up and clear line
            [System.Console]::Write("`e[1A`e[2K")

            sst;
            Write-Host "---------------"
        }
    }
}
