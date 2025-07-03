###############################################################################
<#
.SYNOPSIS
Sets the directory for face image files used in GenXdev.AI operations.

.DESCRIPTION
This function configures the global face directory used by the GenXdev.AI
module for various face recognition and AI operations. Settings can be stored
persistently in preferences (default), only in the current session (using
-SessionOnly), or cleared from the session (using -ClearSession).

.PARAMETER FacesDirectory
A directory path where face image files are located. This directory
will be used by GenXdev.AI functions for face discovery and processing
operations.

.PARAMETER SessionOnly
When specified, stores the setting only in the current session (Global
variable) without persisting to preferences. Setting will be lost when the
session ends.

.PARAMETER ClearSession
When specified, clears only the session setting (Global variable) without
affecting persistent preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Set-AIKnownFacesRootpath -FacesDirectory "C:\Faces"

Sets the faces directory persistently in preferences.

.EXAMPLE
Set-AIKnownFacesRootpath "C:\FacePictures"

Sets the faces directory persistently in preferences.

.EXAMPLE
Set-AIKnownFacesRootpath -FacesDirectory "C:\TempFaces" -SessionOnly

Sets the faces directory only for the current session (Global variable).

.EXAMPLE
Set-AIKnownFacesRootpath -ClearSession

Clears the session faces directory setting (Global variable) without affecting
persistent preferences.
#>
###############################################################################
function Set-AIKnownFacesRootpath {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]

    param(
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Directory path for face image files"
        )]
        [string] $FacesDirectory,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                          "preferences like Language, Image collections, etc")
        )]
        [switch] $SessionOnly,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                          "preferences like Language, Image collections, etc")
        )]
        [switch] $ClearSession,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Dont use alternative settings stored in session for " +
                          "AI preferences like Language, Image collections, etc")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
    ###############################################################################
    )

    begin {

        # validate parameters - facesDirectory is required unless clearing session
        if ((-not $ClearSession) -and
            [string]::IsNullOrWhiteSpace($FacesDirectory)) {

            throw ("FacesDirectory parameter is required when not using " +
                  "-ClearSession")
        }

        # expand path only if not clearing session
        if (-not $ClearSession) {

            $FacesDirectory = GenXdev.FileSystem\Expand-Path "$FacesDirectory\" `
                        -CreateDirectory

            # display verbose information about the faces directory being
            # configured
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting faces directory for GenXdev.AI module: " +
                "[$FacesDirectory]"
            )
        }
    }

    process {

        # handle clearing session variables
        if ($ClearSession) {

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                "Clear session faces directory setting (Global variable)"
            )) {

                # clear the global variable
                $Global:FacesDirectory = $null

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Cleared session faces directory setting: FacesDirectory"
                )
            }
            return
        }

        # handle session-only storage
        if ($SessionOnly) {

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                "Set session-only faces directory to: [$FacesDirectory]"
            )) {

                # set global variable for session-only storage
                $Global:FacesDirectory = $FacesDirectory

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only faces directory: " +
                    "FacesDirectory = $FacesDirectory"
                )
            }
            return
        }

        # handle persistent storage (default behavior)
        # confirm the operation with the user before proceeding with changes
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            "Set faces directory to: [$FacesDirectory]"
        )) {

            # store the configuration in module preferences for persistence
            $null = GenXdev.Data\Set-GenXdevPreference `
                -PreferencesDatabasePath $PreferencesDatabasePath `
                -Name "FacesDirectory" `
                -Value $FacesDirectory

            # output confirmation message about successful configuration
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Successfully configured faces directory in GenXdev.AI module: " +
                "[$FacesDirectory]"
            )
        }
    }

    end {
    }
}
###############################################################################