########################################################################
function Invoke-CommandFromToolCall {
    [CmdletBinding()]
    param(
        ########################################################################
        # Tool call object containing function details and arguments
        [Parameter(Mandatory = $true, Position = 0)]
        [ValidateNotNull()]
        [hashtable]
        $ToolCall,
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
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force output as text"
        )]
        [switch] $ForceAsText
    )

    begin {

        $result = [GenXdev.Helpers.ExposedToolCallInvocationResult] @{}
        $result.CommandExposed = $false
        $result.Reason = "Function not found, check spellling, use fullname and check if function is advertised as tool function."
        $result.Output = $null
        $result.OutputType = $null
        $result.FullName = $null
        $result.UnfilteredArguments = $ToolCall.function.arguments | ConvertFrom-Json -ErrorAction SilentlyContinue | ConvertTo-HashTable | Select-Object -First 1
        $result.UnfilteredArguments[0]
        $result.FilteredArguments = [hashtable] @{}
        $result.ExposedCmdLet = $null
        $result.Error = $null`

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
        foreach ($function in $matchedFunctions) {

            # start optimistic
            $result.CommandExposed = $true

            # start by checking if all required parameters are present
            $function.parameters.required | ForEach-Object {

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
            [Hashtable] $properies = $function.parameters.properties

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
                        ($_.Name -EQ ($function.name)) -or
                        ($function.name -like "*\$($_.Name)")
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

            $cb = $function.callback;
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
                        "-$($_.Name) ($($_.Value | ConvertTo-Json -Compress -Depth 10 -WarningAction SilentlyContinue))"
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
                            $tmpResult = &$cb @filteredArguments
                            break;
                        }

                        1 {
                            throw "User cancelled execution"
                            break;
                        }
                    }
                }

                if ($null -eq $tmpResult) {

                    $tmpResult = "null # No output (success, void return)"
                }
                else {

                    $result.OutputType = "string"
                }

                if ($tmpResult -isnot [string]) {

                    $result.OutputType = "application/json"
                    $jsonDepth = 2;
                    if ($result.ExposedCmdLet -and $result.ExposedCmdLet.JsonDepth) {

                        $jsonDepth = $result.ExposedCmdLet.JsonDepth;
                    }
                    $asText = $ForceAsText -or ($result.ExposedCmdLet -and ($result.ExposedCmdLet.OutputText -eq $true));
                    if ($asText) {

                        $tmpResult = (@($tmpResult) | ForEach-Object { $_ | Out-String }) | ConvertTo-Json -Depth $jsonDepth -WarningAction SilentlyContinue
                    }
                    else {

                        if ($tmpResult -is [System.ValueType]) {

                            $tmpResult = $tmpResult | ConvertTo-Json -Depth $jsonDepth -ErrorAction SilentlyContinue  -WarningAction SilentlyContinue
                        }
                        else {

                            $tmpResult = $tmpResult | ConvertTo-HashTable | ConvertTo-Json -Depth $jsonDepth -ErrorAction SilentlyContinue  -WarningAction SilentlyContinue
                        }
                    }
                }

                $result.Output = $tmpResult
            }
            catch {
                $result.Error = [PSCustomObject]@{
                    error           = $_.Exception.Message
                    exceptionThrown = $true
                    exceptionClass  = $_.Exception.GetType().FullName
                } | ConvertTo-Json -Compress -Depth 3  -WarningAction SilentlyContinue
            }

            # we only execute the first matching function
            break;
        }
    }

    end {

        Write-Output $result
    }
}
