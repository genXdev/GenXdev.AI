        ###############################################################################
<#
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

.PARAMETER FacesDirectory
The directory containing face images organized by person folders. If not
specified, uses the configured faces directory preference.

.PARAMETER EmbedImages
Switch to embed images as base64 in the database.

.PARAMETER ForceIndexRebuild
Switch to force a rebuild of the image index database.

.PARAMETER NoFallback
Switch to disable fallback behavior.

.PARAMETER NeverRebuild
Switch to skip database initialization and rebuilding.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Get-ImageDatabasePath -DatabaseFilePath "C:\\Temp\\mydb.db" `
    -ImageDirectories "C:\\Images" `
    -PathLike '%\\2024\\%' `
    -Language 'English' `
    -EmbedImages `
    -ForceIndexRebuild

.EXAMPLE
Get-ImageDatabasePath
#>
function Get-ImageDatabasePath {

    [CmdletBinding()]
    [OutputType([string])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]

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
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
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
        [ValidateSet(
            "Afrikaans", "Akan", "Albanian", "Amharic", "Arabic", "Armenian",
            "Azerbaijani", "Basque", "Belarusian", "Bemba", "Bengali", "Bihari",
            "Bork, bork, bork!", "Bosnian", "Breton", "Bulgarian", "Cambodian",
            "Catalan", "Cherokee", "Chichewa", "Chinese (Simplified)",
            "Chinese (Traditional)", "Corsican", "Croatian", "Czech", "Danish",
            "Dutch", "Elmer Fudd", "English", "Esperanto", "Estonian", "Ewe",
            "Faroese", "Filipino", "Finnish", "French", "Frisian", "Ga",
            "Galician", "Georgian", "German", "Greek", "Guarani", "Gujarati",
            "Hacker", "Haitian Creole", "Hausa", "Hawaiian", "Hebrew", "Hindi",
            "Hungarian", "Icelandic", "Igbo", "Indonesian", "Interlingua",
            "Irish", "Italian", "Japanese", "Javanese", "Kannada", "Kazakh",
            "Kinyarwanda", "Kirundi", "Klingon", "Kongo", "Korean",
            "Krio (Sierra Leone)", "Kurdish", "Kurdish (Soranî)", "Kyrgyz",
            "Laothian", "Latin", "Latvian", "Lingala", "Lithuanian", "Lozi",
            "Luganda", "Luo", "Macedonian", "Malagasy", "Malay", "Malayalam",
            "Maltese", "Maori", "Marathi", "Mauritian Creole", "Moldavian",
            "Mongolian", "Montenegrin", "Nepali", "Nigerian Pidgin",
            "Northern Sotho", "Norwegian", "Norwegian (Nynorsk)", "Occitan",
            "Oriya", "Oromo", "Pashto", "Persian", "Pirate", "Polish",
            "Portuguese (Brazil)", "Portuguese (Portugal)", "Punjabi", "Quechua",
            "Romanian", "Romansh", "Runyakitara", "Russian", "Scots Gaelic",
            "Serbian", "Serbo-Croatian", "Sesotho", "Setswana",
            "Seychellois Creole", "Shona", "Sindhi", "Sinhalese", "Slovak",
            "Slovenian", "Somali", "Spanish", "Spanish (Latin American)",
            "Sundanese", "Swahili", "Swedish", "Tajik", "Tamil", "Tatar",
            "Telugu", "Thai", "Tigrinya", "Tonga", "Tshiluba", "Tumbuka",
            "Turkish", "Turkmen", "Twi", "Uighur", "Ukrainian", "Urdu", "Uzbek",
            "Vietnamese", "Welsh", "Wolof", "Xhosa", "Yiddish", "Yoruba", "Zulu"
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "The directory containing face images organized by " +
                "person folders. If not specified, uses the " +
                "configured faces directory preference.")
        )]
        [string] $FacesDirectory,
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
        [switch] $NeverRebuild,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Use alternative settings stored in session for AI preferences " +
                "like Language, Image collections, etc")
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                "Clear alternative settings stored in session for AI " +
                "preferences like Language, Image collections, etc")
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
            HelpMessage = (
                "Dont use alternative settings stored in session for AI " +
                "preferences like Language, Image collections, etc")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        # define required schema version constant
        $SCHEMA_VERSION = "1.0.0.3"

        # copy identical parameters for Get-AIMetaLanguage
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get the language setting for AI operations
        $Language = GenXdev.AI\Get-AIMetaLanguage @params
    }

    process {

        # check if DatabaseFilePath is null or whitespace and set from
        # preferences/session
        if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            # first check global variable for database path (unless SkipSession
            # is specified)
            if ((-not $SkipSession) -and `
                (-not [String]::IsNullOrWhiteSpace($Global:ImageDatabasePath))) {

                # use global variable if available
                $DatabaseFilePath = $Global:ImageDatabasePath

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using session image database path: $DatabaseFilePath"
                )
            }
            elseif (-not $SessionOnly) {

                # fallback to preference storage
                try {
                    # retrieve database path from preferences
                    $preferencePath = GenXdev.Data\Get-GenXdevPreference `
                        -PreferencesDatabasePath $PreferencesDatabasePath `
                        -Name "ImageDatabasePath" `
                        -DefaultValue $null `
                        -ErrorAction SilentlyContinue

                    # use preference path if found
                    if (-not [String]::IsNullOrWhiteSpace($preferencePath)) {

                        $DatabaseFilePath = $preferencePath

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Using preference image database path: " +
                            "$DatabaseFilePath"
                        )
                    }
                }
                catch {
                    # ignore preference retrieval errors and use default
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to retrieve database path preference, " +
                        "using default"
                    )
                }
            }

            # if still no path found, use default
            if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

                # expand the default database file path using environment variable
                $DatabaseFilePath = GenXdev.FileSystem\Expand-Path (
                    "$($ENV:LOCALAPPDATA)\GenXdev.PowerShell\allimages.meta.db"
                ) -ErrorAction SilentlyContinue

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using default image database path: $DatabaseFilePath"
                )
            }
        }

        # expand the database file path
        if (-not [String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

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
                $versionResult = GenXdev.Data\Invoke-SQLiteQuery `
                    -DatabaseFilePath $DatabaseFilePath `
                    -Queries "SELECT version FROM ImageSchemaVersion WHERE id = 1" `
                    -ErrorAction SilentlyContinue

                # if version is missing or does not match, initialization is
                # required
                if (($null -eq $versionResult) -or `
                    ($versionResult.Version -ne $SCHEMA_VERSION)) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Schema version mismatch: found '$currentVersion', " +
                        "required '$SCHEMA_VERSION'. Initialization required."
                    )

                    $needsInitialization = $true
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Schema version '$currentVersion' is compatible."
                    )
                }
            }
            catch {
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
                    -FunctionName "GenXdev.AI\Export-ImageDatabase" `
                    -DefaultValues (
                        Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local `
                            -ErrorAction SilentlyContinue
                    )

                # call Export-ImageDatabase to initialize or rebuild the database
                $null = GenXdev.AI\Export-ImageDatabase @params

                return $DatabaseFilePath
            }
            catch {
                # if initialization fails, write error and return null
                Microsoft.PowerShell.Utility\Write-Error (
                    "Failed to initialize image database: " +
                    "$($_.Exception.Message)"
                )

                return $null
            }
        }

        return $DatabaseFilePath
    }

    end {
    }
}
###############################################################################