###############################################################################
<#
.SYNOPSIS
Searches for images using an optimized SQLite database with fast indexed lookups.

.DESCRIPTION
Performs high-performance image searches using a pre-built SQLite database with
optimized indexes. This function provides the same search capabilities as
Find-Image but with significantly faster performance by eliminating file system
scans and using database indexes for all search criteria.

When no selection/filter criteria are specified, the function automatically
sets PathLike to search the current directory. With -NoRecurse, it searches
only the current directory; without -NoRecurse, it searches recursively.

Parameter Logic:
- Within each parameter type (Keywords, People, Objects, etc.): Uses OR logic
  Example: -Keywords "cat","dog" finds images with EITHER cat OR dog
- Between different parameter types: Uses AND logic
  Example: -Keywords "cat" -People "John" finds images with cat AND John
- EXIF range parameters: Provide [min, max] values for filtering ranges
- String parameters: Support wildcard matching with * and ? (converted to SQL LIKE)

.PARAMETER Any
Will match any of all the possible meta data types.

.PARAMETER DatabaseFilePath
The path to the image database file. If not specified, a default path is used.

.PARAMETER ImageDirectories
Array of directory paths to search for images.

.PARAMETER PathLike
Array of directory path-like search strings to filter images by path (SQL LIKE
patterns, e.g. '%\2024\%').

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

.PARAMETER DescriptionSearch
The description text to look for, wildcards allowed.

.PARAMETER Keywords
The keywords to look for, wildcards allowed.

.PARAMETER People
People to look for, wildcards allowed.

.PARAMETER Objects
Objects to look for, wildcards allowed.

.PARAMETER Scenes
Scenes to look for, wildcards allowed.

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

.PARAMETER ShowInBrowser
Show results in a browser gallery.

.PARAMETER PassThru
Return image data as objects.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keys.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys.

.PARAMETER NoBorders
Remove window borders and title bar for a cleaner appearance.

.PARAMETER SideBySide
Place browser window side by side with PowerShell on the same monitor.

.PARAMETER Title
Title for the image gallery.

.PARAMETER Description
Description for the image gallery.

.PARAMETER FocusWindow
Focus the browser window after opening.

.PARAMETER SetForeground
Set the browser window to foreground after opening.

.PARAMETER Maximize
Maximize the browser window after positioning.

.PARAMETER AcceptLang
Browser accept-language header.

.PARAMETER Monitor
Monitor to use for display.

.PARAMETER Width
Initial width of browser window.

.PARAMETER Height
Initial height of browser window.

.PARAMETER X
Initial X position of browser window.

.PARAMETER Y
Initial Y position of browser window.

.PARAMETER Interactive
Enable interactive browser features.

.PARAMETER Private
Open in private/incognito mode.

.PARAMETER Force
Force enable debugging port.

.PARAMETER Edge
Open in Microsoft Edge.

.PARAMETER Chrome
Open in Google Chrome.

.PARAMETER Chromium
Open in Chromium-based browser.

.PARAMETER Firefox
Open in Firefox.

.PARAMETER All
Open in all browsers.

.PARAMETER FullScreen
Open in fullscreen mode.

.PARAMETER Left
Place window on left side.

.PARAMETER Right
Place window on right side.

.PARAMETER Top
Place window on top.

.PARAMETER Bottom
Place window on bottom.

.PARAMETER Centered
Center the window.

.PARAMETER ApplicationMode
Hide browser controls.

.PARAMETER NoBrowserExtensions
Disable browser extensions.

.PARAMETER DisablePopupBlocker
Disable popup blocker.

.PARAMETER RestoreFocus
Restore PowerShell focus.

.PARAMETER NewWindow
Create new browser window.

.PARAMETER OnlyReturnHtml
Only return HTML.

.PARAMETER InputObject
Accepts search results from a previous -PassThru call to regenerate the view.

.PARAMETER ShowOnlyPictures
Show only pictures in a rounded rectangle, no text below.

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

.PARAMETER FocusWindow
Focus the browser window when opening.

.PARAMETER SetForeground
Bring browser window to foreground.

.PARAMETER KeysToSend
Array of key combinations to send to the browser after opening (e.g., @('F11', 'Ctrl+Shift+I')).

.PARAMETER MinConfidenceRatio
Minimum confidence ratio (0.0-1.0) for filtering people, scenes, and objects
by confidence. Only returns data for people, scenes, and objects with confidence
greater than or equal to this value. When specified, filters out low-confidence
detection results from people, scenes, and objects data while keeping the image.

.PARAMETER Append
When used with InputObject, first outputs all InputObject content, then
processes as if InputObject was not set. Allows appending search results to
existing collections.

.EXAMPLE
Find-IndexedImage -Keywords "cat","dog" -ShowInBrowser -NoNudity

.EXAMPLE
lii "cat","dog" -ShowInBrowser -NoNudity

.EXAMPLE
Find-IndexedImage
Searches all images in the current directory and subdirectories (no filter criteria specified).

