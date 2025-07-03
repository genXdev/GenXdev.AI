###############################################################################
<#
.SYNOPSIS
Sends queries to an OpenAI compatible Large Language Chat completion API and
processes responses.

.DESCRIPTION
This function sends queries to an OpenAI compatible Large Language Chat completion
API and processes responses. It supports text and image inputs, handles tool
function calls, and can operate in various chat modes including text and audio.

.PARAMETER Query
The text query to send to the model. Can be empty for chat modes.

.PARAMETER Model
The name or identifier of the LM Studio model to use.

.PARAMETER HuggingFaceIdentifier
Alternative identifier for getting a specific model from LM Studio.

.PARAMETER Instructions
System instructions to provide context to the model.

.PARAMETER Attachments
Array of file paths to attach to the query. Supports images and text files.

.PARAMETER ResponseFormat
A JSON schema for the requested output format.

.PARAMETER Temperature
Controls response randomness (0.0-1.0). Lower values are more deterministic.

.PARAMETER MaxToken
Maximum tokens allowed in the response. Use -1 for model default.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER TTLSeconds
Time-to-live in seconds for loaded models.

.PARAMETER Gpu
How much to offload to the GPU. Values range from -2 (Auto) to 1 (max).

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER ImageDetail
Detail level for image processing (low/medium/high).

.PARAMETER IncludeThoughts
Include model's thought process in output.

.PARAMETER DontAddThoughtsToHistory
Exclude thought processes from conversation history.

.PARAMETER ContinueLast
Continue from the last conversation context.

.PARAMETER Functions
Array of function definitions that the model can call.

.PARAMETER ExposedCmdLets
PowerShell commands to expose as tools to the model.

.PARAMETER NoConfirmationToolFunctionNames
Tool functions that don't require user confirmation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.PARAMETER OutputMarkupBlocksOnly
Only output markup block responses.

.PARAMETER MarkupBlocksTypeFilter
Only output markup blocks of the specified types.

.PARAMETER ChatMode
Enable interactive chat mode with specified input method.

.PARAMETER ChatOnce
Internal parameter to control chat mode invocation.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER ApiEndpoint
API endpoint URL, defaults to http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
The API key to use for the request.

.EXAMPLE
Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7

