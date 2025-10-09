<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Get-AIKnownFacesRootpath.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.300.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
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

    $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
        -BoundParameters $PSBoundParameters `
        -FunctionName 'GenXdev.Data\Get-GenXdevPreference'

    GenXdev.FileSystem\Expand-Path (GenXdev.Data\Get-GenXdevPreference @params `
            -Name 'AIKnownFacesRootpath' `
            -DefaultValue $FacesDirectory
    )
}
###############################################################################