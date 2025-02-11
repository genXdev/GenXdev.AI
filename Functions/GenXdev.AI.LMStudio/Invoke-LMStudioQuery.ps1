################################################################################
<#
.SYNOPSIS
Sends queries to LM Studio and processes responses.

.DESCRIPTION
Interacts with LM Studio to process queries, handle tool calls, and manage
conversation history. Supports attachments, system instructions, and function
definitions.

.PARAMETER Query
Text query to send to the model.

.PARAMETER Model
Name or partial path of the model to initialize, detects and excepts -like 'patterns*' for search

.PARAMETER ModelLMSGetIdentifier
Identifier used for getting specific model from LM Studio.

.PARAMETER Instructions
System instructions for the model.

.PARAMETER Attachments
Array of file paths to attach to the query.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0). Default is 0.0.

.PARAMETER MaxToken
Maximum tokens in response (-1 for default).

.PARAMETER ImageDetail
Image detail level (low/medium/high). Default is "low".

.PARAMETER IncludeThoughts
Include model's thoughts in output.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER Functions
Array of function definitions.

.PARAMETER ExposedCmdLets
Array of PowerShell commands to use as tools.

.PARAMETER NoConfirmationFor
Array of ToolFunction names that don't require user confirmation.

.PARAMETER ShowWindow
Show the LM Studio window.

.PARAMETER TTLSeconds
Set a TTL (in seconds) for models loaded via API requests.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER ChatMode
Enable chat mode.

.PARAMETER ChatOnce
Used internally to only invoke chat mode once after the llm invocation.

.EXAMPLE
Invoke-LMStudioQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7

.EXAMPLE
qlms "What is 2+2?" -Model "qwen"
#>
function Invoke-LMStudioQuery {

    [CmdletBinding()]
    [Alias("qlms", "qllm", "llm")]

    param(
        ########################################################################
        [Parameter(
            ValueFromPipeline = $true,
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
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Identifier used for getting specific model from LM Studio"
        )]
        [string] $ModelLMSGetIdentifier,
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
        [switch] $NoSessionCaching
    )

    begin {

        $initializationParams = Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'Initialize-LMStudioModel'

        if ($PSBoundParameters.ContainsKey("Force")) {

            $null = $PSBoundParameters.Remove("Force")
        }

        $modelInfo = Initialize-LMStudioModel @initializationParams
        $Model = $modelInfo.identifier

        if ($PSBoundParameters.ContainsKey("ShowWindow")) {

            $null = $PSBoundParameters.Remove("ShowWindow")
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

            $null = $messages.Add($newMessage)
        }

        # prepare api endpoint
        $apiUrl = "http://localhost:1234/v1/chat/completions"
        $headers = @{ "Content-Type" = "application/json" }

        Write-Verbose "Initialized conversation with system instructions"
    }

    process {

        if ($ChatOnce -or ((-not [string]::IsNullOrWhiteSpace($Chatmode) -and ($ChatMode -ne "none")))) {

            if ($PSBoundParameters.ContainsKey("NoConfirmationToolFunctionNames")) {

                $null = $PSBoundParameters.Remove("NoConfirmationToolFunctionNames")
            }
        }

        if ($ChatOnce) {

            $invocationArgs = Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'New-LLMTextChat'

            return (New-LLMTextChat @invocationArgs)
        }

        switch ($ChatMode) {

            "textprompt" {

                $invocationArgs = Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'New-LLMTextChat'

                return (New-LLMTextChat @invocationArgs)
            }
            "default audioinput device" {

                $invocationArgs = Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'New-LLMAudioChat'

                return (New-LLMAudioChat @invocationArgs)
            }
            "desktop audio" {

                if (-not $PSBoundParameters.ContainsKey("DesktopAudio")) {

                    $null = $PSBoundParameters.Add("DesktopAudio", $true)
                }

                $invocationArgs = Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'New-LLMAudioChat'

                return (New-LLMAudioChat @invocationArgs)
            }
        }

        # process attachments if provided
        foreach ($attachment in $Attachments) {
            # Process attachments (text or image) as before...
            $filePath = Expand-Path $attachment;
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
            model       = "$Model"
            messages    = $messages
            temperature = $Temperature
            max_tokens  = $MaxToken
        }

        if ($Functions -and $Functions.Count -gt 0) {

            # maintain array structure, create new array with required properties
            $functionsWithoutCallbacks = @(
                $Functions | ForEach-Object {
                    [PSCustomObject] @{
                        type     = $_.type
                        function = [PSCustomObject] @{
                            name                       = $_.function.name
                            description                = $_.function.description
                            parameters                 = @{
                                type       = 'object'
                                properties = [PSCustomObject] $_.function.parameters.properties
                                required   = $_.function.parameters.required
                            }
                            user_confirmation_required = $_.function.user_confirmation_required -eq $true
                        }
                    }
                }
            )

            $payload.tools = $functionsWithoutCallbacks
            $payload.function_call = "auto"
            if (-not [string]::IsNullOrWhiteSpace($Query)) {

                $Query = "You now have access to and only to the following Powershell cmdlets: $(($Functions.function.name | Select-Object -Unique | ConvertTo-Json -Compress -Depth 1 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue))`r`n$Query"
            }
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

        Write-Verbose "Querying LM-Studio model '$Model"

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

                [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = Invoke-CommandFromToolCall `
                    -ToolCall:$toolCall `
                    -Functions:$Functions `
                    -ExposedCmdLets:$ExposedCmdLets `
                    -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames | Select-Object -First 1

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

            Invoke-LMStudioQuery @PSBoundParameters

            return;
        }

        # Handle regular message content if no tool calls
        $finalOutput = ""
        foreach ($msg in $response.choices.message) {

            $content = $msg.content

            # Extract and process embedded tool calls
            while ($content -match '<tool_call>\s*({[^}]+})\s*</tool_call>') {

                $toolCallJson = $matches[1]
                $toolCall = $null

                try {
                    $toolCall = $toolCallJson | ConvertFrom-Json | ConvertTo-HashTable

                    Write-Verbose "Tool call detected: $($toolCall.function.name)"

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

            if (-not [string]::IsNullOrWhiteSpace($content)) {

                if ($IncludeThoughts) {

                    $finalOutput += $content + "`n"
                }

                # Process thoughts as before
                $i = $content.IndexOf("<think>")
                if ($i -ge 0) {
                    $i += 7
                    $i2 = $content.IndexOf("</think>")
                    if ($i2 -ge 0) {

                        $thoughts = $content.Substring($i, $i2 - $i)

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
                $finalOutput += $cleaned + "`n"
            }
        }

        Write-Output $finalOutput

        if ($Speak) {

            $null = Start-TextToSpeech $finalOutput
        }

        # Update chat history with assistant's response
        $null = $messages.Add(@{
                role    = "assistant"
                content = $finalOutput
            })

        Write-Verbose "Conversation history updated"
    }
}
################################################################################
