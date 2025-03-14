################################################################################
<#
.SYNOPSIS
Starts an interactive text chat session with AI capabilities.

.DESCRIPTION
Initiates an interactive chat session with AI capabilities, allowing users to add
or remove PowerShell functions during the conversation and execute PowerShell
commands.

.PARAMETER Query
Initial text to send to the model.

.PARAMETER Model
The LM-Studio model to use, defaults to "qwen2.5-14b-instruct".

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier for automatic model downloads.

.PARAMETER Instructions
System instructions to provide context to the AI model.

.PARAMETER Attachments
Array of file paths to attach to the conversation.

.PARAMETER Temperature
Controls randomness in responses (0.0-1.0). Lower values are more deterministic.

.PARAMETER MaxToken
Maximum number of tokens in the response. Default is 8192.

.PARAMETER ShowWindow
Show the LM Studio interface window.

.PARAMETER TTLSeconds
Set a TTL (in seconds) for models loaded via API requests.

.PARAMETER Gpu
GPU offloading control (-2=Auto, -1=LM Studio decides, 0-1=fraction, off=disabled).

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER ImageDetail
Level of detail for image generation (low, medium, high).

.PARAMETER IncludeThoughts
Include the model's thought process in responses.

.PARAMETER ContinueLast
Continue from the last conversation instead of starting new.

.PARAMETER ExposedCmdLets
Array of PowerShell cmdlets to expose as tools.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.PARAMETER ChatOnce
Used internally to invoke chat mode once after llm invocation.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER ApiEndpoint
Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

.PARAMETER ApiKey
The API key to use for the request.

.EXAMPLE
New-LLMTextChat -Model "qwen2.5-14b-instruct" -Temperature 0.7 -MaxToken 4096
-Instructions "You are a helpful AI assistant"

.EXAMPLE
llmchat "Tell me a joke" -Speak -IncludeThoughts
#>
# Store exposed cmdlets at module level instead of global scope
$script:LMStudioExposedCmdlets = $null


