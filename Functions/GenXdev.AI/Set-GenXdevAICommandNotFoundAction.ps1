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
Set-GenXdevAICommandNotFoundAction
#>
function Set-GenXdevAICommandNotFoundAction {

    [CmdletBinding(SupportsShouldProcess)]
    param()

    begin {

        Write-Verbose "Starting Set-GenXdevAICommandNotFoundAction"

        # store reference to existing handler if it's not already our handler
        $script:originalHandler = $null
        $currentHandler = $ExecutionContext.InvokeCommand.CommandNotFoundAction

        # check if handler is already installed
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

        if (-not $PSCmdlet.ShouldProcess("Command not found handling",
                "Set AI assistance handler")) {
            return
        }

        try {
            # Add flag to prevent recursion
            $script:insideCommandHandler = $false

            Write-Verbose "Configuring new CommandNotFoundAction handler"

            # define the command not found action handler
            $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
                param($CommandName, $CommandLookupEventArgs)

                # prevent recursion
                if ($script:insideCommandHandler) {

                    Write-Debug "Preventing recursive call for command: $CommandName"
                    return
                }

                $script:insideCommandHandler = $true

                $origPSDebugPreference = $PSDebugPreference
                $origErrorActionPreference = $ErrorActionPreference
                $origVerbosePreference = $VerbosePreference
                $origWarningPreference = $WarningPreference

                try {
                    # suppress unnecessary output during handler execution
                    $PSDebugPreference = "continue"
                    $ErrorActionPreference = 'SilentlyContinue'
                    $VerbosePreference = "SilentlyContinue"
                    $WarningPreference = "SilentlyContinue"

                    # skip .NET method calls
                    if ($CommandName -match '^\[.*\]::') {
                        return
                    }

                    # try original handler first
                    if ($null -ne $script:originalHandler) {
                        try {
                            & $script:originalHandler $CommandName $CommandLookupEventArgs

                            if ($CommandLookupEventArgs.StopSearch) {
                                return
                            }
                        }
                        catch {
                            Write-Debug "Original handler failed: $_"
                        }
                    }
                }
                finally {
                    # restore original preferences
                    $PSDebugPreference = $origPSDebugPreference
                    $ErrorActionPreference = $origErrorActionPreference
                    $VerbosePreference = $origVerbosePreference
                    $WarningPreference = $origWarningPreference
                    $script:insideCommandHandler = $false
                }

                # handle directory navigation
                if (Test-Path -Path $CommandName -PathType Container) {

                    $CommandLookupEventArgs.CommandScriptBlock = {
                        Set-Location $CommandName
                        Get-ChildItem
                    }.GetNewClosure()

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                # skip internal and get- commands
                if ($CommandLookupEventArgs.CommandOrigin -eq "Internal" -or
                    $CommandName -like "get-*") {
                    return
                }

                # configure AI assistance
                $CommandLookupEventArgs.CommandScriptBlock = {
                    $userChoice = $host.ui.PromptForChoice(
                        "Command not found",
                        "Do you want AI to figure out what you want?",
                        @("&Nah", "&Yes"),
                        0)

                    if ($userChoice -eq 0) { return }

                    Write-Host -ForegroundColor Yellow "What did you want to do?"
                    [System.Console]::Write("> ")
                    $userIntent = [System.Console]::ReadLine()
                    Write-Host -ForegroundColor Green "Ok, hold on a sec.."

                    # prepare AI hint
                    $aiPrompt = ("Generate a Powershell commandline that would " +
                        "be what user might have meant, but what triggered the " +
                        "`$ExecutionContext.InvokeCommand.CommandNotFoundAction " +
                        "with her prompt being: $userIntent")

                    Invoke-AIPowershellCommand $aiPrompt
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