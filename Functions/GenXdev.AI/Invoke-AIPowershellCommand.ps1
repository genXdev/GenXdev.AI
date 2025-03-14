################################################################################
# helper function to process AI command suggestions
function Set-AICommandSuggestion {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([string])]
    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The PowerShell command to process"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Command
        ########################################################################
    )

    if ($PSCmdlet.ShouldProcess($Command, "Process AI command suggestion")) {

        # convert the command suggestion to json format
        return @{
            command = $Command.Trim()
            success = $true
        } | ConvertTo-Json -WarningAction SilentlyContinue
    }
}

################################################################################
<#
.SYNOPSIS
Generates and executes PowerShell commands using AI assistance.

.DESCRIPTION
Uses LM-Studio to generate PowerShell commands based on natural language queries.
The function can either send commands directly to the PowerShell window or copy
them to the clipboard. It leverages AI models to interpret natural language and
convert it into executable PowerShell commands.

.PARAMETER Query
The natural language description of what you want to accomplish. The AI will
convert this into an appropriate PowerShell command.

.PARAMETER Model
The LM-Studio model to use for command generation. Can be a name or partial path.
Supports -like pattern matching for model selection.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Values range from 0.0
(more focused/deterministic) to 1.0 (more creative/random).

.PARAMETER Clipboard
When specified, copies the generated command to clipboard.

.EXAMPLE
Invoke-AIPowershellCommand -Query "list all running processes" -Model "qwen"

.EXAMPLE
hint "list files modified today"
#>
function Invoke-AIPowershellCommand {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([void])]
    [Alias("hint")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The natural language query to generate a command for"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model name or path to use"
        )]
        [ValidateNotNullOrEmpty()]
        [PSDefaultValue(Value = "qwen")]
        [SupportsWildcards()]
        [string] $Model = "qwen",
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "Temperature for controlling response randomness"
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.01,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Copy command to clipboard"
        )]
        [switch] $Clipboard
        ########################################################################
    )

    begin {

        Write-Verbose "Initializing AI command generation with model: $Model"

        # define the AI system prompt with instructions
        $instructions = @"
You are a PowerShell expert.
Although you only have access to a limited set of tool functions to execute
in your suggested powershell commandline script, you are not limited
and have access to everything Powershell has to offer.
Analyze the user's request and suggest a PowerShell command that accomplishes
their goal.
First try basic powershell commands, if that does not solve it then try to use
the Get-GenXDevCmdlets, Get-Help and the Get-Command cmdlets to find the right
commands to use.
Use the Set-AICommandSuggestion function with the command you suggest. return
only what Set-AICommandSuggestion returns in json format.
"@
    }

    process {

        Write-Verbose "Generating PowerShell command for query: $Query"

        # define the cmdlets that will be available to the AI model
        $exposedCmdlets = @(
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
        )


        $result = [string]::Empty

        if ($PSCmdlet.ShouldProcess($command, "Copy command to clipboard")) {

            # generate the command using the AI model
            $result = Invoke-LLMQuery `
                -Query $Query `
                -Model $Model `
                -Temperature $Temperature `
                -Instructions $instructions `
                -ExposedCmdLets $exposedCmdlets | `
                ConvertFrom-Json
        }

        # parse the AI response and extract the command
        $commandResult = ($result | ConvertFrom-Json)

        # verify the command generation was successful
        if (-not $commandResult.success) {

            Write-Warning "Failed to generate command: $($commandResult.command)"
            return
        }

        $command = $commandResult.command

        if ($Clipboard) {
            if ($PSCmdlet.ShouldProcess($command, "Copy command to clipboard")) {
                # copy the generated command to clipboard
                $command | Set-Clipboard
                Write-Verbose "Command copied to clipboard"
            }
        }
        else {
            if ($PSCmdlet.ShouldProcess("PowerShell window", "Send command")) {
                # get the main powershell window for command input
                $mainWindow = Get-PowershellMainWindow
                if ($null -ne $mainWindow) {
                    $null = $mainWindow.SetForeground()
                }

                # send the command with proper line break handling
                Send-Key ("`r`n$command".Replace("`r`n", " ``+{ENTER}"))
            }
        }
    }

    end {
    }
}
################################################################################