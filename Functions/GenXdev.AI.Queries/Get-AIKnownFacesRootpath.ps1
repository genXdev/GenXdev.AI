###############################################################################
<#
.SYNOPSIS
Gets the configured directory for face image files used in GenXdev.AI
operations.

.DESCRIPTION
This function retrieves the global face directory used by the GenXdev.AI
module for various face recognition and AI operations. It checks Global
variables first (unless SkipSession is specified), then falls back to
persistent preferences, and finally uses system defaults.

.PARAMETER FacesDirectory
Optional faces directory override. If specified, this directory will be
returned instead of retrieving from configuration.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving

.PARAMETER PreferencesDatabasePath
Database path for preference data files

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc

.EXAMPLE
Get-AIKnownFacesRootpath

Gets the currently configured faces directory from Global variables or
preferences.

.EXAMPLE
Get-AIKnownFacesRootpath -SkipSession

Gets the configured faces directory only from persistent preferences, ignoring
any session setting.

.EXAMPLE
Get-AIKnownFacesRootpath -ClearSession

Clears the session faces directory setting and then gets the directory from
persistent preferences.

.EXAMPLE
Get-AIKnownFacesRootpath "C:\MyFaces"

Returns the specified directory after expanding the path.
#>
###############################################################################
function Get-AIKnownFacesRootpath {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Directory path for face image files'
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear the session setting (Global variable) before ' +
                'retrieving')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
    )

    if (-not [string]::IsNullOrWhiteSpace($FacesDirectory)) {
        return (GenXdev.FileSystem\Expand-Path $FacesDirectory)
    }

    # fallback to default system directories
    $defaultPicturesPath = GenXdev.FileSystem\Expand-Path '~\Pictures'

    try {

        # attempt to get known folder path for pictures directory
        $defaultPicturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
    }
    catch {

        # fallback to default if known folder retrieval fails
        $defaultPicturesPath = GenXdev.FileSystem\Expand-Path '~\Pictures'
    }

    $FacesDirectory = [string]::IsNullOrWhiteSpace($FacesDirectory) ? $defaultPicturesPath : (GenXdev.FileSystem\Expand-Path $FacesDirectory)

    $params = GenXdev.Helpers\Copy-IdenticalParamValues `
        -BoundParameters $PSBoundParameters `
        -FunctionName 'GenXdev.Data\Get-GenXdevPreference'

    GenXdev.FileSystem\Expand-Path (Get-GenXdevPreference @params `
            -Name 'AIKnownFacesRootpath' `
            -DefaultValue $FacesDirectory
    )
}
###############################################################################