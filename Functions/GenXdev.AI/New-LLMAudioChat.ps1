################################################################################
<#
.SYNOPSIS
Creates an interactive audio chat session with an LLM model.

.DESCRIPTION
Initiates a voice-based conversation with a language model, supporting audio input
and output. The function handles audio recording, transcription, model queries,
and text-to-speech responses. Supports multiple language models and various
configuration options.

.PARAMETER Query
Initial text query to send to the model. Can be empty to start with voice input.

.PARAMETER Model
The model name/path to use. Supports -like pattern matching. Default: "qwen2.5-14b-instruct"

.PARAMETER ModelLMSGetIdentifier
Model identifier for LM Studio. Default: "qwen2.5-14b-instruct"

.PARAMETER Instructions
System instructions/prompt to guide the model's behavior.

.PARAMETER Attachments
Array of file paths to attach to the conversation for context.

.PARAMETER AudioTemperature
Temperature setting for audio input recognition. Range: 0.0-1.0. Default: 0.0

.PARAMETER Temperature
Temperature for response randomness. Range: 0.0-1.0. Default: 0.0

.PARAMETER MaxToken
Maximum tokens in model response. Default: 8192

.PARAMETER ShowWindow
Switch to show the LM Studio window during operation.

.PARAMETER TTLSeconds
Time-to-live in seconds for models loaded via API requests. Default: -1

.PARAMETER Gpu
GPU offloading configuration. -2=Auto, -1=LM Studio decides, 0-1=fraction of layers
Default: -1

.PARAMETER Force
Switch to force stop LM Studio before initialization.

.PARAMETER ImageDetail
Image detail level setting. Options: "low", "medium", "high". Default: "low"

.PARAMETER IncludeThoughts
Switch to include model's thought process in output.

.PARAMETER ContinueLast
Switch to continue from last conversation context.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions available as tools to the model.

.PARAMETER DontSpeak
Switch to disable text-to-speech for AI responses.

.PARAMETER DontSpeakThoughts
Switch to disable text-to-speech for AI thought responses.

.PARAMETER NoVOX
Switch to disable silence detection for automatic recording stop.

.PARAMETER UseDesktopAudioCapture
Switch to use desktop audio capture instead of microphone input.

.PARAMETER TemperatureResponse
Temperature for controlling response randomness. Range: 0.0-1.0. Default: 0.01

.PARAMETER Language
Language to detect in audio input. Default: "English"

.PARAMETER CpuThreads
Number of CPU threads to use. 0=auto. Default: 0

.PARAMETER SuppressRegex
Regex pattern to suppress tokens from output.

.PARAMETER AudioContextSize
Size of the audio context window.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30)

.PARAMETER LengthPenalty
Penalty factor for response length. Range: 0-1

.PARAMETER EntropyThreshold
Threshold for entropy in responses. Range: 0-1

.PARAMETER LogProbThreshold
Threshold for log probability in responses. Range: 0-1

.PARAMETER NoSpeechThreshold
Threshold for no-speech detection. Range: 0-1. Default: 0.1

.PARAMETER NoContext
Switch to disable context usage in conversation.

.PARAMETER WithBeamSearchSamplingStrategy
Switch to enable beam search sampling strategy.

.PARAMETER OnlyResponses
Switch to suppress recognized text in output.

.PARAMETER NoSessionCaching
Switch to disable session caching.

.PARAMETER ApiEndpoint
API endpoint URL. Default: http://localhost:1234/v1/chat/completions

.PARAMETER ApiKey
API key for authentication.

