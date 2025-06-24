################################################################################
<#
.SYNOPSIS
Scans image files for keywords and descriptions using metadata files.

.DESCRIPTION
Searches for image files (jpg, jpeg, png) in the specified directory and its
subdirectories. For each image, checks associated description.json,
keywords.json, people.json, and objects.json files for metadata. Can filter
images based on keyword matches, people recognition, and object detection, then
return the results as objects. Use -ShowImageGallery to display results in a
browser-based masonry layout.

The function searches through image directories and examines alternate data
streams containing metadata in JSON format. It can match keywords using wildcard
patterns, filter for specific people, and search for detected objects. By
default, returns image data objects. Use -ShowImageGallery to display in a web
browser.

.PARAMETER Keywords
Array of keywords to search for in image metadata. Supports wildcards. If empty,
returns all images with any metadata. Keywords are matched against both the
description content and keywords arrays in metadata files.

.PARAMETER People
Array of people names to search for in image metadata. Supports wildcards. Used
to filter images based on face recognition metadata stored in people.json files.

.PARAMETER Objects
Array of object names to search for in image metadata. Supports wildcards. Used
to filter images based on object detection metadata stored in objects.json files.

.PARAMETER Scenes
Array of scene categories to search for in image metadata. Supports wildcards.
Used to filter images based on scene classification metadata stored in
scenes.json files.

.PARAMETER ImageDirectories
Array of directory paths to search for images. Each directory is searched
recursively for jpg, jpeg, and png files. Relative paths are converted to
absolute paths automatically.

.PARAMETER InputObject
Accepts search results from a previous -PassThru call to regenerate the view.

.PARAMETER PictureType
Array of picture types to filter by (e.g., 'daylight', 'evening', 'indoor',
'outdoor'). Supports wildcards. Matches against the picture_type property in
description metadata.

.PARAMETER StyleType
Array of style types to filter by (e.g., 'casual', 'formal'). Supports
wildcards. Matches against the style_type property in description metadata.

.PARAMETER OverallMood
Array of overall moods to filter by (e.g., 'calm', 'cheerful', 'sad',
'energetic'). Supports wildcards. Matches against the overall_mood_of_image
property in description metadata.

.PARAMETER Title
The title to display at the top of the image gallery.

.PARAMETER Description
The description text to display in the image gallery.

.PARAMETER Language
The language for retrieving descriptions and keywords. Will try to find metadata
in the specified language first, then fall back to English if not available.
This allows you to have metadata in multiple languages for the same images.

.PARAMETER AcceptLang
Set the browser accept-lang http header.

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary
monitor, defaults to Global:DefaultSecondaryMonitor or 2 if not found.

.PARAMETER Width
The initial width of the webbrowser window.

.PARAMETER Height
The initial height of the webbrowser window.

.PARAMETER X
The initial X position of the webbrowser window.

.PARAMETER Y
The initial Y position of the webbrowser window.

.PARAMETER HasNudity
Switch to filter for images that contain nudity. Only returns images where the
has_nudity property is true in the metadata.

.PARAMETER NoNudity
Switch to filter for images that do NOT contain nudity. Only returns images
where the has_nudity property is false in the metadata.

.PARAMETER HasExplicitContent
Switch to filter for images that contain explicit content. Only returns images
where the has_explicit_content property is true in the metadata.

.PARAMETER NoExplicitContent
Switch to filter for images that do NOT contain explicit content. Only returns
images where the has_explicit_content property is false in the metadata.

.PARAMETER ShowImageGallery
Switch to display the search results in a browser-based masonry layout gallery.
When used, the results are shown in an interactive web view. Can be combined
with -PassThru to also return the objects.

.PARAMETER PassThru
Switch to return image data as objects. When used with -ShowImageGallery, both
displays the gallery and returns the objects. When used alone with
-ShowImageGallery, only displays the gallery without returning objects.

.PARAMETER Interactive
Connects to browser and adds additional buttons like Edit and Delete.

.PARAMETER Private
Opens in incognito/private browsing mode.

.PARAMETER Force
Force enable debugging port, stopping existing browsers if needed.

.PARAMETER Edge
Opens in Microsoft Edge.

.PARAMETER Chrome
Opens in Google Chrome.

