###############################################################################
<#
.SYNOPSIS
Creates an interactive audio chat session with an LLM model.

.DESCRIPTION
Initiates a voice-based conversation with a language model, supporting audio
input and output. The function handles audio recording, transcription, model
queries, and text-to-speech responses. Supports multiple language models and
various configuration options.

.PARAMETER Query
Initial text query to send to the model. Can be empty to start with voice
input.

.PARAMETER Instructions
System instructions/prompt to guide the model's behavior.

.PARAMETER Attachments
Array of file paths to attach to the conversation for context.

.PARAMETER AudioTemperature
Temperature setting for audio input recognition. Range: 0.0-1.0. Default: 0.0

.PARAMETER Temperature
Temperature for response randomness. Range: 0.0-1.0. Default: 0.2

.PARAMETER TemperatureResponse
Temperature for controlling response randomness. Range: 0.0-1.0. Default: 0.01

.PARAMETER Language
Language to detect in audio input. Default: "English"

.PARAMETER CpuThreads
Number of CPU threads to use. 0=auto. Default: 0

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations

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

.PARAMETER LLMQueryType
The type of LLM query

.PARAMETER Model
The model identifier or pattern to use for AI operations

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations

.PARAMETER Gpu
GPU offloading configuration. -2=Auto, -1=LM Studio decides, 0-1=fraction of
layers. Default: -1

.PARAMETER ImageDetail
Image detail level setting. Options: "low", "medium", "high". Default: "low"

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations

.PARAMETER ApiKey
The API key for authenticated AI operations

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations

.PARAMETER ResponseFormat
A JSON schema for the requested output format

.PARAMETER MarkupBlocksTypeFilter
Will only output markup blocks of the specified types

.PARAMETER PreferencesDatabasePath
Database path for preference data files

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions available as tools to the model.

.PARAMETER IncludeThoughts
Switch to include model's thought process in output.

.PARAMETER DontAddThoughtsToHistory
Switch to include model's thoughts in output

.PARAMETER ContinueLast
Switch to continue from last conversation context.

.PARAMETER DontSpeak
Switch to disable text-to-speech for AI responses.

.PARAMETER DontSpeakThoughts
Switch to disable text-to-speech for AI thought responses.

.PARAMETER NoVOX
Switch to disable silence detection for automatic recording stop.

.PARAMETER UseDesktopAudioCapture
Switch to use desktop audio capture instead of microphone input.

.PARAMETER NoContext
Switch to disable context usage in conversation.

.PARAMETER WithBeamSearchSamplingStrategy
Switch to enable beam search sampling strategy.

.PARAMETER OnlyResponses
Switch to suppress recognized text in output.

.PARAMETER NoSessionCaching
Switch to disable session caching.

.PARAMETER OutputMarkupBlocksOnly
Will only output markup block responses

.PARAMETER ShowWindow
Switch to show the LM Studio window during operation.

.PARAMETER Force
Switch to force stop LM Studio before initialization.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session

