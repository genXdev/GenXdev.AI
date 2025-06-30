################################################################################
<#
.SYNOPSIS
Removes directories from the configured image directories for GenXdev.AI operations.

.DESCRIPTION
This function removes one or more directory paths from the existing image directories
configuration used by the GenXdev.AI module. It updates both the global variable
and the module's preference storage to persist the configuration across sessions.
Supports wildcard patterns for flexible directory matching.

.PARAMETER ImageDirectories
An array of directory paths or wildcard patterns to remove from the existing
image directories configuration.

.PARAMETER Force
Forces removal without confirmation prompts.

.EXAMPLE
Remove-ImageDirectories -ImageDirectories @("C:\OldPhotos", "D:\TempImages")

Removes the specified directories from the image directories configuration.

.EXAMPLE
Remove-ImageDirectories "C:\Temp\*"

Removes all directories that match the wildcard pattern.

.EXAMPLE
removeimgdir @("C:\OldPhotos") -Force

Uses alias to forcibly remove a directory from the configuration without confirmation.
#>
function Remove-ImageDirectories {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    [Alias("removeimgdir")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Array of directory paths or patterns to remove from image directories"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces removal without confirmation prompts"
        )]
        [switch] $Force,
        ########################################################################
        # Use alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # get current configuration
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIImageCollection" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
        $currentConfig = GenXdev.AI\Get-AIImageCollection @params

        # initialize collection for remaining directories
        $remainingDirectories = [System.Collections.Generic.List[string]]::new()

        # add all existing directories to start
        foreach ($dir in $currentConfig) {

            $remainingDirectories.Add($dir)
        }

        # track directories that will be removed for reporting
        $removedDirectories = [System.Collections.Generic.List[string]]::new()

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Current image directories: [$($ImageDirectories -join ', ')]"
        )
    }

    process {

        # process each directory pattern to remove
        foreach ($directoryPattern in $ImageDirectories) {

            # expand the path to handle relative paths and environment variables
            $expandedPattern = GenXdev.FileSystem\Expand-Path $directoryPattern

            # find matching directories (support wildcards)
            $matchingDirectories = $remainingDirectories |
                Microsoft.PowerShell.Core\Where-Object {
                    $_ -like $expandedPattern
                }

            # remove matching directories
            foreach ($matchingDir in $matchingDirectories) {

                if ($remainingDirectories.Remove($matchingDir)) {

                    $removedDirectories.Add($matchingDir)
                    Microsoft.PowerShell.Utility\Write-Verbose "Marked for removal: $matchingDir"
                }
            }

            # if no matches found and no wildcards, try exact match (case-insensitive)
            if ($matchingDirectories.Count -eq 0 -and -not $expandedPattern.Contains('*') -and -not $expandedPattern.Contains('?')) {

                $exactMatch = $remainingDirectories |
                    Microsoft.PowerShell.Core\Where-Object {
                        $_.ToLower() -eq $expandedPattern.ToLower()
                    }

                if ($exactMatch) {

                    foreach ($match in $exactMatch) {

                        if ($remainingDirectories.Remove($match)) {

                            $removedDirectories.Add($match)
                            Microsoft.PowerShell.Utility\Write-Verbose "Marked for removal (exact match): $match"
                        }
                    }
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Warning "Directory not found in configuration: $expandedPattern"
                }
            }
        }
    }

    end {

        if ($removedDirectories.Count -eq 0) {

            Microsoft.PowerShell.Utility\Write-Host "No directories were found to remove." -ForegroundColor Yellow
            return
        }

        # convert to array for the Set-AIImageCollection call
        $finalDirectories = $remainingDirectories.ToArray()

        # determine if we should proceed based on Force parameter or ShouldProcess
        $shouldProceed = $Force -or $PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            "Remove directories from image directories: [$($removedDirectories -join ', ')]"
        )

        if ($shouldProceed) {

            # use Set-AIImageCollection to update the configuration
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Set-AIImageCollection" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
            GenXdev.AI\Set-AIImageCollection @params -ImageDirectories $finalDirectories

            # output confirmation
            Microsoft.PowerShell.Utility\Write-Host (
                "Removed $($removedDirectories.Count) directories from image directories configuration. " +
                "Remaining directories: $($finalDirectories.Count)"
            ) -ForegroundColor Green

            # list removed directories
            if ($removedDirectories.Count -gt 0) {

                Microsoft.PowerShell.Utility\Write-Host "Removed directories:" -ForegroundColor Cyan
                foreach ($removedDir in $removedDirectories) {

                    Microsoft.PowerShell.Utility\Write-Host "  - $removedDir" -ForegroundColor Gray
                }
            }
        }
    }
}
################################################################################