.PARAMETER Chromium
Opens in Microsoft Edge or Google Chrome, depending on what the default browser
is.

.PARAMETER Firefox
Opens in Firefox.

.PARAMETER All
Opens in all registered modern browsers.

.PARAMETER FullScreen
Opens in fullscreen mode.

.PARAMETER Left
Place browser window on the left side of the screen.

.PARAMETER Right
Place browser window on the right side of the screen.

.PARAMETER Top
Place browser window on the top side of the screen.

.PARAMETER Bottom
Place browser window on the bottom side of the screen.

.PARAMETER Centered
Place browser window in the center of the screen.

.PARAMETER ApplicationMode
Hide the browser controls.

.PARAMETER NoBrowserExtensions
Prevent loading of browser extensions.

.PARAMETER DisablePopupBlocker
Disable the popup blocker.

.PARAMETER RestoreFocus
Restore PowerShell window focus.

.PARAMETER NewWindow
Don't re-use existing browser window, instead, create a new one.

.PARAMETER OnlyReturnHtml
Only return the generated HTML instead of displaying it in a browser.

.PARAMETER EmbedImages
Switch to embed images as base64 data URLs instead of file:// URLs. This makes
the generated HTML file completely self-contained and portable, but results in
larger file sizes. Useful when the HTML needs to be shared or viewed on
different systems where the original image files may not be accessible.

.EXAMPLE
Find-Image -Keywords "cat","dog" -ImageDirectories "C:\Photos"
Searches for images containing 'cat' or 'dog' keywords and returns the image objects.

.EXAMPLE
findimages cat,dog "C:\Photos"
Same as above using the alias and positional parameters.

.EXAMPLE
Find-Image -People "John","Jane" -ImageDirectories "C:\Family" -ShowImageGallery
Searches for photos containing John or Jane and displays them in a web gallery.

.EXAMPLE
Find-Image -Objects "car","bicycle" -ImageDirectories "C:\Photos" -ShowImageGallery -PassThru
Searches for images containing detected cars or bicycles, displays them in a gallery, and also returns the objects.

.EXAMPLE
findimages -Language "Spanish" -Keywords "playa","sol" -ImageDirectories "C:\Vacations" -ShowImageGallery
Searches for images with Spanish metadata containing the keywords "playa" (beach) or "sol" (sun) and displays in gallery.

.EXAMPLE
Find-Image -Keywords "vacation" -People "John" -Objects "beach*" -ImageDirectories "C:\Photos"
Searches for vacation photos with John in them that also contain beach-related objects and returns the data objects.

.EXAMPLE
Find-Image -Scenes "beach","forest","mountain*" -ImageDirectories "C:\Nature" -ShowImageGallery
Searches for images classified as beach, forest, or mountain scenes and displays them in a gallery.

.EXAMPLE
Find-Image -NoNudity -NoExplicitContent -ImageDirectories "C:\Family" -ShowImageGallery
Searches for family-safe images (no nudity or explicit content) and displays them in a gallery.

.EXAMPLE
Find-Image -PictureType "daylight" -OverallMood "calm" -ImageDirectories "C:\Photos"
Searches for daylight photos with a calm/peaceful mood and returns the image objects.

