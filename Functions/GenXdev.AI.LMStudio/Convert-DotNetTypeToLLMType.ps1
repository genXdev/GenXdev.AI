################################################################################
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
# Returns: "string"

.EXAMPLE
Convert-DotNetTypeToLLMType "System.Collections.Generic.List``1"
# Returns: "array"
#>
function Convert-DotNetTypeToLLMType {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The .NET type name to convert to an LLM type name"
        )]
        [string]$DotNetType
        ########################################################################
    )

    begin {
        Write-Verbose "Converting .NET type '$DotNetType' to LLM type"
    }

    process {
        # convert the .net type to a simplified llm type using a switch statement
        $result = switch ($DotNetType) {
            "System.Management.Automation.SwitchParameter]" { "boolean" }
            "System.Management.Automation.PSObject" { "object" }
            "System.String" { "string" }
            "System.Int32" { "number" }
            "System.Int64" { "number" }
            "System.Double" { "number" }
            "System.Boolean" { "boolean" }
            "System.Object[]" { "array" }
            "System.Collections.Generic.List`1" { "array" }
            "System.Collections.Hashtable" { "object" }
            "System.Collections.Generic.Dictionary`2" { "object" }
            default { "object" }
        }

        Write-Verbose "Converted '$DotNetType' to '$result'"
        return $result
    }

    end {
    }
}
################################################################################
