################################################################################
<#
.SYNOPSIS
Sets the default database file path for image operations in GenXdev.AI.

.DESCRIPTION
This function configures the default database file path used by GenXdev.AI functions
for image processing and AI operations. The path can be stored persistently in
preferences (default), only in the current session (using -SessionOnly), or cleared
from the session (using -ClearSession).

.PARAMETER DatabaseFilePath
The path to the image database file. The directory will be created if it doesn't exist.

.PARAMETER SessionOnly
When specified, stores the setting only in the current session (Global variables)
without persisting to preferences. Settings will be lost when the session ends.

.PARAMETER ClearSession
When specified, clears only the session setting (Global variable) without affecting
persistent preferences.

.PARAMETER SkipSession
When specified, stores the setting only in persistent preferences without affecting
the current session setting.

.EXAMPLE
Set-ImageDatabasePath -DatabaseFilePath "C:\MyProject\images.db"

Sets the image database path persistently in preferences.

.EXAMPLE
Set-ImageDatabasePath "D:\Data\custom_images.db"

Sets the image database path persistently in preferences using positional parameter.

.EXAMPLE
Set-ImageDatabasePath -DatabaseFilePath "C:\Temp\temp_images.db" -SessionOnly

Sets the image database path only for the current session (Global variables).

.EXAMPLE
Set-ImageDatabasePath -ClearSession

Clears the session image database path setting (Global variable) without affecting
persistent preferences.
#>
function Set-ImageDatabasePath {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
        # specifies the path to the image database file
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The path to the image database file"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("dbpath", "database")]
        [string] $DatabaseFilePath,
        ###############################################################################
        # Use alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences"
        )]
        [switch] $SessionOnly,
        ###############################################################################
        # Clear alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences"
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Store setting only in persistent preferences without affecting session"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # validate parameters - DatabaseFilePath is required unless clearing session
        if ((-not $ClearSession) -and ([String]::IsNullOrWhiteSpace($DatabaseFilePath))) {
            throw "DatabaseFilePath parameter is required when not using -ClearSession"
        }

        # expand and validate the database file path if provided
        if (-not $ClearSession -and -not [String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            try {
                $DatabaseFilePath = GenXdev.FileSystem\Expand-Path $DatabaseFilePath -ErrorAction Stop
            }
            catch {
                throw "Failed to expand database file path '$DatabaseFilePath': $($_.Exception.Message)"
            }

            # validate that the parent directory exists or can be created
            $parentDir = Microsoft.PowerShell.Management\Split-Path $DatabaseFilePath -Parent
            if (-not [String]::IsNullOrWhiteSpace($parentDir) -and
                -not (Microsoft.PowerShell.Management\Test-Path $parentDir)) {

                try {
                    $null = Microsoft.PowerShell.Management\New-Item -Path $parentDir -ItemType Directory -Force -ErrorAction Stop
                    Microsoft.PowerShell.Utility\Write-Verbose "Created parent directory: $parentDir"
                }
                catch {
                    throw "Failed to create parent directory '$parentDir': $($_.Exception.Message)"
                }
            }
        }
    }

    process {

        # handle clearing session variables
        if ($ClearSession) {

            $clearMessage = "Clear session image database path setting (Global variable)"

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                $clearMessage
            )) {

                # clear the global variable
                $Global:ImageDatabasePath = $null

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Cleared session setting: ImageDatabasePath"
                )
            }
            return
        }

        # handle session-only storage
        if ($SessionOnly) {

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                "Set session-only image database path to: $DatabaseFilePath"
            )) {

                # set global variable for session-only storage
                $Global:ImageDatabasePath = $DatabaseFilePath

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only image database path: $DatabaseFilePath"
                )
            }
            return
        }

        # handle persistent storage (default behavior)
        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            "Set image database path to: $DatabaseFilePath"
        )) {

            # output verbose message about setting database path
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting ImageDatabasePath preference to: $DatabaseFilePath"
            )

            # store the configuration in module preferences for persistence
            $null = GenXdev.Data\Set-GenXdevPreference `
                -Name "ImageDatabasePath" `
                -Value $DatabaseFilePath

            # also set the session variable unless SkipSession is specified
            if (-not $SkipSession) {
                $Global:ImageDatabasePath = $DatabaseFilePath
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session image database path: $DatabaseFilePath"
                )
            }
        }
    }

    end {
    }
}
################################################################################