function New-LLMTextChat {

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "Default")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "New-LLMTextChat")]
    [Alias("llmchat")]

    param(
        ########################################################################
        [Parameter(
            ParameterSetName = "Default",
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
            HelpMessage = "Temperature for response randomness (0.0-1.0)")]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.0,
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
        $ExposedCmdLets,
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
        [Parameter(
            Mandatory = $false,
            DontShow = $true,
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

        Write-Verbose "Initializing chat session with model: $Model"

        $updateInstructions = [string]::IsNullOrWhiteSpace($Instructions)

        # initialize exposed cmdlets if not provided
        if ($null -eq $ExposedCmdLets) {
            if ($ContinueLast -and $script:LMStudioExposedCmdlets) {

                $ExposedCmdLets = $script:LMStudioExposedCmdlets
            }
            else {

                $updateInstructions = $true

                # initialize default allowed PowerShell cmdlets
                $ExposedCmdLets = @(
                    @{
                        Name          = "Microsoft.PowerShell.Management\Get-ChildItem"
                        AllowedParams = @("Path=string", "Recurse=boolean", "Filter=array", "Include=array", "Exclude=array", "Force")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = "GenXdev.FileSystem\Find-Item"
                        AllowedParams = @("SearchMask", "Pattern", "PassThru")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = "Microsoft.PowerShell.Management\Get-Content"
                        AllowedParams = @("Path=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 2
                    },
                    @{
                        Name          = "CimCmdlets\Get-CimInstance"
                        AllowedParams = @("Query=string", "ClassName=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 5
                    },
                    @{
                        Name                                 = "GenXdev.AI\Approve-NewTextFileContent"
                        AllowedParams                        = @("ContentPath", "NewContent")
                        OutputText                           = $false
                        Confirm                              = $true
                        JsonDepth                            = 2
                        DontShowDuringConfirmationParamNames = @("NewContent")
                    },
                    @{
                        Name          = "Microsoft.PowerShell.Utility\Invoke-WebRequest"
                        AllowedParams = @("Uri=string", "Method=string", "Body", "ContentType=string", "Method=string", "UserAgent=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 4
                    },
                    @{
                        Name          = "Microsoft.PowerShell.Utility\Invoke-RestMethod"
                        AllowedParams = @("Uri=string", "Method=string", "Body", "ContentType=string", "Method=string", "UserAgent=string")
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    },
                    @{
                        Name          = "GenXdev.Console\Start-TextToSpeech"
                        AllowedParams = @("Lines=string")
                        OutputText    = $true
                        Confirm       = $false
                    },
                    @{
                        Name          = "Microsoft.PowerShell.Utility\Invoke-Expression"
                        AllowedParams = @("Command=string")
                        Confirm       = $true
                        JsonDepth     = 40
                    },
                    @{
                        Name          = "Microsoft.PowerShell.Management\Get-Clipboard"
                        AllowedParams = @()
                        OutputText    = $true
                        Confirm       = $false
                    },
                    @{
                        Name          = "Microsoft.PowerShell.Management\Set-Clipboard"
                        AllowedParams = @("Value=string")
                        OutputText    = $true
                        Confirm       = $false
                    },
                    @{
                        Name       = "GenXdev.AI\Get-LMStudioModelList"
                        OutputText = $false
                        Confirm    = $false
                        JsonDepth  = 2
                    },
                    @{
                        Name       = "GenXdev.AI\Get-LMStudioLoadedModelList"
                        OutputText = $false
                        Confirm    = $false
                        JsonDepth  = 2
                    }
                );

                $functionInfoObj = (ConvertTo-LMStudioFunctionDefinition -ExposedCmdLets:$ExposedCmdLets)
                $functionInfoObj | ForEach-Object { $null = $_.function.Remove("callback") }
                $functionInfo = $functionInfoObj |
                ConvertTo-Json `
                    -ErrorAction SilentlyContinue `
                    -WarningAction SilentlyContinue `
                    -Depth 10

                $ExposedCmdLets += @(
                    @{
                        Name          = "GenXdev.AI\Invoke-LLMQuery"
                        AllowedParams = @("Query", "Model", "Attachments", "IncludeThoughts", "ContinueLast")
                        ForcedParams  = @(
                            @{
                                Name  = "NoSessionCaching";
                                Value = $true
                            }, @{
                                Name  = "Instructions";
                                Value = "You are being invoked by another LM's tool function. Do what it asks, " +
                                "but if it it didn't pass the right parameters, especially if it tries " +
                                "to let you invoke PowerShell expressions, respond with a warning that " +
                                "that is not possible. `r`n" +
                                "If it asks you to create an execution plan for itself, know that it has " +
                                "access to the following tool functions to help it:`r`n`r`n" +
                                "$functionInfo"
                            }
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    }
                )
            }
        }

        if ($updateInstructions) {

            if ([string]::IsNullOrWhiteSpace($Instructions)) {

                $Instructions = ""
            }

            $Instructions = @"
$Instructions

**You are an interactive AI assistant. Your primary functions are to:**
1. **Ask and Answer Questions:** Engage with users to understand their queries and provide relevant responses.
2. **Invoke Tools:** Proactively suggest the use of tools or directly invoke them if you are confident they can accomplish a task.

**Key Guidelines:**
- **Tool Usage:** You don't need to use all available tool parameters, and some parameters might be mutually exclusive. Determine the best parameters to use based on the task at hand.
- **PowerShell Constraints:**
  - **Avoid PowerShell Features:** Do not rely on PowerShell features like expanding string embeddings (e.g., `$()`) or any similar methods. Parameter checking is strict.
  - **No Variables/Expressions:** Do not use PowerShell variables or expressions under any circumstances.

**Handling Invoke-LLMQuery:**
- If asked to use `Invoke-LLMQuery`, it is likely that the intention is to relay the output of another tool to the `Query` parameter.
- **Steps to Follow:**
  1. Execute the relevant tool.
  2. Copy the output from the tool.
  3. Paste the copied output into the `Query` parameter of the `Invoke-LLMQuery` function.
  4. Include the user's instructions along with the tool's output in the `Query` parameter.

**Multiple Tool Invocations:**
- Feel free to invoke multiple tools within a single response if necessary.

**Safety Measures:**
- Do not worry about potential harm when invoking these tools. They are either unable to make changes or will prompt the user to confirm any actions. Users are aware of the possible consequences due to the nature of the PowerShell environment and the ability to enforce confirmation for any exposed tool.
"@;

            $Instructions = $Instructions.Trim()
        }

        if (-not $NoSessionCaching) {

            $script:LMStudioExposedCmdlets = $ExposedCmdLets
        }

        Write-Verbose "Initialized with $($ExposedCmdLets.Count) exposed cmdlets"

        # ensure required parameters are present in bound parameters
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
                -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            $modelInfo = Initialize-LMStudioModel @initializationParams
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

        if (-not $PSBoundParameters.ContainsKey("MaxToken")) {

            $null = $PSBoundParameters.Add("MaxToken", $MaxToken)
        }

        if ($PSBoundParameters.ContainsKey("ChatOnce")) {

            $null = $PSBoundParameters.Remove("ChatOnce")
        }

        if (-not $PSBoundParameters.ContainsKey("ExposedCmdLets")) {

            $null = $PSBoundParameters.Add("ExposedCmdLets", $ExposedCmdLets);
        }
    }

    process {

        Write-Verbose "Starting chat interaction loop"

        # helper function to display available tool functions
        function Show-ToolFunction {
            function FixName([string] $name) {
                $index = $name.IndexOf("\")
                if ($index -gt 0) {
                    return $name.Substring($index + 1)
                }
                return $name;
            }

            function GetParamString([object] $cmdlet) {
                if ($null -eq $cmdlet.AllowedParams) { return "" }
                $params = $cmdlet.AllowedParams | ForEach-Object {
                    $a = $_
                    if ($a -match "^(.+?)=") {
                        $a = $matches[1]
                    }
                    $a
                }
                return "($(($params -join ',')))"
            }

            if ($ExposedCmdLets.Count -gt 0) {
                Write-Host -ForegroundColor Green `
                    "Tool functions now active ($($ExposedCmdLets.Count)) ->"

                $( ($ExposedCmdLets | ForEach-Object {
                            $name = FixName($_.Name)
                            $params = GetParamString($_)
                            if ($_.Confirm) {
                                "$name$params"
                            }
                            else {
                                "$name*$params"
                            }
                        } | Select-Object -Unique) -join ', ') |
                Write-Host -ForegroundColor Green
            }
        }

        # initialize chat state
        $script:isFirst = -not $ContinueLast

        # display available tools
        Show-ToolFunction

        # main chat loop
        $shouldStop = $false
        while (-not $shouldStop) {
            $question = ""
            if (-not $ChatOnce -and [string]::IsNullOrWhiteSpace($Query)) {

                # get user input
                [Console]::Write("> ");
                try { $null = Set-PSReadLineOption -PredictionSource History } catch { }
                # $question = Read-Host
                $question = PSConsoleHostReadLine
                if ($null -eq $question) { $question = [string]::Empty }
            }
            else {

                if (-not [string]::IsNullOrWhiteSpace($Query)) {

                    $question = $Query
                    $Query = [string]::Empty
                    [Console]::WriteLine("> $question");
                }
            }

            Write-Verbose "Processing query: $question"

            $PSBoundParameters["ContinueLast"] = (-not $script:isFirst);
            $PSBoundParameters["Query"] = $question;
            $PSBoundParameters["ExposedCmdLets"] = $ExposedCmdLets;

            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Invoke-LLMQuery" `
                -DefaultValues (Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            $invocationArguments.ChatOnce = $false

            @(Invoke-LLMQuery @invocationArguments) | ForEach-Object -Process {
                $result = $_
                if (($null -eq $result) -or ([string]::IsNullOrEmpty("$result".trim()))) { return }

                $script:isFirst = $false

                if ($ChatOnce) {

                    Write-Output $result
                }
                else {

                    Write-Host -ForegroundColor Yellow "$result"
                }
            }

            # post-response menu loop
            $shouldStop = $ChatOnce
        }
    }

    end {
        Write-Verbose "Chat session completed"
    }
}
################################################################################