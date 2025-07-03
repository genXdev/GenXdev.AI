###############################################################################
<#
.SYNOPSIS
Starts an interactive text chat session with AI capabilities.

.DESCRIPTION
Initiates an interactive chat session with AI capabilities, allowing users to add
or remove PowerShell functions during the conversation and execute PowerShell
commands. This function provides a comprehensive interface for AI-powered
conversations with extensive tool integration and customization options.

.PARAMETER Query
Initial text to send to the model.

.PARAMETER Instructions
System instructions to provide context to the AI model.

.PARAMETER Attachments
Array of file paths to attach to the conversation.

.PARAMETER Temperature
Controls randomness in responses (0.0-1.0). Lower values are more deterministic.

.PARAMETER ImageDetail
Level of detail for image generation (low, medium, high).

.PARAMETER ResponseFormat
A JSON schema for the requested output format.

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
offload to the GPU. -2 = Auto.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools.

.PARAMETER MarkupBlocksTypeFilter
Will only output markup blocks of the specified types.

.PARAMETER IncludeThoughts
Include model's thoughts in output.

.PARAMETER DontAddThoughtsToHistory
Include model's thoughts in output.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER ShowWindow
Show the LM Studio window.

.PARAMETER Force
Force stop LM Studio before initialization.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER OutputMarkupBlocksOnly
Will only output markup block responses.

