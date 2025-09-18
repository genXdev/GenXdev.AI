<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Add-ImageDirectories.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.276.2025
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
Adds directories to the configured image directories for GenXdev.AI operations.

.DESCRIPTION
This function adds one or more directory paths to the existing image directories
configuration used by the GenXdev.AI module. It updates both the global variable
and the module's preference storage to persist the configuration across sessions.
Duplicate directories are automatically filtered out to prevent configuration
redundancy. Paths are expanded to handle relative paths and environment
variables automatically.

.PARAMETER ImageDirectories
An array of directory paths to add to the existing image directories
configuration. Paths can be relative or absolute and will be expanded
automatically. Duplicates are filtered out using case-insensitive comparison.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Add-ImageDirectories -ImageDirectories @("C:\NewPhotos", "D:\MoreImages")

Adds the specified directories to the existing image directories configuration
using full parameter names.

.EXAMPLE
addimgdir @("C:\Temp\Photos", "E:\Backup\Images")

Uses alias to add multiple directories to the configuration with positional
parameters.
#>
################################################################################
function Add-ImageDirectories {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    [Alias('addimgdir')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'Array of directory paths to add to image directories'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #
    )

    begin {
        try {
            # retrieve current image directories configuration
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Get-AIImageCollection' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            $currentConfig = GenXdev.AI\Get-AIImageCollection @params

            # initialize new collection to store all directories including existing ones
            $newDirectories = [System.Collections.Generic.List[string]]::new()

            # populate collection with existing directories to preserve them
            foreach ($dir in $currentConfig) {
                $newDirectories.Add($dir)
            }

            # output current configuration state for debugging purposes
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Current image directories: ' +
                "[$($currentConfig -join ', ')]"
            )
        } catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to retrieve current image directories: $_"
            return
        }
    }

    process {
        foreach ($directory in $ImageDirectories) {
            try {
                # expand path to resolve relative paths and environment variables
                $expandedPath = GenXdev.FileSystem\Expand-Path $directory
            } catch {
                Microsoft.PowerShell.Utility\Write-Error "Failed to expand path '$directory': $_"
                continue
            }
            # search for existing directory using case-insensitive comparison
            $existingDir = $newDirectories |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.ToLower() -eq $expandedPath.ToLower()
                }
            if (-not $existingDir) {
                $newDirectories.Add($expandedPath)
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Adding directory: $expandedPath"
                )
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Directory already exists: $expandedPath"
                )
            }
        }
    }

    end {

        # convert list collection to array for function call compatibility
        $finalDirectories = $newDirectories.ToArray()

        # request user confirmation before modifying configuration
        if ($PSCmdlet.ShouldProcess(
                'GenXdev.AI Module Configuration',
            ('Add directories to image directories: ' +
                "[$($ImageDirectories -join ', ')]")
            )) {

            # prepare parameters for set operation using identical parameter copying
            $setParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Set-AIImageCollection' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # update configuration using the dedicated setter function
            GenXdev.AI\Set-AIImageCollection `
                -ImageDirectories $finalDirectories `
                @setParams

            # display success confirmation to user with statistics
            Microsoft.PowerShell.Utility\Write-Host (
                "Added $($ImageDirectories.Count) directories to image " +
                'directories configuration. Total directories: ' +
                "$($finalDirectories.Count)"
            ) -ForegroundColor Green
        }
    }
}
################################################################################