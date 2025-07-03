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
            HelpMessage = "Directory path for face image files"
        )]
        [string] $FacesDirectory,
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
            HelpMessage = ("Clear the session setting (Global variable) before " +
                          "retrieving")
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Dont use alternative settings stored in session for " +
                          "AI preferences like Language, Image collections, etc")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
    )
    begin {

        # handle clearing session variables first if requested
        if ($ClearSession) {

            $Global:FacesDirectory = $null
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Cleared session faces directory setting: FacesDirectory"
            )
        }

        # initialize resolved faces directory variable
        $resolvedFacesDirectory = $null

        # check if a faces directory parameter was provided directly
        if (-not ([string]::IsNullOrWhiteSpace($FacesDirectory))) {

            # expand the provided directory path and create it if needed
            $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path `
                "$FacesDirectory\" `
                -CreateDirectory
            return
        }

        # check global variable first unless SkipSession is specified
        if ((-not $SkipSession) -and
            (-not ([string]::IsNullOrWhiteSpace($Global:FacesDirectory)))) {

            $resolvedFacesDirectory = $Global:FacesDirectory
        }
        # fall back to preferences unless SessionOnly is specified
        elseif (-not $SessionOnly) {

            try {

                # attempt to retrieve faces directory from preferences
                $resolvedFacesDirectory = GenXdev.Data\Get-GenXdevPreference `
                    -PreferencesDatabasePath $PreferencesDatabasePath `
                    -Name "FacesDirectory" `
                    -DefaultValue $null `
                    -ErrorAction SilentlyContinue
            }
            catch {

                $resolvedFacesDirectory = $null
            }

            # check if we need to fall back to default directory
            if ([string]::IsNullOrWhiteSpace($resolvedFacesDirectory)) {

                # copy identical parameters for the image collection function call
                $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Get-AIImageCollection" `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # get the first image collection directory as fallback
                $resolvedFacesDirectory = @(GenXdev.AI\Get-AIImageCollection `
                    @params)[0]

                # use system default if no image collection is available
                if (-not $resolvedFacesDirectory) {

                    $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path `
                        -Path "~\Pictures\Faces\" `
                        -CreateDirectory
                }
            }
        }
        else {

            # sessionOnly is specified but no session variable found
            # copy identical parameters for the image collection function call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-AIImageCollection" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # get the first image collection directory as fallback
            $resolvedFacesDirectory = @(GenXdev.AI\Get-AIImageCollection `
                @params)[0]

            # use system default if no image collection is available
            if (-not $resolvedFacesDirectory) {

                $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path `
                    "~\Pictures\Faces\" `
                    -CreateDirectory
            }
        }
    }

    process {
    }

    end {

        # log verbose information about the resolved directory
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using provided faces directory: $resolvedFacesDirectory"

        # expand the final path and ensure it ends with a backslash
        Microsoft.PowerShell.Utility\Write-Output (
            GenXdev.FileSystem\Expand-Path "$resolvedFacesDirectory\"
        )
    }
}
###############################################################################