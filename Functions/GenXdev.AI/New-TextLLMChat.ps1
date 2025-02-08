################################################################################
<#
.SYNOPSIS
Starts an interactive text chat session with AI capabilities.

.DESCRIPTION
Initiates an interactive chat session with AI capabilities, allowing users to add
or remove PowerShell functions during the conversation and execute PowerShell
commands.

.PARAMETER Model
The LM-Studio model to use for text generation. Defaults to "qwen*-instruct".

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

.PARAMETER ShowLMStudioWindow
Show the LM Studio interface window.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.EXAMPLE
New-TextLLMChat -Model "qwen*-instruct" -Temperature 0.7 -Speak

.EXAMPLE
New-TextLLMChat -ContinueLast
#>
function New-TextLLMChat {

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
            HelpMessage = "Array of PowerShell cmdlet or function references " +
            "to use as tools, use Get-Command to obtain such references"        )]

        [System.Management.Automation.CommandInfo[]] $ExposedCmdLets = $null,
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
        [switch] $ChatOnce
    )

    begin {

        Write-Verbose "Initializing chat session with model: $Model"

        if ($ExposedCmdLets) {

            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
            if ($NoConfirmationToolFunctionNames -and $NoConfirmationToolFunctionNames.Count -gt 0) {

                $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames
            }
            else {

                $NoConfirmationToolFunctionNames = @($Global:LMStudioGlobalNoConfirmationToolFunctionNames)
            }
        }
        else {

            if ($continueLast -and $Global:LMStudioGlobalExposedCmdlets -and $Global:LMStudioGlobalExposedCmdlets.Count -gt 0) {

                $ExposedCmdLets = @($Global:LMStudioGlobalExposedCmdlets)
                $NoConfirmationToolFunctionNames = @($Global:LMStudioGlobalNoConfirmationToolFunctionNames)
            }
            else {

                # initialize array of allowed PowerShell cmdlets
                $ExposedCmdLets = @(
                    Get-Command @(
                        "Get-ChildItem",
                        "Find-Item",
                        "Get-Content",
                        "Approve-NewTextFileContent",
                        "Invoke-WebRequest",
                        "Invoke-RestMethod"
                    )
                )
                $NoConfirmationToolFunctionNames = @(
                    "Get-ChildItem",
                    "Find-Item",
                    "Get-Content"
                )
            }

            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
            $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames
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

        if (-not $PSBoundParameters.ContainsKey("MaxToken")) {

            $null = $PSBoundParameters.Add("MaxToken", $MaxToken)
        }

        if ($PSBoundParameters.ContainsKey("ChatOnce")) {

            $null = $PSBoundParameters.Remove("ChatOnce")
        }

        if (-not $PSBoundParameters.ContainsKey("NoConfirmationToolFunctionNames")) {

            $null = $PSBoundParameters.Add("NoConfirmationToolFunctionNames", $Global:LMStudioGlobalNoConfirmationToolFunctionNames);
        }
        else {

            $NoConfirmationToolFunctionNames = $PSBoundParameters["NoConfirmationToolFunctionNames"]
        }

        $hadAQuery = -not [string]::IsNullOrEmpty($Query)
    }

    process {

        function showToolFunctions {

            if ($ExposedCmdLets.Count -gt 0) {

                Write-Host -ForegroundColor Green `
                    "Tool functions now active ($($ExposedCmdLets.Count)) -> " `
                    "$( ($ExposedCmdLets | ForEach-Object Name | ForEach-Object {
                        if ($_ -in $NoConfirmationToolFunctionNames) {
                            "$_*"
                        }
                        else {
                            "$_"
                        }
                     } ) -join ', ')"
            }
            else {

                Write-Host -ForegroundColor Yellow `
                    "No tool functions active"
            }
        }

        function askForConfirmationSettings {

            param(

                [bool] $add,
                $updatedCmdLets
            )
            if ($updatedCmdLets.Count -gt 0) {

                $updatedNames = @($updatedCmdLets | ForEach-Object Name)

                if ($add) {

                    switch ($host.ui.PromptForChoice(
                            "Make a choice",
                            "Allow invocation without confirmation?",
                            @(
                                "&No",
                                "&Yes"
                            ),
                            1)) {

                        0 {
                            $NoConfirmationToolFunctionNames = @(@($NoConfirmationToolFunctionNames | Where-Object -Property Name -NotIn ($updatedNames)))
                            break;
                        }
                        1 {
                            $NoConfirmationToolFunctionNames = @(@(@($NoConfirmationToolFunctionNames) + @($updatedNames)) | Select-Object -Unique)
                            break;
                        }
                    }
                }
                else {

                    $NoConfirmationToolFunctionNames = @($NoConfirmationToolFunctionNames | Where-Object -Property Name -NotIn ($updatedNames))
                }

                $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames
            }
        }

        Write-Verbose "Starting chat interaction loop"

        # initialize chat state
        $script:isFirst = -not $ContinueLast
        $shouldStop = $hadAQuery -or $ChatOnce

        if ($shouldStop) {

            showToolFunctions
        }
        else {

            # display available tools
            showToolFunctions

            # main menu loop
            while (-not $shouldStop) {

                # prompt user for action choice
                $choice = $host.ui.PromptForChoice(
                    "Make a choice",
                    "What to start with?",
                    @(
                        "&Chat",
                        "&Add functions",
                        "&Remove functions",
                        "&Powershell command",
                        "&Stop"
                    ),
                    0)

                # handle user choice
                switch ($choice) {
                    0 {
                        [Console]::Write("> ")
                        $shouldStop = $true
                        break
                    }
                    1 {
                        # add new functions
                        [Console]::Write("LikeExpression for function name? > ")
                        $likeExpression = [Console]::ReadLine()
                        $newCmdLets = @(Get-Command $likeExpression)
                        $ExposedCmdLets = @($ExposedCmdLets + $newCmdLets)
                        $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
                        $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames

                        askForConfirmationSettings $true $newCmdLets

                        $NoConfirmationToolFunctionNames = $Global:LMStudioGlobalNoConfirmationToolFunctionNames
                        showToolFunctions
                        break
                    }
                    2 {
                        # remove functions
                        [Console]::Write("LikeExpression for function name? > ")
                        $likeExpression = [Console]::ReadLine()
                        $oldCmdLets = @($ExposedCmdLets | Where-Object -Property Name -Like $likeExpression)
                        $ExposedCmdLets = @($ExposedCmdLets | Where-Object -Property Name -NotLike $likeExpression)
                        $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
                        $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames

                        askForConfirmationSettings $false $oldCmdLets

                        $NoConfirmationToolFunctionNames = $Global:LMStudioGlobalNoConfirmationToolFunctionNames

                        showToolFunctions
                        break
                    }
                    3 {
                        # execute PowerShell command
                        [Console]::Write("PS $(Get-Location)> ")
                        $expression = [Console]::ReadLine()
                        Invoke-Expression $expression | Out-Host
                        break
                    }
                    4 {
                        $shouldStop = $true
                        return
                    }
                }
            }
        }

        $shouldStop = $false;

        # chat interaction loop
        while (-not $shouldStop) {

            $question = ""
            if (-not $ChatOnce -and [string]::IsNullOrWhiteSpace($Query)) {

                # get user input
                $question = [Console]::ReadLine()
                if ($null -eq $question) { $question = [string]::Empty }
            }
            else {

                if (-not [string]::IsNullOrWhiteSpace($Query)) {

                    $question = $Query
                    $Query = [string]::Empty
                }
            }

            Write-Verbose "Processing query: $question"

            $PSBoundParameters["ContinueLast"] = (-not $script:isFirst);
            $PSBoundParameters["Query"] = $question;
            $PSBoundParameters["ExposedCmdLets"] = $ExposedCmdLets;

            Invoke-LMStudioQuery @PSBoundParameters | ForEach-Object {

                if (($null -eq $_) -or ([string]::IsNullOrEmpty("$_".trim()))) { return }

                $script:isFirst = $false

                if ($ChatOnce) {

                    Write-Output $_
                }
                else {

                    Write-Host -ForegroundColor Yellow "$_"
                }
                # post-response menu loop
                $stopPrompt = $ChatOnce
                $shouldStop = $ChatOnce
                while (-not ($stopPrompt -or $shouldStop)) {

                    switch ($host.ui.PromptForChoice(
                            "Make a choice",
                            "What to do next?",
                            @(
                                "&Chat",
                                "&Add functions",
                                "&Remove functions",
                                "&Powershell command",
                                "&Stop"
                            ),
                            0)) {
                        0 {
                            if ($ChatOnce) {

                                $shouldStop = $true
                                break;
                            }
                            else {

                                [Console]::Write("> ");
                                $stopPrompt = $true;
                                break;
                            }
                        }
                        1 {
                            [Console]::Write("LikeExpression for function name? > ")
                            $likeExpression = [Console]::ReadLine()
                            $newCmdLets = @(Get-Command $likeExpression)
                            $ExposedCmdLets = $ExposedCmdLets + $newCmdLets;
                            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
                            $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames

                            askForConfirmationSettings $true $newCmdLets

                            $NoConfirmationToolFunctionNames = $Global:LMStudioGlobalNoConfirmationToolFunctionNames

                            showToolFunctions
                            break;
                        }
                        2 {
                            [Console]::Write("LikeExpression for function name? > ")
                            $likeExpression = [Console]::ReadLine()
                            $oldCmdlets = @($ExposedCmdLets | Where-Object -Property Name -Like $likeExpression)
                            $ExposedCmdLets = @($ExposedCmdLets | Where-Object -Property Name -NotLike $likeExpression)
                            $Global:LMStudioGlobalExposedCmdlets = $ExposedCmdLets
                            $Global:LMStudioGlobalNoConfirmationToolFunctionNames = $NoConfirmationToolFunctionNames

                            askForConfirmationSettings $false $oldCmdlets

                            $NoConfirmationToolFunctionNames = $Global:LMStudioGlobalNoConfirmationToolFunctionNames

                            showToolFunctions
                            break;
                        }
                        3 {
                            [Console]::Write("PS $(Get-Location)> ")
                            $expression = [Console]::ReadLine()
                            Invoke-Expression $expression | Out-Host
                            break;
                        }
                        4 {
                            if ($ChatOnce) {

                                throw "Stopped"
                            }
                            $shouldStop = $true
                            break;
                        }
                    }
                }
            }
        }
    }

    end {
        Write-Verbose "Chat session completed"
    }
}
################################################################################