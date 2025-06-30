################################################################################
<#
.SYNOPSIS
Gets the configured directories and default language for image files used in
GenXdev.AI operations.

.DESCRIPTION
This function retrieves the global image directories and default language used
by the GenXdev.AI module for various image processing and AI operations. It
returns the configuration from both global variables and the module's
preference storage, with fallback to system defaults.

.PARAMETER ImageDirectories
Optional default value to return if no image directories are configured. If not specified, returns the system default directories (Downloads, OneDrive, Pictures).

.PARAMETER ClearSession
When specified, clears the session image directories setting (Global variable) before retrieving the configuration.

.PARAMETER SkipSession
When specified, skips checking the session setting (Global variable) and retrieves only from persistent preferences.

.EXAMPLE
Get-AIImageCollection

Gets the currently configured image directories from Global variables or preferences.

.EXAMPLE
Get-AIImageCollection -SkipSession

Gets the configured image directories only from persistent preferences, ignoring any session setting.

.EXAMPLE
Get-AIImageCollection -ClearSession

Clears the session image directories setting and then gets the directories from persistent preferences.

.EXAMPLE
$config = Get-AIImageCollection -ImageDirectories @("C:\MyImages")

Returns configured directories or the specified default if none are configured.

.EXAMPLE
getimgdirs

Uses alias to get the current image directory configuration.
#>
function Get-AIImageCollection {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias("getimgdirs")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Default directories to return if none are configured"
        )]
        [AllowNull()]
        [string[]] $ImageDirectories,
        ###############################################################################
        # Use alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $SessionOnly,
        ###############################################################################
        # clear the session setting (Global variable) before retrieving
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear the session setting (Global variable) before retrieving"
        )]
        [switch] $ClearSession,
        ###############################################################################
        # Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {


        # handle clearing session variables first if requested
        if ($ClearSession) {
            $Global:ImageDirectories = $null
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Cleared session image directories setting: ImageDirectories"
            )
        }
    }

    process {

        if ($null -ne $ImageDirectories -and
            $ImageDirectories.Count -gt 0) {

            # use provided directories if available
            $result = $ImageDirectories
            return
        }

        # determine which image directories to use based on priority: Global variable first (unless skipped), then preferences (unless SessionOnly)

        # first check global variable for image directories (unless SkipSession is specified)
        if ((-not $SkipSession) -and ($Global:ImageDirectories -and $Global:ImageDirectories.Count -gt 0)) {

            # use global variable if available and not empty
            $result = $Global:ImageDirectories
        }
        elseif (-not $SessionOnly) {

            # fallback to preference storage
            $imageDirectoriesPreference = $null

            try {

                # retrieve image directories preference from genxdev data storage
                $json = GenXdev.Data\Get-GenXdevPreference `
                    -Name "ImageDirectories" `
                    -DefaultValue $null `
                    -ErrorAction SilentlyContinue

                if (-not [string]::IsNullOrEmpty($json)) {

                    # convert json preference to powershell object
                    $imageDirectoriesPreference = $json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                }
            }
            catch {

                # set to null if preference retrieval fails
                $imageDirectoriesPreference = $null
            }

            if ($null -ne $imageDirectoriesPreference -and
                $imageDirectoriesPreference.Count -gt 0) {

                # use preference value if available and not empty
                $result = $imageDirectoriesPreference
            }
            else {

                # fallback to default system directories
                $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"

                try {

                    # attempt to get known folder path for pictures directory
                    $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
                }
                catch {

                    # fallback to default if known folder retrieval fails
                    $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
                }

                # define default directories for image processing operations
                $result = @(
                    (GenXdev.FileSystem\Expand-Path '~\downloads'),
                    (GenXdev.FileSystem\Expand-Path '~\onedrive'),
                    $picturesPath
                )
            }
        }
        else {
            # SessionOnly is specified but no session variable found, use default directories
            $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"

            try {

                # attempt to get known folder path for pictures directory
                $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
            }
            catch {

                # fallback to default if known folder retrieval fails
                $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
            }

            # define default directories for image processing operations
            $result = @(
                (GenXdev.FileSystem\Expand-Path '~\downloads'),
                (GenXdev.FileSystem\Expand-Path '~\onedrive'),
                $picturesPath
            )
        }
    }

    end {

        # return the configured image directories and language
        $result |  Microsoft.PowerShell.Core\ForEach-Object {

            Microsoft.PowerShell.Utility\Write-Output (GenXdev.FileSystem\Expand-Path $_)
        } | Microsoft.PowerShell.Utility\Select-Object -Unique
    }
}
################################################################################
