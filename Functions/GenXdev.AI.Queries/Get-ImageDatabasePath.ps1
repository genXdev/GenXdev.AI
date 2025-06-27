################################################################################
<#!
.SYNOPSIS
Returns the path to the image database, initializing or rebuilding it if needed.

.DESCRIPTION
This function determines the correct path for the image database file, checks if
it exists and is up to date, and initializes or rebuilds it if required. It
supports options for language, embedding images, forcing index rebuilds, and
filtering images by directory or path patterns. The function returns the path to
the database file, or $null if initialization fails.

.PARAMETER DatabaseFilePath
The path to the image database file. If not specified, a default path is used.

.PARAMETER ImageDirectories
An array of directory paths to search for images.

.PARAMETER PathLike
An array of SQL LIKE patterns to filter images by path (e.g. '%\\2024\\%').

.PARAMETER Language
Language for descriptions and keywords.

.PARAMETER EmbedImages
Switch to embed images as base64 in the database.

.PARAMETER ForceIndexRebuild
Switch to force a rebuild of the image index database.

.PARAMETER NoFallback
Switch to disable fallback behavior.

.PARAMETER NeverRebuild
Switch to skip database initialization and rebuilding.

.EXAMPLE
Get-ImageDatabasePath -DatabaseFilePath "C:\\Temp\\mydb.db" -ImageDirectories "C:\\Images" -PathLike '%\\2024\\%' -Language 'en' -EmbedImages -ForceIndexRebuild

.EXAMPLE
Get-ImageDatabasePath
#>
function Get-ImageDatabasePath {

    [CmdletBinding()]
    [OutputType([string])]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The path to the image database file. If not specified, a default path is used."
        )]
        [string] $DatabaseFilePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of directory paths to search for images"
        )]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Array of directory path-like search strings to filter images by " +
                "path (SQL LIKE patterns, e.g. '%\\2024\\%')"
            )
        )]
        [string[]] $PathLike = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Language for descriptions and keywords."
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Embed images as base64."
        )]
        [switch] $EmbedImages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force rebuild of the image index database."
        )]
        [switch] $ForceIndexRebuild,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Switch to disable fallback behavior."
        )]
        [switch] $NoFallback,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Switch to skip database initialization and rebuilding."
        )]
        [switch] $NeverRebuild
        ###############################################################################
    )

    begin {

        # define required schema version constant
        $SCHEMA_VERSION = "1.0.0.3"
    }

    process {

        # check if DatabaseFilePath is null or whitespace and set default path
        if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            # expand the default database file path using environment variable
            $DatabaseFilePath = GenXdev.FileSystem\Expand-Path (
                "$($ENV:LOCALAPPDATA)\GenXdev.PowerShell\allimages.meta.db"
            ) -ErrorAction SilentlyContinue
        }
        else {

            # expand the provided database file path
            $DatabaseFilePath = GenXdev.FileSystem\Expand-Path (
                $DatabaseFilePath
            ) -ErrorAction SilentlyContinue
        }

        # if NeverRebuild is set, skip initialization and return the path
        if ($NeverRebuild) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Skipping database initialization due to NeverRebuild parameter."
            )
            return $DatabaseFilePath
        }

        # set needsInitialization to true if ForceIndexRebuild is set
        $needsInitialization = $ForceIndexRebuild

        # check if the database file exists; if not, initialization is required
        if (-not (Microsoft.PowerShell.Management\Test-Path $DatabaseFilePath)) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Database file not found, initialization required."
            )
            $needsInitialization = $true
        }

        # if initialization is not yet required, check schema version
        if (-not $needsInitialization) {

            try {
                # query the schema version from the database
                $versionResult = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath (
                    $DatabaseFilePath
                ) `
                -Queries "SELECT version FROM ImageSchemaVersion WHERE id = 1" `
                -ErrorAction SilentlyContinue

                # if version is missing or does not match, initialization is required
                if (($null -eq $versionResult) -or (
                    $versionResult.Version -ne $SCHEMA_VERSION)) {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Schema version mismatch: found '$currentVersion', required '" +
                        "$SCHEMA_VERSION'. Initialization required."
                    )
                    $needsInitialization = $true
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Schema version '$currentVersion' is compatible."
                    )
                }
            } catch {
                # if an error occurs, throw and set initialization required
                throw $_
                $needsInitialization = $true
            }
        }

        # if initialization is required, call Export-ImageDatabase
        if ($needsInitialization) {

            try {

                # copy parameter values for Export-ImageDatabase
                $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "Export-ImageDatabase" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
                )

                # call Export-ImageDatabase to initialize or rebuild the database
                $null = GenXdev.AI\Export-ImageDatabase @params

                return $DatabaseFilePath
            }
            catch {
                # if initialization fails, write error and return null
                Microsoft.PowerShell.Utility\Write-Error (
                    "Failed to initialize image database: $($_.Exception.Message)"
                )
                return $null
            }
        }

        return $DatabaseFilePath
    }

    end {
    }
}
################################################################################