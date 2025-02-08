################################################################################
<#
.SYNOPSIS
Converts PowerShell functions to LMStudio function definitions.

.DESCRIPTION
Takes PowerShell functions and generates LMStudio compatible function definitions
including parameter information and callback handlers.

.PARAMETER Functions
One or more PowerShell function info objects to convert to LMStudio definitions.

.EXAMPLE
Get-Command Get-Process | ConvertTo-LMStudioFunctionDefinition
#>
function ConvertTo-LMStudioFunctionDefinition {

    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[object]])]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "PowerShell commands to convert to tool functions"
        )]
        [System.Management.Automation.CommandInfo[]]
        $ExposedCmdLets,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Array of ToolFunction names that don't require user confirmation"
        )]
        [string[]] $NoConfirmationFor = @(),
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Add full parameter information"
        )]
        [switch] $Full

    )

    begin {

        # create result collection to store function definitions
        $result = [System.Collections.Generic.List[object]]::new()

        Write-Verbose "Starting conversion of PowerShell functions to LMStudio format"
    }

    process {

        if ($ExposedCmdLets) {

            foreach ($currentCommand in $ExposedCmdLets) {

                Write-Verbose "Processing command: $($currentCommand.Name)"

                # Handle both function and cmdlet types
                $commandInfo = $currentCommand -as [System.Management.Automation.CommandInfo]
                $callback = $commandInfo

                $commandInfo.ParameterSets | ForEach-Object {

                    # initialize collections for parameter processing
                    [System.Collections.Generic.List[string]]$requiredParams = @()
                    $parameterSet = $_
                    $propertiesTable = @{}

                    # process each parameter in the set
                    $parameterSet.Parameters | ForEach-Object {

                        [System.Management.Automation.CommandParameterInfo]$parameter = $_

                        # track required parameters
                        if ($parameter.IsMandatory) {
                            if ($requiredParams.IndexOf($parameter.Name) -eq -1) {
                                $null = $requiredParams.Add($parameter.Name)
                            }
                        }
                        else {
                            # Skip common PowerShell parameters
                            if ($_.Name -in @('Verbose', 'Debug', 'ErrorAction', 'WarningAction', 'InformationAction', 'ErrorVariable', 'WarningVariable', 'InformationVariable', "ProgressAction", 'OutVariable', 'OutBuffer', 'PipelineVariable', 'WhatIf', 'Confirm')) {

                                return;
                            }
                        }

                        # build parameter properties
                        $helpMessage = $null;
                        if ($Full) {
                            if ([string]::IsNullOrWhiteSpace($helpMessage)) {

                                try {
                                    $moduleName = $commandInfo.ModuleName
                                    if ($moduleName -like "GenXdev.*") {

                                        $moduleName = (($commandInfo.ModuleName.Split(".") | Select-Object -First 2) -Join ".")
                                    }

                                    if ([string]::IsNullOrWhiteSpace($moduleName)) {

                                        $moduleName = ""
                                    }
                                    else {

                                        $moduleName = "$moduleName\"
                                    }

                                    $help = (Get-Help -Name "$ModuleName$($commandInfo.Name)" -Parameter "$($parameter.name)")
                                    $paramHelp = $help ? "$(($help.description | Out-String).trim())" : $null
                                    if (-not [string]::IsNullOrWhiteSpace($paramHelp)) {

                                        $helpMessage = $paramHelp
                                    }
                                }
                                catch {

                                    $helpMessage = $null
                                    Write-Verbose "Could not get help message for parameter $($parameter.Name)"
                                }
                            }
                        }

                        if ([string]::IsNullOrWhiteSpace($helpMessage )) {

                            $propertiesTable."$($parameter.Name)" = @{

                                type = Convert-DotNetTypeToLLMType -DotNetType $parameter.ParameterType.FullName
                            }
                        }
                        else {
                            $propertiesTable."$($parameter.Name)" = @{

                                type        = Convert-DotNetTypeToLLMType -DotNetType $parameter.ParameterType.FullName
                                description = $helpMessage
                            }
                        }
                    }

                    # get command help message
                    $functionHelpMessage = $commandInfo.Description

                    if ([string]::IsNullOrWhiteSpace($functionHelpMessage)) {
                        try {
                            $moduleNAme = $commandInfo.ModuleName

                            if ($moduleName -like "GenXdev.*") {

                                $moduleName = (($commandInfo.ModuleName.Split(".") | Select-Object -First 2) -Join ".")
                            }

                            if ([string]::IsNullOrWhiteSpace($moduleName)) {

                                $moduleName = ""
                            }
                            else {
                                $moduleName = "$moduleName\"
                            }

                            $functionHelpMessage = "$((Get-Help ("$ModuleName$($commandInfo.Name)")).description.Text)"
                        }
                        catch {
                            $functionHelpMessage = "No description available."
                        }
                    }

                    # build and add function definition
                    $null = $result.Add(
                        @{
                            type     = "function"
                            function = @{
                                name                       = $commandInfo.Name
                                description                = $functionHelpMessage
                                user_confirmation_required = -not ($NoConfirmationFor -contains $commandInfo.Name)
                                parameters                 = @{
                                    type       = 'object'
                                    properties = $propertiesTable
                                    required   = $requiredParams
                                }
                                callback                   = $callback
                            }
                        }
                    )
                }
            }
        }
    }

    end {

        Write-Verbose "Completed conversion with $($result.Count) function definitions"
        return $result
    }
}
################################################################################
