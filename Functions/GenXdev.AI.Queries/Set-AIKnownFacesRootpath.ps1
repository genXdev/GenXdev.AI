<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Set-AIKnownFacesRootpath.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.278.2025
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
            HelpMessage = 'Directory path for face image files'
        )]
        [string] $FacesDirectory,
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
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )
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

    $params = GenXdev.Helpers\Copy-IdenticalParamValues `
        -BoundParameters $PSBoundParameters `
        -FunctionName 'GenXdev.Data\Set-GenXdevPreference'

    $null = GenXdev.Data\Set-GenXdevPreference @params `
        -Name 'AIKnownFacesRootpath' `
        -Value "$((GenXdev.FileSystem\Expand-Path ([string]::IsNullOrWhiteSpace($FacesPath) ? "$picturesPath\Faces\" : $FacesPath) -CreateDirectory))"
}
###############################################################################