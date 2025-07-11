###############################################################################
<#
.SYNOPSIS
Searches for images using an optimized SQLite database with fast indexed lookups.

.DESCRIPTION
Performs high-performance image searches using a pre-built SQLite database with
optimized indexes. This function provides the same search capabilities as
Find-Image but with significantly faster performance by eliminating file system
scans and using database indexes for all search criteria.

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

.PARAMETER Title
Title for the image gallery.

.PARAMETER Description
Description for the image gallery.

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

.EXAMPLE
Find-IndexedImage -Keywords "cat","dog" -ShowInBrowser -NoNudity

.EXAMPLE
lii "cat","dog" -ShowInBrowser -NoNudity
#>
###############################################################################
function Find-IndexedImage {

    [CmdletBinding()]
    [OutputType([Object[]], [System.Collections.Generic.List[Object]], [string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', 'fromInput')]
    [Alias("findindexedimages", "lii")]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "Will match any of all the possible meta data types."
        )]
        [string[]] $Any = @(),
        ###############################################################################
        [Parameter(
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
            HelpMessage = ("Array of directory path-like search strings to " +
                        "filter images by path (SQL LIKE patterns, e.g. " +
                        "'%\\2024\\%')")
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
        [parameter(
            Mandatory = $false,
            HelpMessage = ("The directory containing face images organized by " +
                        "person folders. If not specified, uses the " +
                        "configured faces directory preference.")
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The description text to look for, wildcards allowed."
        )]
        [string[]] $DescriptionSearch = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The keywords to look for, wildcards allowed."
        )]
        [string[]] $Keywords = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "People to look for, wildcards allowed."
        )]
        [string[]] $People = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Objects to look for, wildcards allowed."
        )]
        [string[]] $Objects = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Scenes to look for, wildcards allowed."
        )]
        [string[]] $Scenes = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Picture types to filter by, wildcards allowed."
        )]
        [string[]] $PictureType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Style types to filter by, wildcards allowed."
        )]
        [string[]] $StyleType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Overall moods to filter by, wildcards allowed."
        )]
        [string[]] $OverallMood = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = ("Accepts search results from a previous -PassThru " +
                        "call to regenerate the view.")
        )]
        [System.Object[]] $InputObject,
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
            HelpMessage = "Filter images that contain nudity."
        )]
        [switch] $HasNudity,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Filter images that do NOT contain nudity."
        )]
        [switch] $NoNudity,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Filter images that contain explicit content."
        )]
        [switch] $HasExplicitContent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Filter images that do NOT contain explicit content."
        )]
        [switch] $NoExplicitContent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show results in a browser gallery."
        )]
        [Alias("show", "s")]
        [switch] $ShowInBrowser,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Return image data as objects."
        )]
        [switch] $PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Title for the image gallery."
        )]
        [string] $Title,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Description for the image gallery."
        )]
        [string] $Description,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Browser accept-language header."
        )]
        [string] $AcceptLang,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Monitor to use for display."
        )]
        [int] $Monitor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Initial width of browser window."
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Initial height of browser window."
        )]
        [int] $Height,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Initial X position of browser window."
        )]
        [int] $X,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Initial Y position of browser window."
        )]
        [int] $Y,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Show only pictures in a rounded rectangle, no " +
                        "text below.")
        )]
        [Alias("NoMetadata", "OnlyPictures")]
        [switch] $ShowOnlyPictures,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enable interactive browser features."
        )]
        [Alias("i", "editimages")]
        [switch] $Interactive,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in private/incognito mode."
        )]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Force enable debugging port."
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in Microsoft Edge."
        )]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in Google Chrome."
        )]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in Chromium-based browser."
        )]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in Firefox."
        )]
        [switch] $Firefox,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in all browsers."
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Open in fullscreen mode."
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on left side."
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on right side."
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on top."
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place window on bottom."
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Center the window."
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hide browser controls."
        )]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable browser extensions."
        )]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable popup blocker."
        )]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell focus."
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Create new browser window."
        )]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Only return HTML."
        )]
        [switch] $OnlyReturnHtml,
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
            HelpMessage = ("Clear alternative settings stored in session for " +
                        "AI preferences like Language, Image collections, etc")
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
            HelpMessage = ("Dont use alternative settings stored in session " +
                        "for AI preferences like Language, Image collections, " +
                        "etc")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ###############################################################################
    )

    ###############################################################################
    begin {

        # handle OnlyReturnHtml mode - forces ShowInBrowser with no interactivity
        if ($OnlyReturnHtml) {

            $Interactive = $false
            $ShowInBrowser = $true
        }

        # copy function parameters for ai meta language retrieval
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            )

        # determine the language for metadata retrieval
        $Language = GenXdev.AI\Get-AIMetaLanguage @params

        # initialize result tracking information
        $info = @{
            resultCount = 0
        }

        # create results collection for browser display mode
        [System.Collections.Generic.List[Object]] $results = @()

        # process 'any' parameter to spread across all search types
        if ($null -ne $Any -and
            $Any.Length -gt 0) {

            # add wildcards to any terms that don't already have them
            $Any = @($Any | Microsoft.PowerShell.Core\ForEach-Object {

                $entry = $_.Trim()

                if ($entry.IndexOfAny([char[]]@('*', '?')) -lt 0) {

                    "*$entry*"
                }
                else {
                    $_
                }
            })

            # distribute any terms across all search parameter types
            $DescriptionSearch = $null -ne $DescriptionSearch ?
                ($DescriptionSearch + $Any) :
                $Any

            $Keywords = $null -ne $Keywords ?
                ($Keywords + $Any) :
                $Any

            $People = $null -ne $People ?
                ($People + $Any) :
                $Any

            $Objects = $null -ne $Objects ?
                ($Objects + $Any) :
                $Any

            $Scenes = $null -ne $Scenes ?
                ($Scenes + $Any) :
                $Any

            $PictureType = $null -ne $PictureType ?
                ($PictureType + $Any) :
                $Any

            $StyleType = $null -ne $StyleType ?
                ($StyleType + $Any) :
                $Any

            $OverallMood = $null -ne $OverallMood ?
                ($OverallMood + $Any) :
                $Any
        }
        [System.Collections.Generic.List[Object]] $results = $null

        [bool] $fromInput = $false
    }
    ###############################################################################
    process {

        if ($null -ne $InputObject) {

            @($InputObject) | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {

                $item = $_ | GenXdev.Helpers\ConvertTo-HashTable

                if ($null -eq $results) {

                    # initialize results collection if not already done
                    $results = [System.Collections.Generic.List[Object]]::new()
                    $fromInput = $true
                }

                if ($item -is [System.Collections.IEnumerable] -and
                    (-not $InputObject.ContainsKey("Path"))) {

                        $item | Microsoft.PowerShell.Core\ForEach-Object {

                            $secondItem = $_ | GenXdev.Helpers\ConvertTo-HashTable
                            if ($secondItem.ContainsKey("Path")) {

                            $null = $results.Add($_)
                            $Info.resultCount++
                        }
                    }
                }
                else {

                    # add unique input objects to the results collection
                    $null = $results.Add($_)
                    $Info.resultCount++
                }
            }
        }

        # if we processed input objects, skip database search and use end block for processing
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

            # determine the path - convert to data URL if embedding is enabled and data exists
            $imagePath = $DbResult.path
            if (
                $EmbedImages -and $null -ne $DbResult.image_data -and
                $DbResult.image_data.Length -gt 0
            ) {
                try {
                    # determine MIME type from file extension
                    $extension = [System.IO.Path]::GetExtension($DbResult.path).ToLower()
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
                        "Converted embedded image to data URL: $($DbResult.path) -> " +
                        "$mimeType ($($DbResult.image_data.Length) bytes)"
                    )
                }
                catch {
                    # output warning if conversion fails
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Failed to convert embedded image data to base64 for: " +
                        "$($DbResult.path) - $($_.Exception.Message)"
                    )

                    # fallback to original path
                    $imagePath = $DbResult.path
                }
            }

            # return a custom object with all image metadata
            return [System.Collections.Hashtable]@{
                path = $imagePath
                keywords = if ($DbResult.description_keywords) {
                    $DbResult.description_keywords |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                } else { @() }
                people = if ($DbResult.people_json) {
                    $peopleObj = $DbResult.people_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # ensure predictions array is present
                    if (-not $peopleObj.PSObject.Properties['predictions']) {
                        $peopleObj | Microsoft.PowerShell.Utility\Add-Member `
                            -MemberType NoteProperty `
                            -Name predictions `
                            -Value @()
                    }
                    $peopleObj
                } else {
                    [PSCustomObject]@{
                        count = $DbResult.people_count
                        faces = if ($DbResult.people_faces) {
                            $DbResult.people_faces |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } else { @() }
                        predictions = @()
                    }
                }
                description = if ($DbResult.description_json) {
                    $DbResult.description_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                } else {
                    [PSCustomObject]@{
                        has_explicit_content = [bool]$DbResult.has_explicit_content
                        short_description = $DbResult.short_description
                        long_description = $DbResult.long_description
                        has_nudity = [bool]$DbResult.has_nudity
                        picture_type = $DbResult.picture_type
                        overall_mood_of_image = $DbResult.overall_mood_of_image
                        style_type = $DbResult.style_type
                        keywords = if ($DbResult.description_keywords) {
                            $DbResult.description_keywords |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } else { @() }
                    }
                }
                scenes = if ($DbResult.scenes_json) {
                    $DbResult.scenes_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                } else {
                    [PSCustomObject]@{
                        success = $true
                        scene = $DbResult.scene_label
                        processed_at = $DbResult.scene_processed_at
                        confidence = $DbResult.scene_confidence
                        label = $DbResult.scene_label
                        confidence_percentage = $DbResult.scene_confidence_percentage
                    }
                }
                objects = if ($DbResult.objects_json) {
                    $objectsObj = $DbResult.objects_json |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # ensure objects array is present
                    if (-not $objectsObj.PSObject.Properties['objects']) {
                        $objectsObj | Microsoft.PowerShell.Utility\Add-Member `
                            -MemberType NoteProperty `
                            -Name objects `
                            -Value @()
                    }
                    $objectsObj
                } else {
                    [PSCustomObject]@{
                        objects = if ($DbResult.objects_list) {
                            $DbResult.objects_list |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } else { @() }
                        object_counts = if ($DbResult.object_counts) {
                            $DbResult.object_counts |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json
                        } else { @{} }
                        count = $DbResult.objects_count
                    }
                }
            }
        }

        # determine database file path if not provided
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-ImageDatabasePath" `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            )

        $DatabaseFilePath = GenXdev.AI\Get-ImageDatabasePath @params

        if ($null -eq $DatabaseFilePath) {
            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to retrieve database file path."
            )
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using image database: $DatabaseFilePath"
        )

        # helper function to convert PowerShell wildcards to SQLite LIKE patterns
        function ConvertTo-SqliteLikePattern {
            param(
                [string]$Pattern,
                [switch]$ForceWildcards
            )
            $escaped = $Pattern
            if ($ForceWildcards -and ($escaped.indexOfAny(@('*', '?')) -lt 0)) {

                $escaped = "*$escaped*"
            }

            # escape literal square brackets first
            $escaped = $escaped.Replace('[', '[[]')

            # escape literal percent signs
            $escaped = $escaped.Replace('%', '[%]')

            # escape literal underscores
            $escaped = $escaped.Replace('_', '[_]')

            # * becomes % (zero or more chars)
            $escaped = $escaped.Replace('*', '%')

            # ? becomes _ (exactly one char)
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
                $pattern = ConvertTo-SqliteLikePattern -Pattern $SearchTerm -ForceWildcards:$ForceWildcards

                # optimize for patterns that start with known text (no leading wildcard)
                if (-not $pattern.StartsWith('%')) {
                    # use prefix index for patterns like "cat*" -> "cat%"
                    $condition = (
                        "$TableAlias.$ColumnName LIKE @$ParamName COLLATE NOCASE"
                    )
                    $Parameters[$ParamName] = $pattern
                } else {
                    # fallback to case-insensitive LIKE for patterns with leading wildcards
                    $condition = (
                        "$TableAlias.$ColumnName LIKE @$ParamName COLLATE NOCASE"
                    )
                    $Parameters[$ParamName] = $pattern
                }
            } else {
                # exact match - most efficient, uses exact indexes
                $condition = (
                    "$TableAlias.$ColumnName = @$ParamName COLLATE NOCASE"
                )
                $Parameters[$ParamName] = $SearchTerm
            }
            return $condition
        }

        # build the SQL query with optimized joins and indexes
        $sqlQuery = "SELECT DISTINCT i.* FROM Images i"
        $joinClauses = @()
        $whereClauses = @()
        $parameters = @{}
        $paramCounter = 0

        # add description search with optimized indexed lookup (NO TABLE SCANS)
        if ($DescriptionSearch -and $DescriptionSearch.Count -gt 0) {

            $descriptionConditions = @()
            foreach ($description in $DescriptionSearch) {
                $paramName = "Description$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "short_description" `
                    -TableAlias "i" `
                    -SearchTerm $description `
                    -ParamName $paramName `
                    -Parameters $parameters
                $descriptionConditions += $condition
                $paramCounter++
                $paramName = "Description$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "long_description" `
                    -TableAlias "i" `
                    -SearchTerm $description `
                    -ParamName $paramName `
                    -Parameters $parameters
                $descriptionConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(" + ($descriptionConditions -join " OR ") + ")")
        }

        # add keyword search with optimized indexed lookup (NO TABLE SCANS)
        if ($Keywords -and $Keywords.Count -gt 0) {
            $keywordConditions = @()
            foreach ($keyword in $Keywords) {
                $paramName = "keyword$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "keyword" `
                    -TableAlias "ik" `
                    -SearchTerm $keyword `
                    -ParamName $paramName `
                    -Parameters $parameters
                $keywordConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(EXISTS (SELECT * FROM ImageKeywords ik WHERE ik.image_id = i.id AND (" +
                ($keywordConditions -join " OR ") + ")))")
        }

        # add people search with optimized indexed lookup (NO TABLE SCANS)
        if ($People -and $People.Count -gt 0) {
            $peopleConditions = @()
            foreach ($person in $People) {
                $paramName = "person$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "person_name" `
                    -TableAlias "ip" `
                    -SearchTerm $person `
                    -ParamName $paramName `
                    -Parameters $parameters
                $peopleConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(EXISTS (SELECT * FROM ImagePeople ip WHERE ip.image_id = i.id AND (" +
                ($peopleConditions -join " OR ") + ")))")
        }

        # add objects search with optimized indexed lookup (NO TABLE SCANS)
        if ($Objects -and $Objects.Count -gt 0) {
            $objectConditions = @()
            foreach ($obj in $Objects) {
                $paramName = "object$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "object_name" `
                    -TableAlias "io" `
                    -SearchTerm $obj `
                    -ParamName $paramName `
                    -Parameters $parameters
                $objectConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(EXISTS (SELECT * FROM ImageObjects io WHERE io.image_id = i.id AND (" +
                ($objectConditions -join " OR ") + ")))")
        }

        # add scenes search with optimized indexed lookup (NO TABLE SCANS)
        if ($Scenes -and $Scenes.Count -gt 0) {
            $sceneConditions = @()
            foreach ($scene in $Scenes) {
                $paramName = "scene$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "scene_name" `
                    -TableAlias "isc" `
                    -SearchTerm $scene `
                    -ParamName $paramName `
                    -Parameters $parameters
                $sceneConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(EXISTS (SELECT * FROM ImageScenes isc WHERE isc.image_id = i.id AND (" +
                ($sceneConditions -join " OR ") + ")))")
        }

        # add picture type filter with optimized indexed column (NO TABLE SCANS)
        if ($PictureType -and $PictureType.Count -gt 0) {
            $pictureTypeConditions = @()
            foreach ($type in $PictureType) {
                $paramName = "pictype$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "picture_type" `
                    -TableAlias "i" `
                    -SearchTerm $type `
                    -ParamName $paramName `
                    -Parameters $parameters
                $pictureTypeConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(" + ($pictureTypeConditions -join " OR ") + ")")
        }

        # add style type filter with optimized indexed column (NO TABLE SCANS)
        if ($StyleType -and $StyleType.Count -gt 0) {
            $styleTypeConditions = @()
            foreach ($style in $StyleType) {
                $paramName = "styletype$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "style_type" `
                    -TableAlias "i" `
                    -SearchTerm $style `
                    -ParamName $paramName `
                    -Parameters $parameters
                $styleTypeConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(" + ($styleTypeConditions -join " OR ") + ")")
        }

        # add mood filter with optimized indexed column (NO TABLE SCANS)
        if ($OverallMood -and $OverallMood.Count -gt 0) {
            $moodConditions = @()
            foreach ($mood in $OverallMood) {
                $paramName = "mood$paramCounter"
                $condition = Get-OptimizedSearchCondition `
                    -ColumnName "overall_mood_of_image" `
                    -TableAlias "i" `
                    -SearchTerm $mood `
                    -ParamName $paramName `
                    -Parameters $parameters
                $moodConditions += $condition
                $paramCounter++
            }
            $whereClauses += ("(" + ($moodConditions -join " OR ") + ")")
        }

        # add nudity filters with indexed boolean columns
        if ($HasNudity) {
            $whereClauses += "i.has_nudity = 1"
        }
        if ($NoNudity) {
            $whereClauses += "i.has_nudity = 0"
        }

        # add explicit content filters with indexed boolean columns
        if ($HasExplicitContent) {
            $whereClauses += "i.has_explicit_content = 1"
        }
        if ($NoExplicitContent) {
            $whereClauses += "i.has_explicit_content = 0"
        }

        # add path-like search with optimized LIKE lookup (NO TABLE SCANS)
        if ($PathLike -and $PathLike.Count -gt 0) {
            $pathLikeConditions = @()
            foreach ($pathPattern in $PathLike) {
                $paramName = "pathlike$paramCounter"

                # convert file: URLs to local paths if needed
                if ($pathPattern -like 'file:*') {
                    $localPath = $pathPattern.Substring(5)

                    # decode URL encoding if present
                    $localPath = [System.Uri]::UnescapeDataString($localPath)
                } else {
                    $localPath = $pathPattern
                }

                $filter = GenXdev.FileSystem\Expand-Path $localPath
                $sqlitePattern = ConvertTo-SqliteLikePattern -Pattern $filter -ForceWildcards
                $pathLikeConditions += "i.path LIKE @$paramName COLLATE NOCASE"
                $parameters[$paramName] = $sqlitePattern
                $paramCounter++
            }

            $whereClauses += ("(" + ($pathLikeConditions -join " OR ") + ")")
        }

        # build the complete query with index optimization hints
        $sqlQuery = "SELECT DISTINCT i.* FROM Images i"

        if ($joinClauses.Count -gt 0) {
            $sqlQuery += " " + ($joinClauses -join " ")
        }
        if ($whereClauses.Count -gt 0) {
            $sqlQuery += " WHERE " + ($whereClauses -join " OR ")
        }

        # use indexed ordering for optimal performance
        $sqlQuery += " ORDER BY i.path"

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
                "Index-optimized database query completed in " +
                "$($queryTime.TotalMilliseconds)ms, found $($dbResults.Count) " +
                "results (no table scans)"
            )

            # convert database results to image objects compatible with Show-FoundImagesInBrowser
            foreach ($dbResult in $dbResults) {
                $imageObj = ConvertTo-ImageObject -DbResult $dbResult -EmbedImages:$EmbedImages
                $Info.resultCount++

                if ($null -eq $results) {

                    # initialize results collection if not already done
                    $results = [System.Collections.Generic.List[Object]]::new()
                }

                $null = $results.Add($imageObj)
            }
        } else {
            # stream results for memory efficiency - process each record as it comes from the database
            $Info.resultCount = 0
            GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries $sqlQuery `
                -SqlParameters $parameters |
                Microsoft.PowerShell.Core\ForEach-Object {
                    $Info.resultCount++
                    $imageObj = ConvertTo-ImageObject -DbResult $_ -EmbedImages:$EmbedImages
                    Microsoft.PowerShell.Utility\Write-Output $imageObj
                    $info.resultCount++
                }

            $queryTime = (Microsoft.PowerShell.Utility\Get-Date) - $startTime
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Index-optimized database query completed in " +
                "$($queryTime.TotalMilliseconds)ms, streamed $resultCount " +
                "results (no table scans)"
            )
        }
    }

    ###############################################################################
    end {
        # handle input object processing from pipeline
        # $fromInput is set to true in process block when InputObject is provided
        if ($null -ne $results -and $fromInput) {

            # copy parameters for find-image call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Find-Image" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
                )

            $params.InputObject = $results
            # if InputObject is provided, convert each item to an image object
            GenXdev.AI\Find-Image @params

            return
        }
        # this end block only executes for ShowInBrowser mode since streaming mode exits early

        # provide appropriate message if no results were found in streaming mode
        if ($Info.resultCount -eq 0) {
            $searchCriteria = [System.Collections.Generic.List[string]]::new()
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
                $searchCriteria.Add("has nudity")
            }
            if ($NoNudity) {
                $searchCriteria.Add("no nudity")
            }
            if ($HasExplicitContent) {
                $searchCriteria.Add("has explicit content")
            }
            if ($NoExplicitContent) {
                $searchCriteria.Add("no explicit content")
            }
            if ($PathLike -and $PathLike.Count -gt 0) {
                $searchCriteria.Add("path-like: $($PathLike -join ', ')")
            }

            if ($searchCriteria.Count -gt 0) {
                Microsoft.PowerShell.Utility\Write-Host (
                    "No images found matching search criteria: " +
                    "$($searchCriteria -join ', ')"
                ) -ForegroundColor Yellow
            }
            else {
                Microsoft.PowerShell.Utility\Write-Host (
                    "No images found in database"
                ) -ForegroundColor Yellow
            }
        }

        # if ShowInBrowser is requested, display the gallery
        if ($ShowInBrowser) {

            if ([String]::IsNullOrWhiteSpace($Title)) {
                $Title = "🚀 Fast Indexed Image Search Results"
            }

            if ([String]::IsNullOrWhiteSpace($Description)) {
                $searchInfo = "Database search completed in " +
                    "$($queryTime.TotalMilliseconds)ms | Found $($results.Count) images"
                $Description = "$($MyInvocation.Statement) | $searchInfo"
            }

            # copy all the gallery-related parameters
            $galleryParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Show-FoundImagesInBrowser" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            );

            $galleryParams.InputObject = $results

            # pass the results to Show-FoundImagesInBrowser
            GenXdev.AI\Show-FoundImagesInBrowser @galleryParams

            if ($PassThru) {

                $results | Microsoft.PowerShell.Core\ForEach-Object {

                    Microsoft.PowerShell.Utility\Write-Output $_
                }
            }
        }
    }
}
###############################################################################
