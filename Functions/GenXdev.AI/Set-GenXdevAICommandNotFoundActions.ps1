################################################################################
<#
.SYNOPSIS
Sets up custom command not found handling with AI assistance.

.DESCRIPTION
Configures PowerShell to handle unknown commands by either navigating to
directories or using AI to interpret user intent. The handler first tries any
existing command not found handler, then checks if the command is a valid path
for navigation, and finally offers AI assistance for unknown commands.

.EXAMPLE
Set-GenXdevAICommandNotFoundActions
#>
function Set-GenXdevAICommandNotFoundActions {

    [CmdletBinding()]
    param()

    begin {

        # initialize logging for function start
        Write-Verbose "Starting Set-GenXdevAICommandNotFoundActions"

        # store reference to existing handler if it's not already our handler
        $script:originalHandler = $null
        $currentHandler = $ExecutionContext.InvokeCommand.CommandNotFoundAction

        # check if handler is already installed by looking for unique string
        if ($null -ne $currentHandler) {
            $handlerString = $currentHandler.ToString()
            if ($handlerString.Contains("Do you want AI to figure out")) {
                Write-Verbose "AI Command handler already installed - exiting"
                return
            }
            $script:originalHandler = $currentHandler
            Write-Verbose "Stored original command handler for chaining"
        }
    }

    process {
        try {

            # initialize global variable to track last command
            $global:lastCmd = ""

            Write-Verbose "Configuring new CommandNotFoundAction handler"

            # define the command not found action handler
            $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
                param($CommandName, $CommandLookupEventArgs)

                # try original handler first if one exists
                if ($null -ne $script:originalHandler) {
                    Write-Verbose "Executing original handler"
                    & $script:originalHandler $CommandName $CommandLookupEventArgs

                    # exit if original handler handled the command
                    if ($CommandLookupEventArgs.StopSearch) {
                        return
                    }
                }

                # check if command is a directory path and handle navigation
                if (Test-Path -Path $CommandName -PathType Container) {
                    $CommandLookupEventArgs.CommandScriptBlock = {
                        Set-Location $CommandName
                        Get-ChildItem
                    }.GetNewClosure()
                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                # skip internal commands and get- commands
                if ($CommandLookupEventArgs.CommandOrigin -eq "Internal" -or
                    $CommandName -like "get-*") {
                    return
                }

                # configure AI assistance for unknown commands
                $CommandLookupEventArgs.CommandScriptBlock = {
                    $userChoice = $host.ui.PromptForChoice(
                        "Command not found",
                        "Do you want AI to figure out what you want?",
                        @("&Nah", "&Yes"),
                        0)

                    if ($userChoice -eq 0) { return }

                    Write-Host -ForegroundColor Yellow "What did you want to do?"
                    [Console]::Write("> ")
                    $userIntent = [Console]::ReadLine()
                    Write-Host -ForegroundColor Green "Ok, hold on a sec.."

                    # prepare AI hint for command interpretation
                    hint ("Generate a Powershell commandline that would be what " +
                        "user might have meant, but what triggered the " +
                        "`$ExecutionContext.InvokeCommand.CommandNotFoundAction " +
                        "with her prompt being: $userIntent")
                }.GetNewClosure()

                $CommandLookupEventArgs.StopSearch = $true
            }
        }
        catch {
            Write-Error "Failed to set up command not found handler: $_"
        }
    }

    end {
        Write-Verbose "Command not found handler configuration completed"
    }
}
################################################################################
