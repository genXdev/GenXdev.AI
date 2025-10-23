<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Export-ImageIndex.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
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
Initializes and populates the SQLite database by discovering images directly.

.DESCRIPTION
Creates a SQLite database with optimized schema for fast image searching based on
metadata including keywords, people, objects, scenes, and descriptions. The
function always deletes any existing database file and creates a fresh one,
discovers images using Find-Image from specified directories or configured image
directories, and populates the database directly without requiring a metadata
JSON file. Finally, it creates indexes for optimal performance.

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
Embed images as base64 binary data in the database.

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
Don't use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.PARAMETER FullScreen
Open in fullscreen mode.

.PARAMETER ShowWindow
Show LM Studio window during initialization.

.PARAMETER Any
Will match any of all the possible meta data types.

.PARAMETER All
Search all directories even when limited results would normally be returned.

.PARAMETER AllDrives
Search all drives for images.

.PARAMETER NoRecurse
Do not search subdirectories recursively.

.PARAMETER Keywords
The keywords to look for, wildcards allowed.

.PARAMETER People
People to look for, wildcards allowed.

.PARAMETER Objects
Objects to look for, wildcards allowed.

.PARAMETER Scenes
Scenes to look for, wildcards allowed.

.PARAMETER Description
Description text to search for, wildcards allowed.

.PARAMETER DescriptionSearch
The description text to look for, wildcards allowed.

.PARAMETER PictureType
Picture types to filter by, wildcards allowed.

.PARAMETER StyleType
Style types to filter by, wildcards allowed.

.PARAMETER OverallMood
Overall moods to filter by, wildcards allowed.

.PARAMETER HasNudity
Filter images that contain nudity.

.PARAMETER NoNudity
Filter images that do NOT contain nudity.

.PARAMETER HasExplicitContent
Filter images that contain explicit content.

.PARAMETER NoExplicitContent
Filter images that do NOT contain explicit content.

.PARAMETER MetaCameraMake
Filter by camera make from EXIF metadata.

.PARAMETER MetaCameraModel
Filter by camera model from EXIF metadata.

.PARAMETER MetaWidth
Filter by image width range.

.PARAMETER MetaHeight
Filter by image height range.

.PARAMETER MetaGPSLatitude
Filter by GPS latitude coordinates.

.PARAMETER MetaGPSLongitude
Filter by GPS longitude coordinates.

.PARAMETER MetaGPSAltitude
Filter by GPS altitude.

.PARAMETER MetaExposureTime
Filter by exposure time range.

.PARAMETER MetaFNumber
Filter by f-number range.

.PARAMETER MetaISO
Filter by ISO speed range.

.PARAMETER MetaFocalLength
Filter by focal length range.

.PARAMETER MetaDateTaken
Filter by date taken.

.PARAMETER GeoLocation
GPS coordinates for location-based searching.

.PARAMETER GeoDistanceInMeters
Distance in meters for location-based searching.

.PARAMETER Force
Force processing even if metadata already exists.

.PARAMETER PassThru
Return processed objects instead of displaying in browser.

.PARAMETER MinConfidenceRatio
Minimum confidence ratio (0.0-1.0) for filtering people, scenes, and objects
by confidence. Only returns data for people, scenes, and objects with confidence
greater than or equal to this value. When specified, filters out low-confidence
detection results from people, scenes, and objects data while keeping the image.

.PARAMETER Append
When used with InputObject, first outputs all InputObject content, then
processes as if InputObject was not set. Allows appending search results to
existing collections.

.PARAMETER ForceConsent
Force a consent prompt even if a preference is already set for SQLite package
installation, overriding any saved consent preferences.

.PARAMETER ConsentToThirdPartySoftwareInstallation
Automatically consent to third-party software installation and set a persistent
preference flag for SQLite package, bypassing interactive consent prompts.

