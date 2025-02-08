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
The LM-Studio model to use. Defaults to "qwen".

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

.PARAMETER ShowLMStudioWindow
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
        [PSCustomObject[]] $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell cmdlet or function references " +
            "to use as tools, use Get-Command to obtain such references"        )]
        [System.Management.Automation.CommandInfo[]]
        $ExposedCmdLets = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of ToolFunction names that don't require user confirmation"
        )]
        [Alias("NoConfirmationFor")]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM Studio window")]
        [switch] $ShowLMStudioWindow,
        ########################################################################
        [Alias("ttl")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set a TTL (in seconds) for models loaded via API requests")]
        [int] $TTLSeconds = -1,
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
        [switch] $ChatOnce
    )

    begin {

        if ($PSBoundParameters.ContainsKey("ChatMode")) {

            $null = $PSBoundParameters.Remove("ChatMode")

            if (($ChatMode -ne "none" -or $ChatOnce)) {

                return;
            }
        }

        if ([string]::IsNullOrWhiteSpace($Model)) {

            if (-not [string]::IsNullOrWhiteSpace($ModelLMSGetIdentifier)) {

                if ($ModelLMSGetIdentifier.ToLowerInvariant() -like "https://huggingface.co/lmstudio-community/*-GGUF") {

                    $Model = $ModelLMSGetIdentifier.Substring($ModelLMSGetIdentifier.LastIndexOf("/") + 1).ToLowerInvariant();
                }
                else {

                    $Model = $ModelLMSGetIdentifier
                }
            }
            else {

                $Model = "qwen*-instruct"
                $ModelLMSGetIdentifier = "qwen2.5-14b-instruct"
            }
        }

        # initialize lm studio application
        Write-Verbose "Starting LM Studio application"
        $null = Start-LMStudioApplication -ShowWindow:$ShowLMStudioWindow

        # initialize model
        Write-Verbose "Initializing model: $Model"

        $initializationParams = @{
            Model                 = $Model
            ModelLMSGetIdentifier = $ModelLMSGetIdentifier
            MaxToken              = $MaxToken
        }
        if ($PSBoundParameters.ContainsKey("TTLSeconds")) {

            $initializationParams.TTLSeconds = $TTLSeconds
        }
        if ($PSBoundParameters.ContainsKey("ShowLMStudioWindow")) {

            $initializationParams.ShowWindow = $ShowLMStudioWindow
        }
        if ($PreferredModels -and $PreferredModels.Count -gt 0) {

            $initializationParams.Add("PreferredModels", $PreferredModels)
        }

        $modelInfo = Initialize-LMStudioModel @initializationParams 2> $null
        $Model = $modelInfo.identifier

        # convert tool functions if needed
        if ($ContinueLast -and (-not ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0)) -and
            $Global:LMStudioGlobalExposedCmdlets -and
                ($Global:LMStudioGlobalExposedCmdlets.Count -gt 0)) {

            $ExposedCmdLets = $Global:LMStudioGlobalExposedCmdlets
        }

        if ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0) {

            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
            Write-Verbose "Converting tool functions to LM Studio format"
            $functions = ConvertTo-LMStudioFunctionDefinition `
                -ExposedCmdLets $ExposedCmdLets `
                -NoConfirmationFor $NoConfirmationToolFunctionNames
        }

        $Global:LMStudioChatHistory = [System.Collections.Generic.List[PSCustomObject]] ((($null -ne $Global:LMStudioChatHistory) -and ($ContinueLast)) ? $Global:LMStudioChatHistory : @())

        # initialize message array for conversation
        $messages = $Global:LMStudioChatHistory;

        $newMessage = @{
            role    = "system"
            content = $Instructions
        }

        $newMessageJson = $newMessage | ConvertTo-Json -Depth 10 -Compress
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

        # prepare api endpoint
        $apiUrl = "http://localhost:1234/v1/chat/completions"
        $headers = @{ "Content-Type" = "application/json" }

        Write-Verbose "Initialized conversation with system instructions"
    }

    process {

        if ($ChatOnce) {

            return (New-TextLLMChat @PSBoundParameters)
        }

        switch ($ChatMode) {

            "textprompt" {

                return (New-TextLLMChat @PSBoundParameters)
            }
            "default audioinput device" {

                return (New-AudioLLMChat @PSBoundParameters)
            }
            "desktop audio" {

                if (-not $PSBoundParameters.ContainsKey("DesktopAudio")) {

                    $null = $PSBoundParameters.Add("DesktopAudio", $true)
                }

                return (New-AudioLLMChat @PSBoundParameters)
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
                $newMessageJson = $newMessage | ConvertTo-Json -Depth 10 -Compress
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
                $newMessageJson = $newMessage | ConvertTo-Json -Depth 10 -Compress
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
                    @{
                        type     = $_.type
                        function = @{
                            name        = $_.function.name
                            description = $_.function.description
                            parameters  = $_.function.parameters
                        }
                    }
                }
            )

            $payload.tools = $functionsWithoutCallbacks
            $payload.function_call = "auto"
            $Query = "You now have access to and only to the following Powershell cmdlets: $(($Functions.function.name | Select-Object -Unique | ConvertTo-Json -Compress -Depth 1))`r`n$Query"
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
        $json = $payload | ConvertTo-Json -Depth 60 -Compress
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
            $messages.Add($response.choices[0].message) | Out-Null

            # Process all tool calls sequentially
            foreach ($toolCall in $response.choices[0].message.tool_calls) {

                Write-Verbose "Tool call detected: $($toolCall.function.name)"

                $invocationParams = @{}
                try {
                    $invocationParams = $toolCall.function.arguments | ConvertFrom-Json
                }
                catch {
                    Write-Error "Failed to parse function arguments: $($_.Exception.Message)"
                    continue
                }

                # Find matching function with callback
                $matchedFunc = $Functions.function | Where-Object { $_.name -eq $toolCall.function.name } | Select-Object -First 1

                if (-not $matchedFunc) {

                    $messages.Add(@{
                            role         = "tool"
                            name         = $toolCall.function.name
                            error        = "Function not found"
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | ConvertFrom-Json
                        }) | Out-Null
                }
                elseif ($matchedFunc.ContainsKey("callback") -and ($null -ne ($matchedFunc.callback))) {

                    # Execute callback and get result
                    Write-Verbose "Executing callback for function: $($toolCall.function.name), params = $($invocationParams | ConvertTo-Json)"

                    Write-Verbose "Final parameter hashtable: $($invocationParams | ConvertTo-Json)"

                    # Ensure we're using splatting for the callback
                    $cb = $matchedFunc.callback;
                    if ($cb -isnot [System.Management.Automation.ScriptBlock] -and
                        $cb -isnot [System.Management.Automation.CommandInfo]) {

                        throw "Callback is not a script block or command info, type: $(($cb.GetType().FullName))"
                    }
                    $convertedInvocationParams = @{}
                    foreach ($property in $invocationParams.PSObject.Properties) {
                        $convertedInvocationParams[$property.Name] = $property.Value
                    }
                    $callbackResult = $null
                    try {
                        # Execute callback
                        # Add confirmation prompt for tool functions that require it
                        if ($NoConfirmationToolFunctionNames.IndexOf($toolCall.function.name) -ge 0) {

                            $callbackResult = &$cb @convertedInvocationParams
                        }
                        else {

                            $location = (Get-Location).Path
                            $functionName = $toolCall.function.Name
                            $parametersLine = $convertedInvocationParams.GetEnumerator() | ForEach-Object {
                                "-$($_.Name) ($($_.Value | ConvertTo-Json -Compress -Depth 10))"
                            } | ForEach-Object {
                                $_ -join " "
                            }

                            # Add confirmation prompt for tool functions that require it
                            switch ($host.ui.PromptForChoice(
                                    "Confirm",
                                    "Are you sure you want to ALLOW the LLM to execute: `r`nPS $location> $functionName $parametersLine",
                                    @(
                                        "&Allow",
                                        "&Disallow, reject"), 0)) {
                                0 {
                                    $callbackResult = &$cb @convertedInvocationParams
                                    break;
                                }

                                1 {
                                    $callbackResult = @{
                                        error = "User cancelled execution"
                                    }
                                    break;
                                }
                            }
                        }
                    }
                    catch {
                        $callbackResult = @{

                            error           = $_.Exception.Message
                            exceptionThrown = $true
                            exceptionClass  = $_.Exception.GetType().FullName
                        }
                    }

                    # assure that result is a string or an array of objects by converting
                    # if necessary
                    if ($null -eq $callbackResult) {

                        $callbackResult = "success (void result)"
                        Write-Verbose "Function returned: $callbackResult"

                        # Add tool response to history
                        $null = $messages.Add(@{
                                role         = "tool"
                                name         = $toolCall.function.name
                                content      = "$callbackResult".Trim()
                                tool_call_id = $toolCall.id
                                id           = $toolCall.id
                                arguments    = $toolCall.function.arguments | ConvertFrom-Json
                            })
                    }
                    elseif ($callbackResult -isnot [string]) {

                        $callbackResult = ($callbackResult | ForEach-Object { $_ | Out-String }) | ConvertTo-Json -Depth 99
                        Write-Verbose "Function returned: $callbackResult"

                        # Add tool response to history
                        $null = $messages.Add(@{
                                role         = "tool"
                                name         = $toolCall.function.name
                                content      = "$callbackResult".Trim()
                                content_type = "application/json"
                                tool_call_id = $toolCall.id
                                id           = $toolCall.id
                                arguments    = $toolCall.function.arguments | ConvertFrom-Json
                            })
                    }
                    elseif ($callbackResult -is [string]) {

                        Write-Verbose "Function returned: $callbackResult"

                        # Add tool response to history
                        $null = $messages.Add(@{
                                role         = "tool"
                                name         = $toolCall.function.name
                                content      = $callbackResult
                                tool_call_id = $toolCall.id
                                id           = $toolCall.id
                                arguments    = $toolCall.function.arguments | ConvertFrom-Json
                            })
                    }
                }
                else {

                    $messages.Add(@{
                            role         = "tool"
                            name         = $toolCall.function.name
                            content      = "[Function has no callback assigned]"
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | ConvertFrom-Json
                        }) | Out-Null
                }
            }

            Write-Verbose "Continuing conversation after tool responses"

            if (-not $PSBoundParameters.ContainsKey(('ContinueLast'))) {

                $PSBoundParameters.Add('ContinueLast', $true)
            }
            else {

                $PSBoundParameters['ContinueLast'] = $true
            }

            if (-not $PSBoundParameters.ContainsKey(('Query'))) {

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

            # # Extract and process embedded tool calls
            # while ($content -match '<tool_call>\s*({[^}]+})\s*</tool_call>') {

            #     $toolCallJson = $matches[1]
            #     $toolCall = $null

            #     try {
            #         $toolCall = $toolCallJson | ConvertFrom-Json

            #         # Find matching function
            #         $matchedFunc = $Functions.function | Where-Object { $_.name -eq $toolCall.name }

            #         if ($matchedFunc -and $matchedFunc.ContainsKey("callback")) {

            #             Write-Verbose "Found tool call in content: $($toolCall.name)"

            #             # Check chat history for recent identical call
            #             $cachedResult = $null

            #             # Look through messages in reverse order
            #             for ($i = $messages.Count - 1; $i -ge 0; $i--) {
            #                 $historicMsg = $messages[$i]
            #                 if ($historicMsg.role -eq "tool" -and
            #                     $historicMsg.name -eq $toolCall.name) {

            #                     # Try to match the arguments
            #                     $historicArgs = $historicMsg.arguments | ConvertTo-Json -Compress
            #                     if ($historicArgs -eq ($toolCall.arguments | ConvertTo-Json -Compress)) {
            #                         $cachedResult = $historicMsg.content
            #                         Write-Verbose "Found cached result for $($toolCall.name)"
            #                         break
            #                     }
            #                 }
            #             }

            #             if ($cachedResult) {

            #                 # Use cached result
            #                 $callbackResult = $cachedResult
            #             }
            #             else {
            #                 # Execute function as before
            #                 Write-Verbose "Executing new tool call: $($toolCall.name)"
            #                 $vars = [System.Collections.Generic.List[object]] @($toolCall.arguments)
            #                 $callbackResult = Invoke-Command -ScriptBlock ($matchedFunc.callback) -ArgumentList $vars

            #                 if ($null -eq $callbackResult) {

            #                     $callbackResult = "success"
            #                 }
            #                 elseif ($callbackResult -isnot [string]) {

            #                     $callbackResult = ($callbackResult | ForEach-Object { $_ | Out-String }) | ConvertTo-Json -Depth 99
            #                 }

            #                 $id = [guid]::NewGuid().ToString();

            #                 # Add result to history for future caching
            #                 $null = $messages.Add(
            #                     @{
            #                         role         = "assistant"
            #                         name         = $toolCall.name
            #                         tool_call_id = $id
            #                         id           = $id
            #                         arguments    = $toolCall.arguments
            #                     }
            #                 )

            #                 # Add result to history for future caching
            #                 $null = $messages.Add( @{
            #                         role      = "tool"
            #                         name      = $toolCall.name
            #                         content   = $callbackResult
            #                         arguments = $toolCall.arguments
            #                         id        = $id
            #                     }
            #                 )
            #             }
            #             # Replace the tool call with its result
            #             $content = $content -replace [regex]::Escape($matches[0]), $callbackResult
            #         }
            #         else {
            #             $content = $content -replace [regex]::Escape($matches[0]), ""

            #             $messages.Add(@{
            #                     role         = "tool"
            #                     name         = $toolCall.function.name
            #                     content      = "[Function not found, function = $($toolCall.function.name), params = $($toolCall.function.arguments | ConvertTo-Json)]"
            #                     tool_call_id = $toolCall.id
            #                     id           = $toolCall.id
            #                     arguments    = $toolCall.function.arguments | ConvertFrom-Json
            #                 }) | Out-Null
            #         }
            #     }
            #     catch {
            #         Write-Error "Failed to process embedded tool call: $($_.Exception.Message)"
            #         $content = $content -replace [regex]::Escape($matches[0]), ""
            #     }
            # }

            if (-not [string]::IsNullOrWhiteSpace($content)) {

                if ($IncludeThoughts) {

                    $finalOutput += $content + "`n"
                }
                else {

                    # Process thoughts as before
                    $i = $content.IndexOf("<think>")
                    if ($i -ge 0) {
                        $i += 7
                        $i2 = $content.IndexOf("</think>")
                        if ($i2 -ge 0) {
                            $thoughts = $content.Substring($i, $i2 - $i)
                            Write-Host $thoughts -ForegroundColor Yellow
                            if ($SpeakThoughts) {

                                $null = Start-TextToSpeech $thoughts
                            }
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
