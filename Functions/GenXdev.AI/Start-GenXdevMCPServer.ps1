function Start-GenXdevMCPServer {
    <#
    .SYNOPSIS
        Starts the GenXdev MCP server that exposes PowerShell cmdlets as tools.

    .DESCRIPTION
        This function starts an HTTP server that implements the Model Context Protocol (MCP)
        server pattern, exposing PowerShell cmdlets as callable tools. The server provides
        endpoints for listing available tools and executing them, similar to the TypeScript
        example but using PowerShell's ExposedCmdLets functionality.

    .PARAMETER Port
        The port on which the server will listen. Default is 2175.

    .PARAMETER ExposedCmdLets
        Array of PowerShell command definitions to expose as tools.

    .PARAMETER NoConfirmationToolFunctionNames
        Array of command names that can execute without user confirmation.

    .PARAMETER StopExisting
        Stop any existing server running on the specified port.

    .PARAMETER MaxOutputLength
        Maximum length of tool output in characters. Output exceeding this length will be trimmed with a warning message. Default is 75000 characters (100KB).

    .EXAMPLE
        Start-GenXdevMCPServer -Port 2175

    .EXAMPLE
        $exposedCmdlets = @(
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name = "Get-Process"
                Description = "Get running processes"
                AllowedParams = @("Name", "Id")
                Confirm = $false
            }
        )
        Start-GenXdevMCPServer -Port 2175 -ExposedCmdLets $exposedCmdlets
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [int]$Port = 2175,

        [GenXdev.Helpers.ExposedCmdletDefinition[]]$ExposedCmdLets = @(),

        [string[]]$NoConfirmationToolFunctionNames = @(),

        [switch]$StopExisting,

        [int]$MaxOutputLength = 75000
    )

    # Helper functions (nested to avoid module scope exposure)
    function HandleGenXdevMCPServerSSERequest {
        param(
            [System.Net.HttpListenerRequest]$Request,
            [System.Net.HttpListenerResponse]$Response,
            [hashtable[]]$Functions
        )

        try {
            Microsoft.PowerShell.Utility\Write-Host 'Establishing SSE connection for legacy transport' -ForegroundColor Yellow

            # Set SSE headers
            $Response.ContentType = 'text/event-stream'
            $Response.Headers.Add('Cache-Control', 'no-cache')
            $Response.Headers.Add('Access-Control-Allow-Origin', '*')
            $Response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
            $Response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type, Last-Event-ID')

            # Don't set Content-Length for SSE
            $Response.SendChunked = $true

            # Send initial endpoint event for legacy SSE transport
            $endpointEvent = @{
                method = 'notifications/message'
                params = @{
                    endpoint = '/mcp'
                }
            }

            # Fix: Use deeper JSON serialization depth
            $sseData = "event: endpoint`ndata: $($endpointEvent | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10)`n`n"
            $sseBytes = [System.Text.Encoding]::UTF8.GetBytes($sseData)
            $Response.OutputStream.Write($sseBytes, 0, $sseBytes.Length)
            $Response.OutputStream.Flush()

            # Send initialization capabilities
            $initEvent = @{
                jsonrpc = '2.0'
                method  = 'notifications/initialized'
                params  = @{
                    protocolVersion = '2024-11-05'
                    capabilities    = @{
                        tools = @{
                            listChanged = $true
                        }
                    }
                    serverInfo      = @{
                        name    = 'GenXdev-PowerShell-MCP-Server'
                        version = '1.254.2025'
                    }
                }
            }

            # Fix: Use deeper JSON serialization depth
            $initSseData = "event: message`ndata: $($initEvent | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10)`n`n"
            $initSseBytes = [System.Text.Encoding]::UTF8.GetBytes($initSseData)
            $Response.OutputStream.Write($initSseBytes, 0, $initSseBytes.Length)
            $Response.OutputStream.Flush()

            Microsoft.PowerShell.Utility\Write-Host 'SSE connection established, keeping alive...' -ForegroundColor Green

            # Fix: Reduce heartbeat frequency and add connection validation
            $heartbeatCount = 0
            while ($Response.OutputStream.CanWrite -and $listener.IsListening) {
                try {
                    # Check if client is still connected before sleeping
                    if (-not $Response.OutputStream.CanWrite) {
                        Microsoft.PowerShell.Utility\Write-Host 'Client disconnected, ending SSE session' -ForegroundColor Yellow
                        break
                    }

                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds 10  # Reduced from 30 to 10 seconds
                    $heartbeatCount++

                    # Send heartbeat with better error handling
                    $heartbeat = "event: heartbeat`ndata: {`"timestamp`": `"$(Microsoft.PowerShell.Utility\Get-Date -Format 'yyyy-MM-ddTHH:mm:ss.fffZ')`", `"count`": $heartbeatCount}`n`n"
                    $heartbeatBytes = [System.Text.Encoding]::UTF8.GetBytes($heartbeat)

                    # Check connection before writing
                    if ($Response.OutputStream.CanWrite) {
                        $Response.OutputStream.Write($heartbeatBytes, 0, $heartbeatBytes.Length)
                        $Response.OutputStream.Flush()
                        # Reduced heartbeat logging frequency
                        if ($heartbeatCount % 6 -eq 0) {
                            # Log every 6th heartbeat (every minute)
                            Microsoft.PowerShell.Utility\Write-Host "SSE heartbeat #$heartbeatCount" -ForegroundColor DarkGray
                        }
                    } else {
                        Microsoft.PowerShell.Utility\Write-Host 'Cannot write to stream, client disconnected' -ForegroundColor Yellow
                        break
                    }
                }
                catch [System.ObjectDisposedException] {
                    Microsoft.PowerShell.Utility\Write-Host 'SSE connection disposed by client' -ForegroundColor Yellow
                    break
                }
                catch [System.Net.HttpListenerException] {
                    Microsoft.PowerShell.Utility\Write-Host "SSE connection closed by client: $($_.Exception.Message)" -ForegroundColor Yellow
                    break
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Host "SSE connection error: $($_.Exception.Message)" -ForegroundColor Yellow
                    break
                }
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "SSE connection error: $($_.Exception.Message)"
        }
        finally {
            try {
                if ($Response -and -not $Response.OutputStream.CanWrite) {
                    $Response.Close()
                }
            }
            catch {
                # Ignore close errors
            }
        }
    }

    function HandleGenXdevMCPServerMCPRequest {
        param(
            [object]$Request,
            [hashtable[]]$Functions,
            [GenXdev.Helpers.ExposedCmdletDefinition[]]$ExposedCmdLets,
            [string[]]$NoConfirmationToolFunctionNames,
            [int]$MaxOutputLength = 75000
        )

        try {
            # Handle different MCP methods
            switch ($Request.method) {
                'initialize' {
                    $response = @{
                        jsonrpc = '2.0'
                        id      = $Request.id
                        result  = @{
                            protocolVersion = '2024-11-05'
                            capabilities    = @{
                                tools = @{
                                    listChanged = $true
                                }
                            }
                            serverInfo      = @{
                                name    = 'GenXdev-PowerShell-MCP-Server'
                                version = '1.254.2025'
                            }
                        }
                    }
                    return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -ErrorAction SilentlyContinue
                }
                'initialized' {
                    # Just acknowledge the initialized notification
                    return ''
                }
                'tools/list' {
                    $tools = @()
                    foreach ($func in $Functions) {
                        $tool = @{
                            name        = $func.function.name
                            description = $func.function.description
                            inputSchema = @{
                                type       = 'object'
                                properties = $func.function.parameters.properties
                                required   = $func.function.parameters.required
                            }
                        }
                        $tools += $tool
                    }

                    $response = @{
                        jsonrpc = '2.0'
                        id      = $Request.id
                        result  = @{
                            tools = $tools
                        }
                    }
                    return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress
                }
                'tools/call' {
                    if (-not $Request.params -or -not $Request.params.name) {
                        throw 'Invalid request: missing tool name'
                    }

                    $toolName = $Request.params.name
                    $arguments = $Request.params.arguments

                    Microsoft.PowerShell.Utility\Write-Host "    Executing tool: $toolName" -ForegroundColor Yellow
                    if ($arguments) {
                        Microsoft.PowerShell.Utility\Write-Host "    With arguments: $($arguments | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress)" -ForegroundColor DarkGray
                    }

                    # Create tool call object
                    $toolCall = @{
                        function = @{
                            name      = $toolName
                            arguments = if ($arguments) { ($arguments | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress) } else { '{}' }
                        }
                    }                    # Execute the tool call with defensive error handling to prevent prompts
                    try {
                        # Temporarily redirect stdin to prevent any prompts
                        $originalIn = [Console]::In
                        try {
                            $null = [Console]::SetIn([System.IO.TextReader]::Null)

                            # Execute the tool call directly (no jobs to avoid serialization issues)
                            $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                                -ToolCall:$toolCall `
                                -Functions:$Functions `
                                -ExposedCmdLets:$ExposedCmdLets `
                                -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                                Microsoft.PowerShell.Utility\Select-Object -First 1
                        }
                        finally {
                            # Always restore original stdin
                            [Console]::SetIn($originalIn)
                        }

                        if (-not $invocationResult) {
                            throw 'Tool execution failed to return result'
                        }
                    }
                    catch {
                        # If tool execution fails, return error instead of prompting
                        Microsoft.PowerShell.Utility\Write-Host "    Tool execution failed: $($_.Exception.Message)" -ForegroundColor Red
                        $response = @{
                            jsonrpc = '2.0'
                            id      = $Request.id
                            error   = @{
                                code    = -32603
                                message = "Tool execution failed: $($_.Exception.Message)"
                            }
                        }
                        return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress
                    }

                    if ($invocationResult.CommandExposed) {
                        # Check if the cmdlet is configured to return text only
                        $isTextOnlyOutput = $invocationResult.ExposedCmdLet -and $invocationResult.ExposedCmdLet.OutputText -eq $true

                        # Process output
                        if ($isTextOnlyOutput) {
                            # For text-only output, convert everything to string first using Out-String
                            $outputText = "$(($invocationResult.Output | Microsoft.PowerShell.Utility\Out-String))".Trim()
                        } else {
                            # For structured output, preserve object types but convert non-strings to text
                            $outputText = "$($invocationResult.Output | Microsoft.PowerShell.Core\ForEach-Object {
                                if ($_ -is [string]) {
                                    $_
                                } else {
                                    $_ | Microsoft.PowerShell.Utility\Out-String
                                }
                            })".Trim()
                        }

                        # For text-only output, respect MaxOutputLength and don't serialize to JSON
                        if ($isTextOnlyOutput) {
                            # Trim output if it exceeds MaxOutputLength
                            if ($outputText.Length -gt $MaxOutputLength) {
                                $originalLength = $outputText.Length
                                $trimMessage = "TRIMMED OUTPUT (check parameter use!) invalid json on purpose, AI Agent: don't retry same function without check parameters! >>"
                                $maxContentLength = $MaxOutputLength - $trimMessage.Length
                                $outputText = $trimMessage + $outputText.Substring(0, $maxContentLength)
                                Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' output was trimmed from $originalLength to $MaxOutputLength characters"
                            }

                            # If output is still empty, provide more informative message
                            if ([string]::IsNullOrWhiteSpace($outputText)) {
                                $outputText = "Command '$toolName' executed successfully but produced no output."
                            }

                            Microsoft.PowerShell.Utility\Write-Host "    Tool output ($($outputText.Length) chars):" -ForegroundColor Green
                            Microsoft.PowerShell.Utility\Write-Verbose "Full tool output:`n$outputText"
                            if ($outputText.Length -lt 200) {
                                Microsoft.PowerShell.Utility\Write-Host "$outputText" -ForegroundColor DarkCyan
                            } else {
                                Microsoft.PowerShell.Utility\Write-Host "First 100 chars: $($outputText.Substring(0, 100))..." -ForegroundColor DarkCyan
                                Microsoft.PowerShell.Utility\Write-Host 'Use -Verbose to see full output' -ForegroundColor DarkGray
                            }

                            $response = @{
                                jsonrpc = '2.0'
                                id      = $Request.id
                                result  = @{
                                    content = @(
                                        @{
                                            type = 'text'
                                            text = $outputText
                                        }
                                    )
                                }
                            }
                        } else {
                            # For non-text output, serialize to JSON with length limiting
                            # If output is still empty, provide more informative message
                            if ([string]::IsNullOrWhiteSpace($outputText)) {
                                $outputText = "Command '$toolName' executed successfully but produced no output."
                            }

                            Microsoft.PowerShell.Utility\Write-Host "    Tool output ($($outputText.Length) chars):" -ForegroundColor Green
                            Microsoft.PowerShell.Utility\Write-Verbose "Full tool output:`n$outputText"
                            if ($outputText.Length -lt 200) {
                                Microsoft.PowerShell.Utility\Write-Host "$outputText" -ForegroundColor DarkCyan
                            } else {
                                Microsoft.PowerShell.Utility\Write-Host "First 100 chars: $($outputText.Substring(0, 100))..." -ForegroundColor DarkCyan
                                Microsoft.PowerShell.Utility\Write-Host 'Use -Verbose to see full output' -ForegroundColor DarkGray
                            }

                            # Try to return structured data as JSON text with smart depth reduction
                            try {
                                # Start with the specified depth and progressively reduce if too long
                                $targetDepth = $invocationResult.ExposedCmdLet.JsonDepth ?? 10
                                $parsedOutput = $null
                                $finalDepth = $targetDepth

                                # Try progressively smaller depths until it fits or we reach minimum depth of 2
                                $foundValidDepth = $false
                                while ($finalDepth -ge 2) {
                                    $parsedOutput = $invocationResult.Output | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth $finalDepth -Compress

                                    if ($parsedOutput.Length -le $MaxOutputLength) {
                                        # Success! It fits at this depth
                                        $foundValidDepth = $true
                                        if ($finalDepth -lt $targetDepth) {
                                            Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' JSON output reduced from depth $targetDepth to $finalDepth to fit $MaxOutputLength character limit"
                                        }
                                        break
                                    }

                                    $finalDepth--
                                }

                                # If we found a depth that works, use it
                                if ($foundValidDepth) {

                                    $response = @{
                                        jsonrpc = '2.0'
                                        id      = $Request.id
                                        result  = @{
                                            content = @(
                                                @{
                                                    type = 'text'
                                                    text = $parsedOutput
                                                }
                                            )
                                        }
                                    }
                                } else {
                                    # Even at depth 2 it's too long, so trim it
                                    $originalLength = $parsedOutput.Length
                                    $trimMessage = "TRIMMED JSON OUTPUT (reduced to depth $finalDepth, still too large!) incomplete json data, AI Agent: don't retry same function without checking parameters! >>"
                                    $maxContentLength = $MaxOutputLength - $trimMessage.Length
                                    $trimmedJson = $trimMessage + $parsedOutput.Substring(0, $maxContentLength)
                                    Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' JSON output was reduced to minimum depth $finalDepth and trimmed from $originalLength to $MaxOutputLength characters"

                                    $response = @{
                                        jsonrpc = '2.0'
                                        id      = $Request.id
                                        result  = @{
                                            content = @(
                                                @{
                                                    type = 'text'
                                                    text = $trimmedJson
                                                }
                                            )
                                        }
                                    }
                                }
                            } catch {
                                # If JSON conversion fails, fall back to text with trimming
                                if ($outputText.Length -gt $MaxOutputLength) {
                                    $originalLength = $outputText.Length
                                    $trimMessage = "TRIMMED OUTPUT (check parameter use!) invalid json on purpose, AI Agent: don't retry same function without check parameters! >>"
                                    $maxContentLength = $MaxOutputLength - $trimMessage.Length
                                    $outputText = $trimMessage + $outputText.Substring(0, $maxContentLength)
                                    Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' fallback output was trimmed from $originalLength to $MaxOutputLength characters"
                                }

                                $response = @{
                                    jsonrpc = '2.0'
                                    id      = $Request.id
                                    result  = @{
                                        content = @(
                                            @{
                                                type = 'text'
                                                text = $outputText
                                            }
                                        )
                                    }
                                }
                            }
                        }
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Host "    Tool execution failed: $($invocationResult.Reason)" -ForegroundColor Red
                        $response = @{
                            jsonrpc = '2.0'
                            id      = $Request.id
                            error   = @{
                                code    = -32603
                                message = "Tool execution failed: $($invocationResult.Reason)"
                            }
                        }
                    }

                    return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
                }
                default {
                    $response = @{
                        jsonrpc = '2.0'
                        id      = $Request.id
                        error   = @{
                            code    = -32601
                            message = "Method not found: $($Request.method)"
                        }
                    }
                    return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
                }
            }
        }
        catch {
            $errorResponse = @{
                jsonrpc = '2.0'
                id      = $Request.id
                error   = @{
                    code    = -32603
                    message = "Internal error: $($_.Exception.Message)"
                }
            }
            return $errorResponse | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
        }
    }

    function HandleGenXdevMCPServerListToolsRequest {
        param(
            [hashtable[]]$Functions
        )

        $tools = @()
        foreach ($func in $Functions) {
            $tool = @{
                name        = $func.function.name
                description = $func.function.description
                inputSchema = @{
                    type       = 'object'
                    properties = $func.function.parameters.properties
                    required   = $func.function.parameters.required
                }
            }
            $tools += $tool
        }

        $response = @{
            tools = $tools
        }

        return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
    }

    function HandleGenXdevMCPServerToolRequest {
        param(
            [object]$Request,
            [hashtable[]]$Functions,
            [GenXdev.Helpers.ExposedCmdletDefinition[]]$ExposedCmdLets,
            [string[]]$NoConfirmationToolFunctionNames,
            [int]$MaxOutputLength = 75000
        )

        try {
            # Validate request structure
            if (-not $Request.params -or -not $Request.params.name) {
                throw 'Invalid request: missing tool name'
            }

            $toolName = $Request.params.name
            $arguments = $Request.params.arguments

            # Create tool call object in the exact same format as Invoke-LLMQuery
            # Arguments should be a JSON string, not a PowerShell object
            $toolCall = @{
                function = @{
                    name      = $toolName
                    arguments = if ($arguments) { ($arguments | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10) } else { '{}' }
                }
            }            # Execute the tool call with defensive error handling to prevent prompts
            try {
                # Temporarily redirect stdin to prevent any prompts
                $originalIn = [Console]::In
                try {
                    $null = [Console]::SetIn([System.IO.TextReader]::Null)

                    # Execute the tool call directly (no jobs to avoid serialization issues)
                    $invocationResult = GenXdev.AI\Invoke-CommandFromToolCall `
                        -ToolCall:$toolCall `
                        -Functions:$Functions `
                        -ExposedCmdLets:$ExposedCmdLets `
                        -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                        Microsoft.PowerShell.Utility\Select-Object -First 1
                }
                finally {
                    # Always restore original stdin
                    [Console]::SetIn($originalIn)
                }

                if (-not $invocationResult) {
                    throw 'Tool execution failed to return result'
                }
            }
            catch {
                # If tool execution fails, return error instead of prompting
                $response = @{
                    content = @(
                        @{
                            type = 'text'
                            text = "Error executing tool '$toolName': $($_.Exception.Message)"
                        }
                    )
                    isError = $true
                }
                return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
            }

            if ($invocationResult.CommandExposed) {
                # Check if the cmdlet is configured to return text only
                $isTextOnlyOutput = $invocationResult.ExposedCmdLet -and $invocationResult.ExposedCmdLet.OutputText -eq $true

                # Process output exactly like Invoke-LLMQuery does (line 1560)
                if ($isTextOnlyOutput) {
                    # For text-only output, convert everything to string first using Out-String
                    $outputText = "$($invocationResult.Output | Microsoft.PowerShell.Utility\Out-String)".Trim()
                } else {
                    # For structured output, preserve object types but convert non-strings to text
                    $outputText = "$($invocationResult.Output | Microsoft.PowerShell.Core\ForEach-Object {
                        if ($_ -is [string]) {
                            $_
                        } else {
                            $_ | Microsoft.PowerShell.Utility\Out-String
                        }
                    })".Trim()
                }

                # For text-only output, respect MaxOutputLength and don't serialize to JSON
                if ($isTextOnlyOutput) {
                    # Trim output if it exceeds MaxOutputLength
                    if ($outputText.Length -gt $MaxOutputLength) {
                        $originalLength = $outputText.Length
                        $trimMessage = "TRIMMED OUTPUT (check parameter use!) invalid json on purpose, AI Agent: don't retry same function without check parameters! >>"
                        $maxContentLength = $MaxOutputLength - $trimMessage.Length
                        $outputText = $trimMessage + $outputText.Substring(0, $maxContentLength)
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' output was trimmed from $originalLength to $MaxOutputLength characters"
                    }

                    # If output is still empty, provide more informative message
                    if ([string]::IsNullOrWhiteSpace($outputText)) {
                        $outputText = "Command '$toolName' executed successfully but produced no output."
                    }

                    $response = @{
                        content = @(
                            @{
                                type = 'text'
                                text = $outputText
                            }
                        )
                    }
                } else {
                    # For non-text output, serialize to JSON with length limiting
                    # If output is still empty, provide more informative message
                    if ([string]::IsNullOrWhiteSpace($outputText)) {
                        $outputText = "Command '$toolName' executed successfully but produced no output."
                    }

                    # Try to return structured data as JSON text with smart depth reduction
                    try {
                        # Start with the specified depth and progressively reduce if too long
                        $targetDepth = $invocationResult.ExposedCmdLet.JsonDepth ?? 10
                        $parsedOutput = $null
                        $finalDepth = $targetDepth

                        # Try progressively smaller depths until it fits or we reach minimum depth of 2
                        $foundValidDepth = $false
                        while ($finalDepth -ge 2) {
                            $parsedOutput = $invocationResult.Output | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth $finalDepth -Compress

                            if ($parsedOutput.Length -le $MaxOutputLength) {
                                # Success! It fits at this depth
                                $foundValidDepth = $true
                                if ($finalDepth -lt $targetDepth) {
                                    Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' JSON output reduced from depth $targetDepth to $finalDepth to fit $MaxOutputLength character limit"
                                }
                                break
                            }

                            $finalDepth--
                        }

                        # If we found a depth that works, use it
                        if ($foundValidDepth) {

                            $response = @{
                                content = @(
                                    @{
                                        type = 'text'
                                        text = $parsedOutput
                                    }
                                )
                            }
                        } else {
                            # Even at depth 2 it's too long, so trim it
                            $originalLength = $parsedOutput.Length
                            $trimMessage = "TRIMMED JSON OUTPUT (reduced to depth $finalDepth, still too large!) incomplete json data, AI Agent: don't retry same function without checking parameters! >>"
                            $maxContentLength = $MaxOutputLength - $trimMessage.Length
                            $trimmedJson = $trimMessage + $parsedOutput.Substring(0, $maxContentLength)
                            Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' JSON output was reduced to minimum depth $finalDepth and trimmed from $originalLength to $MaxOutputLength characters"

                            $response = @{
                                content = @(
                                    @{
                                        type = 'text'
                                        text = $trimmedJson
                                    }
                                )
                            }
                        }
                    } catch {
                        # If JSON conversion fails, fall back to text with trimming
                        if ($outputText.Length -gt $MaxOutputLength) {
                            $originalLength = $outputText.Length
                            $trimMessage = "TRIMMED OUTPUT (check parameter use!) invalid json on purpose, AI Agent: don't retry same function without check parameters! >>"
                            $maxContentLength = $MaxOutputLength - $trimMessage.Length
                            $outputText = $trimMessage + $outputText.Substring(0, $maxContentLength)
                            Microsoft.PowerShell.Utility\Write-Verbose "Tool '$toolName' fallback output was trimmed from $originalLength to $MaxOutputLength characters"
                        }

                        $response = @{
                            content = @(
                                @{
                                    type = 'text'
                                    text = $outputText
                                }
                            )
                        }
                    }
                }
            }
            else {
                $response = @{
                    content = @(
                        @{
                            type = 'text'
                            text = "Error: $($invocationResult.Reason)"
                        }
                    )
                    isError = $true
                }
            }

            return $response | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
        }
        catch {
            $errorResponse = @{
                content = @(
                    @{
                        type = 'text'
                        text = "Error executing tool: $($_.Exception.Message)"
                    }
                )
                isError = $true
            }
            return $errorResponse | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
        }
    }

    # Default exposed cmdlets if none provided
    if ($ExposedCmdLets.Count -eq 0) {
        $ExposedCmdLets = @(
             [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Show-GenXdevCmdlet'
                Description                          = "Shows GenXdev PowerShell modules with their cmdlets and aliases, allow it to take a few seconds or more. Don't invoke this function without parameters, that would be too much data. Wildcards allowed like * and ?"
                AllowedParams                        = @(
                    'CmdletName=string',
                    'ModuleName=string',
                    'NoLocal',
                    'OnlyPublished',
                    'FromScripts',
                    'OnlyReturnModuleNames'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                OutputText                           = $true
                JsonDepth                            = 5
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Get-GenXDevCmdlet'
                Description                          = "Gets GenXdev PowerShell modules with their cmdlets and aliases, allow it to take a few seconds or more. Don't invoke this function without parameters, that would be too much data. Wildcards allowed like * and ?"
                AllowedParams                        = @(
                    'CmdletName=string',
                    'ModuleName=string',
                    'NoLocal',
                    'OnlyPublished',
                    'FromScripts',
                    'OnlyReturnModuleNames'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                OutputText                           = $false
                JsonDepth                            = 5
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Import-GenXdevModules'
                Description                          = 'Reloads all GenXdev PowerShell modules to reflect source code changes in the MCP interface. Use this after making any changes to GenXdev module source code to ensure those changes are available through the MCP server without restarting it.'
                AllowedParams                        = @(
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 2
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Get-Help'
                Description                          = 'Gets help information for PowerShell commands. Use to understand cmdlet syntax, parameters, and examples for GenXdev functions.'
                AllowedParams                        = @(
                    'Name=string'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @(@{
                        Name  = 'Full'
                        Value = $true
                    })
                JsonDepth                            = 4
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Add-TodoLineToREADME'
                Description                          = 'Adds a TODO item to the README.md file in the current project. Great for tracking development tasks and project management.'
                AllowedParams                        = @(
                    'Line=string'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 2
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Add-IssueLineToREADME'
                Description                          = 'Adds an issue or bug report to the README.md file in the current project. Useful for tracking bugs and problems.'
                AllowedParams                        = @(
                    'Line=string'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 2
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Add-FeatureLineToREADME'
                Description                          = 'Adds a feature request or enhancement to the README.md file in the current project. Great for tracking feature development.'
                AllowedParams                        = @(
                    'Line=string'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 2
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Get-GitChangedFiles'
                Description                          = 'Gets files that have been changed in a Git repository. Essential for code review, commit preparation, and change tracking.'
                AllowedParams                        = @(

                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 3
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Get-ClipboardFiles'
                Description                          = 'Gets file paths from the Windows clipboard when files are copied. Essential for file management automation.'
                AllowedParams                        = @(

                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 2
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Set-ClipboardFiles'
                Description                          = 'Sets files in the Windows clipboard for copy/paste operations. Powerful file management automation tool.'
                AllowedParams                        = @(
                    'InputObject=string'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 2
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'New-GenXdevCmdlet'
                AllowedParams                        = @(
                    'CmdletName=string',
                    'Description=string',
                    'ModuleName',
                    'ModuleName',
                    'CmdletAliases'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 4
                OutputText                           = $true
                Confirm                              = $false
            },
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name                                 = 'Search-SpotifyAndPlay'
                Description                          = 'Performs a Spotify search and plays the first found item. Searches Spotify using the provided query string and automatically plays the first matching item on the currently active Spotify device.'
                AllowedParams                        = @(
                    'Queries=string',
                    'SearchType=string'
                )
                DontShowDuringConfirmationParamNames = @()
                ForcedParams                         = @()
                JsonDepth                            = 3
                OutputText                           = $true
                Confirm                              = $false
            }
        )
    }

    # Stop existing server if requested
    if ($StopExisting) {
        if ($PSCmdlet.ShouldProcess("MCP Server on port $Port", "Stop existing server")) {
            GenXdev.AI\Stop-GenXdevMCPServer -Port $Port
        }
    }

    if ($PSCmdlet.ShouldProcess("MCP Server on port $Port", "Start server")) {
        Microsoft.PowerShell.Utility\Write-Host "Starting GenXdev MCP server on port $Port..." -ForegroundColor Green
        Microsoft.PowerShell.Utility\Write-Host "Exposed cmdlets: $($ExposedCmdLets.Name -join ', ')" -ForegroundColor Cyan
        Microsoft.PowerShell.Utility\Write-Host "Max output length: $MaxOutputLength characters ($([math]::Round($MaxOutputLength / 1024, 1))KB)" -ForegroundColor Cyan

        # Convert cmdlets to function definitions
        $functions = GenXdev.AI\ConvertTo-LMStudioFunctionDefinition -ExposedCmdLets $ExposedCmdLets

        # Create HTTP listener
        $listener = Microsoft.PowerShell.Utility\New-Object System.Net.HttpListener
        $listener.Prefixes.Add("http://localhost:$Port/")

        while (-not [Console]::KeyAvailable) {
            try {
                $listener.Start()
                Microsoft.PowerShell.Utility\Write-Host "Server started successfully at http://localhost:$Port" -ForegroundColor Green
                Microsoft.PowerShell.Utility\Write-Host 'Available endpoints:' -ForegroundColor Yellow
                Microsoft.PowerShell.Utility\Write-Host '  GET /mcp - List tools (normal HTTP)' -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host '  POST /mcp - MCP HTTP transport (VS Code)' -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host '  GET|POST /mcp/list-tools - List available tools' -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host '  POST /mcp/call-tool - Execute a tool' -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host '  GET /sse - SSE connection for legacy transport' -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host '  POST /messages - Legacy SSE transport POST endpoint' -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host 'Press Ctrl+C to stop the server' -ForegroundColor Yellow
                break
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Failed to start server: $($_.Exception.Message)"
                Microsoft.PowerShell.Utility\Start-Sleep 2
            }
        }
        # Store server info in script scope for stop function
        $script:GenXdevMCPServer = @{
            Listener                        = $listener
            Port                            = $Port
            Functions                       = $functions
            ExposedCmdLets                  = $ExposedCmdLets
            NoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames
            MaxOutputLength                 = $MaxOutputLength
        }

        # Main server loop
        while (-not [Console]::KeyAvailable) {
        try {
            while ($listener.IsListening -and (-not [Console]::KeyAvailable)) {
                $context = $listener.GetContext()
                $request = $context.Request
                $response = $context.Response

                try {
                    # Add separator line for non-routine requests
                    $isRoutineRequest = ($request.HttpMethod -eq 'GET' -and $request.Url.AbsolutePath -eq '/mcp')
                    if (-not $isRoutineRequest) {
                        Microsoft.PowerShell.Utility\Write-Host '──────────────────────────────────────────────────────────────────────────────────' -ForegroundColor DarkGray
                    }

                    # Set CORS headers - SECURITY: Only allow localhost origins to prevent CSRF attacks
                    $origin = $request.Headers['Origin']
                    $allowedOrigins = @(
                        'http://localhost',
                        'https://localhost',
                        'http://127.0.0.1',
                        'https://127.0.0.1',
                        'http://[::1]',
                        'https://[::1]'
                    )

                    # Check if origin is from localhost/127.0.0.1 (any port)
                    $isAllowedOrigin = $false
                    if ($origin) {
                        foreach ($allowedOrigin in $allowedOrigins) {
                            if ($origin.StartsWith($allowedOrigin)) {
                                $isAllowedOrigin = $true
                                break
                            }
                        }
                    }

                    if ($isAllowedOrigin -or -not $origin) {
                        $response.Headers.Add('Access-Control-Allow-Origin',($origin ? $origin : '*' ))
                        $response.Headers.Add('Access-Control-Allow-Methods', 'GET, POST, OPTIONS')
                        $response.Headers.Add('Access-Control-Allow-Headers', 'Content-Type')
                    }

                    # Handle preflight requests - only if CORS headers were set (origin allowed)
                    if ($request.HttpMethod -eq 'OPTIONS') {
                        if ($isAllowedOrigin -or -not $origin) {
                            $response.StatusCode = 200
                        } else {
                            $response.StatusCode = 403 # Forbidden for non-localhost origins
                        }
                        $response.Close()
                        continue
                    }

                    # Security check: Block requests from non-localhost origins
                    if ($origin -and -not $isAllowedOrigin) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Blocked request from unauthorized origin: $origin"
                        $response.StatusCode = 403
                        $response.Close()
                        continue
                    }

                    # Read request body
                    $requestBody = ''
                    if ($request.HasEntityBody) {
                        $reader = Microsoft.PowerShell.Utility\New-Object System.IO.StreamReader($request.InputStream)
                        $requestBody = $reader.ReadToEnd()
                        $reader.Close()
                    }

                    # Parse JSON request
                    $jsonRequest = $null
                    if ($requestBody) {
                        try {
                            $jsonRequest = $requestBody | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            # Only log detailed JSON for non-/mcp endpoints
                            if ($request.Url.AbsolutePath -ne '/mcp') {
                                Microsoft.PowerShell.Utility\Write-Host "Parsed JSON request: $($jsonRequest | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress)" -ForegroundColor Magenta
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Invalid JSON in request: $($_.Exception.Message)"
                            Microsoft.PowerShell.Utility\Write-Host "Raw request body: $requestBody" -ForegroundColor Red
                        }
                    }

                    # Route requests
                    $responseJson = ''
                    $statusCode = 200

                    # Add concise logging (skip routine GET /mcp requests)
                    if (-not $isRoutineRequest) {
                        Microsoft.PowerShell.Utility\Write-Host "Request: $($request.HttpMethod) $($request.Url.AbsolutePath)" -ForegroundColor Cyan
                    }

                    # Normalize path by removing trailing slash for consistent routing
                    $normalizedPath = $request.Url.AbsolutePath.TrimEnd('/')
                    if ([string]::IsNullOrEmpty($normalizedPath)) {
                        $normalizedPath = '/'
                    }

                    switch ($normalizedPath) {
                        '/mcp' {
                            if ($request.HttpMethod -eq 'GET') {
                                # All GET requests to /mcp return normal HTTP (list tools)
                                $responseJson = HandleGenXdevMCPServerListToolsRequest -Functions $functions
                            }
                            elseif ($request.HttpMethod -eq 'POST') {
                                # Handle Streamable HTTP transport
                                if ($jsonRequest) {
                                    Microsoft.PowerShell.Utility\Write-Host "MCP Request: $($jsonRequest.method)" -ForegroundColor Cyan
                                    if ($jsonRequest.method -eq 'tools/call') {
                                        Microsoft.PowerShell.Utility\Write-Host "  Tool: $($jsonRequest.params.name)" -ForegroundColor Green
                                        if ($jsonRequest.params.arguments) {
                                            Microsoft.PowerShell.Utility\Write-Host "  Arguments: $($jsonRequest.params.arguments | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress)" -ForegroundColor Gray
                                        }
                                    }
                                    $responseJson = HandleGenXdevMCPServerMCPRequest -Request $jsonRequest -Functions $functions -ExposedCmdLets $ExposedCmdLets -NoConfirmationToolFunctionNames $NoConfirmationToolFunctionNames -MaxOutputLength $MaxOutputLength
                                    if ($jsonRequest.method -eq 'tools/call') {
                                        Microsoft.PowerShell.Utility\Write-Host "  Response Length: $($responseJson.Length) chars" -ForegroundColor Gray
                                    }
                                }
                                else {
                                    Microsoft.PowerShell.Utility\Write-Error 'No valid JSON request received for POST to /mcp'
                                    $statusCode = 400
                                    $responseJson = @{
                                        error = @{
                                            code    = -32700
                                            message = 'Parse error - Invalid JSON'
                                        }
                                    } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 50
                                }
                            }
                            else {
                                $statusCode = 405
                                $responseJson = @{
                                    error = @{
                                        code    = -32601
                                        message = 'Method not allowed'
                                    }
                                } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 50
                            }
                        }
                        '/mcp/list-tools' {
                            Microsoft.PowerShell.Utility\Write-Host 'Handling list-tools request' -ForegroundColor Cyan
                            $responseJson = HandleGenXdevMCPServerListToolsRequest -Functions $functions
                        }
                        '/sse' {
                            # Dedicated SSE endpoint for legacy transport
                            if ($request.HttpMethod -eq 'GET') {
                                Microsoft.PowerShell.Utility\Write-Host 'Handling dedicated SSE GET request' -ForegroundColor Yellow
                                HandleGenXdevMCPServerSSERequest -Request $request -Response $response -Functions $functions
                                continue # SSE response handles its own connection, continue to next request
                            }
                            else {
                                $statusCode = 405
                                $responseJson = @{
                                    error = @{
                                        code    = -32601
                                        message = 'Method not allowed - SSE endpoint only supports GET'
                                    }
                                } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 50
                            }
                        }
                        '/mcp/call-tool' {
                            Microsoft.PowerShell.Utility\Write-Host "Tool Call: $($jsonRequest.params.name)" -ForegroundColor Green
                            if ($jsonRequest.params.arguments) {
                                Microsoft.PowerShell.Utility\Write-Host "Arguments: $($jsonRequest.params.arguments | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress)" -ForegroundColor Gray
                            }
                            $responseJson = HandleGenXdevMCPServerToolRequest -Request $jsonRequest -Functions $functions -ExposedCmdLets $ExposedCmdLets -NoConfirmationToolFunctionNames $NoConfirmationToolFunctionNames -MaxOutputLength $MaxOutputLength
                            Microsoft.PowerShell.Utility\Write-Host "Tool Response Length: $($responseJson.Length) chars" -ForegroundColor Gray
                        }
                        '/messages' {
                            # Handle legacy SSE transport POST messages
                            Microsoft.PowerShell.Utility\Write-Host "Legacy SSE Message: $($jsonRequest.method)" -ForegroundColor Yellow
                            $responseJson = HandleGenXdevMCPServerMCPRequest -Request $jsonRequest -Functions $functions -ExposedCmdLets $ExposedCmdLets -NoConfirmationToolFunctionNames $NoConfirmationToolFunctionNames -MaxOutputLength $MaxOutputLength
                        }
                        default {
                            $statusCode = 404
                            $responseJson = @{
                                error = @{
                                    code    = -32601
                                    message = 'Method not found'
                                }
                            } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 50
                        }
                    }

                    # Send response
                    $response.StatusCode = $statusCode
                    $response.ContentType = 'application/json'
                    $responseBytes = [System.Text.Encoding]::UTF8.GetBytes($responseJson)
                    $response.ContentLength64 = $responseBytes.Length
                    $response.OutputStream.Write($responseBytes, 0, $responseBytes.Length)
                    $response.Close()
                }
                catch {
                    # Handle request-specific exceptions without stopping the server
                    Microsoft.PowerShell.Utility\Write-Verbose "Request handling error: $($_.Exception.Message)"
                    try {
                        if (-not $response.HeadersSent) {
                            $response.StatusCode = 500
                            $response.ContentType = 'application/json'
                            $errorJson = @{
                                error = @{
                                    code    = -32603
                                    message = 'Internal server error'
                                }
                            } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10
                            $errorBytes = [System.Text.Encoding]::UTF8.GetBytes($errorJson)
                            $response.ContentLength64 = $errorBytes.Length
                            $response.OutputStream.Write($errorBytes, 0, $errorBytes.Length)
                        }
                        $response.Close()
                    }
                    catch {
                        # Ignore errors when trying to send error response
                    }
                }
            }
        }
        catch [System.Net.HttpListenerException] {
            if ($_.Exception.ErrorCode -ne 995) {
                # 995 = WSA_OPERATION_ABORTED (normal shutdown)
                Microsoft.PowerShell.Utility\Write-Error "Server error: $($_.Exception.Message)"
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Unexpected error: $($_.Exception.Message)"
        }
        finally {
            if ($listener.IsListening) {
                $listener.Stop()
            }
            $listener.Close()
            Microsoft.PowerShell.Utility\Write-Host 'Server stopped.' -ForegroundColor Yellow
        }
    }
    }
}

function Stop-GenXdevMCPServer {
    <#
    .SYNOPSIS
        Stops the GenXdev MCP server.

    .DESCRIPTION
        This function stops the GenXdev MCP server if it's running.

    .PARAMETER Port
        The port of the server to stop. If not specified, stops the globally tracked server.

    .EXAMPLE
        Stop-GenXdevMCPServer -Port 2175
    #>
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [int]$Port
    )

    if ($script:GenXdevMCPServer -and $script:GenXdevMCPServer.Listener) {
        if (-not $Port -or $script:GenXdevMCPServer.Port -eq $Port) {
            if ($PSCmdlet.ShouldProcess("MCP Server on port $($script:GenXdevMCPServer.Port)", "Stop server")) {
                Microsoft.PowerShell.Utility\Write-Host "Stopping GenXdev MCP server on port $($script:GenXdevMCPServer.Port)..." -ForegroundColor Yellow
                $script:GenXdevMCPServer.Listener.Stop()
                $script:GenXdevMCPServer.Listener.Close()
                $script:GenXdevMCPServer = $null
                Microsoft.PowerShell.Utility\Write-Host 'Server stopped.' -ForegroundColor Green
            }
        }
    }
    else {
        Microsoft.PowerShell.Utility\Write-Host 'No server is currently running.' -ForegroundColor Gray
    }
}
