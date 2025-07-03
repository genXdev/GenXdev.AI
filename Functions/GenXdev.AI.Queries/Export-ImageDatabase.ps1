###############################################################################
<#
.SYNOPSIS
Initializes and populates the SQLite database by discovering images directly.

.DESCRIPTION
Creates a SQLite database with optimized schema for fast image searching based on
metadata including keywords, people, objects, scenes, and descriptions. The function
always deletes any existing database file and creates a fresh one, discovers images
using Find-Image from specified directories or configured image directories, and
populates the database directly without requiring a metadata JSON file. Finally,
it creates indexes for optimal performance.

.PARAMETER InputObject
Accepts search results from a Find-Image call to regenerate the view.

.PARAMETER DatabaseFilePath
Path to the SQLite database file. If not specified, uses the default location
under Storage\allimages.meta.db.

.PARAMETER ImageDirectories
Array of directory paths to search for images. If not specified, uses the
configured image directories from Get-AIImageCollection.

.PARAMETER PathLike
Array of directory path-like search strings to filter images by path (SQL LIKE
patterns, e.g. '%\\2024\\%').

.PARAMETER Language
Language for descriptions and keywords.

.PARAMETER FacesDirectory
The directory containing face images organized by person folders. If not
specified, uses the configured faces directory preference.

.PARAMETER EmbedImages
Embed images as base64.

.PARAMETER ForceIndexRebuild
Force rebuild of the image index database.

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
Dont use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.EXAMPLE
Export-ImageDatabase -DatabaseFilePath "C:\Custom\Path\images.db" `
    -ImageDirectories @("C:\Photos", "D:\Images") -EmbedImages

.EXAMPLE
indexcachedimages
#>
###############################################################################
function Export-ImageDatabase {

    [CmdletBinding()]
    [Alias("indexcachedimages", "Inititalize-ImageDatabase", "Recreate-ImageIndex")]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = ("Accepts search results from a Find-Image " +
                "call to regenerate the view.")
        )]
        [System.Object[]] $InputObject,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ("The path to the image database file. If not " +
                "specified, a default path is used.")
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
            HelpMessage = ("The directory containing face images organized by " +
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
        [switch] $SkipSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("LM Studio window during " +
                "initialization")
        )]
        [switch]$ShowWindow
    )

    begin {

        # determine database file path if not provided
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-ImageDatabasePath" `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                    -ErrorAction SilentlyContinue
        )

        $DatabaseFilePath = GenXdev.AI\Get-ImageDatabasePath @params -NeverRebuild

        # retrieve configured image directories if not provided
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIImageCollection" `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                    -ErrorAction SilentlyContinue
            )

        $ImageDirectories = GenXdev.AI\Get-AIImageCollection @params

        # output that the image index database is being recreated
        Microsoft.PowerShell.Utility\Write-Host (
            "Recreating image index database`r`n" +
            "Path = $DatabaseFilePath`r`n" +
            "Image directories = $(($ImageDirectories -join ", "))`r`n"
        ) -ForegroundColor Cyan

        # output the directories being used for image discovery
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Directories:`r`n" +
            "$(($ImageDirectories | Microsoft.PowerShell.Utility\ConvertTo-Json))"
        )

        # output whether image embedding is enabled or disabled
        if ($EmbedImages) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Image embedding: ENABLED - Images will be stored as binary " +
                "data in database"
            )
        } else {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Image embedding: DISABLED - Only file paths will be stored"
            )
        }

        # define schema version constant
        $SCHEMA_VERSION = "1.0.0.3"

        # initialize info object for tracking found results
        $Info = @{
            FoundResults = $false
            TotalImages = 0
        }

        # verify database file path is not empty
        if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to retrieve database file path."
            )
            return
        }

        # attempt to shutdown existing sqlite connections
        try {

            [System.Data.SQLite.SQLiteConnection]::Shutdown()
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Failed to shutdown SQLite connection: $($_.Exception.Message)"
            )
        }

        # output which database file will be used
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using image database: $DatabaseFilePath"
        )

        # expand database path and ensure directory exists, remove existing file
        $DatabaseFilePath = GenXdev.FileSystem\Expand-Path (
            $DatabaseFilePath
        ) -CreateDirectory -DeleteExistingFile -ErrorAction SilentlyContinue

        # check if the database file exists after expansion and handle backup
        if ([IO.File]::Exists($DatabaseFilePath)) {

            # try to move the file to backup, swap if move fails
            if (-not (GenXdev.FileSystem\Move-ItemWithTracking $DatabaseFilePath $DatabaseBackupFilePath -Force)) {

                $tmp = $DatabaseFilePath
                $DatabaseFilePath = $DatabaseBackupFilePath
                $DatabaseBackupFilePath = $tmp
            }
            else {

                # move the database journal file as well if it exists
                $journalFilePath = "$DatabaseFilePath-journal"

                if ([IO.File]::Exists($journalFilePath)) {

                    # attempt to move journal file to backup location
                    if (-not (GenXdev.FileSystem\Move-ItemWithTracking $journalFilePath "$DatabaseBackupFilePath-journal" -Force)) {

                        Microsoft.PowerShell.Utility\Write-Warning (
                            "Failed to move journal file: $journalFilePath"
                        )

                        # move renamed file back if journal move failed
                        if (-not (GenXdev.FileSystem\Move-ItemWithTracking -Path $DatabaseBackupFilePath -Destination $DatabaseFilePath -Force -ErrorAction SilentlyContinue)) {

                            Microsoft.PowerShell.Utility\Write-Warning (
                                "Failed to restore original database file: " +
                                "$DatabaseFilePath"
                            )
                        } else {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Restored original database file: " +
                                "$DatabaseFilePath"
                            )
                        }

                        # swap the paths back
                        $tmp = $DatabaseFilePath
                        $DatabaseFilePath = $DatabaseBackupFilePath
                        $DatabaseBackupFilePath = $tmp
                    }
                }
            }
        }

        # output verbose information about database and metadata paths
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Database path: $DatabaseFilePath"
        )

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Metadata path: " +
            "$(($ImageDirectories | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10))"
        )

        # define table creation script for main images table
        $createImagesTable = @"
