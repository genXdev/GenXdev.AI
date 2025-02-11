################################################################################
<#
.SYNOPSIS
Starts an interactive text chat session with AI capabilities.

.DESCRIPTION
Initiates an interactive chat session with AI capabilities, allowing users to add
or remove PowerShell functions during the conversation and execute PowerShell
commands.

.PARAMETER Model
Name or partial path of the model to initialize, detects and excepts -like 'patterns*' for search
Defaults to "qwen*-instruct".

.PARAMETER ModelLMSGetIdentifier
The specific LM-Studio model identifier for automatic model downloads. Defaults to "qwen2.5-14b-instruct".

.PARAMETER Instructions
System instructions to provide context to the AI model.

.PARAMETER Attachments
Array of file paths to attach to the conversation.

.PARAMETER Temperature
Controls randomness in responses (0.0-1.0). Lower values are more deterministic.

.PARAMETER MaxToken
Maximum number of tokens in the response. Default is 32768.

.PARAMETER ImageDetail
Level of detail for image generation: low, medium, or high.

.PARAMETER IncludeThoughts
Include the model's thought process in responses.

.PARAMETER ContinueLast
Continue from the last conversation instead of starting new.

.PARAMETER ExposedCmdLets
Array of PowerShell cmdlets to expose as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of tool function names that don't require confirmation.

.PARAMETER ShowWindow
Show the LM Studio interface window.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.EXAMPLE
New-LLMTextChat -Model "qwen*-instruct" -Temperature 0.7 -Speak

.EXAMPLE
New-LLMTextChat -ContinueLast
#>
function New-LLMTextChat {

    [CmdletBinding()]
    [Alias("llmchat")]

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
        [switch] $NoSessionCaching
    )

    begin {

        Write-Verbose "Initializing chat session with model: $Model"

        if ($null -eq $ExposedCmdLets) {

            if ($ContinueLast -and $Global:LMStudioGlobalExposedCmdlets) {

                $ExposedCmdLets = $Global:LMStudioGlobalExposedCmdlets
            }
            else {
                # initialize array of allowed PowerShell cmdlets
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
                        Name          = "Invoke-LMStudioQuery"
                        AllowedParams = @("Query", "Model", "Instructions", "Attachments", "IncludeThoughts")
                        ForcedParams  = @(@{Name = "NoSessionCaching"; Value = $true })
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    }
                )
            }
        }

        if (-not $NoSessionCaching) {

            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
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

        $initializationParams = Copy-IdenticalParamValues -BoundParameters $PSBoundParameters `
            -FunctionName 'Initialize-LMStudioModel'

        $modelInfo = Initialize-LMStudioModel @initializationParams
        $Model = $modelInfo.identifier

        if ($PSBoundParameters.ContainsKey("Force")) {

            $null = $PSBoundParameters.Remove("Force")
        }

        if ($PSBoundParameters.ContainsKey("ShowWindow")) {

            $null = $PSBoundParameters.Remove("ShowWindow")
        }

        if ($PSBoundParameters.ContainsKey("ChatMode")) {

            $null = $PSBoundParameters.Remove("ChatMode")

            if (($ChatMode -ne "none" -or $ChatOnce)) {

                return;
            }
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

        $hadAQuery = -not [string]::IsNullOrEmpty($Query)
    }

    process {

        function showToolFunctions {

            if ($ExposedCmdLets.Count -gt 0) {

                Write-Host -ForegroundColor Green `
                    @"
Tool functions now active ($($ExposedCmdLets.Count)) ->
$( ($ExposedCmdLets | ForEach-Object {

                        if ($_.Confirm) {

                            "$($_.Name)"
                        }
                        else {

                            "$($_.Name)*"
                        }
                     } | Select-Object -Unique) -join ', ')
"@
            }
            else {

                Write-Host -ForegroundColor Yellow `
                    "No tool functions active"
            }
        }

        Write-Verbose "Starting chat interaction loop"

        # initialize chat state
        $script:isFirst = -not $ContinueLast
        $shouldStop = $hadAQuery -or $ChatOnce

        showToolFunctions

        $shouldStop = $false;

        # chat interaction loop
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

            @(Invoke-LMStudioQuery @PSBoundParameters) | ForEach-Object {

                if (($null -eq $_) -or ([string]::IsNullOrEmpty("$_".trim()))) { return }

                $script:isFirst = $false

                if ($ChatOnce) {

                    Write-Output $_
                }
                else {

                    Write-Host -ForegroundColor Yellow "$_"
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