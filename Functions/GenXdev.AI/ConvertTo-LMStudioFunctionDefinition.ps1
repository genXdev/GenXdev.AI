<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : ConvertTo-LMStudioFunctionDefinition.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.284.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
###############################################################################Module: GenXdev.AI.LMStudio
###############################################################################Purpose: Converts PowerShell function definitions into a format compatible with LMStudio's
###############################################################################         function calling interface. This enables seamless integration between PowerShell
###############################################################################         commands and LMStudio's AI capabilities.
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
##############################################################################
#>

###############################################################################Main function that handles the conversion process from PowerShell to LMStudio format
function ConvertTo-LMStudioFunctionDefinition {

    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[hashtable]])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param(
        ########################################################################
        # Array of custom objects containing function definitions and their allowed parameters
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'PowerShell commands to convert to tool functions'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @()
    )

    begin {

        # Initialize collection to store the converted function definitions
        [System.Collections.Generic.List[hashtable]] $result = Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.List[System.Collections.Hashtable]'

        Microsoft.PowerShell.Utility\Write-Verbose 'Starting conversion of PowerShell functions to LMStudio format'
    }


    process {

        if ($ExposedCmdLets) {

            foreach ($currentCommand in $ExposedCmdLets) {

                # Retrieve detailed command information from PowerShell
                $commandInfo = Microsoft.PowerShell.Core\Get-Command -Name ($currentCommand.Name) -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Select-Object -First 1

                # Skip if command doesn't exist in the current session
                if ($null -eq $commandInfo) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Command $($currentCommand.Name) not found. Skipping."
                    continue
                }

                # Extract allowed parameters for this command
                $allowedParams = @($currentCommand.AllowedParams);

                Microsoft.PowerShell.Utility\Write-Verbose "Processing command: $($currentCommand.Name)"

                # Store command info for callback handling
                $callback = $commandInfo

                # Collections to track parameter metadata
                [System.Collections.Generic.List[string]]$requiredParams = @()
                $propertiesTable = @{}

                # Process each parameter of the command
                @($commandInfo.Parameters.GetEnumerator()).Value | Microsoft.PowerShell.Core\ForEach-Object {
                    $parameter = $_

                    [System.Management.Automation.ParameterMetadata]$parameter = $_

                    # Check if parameter is in allowed list and extract type information
                    $found = $false
                    $typeStr = ''
                    foreach ($allowedParam in $allowedParams) {

                        # Parse parameter name and optional type override
                        $parts = "$allowedParam".Split('=');
                        $name = $parts[0].Trim()

                        if ($parameter.Name -like $name) {

                            $found = $true
                            if ($parts.Length -gt 1) {

                                $typeStr = $parts[1].Trim()
                            }
                            break
                        }
                    }

                    # Skip parameters not in allowed list
                    if (-not $found) {

                        return
                    }

                    # Track return type information
                    $returnType = '';
                    $powershell_returnType = '';

                    # Process parameter attributes
                    $parameter.Attributes | Microsoft.PowerShell.Core\ForEach-Object {
                        # Handle mandatory parameters
                        if ($_.TypeId -eq 'System.Management.Automation.ParameterAttribute') {

                            if ($_.Mandatory) {

                                $null = $requiredParams.Add($parameter.Name)
                            }
                        }
                        # Extract return type information
                        if ($_.TypeId -eq 'System.Management.Automation.OutputTypeAttribute') {

                            [System.Management.Automation.OutputTypeAttribute] $p = $_

                            $powershell_returnType = $p.Type
                            $returnType = GenXdev.AI\Convert-DotNetTypeToLLMType -DotNetType $powershell_returnType.FullName
                        }
                    }

                    # Attempt to get parameter help message from command documentation
                    $helpMessage = $null;

                    try {
                        $moduleName = $commandInfo.ModuleName
                        if ($moduleName -like 'GenXdev.*') {

                            $moduleName = (($commandInfo.ModuleName.Split('.') | Microsoft.PowerShell.Utility\Select-Object -First 2) -Join '.')
                        }

                        if ([string]::IsNullOrWhiteSpace($moduleName)) {

                            $moduleName = ''
                        }
                        else {

                            $moduleName = "$moduleName\"
                        }

                        $help = Microsoft.PowerShell.Core\Get-Help -Name "$ModuleName$($commandInfo.Name)" -Parameter ($parameter.Name) -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                        if ($null -eq $help) {

                            $help = Microsoft.PowerShell.Core\Get-Help -Name ($commandInfo.Name) -Parameter ($parameter.Name) -ErrorAction SilentlyContinue -WarningAction SilentlyContinue
                        }

                        if ($null -ne $help) {

                            $paramHelp = $help ? "$(($help.description | Microsoft.PowerShell.Utility\Out-String).trim())" : $null
                            if (-not [string]::IsNullOrWhiteSpace($paramHelp)) {

                                $helpMessage = $paramHelp
                            }
                        }
                    }
                    catch {

                        $helpMessage = $null
                        Microsoft.PowerShell.Utility\Write-Verbose "Could not get help message for parameter $($parameter.Name)"
                    }

                    # Build parameter property dictionary with type information and description
                    if ([string]::IsNullOrWhiteSpace($helpMessage)) {

                        $propertiesTable."$($parameter.Name)" = @{

                            type            = [string]::IsNullOrWhiteSpace($typeStr) ? (GenXdev.AI\Convert-DotNetTypeToLLMType -DotNetType $parameter.ParameterType.FullName) : $typeStr
                            powershell_type = $parameter.ParameterType.FullName
                        }
                    }
                    else {
                        $propertiesTable."$($parameter.Name)" = @{

                            type            = [string]::IsNullOrWhiteSpace($typeStr) ? (GenXdev.AI\Convert-DotNetTypeToLLMType -DotNetType $parameter.ParameterType.FullName) : $typeStr
                            powershell_type = $parameter.ParameterType.FullName
                            description     = $helpMessage
                        }
                    }

                    # Handle switch parameters explicitly - ensure they get proper boolean/object type
                    if ($parameter.ParameterType.FullName -eq 'System.Management.Automation.SwitchParameter') {
                        $paramDefinition = $propertiesTable."$($parameter.Name)"
                        # Use boolean if no type override is specified, otherwise respect the override
                        if ([string]::IsNullOrWhiteSpace($typeStr)) {
                            # Try 'boolean' first, fallback to 'object' if needed
                            # This can be configured based on the target system's capabilities
                            $paramDefinition.type = 'object'  # Use 'object' as default for broader compatibility
                        }
                        Microsoft.PowerShell.Utility\Write-Verbose "Switch parameter '$($parameter.Name)' set to type '$($paramDefinition.type)'"
                    }

                    if ($parameter.ParameterType.IsEnum) {

                        $paramDefinition = $propertiesTable."$($parameter.Name)"
                        $paramDefinition.type = 'string'
                        $paramDefinition.enum = @($parameter.ParameterType.GetEnumNames())
                    }
                }

                # Get function-level help message and normalize module name
                $functionHelpMessage = $commandInfo.Description

                $moduleName = $commandInfo.ModuleName

                if ($moduleName -like 'GenXdev.*') {

                    $moduleName = (($commandInfo.ModuleName.Split('.') | Microsoft.PowerShell.Utility\Select-Object -First 2) -Join '.')
                }

                if ([string]::IsNullOrWhiteSpace($moduleName)) {

                    $moduleName = ''
                }
                else {
                    $moduleName = "$moduleName\"
                }

                if (-not ([string]::IsNullOrWhiteSpace($currentCommand.Description))) {

                    $functionHelpMessage = $currentCommand.Description
                }
                elseif ([string]::IsNullOrWhiteSpace($functionHelpMessage)) {
                    try {

                        $functionHelpMessage = "$((Microsoft.PowerShell.Core\Get-Help ("$ModuleName$($commandInfo.Name)")).description.Text)"
                    }
                    catch {
                        $functionHelpMessage = 'No description available.'
                    }
                }

                # Check if function requires confirmation based on configuration
                $name = $commandInfo.Name
                $found = $false;
                $allCmdletNames = @($name.ToLowerInvariant(), ($moduleName.ToLowerInvariant() + $name.ToLowerInvariant()))
                $NoConfirmationToolFunctionNames = @($ExposedCmdLets | Microsoft.PowerShell.Core\Where-Object -Property Confirm -EQ $false | Microsoft.PowerShell.Utility\Select-Object -ExpandProperty Name)

                foreach ($AllowedCmdLet in $NoConfirmationToolFunctionNames) {

                    if ($AllowedCmdLet.ToLowerInvariant() -in $allCmdletNames) {

                        $found = $true
                        break;
                    }
                }

                # Construct the final function definition object
                $newFunctionDefinition = @{
                    type     = 'function'
                    function = @{
                        name        = "$name"
                        description = "$functionHelpMessage"
                        parameters  = @{
                            type       = 'object'
                            properties = $propertiesTable
                            required   = $requiredParams
                        }
                        callback    = $callback
                    }
                }

                # Add return type information if available
                if (-not [string]::IsNullOrWhiteSpace($powershell_returnType)) {

                    $newFunctionDefinition.function.powershell_returnType = $powershell_returnType
                }

                if (-not [string]::IsNullOrWhiteSpace($returnType)) {

                    $newFunctionDefinition.function.returnType = $returnType
                }

                # Add the completed function definition to results
                $null = $result.Add($newFunctionDefinition)
            }
        }
    }

    end {

        # Return the collection of converted function definitions
        Microsoft.PowerShell.Utility\Write-Verbose "Completed conversion with $($result.Count) function definitions"
        Microsoft.PowerShell.Utility\Write-Output $result
    }
}