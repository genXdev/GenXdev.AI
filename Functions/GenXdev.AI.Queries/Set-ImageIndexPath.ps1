<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Set-ImageIndexPath.ps1
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
Sets the default database file path for image operations in GenXdev.AI.

.DESCRIPTION
This function configures the default database file path used by GenXdev.AI
functions for image processing and AI operations. The path can be stored
persistently in preferences (default), only in the current session (using
-SessionOnly), or cleared from the session (using -ClearSession).

.PARAMETER DatabaseFilePath
The path to the image database file. The directory will be created if it
doesn't exist.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SessionOnly
When specified, stores the setting only in the current session (Global
variables) without persisting to preferences. Settings will be lost when the
session ends.

.PARAMETER ClearSession
When specified, clears only the session setting (Global variable) without
affecting persistent preferences.

.PARAMETER SkipSession
When specified, stores the setting only in persistent preferences without
affecting the current session setting.

.EXAMPLE
Set-ImageIndexPath -DatabaseFilePath "C:\MyProject\images.db"

Sets the image database path persistently in preferences.

.EXAMPLE
Set-ImageIndexPath "D:\Data\custom_images.db"

Sets the image database path persistently in preferences using positional
parameter.

.EXAMPLE
Set-ImageIndexPath -DatabaseFilePath "C:\Temp\temp_images.db" -SessionOnly

Sets the image database path only for the current session (Global variables).

.EXAMPLE
Set-ImageIndexPath -ClearSession

Clears the session image database path setting (Global variable) without
affecting persistent preferences.
#>
################################################################################
function Set-ImageIndexPath {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments',
        ''
    )]

    param(
        ########################################################################
        # specifies the path to the image database file
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The path to the image database file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('dbpath', 'database')]
        [string] $DatabaseFilePath,
        ########################################################################
        # specify database path for preference data files
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        # use alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for AI preferences'
        )]
        [switch] $SessionOnly,
        ########################################################################
        # clear alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear alternative settings stored in session for AI preferences'
        )]
        [switch] $ClearSession,
        ########################################################################
        # store setting only in persistent preferences without affecting session
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Store setting only in persistent preferences without affecting session'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # validate parameters - DatabaseFilePath is required unless clearing
        if ((-not $ClearSession) -and
            ([String]::IsNullOrWhiteSpace($DatabaseFilePath))) {

            throw ('DatabaseFilePath parameter is required when not using ' +
                '-ClearSession')
        }

        # expand and validate the database file path if provided
        if (-not $ClearSession -and
            -not [String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            try {
                # expand the database file path to full path
                $DatabaseFilePath = GenXdev.FileSystem\Expand-Path `
                    $DatabaseFilePath `
                    -ErrorAction Stop

            }
            catch {
                throw ('Failed to expand database file path ' +
                    "'$DatabaseFilePath': $($_.Exception.Message)")
            }

            # get parent directory for validation
            $parentDir = Microsoft.PowerShell.Management\Split-Path `
                $DatabaseFilePath `
                -Parent

            # validate that the parent directory exists or can be created
            if (-not [String]::IsNullOrWhiteSpace($parentDir) -and
                -not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $parentDir)) {

                try {
                    # create parent directory if it doesn't exist
                    $null = Microsoft.PowerShell.Management\New-Item `
                        -Path $parentDir `
                        -ItemType Directory `
                        -Force `
                        -ErrorAction Stop

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Created parent directory: $parentDir"
                    )
                }
                catch {
                    throw ('Failed to create parent directory ' +
                        "'$parentDir': $($_.Exception.Message)")
                }
            }
        }
    }

    process {

        # handle clearing session variables
        if ($ClearSession) {

            # prepare confirmation message for clearing session
            $clearMessage = ('Clear session image database path setting ' +
                '(Global variable)')

            # confirm the operation with the user before proceeding
            if ($PSCmdlet.ShouldProcess(
                    'GenXdev.AI Module Configuration',
                    $clearMessage
                )) {

                # clear the global variable
                $Global:ImageIndexPath = $null

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Cleared session setting: ImageIndexPath'
                )
            }
            return
        }

        # handle session-only storage
        if ($SessionOnly) {

            # prepare confirmation message for session-only storage
            $sessionMessage = ('Set session-only image database path to: ' +
                "$DatabaseFilePath")

            # confirm the operation with the user before proceeding
            if ($PSCmdlet.ShouldProcess(
                    'GenXdev.AI Module Configuration',
                    $sessionMessage
                )) {

                # set global variable for session-only storage
                $Global:ImageIndexPath = $DatabaseFilePath

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only image database path: $DatabaseFilePath"
                )
            }
            return
        }

        # handle persistent storage (default behavior)
        # prepare confirmation message for persistent storage
        $persistentMessage = "Set image database path to: $DatabaseFilePath"

        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess(
                'GenXdev.AI Module Configuration',
                $persistentMessage
            )) {

            # output verbose message about setting database path
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting ImageIndexPath preference to: $DatabaseFilePath"
            )

            # store the configuration in module preferences for persistence
            $null = GenXdev.Data\Set-GenXdevPreference `
                -PreferencesDatabasePath $PreferencesDatabasePath `
                -Name 'ImageIndexPath' `
                -Value $DatabaseFilePath
        }
    }

    end {
    }
}
################################################################################