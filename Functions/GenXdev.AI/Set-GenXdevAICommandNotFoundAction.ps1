<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : Set-GenXdevAICommandNotFoundAction.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.296.2025
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

        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Set-GenXdevAICommandNotFoundAction'

        # store reference to existing handler if it's not already our handler
        $script:originalHandler = $null
        $currentHandler = $ExecutionContext.InvokeCommand.CommandNotFoundAction

        # check if handler is already installed
        if ($null -ne $currentHandler) {

            $handlerString = $currentHandler.ToString()
            if ($handlerString.Contains('Do you want AI to figure out')) {

                Microsoft.PowerShell.Utility\Write-Verbose 'AI Command handler already installed - exiting'
                return
            }

            $script:originalHandler = $currentHandler
            Microsoft.PowerShell.Utility\Write-Verbose 'Stored original command handler for chaining'
        }
    }

    process {

        if (-not $PSCmdlet.ShouldProcess('Command not found handling',
                'Set AI assistance handler')) {
            return
        }

        try {
            # Add flag to prevent recursion
            $script:insideCommandHandler = $false

            Microsoft.PowerShell.Utility\Write-Verbose 'Configuring new CommandNotFoundAction handler'

            # define the command not found action handler
            $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
                param($CommandName, $CommandLookupEventArgs)

                # prevent recursion
                if ($script:insideCommandHandler) {

                    Microsoft.PowerShell.Utility\Write-Debug "Preventing recursive call for command: $CommandName"
                    return
                }

                $script:insideCommandHandler = $true

                $origPSDebugPreference = $PSDebugPreference
                $origErrorActionPreference = $ErrorActionPreference
                $origVerbosePreference = $VerbosePreference
                $origWarningPreference = $WarningPreference

                try {
                    # suppress unnecessary output during handler execution
                    $PSDebugPreference = 'continue'
                    $ErrorActionPreference = 'SilentlyContinue'
                    $VerbosePreference = 'SilentlyContinue'
                    $WarningPreference = 'SilentlyContinue'

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
                            Microsoft.PowerShell.Utility\Write-Debug "Original handler failed: $_"
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
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $CommandName -PathType Container) {

                    $CommandLookupEventArgs.CommandScriptBlock = {
                        Microsoft.PowerShell.Management\Set-Location -LiteralPath $CommandName
                        Microsoft.PowerShell.Management\Get-ChildItem
                    }.GetNewClosure()

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                # skip internal and get- commands
                if ($CommandLookupEventArgs.CommandOrigin -eq 'Internal' -or
                    $CommandName -like 'get-*') {
                    return
                }

                if ($CommandName -like '-' -or  $CommandName -like "cd -" -or $CommandName -like "Set-Location +") {

                    $CommandLookupEventArgs.CommandScriptBlock = {
                        Microsoft.PowerShell.Management\Set-Location "-"
                    }

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                if ($CommandName -like '+' -or  $CommandName -like "cd +" -or $CommandName -like "Set-Location -") {

                    $CommandLookupEventArgs.CommandScriptBlock = {

                        Microsoft.PowerShell.Management\Set-Location "+"
                    }

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                # configure AI assistance
                $CommandLookupEventArgs.CommandScriptBlock = {

                    $userChoice = $host.ui.PromptForChoice(
                        'Command not found',
                        'Do you want AI to figure out what you want?',
                        @('&Nah', '&Yes'),
                        0)

                    if ($userChoice -eq 0) { return }

                    GenXdev.Windows\Send-Key ($MyInvocation.line) -Escape

                    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow 'What did you want to do?'

                    [System.Console]::Write('> ')
                    $userIntent = [System.Console]::ReadLine()
                    Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green 'Ok, hold on a sec..'

                    # prepare AI hint
                    $aiPrompt = ('Generate a Powershell commandline that would ' +
                        'be what user might have meant, but what triggered the ' +
                        "`$ExecutionContext.InvokeCommand.CommandNotFoundAction " +
                        "with her prompt being: $userIntent")

                    GenXdev.AI\Invoke-AIPowershellCommand $aiPrompt
                }.GetNewClosure()

                $CommandLookupEventArgs.StopSearch = $true
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to set up command not found handler: $_"
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose 'Command not found handler configuration completed'
    }
}