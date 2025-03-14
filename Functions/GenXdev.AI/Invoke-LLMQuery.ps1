################################################################################
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

.PARAMETER ModelLMSGetIdentifier
Alternative identifier for getting a specific model from LM Studio.

.PARAMETER Instructions
System instructions to provide context to the model.

.PARAMETER Attachments
Array of file paths to attach to the query. Supports images and text files.

.PARAMETER Temperature
Controls response randomness (0.0-1.0). Lower values are more deterministic.

.PARAMETER MaxToken
Maximum tokens allowed in the response. Use -1 for model default.

.PARAMETER ImageDetail
Detail level for image processing (low/medium/high).

.PARAMETER IncludeThoughts
Include model's thought process in output.

.PARAMETER ContinueLast
Continue from the last conversation context.

.PARAMETER Functions
Array of function definitions that the model can call.

.PARAMETER ExposedCmdLets
PowerShell commands to expose as tools to the model.

.PARAMETER NoConfirmationFor
Tool functions that don't require user confirmation.

.PARAMETER ShowWindow
Show the LM Studio window during processing.

.PARAMETER TTLSeconds
Time-to-live in seconds for loaded models.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.PARAMETER ChatMode
Enable interactive chat mode with specified input method.

.PARAMETER ChatOnce
Internal parameter to control chat mode invocation.

.EXAMPLE
Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7