.EXAMPLE
qllm "What is 2+2?" -Model "qwen"
###############################################################################>
function Invoke-LLMQuery {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [Alias("qllm", "llm", "Invoke-LMStudioQuery", "qlms")]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Query text to send to the model"
        )]
        [AllowEmptyString()]
        [string] $Query = "",

        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "System instructions for the model")]
        [string] $Instructions,
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach")]
        [string[]] $Attachments = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "A JSON schema for the requested output format")]
        [string] $ResponseFormat = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowWindow,
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
            HelpMessage = "Array of function definitions")]
        [hashtable[]] $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools")]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = $null,
        ########################################################################
        # Array of command names that don't require confirmation
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Tool functions that don't require user confirmation")]
        [Alias("NoConfirmationFor")]
        [string[]]
        $NoConfirmationToolFunctionNames = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI responses"
        )]
        [switch] $Speak,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI thought responses"
        )]
        [switch] $SpeakThoughts,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will only output markup block responses"
        )]
        [switch] $OutputMarkupBlocksOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will only output markup blocks of the specified types"
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @("json", "powershell", "C#", "python", "javascript", "typescript", "html", "css", "yaml", "xml", "bash"),
        ########################################################################
        [Alias("chat")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable chat mode")]
        [ValidateSet("none", "textprompt", "default audioinput device", "desktop audio")]
        [string] $ChatMode,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Used internally, to only invoke chat mode once after the llm invocation")]
        [switch] $ChatOnce,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache")]
        [switch] $NoSessionCaching,
        ########################################################################
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
        [string] $LLMQueryType = "SimpleIntelligence",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The model identifier or pattern to use for AI operations"
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio specific model identifier"
        )]
        [Alias("ModelLMSGetIdentifier")]
        [string] $HuggingFaceIdentifier,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,

        ###############################################################################
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
        [int]$Gpu = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API endpoint URL for AI operations"
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key for authenticated AI operations"
        )]
        [string] $ApiKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The timeout in seconds for AI operations"
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
        )

    begin {
        $llmConfigParams = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AILLMSettings" `
            -DefaultValues  (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $llmConfig = GenXdev.AI\Get-AILLMSettings @llmConfigParams

        foreach ($param in $llmConfig.Keys) {

            if (Microsoft.PowerShell.Utility\Get-Variable -Name $param -Scope Local -ErrorAction SilentlyContinue) {

                Microsoft.PowerShell.Utility\Set-Variable -Name $param -Value $llmConfig[$param] `
                    -Scope Local -Force
            }
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Starting LLM interaction..."

        # convert markup block types to lowercase for case-insensitive comparison
        $MarkupBlocksTypeFilter = $MarkupBlocksTypeFilter |
            Microsoft.PowerShell.Core\ForEach-Object { $_.ToLowerInvariant() }

        # initialize lm studio if using localhost
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains("localhost")) {

            # copy identical parameter values to initialize the model
            $initParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                    -ErrorAction SilentlyContinue)

            # handle force parameter separately
            if ($PSBoundParameters.ContainsKey("Force")) {
                $null = $PSBoundParameters.Remove("Force")
                $Force = $false
            }

            # initialize the model and get model information
            $modelInfo = GenXdev.AI\Initialize-LMStudioModel @initParams
            $Model = $modelInfo.identifier
        }

        # remove show window parameter after initialization
        if ($PSBoundParameters.ContainsKey("ShowWindow")) {
            $null = $PSBoundParameters.Remove("ShowWindow")
            $ShowWindow = $false
        }

        # handle chat mode parameter
        if ($PSBoundParameters.ContainsKey("ChatMode")) {
            $null = $PSBoundParameters.Remove("ChatMode")
            if (($ChatMode -ne "none" -or $ChatOnce)) {
                return;
            }
        }

        # convert tool functions if needed or use cached ones
        # for continue last conversation
        if ($ContinueLast -and (-not ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0)) -and
            $Global:LMStudioGlobalExposedCmdlets -and ($Global:LMStudioGlobalExposedCmdlets.Count -gt 0)) {

            # take from cache
            $ExposedCmdLets = $Global:LMStudioGlobalExposedCmdlets
        }

        # user has provided exposed cmdlet definitions?
        if ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0) {

            # set global cache if session caching is enabled
            if (-not $NoSessionCaching) {
                $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Converting tool functions to LM Studio format"

            # convert exposed cmdlets to function definitions
            $functions = GenXdev.AI\ConvertTo-LMStudioFunctionDefinition `
                -ExposedCmdLets $ExposedCmdLets
        }

        # create messages list for conversation context
        $messages = [System.Collections.Generic.List[PSCustomObject]] (

            # from cache if available and user wants to continue last conversation?
            (($null -ne $Global:LMStudioChatHistory) -and ($ContinueLast)) ?

            # take from cache
            $Global:LMStudioChatHistory :

            # otherwise, create new
            @()
        )

        # update global chat history if session caching is enabled
        if (-not $NoSessionCaching) {
            $Global:LMStudioChatHistory = $messages
        }

        # create system instruction message
        $newMessage = @{
            role    = "system"
            content = $Instructions
        }

        # add system message if not already present (avoid duplicates)
        $newMessageJson = $newMessage |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress `
            -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $isDuplicate = $false
        foreach ($msg in $messages) {
            if (($msg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress `
                    -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -eq $newMessageJson) {
                $isDuplicate = $true
                break
            }
        }
        if (-not $isDuplicate) {
            Microsoft.PowerShell.Utility\Write-Verbose "System Instructions: $Instructions"
            $null = $messages.Add($newMessage)
        }

        # prepare api endpoint and headers
        $apiUrl = "http://localhost:1234/v1/chat/completions"

        if (-not [string]::IsNullOrWhiteSpace($ApiEndpoint)) {
            $apiUrl = $ApiEndpoint
        }

        # set up http headers including authorization if api key provided
        $headers = @{ "Content-Type" = "application/json" }
        if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {
            $headers."Authorization" = "Bearer $ApiKey"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Initialized conversation with system instructions"
    }

    process {
        if ($ChatOnce) {

            $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\New-LLMTextChat' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            return (GenXdev.AI\New-LLMTextChat @invocationArgs)
        }

        # Just before sending request
        Microsoft.PowerShell.Utility\Write-Verbose "Sending request to LLM with:"
        Microsoft.PowerShell.Utility\Write-Verbose "Model: $Model"
        Microsoft.PowerShell.Utility\Write-Verbose "Query: $Query"
        Microsoft.PowerShell.Utility\Write-Verbose "Temperature: $Temperature"

        switch ($ChatMode) {

            "textprompt" {

                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\New-LLMTextChat' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

                return (GenXdev.AI\New-LLMTextChat @invocationArgs)
            }
            "default audioinput device" {

                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\New-LLMAudioChat' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

                return (GenXdev.AI\New-LLMAudioChat @invocationArgs)
            }
            "desktop audio" {

                $DesktopAudio = $true
                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\New-LLMAudioChat' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

                return (GenXdev.AI\New-LLMAudioChat @invocationArgs)
            }
        }

        # process attachments if provided
        foreach ($attachment in $Attachments) {
            # Process attachments (text or image) as before
            $filePath = GenXdev.FileSystem\Expand-Path $attachment;
            $fileExtension = [IO.Path]::GetExtension($filePath).ToLowerInvariant();
            $mimeType = "application/octet-stream";
            $isText = $false;
            switch ($fileExtension) {
                ".jpg" {
                    $mimeType = "image/jpeg"
                    $isText = $false
                    break;
                }
                ".jpeg" {
                    $mimeType = "image/jpeg"
                    $isText = $false
                    break;
                }
                ".png" {
                    $mimeType = "image/png"
                    $isText = $false
                    break;
                }
                ".gif" {
                    $mimeType = "image/gif"
                    $isText = $false
                    break;
                }
                ".bmp" {
                    $mimeType = "image/bmp"
                    $isText = $false
                    break;
                }
                ".tiff" {
                    $mimeType = "image/tiff"
                    $isText = $false
                    break;
                }
                ".mp4" {
                    $mimeType = "video/mp4"
                    $isText = $false
                    break;
                }
                ".avi" {
                    $mimeType = "video/avi"
                    $isText = $false
                    break;
                }
                ".mov" {
                    $mimeType = "video/quicktime"
                    $isText = $false
                    break;
                }
                ".webm" {
                    $mimeType = "video/webm"
                    $isText = $false
                    break;
                }
                ".mkv" {
                    $mimeType = "video/x-matroska"
                    $isText = $false
                    break;
                }
                ".flv" {
                    $mimeType = "video/x-flv"
                    $isText = $false
                    break;
                }
                ".wmv" {
                    $mimeType = "video/x-ms-wmv"
                    $isText = $false
                    break;
                }
                ".mpg" {
                    $mimeType = "video/mpeg"
                    $isText = $false
                    break;
                }
                ".mpeg" {
                    $mimeType = "video/mpeg"
                    $isText = $false
                    break;
                }
                ".3gp" {
                    $mimeType = "video/3gpp"
                    $isText = $false
                    break;
                }
                ".3g2" {
                    $mimeType = "video/3gpp2"
                    $isText = $false
                    break;
                }
                ".m4v" {
                    $mimeType = "video/x-m4v"
                    $isText = $false
                    break;
                }
                ".webp" {
                    $mimeType = "image/webp"
                    $isText = $false
                    break;
                }
                ".heic" {
                    $mimeType = "image/heic"
                    $isText = $false
                    break;
                }
                ".heif" {
                    $mimeType = "image/heif"
                    $isText = $false
                    break;
                }
                ".avif" {
                    $mimeType = "image/avif"
                    $isText = $false
                    break;
                }
                ".jxl" {
                    $mimeType = "image/jxl"
                    $isText = $false
                    break;
                }
                ".ps1" {
                    $mimeType = "text/x-powershell"
                    $isText = $true
                    break;
                }
                ".psm1" {
                    $mimeType = "text/x-powershell"
                    $isText = $true
                    break;
                }
                ".psd1" {
                    $mimeType = "text/x-powershell"
                    $isText = $true
                    break;
                }
                ".sh" {
                    $mimeType = "application/x-sh"
                    $isText = $true
                    break;
                }
                ".bat" {
                    $mimeType = "application/x-msdos-program"
                    $isText = $true
                    break;
                }
                ".cmd" {
                    $mimeType = "application/x-msdos-program"
                    $isText = $true
                    break;
                }
                ".py" {
                    $mimeType = "text/x-python"
                    $isText = $true
                    break;
                }
                ".rb" {
                    $mimeType = "application/x-ruby"
                    $isText = $true
                    break;
                }
                ".txt" {
                    $mimeType = "text/plain"
                    $isText = $true
                    break;
                }
                ".pl" {
                    $mimeType = "text/x-perl"
                    $isText = $true
                    break;
                }
                ".php" {
                    $mimeType = "application/x-httpd-php"
                    $isText = $true
                    break;
                }
                ".pdf" {
                    $mimeType = "application/pdf"
                    $isText = $false
                    break;
                }
                ".js" {
                    $mimeType = "application/javascript"
                    $isText = $true
                    break;
                }
                ".ts" {
                    $mimeType = "application/typescript"
                    $isText = $true
                    break;
                }
                ".java" {
                    $mimeType = "text/x-java-source"
                    $isText = $true
                    break;
                }
                ".c" {
                    $mimeType = "text/x-c"
                    $isText = $true
                    break;
                }
                ".cpp" {
                    $mimeType = "text/x-c++src"
                    $isText = $true
                    break;
                }
                ".cs" {
                    $mimeType = "text/x-csharp"
                    $isText = $true
                    break;
                }
                ".go" {
                    $mimeType = "text/x-go"
                    $isText = $true
                    break;
                }
                ".rs" {
                    $mimeType = "text/x-rustsrc"
                    $isText = $true
                    break;
                }
                ".swift" {
                    $mimeType = "text/x-swift"
                    $isText = $true
                    break;
                }
                ".kt" {
                    $mimeType = "text/x-kotlin"
                    $isText = $true
                    break;
                }
                ".scala" {
                    $mimeType = "text/x-scala"
                    $isText = $true
                    break;
                }
                ".r" {
                    $mimeType = "text/x-r"
                    $isText = $true
                    break;
                }
                ".sql" {
                    $mimeType = "application/sql"
                    $isText = $true
                    break;
                }
                ".html" {
                    $mimeType = "text/html"
                    $isText = $true
                    break;
                }
                ".css" {
                    $mimeType = "text/css"
                    $isText = $true
                    break;
                }
                ".xml" {
                    $mimeType = "application/xml"
                    $isText = $true
                    break;
                }
                ".json" {
                    $mimeType = "application/json"
                    $isText = $true
                    break;
                }
                ".yaml" {
                    $mimeType = "application/x-yaml"
                    $isText = $true
                    break;
                }
                ".md" {
                    $mimeType = "text/markdown"
                    $isText = $true
                    break;
                }
                default {
                    $mimeType = "image/jpeg"
                    $isText = $false
                    break;
                }
            }
            function getImageBase64Data($filePath, $ImageDetail) {

                $image = $null
                try {
                    $image = [System.Drawing.Image]::FromFile($filePath)
                }
                catch {
                    $image = $null
                }
                if ($null -eq $image) {
                    return [System.Convert]::ToBase64String([IO.File]::ReadAllBytes($filePath))
                }
                $maxImageDimension = [Math]::Max($image.Width, $image.Height);
                $maxDimension = $maxImageDimension;
                switch ($ImageDetail) {
                    "low" {
                        $maxDimension = 800;
                        break;
                    }
                    "medium" {
                        $maxDimension = 1600;
                        break;
                    }
                }
                try {
                    if ($maxDimension -lt $maxImageDimension) {
                        $newWidth = $image.Width;
                        $newHeight = $image.Height;
                        if ($image.Width -gt $image.Height) {
                            $newWidth = $maxDimension
                            $newHeight = [math]::Round($image.Height * ($maxDimension / $image.Width))
                        }
                        else {
                            $newHeight = $maxDimension
                            $newWidth = [math]::Round($image.Width * ($maxDimension / $image.Height))
                        }
                        $scaledImage = Microsoft.PowerShell.Utility\New-Object System.Drawing.Bitmap $newWidth, $newHeight
                        $graphics = [System.Drawing.Graphics]::FromImage($scaledImage)
                        $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
                        $graphics.Dispose();
                    }
                }
                catch {
                }
                $memoryStream = Microsoft.PowerShell.Utility\New-Object System.IO.MemoryStream
                $image.Save($memoryStream, $image.RawFormat)
                $imageData = $memoryStream.ToArray()
                $memoryStream.Close()
                $image.Dispose()
                return [System.Convert]::ToBase64String($imageData)
            }

            [string] $base64Data = getImageBase64Data $filePath $ImageDetail

            if ($isText) {

                $newMessage = @{
                    role    = "user"
                    content = $Query
                    file    = @{
                        name         = [IO.Path]::GetFileName($filePath)
                        content_type = $mimeType
                        bytes        = "data:$mimeType;base64,$base64Data"
                    }
                }
                $newMessageJson = $newMessage | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                $isDuplicate = $false
                foreach ($msg in $messages) {
                    if (($msg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress) -eq $newMessageJson) {
                        $isDuplicate = $true
                        break
                    }
                }
                if (-not $isDuplicate) {

                    $null = $messages.Add($newMessage)
                }
            }
            else {

                $newMessage = @{
                    role    = "user"
                    content = @(
                        @{
                            type      = "image_url"
                            image_url = @{
                                url    = "data:$mimeType;base64,$base64Data"
                                detail = "$ImageDetail"
                            }
                        }
                    )
                }
                $newMessageJson = $newMessage | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                $isDuplicate = $false
                foreach ($msg in $messages) {
                    if (($msg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -eq $newMessageJson) {
                        $isDuplicate = $true
                        break
                    }
                }
                if (-not $isDuplicate) {

                    $null = $messages.Add($newMessage)
                }
            }
        }

        # prepare api payload

        $payload = @{
            stream      = $false
            messages    = $messages
            temperature = $Temperature
        }

        if (-not [string]::IsNullOrWhiteSpace($ResponseFormat)) {
            try {
                $payload.response_format = $ResponseFormat | Microsoft.PowerShell.Utility\ConvertFrom-Json
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Invalid response format schema. Ignoring."
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($Model)) {

            $payload.model = $Model
        }

        if ($MaxToken -gt 0) {

            $payload.max_tokens = $MaxToken
        }

        if ($Functions -and $Functions.Count -gt 0) {

            # maintain array structure, create new array with required properties
            $functionsWithoutCallbacks = @(
                $Functions | Microsoft.PowerShell.Core\ForEach-Object {
                    [PSCustomObject] @{
                        type     = $_.type
                        function = [PSCustomObject] @{
                            name        = $_.function.name
                            description = $_.function.description
                            parameters  = @{
                                type       = 'object'
                                properties = [PSCustomObject] $_.function.parameters.properties
                                required   = $_.function.parameters.required
                            }
                        }
                    }
                }
            )

            $payload.tools = $functionsWithoutCallbacks
            $payload.function_call = "auto"
        }

        if (-not [string]::IsNullOrWhiteSpace($Query)) {

            # add main query message
            $newMsg = @{
                role    = "user"
                content = $Query;
            }

            $null = $messages.Add($newMsg)
        }

        # convert payload to json
        $json = $payload | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 60 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        Microsoft.PowerShell.Utility\Write-Verbose "Querying LM-Studio model '$Model' with parameters:"
        Microsoft.PowerShell.Utility\Write-Verbose $($payload | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 7 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)

        # send request with long timeouts
        $response = Microsoft.PowerShell.Utility\Invoke-RestMethod -Uri $apiUrl `
            -Method Post `
            -Body $bytes `
            -Headers $headers `
            -OperationTimeoutSeconds $TimeoutSeconds `
            -ConnectionTimeoutSeconds $TimeoutSeconds

        # First handle tool calls if present
        if ($response.choices[0].message.tool_calls) {

            # Add assistant's tool calls to history
            $newMsg = $response.choices[0].message
            $newMsgJson = $newMsg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

            # Only add if it's not a duplicate of the last message
            if ($messages.Count -eq 0 -or
                ($messages[-1] | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -ne $newMsgJson) {
                $messages.Add($newMsg) | Microsoft.PowerShell.Core\Out-Null
            }

            # Process all tool calls sequentially
            foreach ($toolCallCO in $response.choices[0].message.tool_calls) {

                $toolCall = $toolCallCO | GenXdev.Helpers\ConvertTo-HashTable

                Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected: $($toolCall.function.name)"

                # Format parameters as PowerShell command line style
                $foundArguments = ($toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json)
                $paramLine = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json |
                Microsoft.PowerShell.Utility\Get-Member -MemberType NoteProperty |
                Microsoft.PowerShell.Core\ForEach-Object {
                    $name = $_.Name
                    $value = $foundArguments.$name
                    "-$name $($value | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue)"
                } | Microsoft.PowerShell.Utility\Join-String -Separator " "

                Microsoft.PowerShell.Utility\Write-Verbose "PS> $($toolCall.function.name) $paramLine"
                if (-not ($Verbose -or $VerbosePreference -eq "Continue")) {

                    Microsoft.PowerShell.Utility\Write-Host "PS> $($toolCall.function.name) $paramLine" -ForegroundColor Cyan
                }

                [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                    -ToolCall:$toolCall `
                    -Functions:$Functions `
                    -ExposedCmdLets:$ExposedCmdLets `
                    -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames | Microsoft.PowerShell.Utility\Select-Object -First 1

                if (-not ($Verbose -or $VerbosePreference -eq "Continue")) {

                    Microsoft.PowerShell.Utility\Write-Host "$($invocationResult.Output | Microsoft.PowerShell.Core\ForEach-Object { if ($_ -is [string]) { $_ } else { $_ | Microsoft.PowerShell.Utility\Out-String } })" -ForegroundColor Green
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Tool function result: $($invocationResult | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3 -Compress)"

                if (-not $invocationResult.CommandExposed) {

                    # Add tool response to history
                    $null = $messages.Add(@{
                            role         = "tool"
                            name         = $toolCall.function.name
                            content      = $invocationResult.Error ? $invocationResult.Error : $invocationResult.Reason
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json
                        })
                }
                else {
                    # Add tool response to history
                    $null = $messages.Add(@{
                            role         = "tool"
                            name         = $toolCall.function.name
                            content      = "$($invocationResult.Output)".Trim()
                            content_type = $invocationResult.OutputType
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json
                        })
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Continuing conversation after tool responses"

            if (-not $PSBoundParameters.ContainsKey('ContinueLast')) {

                $PSBoundParameters.Add('ContinueLast', $true)
            }
            else {

                $PSBoundParameters['ContinueLast'] = $true
            }

            if (-not $PSBoundParameters.ContainsKey('Query')) {

                $PSBoundParameters.Add('Query', "")
            }
            else {

                $PSBoundParameters['Query'] = ""
            }

            GenXdev.AI\Invoke-LLMQuery @PSBoundParameters

            return;
        }

        # Handle regular message content if no tool calls
        [System.Collections.Generic.List[object]] $finalOutput = @()

        foreach ($msg in $response.choices.message) {

            $content = $msg.content

            # Extract and process embedded tool calls
            # Try multiple formats that LLMs might use for tool function calls

            # Format 1: <tool_call>{...}</tool_call>
            while ($content -match '<tool_call>\s*({[^}]+})\s*</tool_call>') {
                $toolCallJson = $matches[1]
                try {
                    # parse the json into a tool call object
                    $toolCall = $toolCallJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev.Helpers\ConvertTo-HashTable

                    # verify this has the expected properties for a function call
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected (Format 1): $($toolCall.function.name)"

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # if we can't process it, replace with error message
                    $content = $content.Replace($matches[0], "Error processing tool call: $($_.Exception.Message)")
                }
            }

            # Format 2: [FUNCTION_CALL]{...}[/FUNCTION_CALL]
            while ($content -match '\[FUNCTION_CALL\]\s*({[^}]+})\s*\[/FUNCTION_CALL\]') {
                $toolCallJson = $matches[1]
                try {
                    # parse the json into a tool call object
                    $toolCall = $toolCallJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev.Helpers\ConvertTo-HashTable

                    # verify this has the expected properties for a function call
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected (Format 2): $($toolCall.function.name)"

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # if we can't process it, replace with error message
                    $content = $content.Replace($matches[0], "Error processing tool call: $($_.Exception.Message)")
                }
            }

            # Format 3: <function>{...}</function>
            while ($content -match '<function>\s*({[^}]+})\s*</function>') {
                $toolCallJson = $matches[1]
                try {
                    # parse the json into a tool call object
                    $toolCall = $toolCallJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev.Helpers\ConvertTo-HashTable

                    # verify this has the expected properties for a function call
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected (Format 3): $($toolCall.function.name)"

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # if we can't process it, replace with error message
                    $content = $content.Replace($matches[0], "Error processing tool call: $($_.Exception.Message)")
                }
            }

            # Format 4: Check for code blocks with function calls
            while ($content -match '```(?:json)?\s*({[\s\S]*?"function"[\s\S]*?})\s*```') {
                $potentialJson = $matches[1].Trim()
                try {
                    # Try to parse as a function call
                    $toolCall = $potentialJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev.Helpers\ConvertTo-HashTable

                    # Verify this is actually a function call with the expected properties
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Tool call detected (Format 4): $($toolCall.function.name)")

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # not a valid function call, leave it as is
                    # only replace if we're sure it's a function call
                }
            }

            # update chat history with assistant's response
            # convert message to json and back to create a copy
            $messageForHistory = $msg |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -WarningAction SilentlyContinue |
                Microsoft.PowerShell.Utility\ConvertFrom-Json -WarningAction SilentlyContinue

            # decide whether to include thoughts in history based on parameter
            $messageForHistory.content = $DontAddThoughtsToHistory ?
                [regex]::Replace($content, "<think>.*?</think>", "") :
                $content

            # add the message to conversation history
            $null = $messages.Add($messageForHistory)

            # process content if not empty
            if (-not [string]::IsNullOrWhiteSpace($content)) {

                # if including thoughts, add raw content to output
                if ($IncludeThoughts) {
                    $null = $finalOutput.Add($content)
                }

                # extract and process thought content between <think> tags
                $i = $content.IndexOf("<think>")
                if ($i -ge 0) {
                    # skip the opening tag
                    $i += 7
                    $i2 = $content.IndexOf("</think>")
                    if ($i2 -ge 0) {
                        # extract thought content between tags
                        $thoughts = $content.Substring($i, $i2 - $i)
                        Microsoft.PowerShell.Utility\Write-Verbose "LLM Thoughts: $thoughts"

                        # display thoughts if not including them in output
                        if (-not $IncludeThoughts) {
                            Microsoft.PowerShell.Utility\Write-Host $thoughts -ForegroundColor Yellow
                        }

                        # speak thoughts if enabled
                        if ($SpeakThoughts) {
                            $null = GenXdev.Console\Start-TextToSpeech $thoughts
                        }
                    }
                }

                # Remove <think> patterns
                $cleaned = [regex]::Replace($content, "<think>.*?</think>", "")
                Microsoft.PowerShell.Utility\Write-Verbose "LLM Response: $cleaned"

                if ($OutputMarkupBlocksOnly) {

                    $null = $finalOutput.RemoveAt($finalOutput.Count - 1);

                    $cleaned = "`n$cleaned`n"
                    $i = $cleaned.IndexOf("`n``````");
                    while ($i -ge 0) {

                        $i += 4;
                        $i2 = $cleaned.IndexOf("`n", $i);
                        $name = $cleaned.Substring($i, $i2 - $i).Trim().ToLowerInvariant();

                        $i = $i2 + 1;
                        $i2 = $cleaned.IndexOf("`n``````", $i);
                        if ($i2 -ge 0) {

                            $codeBlock = $cleaned.Substring($i, $i2 - $i);
                            $codeBlock = $json.Trim();
                            if ($name -in $MarkupBlocksTypeFilter) {

                                $null = $finalOutput.Add($codeBlock);
                            }
                        }

                        $i = $cleaned.IndexOf("`n``````", $i2 + 4);
                    }
                }
                else {

                    $null = $finalOutput.Add($cleaned)

                    if ($Speak) {

                        $null = GenXdev.Console\Start-TextToSpeech $cleaned
                    }
                }
            }
        }
        $finalOutput | Microsoft.PowerShell.Core\ForEach-Object {

            Microsoft.PowerShell.Utility\Write-Output $_
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Conversation history updated"
    }
}
        ###############################################################################