.EXAMPLE
findimages -StyleType "casual" -HasNudity -ImageDirectories "C:\Art"
Searches for casual style images that contain nudity and returns the data objects.
#>
###############################################################################
function Find-Image {

    [CmdletBinding()]
    [OutputType([Object[]], [System.Collections.Generic.List[Object]], [string])]
    [Alias("findimages", "li")]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The keywords to look for, wildcards allowed."
        )]
        [string[]] $Keywords = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "People to look for, wildcards allowed."
        )]
        [string[]] $People = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Objects to look for, wildcards allowed."
        )]
        [string[]] $Objects = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Scene categories to look for, wildcards allowed."
        )]
        [string[]] $Scenes = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "The image directory paths to search."
        )]
        [Alias("ImageDirectory")]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = ("Accepts search results from a previous -PassThru " +
                "call to regenerate the view.")
        )]
        [object[]] $InputObject,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Picture type to filter by (e.g., 'daylight', " +
                "'evening', 'indoor', etc). Supports wildcards.")
        )]
        [string[]] $PictureType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Style type to filter by (e.g., 'casual', 'formal', " +
                "etc). Supports wildcards.")
        )]
        [string[]] $StyleType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Overall mood to filter by (e.g., 'calm', 'cheerful', " +
                "'sad', etc). Supports wildcards.")
        )]
        [string[]] $OverallMood = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Title for the gallery"
        )]
        [string] $Title = "Photo Gallery",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Description for the gallery"
        )]
        [string] $Description = ("Hover over images to see face recognition " +
            "and object detection data"),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The language for retrieving descriptions and keywords."
        )]
        [PSDefaultValue(Value = "English")]
        [ValidateSet(
            "Afrikaans",
            "Akan",
            "Albanian",
            "Amharic",
            "Arabic",
            "Armenian",
            "Azerbaijani",
            "Basque",
            "Belarusian",
            "Bemba",
            "Bengali",
            "Bihari",
            "Bosnian",
            "Breton",
            "Bulgarian",
            "Cambodian",
            "Catalan",
            "Cherokee",
            "Chichewa",
            "Chinese (Simplified)",
            "Chinese (Traditional)",
            "Corsican",
            "Croatian",
            "Czech",
            "Danish",
            "Dutch",
            "English",
            "Esperanto",
            "Estonian",
            "Ewe",
            "Faroese",
            "Filipino",
            "Finnish",
            "French",
            "Frisian",
            "Ga",
            "Galician",
            "Georgian",
            "German",
            "Greek",
            "Guarani",
            "Gujarati",
            "Haitian Creole",
            "Hausa",
            "Hawaiian",
            "Hebrew",
            "Hindi",
            "Hungarian",
            "Icelandic",
            "Igbo",
            "Indonesian",
            "Interlingua",
            "Irish",
            "Italian",
            "Japanese",
            "Javanese",
            "Kannada",
            "Kazakh",
            "Kinyarwanda",
            "Kirundi",
            "Kongo",
            "Korean",
            "Krio (Sierra Leone)",
            "Kurdish",
            "Kurdish (Soranî)",
            "Kyrgyz",
            "Laothian",
            "Latin",
            "Latvian",
            "Lingala",
            "Lithuanian",
            "Lozi",
            "Luganda",
            "Luo",
            "Macedonian",
            "Malagasy",
            "Malay",
            "Malayalam",
            "Maltese",
            "Maori",
            "Marathi",
            "Mauritian Creole",
            "Moldavian",
            "Mongolian",
            "Montenegrin",
            "Nepali",
            "Nigerian Pidgin",
            "Northern Sotho",
            "Norwegian",
            "Norwegian (Nynorsk)",
            "Occitan",
            "Oriya",
            "Oromo",
            "Pashto",
            "Persian",
            "Polish",
            "Portuguese (Brazil)",
            "Portuguese (Portugal)",
            "Punjabi",
            "Quechua",
            "Romanian",
            "Romansh",
            "Runyakitara",
            "Russian",
            "Scots Gaelic",
            "Serbian",
            "Serbo-Croatian",
            "Sesotho",
            "Setswana",
            "Seychellois Creole",
            "Shona",
            "Sindhi",
            "Sinhalese",
            "Slovak",
            "Slovenian",
            "Somali",
            "Spanish",
            "Spanish (Latin American)",
            "Sundanese",
            "Swahili",
            "Swedish",
            "Tajik",
            "Tamil",
            "Tatar",
            "Telugu",
            "Thai",
            "Tigrinya",
            "Tonga",
            "Tshiluba",
            "Tumbuka",
            "Turkish",
            "Turkmen",
            "Twi",
            "Uighur",
            "Ukrainian",
            "Urdu",
            "Uzbek",
            "Vietnamese",
            "Welsh",
            "Wolof",
            "Xhosa",
            "Yiddish",
            "Yoruba",
            "Zulu")]
        [string] $Language,
        ###############################################################################
        [Alias("lang", "locale")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [string] $AcceptLang = $null,
        ###############################################################################
        [Alias("m", "mon")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The monitor to use, 0 = default, -1 is discard, " +
                "-2 = Configured secondary monitor, defaults to " +
                "`Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,
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
            HelpMessage = ("Display the search results in a browser-based " +
                "image gallery.")
        )]
        [switch] $ShowImageGallery,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Return image data as objects. When used with " +
                "-ShowImageGallery, both displays the gallery and returns " +
                "the objects.")
        )]
        [switch] $PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Will connect to browser and adds additional buttons " +
                "like Edit and Delete. Only effective when used with " +
                "-ShowImageGallery.")
        )]
        [switch] $Interactive,
        ###############################################################################
        [Alias("incognito", "inprivate")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito/private browsing mode"
        )]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Force enable debugging port, stopping existing " +
                "browsers if needed")
        )]
        [switch] $Force,
        ###############################################################################
        [Alias("e")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge"
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias("ch")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Google Chrome"
        )]
        [switch] $Chrome,
        ###############################################################################
        [Alias("c")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Opens in Microsoft Edge or Google Chrome, depending " +
                "on what the default browser is")
        )]
        [switch] $Chromium,
        ###############################################################################
        [Alias("ff")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Firefox"
        )]
        [switch] $Firefox,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in all registered modern browsers"
        )]
        [switch] $All,
        ###############################################################################
        [Alias("fs", "f")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window in the center of the screen"
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias("a", "app", "appmode")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hide the browser controls"
        )]
        [switch] $ApplicationMode,
        ###############################################################################
        [Alias("de", "ne", "NoExtensions")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Prevent loading of browser extensions"
        )]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Alias("allowpopups")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable the popup blocker"
        )]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Alias("bg")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias("nw", "new")]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                "create a new one")
        )]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only return the generated HTML instead of " +
                "displaying it in a browser.")
        )]
        [switch] $OnlyReturnHtml,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Embed images as base64 data URLs instead of " +
                "file:// URLs for better portability.")
        )]
        [switch] $EmbedImages
    )

    begin {

        # enable interactive mode when interactive switch is used
        if ($Interactive) {

            $ShowImageGallery = $true
        }

        # initialize results collection for all found images
        $results = [System.Collections.Generic.List[Object]] @()

        # get configured directories and language using Get-ImageDirectories
        $config = GenXdev.AI\Get-ImageDirectories -DefaultValue $ImageDirectories

        # use provided directories or get from configuration
        if ($ImageDirectories) {

            $directories = $ImageDirectories
        }
        else {

            $directories = $config.ImageDirectories
        }

        # resolve default language if not explicitly provided
        if ([string]::IsNullOrEmpty($Language)) {

            $Language = $config.Language
        }
    }

    process {

        # define internal function to process individual image files
        function processImageFile {

            param($item)

            # get full path of current image file being processed
            $image = $PSItem.FullName

            # output current image being processed for debugging
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing image: $image")

            # initialize metadata containers for this image
            $keywordsFound = @()

            $descriptionFound = $null

            $metadataFile = $null

            # try to load description metadata in requested language if not english
            if ($Language -ne "English" -and
                [System.IO.File]::Exists("$($image):description.$Language.json")) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found $Language metadata for $image")

                $metadataFile = "$($image):description.$Language.json"
            }
            # fallback to english if language-specific file doesn't exist
            elseif ([System.IO.File]::Exists("$($image):description.json")) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found English metadata for $image")

                $metadataFile = "$($image):description.json"
            }

            # try to load description metadata if any file was found
            if ($metadataFile) {

                try {

                    # read and parse description json from alternate data stream
                    $descriptionFound = [System.IO.File]::ReadAllText(
                        $metadataFile) |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # extract keywords from description if they exist
                    $keywordsFound = ($null -eq $descriptionFound.keywords) ?
                        @() : $descriptionFound.keywords
                }
                catch {

                    # reset description if json parsing fails
                    $descriptionFound = $null

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to parse metadata from $metadataFile")
                }
            }

            # initialize people metadata container with default structure
            $peopleFound = @{count = 0; faces = @() }

            # try to load people metadata if alternate data stream exists
            if ([System.IO.File]::Exists("$($image):people.json")) {

                try {

                    # read and parse people json from alternate data stream
                    $peopleFound = [System.IO.File]::ReadAllText(
                        "$($image):people.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # ensure people data has proper structure or reset to default
                    $peopleFound = (($null -eq $peopleFound) -or
                        ($peopleFound.count -eq 0)) ?
                        @{count = 0; faces = @() } : $peopleFound
                }
                catch {

                    # reset people data if json parsing fails
                    $peopleFound = @{count = 0; faces = @() }
                }
            }

            # initialize objects metadata container with default structure
            $objectsFound = @{count = 0; objects = @(); object_counts = @{} }

            # try to load objects metadata if alternate data stream exists
            if ([System.IO.File]::Exists("$($image):objects.json")) {

                try {

                    # read and parse objects json from alternate data stream
                    $parsedObjects = [System.IO.File]::ReadAllText(
                        "$($image):objects.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # if parsed data is not null and has predictions
                    if ($null -ne $parsedObjects -and
                        $null -ne $parsedObjects.predictions) {

                        # remap to the structure the script expects
                        $objectsFound = @{
                            count = $parsedObjects.predictions.Count
                            objects = $parsedObjects.predictions
                            object_counts = $parsedObjects.object_counts
                        }
                    }
                }
                catch {

                    # reset objects data if json parsing fails
                    $objectsFound = @{
                        count = 0;
                        objects = @();
                        object_counts = @{}
                    }
                }
            }

            # initialize scenes metadata container with default structure
            $scenesFound = @{
                success = $false;
                scene = "unknown";
                confidence = 0.0
            }

            # try to load scenes metadata if alternate data stream exists
            if ([System.IO.File]::Exists("$($image):scenes.json")) {

                try {

                    # read and parse scenes json from alternate data stream
                    $parsedScenes = [System.IO.File]::ReadAllText(
                        "$($image):scenes.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # if parsed data is not null and has scene data
                    if ($null -ne $parsedScenes -and
                        $null -ne $parsedScenes.scene) {

                        $scenesFound = $parsedScenes
                    }
                }
                catch {

                    # reset scenes data if json parsing fails
                    $scenesFound = @{
                        success = $false;
                        scene = "unknown";
                        confidence = 0.0
                    }
                }
            }

            # determine if image has search criteria or metadata
            $hasSearchCriteria = (($null -ne $Keywords) -and
                ($Keywords.Length -gt 0)) -or
                (($null -ne $People) -and ($People.Count -gt 0)) -or
                (($null -ne $Objects) -and ($Objects.Count -gt 0)) -or
                (($null -ne $Scenes) -and ($Scenes.Count -gt 0)) -or
                $HasNudity -or $NoNudity -or $HasExplicitContent -or
                $NoExplicitContent -or
                (($null -ne $PictureType) -and ($PictureType.Count -gt 0)) -or
                (($null -ne $StyleType) -and ($StyleType.Count -gt 0)) -or
                (($null -ne $OverallMood) -and ($OverallMood.Count -gt 0))

            $hasAnyMetadata = (($null -ne $keywordsFound) -and
                ($keywordsFound.length -gt 0)) -or
                ($null -ne $descriptionFound) -or
                ($peopleFound.count -gt 0) -or
                ($objectsFound.count -gt 0) -or
                ($scenesFound.success -eq $true)

            # only skip if we have no search criteria AND no metadata
            if (-not $hasSearchCriteria -and -not $hasAnyMetadata) {
                return
            }

            # assume match if no keyword search criteria specified
            $found = (($null -eq $Keywords) -or ($Keywords.Length -eq 0))

            # perform keyword matching if keywords were specified for search
            if (-not $found) {

                # convert description to json string for wildcard matching
                $descriptionFound = ($null -ne $descriptionFound) ?
                $descriptionFound : "" |
                Microsoft.PowerShell.Utility\ConvertTo-Json `
                    -Compress `
                    -Depth 10 `
                    -WarningAction SilentlyContinue

                # check each required keyword against available metadata
                foreach ($requiredKeyword in $Keywords) {

                    # first check if keyword matches in description content
                    $found = "$descriptionFound" -like $requiredKeyword

                    # if not found in description, check individual keywords array
                    if (-not $found) {

                        # skip keyword array check if no keywords exist
                        if (($null -eq $keywordsFound) -or
                            ($keywordsFound.Length -eq 0)) {
                            continue
                        }

                        # check each image keyword against required keyword pattern
                        foreach ($imageKeyword in $keywordsFound) {

                            # use wildcard matching for flexible keyword search
                            if ($imageKeyword -like $requiredKeyword) {

                                $found = $true

                                break
                            }
                        }
                    }

                    # exit early if any required keyword matches
                    if ($found) { break }
                }
            }

            # perform additional people filtering if people criteria specified
            if ($found -and ($null -ne $People) -and ($People.Length -gt 0)) {

                # reset found flag to require people match
                $found = $false

                # check each found person against search criteria
                foreach ($foundPerson in $peopleFound.faces) {

                    # check each searched person against found person
                    foreach ($searchedForPerson in $People) {

                        # use wildcard matching for flexible people search
                        if ($foundPerson -like $searchedForPerson) {

                            $found = $true

                            break
                        }
                    }

                    # exit early if any person matches
                    if ($found) { break }
                }
            }

            # perform additional objects filtering if objects criteria specified
            if ($found -and ($null -ne $Objects) -and ($Objects.Length -gt 0)) {

                # reset found flag to require objects match
                $found = $false

                # check each found object against search criteria
                foreach ($foundObject in $objectsFound.objects) {

                    # check each searched object against found object
                    foreach ($searchedForObject in $Objects) {

                        # use wildcard matching for flexible objects search
                        if ($foundObject.label -like $searchedForObject) {

                            $found = $true

                            break
                        }
                    }

                    # exit early if any object matches
                    if ($found) { break }
                }
            }

            # perform additional scenes filtering if scenes criteria specified
            if ($found -and ($null -ne $Scenes) -and ($Scenes.Count -gt 0)) {

                # reset found flag to require scene match
                $found = $false

                # debug output for scene filtering
                if ($VerbosePreference -eq 'Continue') {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Scene filtering - Searching for: $($Scenes -join ', ')")

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Scene filtering - Found scene: $($scenesFound.scene)")

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Scene filtering - Scene success: $($scenesFound.success)")
                }

                # check if the found scene matches any of the search criteria
                foreach ($searchedForScene in $Scenes) {

                    # use wildcard matching for flexible scene search
                    if ($scenesFound.scene -like $searchedForScene) {

                        $found = $true

                        if ($VerbosePreference -eq 'Continue') {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Scene filtering - Match found: " +
                                "'$($scenesFound.scene)' matches " +
                                "'$searchedForScene'")
                        }

                        break
                    }

                    # special handling for wildcard scenes with other metadata
                    if ($searchedForScene -eq "*" -and
                        $scenesFound.success -eq $false) {

                        # check if we have any other metadata that makes this interesting
                        $hasOtherMetadata = (($null -ne $keywordsFound) -and
                            ($keywordsFound.length -gt 0)) -or
                            ($null -ne $descriptionFound) -or
                            ($peopleFound.count -gt 0) -or
                            ($objectsFound.count -gt 0)

                        if ($hasOtherMetadata) {

                            $found = $true

                            if ($VerbosePreference -eq 'Continue') {

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "Scene filtering - Wildcard match: including " +
                                    "image with other metadata despite missing " +
                                    "scene data")
                            }

                            break
                        }
                    }
                }

                if (-not $found -and $VerbosePreference -eq 'Continue') {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Scene filtering - No match found for scene: " +
                        "$($scenesFound.scene)")
                }
            }

            # perform content filtering based on description metadata properties
            if ($found -and ($HasNudity -or $NoNudity -or $HasExplicitContent -or
                $NoExplicitContent -or
                (($null -ne $PictureType) -and ($PictureType.Count -gt 0)) -or
                (($null -ne $StyleType) -and ($StyleType.Count -gt 0)) -or
                (($null -ne $OverallMood) -and ($OverallMood.Count -gt 0)))) {

                # check if we have description metadata required for these filters
                if ($null -eq $descriptionFound) {

                    $found = $false
                }
                else {

                    # nudity filtering
                    if ($HasNudity -and $descriptionFound.has_nudity -ne $true) {

                        $found = $false
                    }

                    if ($NoNudity -and $descriptionFound.has_nudity -eq $true) {

                        $found = $false
                    }

                    # explicit content filtering
                    if ($HasExplicitContent -and
                        $descriptionFound.has_explicit_content -ne $true) {

                        $found = $false
                    }

                    if ($NoExplicitContent -and
                        $descriptionFound.has_explicit_content -eq $true) {

                        $found = $false
                    }

                    # picture type filtering
                    if ($found -and ($null -ne $PictureType) -and
                        ($PictureType.Count -gt 0)) {

                        $pictureTypeFound = $false

                        foreach ($requiredPictureType in $PictureType) {

                            if ($descriptionFound.picture_type -like
                                $requiredPictureType) {

                                $pictureTypeFound = $true

                                break
                            }
                        }

                        if (-not $pictureTypeFound) {

                            $found = $false
                        }
                    }

                    # style type filtering
                    if ($found -and ($null -ne $StyleType) -and
                        ($StyleType.Count -gt 0)) {

                        $styleTypeFound = $false

                        foreach ($requiredStyleType in $StyleType) {

                            if ($descriptionFound.style_type -like
                                $requiredStyleType) {

                                $styleTypeFound = $true

                                break
                            }
                        }

                        if (-not $styleTypeFound) {

                            $found = $false
                        }
                    }

                    # overall mood filtering
                    if ($found -and ($null -ne $OverallMood) -and
                        ($OverallMood.Count -gt 0)) {

                        $overallMoodFound = $false

                        foreach ($requiredMood in $OverallMood) {

                            if ($descriptionFound.overall_mood_of_image -like
                                $requiredMood) {

                                $overallMoodFound = $true

                                break
                            }
                        }

                        if (-not $overallMoodFound) {

                            $found = $false
                        }
                    }
                }
            }

            # return image data if all criteria matched
            if ($found) {

                # output match found for debugging purposes
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found matching image: $image")

                # return hashtable with all image metadata
                Microsoft.PowerShell.Utility\Write-Output @{
                    path        = $image
                    keywords    = $keywordsFound
                    description = $descriptionFound
                    people      = $peopleFound
                    objects     = $objectsFound
                    scenes      = $scenesFound
                }
            }
        }

        # handle input object processing from pipeline
        if ($PSBoundParameters.ContainsKey('InputObject')) {

            $null = $InputObject |
                Microsoft.PowerShell.Core\ForEach-Object {

                # process each input object as an image file
                $path = $_.Path

                if ($null -eq $path) {
                    return;
                }

                if ($path.StartsWith("file://")) {

                    $path = $path.Substring(7).Replace('/', '\')
                }

                processImageFile $path
            }

            return;
        }

        # iterate through each specified image directory
        foreach ($imageDirectory in $directories) {

            # convert relative path to absolute path for consistency
            $path = GenXdev.FileSystem\Expand-Path $imageDirectory

            # output directory being scanned for debugging purposes
            Microsoft.PowerShell.Utility\Write-Verbose "Scanning directory: $path"

            # validate directory exists before proceeding with search
            if (-not [System.IO.Directory]::Exists($path)) {

                Microsoft.PowerShell.Utility\Write-Host (
                    "The directory '$path' does not exist.")

                continue
            }

            # search for jpg/jpeg/png files and process each one found
            Microsoft.PowerShell.Management\Get-ChildItem `
                -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
                -Recurse `
                -File `
                -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                processImageFile $_ |
                    Microsoft.PowerShell.Core\ForEach-Object {

                    if (-not $ShowImageGallery) {

                        Microsoft.PowerShell.Utility\Write-Output $_
                    }
                    else {

                        $null = $results.Add($_)
                    }
                }
            }
        }
    }

    end {

        # check if any results were found
        if ((-not $results) -or ($null -eq $results) -or
            ($results.Length -eq 0)) {

            # provide appropriate message based on search criteria
            if (($null -eq $Keywords) -or ($Keywords.Length -eq 0)) {

                Microsoft.PowerShell.Utility\Write-Host "No images found."
            }
            else {

                Microsoft.PowerShell.Utility\Write-Host (
                    "No images found with the specified keywords.")
            }

            return
        }

        # if ShowImageGallery is requested, display the gallery
        if ($ShowImageGallery) {

            if ([String]::IsNullOrWhiteSpace($Title)) {

                $Title = "Image Search Results"
            }

            if ([String]::IsNullOrWhiteSpace($Description)) {

                $Description = $MyInvocation.Statement
            }

            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "Show-ImageGallery" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # pass the results to Show-ImageGallery
            $null = GenXdev.AI\Show-ImageGallery @params -InputObject $results
        }

        if ((-not $ShowImageGallery) -or $PassThru) {

            return $results
        }
    }
}
################################################################################