.EXAMPLE
qllm "What is 2+2?" -Model "qwen"
#>
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
            HelpMessage = "The LM-Studio model to use"
        )]
        [SupportsWildcards()]
        [string] $Model = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier = "qwen2.5-14b-instruct",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "System instructions for the model")]
        [string] $Instructions,
        ########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Array of file paths to attach")]
        [string[]] $Attachments = @(),
        ########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "A JSON schema for the requested output format")]
        [string] $ResponseFormat = $null,
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
        [int] $MaxToken = -1,
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
            HelpMessage = "Array of function definitions")]
        [hashtable[]] $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools")]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        # Array of command names that don't require confirmation
        [Parameter(Mandatory = $false)]
        [string[]]
        [Alias("NoConfirmationFor")]
        $NoConfirmationToolFunctionNames = @(),
        ###########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI responses",
            Mandatory = $false
        )]
        [switch] $Speak,
        ###########################################################################
        [Parameter(
            HelpMessage = "Enable text-to-speech for AI thought responses",
            Mandatory = $false
        )]
        [switch] $SpeakThoughts,
        ###########################################################################
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
            HelpMessage = "Api endpoint url, defaults to http://localhost:1234/v1/chat/completions")]
        [string] $ApiEndpoint = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The API key to use for the request")]
        [string] $ApiKey = $null
        ########################################################################
    )

    begin {
        Write-Verbose "Starting LLM interaction..."

        $MarkupBlocksTypeFilter = $MarkupBlocksTypeFilter | ForEach-Object { $_.ToLowerInvariant() }

        # initialize lm studio if using localhost
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or
            $ApiEndpoint.Contains("localhost")) {

            $initParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Get-Variable -Scope Local -Name * `
                    -ErrorAction SilentlyContinue)

            if ($PSBoundParameters.ContainsKey("Force")) {
                $null = $PSBoundParameters.Remove("Force")
                $Force = $false
            }

            $modelInfo = Initialize-LMStudioModel @initParams
            $Model = $modelInfo.identifier
        }

        if ($PSBoundParameters.ContainsKey("ShowWindow")) {

            $null = $PSBoundParameters.Remove("ShowWindow")
            $ShowWindow = $false
        }

        if ($PSBoundParameters.ContainsKey("ChatMode")) {

            $null = $PSBoundParameters.Remove("ChatMode")

            if (($ChatMode -ne "none" -or $ChatOnce)) {

                return;
            }
        }

        # convert tool functions if needed
        # or take from global cache if available and user wants to continue last conversation
        if ($ContinueLast -and (-not ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0)) -and
            $Global:LMStudioGlobalExposedCmdlets -and ($Global:LMStudioGlobalExposedCmdlets.Count -gt 0)) {

            # take from cache
            $ExposedCmdLets = $Global:LMStudioGlobalExposedCmdlets
        }

        # user has provided exposed cmdlet definitions?
        if ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0) {

            # set global cache
            if (-not $NoSessionCaching) {

                $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
            }

            Write-Verbose "Converting tool functions to LM Studio format"

            # convert them
            $functions = ConvertTo-LMStudioFunctionDefinition `
                -ExposedCmdLets $ExposedCmdLets
        }

        $messages = [System.Collections.Generic.List[PSCustomObject]] (

            # from cache if available and user wants to continue last conversation?
            (($null -ne $Global:LMStudioChatHistory) -and ($ContinueLast)) ?

            # take from cache
            $Global:LMStudioChatHistory :

            # otherwise, create new
            @()
        )

        if (-not $NoSessionCaching) {

            # initialize message array for conversation
            $Global:LMStudioChatHistory = $messages
        }

        # add system instructions if provided
        $newMessage = @{
            role    = "system"
            content = $Instructions
        }

        # add if not already present
        $newMessageJson = $newMessage | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $isDuplicate = $false
        foreach ($msg in $messages) {
            if (($msg | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -eq $newMessageJson) {
                $isDuplicate = $true
                break
            }
        }
        if (-not $isDuplicate) {
            Write-Verbose "System Instructions: $Instructions"
            $null = $messages.Add($newMessage)
        }

        # prepare api endpoint

        $apiUrl = "http://localhost:1234/v1/chat/completions"

        if (-not [string]::IsNullOrWhiteSpace($ApiEndpoint)) {

            $apiUrl = $ApiEndpoint
        }

        $headers = @{ "Content-Type" = "application/json" }
        if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {

            $headers."Authorization" = "Bearer $ApiKey"
        }

        Write-Verbose "Initialized conversation with system instructions"
    }

    process {

        if ($ChatOnce) {

            $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\New-LLMTextChat' `
                -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            return (New-LLMTextChat @invocationArgs)
        }
        # Just before sending request
        Write-Verbose "Sending request to LLM with:"
        Write-Verbose "Model: $Model"
        Write-Verbose "Query: $Query"
        Write-Verbose "Temperature: $Temperature"


        switch ($ChatMode) {

            "textprompt" {

                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\New-LLMTextChat' `
                    -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

                return (New-LLMTextChat @invocationArgs)
            }
            "default audioinput device" {

                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\New-LLMAudioChat' `
                    -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

                return (New-LLMAudioChat @invocationArgs)
            }
            "desktop audio" {

                $DesktopAudio = $true
                $invocationArgs = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev.AI\New-LLMAudioChat' `
                    -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

                return (New-LLMAudioChat @invocationArgs)
            }
        }

        # process attachments if provided
        foreach ($attachment in $Attachments) {
            # Process attachments (text or image) as before...
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
                        $scaledImage = New-Object System.Drawing.Bitmap $newWidth, $newHeight
                        $graphics = [System.Drawing.Graphics]::FromImage($scaledImage)
                        $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
                        $graphics.Dispose();
                    }
                }
                catch {
                }
                $memoryStream = New-Object System.IO.MemoryStream
                $image.Save($memoryStream, $image.RawFormat)
                $imageData = $memoryStream.ToArray()
                $memoryStream.Close()
                $image.Dispose()
                return [System.Convert]::ToBase64String($imageData)
            }

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
                $newMessageJson = $newMessage | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                $isDuplicate = $false
                foreach ($msg in $messages) {
                    if (($msg | ConvertTo-Json -Depth 10 -Compress) -eq $newMessageJson) {
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
                $newMessageJson = $newMessage | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                $isDuplicate = $false
                foreach ($msg in $messages) {
                    if (($msg | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -eq $newMessageJson) {
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
                $payload.response_format = $ResponseFormat | ConvertFrom-Json
            }
            catch {
                Write-Warning "Invalid response format schema. Ignoring."
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
                $Functions | ForEach-Object {
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
        $json = $payload | ConvertTo-Json -Depth 60 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)

        Write-Verbose "Querying LM-Studio model '$Model' with parameters:"
        Write-Verbose $($payload | ConvertTo-Json -Depth 7 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)

        # send request with long timeouts
        $response = Invoke-RestMethod -Uri $apiUrl `
            -Method Post `
            -Body $bytes `
            -Headers $headers `
            -OperationTimeoutSeconds (3600 * 24) `
            -ConnectionTimeoutSeconds (3600 * 24)

        # First handle tool calls if present
        if ($response.choices[0].message.tool_calls) {

            # Add assistant's tool calls to history
            $newMsg = $response.choices[0].message
            $newMsgJson = $newMsg | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

            # Only add if it's not a duplicate of the last message
            if ($messages.Count -eq 0 -or
                ($messages[-1] | ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -ne $newMsgJson) {
                $messages.Add($newMsg) | Out-Null
            }

            # Process all tool calls sequentially
            foreach ($toolCallCO in $response.choices[0].message.tool_calls) {

                $toolCall = $toolCallCO | ConvertTo-HashTable

                Write-Verbose "Tool call detected: $($toolCall.function.name)"

                # Format parameters as PowerShell command line style
                $foundArguments = ($toolCall.function.arguments | ConvertFrom-Json)
                $paramLine = $toolCall.function.arguments | ConvertFrom-Json |
                Get-Member -MemberType NoteProperty |
                ForEach-Object {
                    $name = $_.Name
                    $value = $foundArguments.$name
                    "-$name $($value | ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue)"
                } | Join-String -Separator " "

                Write-Verbose "PS> $($toolCall.function.name) $paramLine"
                if (-not ($Verbose -or $VerbosePreference -eq "Continue")) {

                    Write-Host "PS> $($toolCall.function.name) $paramLine" -ForegroundColor Cyan
                }

                [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = Invoke-CommandFromToolCall `
                    -ToolCall:$toolCall `
                    -Functions:$Functions `
                    -ExposedCmdLets:$ExposedCmdLets `
                    -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames | Select-Object -First 1

                if (-not ($Verbose -or $VerbosePreference -eq "Continue")) {

                    Write-Host "$($invocationResult.Output | ForEach-Object { if ($_ -is [string]) { $_ } else { $_ | Out-String } })" -ForegroundColor Green
                }

                Write-Verbose "Tool function result: $($invocationResult | ConvertTo-Json -Depth 3 -Compress)"

                if (-not $invocationResult.CommandExposed) {

                    # Add tool response to history
                    $null = $messages.Add(@{
                            role         = "tool"
                            name         = $toolCall.function.name
                            content      = $invocationResult.Error ? $invocationResult.Error : $invocationResult.Reason
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | ConvertFrom-Json
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
                            arguments    = $toolCall.function.arguments | ConvertFrom-Json
                        })
                }
            }

            Write-Verbose "Continuing conversation after tool responses"

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

            Invoke-LLMQuery @PSBoundParameters

            return;
        }

        # Handle regular message content if no tool calls
        [System.Collections.Generic.List[object]] $finalOutput = @()

        foreach ($msg in $response.choices.message) {

            $content = $msg.content

            # Extract and process embedded tool calls
            while ($content -match '<tool_call>\s*({[^}]+})\s*</tool_call>') {

                $toolCallJson = $matches[1]
                $toolCall = $null

                try {
                    $toolCall = $toolCallJson | ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue | ConvertTo-HashTable

                    Write-Verbose "Tool call detected: $($toolCall.function.name)"

                    # Format parameters as PowerShell command line style
                    $foundArguments = ($toolCall.function.arguments | ConvertFrom-Json)
                    $paramLine = $toolCall.function.arguments | ConvertFrom-Json |
                    Get-Member -MemberType NoteProperty |
                    ForEach-Object {
                        $name = $_.Name
                        $value = $foundArguments.$name
                        "-$name $($value | ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue)"
                    } | Join-String -Separator " "

                    Write-Verbose "PS> $($toolCall.function.name) $paramLine"
                    if (-not ($Verbose -or $VerbosePreference -eq "Continue")) {
                        Write-Host "PS> $($toolCall.function.name) $paramLine" -ForegroundColor Cyan
                    }
                    # Check if this tool_call_id is already in messages
                    $existingResponse = $messages | Where-Object {
                        $_.tool_call_id -eq $toolCall.id
                    } | Select-Object -First 1

                    if ($existingResponse) {
                        # Replace the tool call with existing response
                        $replacement = [string]::IsNullOrWhiteSpace($existingResponse.Content) ?
                            ($existingResponse.Error | ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) :
                        $existingResponse.Content;

                        $content = $content.Replace($matches[0], $replacement)
                        continue
                    }

                    [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = Invoke-CommandFromToolCall `
                        -ToolCall:$toolCall `
                        -Functions:$Functions `
                        -ExposedCmdLets:$ExposedCmdLets `
                        -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames `
                        -ForceAsText | Select-Object -First 1

                    if ((-not ($Verbose -or $VerbosePreference -eq "Continue")) -and
                        ($null -ne $invocationResult.Output)) {

                        Write-Host "$($invocationResult.Output | ForEach-Object { if ($_ -is [string]) { $_ } else { $_ | Out-String } })" -ForegroundColor Green
                    }

                    Write-Verbose "Tool function result: $($invocationResult | ConvertTo-Json -Depth 3 -Compress)"

                    if (-not $invocationResult.CommandExposed) {

                        $newMessage = @{
                            role         = "tool"
                            name         = $toolCall.function.name
                            content      = $invocationResult.Error ? ($invocationResult.Error | ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) : $invocationResult.Reason
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | ConvertFrom-Json
                        };

                        # Add tool response to history
                        $null = $messages.Add($newMessage)

                        $content = $content.Replace($matches[0], $newMessage.error)
                    }
                    else {

                        $newMessage = @{
                            role         = "tool"
                            name         = $toolCall.function.name
                            content      = "$($invocationResult.Output)".Trim()
                            content_type = $invocationResult.OutputType
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | ConvertFrom-Json
                        };

                        # Add tool response to history
                        $null = $messages.Add($newMessage)

                        $content = $content.Replace($matches[0], $newMessage.content)
                    }
                }
                catch {

                    $newMessage = @{
                        role         = "tool"
                        name         = $toolCall.function.name
                        error        = @{
                            error           = $_.Exception.Message
                            exceptionThrown = $true
                            exceptionClass  = $_.Exception.GetType().FullName
                        } | ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue;
                        tool_call_id = $toolCall.id
                        id           = $toolCall.id
                        arguments    = $toolCall.function.arguments | ConvertFrom-Json
                    };

                    # Add tool response to history
                    $null = $messages.Add($newMessage)

                    $content = $content.Replace($matches[0], $newMessage.error)
                }
            }

            # Update chat history with assistant's response
            if (-not $DontAddThoughtsToHistory) {
                $msg.content = $content;
                $null = $messages.Add($msg)
            }

            if (-not [string]::IsNullOrWhiteSpace($content)) {

                if ($IncludeThoughts) {

                    $finalOutput.Add($content)
                }

                # Process thoughts as before
                $i = $content.IndexOf("<think>")
                if ($i -ge 0) {
                    $i += 7
                    $i2 = $content.IndexOf("</think>")
                    if ($i2 -ge 0) {

                        $thoughts = $content.Substring($i, $i2 - $i)
                        Write-Verbose "LLM Thoughts: $thoughts"

                        if (-not $IncludeThoughts) {

                            Write-Host $thoughts -ForegroundColor Yellow
                        }

                        if ($SpeakThoughts) {

                            $null = Start-TextToSpeech $thoughts
                        }
                    }
                }

                # Remove <think> patterns
                $cleaned = [regex]::Replace($content, "<think>.*?</think>", "")
                Write-Verbose "LLM Response: $cleaned"

                if ($DontAddThoughtsToHistory) {

                    $msg.content = $cleaned;
                    $null = $messages.Add($msg)
                }

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

                        $null = Start-TextToSpeech $cleaned
                    }
                }
            }
        }
        $finalOutput | ForEach-Object {

            Write-Output $_
        }

        Write-Verbose "Conversation history updated"
    }
}
################################################################################