.EXAMPLE
New-LLMAudioChat -Query "Tell me about PowerShell" `
    -Model "qwen2.5-14b-instruct" `
    -Temperature 0.7 `
    -MaxToken 4096

.EXAMPLE
llmaudiochat "What's the weather?" -DontSpeak
#>
function New-LLMAudioChat {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
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
        [string] $query = "",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model = "qwen2.5-14b-instruct",
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
        [double] $Temperature = 0.2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Maximum tokens in response (-1 for default)")]
        [Alias("MaxTokens")]
        [int] $MaxToken = 8192,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,
        ########################################################################
        [Alias("ttl")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API requests")]
        [int] $TTLSeconds = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "How much to offload to the GPU. If `"off`", GPU offloading is disabled. If `"max`", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto "
        )]
        [int]$Gpu = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch]$Force,
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
            HelpMessage = "Include model's thoughts in output")]
        [switch] $DontAddThoughtsToHistory,
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
        [string] $Language = "",
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
        [Parameter(Mandatory = $false, HelpMessage = "Silence detect threshold (0..32767 defaults to 30)")]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold = 30,
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
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache")]
        [switch] $NoSessionCaching,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/chat/completions")]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "A JSON schema for the requested output format")]
        [string] $ResponseFormat = $null,
        ########################################################################
        [Parameter(
            HelpMessage = "Will only output markup block responses",
            Mandatory = $false
        )]
        [switch] $OutputMarkupBlocksOnly,
        ########################################################################
        [Parameter(
            HelpMessage = "Will only output markup blocks of the specified types",
            Mandatory = $false
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @("json", "powershell", "C#", "python", "javascript", "typescript", "html", "css", "yaml", "xml", "bash")
        ########################################################################
    )

    begin {

        if ([string]::IsNullOrWhiteSpace($Language)) {

            # get default language from system settings
            $Language = GenXdev.Helpers\Get-DefaultWebLanguage
            Microsoft.PowerShell.Utility\Write-Verbose "Using system default language: $Language"
        }

        # initialize stopping flag for chat loop
        $stopping = $false
        Microsoft.PowerShell.Utility\Write-Verbose "Starting new audio LLM chat session with model $Model"

        # handle exposed cmdlets configuration
        Microsoft.PowerShell.Utility\Write-Verbose "Configuring exposed cmdlets..."
        if ($null -eq $ExposedCmdLets) {
            if ($ContinueLast -and $Global:LMStudioGlobalExposedCmdlets) {
                Microsoft.PowerShell.Utility\Write-Verbose "Using existing exposed cmdlets from last session"
                $ExposedCmdLets = $Global:LMStudioGlobalExposedCmdlets
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "Initializing default exposed cmdlets"
                # initialize default allowed PowerShell cmdlets
                $ExposedCmdLets = @(
                    @{
                        Name          = "Get-ChildItem"
                        AllowedParams = @("Path=string", "Recurse=boolean", "Filter=array", "Include=array", "Exclude=array", "Force")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = "Find-Item"
                        AllowedParams = @("SearchMask", "Pattern", "PassThru")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = "Get-Content"
                        AllowedParams = @("Path=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 2
                    },
                    @{
                        Name          = "Approve-NewTextFileContent"
                        AllowedParams = @("ContentPath", "NewContent")
                        OutputText    = $false
                        Confirm       = $true
                        JsonDepth     = 2
                    },
                    @{
                        Name          = "Invoke-WebRequest"
                        AllowedParams = @("Uri=string", "Method=string", "Body", "ContentType=string", "Method=string", "UserAgent=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 4
                    },
                    @{
                        Name          = "Invoke-RestMethod"
                        AllowedParams = @("Uri=string", "Method=string", "Body", "ContentType=string", "Method=string", "UserAgent=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    },
                    @{
                        Name       = "UTCNow"
                        OutputText = $true
                        Confirm    = $false
                    },
                    @{
                        Name       = "Get-LMStudioModelList"
                        OutputText = $false
                        Confirm    = $false
                        JsonDepth  = 2
                    },
                    @{
                        Name       = "Get-LMStudioLoadedModelList"
                        OutputText = $false
                        Confirm    = $false
                        JsonDepth  = 2
                    },
                    @{
                        Name          = "Invoke-LLMQuery"
                        AllowedParams = @("Query", "Model", "Instructions", "Attachments", "IncludeThoughts")
                        ForcedParams  = @(@{Name = "NoSessionCaching"; Value = $true })
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    }
                )
            }
        }

        # cache exposed cmdlets if session caching is enabled
        if (-not $NoSessionCaching) {
            Microsoft.PowerShell.Utility\Write-Verbose "Caching exposed cmdlets for future sessions"
            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Successfully initialized with $($ExposedCmdLets.Count) exposed cmdlets"

        # ensure required parameters are properly set
        Microsoft.PowerShell.Utility\Write-Verbose "Validating and setting required parameters"
        # ensure required parameters exist
        if (-not $PSBoundParameters.ContainsKey("Model")) {
            $null = $PSBoundParameters.Add("Model", $Model)
        }

        if (-not $PSBoundParameters.ContainsKey("ModelLMSGetIdentifier") -and
            $PSBoundParameters.ContainsKey("Model")) {
            $null = $PSBoundParameters.Add("ModelLMSGetIdentifier",
                $ModelLMSGetIdentifier)
        }

        if (-not $PSBoundParameters.ContainsKey("ContinueLast")) {

            $null = $PSBoundParameters.Add("ContinueLast", $ContinueLast)
        }

        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or $ApiEndpoint.Contains("localhost")) {

            $initializationParams = GenXdev.Helpers\Copy-IdenticalParamValues -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            $modelInfo = GenXdev.AI\Initialize-LMStudioModel @initializationParams
            $Model = $modelInfo.identifier
        }

        if ($PSBoundParameters.ContainsKey("Force")) {

            $null = $PSBoundParameters.Remove("Force")
            $Force = $false
        }

        if ($PSBoundParameters.ContainsKey("ShowWindow")) {

            $null = $PSBoundParameters.Remove("ShowWindow")
            $ShowWindow = $false
        }

        if ($PSBoundParameters.ContainsKey("ChatOnce")) {

            $null = $PSBoundParameters.Remove("ChatOnce")
        }

        if (-not $PSBoundParameters.ContainsKey("ExposedCmdLets")) {

            $null = $PSBoundParameters.Add("ExposedCmdLets", $ExposedCmdLets);
        }

        $hadAQuery = -not [string]::IsNullOrEmpty($query)
    }


process {
        [string] $recognizedText = $query

        while (-not $stopping) {
            # handle initial query vs subsequent voice input
            if ($hadAQuery) {
                Microsoft.PowerShell.Utility\Write-Verbose "Processing initial query: $query"
                if ($PSCmdlet.ShouldProcess("Process initial query: $query", "Process Query", "New-LLMAudioChat")) {
                    $hadAQuery = $false
                    $query = [string]::Empty
                    if ($PSBoundParameters.ContainsKey("Query")) {
                        $null = $PSBoundParameters.Remove("Query")
                    }
                }
            }
            else {
                Microsoft.PowerShell.Utility\Write-Host "Press any key to start recording or Q to quit"

                try {
                    # prepare audio transcription parameters
                    Microsoft.PowerShell.Utility\Write-Verbose "Preparing audio transcription parameters"
                    $audioParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev.AI\Start-AudioTranscription" `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                            -ErrorAction SilentlyContinue)

                    # configure and execute audio recording
                    Microsoft.PowerShell.Utility\Write-Verbose "Configuring audio settings"
                    $audioParams.VOX = -not $NoVOX
                    $audioParams.Temperature = $AudioTemperature

                    # process text input or start recording
                    $recognizedText = $query ? $query.Trim() : [string]::Empty

                    if ([string]::IsNullOrWhiteSpace($recognizedText)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Starting audio recording and transcription"
                        if ($PSCmdlet.ShouldProcess("Start audio recording and transcription", "Record Audio", "New-LLMAudioChat")) {
                            $recognizedText = GenXdev.AI\Start-AudioTranscription @audioParams
                        }
                    }
                }
                catch {
                    # handle audio recording errors
                    if ("$PSItem" -notlike "*aborted*") {
                        Microsoft.PowerShell.Utility\Write-Error $PSItem
                    }
                    Microsoft.PowerShell.Utility\Write-Verbose "Audio transcription failed or was aborted"
                    $query = [string]::Empty
                    $recognizedText = [string]::Empty
                    continue
                }
            }

            # process recognized input if not empty
            if (-not [string]::IsNullOrWhiteSpace($recognizedText)) {
                $question = $recognizedText
                Microsoft.PowerShell.Utility\Write-Verbose "Processing recognized input: $question"

                # prepare LM Studio query parameters
                Microsoft.PowerShell.Utility\Write-Verbose "Preparing LM Studio parameters"
                $invokeLMStudioParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\New-LLMTextChat" `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                        -ErrorAction SilentlyContinue)

                # configure and execute LM Studio query
                Microsoft.PowerShell.Utility\Write-Verbose "Configuring LM Studio query parameters"
                $invokeLMStudioParams.Query = $question
                $invokeLMSTudioParams.Speak = -not $DontSpeak
                $invokeLMStudioParams.SpeakThoughts = -not $DontSpeakThoughts
                $invokeLMStudioParams.ChatOnce = $true

                Microsoft.PowerShell.Utility\Write-Verbose "Executing LM Studio query"
                if ($PSCmdlet.ShouldProcess("Execute LM Studio query: $question", "Query LM Studio", "New-LLMAudioChat")) {
                    $answer = GenXdev.AI\New-LLMTextChat @invokeLMStudioParams

                    # display formatted response
                    if ($OnlyResponses) {
                        Microsoft.PowerShell.Utility\Write-Host "$answer" -ForegroundColor Green
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Host "<< $answer" -ForegroundColor Green
                    }
                }

                Microsoft.PowerShell.Utility\Write-Host "Press any key to interrupt and start recording or Q to quit"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Host "Too short or only silence recorded`r`n"
            }

            # monitor for key presses during speech output
            Microsoft.PowerShell.Utility\Write-Verbose "Monitoring for key presses during speech output"
            $continueWaiting = $true
            while ($continueWaiting -and (GenXdev.Console\Get-IsSpeaking)) {

                while ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey().Key
                    [System.Console]::Write("`e[1G`e[2K")

                    if ($key -eq [ConsoleKey]::Q) {
                        GenXdev.Console\Stop-TextToSpeech
                        Microsoft.PowerShell.Utility\Write-Host "---------------"
                        $continueWaiting = $false
                        $stopping = $true
                        return
                    }
                    else {
                        $continueWaiting = $false
                        break
                    }
                }

                $null = Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 100
            }

            # clear previous prompt
            [System.Console]::Write("`e[1A`e[2K")

            GenXdev.Console\Stop-TextToSpeech
            Microsoft.PowerShell.Utility\Write-Host "---------------"
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose "Audio chat session completed"
    }
}
################################################################################