.EXAMPLE
New-LLMAudioChat -Query "Tell me about PowerShell" `
    -Model "qwen2.5-14b-instruct" `
    -Temperature 0.7 `
    -MaxToken 4096

.EXAMPLE
llmaudiochat "What's the weather?" -DontSpeak
#>
###############################################################################
function New-LLMAudioChat {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [Alias("llmaudiochat")]

    param(
        #######################################################################
        [Parameter(
            ValueFromPipeline = $true,
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Initial query text to send to the model"
        )]
        [AllowEmptyString()]
        [string] $Query = "",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "System instructions for the model"
        )]
        [string] $Instructions,
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach"
        )]
        [string[]] $Attachments = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for audio input recognition (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $AudioTemperature = 0.0,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The temperature parameter for controlling the " +
                "randomness of the response.")
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $TemperatureResponse = 0.01,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Sets the language to detect"
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
            "Zulu"
        )]
        [string] $Language,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Number of CPU threads to use, defaults to 0 " +
                "(auto)")
        )]
        [int] $CpuThreads = 0,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Regex to suppress tokens from the output"
        )]
        [string] $SuppressRegex = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Size of the audio context"
        )]
        [int] $AudioContextSize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Silence detect threshold (0..32767 defaults " +
                "to 30)")
        )]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold = 30,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Length penalty"
        )]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Entropy threshold"
        )]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Log probability threshold"
        )]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "No speech threshold"
        )]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The type of LLM query"
        )]
        [ValidateSet(
            "SimpleIntelligence",
            "Knowledge",
            "Pictures",
            "TextTranslation",
            "Coding",
            "ToolUse"
        )]
        [string] $LLMQueryType = "ToolUse",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The model identifier or pattern to use for AI " +
                "operations")
        )]
        [string] $Model,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The maximum number of tokens to use in AI " +
                "operations")
        )]
        [int] $MaxToken,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                "offloaded to GPU. If a number between 0 and 1, " +
                "that fraction of layers will be offloaded to the " +
                "GPU. -1 = LM Studio will decide how much to " +
                "offload to the GPU. -2 = Auto")
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Image detail level"
        )]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "low",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("A JSON schema for the requested output format")
        )]
        [string] $ResponseFormat = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Will only output markup blocks of the " +
                "specified types")
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @(
            "json",
            "powershell",
            "C#",
            "python",
            "javascript",
            "typescript",
            "html",
            "css",
            "yaml",
            "xml",
            "bash"
        ),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of PowerShell command definitions to use " +
                "as tools")
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $DontAddThoughtsToHistory,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Continue from last conversation"
        )]
        [switch] $ContinueLast,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable text-to-speech for AI responses"
        )]
        [switch] $DontSpeak,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable text-to-speech for AI thought responses"
        )]
        [switch] $DontSpeakThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't use silence detection to automatically " +
                "stop recording.")
        )]
        [switch] $NoVOX,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Whether to use desktop audio capture instead " +
                "of microphone input")
        )]
        [switch] $UseDesktopAudioCapture,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't use context"
        )]
        [switch] $NoContext,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use beam search sampling strategy"
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Whether to suppress reconized text in the " +
                "output")
        )]
        [switch] $OnlyResponses,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will only output markup block responses"
        )]
        [switch] $OutputMarkupBlocksOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window"
        )]
        [switch] $ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force stop LM Studio before initialization"
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session " +
                "for AI preferences")
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session " +
                "for AI preferences")
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences " +
                "without affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        # copy identical parameter values for meta language configuration
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # determine appropriate language setting for audio recognition
        $Language = GenXdev.AI\Get-AIMetaLanguage @params

        # initialize stopping flag for chat loop
        $stopping = $false
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting new audio LLM chat sessio")

        # handle exposed cmdlets configuration
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Configuring exposed cmdlets...")
        if ($null -eq $ExposedCmdLets) {

            # check if continuing last session with cached cmdlets
            if ($ContinueLast -and $Global:LMStudioGlobalExposedCmdlets) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using existing exposed cmdlets from last session")
                $ExposedCmdLets = $Global:LMStudioGlobalExposedCmdlets
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Initializing default exposed cmdlets")
                # initialize default allowed PowerShell cmdlets
                $ExposedCmdLets = @(
                    @{
                        Name          = "Get-ChildItem"
                        AllowedParams = @(
                            "Path=string",
                            "Recurse=boolean",
                            "Filter=array",
                            "Include=array",
                            "Exclude=array",
                            "Force"
                        )
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
                        AllowedParams = @(
                            "Uri=string",
                            "Method=string",
                            "Body",
                            "ContentType=string",
                            "Method=string",
                            "UserAgent=string"
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 4
                    },
                    @{
                        Name          = "Invoke-RestMethod"
                        AllowedParams = @(
                            "Uri=string",
                            "Method=string",
                            "Body",
                            "ContentType=string",
                            "Method=string",
                            "UserAgent=string"
                        )
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
                        AllowedParams = @(
                            "Query",
                            "Model",
                            "Instructions",
                            "Attachments",
                            "IncludeThoughts"
                        )
                        ForcedParams  = @(
                            @{
                                Name = "NoSessionCaching";
                                Value = $true
                            }
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    }
                )
            }
        }

        # cache exposed cmdlets if session caching is enabled
        if (-not $NoSessionCaching) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Caching exposed cmdlets for future sessions")
            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Successfully initialized with $($ExposedCmdLets.Count) " +
            "exposed cmdlets")

        # ensure required parameters are properly set
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Validating and setting required parameters")

        # ensure required parameters exist
        if (-not $PSBoundParameters.ContainsKey("Model")) {

            $null = $PSBoundParameters.Add("Model", $Model)
        }

        # add hugging face identifier if model is specified
        if (-not $PSBoundParameters.ContainsKey("HuggingFaceIdentifier") -and
            $PSBoundParameters.ContainsKey("Model")) {

            $null = $PSBoundParameters.Add("HuggingFaceIdentifier",
                $HuggingFaceIdentifier)
        }

        # ensure continue last parameter is available
        if (-not $PSBoundParameters.ContainsKey("ContinueLast")) {

            $null = $PSBoundParameters.Add("ContinueLast", $ContinueLast)
        }

        # initialize lm studio if using localhost endpoint
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains("localhost")) {

            $initializationParams = `
                GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -Name * `
                    -ErrorAction SilentlyContinue)

            $modelInfo = GenXdev.AI\Initialize-LMStudioModel `
                @initializationParams
            $Model = $modelInfo.identifier
        }

        # remove force parameter to prevent issues downstream
        if ($PSBoundParameters.ContainsKey("Force")) {

            $null = $PSBoundParameters.Remove("Force")
            $Force = $false
        }

        # remove show window parameter to prevent issues downstream
        if ($PSBoundParameters.ContainsKey("ShowWindow")) {

            $null = $PSBoundParameters.Remove("ShowWindow")
            $ShowWindow = $false
        }

        # remove chat once parameter if present
        if ($PSBoundParameters.ContainsKey("ChatOnce")) {

            $null = $PSBoundParameters.Remove("ChatOnce")
        }

        # ensure exposed cmdlets parameter is available
        if (-not $PSBoundParameters.ContainsKey("ExposedCmdLets")) {

            $null = $PSBoundParameters.Add("ExposedCmdLets", $ExposedCmdLets);
        }

        # track if we had an initial query
        $hadAQuery = -not [string]::IsNullOrEmpty($Query)
    }

    process {

        # set recognized text to initial query value
        [string] $recognizedText = $Query

        # main chat loop - continue until user stops
        while (-not $stopping) {

            # handle initial query vs subsequent voice input
            if ($hadAQuery) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing initial query: $Query")

                # check if we should process the initial query
                if ($PSCmdlet.ShouldProcess(
                    "Process initial query: $Query",
                    "Process Query",
                    "New-LLMAudioChat")) {

                    $hadAQuery = $false
                    $Query = [string]::Empty

                    # remove query parameter to prevent reuse
                    if ($PSBoundParameters.ContainsKey("Query")) {

                        $null = $PSBoundParameters.Remove("Query")
                    }
                }
            }
            else {

                Microsoft.PowerShell.Utility\Write-Host (
                    "Press any key to start recording or Q to quit")

                try {

                    # prepare audio transcription parameters
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Preparing audio transcription parameters")
                    $audioParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev.AI\Invoke-Whisper" `
                        -DefaultValues `
                            (Microsoft.PowerShell.Utility\Get-Variable `
                                -Scope Local `
                                -ErrorAction SilentlyContinue)

                    # configure and execute audio recording
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Configuring audio settings")
                    $audioParams.VOX = -not $NoVOX
                    $audioParams.Temperature = $AudioTemperature

                    # process text input or start recording
                    $recognizedText = $Query ? $Query.Trim() : [string]::Empty

                    # start audio recording if no text input provided
                    if ([string]::IsNullOrWhiteSpace($recognizedText)) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Starting audio recording session")
                        $recognizedText = GenXdev.AI\Invoke-Whisper @audioParams
                    }
                }
                catch {

                    # handle audio recording errors
                    if ("$PSItem" -notlike "*aborted*") {

                        Microsoft.PowerShell.Utility\Write-Error $PSItem
                    }
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Audio transcription failed or was aborted")
                    $Query = [string]::Empty
                    $recognizedText = [string]::Empty
                    continue
                }
            }

            # process recognized input if not empty
            if (-not [string]::IsNullOrWhiteSpace($recognizedText)) {

                $question = $recognizedText
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing recognized input: $question")

                # prepare lm studio query parameters
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Preparing LM Studio parameters")
                $invokeLMStudioParams = `
                    GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\New-LLMTextChat" `
                    -DefaultValues `
                        (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local `
                            -ErrorAction SilentlyContinue)

                # configure and execute lm studio query
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Configuring LM Studio query parameters")
                $invokeLMStudioParams.Query = $question
                $invokeLMSTudioParams.Speak = -not $DontSpeak
                $invokeLMStudioParams.SpeakThoughts = -not $DontSpeakThoughts
                $invokeLMStudioParams.ChatOnce = $true

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Executing LM Studio query")

                # execute the llm query if user confirms
                if ($PSCmdlet.ShouldProcess(
                    "Execute LM Studio query: $question",
                    "Query LM Studio",
                    "New-LLMAudioChat")) {

                    $null = GenXdev.AI\New-LLMTextChat @invokeLMStudioParams
                }

                Microsoft.PowerShell.Utility\Write-Host (
                    "Press any key to interrupt and start recording or Q to quit")
            }
            else {

                Microsoft.PowerShell.Utility\Write-Host (
                    "Too short or only silence recorded`r`n")
            }

            # monitor for key presses during speech output
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Monitoring for key presses during speech output")
            $continueWaiting = $true
            while ($continueWaiting -and (GenXdev.Console\Get-IsSpeaking)) {

                # check for available key presses
                while ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey().Key
                    [System.Console]::Write("`e[1G`e[2K")

                    # quit if q key pressed
                    if ($key -eq [ConsoleKey]::Q) {

                        GenXdev.Console\Stop-TextToSpeech
                        Microsoft.PowerShell.Utility\Write-Host (
                            "---------------")
                        $continueWaiting = $false
                        $stopping = $true
                        return
                    }
                    else {

                        $continueWaiting = $false
                        break
                    }
                }

                # wait briefly before checking again
                $null = Microsoft.PowerShell.Utility\Start-Sleep `
                    -Milliseconds 100
            }

            # clear previous prompt
            [System.Console]::Write("`e[1A`e[2K")

            # stop text to speech and show separator
            GenXdev.Console\Stop-TextToSpeech
            Microsoft.PowerShell.Utility\Write-Host "---------------"
        }
    }

    end {

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Audio chat session completed")
    }
}
###############################################################################
