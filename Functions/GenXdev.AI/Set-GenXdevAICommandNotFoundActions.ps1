################################################################################
<#
.SYNOPSIS
Sets up custom command not found handling with AI assistance.

.DESCRIPTION
Configures PowerShell to handle unknown commands by either navigating to
directories or using AI to interpret user intent.

.EXAMPLE
Set-GenXdevAICommandNotFoundActions
#>
function Set-GenXdevAICommandNotFoundActions {

    [CmdletBinding()]
    param()

    begin {
        Write-Verbose "Initializing command not found handler"

        # store reference to existing handler if it's not already our handler
        $script:originalHandler = $null
        $currentHandler = $ExecutionContext.InvokeCommand.CommandNotFoundAction

        # check if we're already installed
        if ($null -ne $currentHandler) {
            $handlerStr = $currentHandler.ToString()
            if ($handlerStr.Contains("Do you want AI to figure out")) {
                Write-Verbose "AI Command handler already installed"
                return
            }
            $script:originalHandler = $currentHandler
            Write-Verbose "Storing original command handler for chaining"
        }
    }

    process {
        try {
           
            # initialize last command tracker
            $global:lastCmd = ""

            Write-Verbose "Setting up CommandNotFoundAction handler"

            # define the command not found action handler
            $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
                param($CommandName, $CommandLookupEventArgs)

                # try original handler first if it exists
                if ($null -ne $script:originalHandler) {
                    Write-Verbose "Trying original handler first"
                    & $script:originalHandler $CommandName $CommandLookupEventArgs

                    # if original handler handled it, we're done
                    if ($CommandLookupEventArgs.StopSearch) {
                        return
                    }
                }

                # handle directory navigation if command is a valid path
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

                # handle unknown commands with AI assistance
                $CommandLookupEventArgs.CommandScriptBlock = {
                    $choice = $host.ui.PromptForChoice(
                        "Command not found",
                        "Do you want AI to figure out what you want?",
                        @("&Nah", "&Yes"),
                        0)

                    if ($choice -eq 0) { return }

                    Write-Host -ForegroundColor Yellow "What did you want to do?"
                    [Console]::Write("> ")
                    $what = [Console]::ReadLine()
                    Write-Host -ForegroundColor Green "Ok, hold on a sec.."

                    hint ("Generate a Powershell commandline that would be what " +
                        "user might have meant, but what triggered the " +
                        "`$ExecutionContext.InvokeCommand.CommandNotFoundAction " +
                        "with her prompt being: $what")
                }.GetNewClosure()

                $CommandLookupEventArgs.StopSearch = $true
            }
        }
        catch {
            Write-Error "Failed to set up command not found handler: $_"
        }
    }

    end {
        Write-Verbose "Command not found handler configured successfully"
    }
}
################################################################################
