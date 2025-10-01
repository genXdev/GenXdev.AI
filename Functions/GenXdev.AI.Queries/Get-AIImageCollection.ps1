<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Get-AIImageCollection.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.290.2025
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
Gets the configured directories for image files used in GenXdev.AI operations.

.DESCRIPTION
This function retrieves the global image directories used by the GenXdev.AI
module for various image processing and AI operations. It returns the
configuration from both global variables and the module's preference storage,
with fallback to system defaults.

The function follows a priority order: first checks global variables (unless
SkipSession is specified), then falls back to persistent preferences (unless
SessionOnly is specified), and finally uses system default directories.

.PARAMETER ImageDirectories
Optional default value to return if no image directories are configured. If
not specified, returns the system default directories (Downloads, OneDrive,
Pictures).

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Get-AIImageCollection

Gets the currently configured image directories from Global variables or
preferences.

.EXAMPLE
Get-AIImageCollection -SkipSession

Gets the configured image directories only from persistent preferences,
ignoring any session setting.

.EXAMPLE
Get-AIImageCollection -ClearSession

Clears the session image directories setting and then gets the directories
from persistent preferences.

.EXAMPLE
$config = Get-AIImageCollection -ImageDirectories @("C:\MyImages")

Returns configured directories or the specified default if none are configured.

.EXAMPLE
getimgdirs

Uses alias to get the current image directory configuration.
#>
################################################################################
function Get-AIImageCollection {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('getimgdirs')]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Default directories to return if none are configured'
        )]
        [AllowNull()]
        [string[]] $ImageDirectories,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear the session setting (Global variable) ' +
                'before retrieving')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        $result = $null

        # handle clearing session variables first if requested
        if ($ClearSession) {

            # clear the global image directories variable
            $Global:ImageDirectories = $null

            # output verbose message about clearing session setting
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Cleared session image directories setting: ImageDirectories'
            )
        }
    }

    process {

        # check if user provided specific directories to use as default
        if ($null -ne $ImageDirectories -and
            ($ImageDirectories.Count -gt 0)) {

            # use provided directories if available
            $result = $ImageDirectories
            return
        }

        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Data\Get-GenXdevPreference'

        # fallback to default system directories
        $picturesPath = GenXdev.FileSystem\Expand-Path '~\Pictures'

        try {

            # attempt to get known folder path for pictures directory
            $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
        }
        catch {

            # fallback to default if known folder retrieval fails
            $picturesPath = GenXdev.FileSystem\Expand-Path '~\Pictures'
        }

        # fallback to default system directories
        $desktopPath = GenXdev.FileSystem\Expand-Path '~\Desktop'

        try {

            # attempt to get known folder path for desktop directory
            $desktopPath = GenXdev.Windows\Get-KnownFolderPath Desktop
        }
        catch {

            # fallback to default if known folder retrieval fails
            $desktopPath = GenXdev.FileSystem\Expand-Path '~\Desktop'
        }

        # fallback to default system directories
        $documentsPath = GenXdev.FileSystem\Expand-Path '~\Documents'

        try {

            # attempt to get known folder path for documents directory
            $documentsPath = GenXdev.Windows\Get-KnownFolderPath Documents
        }
        catch {

            # fallback to default if known folder retrieval fails
            $documentsPath = GenXdev.FileSystem\Expand-Path '~\Documents'
        }

        # define default directories for image processing operations
        $DefaultValue = @(
            (GenXdev.FileSystem\Expand-Path '~\downloads'),
            (GenXdev.FileSystem\Expand-Path '~\onedrive'),
            $picturesPath,
            $desktopPath,
            $documentsPath
        ) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

        try {
            $result = GenXdev.Data\Get-GenXdevPreference @params `
                -Name 'AIImageCollection' `
                -DefaultValue $DefaultValue | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue
        }
        catch {
            $result = @()
        }
    }

    end {

        # return the configured image directories with expanded paths
        $result |
            Microsoft.PowerShell.Core\ForEach-Object {

                # expand each path and output it
                Microsoft.PowerShell.Utility\Write-Output (
                    GenXdev.FileSystem\Expand-Path $_
                )
            } |
            Microsoft.PowerShell.Utility\Select-Object -Unique
    }
}
################################################################################