.PARAMETER ChatOnce
Used internally, to only invoke chat mode once after the llm invocation.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
New-LLMTextChat -Model "qwen2.5-14b-instruct" -Temperature 0.7 -MaxToken 4096 `
    -Instructions "You are a helpful AI assistant"

.EXAMPLE
llmchat "Tell me a joke" -Speak -IncludeThoughts
#>
###############################################################################
# store exposed cmdlets at module level instead of global scope
$script:LMStudioExposedCmdlets = $null

###############################################################################
function New-LLMTextChat {

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = "Default")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [Alias("llmchat")]

    param(
        #######################################################################
        [Parameter(
            ParameterSetName = "Default",
            ValueFromPipeline = $true,
            Position = 0,
            Mandatory = $false,
            HelpMessage = "Query text to send to the model"
        )]
        [AllowEmptyString()]
        [string] $Query = "",
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
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
            HelpMessage = "Temperature for response randomness (0.0-1.0)"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.2,
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
            HelpMessage = "A JSON schema for the requested output format"
        )]
        [string] $ResponseFormat = $null,
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
            HelpMessage = "The model identifier or pattern to use for AI operations"
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
            HelpMessage = "The maximum number of tokens to use in AI operations"
        )]
        [int] $MaxToken,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The number of CPU cores to dedicate to AI operations"
        )]
        [int] $Cpu,
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
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools"
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will only output markup blocks of the specified types"
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @("json", "powershell", "C#", "python", "javascript", "typescript", "html", "css", "yaml", "xml", "bash"),
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
            HelpMessage = "Enable text-to-speech for AI responses"
        )]
        [switch] $Speak,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable text-to-speech for AI thought responses"
        )]
        [switch] $SpeakThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will only output markup block responses"
        )]
        [switch] $OutputMarkupBlocksOnly,
        #######################################################################
        [Parameter(
            DontShow = $true,
            Mandatory = $false,
            HelpMessage = "Used internally, to only invoke chat mode once after the llm invocation"
        )]
        [switch] $ChatOnce,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                "preferences")
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Store settings only in persistent preferences without " +
                "affecting session")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        # output initialization verbose message
        Microsoft.PowerShell.Utility\Write-Verbose "Initializing chat session with model: $Model"

        # determine if instructions need updating
        $updateInstructions = [string]::IsNullOrWhiteSpace($Instructions)

        # initialize exposed cmdlets if not provided
        if ($null -eq $ExposedCmdLets) {

            # use cached cmdlets if continuing last session
            if ($ContinueLast -and $script:LMStudioExposedCmdlets) {

                $ExposedCmdLets = $script:LMStudioExposedCmdlets
            }
            else {

                # flag that instructions need updating
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

                # convert cmdlets to function definition objects
                $functionInfoObj = (GenXdev.AI\ConvertTo-LMStudioFunctionDefinition -ExposedCmdLets:$ExposedCmdLets)

                # remove callback functions from each function definition
                $functionInfoObj |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        $null = $_.function.Remove("callback")
                    }

                # serialize function definitions to json for instructions
                $functionInfo = $functionInfoObj |
                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                        -ErrorAction SilentlyContinue `
                        -WarningAction SilentlyContinue `
                        -Depth 10

                # add invoke-llmquery as an additional exposed cmdlet
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
                                Value = ("You are being invoked by another LM's tool function. Do what it asks, " +
                                "but if it it didn't pass the right parameters, especially if it tries " +
                                "to let you invoke PowerShell expressions, respond with a warning that " +
                                "that is not possible. `r`n" +
                                "If it asks you to create an execution plan for itself, know that it has " +
                                "access to the following tool functions to help it:`r`n`r`n" +
                                "$functionInfo")
                            }
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    }
                )
            }
        }

        # update instructions with ai assistant context if needed
        if ($updateInstructions) {

            # ensure instructions string is not null
            if ([string]::IsNullOrWhiteSpace($Instructions)) {

                $Instructions = ""
            }

            # append comprehensive ai assistant instructions
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

            # trim any excess whitespace from instructions
            $Instructions = $Instructions.Trim()
        }

        # cache exposed cmdlets if session caching is enabled
        if (-not $NoSessionCaching) {

            $script:LMStudioExposedCmdlets = $ExposedCmdLets
        }

        # output verbose message about initialized cmdlets
        Microsoft.PowerShell.Utility\Write-Verbose "Initialized with $($ExposedCmdLets.Count) exposed cmdlets"

        # initialize lm studio model if using localhost endpoint
        if ([string]::IsNullOrWhiteSpace($ApiEndpoint) -or $ApiEndpoint.Contains("localhost")) {

            # copy parameters for model initialization
            $initializationParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Initialize-LMStudioModel' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            # initialize the model and get its identifier
            $modelInfo = GenXdev.AI\Initialize-LMStudioModel @initializationParams
            $Model = $modelInfo.identifier
        }

        # clean up force parameter from bound parameters
        if ($PSBoundParameters.ContainsKey("Force")) {

            $null = $PSBoundParameters.Remove("Force")
            $Force = $false
        }

        # clean up showwindow parameter from bound parameters
        if ($PSBoundParameters.ContainsKey("ShowWindow")) {

            $null = $PSBoundParameters.Remove("ShowWindow")
            $ShowWindow = $false
        }

        # ensure maxtoken parameter is present in bound parameters
        if (-not $PSBoundParameters.ContainsKey("MaxToken")) {

            $null = $PSBoundParameters.Add("MaxToken", $MaxToken)
        }

        # clean up chatonce parameter from bound parameters
        if ($PSBoundParameters.ContainsKey("ChatOnce")) {

            $null = $PSBoundParameters.Remove("ChatOnce")
        }

        # ensure exposedcmdlets parameter is present in bound parameters
        if (-not $PSBoundParameters.ContainsKey("ExposedCmdLets")) {

            $null = $PSBoundParameters.Add("ExposedCmdLets", $ExposedCmdLets);
        }
    }


    process {

        # output verbose message about starting chat interaction
        Microsoft.PowerShell.Utility\Write-Verbose "Starting chat interaction loop"

        # helper function to display available tool functions
        function Show-ToolFunction {

            # internal function to extract cmdlet name from full name
            function FixName([string] $name) {

                # find the backslash separator index
                $index = $name.IndexOf("\")

                # return substring after backslash if found, otherwise return original
                if ($index -gt 0) {
                    return $name.Substring($index + 1)
                }
                return $name;
            }

            # internal function to build parameter string for display
            function GetParamString([object] $cmdlet) {

                # return empty string if no allowed parameters
                if ($null -eq $cmdlet.AllowedParams) { return "" }

                # extract parameter names from allowed parameters array
                $params = $cmdlet.AllowedParams |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        $a = $_

                        # extract parameter name before equals sign if present
                        if ($a -match "^(.+?)=") {
                            $a = $matches[1]
                        }
                        $a
                    }

                # return formatted parameter list
                return "($(($params -join ',')))"
            }

            # display tool functions if any are available
            if ($ExposedCmdLets.Count -gt 0) {

                # output header message for active tool functions
                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                    "Tool functions now active ($($ExposedCmdLets.Count)) ->"

                # format and display each exposed cmdlet with parameters
                $( ($ExposedCmdLets |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # get simplified name and parameter string
                            $name = FixName($_.Name)
                            $params = GetParamString($_)

                            # add asterisk for functions requiring confirmation
                            if ($_.Confirm) {
                                "$name$params"
                            }
                            else {
                                "$name*$params"
                            }
                        } |
                        Microsoft.PowerShell.Utility\Select-Object -Unique) -join ', ') |
                    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green
            }
        }

        # initialize chat state variable
        $script:isFirst = -not $ContinueLast

        # display available tools to user
        Show-ToolFunction

        # main chat loop initialization
        $shouldStop = $false

        # enter main chat interaction loop
        while (-not $shouldStop) {

            # initialize question variable
            $question = ""

            # get user input if not in chat-once mode and no query provided
            if (-not $ChatOnce -and [string]::IsNullOrWhiteSpace($Query)) {

                # display prompt character to user
                [Console]::Write("> ");

                # configure psreadline for history prediction
                try {
                    $null = PSReadLine\Set-PSReadLineOption -PredictionSource History
                } catch { }

                # read user input line using psreadline
                $question = PSReadLine\PSConsoleHostReadLine

                # ensure question is not null
                if ($null -eq $question) {
                    $question = [string]::Empty
                }
            }
            else {

                # use provided query if available
                if (-not [string]::IsNullOrWhiteSpace($Query)) {

                    # set question to query and clear query variable
                    $question = $Query
                    $Query = [string]::Empty

                    # echo the question to console
                    [Console]::WriteLine("> $question");
                }
            }

            # output verbose message about processing query
            Microsoft.PowerShell.Utility\Write-Verbose "Processing query: $question"

            # update bound parameters for llm invocation
            $PSBoundParameters["ContinueLast"] = (-not $script:isFirst);
            $PSBoundParameters["Query"] = $question;
            $PSBoundParameters["ExposedCmdLets"] = $ExposedCmdLets;

            # copy parameters for llm query invocation
            $invocationArguments = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Invoke-LLMQuery" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * -ErrorAction SilentlyContinue)

            # ensure chatonce is disabled for recursive calls
            $invocationArguments.ChatOnce = $false

            # invoke llm query and process each result
            @(GenXdev.AI\Invoke-LLMQuery @invocationArguments) |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # store current result
                    $result = $_

                    # skip empty or null results
                    if (($null -eq $result) -or ([string]::IsNullOrEmpty("$result".trim()))) {
                        return
                    }

                    # mark that this is no longer the first interaction
                    $script:isFirst = $false

                    # output result based on mode
                    if ($ChatOnce) {

                        # return result object for chat-once mode
                        Microsoft.PowerShell.Utility\Write-Output $result
                    }
                    else {

                        # display result as host output for interactive mode
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow "$result"
                    }
                }

            # determine if chat loop should stop
            $shouldStop = $ChatOnce
        }
    }

    end {

        # output verbose message about chat session completion
        Microsoft.PowerShell.Utility\Write-Verbose "Chat session completed"
    }
}
###############################################################################