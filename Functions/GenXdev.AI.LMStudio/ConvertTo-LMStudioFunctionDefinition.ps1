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
    [OutputType([System.Collections.Generic.List[hashtable]])]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "PowerShell commands to convert to tool functions"
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @()
    )

    begin {

        # create result collection to store function definitions
        [System.Collections.Generic.List[hashtable]] $result = New-Object "System.Collections.Generic.List[System.Collections.Hashtable]"

        Write-Verbose "Starting conversion of PowerShell functions to LMStudio format"
    }

    process {

        if ($ExposedCmdLets) {

            foreach ($currentCommand in $ExposedCmdLets) {

                $commandInfo = Get-Command -Name ($currentCommand.Name) -ErrorAction SilentlyContinue | Select-Object -First 1

                if ($null -eq $commandInfo) {

                    Write-Warning "Command $($currentCommand.Name) not found. Skipping."
                    continue
                }

                $allowedParams = @($currentCommand.AllowedParams);

                Write-Verbose "Processing command: $($currentCommand.Name)"

                # Handle both function and cmdlet types
                $callback = $commandInfo

                # initialize collections for parameter processing
                [System.Collections.Generic.List[string]]$requiredParams = @()
                $propertiesTable = @{}

                @($commandInfo.Parameters.GetEnumerator()).Value | ForEach-Object {
                    $parameter = $_

                    [System.Management.Automation.ParameterMetadata]$parameter = $_

                    $found = $false
                    $typeStr = ""
                    foreach ($allowedParam in $allowedParams) {

                        $parts = "$allowedParam".Split("=");
                        $name = $parts[0].Trim()

                        if ($parameter.Name -like $name) {

                            $found = $true
                            if ($parts.Length -gt 1) {

                                $typeStr = $parts[1].Trim()
                            }
                            break
                        }
                    }

                    if (-not $found) {

                        return
                    }

                    $returnType = "";
                    $powershell_returnType = "";

                    # track required parameters
                    $parameter.Attributes | ForEach-Object {
                        if ($_.TypeId -eq "System.Management.Automation.ParameterAttribute") {

                            if ($_.Mandatory) {

                                $null = $requiredParams.Add($parameter.Name)
                            }
                        }
                        if ($_.TypeId -eq "System.Management.Automation.OutputTypeAttribute") {

                            [System.Management.Automation.OutputTypeAttribute] $p = $_

                            $powershell_returnType = $p.Type
                            $returnType = Convert-DotNetTypeToLLMType -DotNetType $powershell_returnType.FullName
                        }
                    }

                    # build parameter properties
                    $helpMessage = $null;
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

                    if ([string]::IsNullOrWhiteSpace($helpMessage )) {

                        $propertiesTable."$($parameter.Name)" = @{

                            type            = [string]::IsNullOrWhiteSpace($typeStr) ? (Convert-DotNetTypeToLLMType -DotNetType $parameter.ParameterType.FullName) : $typeStr
                            powershell_type = $parameter.ParameterType.FullName
                        }
                    }
                    else {
                        $propertiesTable."$($parameter.Name)" = @{

                            type            = [string]::IsNullOrWhiteSpace($typeStr) ? (Convert-DotNetTypeToLLMType -DotNetType $parameter.ParameterType.FullName) : $typeStr
                            powershell_type = $parameter.ParameterType.FullName
                            description     = $helpMessage
                        }
                    }
                }

                # get command help message
                $functionHelpMessage = $commandInfo.Description

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
                if ([string]::IsNullOrWhiteSpace($functionHelpMessage)) {
                    try {

                        $functionHelpMessage = "$((Get-Help ("$ModuleName$($commandInfo.Name)")).description.Text)"
                    }
                    catch {
                        $functionHelpMessage = "No description available."
                    }
                }

                # build and add function definition
                $name = $commandInfo.Name
                $found = $false;
                $allcmdLetNames = @($name.ToLowerInvariant(), ($moduleName.ToLowerInvariant() + $name.ToLowerInvariant()))
                $NoConfirmationToolFunctionNames = @($ExposedCmdLets | Where-Object -Property Confirm -EQ $false | Select-Object -ExpandProperty Name)

                foreach ($AllowedCmdLet in $NoConfirmationToolFunctionNames) {

                    if ($AllowedCmdLet.ToLowerInvariant() -in $allcmdLetNames) {

                        $found = $true
                        break;
                    }
                }

                $newFunctionDefinition = @{
                    type     = "function"
                    function = @{
                        name                       = "$name"
                        description                = "$functionHelpMessage"
                        user_confirmation_required = (-not $found)
                        parameters                 = @{
                            type       = 'object'
                            properties = $propertiesTable
                            required   = $requiredParams
                        }
                        callback                   = $callback
                    }
                }

                if (-not [string]::IsNullOrWhiteSpace($powershell_returnType)) {

                    $newFunctionDefinition.function.powershell_returnType = $powershell_returnType
                }

                if (-not [string]::IsNullOrWhiteSpace($returnType)) {

                    $newFunctionDefinition.function.returnType = $returnType
                }

                $null = $result.Add($newFunctionDefinition)
            }
        }
    }

    end {

        Write-Verbose "Completed conversion with $($result.Count) function definitions"
        Write-Output $result
    }
}
################################################################################