CREATE TABLE IF NOT EXISTS Images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    image_data BLOB,
    has_explicit_content BOOLEAN DEFAULT 0,
    has_nudity BOOLEAN DEFAULT 0,
    short_description TEXT,
    long_description TEXT,
    picture_type TEXT,
    overall_mood_of_image TEXT,
    style_type TEXT,
    description_keywords TEXT,
    people_count INTEGER DEFAULT 0,
    people_faces TEXT,
    people_json TEXT,
    objects_count INTEGER DEFAULT 0,
    objects_list TEXT,
    objects_json TEXT,
    object_counts TEXT,
    scene_label TEXT,
    scene_confidence REAL,
    scene_confidence_percentage REAL,
    scene_processed_at DATETIME,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
"@

        # create keywords lookup table for fast searching
        $createKeywordsTable = @"
CREATE TABLE IF NOT EXISTS ImageKeywords (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    keyword TEXT NOT NULL,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
"@

        # create people lookup table for face recognition data
        $createPeopleTable = @"
CREATE TABLE IF NOT EXISTS ImagePeople (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    person_name TEXT NOT NULL,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
"@

        # create objects lookup table for detected objects
        $createObjectsTable = @"
CREATE TABLE IF NOT EXISTS ImageObjects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    object_name TEXT NOT NULL,
    object_count INTEGER DEFAULT 1,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
"@

        # create scenes lookup table for scene detection data
        $createScenesTable = @"
CREATE TABLE IF NOT EXISTS ImageScenes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    scene_name TEXT NOT NULL,
    confidence REAL,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
"@

        # create schema version table for database versioning
        $createSchemaVersionTable = @"
CREATE TABLE IF NOT EXISTS ImageSchemaVersion (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    version TEXT NOT NULL
);
"@

        # create comprehensive indexes for super fast searching with no table scans
        $createIndexes = @"
-- ===================================================================
-- PRIMARY SINGLE-COLUMN INDEXES (Most frequently used filters)
-- ===================================================================

-- Path index for unique lookups and sorting (most common operation)
CREATE INDEX IF NOT EXISTS idx_images_path ON Images(path);

-- Content safety filters (very frequently used together)
CREATE INDEX IF NOT EXISTS idx_images_nudity ON Images(has_nudity);
CREATE INDEX IF NOT EXISTS idx_images_explicit ON Images(has_explicit_content);

-- Core categorical filters
CREATE INDEX IF NOT EXISTS idx_images_picture_type ON Images(picture_type);
CREATE INDEX IF NOT EXISTS idx_images_mood ON Images(overall_mood_of_image);
CREATE INDEX IF NOT EXISTS idx_images_style ON Images(style_type);
CREATE INDEX IF NOT EXISTS idx_images_scene_label ON Images(scene_label);

-- Add regular indexes for text search columns (for LIKE/GLOB)
CREATE INDEX IF NOT EXISTS idx_images_short_description ON Images(short_description);
CREATE INDEX IF NOT EXISTS idx_images_long_description ON Images(long_description);
CREATE INDEX IF NOT EXISTS idx_images_description_keywords ON Images(description_keywords);

-- Count filters for performance
CREATE INDEX IF NOT EXISTS idx_images_people_count ON Images(people_count);
CREATE INDEX IF NOT EXISTS idx_images_objects_count ON Images(objects_count);

-- ===================================================================
-- COMPOSITE INDEXES FOR COMMON FILTER COMBINATIONS
-- ===================================================================

-- Safety + Type combinations (very common search pattern)
CREATE INDEX IF NOT EXISTS idx_images_safety_type ON Images(has_nudity, has_explicit_content, picture_type);
CREATE INDEX IF NOT EXISTS idx_images_safety_mood ON Images(has_nudity, has_explicit_content, overall_mood_of_image);
CREATE INDEX IF NOT EXISTS idx_images_safety_style ON Images(has_nudity, has_explicit_content, style_type);

-- Type + Mood + Style combinations (aesthetic searches)
CREATE INDEX IF NOT EXISTS idx_images_aesthetic ON Images(picture_type, overall_mood_of_image, style_type);

-- Count-based composite indexes (for filtering by presence of people/objects)
CREATE INDEX IF NOT EXISTS idx_images_counts_safety ON Images(people_count, objects_count, has_nudity, has_explicit_content);

-- Scene confidence optimization
CREATE INDEX IF NOT EXISTS idx_images_scene_confidence ON Images(scene_label, scene_confidence);

-- ===================================================================
-- COVERING INDEXES TO AVOID TABLE LOOKUPS
-- ===================================================================

-- Covering index for basic search results (includes most commonly selected columns)
CREATE INDEX IF NOT EXISTS idx_images_covering_basic ON Images(
    path, has_nudity, has_explicit_content, picture_type, overall_mood_of_image,
    style_type, people_count, objects_count, scene_label, scene_confidence,
    short_description, long_description, description_keywords
);

-- ===================================================================
-- LOOKUP TABLE INDEXES FOR JOINS (Optimized FOR exact matches first)
-- ===================================================================

-- Keywords table optimization - exact matches first, then prefix matches
CREATE INDEX IF NOT EXISTS idx_keywords_exact ON ImageKeywords(keyword, image_id);
CREATE INDEX IF NOT EXISTS idx_keywords_prefix ON ImageKeywords(keyword COLLATE NOCASE, image_id);
CREATE INDEX IF NOT EXISTS idx_keywords_reverse ON ImageKeywords(image_id, keyword);

-- People table optimization - exact matches first, then prefix matches
CREATE INDEX IF NOT EXISTS idx_people_exact ON ImagePeople(person_name, image_id);
CREATE INDEX IF NOT EXISTS idx_people_prefix ON ImagePeople(person_name COLLATE NOCASE, image_id);
CREATE INDEX IF NOT EXISTS idx_people_reverse ON ImagePeople(image_id, person_name);

-- Objects table optimization - exact matches first, then prefix matches
CREATE INDEX IF NOT EXISTS idx_objects_exact ON ImageObjects(object_name, image_id, object_count);
CREATE INDEX IF NOT EXISTS idx_objects_prefix ON ImageObjects(object_name COLLATE NOCASE, image_id, object_count);
CREATE INDEX IF NOT EXISTS idx_objects_reverse ON ImageObjects(image_id, object_name, object_count);

-- Scenes table optimization - exact matches first, then prefix matches
CREATE INDEX IF NOT EXISTS idx_scenes_exact ON ImageScenes(scene_name, image_id, confidence);
CREATE INDEX IF NOT EXISTS idx_scenes_prefix ON ImageScenes(scene_name COLLATE NOCASE, image_id, confidence);
CREATE INDEX IF NOT EXISTS idx_scenes_reverse ON ImageScenes(image_id, scene_name, confidence);
CREATE INDEX IF NOT EXISTS idx_scenes_confidence ON ImageScenes(confidence, scene_name);

-- ===================================================================
-- PARTIAL INDEXES FOR SELECTIVE FILTERING (NO TABLE SCANS)
-- ===================================================================

-- Only index images with nudity (for faster nudity searches)
CREATE INDEX IF NOT EXISTS idx_images_has_nudity ON Images(path, picture_type, overall_mood_of_image)
    WHERE has_nudity = 1;

-- Only index images with explicit content
CREATE INDEX IF NOT EXISTS idx_images_has_explicit ON Images(path, picture_type, overall_mood_of_image)
    WHERE has_explicit_content = 1;

-- Only index family-safe images (no nudity, no explicit content)
CREATE INDEX IF NOT EXISTS idx_images_family_safe ON Images(path, picture_type, overall_mood_of_image, style_type)
    WHERE has_nudity = 0 AND has_explicit_content = 0;

-- Only index images with people (people_count > 0)
CREATE INDEX IF NOT EXISTS idx_images_with_people ON Images(path, people_count, picture_type)
    WHERE people_count > 0;

-- Only index images with objects (objects_count > 0)
CREATE INDEX IF NOT EXISTS idx_images_with_objects ON Images(path, objects_count, picture_type)
    WHERE objects_count > 0;

-- ===================================================================
-- PREFIX SEARCH OPTIMIZATION (AVOID LEADING WILDCARD TABLE SCANS)
-- ===================================================================

-- For efficient prefix searches without leading wildcards
CREATE INDEX IF NOT EXISTS idx_keywords_prefix_only ON ImageKeywords(
    CASE WHEN keyword GLOB '[A-Za-z]*' THEN substr(keyword, 1, 3) END,
    keyword, image_id
) WHERE keyword GLOB '[A-Za-z]*';

CREATE INDEX IF NOT EXISTS idx_people_prefix_only ON ImagePeople(
    CASE WHEN person_name GLOB '[A-Za-z]*' THEN substr(person_name, 1, 3) END,
    person_name, image_id
) WHERE person_name GLOB '[A-Za-z]*';

CREATE INDEX IF NOT EXISTS idx_objects_prefix_only ON ImageObjects(
    CASE WHEN object_name GLOB '[A-Za-z]*' THEN substr(object_name, 1, 3) END,
    object_name, image_id
) WHERE object_name GLOB '[A-Za-z]*';

CREATE INDEX IF NOT EXISTS idx_scenes_prefix_only ON ImageScenes(
    CASE WHEN scene_name GLOB '[A-Za-z]*' THEN substr(scene_name, 1, 3) END,
    scene_name, image_id
) WHERE scene_name GLOB '[A-Za-z]*';

-- ===================================================================
-- CASE-INSENSITIVE SEARCH OPTIMIZATION (COLLATION BASED)
-- ===================================================================

-- Main table case-insensitive searches using collation (more efficient than lower())
CREATE INDEX IF NOT EXISTS idx_images_type_nocase ON Images(picture_type COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_images_mood_nocase ON Images(overall_mood_of_image COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_images_style_nocase ON Images(style_type COLLATE NOCASE);
CREATE INDEX IF NOT EXISTS idx_images_scene_nocase ON Images(scene_label COLLATE NOCASE);

-- ===================================================================
-- SPECIALIZED INDEXES FOR COMPLEX QUERIES
-- ===================================================================

-- Multi-table join optimization with covering columns
CREATE INDEX IF NOT EXISTS idx_images_join_optimize ON Images(
    id, path, has_nudity, has_explicit_content, picture_type,
    overall_mood_of_image, style_type, people_count, objects_count
);

-- Range queries on confidence scores
CREATE INDEX IF NOT EXISTS idx_images_scene_confidence_range ON Images(scene_confidence, scene_label, path)
    WHERE scene_confidence > 0;
"@
    }

    process {

        # start stopwatch for timing the process
        $totalTime = [System.Diagnostics.Stopwatch]::StartNew()

        # always delete existing database file to ensure clean rebuild
        if (Microsoft.PowerShell.Management\Test-Path $DatabaseFilePath) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Deleting existing database file for clean rebuild..."
            )

            Microsoft.PowerShell.Management\Remove-Item $DatabaseFilePath -Force
        }

        # create new database using specialized function
        Microsoft.PowerShell.Utility\Write-Verbose "Creating new database..."

        GenXdev.Data\New-SQLiteDatabase -DatabaseFilePath $DatabaseFilePath

        # create tables without indexes initially for faster inserts
        Microsoft.PowerShell.Utility\Write-Verbose "Creating database tables..."

        $createTablesQueries = @(
            $createImagesTable,
            $createKeywordsTable,
            $createPeopleTable,
            $createObjectsTable,
            $createScenesTable,
            $createSchemaVersionTable
        )

        GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath `
            -Queries $createTablesQueries

        # get images using Find-Image for direct integration
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Discovering images using Find-Image..."
        )

        # create transaction for batch operations to improve performance
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Data\Get-SQLiteTransaction" `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                    -ErrorAction SilentlyContinue
            )

        $transaction = GenXdev.Data\Get-SQLiteTransaction @params

        # prepare image insertion query based on whether embedding is enabled
        $insertQuery = if ($EmbedImages) {

            "INSERT INTO Images (path, image_data, has_explicit_content, " +
            "has_nudity, short_description, long_description, picture_type, " +
            "overall_mood_of_image, style_type, description_keywords, " +
            "people_count, people_faces, people_json, objects_count, " +
            "objects_list, objects_json, object_counts, scene_label, " +
            "scene_confidence, scene_confidence_percentage, " +
            "scene_processed_at) VALUES (@path, @image_data, @explicit, " +
            "@nudity, @short_desc, @long_desc, @pic_type, @mood, @style, " +
            "@desc_keywords, @people_count, @people_faces, @people_json, " +
            "@objects_count, @objects_list, @objects_json, @object_counts, " +
            "@scene_label, @scene_confidence, @scene_conf_pct, " +
            "@scene_processed)"
        } else {

            "INSERT INTO Images (path, has_explicit_content, has_nudity, " +
            "short_description, long_description, picture_type, " +
            "overall_mood_of_image, style_type, description_keywords, " +
            "people_count, people_faces, people_json, objects_count, " +
            "objects_list, objects_json, object_counts, scene_label, " +
            "scene_confidence, scene_confidence_percentage, " +
            "scene_processed_at) VALUES (@path, @explicit, @nudity, " +
            "@short_desc, @long_desc, @pic_type, @mood, @style, " +
            "@desc_keywords, @people_count, @people_faces, @people_json, " +
            "@objects_count, @objects_list, @objects_json, @object_counts, " +
            "@scene_label, @scene_confidence, @scene_conf_pct, " +
            "@scene_processed)"
        }

        # define internal function to import images from various sources
        function ImportImages {
            param($Info)

            # set found results to true when images are found
            $Info.FoundResults = $true

            # copy identical parameter values for Find-Image function call
            $findImageParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Find-Image" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                        -ErrorAction SilentlyContinue
                )

            # set image directories for Find-Image from configured sources
            $imageCollectionParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-AIImageCollection" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                        -ErrorAction SilentlyContinue
                )

            $findImageParams.ImageDirectories = GenXdev.AI\Get-AIImageCollection @imageCollectionParams

            # prepare lookup table inserts using strongly typed collections
            [System.Collections.Generic.List[String]] $lookupQueries = [System.Collections.Generic.List[String]]::new()

            [System.Collections.Generic.List[System.Collections.Hashtable]] $lookupParams = [System.Collections.Generic.List[System.Collections.Hashtable]]::new()

            # define internal function to insert a single image into database
            function insertImage {
                param($image, $Info)

                process {

                    # clear previous lookup data for this image
                    $lookupQueries.Clear()
                    $lookupParams.Clear()
                    $Info.FoundResults = $true

                    try {

                        # convert image object to json and back for deep copy to prevent modification
                        $image = $image |
                            Microsoft.PowerShell.Utility\ConvertTo-Json -depth 20 |
                            Microsoft.PowerShell.Utility\ConvertFrom-Json

                        $Info.TotalImages++

                        # build parameters for main image record insert with null checks
                        $imageParams = @{
                            "path"            = $image.path
                            "explicit"        = if ($image.description -and $image.description.has_explicit_content) { 1 } else { 0 }
                            "nudity"          = if ($image.description -and $image.description.has_nudity) { 1 } else { 0 }
                            "short_desc"      = if ($image.description) { $image.description.short_description } else { "" }
                            "long_desc"       = if ($image.description) { $image.description.long_description } else { "" }
                            "pic_type"        = if ($image.description) { $image.description.picture_type } else { "" }
                            "mood"            = if ($image.description) { $image.description.overall_mood_of_image } else { "" }
                            "style"           = if ($image.description) { $image.description.style_type } else { "" }
                            "desc_keywords"   = if ($image.description -and $image.description.keywords) {
                                if ($image.description.keywords.Count -gt 0) {
                                    $image.description.keywords | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20
                                } else { "[]" }
                            } else { "[]" }
                            "people_count"    = if ($image.people) { $image.people.count } else { 0 }
                            "people_faces"    = if ($image.people -and $image.people.faces) {
                                if ($image.people.faces.Count -gt 0) {
                                    $image.people.faces | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20
                                } else { "[]" }
                            } else { "[]" }
                            "people_json"     = if ($image.people) { $image.people | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20 } else { '{}' }
                            "objects_count"   = if ($image.objects) { $image.objects.count } else { 0 }
                            "objects_list"    = if ($image.objects -and $image.objects.objects) {
                                if ($image.objects.objects.Count -gt 0) {
                                    $image.objects.objects | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20
                                } else { "[]" }
                            } else { "[]" }
                            "objects_json"    = if ($image.objects) { $image.objects | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20 } else { '{}' }
                            "object_counts"   = if ($image.objects -and $image.objects.object_counts) {
                                $image.objects.object_counts | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20
                            } else { "{}" }
                            "scene_label"     = if ($image.scenes) { $image.scenes.label } else { "" }
                            "scene_confidence" = if ($image.scenes) { $image.scenes.confidence } else { 0 }
                            "scene_conf_pct"   = if ($image.scenes) { $image.scenes.confidence_percentage } else { 0 }
                            "scene_processed"  = if ($image.scenes) { $image.scenes.processed_at } else { "" }
                        }

                        # add image data if embedding is enabled for binary storage
                        if ($EmbedImages) {

                            try {

                                # check if image file exists before reading binary data
                                if (Microsoft.PowerShell.Management\Test-Path $image.path -PathType Leaf) {

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Reading image data from: $($image.path)"
                                    )

                                    $imageBytes = [System.IO.File]::ReadAllBytes($image.path)
                                    $imageParams["image_data"] = $imageBytes

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Embedded $($imageBytes.Length) bytes for " +
                                        "image: $($image.path)"
                                    )
                                } else {

                                    Microsoft.PowerShell.Utility\Write-Warning (
                                        "Image file not found for embedding: " +
                                        "$($image.path)"
                                    )

                                    $imageParams["image_data"] = $null
                                }
                            } catch {

                                Microsoft.PowerShell.Utility\Write-Warning (
                                    "Failed to read image data for embedding: " +
                                    "$($image.path) - $($_.Exception.Message)"
                                )

                                $imageParams["image_data"] = $null
                            }
                        }

                        # execute the insert and get the new ID for foreign key references
                        $queries = @($insertQuery, "SELECT last_insert_rowid() AS newId;")

                        $result = GenXdev.Data\Invoke-SQLiteQuery -Transaction $transaction `
                            -Queries $queries -SqlParameters @($imageParams)

                        $imageId = $result |
                            Microsoft.PowerShell.Utility\Select-Object -ExpandProperty newId

                        # clear collections for reuse with this image
                        $lookupQueries.Clear()
                        $lookupParams.Clear()

                        # insert keywords if present for searchable metadata
                        if ($image.keywords -and $image.keywords.Count -gt 0) {

                            foreach ($keyword in $image.keywords) {

                                $lookupQueries.Add("INSERT INTO ImageKeywords " +
                                    "(image_id, keyword) VALUES (@image_id, @keyword)")

                                $lookupParams.Add(@{
                                    "image_id" = $imageId;
                                    "keyword" = $keyword
                                })
                            }
                        }

                        # insert people data by parsing faces string if needed
                        if ($image.people -and $image.people.faces -and $image.people.faces -ne "" -and $image.people.faces.Count -gt 0) {

                            # handle both array and comma-separated string formats
                            $people = if ($image.people.faces -is [array]) {
                                $image.people.faces
                            } else {
                                $image.people.faces -split ',' |
                                    Microsoft.PowerShell.Core\ForEach-Object { $_.Trim() } |
                                    Microsoft.PowerShell.Core\Where-Object { $_ -ne "" }
                            }

                            foreach ($person in $people) {

                                $lookupQueries.Add("INSERT INTO ImagePeople " +
                                    "(image_id, person_name) VALUES (@image_id, @person_name)")

                                $lookupParams.Add(@{
                                    "image_id" = $imageId;
                                    "person_name" = $person
                                })
                            }
                        }

                        # insert objects data by parsing objects string if needed
                        if ($image.objects -and $image.objects.objects -and $image.objects.objects -ne "" -and $image.objects.objects.Count -gt 0) {

                            # handle both array and comma-separated string formats
                            $objects = if ($image.objects.objects -is [array]) {
                                $image.objects.objects
                            } else {
                                $image.objects.objects -split ',' |
                                    Microsoft.PowerShell.Core\ForEach-Object { $_.Trim() } |
                                    Microsoft.PowerShell.Core\Where-Object { $_ -ne "" }
                            }

                            foreach ($obj in $objects) {

                                $lookupQueries.Add("INSERT INTO ImageObjects " +
                                    "(image_id, object_name) VALUES (@image_id, @object_name)")

                                $lookupParams.Add(@{
                                    "image_id" = $imageId;
                                    "object_name" = $obj
                                })
                            }
                        }

                        # insert scenes if present with confidence data
                        if ($image.scenes -and (-not [string]::IsNullOrWhiteSpace($image.scenes.label))) {

                            $lookupQueries.Add("INSERT INTO ImageScenes " +
                                "(image_id, scene_name, confidence) VALUES " +
                                "(@image_id, @scene_name, @confidence)")

                            $lookupParams.Add(@{
                                "image_id" = $imageId;
                                "scene_name" = $image.scenes.label;
                                "confidence" = $image.scenes.confidence
                            })
                        }

                        # execute all lookup inserts in a single batch for performance
                        if ($lookupQueries.Count -gt 0) {

                            GenXdev.Data\Invoke-SQLiteQuery -Transaction $transaction `
                                -Queries $lookupQueries -SqlParameters $lookupParams

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Inserted lookup data for image ID $imageId"
                            )
                        } else {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "No lookup data to insert for image ID $imageId"
                            )
                        }

                        # progress update every 100 images to track processing
                        if ($Info.TotalImages % 100 -eq 0) {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Processed $($Info.TotalImages) images..."
                            )
                        }

                        # output the image object if PassThru is enabled
                        if ($PassThru) {

                            $image |
                                Microsoft.PowerShell.Utility\Write-Output
                        }
                    }
                    catch {

                        Microsoft.PowerShell.Utility\Write-Warning (
                            "Failed to insert image data for $($image.path): " +
                            "$($_.Exception.Message)"
                        )
                    }
                }
            }

            # process input object if provided instead of discovering images
            if ($InputObject -and $InputObject.Count -gt 0) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing input object with $($InputObject.Count) images..."
                )

                $InputObject |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        $Info.FoundResults = $true
                        insertImage $PSItem $Info
                    }
            }
            else {

                # discover images using Find-Image and process each one
                GenXdev.AI\Find-Image @findImageParams |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        $Info.FoundResults = $true
                        insertImage $PSItem $Info
                    }
            }
        }

        try {

            try {

                # attempt to import images using current configuration
                ImportImages $Info

                # if no results found, update all image metadata and retry once
                if (-not $Info.FoundResults) {

                    $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev.AI\Update-AllImageMetaData" `
                        -DefaultValues (
                            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                                -ErrorAction SilentlyContinue
                        )

                    $null = GenXdev.AI\Update-AllImageMetaData @params

                    ImportImages $Info
                }

                # commit the transaction to save all changes
                $transaction.Commit()

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Transaction committed successfully with " +
                    "$($Info.TotalImages) images"
                )

            }
            catch {

                # rollback on error to maintain database integrity
                $transaction.Rollback()

                Microsoft.PowerShell.Utility\Write-Warning (
                    "Transaction rolled back due to error: " +
                    "$($_.Exception.Message)"
                )

                throw $_
            }

            # create indexes for optimal performance outside transaction
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Creating indexes for optimal performance..."
            )

            GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath `
                -Queries $createIndexes

            # run ANALYZE to update query optimizer statistics for best performance
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Running ANALYZE to optimize query planning..."
            )

            GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath `
                -Queries "ANALYZE;"

            # insert schema version for database versioning
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting schema version to $SCHEMA_VERSION..."
            )

            GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath `
                -Queries ("INSERT OR REPLACE INTO ImageSchemaVersion " +
                "(id, version) VALUES (1, @version)") `
                -SqlParameters @{ "version" = $SCHEMA_VERSION }


            # stop the stopwatch and output completion message with timing
            $totalTime.Stop()

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Image database initialization completed successfully with " +
                "$($Info.TotalImages) records in " +
                "$($totalTime.Elapsed.ToString('mm\:ss'))"
            )
        }
        finally {

            # always close the connection to prevent resource leaks
            if ($transaction -and $transaction.Connection) {
                $transaction.Connection.Close()
            }
        }

        # output image database stats if PassThru is not enabled
        if (-not $PassThru) {

            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-ImageDatabaseStats" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                        -ErrorAction SilentlyContinue
                )

            GenXdev.AI\Get-ImageDatabaseStats @params |
                Microsoft.PowerShell.Utility\Write-Output
        }
    }

    end {

    }
}
###############################################################################
