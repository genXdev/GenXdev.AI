<#
.SYNOPSIS
Gets the configured directory for face image files used in GenXdev.AI operations.

.DESCRIPTION
This function retrieves the global face directory used by the GenXdev.AI module for various face recognition and AI operations. It checks Global variables first (unless SkipSession is specified), then falls back to persistent preferences, and finally uses system defaults.

.PARAMETER FacesDirectory
Optional faces directory override. If specified, this directory will be returned instead of retrieving from configuration.

.PARAMETER ClearSession
When specified, clears the session faces directory setting (Global variable) before retrieving the configuration.

.PARAMETER SkipSession
When specified, skips checking the session setting (Global variable) and retrieves only from persistent preferences.

.EXAMPLE
Get-AIKnownFacesRootpath

Gets the currently configured faces directory from Global variables or preferences.

.EXAMPLE
Get-AIKnownFacesRootpath -SkipSession

Gets the configured faces directory only from persistent preferences, ignoring any session setting.

.EXAMPLE
Get-AIKnownFacesRootpath -ClearSession

Clears the session faces directory setting and then gets the directory from persistent preferences.

.EXAMPLE
Get-AIKnownFacesRootpath "C:\MyFaces"

Returns the specified directory after expanding the path.
#>
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
    )
    begin
    {

        # handle clearing session variables first if requested
        if ($ClearSession) {
            $Global:FacesDirectory = $null
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Cleared session faces directory setting: FacesDirectory"
            )
        }

        # get configured faces directory from preference store
        $resolvedFacesDirectory = $null

        if (-not ([string]::IsNullOrWhiteSpace($FacesDirectory))) {

            $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path "$FacesDirectory\" -CreateDirectory
            return $resolvedFacesDirectory
        }

        # check global variable first (unless SkipSession is specified), then fall back to preferences (unless SessionOnly is specified)
        if ((-not $SkipSession) -and (-not ([string]::IsNullOrWhiteSpace($Global:FacesDirectory)))) {

            $resolvedFacesDirectory = $Global:FacesDirectory
        }
        elseif (-not $SessionOnly) {

            try {

                $resolvedFacesDirectory = GenXdev.Data\Get-GenXdevPreference `
                    -Name "FacesDirectory" `
                    -DefaultValue $null `
                    -ErrorAction SilentlyContinue
            }
            catch {

                $resolvedFacesDirectory = $null
            }

            # use configured directory or fallback to default
            if ([string]::IsNullOrWhiteSpace($resolvedFacesDirectory)) {

                # fallback to default directory
                $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev.AI\Get-AIImageCollection" `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
                $resolvedFacesDirectory = @(GenXdev.AI\Get-AIImageCollection @params)[0]

                if (-not $resolvedFacesDirectory) {
                    $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path `
                        -Path "~\Pictures\Faces\" `
                        -CreateDirectory
                }
            }
        }
        else {
            # SessionOnly is specified but no session variable found, use default
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-AIImageCollection" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
            $resolvedFacesDirectory = @(GenXdev.AI\Get-AIImageCollection @params)[0]

            if (-not $resolvedFacesDirectory) {
                $resolvedFacesDirectory = GenXdev.FileSystem\Expand-Path `
                    -Path "~\Pictures\Faces\" `
                    -CreateDirectory
            }
        }
    }

    end
    {
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using provided faces directory: $resolvedFacesDirectory"

        Microsoft.PowerShell.Utility\Write-Output (GenXdev.FileSystem\Expand-Path "$resolvedFacesDirectory\")
    }
}