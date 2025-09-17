<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Convert-DotNetTypeToLLMType.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.274.2025
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
<#
.SYNOPSIS
Converts .NET type names to LLM (Language Model) type names.

.DESCRIPTION
This function takes a .NET type name as input and returns the corresponding
simplified type name used in Language Models. It handles common .NET types
and provides appropriate type mappings.

.PARAMETER DotNetType
The .NET type name to convert to an LLM type name.

.EXAMPLE
Convert-DotNetTypeToLLMType -DotNetType "System.String"
Returns: "string"

.EXAMPLE
Convert-DotNetTypeToLLMType "System.Collections.Generic.List``1"
Returns: "object"
#>
function Convert-DotNetTypeToLLMType {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The .NET type name to convert to an LLM type name'
        )]
        [string]$DotNetType
        ########################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose "Converting .NET type '$DotNetType' to LLM type"
    }


    process {
        # convert the .net type to a simplified llm type using a switch statement
        # Note: For MCP content types, arrays should be treated as objects since 'array' is not a valid MCP content type
        $result = switch ($DotNetType) {
            'System.Management.Automation.SwitchParameter' { 'boolean' }
            'System.Management.Automation.PSObject' { 'object' }
            'System.String' { 'string' }
            'System.Int32' { 'number' }
            'System.Int64' { 'number' }
            'System.Double' { 'number' }
            'System.Boolean' { 'boolean' }
            'System.Object[]' { 'object' }
            "System.Collections.Generic.List`1" { 'object' }
            'System.Collections.Hashtable' { 'object' }
            "System.Collections.Generic.Dictionary`2" { 'object' }
            default { 'object' }
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Converted '$DotNetType' to '$result'"
        return $result
    }

    end {
    }
}