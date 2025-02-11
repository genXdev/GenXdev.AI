function Set-AICommandSuggestion {
    param(
        [Parameter(Mandatory)]
        [string]$Command
    )

    return @{
        command = $Command.Trim()
        success = $true
    } | ConvertTo-Json -WarningAction SilentlyContinue
}


################################################################################
<#
.SYNOPSIS
Generates and executes PowerShell commands using AI assistance.

.DESCRIPTION
Uses LM-Studio to generate PowerShell commands based on natural language queries
and either sends them to the current PowerShell window or copies to clipboard.

.PARAMETER Query
The natural language query to generate a PowerShell command.

.PARAMETER Model
Name or partial path of the model to initialize, detects and excepts -like 'patterns*' for search

.PARAMETER Temperature
Controls randomness in the response (0.0-1.0). Lower values are more focused.

.PARAMETER Clipboard
Switch to copy the generated command to clipboard instead of executing it.

.EXAMPLE
Invoke-AIPowershellCommand -Query "list all running processes" -Model "qwen"

.EXAMPLE
hint "list files modified today"
#>
function Invoke-AIPowershellCommand {

    [CmdletBinding()]
    [Alias("hint")]

    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "The query string for the LLM."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response"
        )]
        [PSDefaultValue(Value = "qwen")]
        [string] $Model = "qwen",
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Temperature parameter for response randomness"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.01,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Only set clipboard"
        )]
        [switch] $Clipboard
        ########################################################################
    )

    begin {

        Write-Verbose "Initializing AI command generation with model: $Model"

        # simplified instructions focusing on command generation
        $instructions = "You are a PowerShell expert.
Although you only have access to a limited set of tool functions to execute
in your suggested powershell commandline script, you are not limited
and have access to everything Powershell has to offer.
Analyze the user's request and suggest a PowerShell command that accomplishes their goal.
First try basic powershell commands, if that does not solve it then try to use the
Get-GenXDevCmdlets, Get-Help and the Get-Command cmdlets to find the right commands to use.
Use the Set-AICommandSuggestion function with the command you suggest. return only what
Set-AICommandSuggestion returns in json format.
"
    }

    process {
        Write-Verbose "Generating PowerShell command for query: $Query"

        # generate command using LM-Studio with exposed cmdlet
        $result = Invoke-LMStudioQuery `
            -Query $Query `
            -Model $Model `
            -Temperature $Temperature `
            -Instructions $instructions `
            -ExposedCmdLets @(
            @{
                Name          = "Get-Command"
                AllowedParams = @("Name=string")
                Confirm       = $false
                JsonDepth     = 3
                OutputText    = $false
            },
            @{
                Name          = "Set-AICommandSuggestion"
                AllowedParams = @("Command")
                Confirm       = $false
            },
            @{
                Name          = "Get-GenXDevCmdlets"
                AllowedParams = @("ModuleName", "Filter")
                Confirm       = $false
            },
            @{
                Name          = "Get-Help"
                AllowedParams = @("Name=string")
                Confirm       = $false
                ForcedParams  = @(
                    @{
                        Name  = "Category"
                        Value = "Cmdlet"
                    }
                )
            }
        ) | `
            ConvertFrom-Json

        # extract command from result
        $command = ($result | ConvertFrom-Json).Command

        if (-not $command.success) {

            Write-Warning "Failed to generate command: $command"
            return
        }

        if ($Clipboard) {

            # copy to clipboard
            $command | Set-Clipboard
            Write-Verbose "Command copied to clipboard"
        }
        else {
            # get main window and send command
            $window = Get-PowershellMainWindow
            if ($null -ne $window) {

                $window.SetForeground()
            }
            Send-Keys ("`r`n$command".Replace("`r`n", " ``+{ENTER}"))
        }
    }
}
################################################################################