.EXAMPLE
Find-IndexedImage -NoRecurse
Searches only images in the current directory, without recursing into subdirectories.
#>
###############################################################################
function Find-IndexedImage {

    [CmdletBinding()]
    [OutputType([Object[]], [System.Collections.Generic.List[Object]], [string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'fromInput')]
    [Alias('findindexedimages', 'lii')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Will match any of all the possible meta data types.'
        )]
        [string[]] $Any = @(),
        ###############################################################################
        [Parameter(
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
            HelpMessage = ('Array of directory path-like search strings to ' +
                'filter images by path (SQL LIKE patterns, e.g. ' +
                "'%\\2024\\%')")
        )]
        [string[]] $PathLike = @(),
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
        [parameter(
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized by ' +
                'person folders. If not specified, uses the ' +
                'configured faces directory preference.')
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The description text to look for, wildcards allowed.'
        )]
        [string[]] $DescriptionSearch = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The keywords to look for, wildcards allowed.'
        )]
        [string[]] $Keywords = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'People to look for, wildcards allowed.'
        )]
        [string[]] $People = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Objects to look for, wildcards allowed.'
        )]
        [string[]] $Objects = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Scenes to look for, wildcards allowed.'
        )]
        [string[]] $Scenes = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Picture types to filter by, wildcards allowed.'
        )]
        [string[]] $PictureType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Style types to filter by, wildcards allowed.'
        )]
        [string[]] $StyleType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Overall moods to filter by, wildcards allowed.'
        )]
        [string[]] $OverallMood = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = ('Accepts search results from a previous -PassThru ' +
                'call to regenerate the view.')
        )]
        [System.Object[]] $InputObject,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Embed images as base64.'
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
            HelpMessage = 'Show results in a browser gallery.'
        )]
        [Alias('show', 's')]
        [switch] $ShowInBrowser,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return image data as objects.'
        )]
        [Alias('pt')]
        [switch]$PassThru,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevents returning keyboard focus to PowerShell after sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay between different input strings in milliseconds when sending keys'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Remove window borders and title bar for a cleaner appearance'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window side by side with PowerShell on the same monitor'
        )]
        [Alias('sbs')]
        [switch]$SideBySide,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Title for the image gallery.'
        )]
        [string] $Title,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Description for the image gallery.'
        )]
        [string] $Description,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Browser accept-language header.'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Monitor to use for display.'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Initial width of browser window.'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Initial height of browser window.'
        )]
        [int] $Height,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Initial X position of browser window.'
        )]
        [int] $X,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Initial Y position of browser window.'
        )]
        [int] $Y,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Show only pictures in a rounded rectangle, no ' +
                'text below.')
        )]
        [Alias('NoMetadata', 'OnlyPictures')]
        [switch] $ShowOnlyPictures,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable interactive browser features.'
        )]
        [Alias('i', 'editimages')]
        [switch] $Interactive,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in private/incognito mode.'
        )]
        [Alias('incognito', 'inprivate')]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force enable debugging port.'
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Microsoft Edge.'
        )]
        [Alias('e')]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Google Chrome.'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Chromium-based browser.'
        )]
        [Alias('c')]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Firefox.'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in all browsers.'
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in fullscreen mode.'
        )]
        [Alias('sw')]
        [switch]$ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on left side.'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on right side.'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on top.'
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on bottom.'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window.'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide browser controls.'
        )]
        [Alias('a', 'app', 'appmode')]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable browser extensions.'
        )]
        [Alias('de', 'ne', 'NoExtensions')]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable popup blocker.'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell focus.'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Create new browser window.'
        )]
        [Alias('nw', 'new')]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only return HTML.'
        )]
        [switch] $OnlyReturnHtml,
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
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###############################################################################
        ###############################################################################
        [Alias('DatabasePath')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, ' +
                'etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send specified keys to the browser window after opening'
        )]
        [string[]] $KeysToSend,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Auto-scroll the page by this many pixels per second (null to disable)'
        )]
        [int]$AutoScrollPixelsPerSecond = $null,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Animate rectangles (objects/faces) in visible range, cycling every 300ms'
        )]
        [switch]$AutoAnimateRectangles,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force single column layout (centered, 1/3 screen width)'
        )]
        [switch]$SingleColumnMode = $false,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prefix to prepend to each image path (e.g. for remote URLs)'
        )]
        [string]$ImageUrlPrefix = '',
        ###############################################################################
        <#
        .PARAMETER AllDrives
        Search across all available drives.
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search across all available drives'
        )]
        [switch] $AllDrives,
        ###############################################################################
        <#
        .PARAMETER NoRecurse
        Do not recurse into subdirectories.
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not recurse into subdirectories'
        )]
        [switch] $NoRecurse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by camera make in image EXIF metadata (manufacturer name).'
        )]
        [string[]] $MetaCameraMake = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by camera model in image EXIF metadata.'
        )]
        [string[]] $MetaCameraModel = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS latitude in image EXIF metadata. Single value or range.'
        )]
        [double[]] $MetaGPSLatitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS longitude in image EXIF metadata. Single value or range.'
        )]
        [double[]] $MetaGPSLongitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS altitude in image EXIF metadata. Single value or range.'
        )]
        [double[]] $MetaGPSAltitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by exposure time in image EXIF metadata (in seconds).'
        )]
        [double[]] $MetaExposureTime,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by F-number (aperture) in image EXIF metadata.'
        )]
        [double[]] $MetaFNumber,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by ISO speed in image EXIF metadata.'
        )]
        [int[]] $MetaISO,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by focal length in image EXIF metadata (in mm).'
        )]
        [double[]] $MetaFocalLength,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by image width in pixels from EXIF metadata.'
        )]
        [int[]] $MetaWidth,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by image height in pixels from EXIF metadata.'
        )]
        [int[]] $MetaHeight,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by date taken from EXIF metadata. Can be a date range.'
        )]
        [DateTime[]] $MetaDateTaken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Find images near this location (latitude,longitude).'
        )]
        [double[]] $GeoLocation,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum distance in meters from GeoLocation to search for images.'
        )]
        [double] $GeoDistanceInMeters = 1000,
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
        [switch] $Append
        ###############################################################################
    )

    ###############################################################################
    begin {

        # handle html only mode - forces show in browser without interactive features
        if ($OnlyReturnHtml) {

            $Interactive = $false
            $ShowInBrowser = $true
        }

        # copy function parameters for ai meta language retrieval
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # determine the language for metadata retrieval
        $Language = GenXdev.AI\Get-AIMetaLanguage @params

        # initialize result tracking information
        $info = @{
            resultCount = 0
        }

        # create results collection for browser display mode
        [System.Collections.Generic.List[Object]] $results = @()

        # initialize results collection
        [System.Collections.Generic.List[Object]] $results = $null

        # initialize input tracking flag
        [bool] $fromInput = $false

        # detect if no selection/filter criteria are specified
        $hasSelectionCriteria = (
            ($null -ne $Any -and $Any.Count -gt 0) -or
            ($null -ne $InputObject) -or
            ($null -ne $DescriptionSearch -and $DescriptionSearch.Count -gt 0) -or
            ($null -ne $Keywords -and $Keywords.Count -gt 0) -or
            ($null -ne $People -and $People.Count -gt 0) -or
            ($null -ne $Objects -and $Objects.Count -gt 0) -or
            ($null -ne $Scenes -and $Scenes.Count -gt 0) -or
            ($null -ne $PictureType -and $PictureType.Count -gt 0) -or
            ($null -ne $StyleType -and $StyleType.Count -gt 0) -or
            ($null -ne $OverallMood -and $OverallMood.Count -gt 0) -or
            ($null -ne $PathLike -and $PathLike.Count -gt 0) -or
            $HasNudity -or $NoNudity -or $HasExplicitContent -or $NoExplicitContent -or
            ($null -ne $MetaCameraMake -and $MetaCameraMake.Count -gt 0) -or
            ($null -ne $MetaCameraModel -and $MetaCameraModel.Count -gt 0) -or
            ($null -ne $MetaGPSLatitude -and $MetaGPSLatitude.Count -gt 0) -or
            ($null -ne $MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) -or
            ($null -ne $MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0) -or
            ($null -ne $MetaExposureTime -and $MetaExposureTime.Count -gt 0) -or
            ($null -ne $MetaFNumber -and $MetaFNumber.Count -gt 0) -or
            ($null -ne $MetaISO -and $MetaISO.Count -gt 0) -or
            ($null -ne $MetaFocalLength -and $MetaFocalLength.Count -gt 0) -or
            ($null -ne $MetaWidth -and $MetaWidth.Count -gt 0) -or
            ($null -ne $MetaHeight -and $MetaHeight.Count -gt 0) -or
            ($null -ne $MetaDateTaken -and $MetaDateTaken.Count -gt 0) -or
            ($null -ne $GeoLocation -and $GeoLocation.Count -eq 2) -or
            ($PSBoundParameters.ContainsKey('MinConfidenceRatio'))
        )

        # if no selection criteria are specified, set PathLike to current directory wildcard
        if (-not $hasSelectionCriteria) {
            # get current directory for limiting results
            $currentDirExpanded = GenXdev.FileSystem\Expand-Path '.\'

            # search only current directory (non-recursive)
            $PathLike = @("$currentDirExpanded\*")
            $ImageDirectories = @($currentDirExpanded)
            Microsoft.PowerShell.Utility\Write-Verbose (
                "No selection criteria, searching current directory only: $currentDirExpanded"
            )
        }

        $done = @{}
    }
    ###############################################################################
    process {

        # handle append mode - output InputObject first, then process as normal
        if ($Append -and $null -ne $InputObject) {

            # first, output all InputObject content using Write-Output
            $InputObject | Microsoft.PowerShell.Utility\Write-Output
            $done."$(($InputObject.Path))" = $true;

            # then clear InputObject and continue processing as if it wasn't set
            $InputObject = $null
        }

        # handle input objects from pipeline
        if ($null -ne $InputObject) {

            @($InputObject) |
                Microsoft.PowerShell.Core\ForEach-Object `
                    -ErrorAction SilentlyContinue {

                # convert pipeline input to hashtable
                $item = $_ | GenXdev.Helpers\ConvertTo-HashTable

                # initialize results collection if needed
                if ($null -eq $results) {

                    $results = [System.Collections.Generic.List[Object]]::new()
                    $fromInput = $true
                }

                # handle collection items
                if ($item -is [System.Collections.IEnumerable] -and
                    (-not $InputObject.ContainsKey('Path'))) {

                    $item | Microsoft.PowerShell.Core\ForEach-Object {

                        # convert nested items to hashtables
                        $secondItem = $_ |
                            GenXdev.Helpers\ConvertTo-HashTable

                        # add items with valid paths to results
                        if ($secondItem.ContainsKey('Path')) {

                            $null = $results.Add($_)
                            $Info.resultCount++
                        }
                    }
                }
                else {

                    # add single input objects to the results collection
                    $null = $results.Add($_)
                    $Info.resultCount++
                }
            }
        }

        # if we processed input objects, skip database search
        if ($fromInput) {
            return
        }

        # helper function to convert database result to image object
        function ConvertTo-ImageObject {
            param(
                [Parameter(Mandatory)]
                $DbResult,
                [switch]$EmbedImages
            )

            # determine image path and handle base64 embedding if requested
            $imagePath = $DbResult.path

            # convert to base64 data url if embedding is enabled and data exists
            if (
                $EmbedImages -and $null -ne $DbResult.image_data -and
                $DbResult.image_data.Length -gt 0
            ) {
                try {
                    # determine mime type from file extension
                    $extension = [System.IO.Path]::GetExtension($DbResult.path).
                        ToLower()

                    # select appropriate mime type based on file extension
                    $mimeType = switch ($extension) {
                        '.jpg'  { 'image/jpeg' }
                        '.jpeg' { 'image/jpeg' }
                        '.png'  { 'image/png' }
                        '.gif'  { 'image/gif' }
                        '.bmp'  { 'image/bmp' }
                        '.webp' { 'image/webp' }
                        '.tiff' { 'image/tiff' }
                        '.tif'  { 'image/tiff' }
                        default { 'image/jpeg' }  # fallback
                    }

                    # convert bytes to base64 data URL
                    $base64 = [Convert]::ToBase64String($DbResult.image_data)
                    $imagePath = (
                        "data:$mimeType;base64,$base64"
                    )

                    # output verbose message for conversion
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Converted embedded image to data URL: " +
                        "$($DbResult.path) -> $mimeType " +
                        "($($DbResult.image_data.Length) bytes)"
                    )
                }
                catch {
                    # output warning if conversion fails
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Failed to convert embedded image data to base64 for: ' +
                        "$($DbResult.path) - $($_.Exception.Message)"
                    )

                    # fallback to original path
                    $imagePath = $DbResult.path
                }
            }

            # build complete metadata object with exif data structure
            $metadataObject = @{
                Camera = @{
                    Make = $DbResult.camera_make
                    Model = $DbResult.camera_model
                }
                GPS = @{
                    Latitude = $DbResult.gps_latitude
                    Longitude = $DbResult.gps_longitude
                    Altitude = $DbResult.gps_altitude
                }
                Exposure = @{
                    ExposureTime = $DbResult.exposure_time
                    FNumber = $DbResult.f_number
                    ISOSpeedRatings = $DbResult.iso_speed
                    FocalLength = $DbResult.focal_length
                    Flash = $DbResult.flash
                }
                DateTime = @{
                    DateTimeOriginal = $DbResult.date_time_original
                    DateTimeDigitized = $DbResult.date_time_digitized
                }
                Basic = @{
                    BitsPerSample = $DbResult.bits_per_sample
                    Orientation = $DbResult.orientation
                    HorizontalResolution = $DbResult.x_resolution
                    VerticalResolution = $DbResult.y_resolution
                }
                Author = @{
                    Artist = $DbResult.artist
                    Copyright = $DbResult.copyright
                }
                Other = @{
                    Software = $DbResult.software
                    ColorSpace = $DbResult.color_space
                    ResolutionUnit = $DbResult.resolution_unit
                }
            }

            # Parse keywords from database
            $keywords = if ($DbResult.description_keywords) {
                try {
                    $keywordArray = $DbResult.description_keywords |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                    [string[]]$keywordArray
                } catch {
                    [string[]]@()
                }
            } else {
                [string[]]@()
            }

            # Build people hashtable with proper structure
            $peopleData = if ($DbResult.people_json) {
                try {
                    $peopleObj = $DbResult.people_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    @{
                        count = if ($peopleObj.PSObject.Properties['count']) {
                            $peopleObj.count
                        } else {
                            $DbResult.people_count
                        }
                        faces = if ($peopleObj.PSObject.Properties['faces']) {
                            $peopleObj.faces
                        } elseif ($DbResult.people_faces) {
                            try {
                                $DbResult.people_faces |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @()
                            }
                        } else {
                            @()
                        }
                        predictions = if ($peopleObj.PSObject.Properties['predictions']) {
                            $peopleObj.predictions
                        } else {
                            @()
                        }
                    }
                } catch {
                    @{
                        count = $DbResult.people_count
                        faces = if ($DbResult.people_faces) {
                            try {
                                $DbResult.people_faces |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @()
                            }
                        } else { @() }
                        predictions = @()
                    }
                }
            } else {
                @{
                    count = $DbResult.people_count
                    faces = @()
                    predictions = @()
                }
            }

            # Build description hashtable
            $descriptionData = if ($DbResult.description_json) {
                try {
                    $descObj = $DbResult.description_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    $desc = @{
                        has_explicit_content = [bool]$DbResult.has_explicit_content
                        has_nudity = [bool]$DbResult.has_nudity
                        picture_type = if ($DbResult.picture_type) { $DbResult.picture_type } else { '' }
                        overall_mood_of_image = if ($DbResult.overall_mood_of_image) { $DbResult.overall_mood_of_image } else { '' }
                        style_type = if ($DbResult.style_type) { $DbResult.style_type } else { '' }
                        keywords = if ($DbResult.description_keywords) {
                            try {
                                $DbResult.description_keywords |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @()
                            }
                        } else { @() }
                    }

                    # Add optional description content properties if available
                    if ($descObj.PSObject.Properties['description']) {
                        $desc['description'] = $descObj.description
                    }
                    if ($descObj.PSObject.Properties['short_description'] -or $DbResult.short_description) {
                        $desc['short_description'] = ($descObj.short_description ?? $DbResult.short_description)
                    }
                    if ($descObj.PSObject.Properties['long_description'] -or $DbResult.long_description) {
                        $desc['long_description'] = ($descObj.long_description ?? $DbResult.long_description)
                    }

                    $desc
                } catch {
                    @{
                        has_explicit_content = [bool]$DbResult.has_explicit_content
                        has_nudity = [bool]$DbResult.has_nudity
                        short_description = if ($DbResult.short_description) { $DbResult.short_description } else { '' }
                        long_description = if ($DbResult.long_description) { $DbResult.long_description } else { '' }
                        picture_type = if ($DbResult.picture_type) { $DbResult.picture_type } else { '' }
                        overall_mood_of_image = if ($DbResult.overall_mood_of_image) { $DbResult.overall_mood_of_image } else { '' }
                        style_type = if ($DbResult.style_type) { $DbResult.style_type } else { '' }
                        keywords = if ($DbResult.description_keywords) {
                            try {
                                $DbResult.description_keywords |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @()
                            }
                        } else { @() }
                    }
                }
            } else {
                @{
                    has_explicit_content = [bool]$DbResult.has_explicit_content
                    has_nudity = [bool]$DbResult.has_nudity
                    short_description = if ($DbResult.short_description) { $DbResult.short_description } else { '' }
                    long_description = if ($DbResult.long_description) { $DbResult.long_description } else { '' }
                    picture_type = if ($DbResult.picture_type) { $DbResult.picture_type } else { '' }
                    overall_mood_of_image = if ($DbResult.overall_mood_of_image) { $DbResult.overall_mood_of_image } else { '' }
                    style_type = if ($DbResult.style_type) { $DbResult.style_type } else { '' }
                    keywords = if ($DbResult.description_keywords) {
                        try {
                            $DbResult.description_keywords |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } catch {
                            @()
                        }
                    } else { @() }
                }
            }

            # Build scenes hashtable
            $scenesData = if ($DbResult.scenes_json) {
                try {
                    $scenesObj = $DbResult.scenes_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    @{
                        success = if ($scenesObj.PSObject.Properties['success']) {
                            $scenesObj.success
                        } else {
                            $true
                        }
                        scene = if ($scenesObj.PSObject.Properties['scene']) {
                            $scenesObj.scene
                        } else {
                            $DbResult.scene_label ?? 'unknown'
                        }
                        label = if ($scenesObj.PSObject.Properties['label']) {
                            $scenesObj.label
                        } else {
                            $DbResult.scene_label ?? $scenesObj.scene ?? 'unknown'
                        }
                        confidence = if ($scenesObj.PSObject.Properties['confidence']) {
                            $scenesObj.confidence
                        } else {
                            $DbResult.scene_confidence ?? 0.0
                        }
                        confidence_percentage = if ($scenesObj.PSObject.Properties['confidence_percentage']) {
                            $scenesObj.confidence_percentage
                        } elseif ($DbResult.scene_confidence_percentage) {
                            $DbResult.scene_confidence_percentage
                        } else {
                            ($DbResult.scene_confidence ?? 0.0) * 100
                        }
                        processed_at = if ($scenesObj.PSObject.Properties['processed_at']) {
                            $scenesObj.processed_at
                        } else {
                            $DbResult.scene_processed_at
                        }
                    }
                } catch {
                    @{
                        success = $true
                        scene = $DbResult.scene_label ?? 'unknown'
                        label = $DbResult.scene_label ?? 'unknown'
                        confidence = $DbResult.scene_confidence ?? 0.0
                        confidence_percentage = $DbResult.scene_confidence_percentage ?? (($DbResult.scene_confidence ?? 0.0) * 100)
                        processed_at = $DbResult.scene_processed_at
                    }
                }
            } else {
                @{
                    success = $true
                    scene = $DbResult.scene_label ?? 'unknown'
                    label = $DbResult.scene_label ?? 'unknown'
                    confidence = $DbResult.scene_confidence ?? 0.0
                    confidence_percentage = $DbResult.scene_confidence_percentage ?? (($DbResult.scene_confidence ?? 0.0) * 100)
                    processed_at = $DbResult.scene_processed_at
                }
            }

            # Build objects hashtable
            $objectsData = if ($DbResult.objects_json) {
                try {
                    $objectsObj = $DbResult.objects_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    @{
                        count = if ($objectsObj.PSObject.Properties['count']) {
                            $objectsObj.count
                        } else {
                            $DbResult.objects_count
                        }
                        objects = if ($objectsObj.PSObject.Properties['objects']) {
                            $objectsObj.objects
                        } elseif ($DbResult.objects_list) {
                            try {
                                $DbResult.objects_list |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @()
                            }
                        } else {
                            @()
                        }
                        object_counts = if ($objectsObj.PSObject.Properties['object_counts']) {
                            $objectsObj.object_counts
                        } elseif ($DbResult.object_counts) {
                            try {
                                $DbResult.object_counts |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @{}
                            }
                        } else {
                            @{}
                        }
                    }
                } catch {
                    @{
                        count = $DbResult.objects_count
                        objects = if ($DbResult.objects_list) {
                            try {
                                $DbResult.objects_list |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @()
                            }
                        } else { @() }
                        object_counts = if ($DbResult.object_counts) {
                            try {
                                $DbResult.object_counts |
                                    Microsoft.PowerShell.Utility\ConvertFrom-Json
                            } catch {
                                @{}
                            }
                        } else { @{} }
                    }
                }
            } else {
                @{
                    count = $DbResult.objects_count
                    objects = if ($DbResult.objects_list) {
                        try {
                            $DbResult.objects_list |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } catch {
                            @()
                        }
                    } else { @() }
                    object_counts = if ($DbResult.object_counts) {
                        try {
                            $DbResult.object_counts |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } catch {
                            @{}
                        }
                    } else { @{} }
                }
            }

            # Create efficient .NET ImageSearchResult object with cached properties (no file system calls)
            # $result = [GenXdev.Helpers.ImageSearchResult]::CreateWithCachedProperties(
            #     $imagePath,
            #     $DbResult.width,
            #     $DbResult.height,
            #     [System.Collections.Hashtable]$peopleData,
            #     [System.Collections.Hashtable]$objectsData,
            #     [System.Collections.Hashtable]$metadataObject,
            #     [System.Collections.Hashtable]$descriptionData,
            #     [System.Collections.Hashtable]$scenesData,
            #     $keywords,
            #     $null,  # fileSize - not available from database
            #     $null   # lastWriteTime - not available from database
            # )
            $result = @{
                Path              = $imagePath
                Width             = $DbResult.width
                Height            = $DbResult.height
                People            = $peopleData
                Objects           = $objectsData
                Metadata          = $metadataObject
                Description       = $descriptionData
                Scenes            = $scenesData
                Keywords          = $keywords
                FileSize          = $DbResult.file_size
                LastWriteTime     = $DbResult.last_write_time
            }

            # Apply proper type name and return formatted object
            # $psObject = [System.Management.Automation.PSObject]::AsPSObject($result)
            # $psObject.TypeNames.Insert(0, "GenXdev.Helpers.ImageSearchResult")
            return $result
        }

    # helper function to apply confidence filtering to image objects (matching Find-Image behavior)
    function Invoke-ConfidenceFiltering {
            param(
                [Parameter(Mandatory)]
                $ImageObject,
                [Parameter(Mandatory)]
                [double] $MinConfidenceRatio
            )

            $confidenceMatch = $null -ne $MinConfidenceRatio;

            # filter scenes by confidence - modify the scenes object directly
            if ($null -ne $confidenceMatch -and
                $null -ne $ImageObject.scenes -and
                $null -ne $ImageObject.scenes.confidence) {

                if ($ImageObject.scenes.confidence -ge $MinConfidenceRatio) {
                    $confidenceMatch = $true
                } else {
                    $confidenceMatch = $false
                    # filter out the scene data by setting it to default
                    $ImageObject.scenes = [PSCustomObject]@{
                        success = $false
                        scene = 'unknown'
                        label = 'unknown'
                        confidence = 0.0
                        confidence_percentage = 0.0
                        processed_at = $null
                    }
                }
            } else  { $confidenceMatch = $true }

            # filter people by confidence - remove people predictions below minimum threshold
            $confidenceMatch = $null -ne $MinConfidenceRatio;
            if ($null -ne $confidenceMatch -and
            $null -ne $ImageObject.people -and
            $null -ne $ImageObject.people.predictions -and
            $ImageObject.people.predictions.Count -gt 0) {

                $filteredPredictions = @()
                foreach ($prediction in $ImageObject.people.predictions) {
                    if ($null -ne $prediction.confidence -and $prediction.confidence -ge $MinConfidenceRatio) {
                        $filteredPredictions += $prediction
                        $confidenceMatch = $true
                    }
                }
                $ImageObject.people.predictions = $filteredPredictions
                $ImageObject.people.count = $filteredPredictions.Count

                # update faces array to match filtered predictions
                $ImageObject.people.faces = @($filteredPredictions | Microsoft.PowerShell.Core\ForEach-Object { $_.label })
            } else  { $confidenceMatch = $true }

            # filter objects by confidence - remove object predictions below minimum threshold
            $confidenceMatch = $null -ne $MinConfidenceRatio;
            if ($null -ne $confidenceMatch -and
                $null -ne $ImageObject.objects -and
                $null -ne $ImageObject.objects.objects -and
                $ImageObject.objects.objects.Count -gt 0) {

                $filteredObjects = @()
                $filteredCounts = @{}

                foreach ($obj in $ImageObject.objects.objects) {
                    if ($null -ne $obj.confidence -and $obj.confidence -ge $MinConfidenceRatio) {
                        $filteredObjects += $obj
                        $confidenceMatch = $true

                        # update object counts for filtered objects
                        if ($filteredCounts.ContainsKey($obj.label)) {
                            $filteredCounts[$obj.label]++
                        } else {
                            $filteredCounts[$obj.label] = 1
                        }
                    }
                }

                $ImageObject.objects.objects = $filteredObjects
                $ImageObject.objects.count = $filteredObjects.Count
                $ImageObject.objects.object_counts = $filteredCounts
            }

            # return whether any confidence match was found
            return $confidenceMatch
        }

        # determine database file path if not provided
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-ImageIndexPath' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # retrieve the database path
        $DatabaseFilePath = GenXdev.AI\Get-ImageIndexPath @params

        # validate database path exists
        if ($null -eq $DatabaseFilePath) {
            Microsoft.PowerShell.Utility\Write-Error (
                'Failed to retrieve database file path.'
            )
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using image database: $DatabaseFilePath"
        )

        function ConvertTo-SqliteLikePattern {
            param(
                [string]$Pattern,
                [switch]$ForceWildcards
            )
            $escaped = $Pattern

            # Add wildcards if requested and none exist
            if ($ForceWildcards -and ($escaped.IndexOfAny(@('*', '?')) -lt 0)) {
                $escaped = "*$escaped*"
            }

            # Escape literal square brackets first
            $escaped = $escaped.Replace('[', '[[]')

            # Escape literal percent signs
            $escaped = $escaped.Replace('%', '[%]')

            # Escape literal underscores
            $escaped = $escaped.Replace('_', '[_]')

            # Convert * to % for zero or more characters
            $escaped = $escaped.Replace('*', '%')

            # Convert ? to _ for exactly one character
            $escaped = $escaped.Replace('?', '_')

            return $escaped
        }

        # helper function to optimize search conditions and avoid table scans
        function Get-OptimizedSearchCondition {
            param(
                [string]$ColumnName,
                [string]$TableAlias,
                [string]$SearchTerm,
                [string]$ParamName,
                [hashtable]$Parameters,
                [switch]$ForceWildcards
            )

            # check if this is a wildcard pattern
            if ($SearchTerm.Contains('*') -or $SearchTerm.Contains('?')) {
                $pattern = ConvertTo-SqliteLikePattern `
                    -Pattern $SearchTerm `
                    -ForceWildcards:$ForceWildcards

                # optimize for patterns without leading wildcards
                if (-not $pattern.StartsWith('%')) {
                    # use prefix index for patterns like "cat*" -> "cat%"
                    $condition = (
                        "$TableAlias.$ColumnName LIKE @$ParamName COLLATE NOCASE"
                    )
                    $Parameters[$ParamName] = $pattern
                } else {
                    # fallback to case-insensitive like for leading wildcards
                    $condition = (
                        "$TableAlias.$ColumnName LIKE @$ParamName COLLATE NOCASE"
                    )
                    $Parameters[$ParamName] = $pattern
                }
            } else {
                # exact match - most efficient using exact indexes
                $condition = (
                    "$TableAlias.$ColumnName = @$ParamName COLLATE NOCASE"
                )
                $Parameters[$ParamName] = $SearchTerm
            }
            return $condition
        }

        # build the sql query with optimized joins and indexes
        $sqlQuery = 'SELECT DISTINCT i.* FROM Images i'
        $joinClauses = @()
        $whereClauses = @()
        $parameters = @{}
        $paramCounter = 0

        # add description search with optimized indexed lookup
        if ($DescriptionSearch -and $DescriptionSearch.Count -gt 0) {

            $descriptionConditions = @()

            # build conditions for each description search term
            foreach ($description in $DescriptionSearch) {
                $paramName = "Description$paramCounter"

                # search in short description field
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'short_description' `
                    -TableAlias 'i' `
                    -SearchTerm $description `
                    -ParamName $paramName `
                    -Parameters $parameters
                $descriptionConditions += $condition
                $paramCounter++

                $paramName = "Description$paramCounter"

                # search in long description field
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'long_description' `
                    -TableAlias 'i' `
                    -SearchTerm $description `
                    -ParamName $paramName `
                    -Parameters $parameters
                $descriptionConditions += $condition
                $paramCounter++
            }

            # combine description conditions with or logic
            $whereClauses += ('(' + ($descriptionConditions -join ' OR ') + ')')
        }

        # add keyword search with optimized indexed lookup
        if ($Keywords -and $Keywords.Count -gt 0) {
            $keywordConditions = @()

            # build conditions for each keyword search term
            foreach ($keyword in $Keywords) {
                $paramName = "keyword$paramCounter"

                # search using exists subquery for performance
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'keyword' `
                    -TableAlias 'ik' `
                    -SearchTerm $keyword `
                    -ParamName $paramName `
                    -Parameters $parameters
                $keywordConditions += $condition
                $paramCounter++
            }

            # add exists clause to avoid table scans
            $whereClauses += (
                '(EXISTS (SELECT * FROM ImageKeywords ik WHERE ' +
                'ik.image_id = i.id AND (' +
                ($keywordConditions -join ' OR ') + ')))'
            )
        }

        # add people search with optimized indexed lookup
        if ($People -and $People.Count -gt 0) {
            $peopleConditions = @()

            # build conditions for each person search term
            foreach ($person in $People) {
                $paramName = "person$paramCounter"

                # search using optimized condition for person names
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'person_name' `
                    -TableAlias 'ip' `
                    -SearchTerm $person `
                    -ParamName $paramName `
                    -Parameters $parameters
                $peopleConditions += $condition
                $paramCounter++
            }

            # add exists clause to avoid table scans
            $whereClauses += (
                '(EXISTS (SELECT * FROM ImagePeople ip WHERE ' +
                'ip.image_id = i.id AND (' +
                ($peopleConditions -join ' OR ') + ')))'
            )
        }

        # add objects search with optimized indexed lookup
        if ($Objects -and $Objects.Count -gt 0) {
            $objectConditions = @()

            # build conditions for each object search term
            foreach ($obj in $Objects) {
                $paramName = "object$paramCounter"

                # search using optimized condition for object names
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'object_name' `
                    -TableAlias 'io' `
                    -SearchTerm $obj `
                    -ParamName $paramName `
                    -Parameters $parameters
                $objectConditions += $condition
                $paramCounter++
            }

            # add exists clause to avoid table scans
            $whereClauses += (
                '(EXISTS (SELECT * FROM ImageObjects io WHERE ' +
                'io.image_id = i.id AND (' +
                ($objectConditions -join ' OR ') + ')))'
            )
        }

        # add scenes search with optimized indexed lookup
        if ($Scenes -and $Scenes.Count -gt 0) {
            $sceneConditions = @()

            # build conditions for each scene search term
            foreach ($scene in $Scenes) {
                $paramName = "scene$paramCounter"

                # search using optimized condition for scene names
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'scene_name' `
                    -TableAlias 'isc' `
                    -SearchTerm $scene `
                    -ParamName $paramName `
                    -Parameters $parameters
                $sceneConditions += $condition
                $paramCounter++
            }

            # add exists clause to avoid table scans
            $whereClauses += (
                '(EXISTS (SELECT * FROM ImageScenes isc WHERE ' +
                'isc.image_id = i.id AND (' +
                ($sceneConditions -join ' OR ') + ')))'
            )
        }

        # add picture type filter with optimized indexed column
        if ($PictureType -and $PictureType.Count -gt 0) {
            $pictureTypeConditions = @()

            # build conditions for each picture type
            foreach ($type in $PictureType) {
                $paramName = "pictype$paramCounter"

                # search using optimized condition for picture types
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'picture_type' `
                    -TableAlias 'i' `
                    -SearchTerm $type `
                    -ParamName $paramName `
                    -Parameters $parameters
                $pictureTypeConditions += $condition
                $paramCounter++
            }

            # combine picture type conditions with or logic
            $whereClauses += ('(' + ($pictureTypeConditions -join ' OR ') + ')')
        }

        # add style type filter with optimized indexed column
        if ($StyleType -and $StyleType.Count -gt 0) {
            $styleTypeConditions = @()

            # build conditions for each style type
            foreach ($style in $StyleType) {
                $paramName = "styletype$paramCounter"

                # search using optimized condition for style types
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'style_type' `
                    -TableAlias 'i' `
                    -SearchTerm $style `
                    -ParamName $paramName `
                    -Parameters $parameters
                $styleTypeConditions += $condition
                $paramCounter++
            }

            # combine style type conditions with or logic
            $whereClauses += ('(' + ($styleTypeConditions -join ' OR ') + ')')
        }

        # add mood filter with optimized indexed column
        if ($OverallMood -and $OverallMood.Count -gt 0) {
            $moodConditions = @()

            # build conditions for each mood
            foreach ($mood in $OverallMood) {
                $paramName = "mood$paramCounter"

                # search using optimized condition for moods
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'overall_mood_of_image' `
                    -TableAlias 'i' `
                    -SearchTerm $mood `
                    -ParamName $paramName `
                    -Parameters $parameters
                $moodConditions += $condition
                $paramCounter++
            }

            # combine mood conditions with or logic
            $whereClauses += ('(' + ($moodConditions -join ' OR ') + ')')
        }

        # add nudity filters with indexed boolean columns
        if ($HasNudity) {
            $whereClauses += 'i.has_nudity = 1'
        }

        # add no nudity filter
        if ($NoNudity) {
            $whereClauses += 'i.has_nudity = 0'
        }

        # add explicit content filters with indexed boolean columns
        if ($HasExplicitContent) {
            $whereClauses += 'i.has_explicit_content = 1'
        }

        # add no explicit content filter
        if ($NoExplicitContent) {
            $whereClauses += 'i.has_explicit_content = 0'
        }

        # add path-like search with optimized like lookup
        if ($PathLike -and $PathLike.Count -gt 0) {
            $pathLikeConditions = @()

            # process each path pattern
            foreach ($pathPattern in $PathLike) {
                $paramName = "pathlike$paramCounter"

                # convert file: urls to local paths if needed
                if ($pathPattern -like 'file:*') {
                    $localPath = $pathPattern.Substring(5)

                    # decode url encoding if present
                    $localPath = [System.Uri]::UnescapeDataString($localPath)
                } else {
                    $localPath = $pathPattern
                }

                # expand the path pattern
                $filter = GenXdev.FileSystem\Expand-Path $localPath

                # convert to sqlite like pattern
                $sqlitePattern = ConvertTo-SqliteLikePattern `
                    -Pattern $filter `
                    -ForceWildcards

                # add path condition
                $pathLikeConditions += "i.path LIKE @$paramName COLLATE NOCASE"
                $parameters[$paramName] = $sqlitePattern
                $paramCounter++
            }

            # combine path conditions with or logic
            $whereClauses += ('(' + ($pathLikeConditions -join ' OR ') + ')')
        }

        # add camera make filter
        if ($MetaCameraMake -and $MetaCameraMake.Count -gt 0) {
            $cameraMakeConditions = @()

            # build conditions for each camera make
            foreach ($make in $MetaCameraMake) {
                $paramName = "cameraMake$paramCounter"

                # search using optimized condition with wildcard support
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'camera_make' `
                    -TableAlias 'i' `
                    -SearchTerm $make `
                    -ParamName $paramName `
                    -Parameters $parameters `
                    -ForceWildcards
                $cameraMakeConditions += $condition
                $paramCounter++
            }

            # combine camera make conditions with or logic
            $whereClauses += ('(' + ($cameraMakeConditions -join ' OR ') + ')')
        }

        # add camera model filter
        if ($MetaCameraModel -and $MetaCameraModel.Count -gt 0) {
            $cameraModelConditions = @()

            # build conditions for each camera model
            foreach ($model in $MetaCameraModel) {
                $paramName = "cameraModel$paramCounter"

                # search using optimized condition with wildcard support
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName 'camera_model' `
                    -TableAlias 'i' `
                    -SearchTerm $model `
                    -ParamName $paramName `
                    -Parameters $parameters `
                    -ForceWildcards
                $cameraModelConditions += $condition
                $paramCounter++
            }

            # combine camera model conditions with or logic
            $whereClauses += ('(' + ($cameraModelConditions -join ' OR ') + ')')
        }

        # add gps latitude range filter
        if ($MetaGPSLatitude -and $MetaGPSLatitude.Count -gt 0) {
            if ($MetaGPSLatitude.Count -eq 1) {
                # apply exact match for single latitude value
                $paramName = "gpsLatitude$paramCounter"
                $whereClauses += "(i.gps_latitude IS NOT NULL AND i.gps_latitude = @$paramName)"
                $parameters[$paramName] = $MetaGPSLatitude[0]
                $paramCounter++
            } else {
                # apply range match for latitude values
                $minLat = [Math]::Min($MetaGPSLatitude[0], $MetaGPSLatitude[1])
                $maxLat = [Math]::Max($MetaGPSLatitude[0], $MetaGPSLatitude[1])

                $paramNameMin = "gpsLatitudeMin$paramCounter"
                $paramNameMax = "gpsLatitudeMax$paramCounter"

                $whereClauses += ("(i.gps_latitude IS NOT NULL AND i.gps_latitude BETWEEN @$paramNameMin " +
                    "AND @$paramNameMax)")
                $parameters[$paramNameMin] = $minLat
                $parameters[$paramNameMax] = $maxLat
                $paramCounter += 2
            }
        }

        # add gps longitude range filter
        if ($MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) {
            if ($MetaGPSLongitude.Count -eq 1) {
                # apply exact match for single longitude value
                $paramName = "gpsLongitude$paramCounter"
                $whereClauses += "(i.gps_longitude IS NOT NULL AND i.gps_longitude = @$paramName)"
                $parameters[$paramName] = $MetaGPSLongitude[0]
                $paramCounter++
            } else {
                # apply range match for longitude values
                $minLong = [Math]::Min($MetaGPSLongitude[0],
                    $MetaGPSLongitude[1])
                $maxLong = [Math]::Max($MetaGPSLongitude[0],
                    $MetaGPSLongitude[1])

                $paramNameMin = "gpsLongitudeMin$paramCounter"
                $paramNameMax = "gpsLongitudeMax$paramCounter"

                $whereClauses += ("(i.gps_longitude IS NOT NULL AND i.gps_longitude BETWEEN @$paramNameMin " +
                    "AND @$paramNameMax)")
                $parameters[$paramNameMin] = $minLong
                $parameters[$paramNameMax] = $maxLong
                $paramCounter += 2
            }
        }

        # add gps altitude range filter
        if ($MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0) {
            if ($MetaGPSAltitude.Count -eq 1) {
                # apply exact match for single altitude value
                $paramName = "gpsAltitude$paramCounter"
                $whereClauses += "(i.gps_altitude IS NOT NULL AND i.gps_altitude = @$paramName)"
                $parameters[$paramName] = $MetaGPSAltitude[0]
                $paramCounter++
            } else {
                # apply range match for altitude values
                $minAlt = [Math]::Min($MetaGPSAltitude[0], $MetaGPSAltitude[1])
                $maxAlt = [Math]::Max($MetaGPSAltitude[0], $MetaGPSAltitude[1])

                $paramNameMin = "gpsAltitudeMin$paramCounter"
                $paramNameMax = "gpsAltitudeMax$paramCounter"

                $whereClauses += ("(i.gps_altitude IS NOT NULL AND i.gps_altitude BETWEEN @$paramNameMin " +
                    "AND @$paramNameMax)")
                $parameters[$paramNameMin] = $minAlt
                $parameters[$paramNameMax] = $maxAlt
                $paramCounter += 2
            }
        }

        # Exposure Time range filter
        if ($MetaExposureTime -and $MetaExposureTime.Count -gt 0) {
            if ($MetaExposureTime.Count -eq 1) {
                # Exact match
                $paramName = "exposureTime$paramCounter"
                $whereClauses += "(i.exposure_time IS NOT NULL AND i.exposure_time = @$paramName)"
                $parameters[$paramName] = $MetaExposureTime[0]
                $paramCounter++
            } else {
                # Range match
                $minExp = [Math]::Min($MetaExposureTime[0], $MetaExposureTime[1])
                $maxExp = [Math]::Max($MetaExposureTime[0], $MetaExposureTime[1])

                $paramNameMin = "exposureTimeMin$paramCounter"
                $paramNameMax = "exposureTimeMax$paramCounter"

                $whereClauses += "(i.exposure_time IS NOT NULL AND i.exposure_time BETWEEN @$paramNameMin AND @$paramNameMax)"
                $parameters[$paramNameMin] = $minExp
                $parameters[$paramNameMax] = $maxExp
                $paramCounter += 2
            }
        }

        # F-Number (aperture) range filter
        if ($MetaFNumber -and $MetaFNumber.Count -gt 0) {
            if ($MetaFNumber.Count -eq 1) {
                # Exact match
                $paramName = "fNumber$paramCounter"
                $whereClauses += "(i.f_number IS NOT NULL AND i.f_number = @$paramName)"
                $parameters[$paramName] = $MetaFNumber[0]
                $paramCounter++
            } else {
                # Range match
                $minF = [Math]::Min($MetaFNumber[0], $MetaFNumber[1])
                $maxF = [Math]::Max($MetaFNumber[0], $MetaFNumber[1])

                $paramNameMin = "fNumberMin$paramCounter"
                $paramNameMax = "fNumberMax$paramCounter"

                $whereClauses += "(i.f_number IS NOT NULL AND i.f_number BETWEEN @$paramNameMin AND @$paramNameMax)"
                $parameters[$paramNameMin] = $minF
                $parameters[$paramNameMax] = $maxF
                $paramCounter += 2
            }
        }

        # ISO Speed range filter
        if ($MetaISO -and $MetaISO.Count -gt 0) {
            if ($MetaISO.Count -eq 1) {
                # Exact match
                $paramName = "iso$paramCounter"
                $whereClauses += "(i.iso_speed IS NOT NULL AND i.iso_speed = @$paramName)"
                $parameters[$paramName] = $MetaISO[0]
                $paramCounter++
            } else {
                # Range match
                $minISO = [Math]::Min($MetaISO[0], $MetaISO[1])
                $maxISO = [Math]::Max($MetaISO[0], $MetaISO[1])

                $paramNameMin = "isoMin$paramCounter"
                $paramNameMax = "isoMax$paramCounter"

                $whereClauses += "(i.iso_speed IS NOT NULL AND i.iso_speed BETWEEN @$paramNameMin AND @$paramNameMax)"
                $parameters[$paramNameMin] = $minISO
                $parameters[$paramNameMax] = $maxISO
                $paramCounter += 2
            }
        }

        # Focal Length range filter
        if ($MetaFocalLength -and $MetaFocalLength.Count -gt 0) {
            if ($MetaFocalLength.Count -eq 1) {
                # Exact match
                $paramName = "focalLength$paramCounter"
                $whereClauses += "(i.focal_length IS NOT NULL AND i.focal_length = @$paramName)"
                $parameters[$paramName] = $MetaFocalLength[0]
                $paramCounter++
            } else {
                # Range match
                $minFL = [Math]::Min($MetaFocalLength[0], $MetaFocalLength[1])
                $maxFL = [Math]::Max($MetaFocalLength[0], $MetaFocalLength[1])

                $paramNameMin = "focalLengthMin$paramCounter"
                $paramNameMax = "focalLengthMax$paramCounter"

                $whereClauses += "(i.focal_length IS NOT NULL AND i.focal_length BETWEEN @$paramNameMin AND @$paramNameMax)"
                $parameters[$paramNameMin] = $minFL
                $parameters[$paramNameMax] = $maxFL
                $paramCounter += 2
            }
        }

        # Image Width range filter
        if ($MetaWidth -and $MetaWidth.Count -gt 0) {
            if ($MetaWidth.Count -eq 1) {
                # Exact match
                $paramName = "width$paramCounter"
                $whereClauses += "i.width = @$paramName"
                $parameters[$paramName] = $MetaWidth[0]
                $paramCounter++
            } else {
                # Range match
                $minWidth = [Math]::Min($MetaWidth[0], $MetaWidth[1])
                $maxWidth = [Math]::Max($MetaWidth[0], $MetaWidth[1])

                $paramNameMin = "widthMin$paramCounter"
                $paramNameMax = "widthMax$paramCounter"

                $whereClauses += "i.width BETWEEN @$paramNameMin AND @$paramNameMax"
                $parameters[$paramNameMin] = $minWidth
                $parameters[$paramNameMax] = $maxWidth
                $paramCounter += 2
            }
        }

        # Image Height range filter
        if ($MetaHeight -and $MetaHeight.Count -gt 0) {
            if ($MetaHeight.Count -eq 1) {
                # Exact match
                $paramName = "height$paramCounter"
                $whereClauses += "i.height = @$paramName"
                $parameters[$paramName] = $MetaHeight[0]
                $paramCounter++
            } else {
                # Range match
                $minHeight = [Math]::Min($MetaHeight[0], $MetaHeight[1])
                $maxHeight = [Math]::Max($MetaHeight[0], $MetaHeight[1])

                $paramNameMin = "heightMin$paramCounter"
                $paramNameMax = "heightMax$paramCounter"

                $whereClauses += "i.height BETWEEN @$paramNameMin AND @$paramNameMax"
                $parameters[$paramNameMin] = $minHeight
                $parameters[$paramNameMax] = $maxHeight
                $paramCounter += 2
            }
        }

        # Date Taken range filter
        if ($MetaDateTaken -and $MetaDateTaken.Count -gt 0) {
            if ($MetaDateTaken.Count -eq 1) {
                # Match for single day - use date part only
                $dateTaken = $MetaDateTaken[0].Date
                $nextDay = $dateTaken.AddDays(1)

                $paramNameStart = "dateTakenStart$paramCounter"
                $paramNameEnd = "dateTakenEnd$paramCounter"

                $whereClauses += "(i.date_taken IS NOT NULL AND i.date_taken BETWEEN @$paramNameStart AND @$paramNameEnd)"
                $parameters[$paramNameStart] = $dateTaken.ToString('yyyy-MM-dd')
                $parameters[$paramNameEnd] = $nextDay.ToString('yyyy-MM-dd')
                $paramCounter += 2
            } else {
                # Range match
                $startDate = $MetaDateTaken[0]
                $endDate = $MetaDateTaken[1]

                # Ensure proper order
                if ($startDate -gt $endDate) {
                    $temp = $startDate
                    $startDate = $endDate
                    $endDate = $temp
                }

                # Include full end day by adding 1 day to end date
                $endDatePlusOneDay = $endDate.AddDays(1)

                $paramNameStart = "dateTakenStart$paramCounter"
                $paramNameEnd = "dateTakenEnd$paramCounter"

                $whereClauses += "(i.date_taken IS NOT NULL AND i.date_taken BETWEEN @$paramNameStart AND @$paramNameEnd)"
                $parameters[$paramNameStart] = $startDate.ToString('yyyy-MM-dd')
                $parameters[$paramNameEnd] = $endDatePlusOneDay.ToString('yyyy-MM-dd')
                $paramCounter += 2
            }
        }

        # Geo Location search with distance calculation
        if ($GeoLocation -and $GeoLocation.Count -eq 2) {
            $lat = $GeoLocation[0]
            $lon = $GeoLocation[1]
            $dist = $GeoDistanceInMeters / 1000 # Convert to kilometers for the calculation

            # Optimized SQL implementation of Haversine formula with spatial indexing support
            # This version uses trigonometric pre-calculations and index-friendly range filtering
            $latRad = $lat * [Math]::PI / 180
            $distKm = $dist / 1000  # Convert meters to kilometers

            # Pre-calculate latitude range for initial filtering
            $latRange = $distKm / 111.12  # 1 degree latitude ≈ 111.12 km
            $minLat = $lat - $latRange
            $maxLat = $lat + $latRange

            # Pre-calculate longitude range (adjusts for latitude)
            $lonRange = $distKm / (111.12 * [Math]::Cos($latRad))
            $minLon = $lon - $lonRange
            $maxLon = $lon + $lonRange

            # First filter by lat/lon ranges, then apply exact Haversine calculation
            $whereClauses += @"
(
    i.gps_latitude IS NOT NULL AND
    i.gps_longitude IS NOT NULL AND
    i.gps_latitude BETWEEN @minLat AND @maxLat AND
    i.gps_longitude BETWEEN @minLon AND @maxLon AND
    (6371.0 * 2 * asin(sqrt(
        power(sin((@geoLat - abs(i.gps_latitude)) * pi()/180/2), 2) +
        cos(@geoLat * pi()/180) * cos(abs(i.gps_latitude) * pi()/180) *
        power(sin((@geoLon - i.gps_longitude) * pi()/180/2), 2)
    ))) <= @geoMaxDist
)
"@
            # Add all parameters for the query
            $parameters["geoLat"] = $lat
            $parameters["geoLon"] = $lon
            $parameters["geoMaxDist"] = $distKm
            $parameters["minLat"] = $minLat
            $parameters["maxLat"] = $maxLat
            $parameters["minLon"] = $minLon
            $parameters["maxLon"] = $maxLon
        }

        # Handle -Any parameter: create OR conditions for all metadata types
        if ($null -ne $Any -and $Any.Length -gt 0) {
            # Add wildcards to any terms that don't already have them
            $processedAnyTerms = @($Any | Microsoft.PowerShell.Core\ForEach-Object {
                $entry = $_.Trim()
                if ($entry.IndexOfAny([char[]]@('*', '?')) -lt 0) {
                    "*$entry*"
                } else {
                    $_
                }
            })

            $anyConditions = @()

            # Build OR conditions for each Any term against all metadata types
            foreach ($anyTerm in $processedAnyTerms) {
                $termConditions = @()

                # Escape the term for SQL LIKE pattern
                $escapedTerm = $anyTerm -replace "'", "''" -replace '%', '\%' -replace '_', '\_'
                $likeTerm = $escapedTerm -replace '\*', '%' -replace '\?', '_'

                # File path condition (known to exist)
                $termConditions += "i.path LIKE '%$likeTerm%'"

                # Description search conditions (known to exist)
                $termConditions += "i.long_description LIKE '%$likeTerm%'"
                $termConditions += "i.short_description LIKE '%$likeTerm%'"

                # EXIF metadata conditions (known to exist)
                $termConditions += "i.picture_type LIKE '%$likeTerm%'"
                $termConditions += "i.style_type LIKE '%$likeTerm%'"
                $termConditions += "i.overall_mood_of_image LIKE '%$likeTerm%'"
                $termConditions += "i.has_nudity LIKE '%$likeTerm%'"
                $termConditions += "i.has_explicit_content LIKE '%$likeTerm%'"

                # Keyword conditions
                $termConditions += "EXISTS (SELECT 1 FROM ImageKeywords ik WHERE ik.image_id = i.id AND ik.keyword LIKE '%$likeTerm%')"

                # People conditions
                $termConditions += "EXISTS (SELECT 1 FROM ImagePeople ip WHERE ip.image_id = i.id AND ip.person_name LIKE '%$likeTerm%')"

                # Objects conditions
                $termConditions += "EXISTS (SELECT 1 FROM ImageObjects io WHERE io.image_id = i.id AND io.object_name LIKE '%$likeTerm%')"

                # Scenes conditions
                $termConditions += "EXISTS (SELECT 1 FROM ImageScenes isc WHERE isc.image_id = i.id AND isc.scene_name LIKE '%$likeTerm%')"

                # Combine all conditions for this term with OR
                $anyConditions += '(' + ($termConditions -join ' OR ') + ')'
            }

            # Add the Any clause to WHERE conditions (OR within Any terms, AND with other filters)
            if ($anyConditions.Count -gt 0) {
                $whereClauses += '(' + ($anyConditions -join ' OR ') + ')'
            }
        }

        # build the complete query with index optimization hints
        $sqlQuery = 'SELECT DISTINCT i.* FROM Images i'

        if ($joinClauses.Count -gt 0) {
            $sqlQuery += ' ' + ($joinClauses -join ' ')
        }
        if ($whereClauses.Count -gt 0) {
            # Combine main search clauses with OR (for descriptions, keywords, etc.)
            # But combine metadata filters with AND for precise filtering
            $sqlQuery += ' WHERE ' + ($whereClauses -join ' AND ')
        }

        # use indexed ordering for optimal performance
        $sqlQuery += ' ORDER BY i.path'

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Executing NO-TABLE-SCAN optimized SQL query: $sqlQuery"
        )
        Microsoft.PowerShell.Utility\Write-Verbose (
            "With parameters: $($parameters | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress)"
        )

        # execute the query with parameters
        $startTime = Microsoft.PowerShell.Utility\Get-Date

        # for ShowInBrowser we need to collect all results first, otherwise we stream them
        if ($ShowInBrowser) {

            $dbResults = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries $sqlQuery `
                -SqlParameters $parameters
            $queryTime = (Microsoft.PowerShell.Utility\Get-Date) - $startTime

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Index-optimized database query completed in ' +
                "$($queryTime.TotalMilliseconds)ms, found $($dbResults.Count) " +
                'results (no table scans)'
            )

            # convert database results to image objects compatible with Show-FoundImagesInBrowser
            foreach ($dbResult in $dbResults) {
                $imageObj = ConvertTo-ImageObject -DbResult $dbResult -EmbedImages:$EmbedImages

                # apply confidence filtering only if MinConfidenceRatio is explicitly specified
                $includeImage = -not $done."$(($imageObj.Path))";
                $done."$(($imageObj.Path))" = $true;

                if ($PSBoundParameters.ContainsKey('MinConfidenceRatio') -and $null -ne $MinConfidenceRatio) {
                    $confidenceMatch = Invoke-ConfidenceFiltering -ImageObject $imageObj -MinConfidenceRatio $MinConfidenceRatio
                    if (-not $confidenceMatch) {
                        $includeImage = $false
                    }
                }

                if ($includeImage) {
                    $Info.resultCount++

                    if ($null -eq $results) {
                        # initialize results collection if not already done
                        $results = [System.Collections.Generic.List[Object]]::new()
                    }

                    $null = $results.Add($imageObj)
                }
            }
        } else {
            # stream results for memory efficiency - process each record as it comes from the database
            $Info.resultCount = 0
            GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries $sqlQuery `
                -SqlParameters $parameters |
                Microsoft.PowerShell.Core\ForEach-Object {
                    $imageObj = ConvertTo-ImageObject -DbResult $_ -EmbedImages:$EmbedImages

                    # apply confidence filtering only if MinConfidenceRatio is explicitly specified
                    $includeImage = -not $done."$(($imageObj.Path))";
                    $done."$(($imageObj.Path))" = $true;

                    if ($PSBoundParameters.ContainsKey('MinConfidenceRatio') -and $null -ne $MinConfidenceRatio) {
                        $confidenceMatch = Invoke-ConfidenceFiltering -ImageObject $imageObj -MinConfidenceRatio $MinConfidenceRatio
                        if (-not $confidenceMatch) {
                            $includeImage = $false
                        }
                    }

                    if ($includeImage) {
                        # Add to results collection - don't convert here for performance
                        Microsoft.PowerShell.Utility\Write-Output $imageObj
                        $info.resultCount++
                    }
                }

            $queryTime = (Microsoft.PowerShell.Utility\Get-Date) - $startTime
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Index-optimized database query completed in ' +
                "$($queryTime.TotalMilliseconds)ms, streamed $($info.resultCount) " +
                'results (no table scans)'
            )
        }
    }

    ###############################################################################
    end {

        # handle input object processing from pipeline
        if (($null -ne $results -and $fromInput) -or ($filenames.Count -gt 0)) {

            # copy parameters for find-image call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Find-Image' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # pass results as input object
            $params.InputObject = $results

            # delegate to find-image for pipeline input processing
            GenXdev.AI\Find-Image @params

            return
        }

        # provide appropriate message if no results were found
        if ($Info.resultCount -eq 0) {
            $searchCriteria = [System.Collections.Generic.List[string]]::new()

            # collect search criteria for user feedback
            if ($Keywords -and $Keywords.Count -gt 0) {
                $searchCriteria.Add("keywords: $($Keywords -join ', ')")
            }
            if ($People -and $People.Count -gt 0) {
                $searchCriteria.Add("people: $($People -join ', ')")
            }
            if ($Objects -and $Objects.Count -gt 0) {
                $searchCriteria.Add("objects: $($Objects -join ', ')")
            }
            if ($Scenes -and $Scenes.Count -gt 0) {
                $searchCriteria.Add("scenes: $($Scenes -join ', ')")
            }
            if ($PictureType -and $PictureType.Count -gt 0) {
                $searchCriteria.Add("picture types: $($PictureType -join ', ')")
            }
            if ($StyleType -and $StyleType.Count -gt 0) {
                $searchCriteria.Add("style types: $($StyleType -join ', ')")
            }
            if ($OverallMood -and $OverallMood.Count -gt 0) {
                $searchCriteria.Add("overall moods: $($OverallMood -join ', ')")
            }
            if ($HasNudity) {
                $searchCriteria.Add('has nudity')
            }
            if ($NoNudity) {
                $searchCriteria.Add('no nudity')
            }
            if ($HasExplicitContent) {
                $searchCriteria.Add('has explicit content')
            }
            if ($NoExplicitContent) {
                $searchCriteria.Add('no explicit content')
            }
            if ($PathLike -and $PathLike.Count -gt 0) {
                $searchCriteria.Add("path-like: $($PathLike -join ', ')")
            }

            # add exif metadata search criteria to user feedback
            if ($MetaCameraMake -and $MetaCameraMake.Count -gt 0) {
                $searchCriteria.Add("camera make: $($MetaCameraMake -join ', ')")
            }
            if ($MetaCameraModel -and $MetaCameraModel.Count -gt 0) {
                $searchCriteria.Add("camera model: $($MetaCameraModel -join ', ')")
            }
            if ($MetaGPSLatitude -and $MetaGPSLatitude.Count -gt 0) {
                $searchCriteria.Add("GPS latitude: $($MetaGPSLatitude -join ' to ')")
            }
            if ($MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) {
                $searchCriteria.Add("GPS longitude: $($MetaGPSLongitude -join ' to ')")
            }
            if ($MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0) {
                $searchCriteria.Add("GPS altitude: $($MetaGPSAltitude -join ' to ')")
            }
            if ($MetaExposureTime -and $MetaExposureTime.Count -gt 0) {
                $searchCriteria.Add("exposure time: $($MetaExposureTime -join ' to ')")
            }
            if ($MetaFNumber -and $MetaFNumber.Count -gt 0) {
                $searchCriteria.Add("F-number: $($MetaFNumber -join ' to ')")
            }
            if ($MetaISO -and $MetaISO.Count -gt 0) {
                $searchCriteria.Add("ISO: $($MetaISO -join ' to ')")
            }
            if ($MetaFocalLength -and $MetaFocalLength.Count -gt 0) {
                $searchCriteria.Add("focal length: $($MetaFocalLength -join ' to ')")
            }
            if ($MetaWidth -and $MetaWidth.Count -gt 0) {
                $searchCriteria.Add("width: $($MetaWidth -join ' to ')")
            }
            if ($MetaHeight -and $MetaHeight.Count -gt 0) {
                $searchCriteria.Add("height: $($MetaHeight -join ' to ')")
            }
            if ($MetaDateTaken -and $MetaDateTaken.Count -gt 0) {
                $searchCriteria.Add("date taken: $($MetaDateTaken -join ' to ')")
            }
            if ($GeoLocation -and $GeoLocation.Count -eq 2) {
                $searchCriteria.Add(
                    "near location: $($GeoLocation[0]),$($GeoLocation[1]) " +
                    "within ${GeoDistanceInMeters}m"
                )
            }

            # display appropriate no results message
            if ($searchCriteria.Count -gt 0) {
                Microsoft.PowerShell.Utility\Write-Host (
                    'No images found matching search criteria: ' +
                    "$($searchCriteria -join ', ')"
                ) -ForegroundColor Yellow
            }
            else {
                Microsoft.PowerShell.Utility\Write-Host (
                    'No images found in database'
                ) -ForegroundColor Yellow
            }
        }

        # display results in browser gallery if requested
        if ($ShowInBrowser) {

            # set default title if not provided
            if ([String]::IsNullOrWhiteSpace($Title)) {
                $Title = '🚀 Fast Indexed Image Search Results'
            }

            # set default description with performance information
            if ([String]::IsNullOrWhiteSpace($Description)) {
                $searchInfo = 'Database search completed in ' +
                    "$($queryTime.TotalMilliseconds)ms | " +
                    "Found $($results.Count) images"
                $Description = "$($MyInvocation.Statement) | $searchInfo"
            }

            # copy all gallery-related parameters for browser display
            $galleryParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Show-FoundImagesInBrowser' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            );

            # pass results to gallery display function
            $galleryParams.InputObject = $results

            # show the results in browser gallery
            GenXdev.AI\Show-FoundImagesInBrowser @galleryParams

            # return results if passthru is requested - objects already properly formatted
            if ($PassThru) {
                Microsoft.PowerShell.Utility\Write-Output $results
            }
        }
    }
}
###############################################################################