.EXAMPLE
Export-ImageIndex -DatabaseFilePath "C:\Custom\Path\images.db" `
    -ImageDirectories @("C:\Photos", "D:\Images") -EmbedImages

.EXAMPLE
indexcachedimages

.EXAMPLE
Export-ImageIndex -ConsentToThirdPartySoftwareInstallation
#>
###############################################################################
function Export-ImageIndex {

    [CmdletBinding()]
    [OutputType([GenXdev.Helpers.ImageSearchResult[]], [GenXdev.Helpers.ImageSearchResult])]
    [Alias('indeximages')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = ('Accepts search results from a Find-Image ' +
                'call to regenerate the view.')
        )]
        [System.Object[]] $InputObject,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('The path to the image database file. If not ' +
                'specified, a default path is used.')
        )]
        [string] $DatabaseFilePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of directory paths to search for images'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                'Array of directory path-like search strings to filter images by ' +
                "path (SQL LIKE patterns, e.g. '%\\2024\\%')"
            )
        )]
        [string[]] $PathLike,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language for descriptions and keywords.'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian',
            'Azerbaijani', 'Basque', 'Belarusian', 'Bemba', 'Bengali', 'Bihari',
            'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)',
            'Chinese (Traditional)', 'Corsican', 'Croatian', 'Czech', 'Danish',
            'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga',
            'Galician', 'Georgian', 'German', 'Greek', 'Guarani', 'Gujarati',
            'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi',
            'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Interlingua',
            'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada', 'Kazakh',
            'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean',
            'Krio (Sierra Leone)', 'Kurdish', 'Kurdish (Soranî)', 'Kyrgyz',
            'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi',
            'Luganda', 'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam',
            'Maltese', 'Maori', 'Marathi', 'Mauritian Creole', 'Moldavian',
            'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin',
            'Northern Sotho', 'Norwegian', 'Norwegian (Nynorsk)', 'Occitan',
            'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi', 'Quechua',
            'Romanian', 'Romansh', 'Runyakitara', 'Russian', 'Scots Gaelic',
            'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana',
            'Seychellois Creole', 'Shona', 'Sindhi', 'Sinhalese', 'Slovak',
            'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar',
            'Telugu', 'Thai', 'Tigrinya', 'Tonga', 'Tshiluba', 'Tumbuka',
            'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu', 'Uzbek',
            'Vietnamese', 'Welsh', 'Wolof', 'Xhosa', 'Yiddish', 'Yoruba', 'Zulu'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized by ' +
                'person folders. If not specified, uses the ' +
                'configured faces directory preference.')
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Embed images as base64 binary data in the database.'
        )]
        [switch] $EmbedImages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuild of the image index database.'
        )]
        [switch] $ForceIndexRebuild,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to disable fallback behavior.'
        )]
        [switch] $NoFallback,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to skip database initialization and rebuilding.'
        )]
        [switch] $NeverRebuild,
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
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Don''t use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [Alias('fs', 'f')]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Show LM Studio window during ' +
                'initialization')
        )]
        [Alias('sw')]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will match any of all the possible meta data types.'
        )]
        [string[]] $Any,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search all directories even when limited results would normally be returned.'
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search all drives for images.'
        )]
        [switch] $AllDrives,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not search subdirectories recursively.'
        )]
        [switch] $NoRecurse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The keywords to look for, wildcards allowed.'
        )]
        [string[]] $Keywords,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'People to look for, wildcards allowed.'
        )]
        [string[]] $People,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Objects to look for, wildcards allowed.'
        )]
        [string[]] $Objects,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Scenes to look for, wildcards allowed.'
        )]
        [string[]] $Scenes,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Description text to search for, wildcards allowed.'
        )]
        [string[]] $Description,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The description text to look for, wildcards allowed.'
        )]
        [string[]] $DescriptionSearch,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Picture types to filter by, wildcards allowed.'
        )]
        [string[]] $PictureType,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Style types to filter by, wildcards allowed.'
        )]
        [string[]] $StyleType,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Overall moods to filter by, wildcards allowed.'
        )]
        [string[]] $OverallMood,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that contain nudity.'
        )]
        [switch] $HasNudity,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that do NOT contain nudity.'
        )]
        [switch] $NoNudity,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that contain explicit content.'
        )]
        [switch] $HasExplicitContent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that do NOT contain explicit content.'
        )]
        [switch] $NoExplicitContent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by camera make from EXIF metadata.'
        )]
        [string[]] $MetaCameraMake,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by camera model from EXIF metadata.'
        )]
        [string[]] $MetaCameraModel,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by image width range.'
        )]
        [int[]] $MetaWidth,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by image height range.'
        )]
        [int[]] $MetaHeight,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS latitude coordinates.'
        )]
        [decimal[]] $MetaGPSLatitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS longitude coordinates.'
        )]
        [decimal[]] $MetaGPSLongitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS altitude.'
        )]
        [decimal[]] $MetaGPSAltitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by exposure time range.'
        )]
        [decimal[]] $MetaExposureTime,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by f-number range.'
        )]
        [decimal[]] $MetaFNumber,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by ISO speed range.'
        )]
        [int[]] $MetaISO,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by focal length range.'
        )]
        [decimal[]] $MetaFocalLength,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by date taken.'
        )]
        [string[]] $MetaDateTaken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'GPS coordinates for location-based searching.'
        )]
        [decimal[]] $GeoLocation,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Distance in meters for location-based searching.'
        )]
        [int] $GeoDistanceInMeters,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force processing even if metadata already exists.'
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return processed objects instead of displaying in browser.'
        )]
        [switch] $PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Minimum confidence ratio (0.0-1.0) for filtering ' +
                'people, scenes, and objects by confidence. Only returns data for ' +
                'people, scenes, and objects with confidence greater than or equal ' +
                'to this value.')
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $MinConfidenceRatio,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('When used with InputObject, first outputs all ' +
                'InputObject content, then processes as if InputObject was not set. ' +
                'Allows appending search results to existing collections.')
        )]
        [switch] $Append,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force a consent prompt even if preference is set for SQLite package installation.'
        )]
        [switch] $ForceConsent,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to third-party software installation and set persistent flag for SQLite package.'
        )]
        [switch] $ConsentToThirdPartySoftwareInstallation
    )

    begin {
        # load SQLite client assembly with embedded consent using Copy-IdenticalParamValues
        $ensureParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Helpers\EnsureNuGetAssembly' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # Set specific parameters for SQLite package
        $ensureParams['PackageKey'] = 'System.Data.Sqlite'
        $ensureParams['Description'] = 'Required for SQLite database operations in image indexing'
        $ensureParams['Publisher'] = 'System.Data.SQLite Development Team'

        GenXdev.Helpers\EnsureNuGetAssembly @ensureParams

        # determine database file path if not provided
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-ImageIndexPath' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        $DatabaseFilePath = GenXdev.AI\Get-ImageIndexPath @params -NeverRebuild -NoFallback

        # retrieve configured image directories if not provided
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIImageCollection' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        $ImageDirectories = GenXdev.AI\Get-AIImageCollection @params

        # copy identical parameter values for Find-Image function call
        $findImageParams = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Find-Image' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # output that the image index database is being recreated
        Microsoft.PowerShell.Utility\Write-Host (
            "Recreating image index database`r`n" +
            "Path = ${DatabaseFilePath}`r`n" +
            "Image directories = $(($ImageDirectories -join ', '))`r`n"
        ) -ForegroundColor Cyan

        # output the directories being used for image discovery
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Directories:`r`n" +
            "$(($ImageDirectories |
                Microsoft.PowerShell.Utility\ConvertTo-Json))"
        )

        # output whether image embedding is enabled or disabled
        if ($EmbedImages) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Image embedding: ENABLED - Images will be stored as binary ' +
                'data in database'
            )
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Image embedding: DISABLED - Only file paths will be stored'
            )
        }

        # define schema version constant
        $SCHEMA_VERSION = '1.0.0.7'

        # initialize info object for tracking found results
        $Info = @{
            FoundResults = $false
            TotalImages  = 0
        }

        # verify database file path is not empty
        if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            Microsoft.PowerShell.Utility\Write-Error (
                'Failed to retrieve database file path.'
            )
            return
        }

        # attempt to shutdown existing sqlite connections
        try {

            $null = [System.Data.Sqlite.SQLiteConnection]::Shutdown()
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Failed to shutdown SQLite connection: $($_.Exception.Message)"
            )
        }

        # output which database file will be used
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using image database: ${DatabaseFilePath}"
        )

        # expand database path and ensure directory exists, remove existing file
        $DatabaseFilePath = GenXdev.FileSystem\Expand-Path (
            $DatabaseFilePath
        ) -CreateDirectory -DeleteExistingFile -ErrorAction SilentlyContinue

        # define backup file path for database
        $DatabaseBackupFilePath = "";
        $idx = 0;
        while ($true) {
            try {
                $DatabaseBackupFilePath = GenXdev.FileSystem\Expand-Path "${DatabaseFilePath}.backup.$(($idx -gt 0 ? '.$idx' : ''))db" -DeleteExistingFile -CreateDirectory
                break;
            }
            catch {
                $idx++;
            }
        }

        # check if the database file exists after expansion and handle backup
        if ([IO.File]::Exists($DatabaseFilePath)) {

            # try to move the file to backup, swap if move fails
            if (-not (GenXdev.FileSystem\Move-ItemWithTracking `
                        $DatabaseFilePath $DatabaseBackupFilePath -Force)) {

                $tmp = $DatabaseFilePath
                $DatabaseFilePath = $DatabaseBackupFilePath
                $DatabaseBackupFilePath = $tmp
            }
            else {

                # move the database journal file as well if it exists
                $journalFilePath = "${DatabaseFilePath}-journal"

                if ([IO.File]::Exists($journalFilePath)) {

                    # attempt to move journal file to backup location
                    if (-not (GenXdev.FileSystem\Move-ItemWithTracking `
                                $journalFilePath "${DatabaseBackupFilePath}-journal" `
                                -Force)) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Failed to move journal file: ${journalFilePath}"
                        )

                        # move renamed file back if journal move failed
                        if (-not (GenXdev.FileSystem\Move-ItemWithTracking `
                                    -Path $DatabaseBackupFilePath `
                                    -Destination $DatabaseFilePath -Force `
                                    -ErrorAction SilentlyContinue)) {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                'Failed to restore original database file: ' +
                                "${DatabaseFilePath}"
                            )
                        }
                        else {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                'Restored original database file: ' +
                                "${DatabaseFilePath}"
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
            "Database path: ${DatabaseFilePath}"
        )

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Metadata path: ' +
            "$(($ImageDirectories |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10))"
        )

        # define table creation script for main images table
        $createImagesTable = @'
CREATE TABLE IF NOT EXISTS Images (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    path TEXT UNIQUE NOT NULL,
    image_data BLOB,
    width INTEGER,
    height INTEGER,
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

    -- Camera metadata
    camera_make TEXT,
    camera_model TEXT,
    software TEXT,

    -- GPS metadata
    gps_latitude REAL,
    gps_longitude REAL,
    gps_altitude REAL,

    -- Exposure metadata
    exposure_time REAL,
    f_number REAL,
    iso_speed INTEGER,
    focal_length REAL,
    flash INTEGER,

    -- DateTime metadata
    date_time_original TEXT,
    date_time_digitized TEXT,

    -- Color metadata
    color_space TEXT,
    bits_per_sample INTEGER,
    pixel_format TEXT,
    format TEXT,

    -- File metadata
    file_size_bytes INTEGER,
    file_name TEXT,
    file_extension TEXT,

    -- Author metadata
    artist TEXT,
    copyright TEXT,

    -- Orientation and resolution
    orientation INTEGER,
    resolution_unit TEXT,
    x_resolution REAL,
    y_resolution REAL,

    -- Raw metadata JSON - stores all metadata as JSON for LIKE searches
    metadata_json TEXT,

    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);
'@

        # create keywords lookup table for fast searching
        $createKeywordsTable = @'
CREATE TABLE IF NOT EXISTS ImageKeywords (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    keyword TEXT NOT NULL,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
'@

        # create people lookup table for face recognition data
        $createPeopleTable = @'
CREATE TABLE IF NOT EXISTS ImagePeople (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    person_name TEXT NOT NULL,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
'@

        # create objects lookup table for detected objects
        $createObjectsTable = @'
CREATE TABLE IF NOT EXISTS ImageObjects (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    object_name TEXT NOT NULL,
    object_count INTEGER DEFAULT 1,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
'@

        # create scenes lookup table for scene detection data
        $createScenesTable = @'
CREATE TABLE IF NOT EXISTS ImageScenes (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    image_id INTEGER NOT NULL,
    scene_name TEXT NOT NULL,
    confidence REAL,
    FOREIGN KEY (image_id) REFERENCES Images(id) ON DELETE CASCADE
);
'@

        # create schema version table for database versioning
        $createSchemaVersionTable = @'
CREATE TABLE IF NOT EXISTS ImageSchemaVersion (
    id INTEGER PRIMARY KEY CHECK (id = 1),
    version TEXT NOT NULL
);
'@

        # create comprehensive indexes for super fast searching with no table scans
        $createIndexes = @'
-- ===================================================================
-- PRIMARY SINGLE-COLUMN INDEXES (Most frequently used filters)
-- ===================================================================

-- Path index for unique lookups and sorting (most common operation)
CREATE INDEX IF NOT EXISTS idx_images_path ON Images(path);

-- Content safety filters (very frequently used together)
CREATE INDEX IF NOT EXISTS idx_images_nudity ON Images(has_nudity);
CREATE INDEX IF NOT EXISTS idx_images_explicit ON Images(has_explicit_content);

-- Metadata JSON for text-based searching
CREATE INDEX IF NOT EXISTS idx_images_metadata_json ON Images(metadata_json);

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

-- Only index images with GPS coordinates
CREATE INDEX IF NOT EXISTS idx_images_with_gps ON Images(gps_latitude, gps_longitude, path)
    WHERE gps_latitude IS NOT NULL AND gps_longitude IS NOT NULL;

-- Only index images with camera information
CREATE INDEX IF NOT EXISTS idx_images_with_camera ON Images(camera_make, camera_model, path)
    WHERE camera_make IS NOT NULL OR camera_model IS NOT NULL;

-- Only index images with date information
CREATE INDEX IF NOT EXISTS idx_images_with_date ON Images(date_time_original, path)
    WHERE date_time_original IS NOT NULL;

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
'@
    }

    process {

        # start stopwatch for timing the process
        $totalTime = [System.Diagnostics.Stopwatch]::StartNew()

        # always delete existing database file to ensure clean rebuild
        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $DatabaseFilePath) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Deleting existing database file for clean rebuild...'
            )

            Microsoft.PowerShell.Management\Remove-Item -LiteralPath $DatabaseFilePath -Force
        }

        # create new database using specialized function
        Microsoft.PowerShell.Utility\Write-Verbose 'Creating new database...'

        $null = GenXdev.Data\New-SQLiteDatabase -DatabaseFilePath $DatabaseFilePath

        # create tables without indexes initially for faster inserts
        Microsoft.PowerShell.Utility\Write-Verbose 'Creating database tables...'

        $createTablesQueries = @(
            $createImagesTable,
            $createKeywordsTable,
            $createPeopleTable,
            $createObjectsTable,
            $createScenesTable,
            $createSchemaVersionTable
        )

        $null = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath `
            -Queries $createTablesQueries

        # get images using Find-Image for direct integration
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Discovering images using Find-Image...'
        )

        # create transaction for batch operations to improve performance
        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Data\Get-SQLiteTransaction' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        $transaction = GenXdev.Data\Get-SQLiteTransaction @params

        # prepare image insertion query based on whether embedding is enabled
        $insertQuery = if ($EmbedImages) {

            ('INSERT INTO Images (path, image_data, width, height, ' +
            'has_explicit_content, has_nudity, short_description, ' +
            'long_description, picture_type, overall_mood_of_image, ' +
            'style_type, description_keywords, people_count, people_faces, ' +
            'people_json, objects_count, objects_list, objects_json, ' +
            'object_counts, scene_label, scene_confidence, ' +
            'scene_confidence_percentage, camera_make, ' +
            'camera_model, software, gps_latitude, gps_longitude, ' +
            'gps_altitude, exposure_time, f_number, iso_speed, focal_length, ' +
            'flash, date_time_original, date_time_digitized, color_space, ' +
            'bits_per_sample, pixel_format, format, file_size_bytes, file_name, ' +
            'file_extension, artist, copyright, orientation, ' +
            'resolution_unit, x_resolution, y_resolution, metadata_json) ' +
            'VALUES (@path, @image_data, @width, @height, @explicit, ' +
            '@nudity, @short_desc, @long_desc, @pic_type, @mood, @style, ' +
            '@desc_keywords, @people_count, @people_faces, @people_json, ' +
            '@objects_count, @objects_list, @objects_json, @object_counts, ' +
            '@scene_label, @scene_confidence, @scene_conf_pct, ' +
            '@camera_make, @camera_model, @software, ' +
            '@gps_latitude, @gps_longitude, @gps_altitude, @exposure_time, ' +
            '@f_number, @iso_speed, @focal_length, @flash, ' +
            '@date_time_original, @date_time_digitized, @color_space, ' +
            '@bits_per_sample, @pixel_format, @format, @file_size_bytes, @file_name, ' +
            '@file_extension, @artist, @copyright, @orientation, ' +
            '@resolution_unit, @x_resolution, @y_resolution, @metadata_json)')
        }
        else {

            ('INSERT INTO Images (path, width, height, has_explicit_content, ' +
            'has_nudity, short_description, long_description, picture_type, ' +
            'overall_mood_of_image, style_type, description_keywords, ' +
            'people_count, people_faces, people_json, objects_count, ' +
            'objects_list, objects_json, object_counts, scene_label, ' +
            'scene_confidence, scene_confidence_percentage, ' +
            'camera_make, camera_model, software, ' +
            'gps_latitude, gps_longitude, gps_altitude, exposure_time, ' +
            'f_number, iso_speed, focal_length, flash, date_time_original, ' +
            'date_time_digitized, color_space, bits_per_sample, pixel_format, format, ' +
            'file_size_bytes, file_name, file_extension, artist, ' +
            'copyright, orientation, resolution_unit, x_resolution, ' +
            'y_resolution, metadata_json) VALUES (@path, @width, @height, ' +
            '@explicit, @nudity, @short_desc, @long_desc, @pic_type, @mood, ' +
            '@style, @desc_keywords, @people_count, @people_faces, ' +
            '@people_json, @objects_count, @objects_list, @objects_json, ' +
            '@object_counts, @scene_label, @scene_confidence, ' +
            '@scene_conf_pct, @camera_make, @camera_model, ' +
            '@software, @gps_latitude, @gps_longitude, @gps_altitude, ' +
            '@exposure_time, @f_number, @iso_speed, @focal_length, @flash, ' +
            '@date_time_original, @date_time_digitized, @color_space, ' +
            '@bits_per_sample, @pixel_format, @format, @file_size_bytes, @file_name, ' +
            '@file_extension, @artist, @copyright, @orientation, ' +
            '@resolution_unit, @x_resolution, @y_resolution, @metadata_json)')
        }

        # define internal function to import images from various sources
        function ImportImages {
            param($Info)

            # set found results to true when images are found
            $Info.FoundResults = $true



            # prepare lookup table inserts using strongly typed collections
            [System.Collections.Generic.List[String]] $lookupQueries = `
                [System.Collections.Generic.List[String]]::new()

            [System.Collections.Generic.List[System.Collections.Hashtable]] `
                $lookupParams = `
                [System.Collections.Generic.List[System.Collections.Hashtable]]::new()

            # define internal function to insert a single image into database
            function insertImage {
                param([GenXdev.Helpers.ImageSearchResult] $image, $Info)

                process {


                    # clear previous lookup data for this image
                    $lookupQueries.Clear()
                    $lookupParams.Clear()
                    $Info.FoundResults = $true

                    try {

                        $Info.TotalImages++

                        # build parameters for main image record insert with null checks
                        $imageParams = @{
                            'path'                = $image.path
                            'width'               = $image.width
                            'height'              = $image.height
                            'explicit'            = if ($image.description -and
                                $image.description.Has_Explicit_Content) { 1 }
                            else { 0 }
                            'nudity'              = if ($image.description -and
                                $image.description.Has_Nudity) { 1 }
                            else { 0 }
                            'short_desc'          = if ($image.description) {
                                $image.description.Short_Description
                            }
                            else { '' }
                            'long_desc'           = if ($image.description) {
                                $image.description.Long_Description
                            }
                            else { '' }
                            'pic_type'            = if ($image.description) {
                                $image.description.Picture_Type
                            }
                            else { '' }
                            'mood'                = if ($image.description) {
                                $image.description.Overall_MoodOf_Image
                            }
                            else { '' }
                            'style'               = if ($image.description) {
                                $image.description.Style_Type
                            }
                            else { '' }
                            'desc_keywords'       = if ($image.description -and
                                $image.description.Keywords) {
                                if ($image.description.Keywords.Count -gt 0) {
                                    ($image.description.Keywords |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                                            -Compress -Depth 20)
                                }
                                else {
                                    '[]'
                                }
                            }
                            else {
                                '[]'
                            }
                            'people_count'        = if ($image.people) {
                                $image.people.Count
                            }
                            else { 0 }
                            'people_faces'        = if ($image.people -and
                                $image.people.Faces) {
                                if ($image.people.Faces.Count -gt 0) {
                                    ($image.people.Faces |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                                            -Compress -Depth 20)
                                }
                                else {
                                    '[]'
                                }
                            }
                            else {
                                '[]'
                            }
                            'people_json'         = if ($image.people) {
                                ($image.people |
                                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                                        -Compress -Depth 20)
                            }
                            else { '{}' }
                            'objects_count'       = if ($image.objects) {
                                $image.objects.Count
                            }
                            else { 0 }
                            'objects_list'        = if ($image.objects -and
                                $image.objects.objects) {
                                if ($image.objects.objects.Count -gt 0) {
                                    ($image.objects.objects |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                                            -Compress -Depth 20)
                                }
                                else {
                                    '[]'
                                }
                            }
                            else {
                                '[]'
                            }
                            'objects_json'        = if ($image.objects) {
                                ($image.objects |
                                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                                        -Compress -Depth 20)
                            }
                            else { '{}' }
                            'object_counts'       = if ($image.objects -and
                                $image.objects.object_counts) {
                                ($image.objects.object_counts |
                                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                                        -Compress -Depth 20)
                            }
                            else {
                                '{}'
                            }
                            'scene_label'         = if ($image.scenes) {
                                $image.scenes.Label
                            }
                            else { '' }
                            'scene_confidence'    = if ($image.scenes) {
                                $image.scenes.Confidence
                            }
                            else { 0 }
                            'scene_conf_pct'      = if ($image.scenes) {
                                $image.scenes.Confidence_Percentage
                            }
                            else { 0 }

                            # Camera metadata
                            'camera_make'         = if ($image.metadata -and
                                $image.metadata.Camera.Make) {
                                $image.metadata.Camera.Make
                            }
                            else { '' }
                            'camera_model'        = if ($image.metadata -and
                                $image.metadata.Camera.Model) {
                                $image.metadata.Camera.Model
                            }
                            else { '' }
                            # Use only Other.Software since Find-Image searches this field
                            # Camera.Software is for EXIF camera info, Other.Software is for
                            # image editing software like Picasa, Photoshop, etc.
                            'software'            = if ($image.metadata -and
                                -not [string]::IsNullOrEmpty($image.metadata.Other.Software)) {
                                $image.metadata.Other.Software
                            }
                            else { '' }

                            # GPS metadata
                            'gps_latitude'        = if ($image.metadata -and
                                $image.metadata.GPS.Latitude) {
                                $image.metadata.GPS.Latitude
                            }
                            else { $null }
                            'gps_longitude'       = if ($image.metadata -and
                                $image.metadata.GPS.Longitude) {
                                $image.metadata.GPS.Longitude
                            }
                            else { $null }
                            'gps_altitude'        = if ($image.metadata -and
                                $image.metadata.GPS.Altitude) {
                                $image.metadata.GPS.Altitude
                            }
                            else { $null }

                            # Exposure metadata
                            'exposure_time'       = if ($image.metadata -and
                                $image.metadata.Exposure.ExposureTime) {
                                "$($image.metadata.Exposure.ExposureTime)"
                            }
                            else { $null }
                            'f_number'            = if ($image.metadata -and
                                $image.metadata.Exposure.FNumber) {
                                "$($image.metadata.Exposure.FNumber)"
                            }
                            else { $null }
                            'iso_speed'           = if ($image.metadata -and
                                $image.metadata.Exposure.ISOSpeedRatings) {
                                $image.metadata.Exposure.ISOSpeedRatings
                            }
                            else { $null }
                            'focal_length'        = if ($image.metadata -and
                                $image.metadata.Exposure.FocalLength) {
                                "$($image.metadata.Exposure.FocalLength)"
                            }
                            else { $null }
                            'flash'               = if ($image.metadata -and
                                $image.metadata.Exposure.Flash) {
                                $image.metadata.Exposure.Flash
                            }
                            else { $null }

                            # DateTime metadata
                            'date_time_original'  = if ($image.metadata -and
                                $image.metadata.DateTime.DateTimeOriginal) {
                                $image.metadata.DateTime.DateTimeOriginal
                            }
                            else { '' }
                            'date_time_digitized' = if ($image.metadata -and
                                $image.metadata.DateTime.DateTimeDigitized) {
                                $image.metadata.DateTime.DateTimeDigitized
                            }
                            else { '' }

                            # Color metadata
                            'color_space'         = if ($image.metadata -and
                                $image.metadata.Other.ColorSpace) {
                                $image.metadata.Other.ColorSpace
                            }
                            else { '' }
                            'bits_per_sample'     = if ($image.metadata -and
                                $image.metadata.Basic.BitsPerSample) {
                                $image.metadata.Basic.BitsPerSample
                            }
                            else { $null }
                            'pixel_format'        = if ($image.metadata -and
                                $image.metadata.Basic.PixelFormat) {
                                $image.metadata.Basic.PixelFormat
                            }
                            else { '' }
                            'format'              = if ($image.metadata -and
                                $image.metadata.Basic.Format) {
                                $image.metadata.Basic.Format
                            }
                            else { '' }

                            # File metadata
                            'file_size_bytes'     = if ($image.metadata -and
                                $image.metadata.Basic.FileSizeBytes) {
                                $image.metadata.Basic.FileSizeBytes
                            }
                            else { $null }
                            'file_name'           = if ($image.metadata -and
                                $image.metadata.Basic.FileName) {
                                $image.metadata.Basic.FileName
                            }
                            else { '' }
                            'file_extension'      = if ($image.metadata -and
                                $image.metadata.Basic.FileExtension) {
                                $image.metadata.Basic.FileExtension
                            }
                            else { '' }

                            # Author metadata
                            'artist'              = if ($image.metadata -and
                                $image.metadata.Author.Artist) {
                                $image.metadata.Author.Artist
                            }
                            else { '' }
                            'copyright'           = if ($image.metadata -and
                                $image.metadata.Author.Copyright) {
                                $image.metadata.Author.Copyright
                            }
                            else { '' }

                            # Orientation and resolution
                            'orientation'         = if ($image.metadata -and
                                $image.metadata.Basic.Orientation) {
                                $image.metadata.Basic.Orientation
                            }
                            else { $null }
                            'resolution_unit'     = if ($image.metadata -and
                                $image.metadata.Other.ResolutionUnit) {
                                $image.metadata.Other.ResolutionUnit
                            }
                            else { '' }
                            'x_resolution'        = if ($image.metadata -and
                                $image.metadata.Basic.HorizontalResolution) {
                                $image.metadata.Basic.HorizontalResolution
                            }
                            else { $null }
                            'y_resolution'        = if ($image.metadata -and
                                $image.metadata.Basic.VerticalResolution) {
                                $image.metadata.Basic.VerticalResolution
                            }
                            else { $null }

                            # Store complete metadata as JSON for text-based searching
                            'metadata_json'       = if ($image.metadata) {
                                ($image.metadata |
                                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                                        -Compress -Depth 20)
                            }
                            else { '{}' }
                        }

                        # add image data if embedding is enabled for binary storage
                        if ($EmbedImages) {

                            try {

                                # check if image file exists before reading binary data
                                if (Microsoft.PowerShell.Management\Test-Path `
                                        -LiteralPath $image.path -PathType Leaf) {

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Reading image data from: $($image.path)"
                                    )

                                    $imageBytes = `
                                        [System.IO.File]::ReadAllBytes($image.path)
                                    $imageParams['image_data'] = $imageBytes

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Embedded $($imageBytes.Length) bytes " +
                                        "for image: $($image.path)"
                                    )
                                }
                                else {

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        'Image file not found for embedding: ' +
                                        "$($image.path)"
                                    )

                                    $imageParams['image_data'] = $null
                                }
                            }
                            catch {

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    'Failed to read image data for embedding: ' +
                                    "$($image.path) - $($_.Exception.Message)"
                                )

                                $imageParams['image_data'] = $null
                            }
                        }

                        # execute the insert and get the new ID for foreign key references
                        $queries = @($insertQuery, 'SELECT last_insert_rowid() AS newId;')

                        $result = GenXdev.Data\Invoke-SQLiteQuery `
                            -Transaction $transaction -Queries $queries `
                            -SqlParameters @($imageParams)

                        $imageId = $result |
                            Microsoft.PowerShell.Utility\Select-Object `
                                -ExpandProperty newId

                        # clear collections for reuse with this image
                        $lookupQueries.Clear()
                        $lookupParams.Clear()

                        # insert keywords if present for searchable metadata
                        if ($image.description -and $image.description.Keywords -and $image.description.Keywords.Count -gt 0) {

                            foreach ($keyword in $image.description.Keywords) {

                                $lookupQueries.Add(
                                    ('INSERT INTO ImageKeywords (image_id, ' +
                                    'keyword) VALUES (@image_id, @keyword)'))

                                $lookupParams.Add(@{
                                        'image_id' = $imageId;
                                        'keyword'  = $keyword
                                    })
                            }
                        }

                        # insert people data by parsing faces string if needed
                        if ($image.people -and $image.people.faces -and
                            $image.people.faces -ne '' -and
                            $image.people.faces.Count -gt 0) {

                            # handle both array and comma-separated string formats
                            $people = if ($image.people.faces -is [array]) {
                                $image.people.faces
                            }
                            else {
                                $image.people.faces -split ',' |
                                    Microsoft.PowerShell.Core\ForEach-Object {
                                        $_.Trim() } |
                                    Microsoft.PowerShell.Core\Where-Object {
                                        $_ -ne '' }
                            }

                            foreach ($person in $people) {

                                $lookupQueries.Add(
                                    ('INSERT INTO ImagePeople (image_id, ' +
                                    'person_name) VALUES (@image_id, @person_name)'))

                                $lookupParams.Add(@{
                                        'image_id'    = $imageId;
                                        'person_name' = $person
                                    })
                            }
                        }

                        # insert objects data by parsing objects string if needed
                        if ($image.objects -and $image.objects.objects -and
                            $image.objects.objects -ne '' -and
                            $image.objects.objects.Count -gt 0) {

                            # handle both array and comma-separated string formats
                            $objects = if ($image.objects.objects -is [array]) {
                                $image.objects.objects
                            }
                            else {
                                $image.objects.objects -split ',' |
                                    Microsoft.PowerShell.Core\ForEach-Object {
                                        $_.Trim() } |
                                    Microsoft.PowerShell.Core\Where-Object {
                                        $_ -ne '' }
                            }

                            foreach ($obj in $objects) {

                                $lookupQueries.Add(
                                    ('INSERT INTO ImageObjects (image_id, ' +
                                    'object_name) VALUES (@image_id, @object_name)'))

                                $lookupParams.Add(@{
                                        'image_id'    = $imageId;
                                        'object_name' = $obj
                                    })
                            }
                        }

                        # insert scenes if present with confidence data
                        if ($image.scenes -and
                            (-not [string]::IsNullOrWhiteSpace($image.scenes.label))) {

                            $lookupQueries.Add(
                                ('INSERT INTO ImageScenes (image_id, scene_name, ' +
                                'confidence) VALUES (@image_id, @scene_name, ' +
                                '@confidence)'))

                            $lookupParams.Add(@{
                                    'image_id'   = $imageId;
                                    'scene_name' = $image.scenes.label;
                                    'confidence' = $image.scenes.confidence
                                })
                        }

                        # execute all lookup inserts in a single batch for performance
                        if ($lookupQueries.Count -gt 0) {

                            $null = GenXdev.Data\Invoke-SQLiteQuery `
                                -Transaction $transaction -Queries $lookupQueries `
                                -SqlParameters $lookupParams

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Inserted lookup data for image ID ${imageId}"
                            )
                        }
                        else {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "No lookup data to insert for image ID ${imageId}"
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

                        Microsoft.PowerShell.Utility\Write-Verbose (
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

                        try {
                            insertImage $PSItem $Info
                            $Info.FoundResults = $true
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "[Export-ImageIndex] Exception: $($_.Exception.Message)"
                        }
                    }
            }
            else {

                # discover images using Find-Image and process each one
                GenXdev.AI\Find-Image @findImageParams |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        try {
                            insertImage $PSItem $Info
                            $Info.FoundResults = $true
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "[Export-ImageIndex] Exception: $($_.Exception.Message)"
                        }
                    }
            }
        }

        try {

            try {

                # attempt to import images using current configuration
                ImportImages $Info

                # if no results found, update all image metadata and retry once
                if (-not $Info.FoundResults) {

                    $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev.AI\Update-AllImageMetaData' `
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
                    'Transaction committed successfully with ' +
                    "$($Info.TotalImages) images"
                )

            }
            catch {
                # rollback on error to maintain database integrity
                $transaction.Rollback()
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Transaction rolled back due to error: ' +
                    "$($_.Exception.Message)"
                )
                Microsoft.PowerShell.Utility\Write-Verbose "[Export-ImageIndex] Exception: $($_.Exception.Message)"
                throw $_
            }

            # create indexes for optimal performance outside transaction
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Creating indexes for optimal performance...'
            )

            $null = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath -Queries $createIndexes

            # run ANALYZE to update query optimizer statistics for best performance
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Running ANALYZE to optimize query planning...'
            )

            $null = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath -Queries 'ANALYZE;'

            # insert schema version for database versioning
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting schema version to ${SCHEMA_VERSION}..."
            )

            $null = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries ('INSERT OR REPLACE INTO ImageSchemaVersion ' +
                '(id, version) VALUES (1, @version)') `
                -SqlParameters @{ 'version' = $SCHEMA_VERSION }

            # stop the stopwatch and output completion message with timing
            $totalTime.Stop()

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Image database initialization completed successfully with ' +
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

            $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Get-ImageIndexStats' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            GenXdev.AI\Get-ImageIndexStats @params |
                Microsoft.PowerShell.Utility\Write-Output
        }
    }

    end {

    }
}
###############################################################################