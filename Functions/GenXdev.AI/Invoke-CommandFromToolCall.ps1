################################################################################
<#
.SYNOPSIS
Executes a tool call function with validation and parameter filtering.

.DESCRIPTION
This function processes tool calls by validating arguments, filtering parameters,
and executing callbacks with proper confirmation handling. It supports both script
block and command info callbacks.

.PARAMETER ToolCall
A hashtable containing the function details and arguments to be executed.

.PARAMETER Functions
Array of function definitions that can be called as tools.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions available as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that can execute without user confirmation.

.PARAMETER ForceAsText
Forces the output to be formatted as text.

.EXAMPLE
Invoke-CommandFromToolCall -ToolCall $toolCall -Functions $functions `
    -ExposedCmdLets $exposedCmdlets

.EXAMPLE
$result = Invoke-CommandFromToolCall $toolCall $functions -ForceAsText
#>
function Invoke-CommandFromToolCall {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "Tool call object containing function details and args"
        )]
        [ValidateNotNull()]
        [hashtable]
        $ToolCall,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of function definitions"
        )]
        [hashtable[]]
        $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of PowerShell command definitions to use as tools"
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of command names that don't require confirmation"
        )]
        [string[]]
        [Alias("NoConfirmationFor")]
        $NoConfirmationToolFunctionNames = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force output as text"
        )]
        [switch]
        $ForceAsText
    )

    begin {
        # initialize the result object with default values
        $result = [GenXdev.Helpers.ExposedToolCallInvocationResult] @{}
        $result.CommandExposed = $false
        $result.Reason = "Function not found, check spelling and availability"
        $result.Output = $null
        $result.OutputType = $null
        $result.FullName = $null

        # extract and convert arguments from the tool call
        $result.UnfilteredArguments = $ToolCall.function.arguments |
        ConvertFrom-Json -ErrorAction SilentlyContinue |
        ConvertTo-HashTable |
        Select-Object -First 1

        Write-Verbose "Processing tool call: $($ToolCall.function.name)"
        Write-Verbose "Unfiltered arguments: $($result.UnfilteredArguments |
            ConvertTo-Json)"

        $result.FilteredArguments = [hashtable] @{}
        $result.ExposedCmdLet = $null
        $result.Error = $null
    }

    process {

        $fullToolFunction = $ToolCall.function.name
        $toolFunction = $fullToolFunction.Split("\")[1];

        # find all exising predefined function definitions that match the tool call
        $matchedFunctions = @(
            $Functions.function | ForEach-Object {

                $fullFunction = $PSItem.Name
                $function = $fullFunction.Split("\")[1];
                if ([string]::IsNullOrWhiteSpace($function) -or [string]::IsNullOrWhiteSpace($toolFunction)) {

                    if ([string]::IsNullOrWhiteSpace($function) -and [string]::IsNullOrWhiteSpace($toolFunction)) {

                        if ($fullFunction -eq $fullToolFunction) {

                            $PSItem
                        }
                    }
                    elseif ([string]::IsNullOrWhiteSpace($toolFunction)) {

                        if ($function -eq $fullToolFunction) {

                            $PSItem
                        }
                    }
                    else {

                        if ($fullFunction -eq $toolFunction) {

                            $PSItem
                        }
                    }
                }
                else {

                    if ($function -eq $toolFunction) {

                        $PSItem
                    }
                }
            }
        )

        # process each matched function
        foreach ($matchedFunction in $matchedFunctions) {

            # start optimistic
            $result.CommandExposed = $true

            # start by checking if all required parameters are present
            $matchedFunction.parameters.required | ForEach-Object {

                # reference next required parameter's name
                $definedParamName = $_

                $foundArguments = @(
                    $result.UnfilteredArguments.GetEnumerator() | ForEach-Object {
                        if ($PSItem.Name -EQ $definedParamName) { $PSItem } }
                );

                if ($foundArguments.Count -eq 0) {

                    $result.CommandExposed = $false
                    $result.Reason = "Missing required parameter: $definedParamName"
                    $result.Output = $null
                    $result.OutputType = $null
                    $result.FullName = $null
                    $result.UnfilteredArguments = $ToolCall.function.arguments | ConvertFrom-Json -ErrorAction SilentlyContinue | ConvertTo-HashTable | Select-Object -First 1
                    $result.FilteredArguments = [hashtable] @{}
                    $result.ExposedCmdLet = $null
                    $result.Error = $null

                    # maybe there is another function that matches
                    break;
                }
            }

            if (-not $result.CommandExposed) {

                # maybe there is another function that matches
                break;
            }

            # check if all parameters are valid
            [Hashtable] $properies = $matchedFunction.parameters.properties

            foreach ($unfilteredArgument in $result.UnfilteredArguments.GetEnumerator()) {

                $unfilteredArgumentName = $unfilteredArgument.Name

                if ($unfilteredArgumentName -notin $properies.Keys) {

                    $result.CommandExposed = $false
                    $result.Reason = "Function found, but provided argument with name $unfilteredArgumentName not found in advertised tool function parameters"
                    $result.Output = $null
                    $result.OutputType = $null
                    $result.FullName = $null
                    $result.UnfilteredArguments = $ToolCall.function.arguments | ConvertFrom-Json -ErrorAction SilentlyContinue | ConvertTo-HashTable | Select-Object -First 1
                    $result.FilteredArguments = [hashtable] @{}
                    $result.ExposedCmdLet = $null
                    $result.Error = $null

                    # maybe there is another function that matches
                    break;
                }
            }

            if (-not $result.CommandExposed) {

                # maybe there is another function that matches
                break;
            }

            # add all properties and their values from the unfiltered to the filtered arguments
            $result.FilteredArguments = [hashtable] @{}
            foreach ($unfilteredArgument in $result.UnfilteredArguments.GetEnumerator()) {

                $unfilteredArgumentName = $unfilteredArgument.Name

                $result.FilteredArguments."$unfilteredArgumentName" = $unfilteredArgument.Value
            }

            # check if there are any forced parameters
            $foundCmdlets = @(
                $ExposedCmdLets |
                Sort-Object -Property Name -Descending |
                ForEach-Object {
                    if (
                        ($_.Name -EQ ($matchedFunction.name)) -or
                        ($_.Name -like "*\$($matchedFunction.name)") -or
                        ($matchedFunction.name -like "*\$($_.Name)")
                    ) { $_ }
                }
            );

            foreach ($exposedCmdLet in $foundCmdlets) {

                $exposedCmdLetParamNames = @($exposedCmdLet.AllowedParams | ForEach-Object { "$_".Split("=")[0] }) + @($exposedCmdLet.ForcedParams)

                $foundUnmatchingParam = $false;
                foreach ($filteredArgument in $result.FilteredArguments.GetEnumerator()) {

                    $filteredArgumentName = $filteredArgument.Name;

                    if ($filteredArgumentName -notin $exposedCmdLetParamNames) {

                        $foundUnmatchingParam = $true
                        break;
                    }
                }

                if ($foundUnmatchingParam) {

                    $result.CommandExposed = $false
                    $result.Reason = "Function found, but provided argument with name $filteredArgument. Name not found in advertised tool function parameters"
                    $result.Output = $null
                    $result.OutputType = $null
                    $result.FullName = $null
                    $result.UnfilteredArguments = $ToolCall.function.arguments | ConvertFrom-Json -ErrorAction SilentlyContinue | ConvertTo-HashTable | Select-Object -First 1
                    $result.FilteredArguments = [hashtable] @{}
                    $result.ExposedCmdLet = $null
                    $result.Error = $null

                    # maybe there is another function that matches
                    continue
                }

                foreach ($forcedParam in $exposedCmdLet.ForcedParams) {

                    $result.FilteredArguments."$($forcedParam.Name)" = $forcedParam.Value
                }

                $result.ExposedCmdLet = $exposedCmdLet
            }

            if (-not $result.CommandExposed) {

                # maybe there is another function that matches
                break;
            }

            $result.Reason = $null
            $result.Output = $null
            $result.FullName = $ToolCall.function.name

            $cb = $matchedFunction.callback;
            if ($cb -isnot [System.Management.Automation.ScriptBlock] -and
                $cb -isnot [System.Management.Automation.CommandInfo]) {

                throw "Callback is not a script block or command info, type: $(($cb.GetType().FullName))"
            }

            $tmpResult = $null

            try {
                # Execute callback
                # Add confirmation prompt for tool functions that require it
                if (($NoConfirmationToolFunctionNames -and $NoConfirmationToolFunctionNames.IndexOf($toolCall.function.name) -ge 0) -or
                    ($result.ExposedCmdLet -and (-not $result.ExposedCmdLet.Confirm))) {

                    $filteredArguments = $result.FilteredArguments;
                    $tmpResult = &$cb @filteredArguments
                }
                else {

                    $location = (Get-Location).Path
                    $functionName = $toolCall.function.Name
                    $filteredArguments = $result.FilteredArguments;
                    $parametersLine = $filteredArguments.GetEnumerator() | ForEach-Object {

                        $skip = $false;
                        $filteredArgumentName = $_.Name

                        if ($result.ExposedCmdlet) {

                            foreach ($name in $result.ExposedCmdLet.DontShowDuringConfirmationParamNames) {

                                if ($filteredArgumentName -like $name) {

                                    $skip = $true;
                                    break;
                                }
                            }
                        }

                        if (-not $skip) {

                            "-$($_.Name) ($($_.Value | ConvertTo-Json -Compress -Depth 10 -WarningAction SilentlyContinue))"
                        }
                        else {

                            "-$($_.Name) [value]"
                        }
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
                            # Create a string builder to capture verbose output (warnings)
                            $verboseOutput = [System.Text.StringBuilder]::new()
                            $errorOutput = [System.Text.StringBuilder]::new()
                            $warningOutput = [System.Text.StringBuilder]::new()

                            # Create a scriptblocks
                            $verboseScriptBlock = {
                                param($Message)
                                $null = $verboseOutput.AppendLine($Message)
                            }
                            $errorScriptBlock = {
                                param($Message)
                                $null = $errorOutput.AppendLine($Message)
                            }
                            $warningScriptBlock = {
                                param($Message)
                                $null = $warningOutput.AppendLine($Message)
                            }

                            # Save the current VerbosePreference and register the temporary handler
                            $oldVerbosePreference = $VerbosePreference
                            $oldErrorActionPreference = $ErrorActionPreference
                            $oldWarningPreference = $WarningPreference
                            $VerbosePreference = 'Continue'
                            $ErrorActionPreference = 'Continue'
                            $WarningPreference = 'Continue'
                            $null = Register-EngineEvent -SourceIdentifier "Verbose" -Action $verboseScriptBlock
                            $null = Register-EngineEvent -SourceIdentifier "Error" -Action $errorScriptBlock
                            $null = Register-EngineEvent -SourceIdentifier "Warning" -Action $warningScriptBlock

                            try {
                                $tmpResult = &$cb @filteredArguments
                            }
                            catch {
                                $result.ExecutionErrors = $_.Exception.Message
                                $tmpResult = $null
                            }
                            finally {
                                $null = Unregister-Event -SourceIdentifier "Verbose" -ErrorAction SilentlyContinue
                                $null = Unregister-Event -SourceIdentifier "Error" -ErrorAction SilentlyContinue
                                $null = Unregister-Event -SourceIdentifier "Warning" -ErrorAction SilentlyContinue
                                $VerbosePreference = $oldVerbosePreference
                                $ErrorActionPreference = $oldErrorActionPreference
                                $WarningPreference = $oldWarningPreference
                            }

                            if ($verboseOutput.Length -gt 0) {

                                $warnings = $verboseOutput.ToString().Trim().Split("`n")
                                $result.Warnings = $warnings
                            }

                            if (!!$result.ExecutionErrors) {

                                $errorOutput.Append($result.ExecutionErrors)
                            }

                            if ($errorOutput.Length -gt 0) {
                                $errors = $errorOutput.ToString().Trim().Split("`n")
                                $result.Errors = $errors
                            }

                            if ($warningOutput.Length -gt 0) {
                                $warnings = $warningOutput.ToString().Trim().Split("`n")
                                $result.Warnings = $warnings
                            }

                            break;
                        }

                        1 {
                            throw "User cancelled execution"
                            break;
                        }
                    }
                }

                if ($null -eq $tmpResult) {

                    if ($result.Errors -and $result.Errors.Count -gt 0) {

                        $tmpResult = @{
                            success  = $false
                            errors   = $result.Errors
                            warnings = $result.Warnings
                            verbose  = $result.Verbose
                        }
                    }
                    else {
                        $tmpResult = "null # No output (success, void return)"
                    }
                }
                else {

                    # check if the tmpResult is already a valid JSON string
                    # this can happen if the callback already converts to JSON
                    $isAlreadyJson = $false
                    try {
                        if ($tmpResult -is [string]) {
                            $jsonTest = $tmpResult |
                            ConvertFrom-Json -ErrorAction Stop
                            if ($jsonTest) {
                                $isAlreadyJson = $true
                                $result.OutputType = "application/json"
                            }
                        }
                    }
                    catch {
                        # not valid JSON, continue with normal processing
                        $isAlreadyJson = $false
                    }

                    if ($isAlreadyJson) {
                        # already JSON, use it as is
                        $result.Output = $tmpResult
                    }
                    else {
                        # handle non-JSON output
                        $result.OutputType = "string"

                        if ($tmpResult -isnot [string]) {

                            $result.OutputType = "application/json"
                            $jsonDepth = 2;
                            if ($result.ExposedCmdLet -and $result.ExposedCmdLet.JsonDepth) {

                                $jsonDepth = $result.ExposedCmdLet.JsonDepth;
                            }
                            $asText = $ForceAsText -or
                                ($result.ExposedCmdLet -and
                                ($result.ExposedCmdLet.OutputText -eq $true));
                            if ($asText) {

                                $tmpResult = (@($tmpResult) |
                                    ForEach-Object { $_ | Out-String }) |
                                ConvertTo-Json -Depth $jsonDepth `
                                    -WarningAction SilentlyContinue
                            }
                            else {

                                if ($tmpResult -is [System.ValueType] -or
                                    $tmpResult -is [string]) {

                                    $tmpResult = $tmpResult |
                                    ConvertTo-Json -Depth $jsonDepth `
                                        -ErrorAction SilentlyContinue `
                                        -WarningAction SilentlyContinue
                                }
                                else {

                                    $tmpResult = $tmpResult | ForEach-Object {
                                        $_ | ConvertTo-Json `
                                            -ErrorAction SilentlyContinue `
                                            -WarningAction SilentlyContinue `
                                            -Depth ($jsonDepth - 1) |
                                        ConvertFrom-Json `
                                            -ErrorAction SilentlyContinue `
                                            -WarningAction SilentlyContinue |
                                        ConvertTo-HashTable
                                    } | ConvertTo-Json -Depth $jsonDepth `
                                        -ErrorAction SilentlyContinue `
                                        -WarningAction SilentlyContinue
                                }
                            }
                        }

                        $result.Output = $tmpResult
                    }
                }
            }
            catch {
                $result.Error = [PSCustomObject]@{
                    error           = $_.Exception.Message
                    exceptionThrown = $true
                    exceptionClass  = $_.Exception.GetType().FullName
                } | ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue
            }

            # we only execute the first matching function
            break;
        }
    }

    end {

        Write-Output $result
    }
}
################################################################################