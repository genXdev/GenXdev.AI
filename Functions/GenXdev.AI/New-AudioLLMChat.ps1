################################################################################
<#
.SYNOPSIS
Creates a new audio-based chat session with an LLM model.

.DESCRIPTION
Initiates an interactive chat session using audio input and output with a
specified LLM model. Supports various language models, audio processing options,
and customization parameters.

.PARAMETER Query
Initial query text to send to the model.

.PARAMETER Model
The LM-Studio model to use. Defaults to "qwen*-instruct".

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier. Defaults to "qwen2.5-14b-instruct".

.PARAMETER Instructions
System instructions for the model.

.PARAMETER Attachments
Array of file paths to attach to the conversation.

.PARAMETER AudioTemperature
Temperature for audio input recognition (0.0-1.0).

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0).

.PARAMETER MaxToken
Maximum tokens in response (-1 for default).

.PARAMETER ImageDetail
Image detail level (low/medium/high).

.EXAMPLE
New-AudioLLMChat -Query "Tell me about AI" -Model "qwen*-instruct" -Temperature 0.7

.EXAMPLE
llmaudiochat "What is PowerShell?" -DontSpeak
#>
function New-AudioLLMChat {

    [CmdletBinding()]
    [Alias("llmaudiochat")]

    param(
        ########################################################################
        [Parameter(
            ValueFromPipeline = $true,
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Initial query text to send to the model"
        )]
        [AllowEmptyString()]
        [string] $Query = "",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [string] $Model = "qwen*-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The LM-Studio model identifier"
        )]
        [string] $ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "System instructions for the model")]
        [string] $Instructions,
        ########################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach")]
        [string[]] $Attachments = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for audio input recognition (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $AudioTemperature = 0.0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)")]
        [Alias("MaxTokens")]
        [int] $MaxToken = 32768,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Image detail level")]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "low",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output")]
        [switch] $IncludeThoughts,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Continue from last conversation")]
        [switch] $ContinueLast,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools")]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowLMStudioWindow,
        ###########################################################################
        [Parameter(
            HelpMessage = "Disable text-to-speech for AI responses",
            Mandatory = $false
        )]
        [switch] $DontSpeak,
        ###########################################################################
        [Parameter(
            HelpMessage = "Disable text-to-speech for AI thought responses",
            Mandatory = $false
        )]
        [switch] $DontSpeakThoughts,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't use silence detection to automatically stop recording."
        )]
        [switch] $NoVOX,
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
        [Parameter(Mandatory = $false, HelpMessage = "Regex to suppress tokens from the output")]
        [string] $SuppressRegex = $null,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Size of the audio context")]
        [int] $AudioContextSize,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of the audio")]
        [ValidateRange(0.0, 1.0)]
        [float] $SilenceThreshold = 0.3,
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
        [float] $NoSpeechThreshold = 0.1,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Don't use context")]
        [switch] $NoContext,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Use beam search sampling strategy")]
        [switch] $WithBeamSearchSamplingStrategy,
        ################################################################################
        [Parameter(Mandatory = $false, HelpMessage = "Whether to suppress reconized text in the output")]
        [switch] $OnlyResponses,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache")]
        [switch] $NoSessionCaching
    )

    begin {

        # initialize stopping flag
        $stopping = $false
        Write-Verbose "Starting new audio LLM chat session"
    }

    process {

        [string] $text = $Query

        while (-not $stopping) {

            try {
                # prepare audio transcription parameters
                $startAudioTranscriptionParams = @{}
                $help = Get-Command "GenXdev.AI\Start-AudioTranscription"

                # copy matching parameters from bound parameters
                $null = $help.ParameterSets.Parameter.Name |
                Select-Object -Unique |
                ForEach-Object {
                    if ($PSBoundParameters.ContainsKey($_)) {
                        $startAudioTranscriptionParams[$_] = `
                            $PSBoundParameters[$_]
                    }
                }

                # configure audio parameters
                $startAudioTranscriptionParams.VOX = -not $NoVOX
                $startAudioTranscriptionParams.Temperature = $AudioTemperature
                $startAudioTranscriptionParams.ModelFilePath = `
                    Expand-Path "..\..\..\..\GenXdev.Local\" -CreateDirectory

                # handle query text
                $text = $Query ? $Query.Trim() : [string]::Empty

                if (-not [string]::IsNullOrWhiteSpace($text)) {
                    $Query = [string]::Empty
                }
                else {
                    Write-Verbose "Starting audio transcription"
                    $text = Start-AudioTranscription @startAudioTranscriptionParams
                }
            }
            catch {
                if ("$PSItem" -notlike "*aborted*") {
                    Write-Error $PSItem
                }
                Write-Verbose "Audio transcription failed"
                $Query = [string]::Empty
                $text = [string]::Empty
                return
            }

            # process recognized text
            if (-not [string]::IsNullOrWhiteSpace($text)) {

                $question = $text
                Write-Verbose "Processing question: $question"

                # prepare LM Studio parameters
                $invokeLMStudioParams = @{}
                $help = Get-Command "GenXdev.AI\Invoke-LMStudioQuery"

                # copy matching parameters
                $null = $help.ParameterSets.Parameter.Name |
                Select-Object -Unique |
                ForEach-Object {
                    if ($PSBoundParameters.ContainsKey($_)) {
                        $invokeLMStudioParams[$_] = $PSBoundParameters[$_]
                    }
                }

                # invoke LM Studio
                $invokeLMStudioParams.Query = $question
                $invokeLMSTudioParams.Speak = -not $DontSpeak
                $invokeLMStudioParams.SpeakThoughts = -not $DontSpeakThoughts
                $invokeLMStudioParams.ChatOnce = $true

                Write-Verbose "Invoking LM Studio query"
                $answer = New-TextLLMChat @invokeLMStudioParams

                # display response with green color
                if ($OnlyResponses) {

                    Write-Host "$answer" -ForegroundColor Green
                }
                else {
                    Write-Host "<< $answer" -ForegroundColor Green
                }

                Write-Host "Press any key to interrupt and start recording or Q to quit"
            }
            else {
                Write-Host "Too short or only silence recorded`r`n"
            }

            # wait for key press while speaking
            $continueWaiting = $true
            while ($continueWaiting -and (Get-IsSpeaking)) {

                while ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey().Key
                    [System.Console]::Write("`e[1G`e[2K")

                    if ($key -eq [ConsoleKey]::Q) {
                        sst
                        Write-Host "---------------"
                        $continueWaiting = $false
                        $stopping = $true
                        return
                    }
                    else {
                        $continueWaiting = $false
                        break
                    }
                }

                $null = Start-Sleep -Milliseconds 100
            }

            # clear previous prompt
            [System.Console]::Write("`e[1A`e[2K")

            sst
            Write-Host "---------------"
        }
    }

    end {
    }
}
################################################################################
