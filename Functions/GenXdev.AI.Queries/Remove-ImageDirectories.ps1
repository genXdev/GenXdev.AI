<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Remove-ImageDirectories.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.298.2025
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
################################################################################
<#
.SYNOPSIS
Removes directories from the configured image directories for GenXdev.AI operations.

.DESCRIPTION
This function removes one or more directory paths from the existing image
directories configuration used by the GenXdev.AI module. It updates both the
global variable and the module's preference storage to persist the configuration
across sessions. Supports wildcard patterns for flexible directory matching.

.PARAMETER ImageDirectories
An array of directory paths or wildcard patterns to remove from the existing
image directories configuration.

.PARAMETER Force
Forces removal without confirmation prompts.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.EXAMPLE
Remove-ImageDirectories -ImageDirectories @("C:\OldPhotos", "D:\TempImages")

Removes the specified directories from the image directories configuration.

.EXAMPLE
Remove-ImageDirectories "C:\Temp\*"

Removes all directories that match the wildcard pattern.

.EXAMPLE
removeimgdir @("C:\OldPhotos") -Force

Uses alias to forcibly remove a directory from the configuration without
confirmation.
#>
################################################################################
function Remove-ImageDirectories {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('removeimgdir')]

    param(
        #
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'Array of directory paths or patterns to remove from image directories'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Forces removal without confirmation prompts'
        )]
        [switch] $Force,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for AI preferences like Language, Image collections, etc'
        )]
        [switch] $SessionOnly,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear alternative settings stored in session for AI preferences like Language, Image collections, etc'
        )]
        [switch] $ClearSession,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #
    )

    begin {

        # get current configuration using helper function to copy identical parameters
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIImageCollection' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # retrieve the current image collection configuration
        $currentConfig = GenXdev.AI\Get-AIImageCollection @params

        # initialize collection for tracking directories that will remain
        $remainingDirectories = [System.Collections.Generic.List[string]]::new()

        # populate the remaining directories list with current configuration
        foreach ($dir in $currentConfig) {

            $null = $remainingDirectories.Add($dir)
        }

        # initialize collection for tracking directories that get removed
        $removedDirectories = [System.Collections.Generic.List[string]]::new()

        # output verbose information about the directories to be processed
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Current image directories: [$($ImageDirectories -join ', ')]"
        )
    }

    process {

        # iterate through each directory pattern provided for removal
        foreach ($directoryPattern in $ImageDirectories) {

            # expand the path to resolve relative paths and environment variables
            $expandedPattern = GenXdev.FileSystem\Expand-Path $directoryPattern

            # find directories that match the pattern using wildcard support
            $matchingDirectories = $remainingDirectories |
                Microsoft.PowerShell.Core\Where-Object {
                    $_ -like $expandedPattern
                }

            # remove each matching directory from the remaining collection
            foreach ($matchingDir in $matchingDirectories) {

                # attempt to remove the directory and track successful removals
                if ($remainingDirectories.Remove($matchingDir)) {

                    $null = $removedDirectories.Add($matchingDir)

                    # output verbose information about the removal
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Marked for removal: $matchingDir"
                    )
                }
            }

            # handle exact matches when no wildcards are used and no pattern matches found
            if ($matchingDirectories.Count -eq 0 -and
                -not $expandedPattern.Contains('*') -and
                -not $expandedPattern.Contains('?')) {

                # perform case-insensitive exact match search
                $exactMatch = $remainingDirectories |
                    Microsoft.PowerShell.Core\Where-Object {
                        $_.ToLower() -eq $expandedPattern.ToLower()
                    }

                # process exact matches if found
                if ($exactMatch) {

                    foreach ($match in $exactMatch) {

                        # attempt to remove the exact match and track removal
                        if ($remainingDirectories.Remove($match)) {

                            $null = $removedDirectories.Add($match)

                            # output verbose information about exact match removal
                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Marked for removal (exact match): $match"
                            )
                        }
                    }
                }
                else {

                    # warn user when directory is not found in configuration
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Directory not found in configuration: $expandedPattern"
                    )
                }
            }
        }
    }

    end {

        # check if any directories were actually marked for removal
        if ($removedDirectories.Count -eq 0) {

            # inform user that no directories were found to remove
            Microsoft.PowerShell.Utility\Write-Host (
                'No directories were found to remove.'
            ) -ForegroundColor Yellow

            return
        }

        # convert the remaining directories list to array for function call
        $finalDirectories = $remainingDirectories.ToArray()

        # determine if removal should proceed based on force flag or user confirmation
        $shouldProceed = $Force -or $PSCmdlet.ShouldProcess(
            'GenXdev.AI Module Configuration',
            ('Remove directories from image directories: ' +
            "[$($removedDirectories -join ', ')]")
        )

        # proceed with the removal if confirmed or forced
        if ($shouldProceed) {

            # prepare parameters for the set operation using helper function
            $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Set-AIImageCollection' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # update the image collection with the remaining directories
            GenXdev.AI\Set-AIImageCollection @params `
                -ImageDirectories $finalDirectories

            # output confirmation message with summary statistics
            Microsoft.PowerShell.Utility\Write-Host (
                ("Removed $($removedDirectories.Count) directories from image " +
                'directories configuration. ' +
                "Remaining directories: $($finalDirectories.Count)")
            ) -ForegroundColor Green

            # display list of removed directories if any were removed
            if ($removedDirectories.Count -gt 0) {

                # display header for removed directories list
                Microsoft.PowerShell.Utility\Write-Host (
                    'Removed directories:'
                ) -ForegroundColor Cyan

                # iterate through and display each removed directory
                foreach ($removedDir in $removedDirectories) {

                    Microsoft.PowerShell.Utility\Write-Host (
                        "  - $removedDir"
                    ) -ForegroundColor Gray
                }
            }
        }
    }
}
################################################################################