<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Save-FoundImageObjects.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.274.2025
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
Saves cropped object images from indexed image search results to files.

.DESCRIPTION
This function takes image search results and extracts individual detected
object regions, saving them as separate image files. It can search for objects
using various criteria including keywords, people, scenes, and metadata filters.
The function processes images with AI-detected object boundaries and crops them
to individual PNG files in the specified output directory.

.PARAMETER Any
Will match any of all the possible meta data types including descriptions,
keywords, people, objects, scenes, picture types, style types, and moods.

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

.PARAMETER DatabaseFilePath
Path to the SQLite database file.

.PARAMETER Title
Title for the image gallery.

.PARAMETER Description
Description for the image gallery.

.PARAMETER Language
Language for descriptions and keywords.

.PARAMETER PathLike
Array of directory path-like search strings to filter images by path
(SQL LIKE patterns, e.g. '%\2024\%').

.PARAMETER InputObject
Accepts search results from a previous -PassThru call to regenerate the view.

.PARAMETER OutputDirectory
Directory to save cropped object images.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER ImageDirectories
Array of directory paths to search for images.

.PARAMETER FacesDirectory
The directory containing face images organized by person folders.

.PARAMETER EmbedImages
Embed images as base64.

.PARAMETER NoFallback
Switch to disable fallback behavior.

.PARAMETER NeverRebuild
Never rebuild the image index database.

.PARAMETER ShowInBrowser
Show results in browser.

.PARAMETER SendKeyEscape
Send Escape key to browser.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus in browser.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter for browser input.

.PARAMETER SendKeyDelayMilliSeconds
Delay in milliseconds for sending keys.

.PARAMETER NoBorders
Show images without borders.

.PARAMETER SideBySide
Show images side by side.

.PARAMETER AcceptLang
Accept-Language header for browser.

.PARAMETER Monitor
Monitor to use for browser window.

.PARAMETER ShowOnlyPictures
Show only pictures.

.PARAMETER Interactive
Enable interactive mode.

.PARAMETER Private
Open browser in private/incognito mode.

.PARAMETER Edge
Use Microsoft Edge browser.

.PARAMETER Chrome
Use Google Chrome browser.

.PARAMETER Chromium
Use Chromium browser.

.PARAMETER Firefox
Use Mozilla Firefox browser.

.PARAMETER ShowWindow
Show browser window.

.PARAMETER Left
Set browser window left position.

.PARAMETER Right
Set browser window right position.

.PARAMETER Top
Set browser window top position.

.PARAMETER Bottom
Set browser window bottom position.

.PARAMETER Centered
Center browser window.

.PARAMETER ApplicationMode
Open browser in application mode.

.PARAMETER NoBrowserExtensions
Disable browser extensions.

.PARAMETER DisablePopupBlocker
Disable popup blocker in browser.

.PARAMETER RestoreFocus
Restore focus to previous window.

.PARAMETER NewWindow
Open browser in new window.

.PARAMETER OnlyReturnHtml
Return only HTML from browser.

.PARAMETER FocusWindow
Focus browser window.

.PARAMETER SetForeground
Set browser window to foreground.

.PARAMETER Maximize
Maximize browser window.

.PARAMETER HasNudity
Filter images that contain nudity.

.PARAMETER NoNudity
Filter images that do NOT contain nudity.

.PARAMETER HasExplicitContent
Filter images that contain explicit content.

.PARAMETER NoExplicitContent
Filter images that do NOT contain explicit content.

.PARAMETER ForceIndexRebuild
Force rebuild of the image index database.

.PARAMETER GeoLocation
Geographic coordinates [latitude, longitude] to search near.

.PARAMETER GeoDistanceInMeters
Maximum distance in meters from GeoLocation to search for images.

.PARAMETER SaveUnknownPersons
Also save unknown persons detected as objects.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Save-FoundImageObjects -Objects "car", "tree" -OutputDirectory "C:\CroppedObjects"

.EXAMPLE
saveimageObjects -Any "sunset" -SaveUnknownPersons
#>
function Save-FoundImageObjects {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([Object[]], [System.Collections.Generic.List[Object]], [string])]
    [Alias('saveimageObjects')]

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
            HelpMessage = 'Path to the SQLite database file.'
        )]
        [string] $DatabaseFilePath,
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
            HelpMessage = 'Language for descriptions and keywords.'
        )]
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu')]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of directory path-like search strings to ' +
                "filter images by path (SQL LIKE patterns, e.g. '%\\2024\\%')")
        )]
        [string[]] $PathLike = @(),
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
            HelpMessage = 'Directory to save cropped Object images.'
        )]
        [string] $OutputDirectory = '.\',
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
            HelpMessage = 'Array of directory paths to search for images.'
        )]
        [Alias('imagespath','directories','imgdirs','imagedirectory')]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized by ' +
                'person folders.')
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Geographic coordinates [latitude, longitude] to search near.'
        )]
        [double[]] $GeoLocation,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Maximum distance in meters from GeoLocation to ' +
                'search for images.')
        )]
        [double] $GeoDistanceInMeters = 1000,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds for sending keys.'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Accept-Language header for browser.'
        )]
        [Alias('lang','locale')]
        [string] $AcceptLang,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Monitor to use for browser window.'
        )]
        [Alias('m','mon')]
        [int] $Monitor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set browser window left position.'
        )]
        [int] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set browser window right position.'
        )]
        [int] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set browser window top position.'
        )]
        [int] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set browser window bottom position.'
        )]
        [int] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Embed images as base64.'
        )]
        [switch] $EmbedImages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to disable fallback behavior.'
        )]
        [switch] $NoFallback,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Never rebuild the image index database.'
        )]
        [switch] $NeverRebuild,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show results in browser.'
        )]
        [Alias('show','s')]
        [switch] $ShowInBrowser,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key to browser.'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus in browser.'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter for browser input.'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show images without borders.'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show images side by side.'
        )]
        [Alias('sbs')]
        [switch] $SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show only pictures.'
        )]
        [Alias('NoMetadata','OnlyPictures')]
        [switch] $ShowOnlyPictures,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable interactive mode.'
        )]
        [Alias('i','editimages')]
        [switch] $Interactive,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open browser in private/incognito mode.'
        )]
        [Alias('incognito','inprivate')]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Microsoft Edge browser.'
        )]
        [Alias('e')]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Google Chrome browser.'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Chromium browser.'
        )]
        [Alias('c')]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Mozilla Firefox browser.'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show browser window.'
        )]
        [Alias('sw')]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center browser window.'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open browser in application mode.'
        )]
        [Alias('a','app','appmode')]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable browser extensions.'
        )]
        [Alias('de','ne','NoExtensions')]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable popup blocker in browser.'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to previous window.'
        )]
        [Alias('rf','bg')]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open browser in new window.'
        )]
        [Alias('nw','new')]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only HTML from browser.'
        )]
        [switch] $OnlyReturnHtml,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus browser window.'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set browser window to foreground.'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize browser window.'
        )]
        [switch] $Maximize,
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
            HelpMessage = 'Force rebuild of the image index database.'
        )]
        [switch] $ForceIndexRebuild,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Also save unknown persons detected as objects.'
        )]
        [switch] $SaveUnknownPersons,
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
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )


    ###############################################################################
    begin {

        # copy parameters for the ai meta language function to resolve language
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # resolve the language parameter using ai meta language function
        $language = GenXdev.AI\Get-AIMetaLanguage @params

        # initialize information tracking object for processing statistics
        $info = @{
            resultCount = 0
        }

        # process the any parameter if provided to expand search criteria
        if ($null -ne $Any -and $Any.Length -gt 0) {

            # transform each entry in any parameter to include wildcards if needed
            $any = @($Any |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        # trim whitespace from the entry
                        $entry = $_.Trim()

                        # add wildcards if no wildcard characters are present
                        if ($entry.IndexOfAny([char[]]@('*', '?')) -lt 0) {

                            "*$entry*"
                        }
                        else {
                            $_
                        }
                    })

            # merge any parameter values with existing search criteria arrays
            $descriptionSearch = $null -ne $DescriptionSearch ?
                ($DescriptionSearch + $Any) : $Any

            $keywords = $null -ne $Keywords ?
                ($Keywords + $Any) : $Any

            $people = $null -ne $People ?
                ($People + $Any) : $Any

            $objects = $null -ne $Objects ?
                ($Objects + $Any) : $Any

            $scenes = $null -ne $Scenes ?
                ($Scenes + $Any) : $Any

            $pictureType = $null -ne $PictureType ?
                ($PictureType + $Any) : $Any

            $styleType = $null -ne $StyleType ?
                ($StyleType + $Any) : $Any

            $overallMood = $null -ne $OverallMood ?
                ($OverallMood + $Any) : $Any
        }
    }
    ###############################################################################
    process {

        # ensure the output directory exists by expanding the path
        $outputDirectory = GenXdev.FileSystem\Expand-Path $OutputDirectory `
            -CreateDirectory

        Microsoft.PowerShell.Utility\Write-Verbose (
            "using output directory: $outputDirectory")

        # define internal function to save image objects from processed images
        function saveImage {

            param ($InputObject)

            # process each image object in the pipeline
            $InputObject |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # get current image object and validate it has required data
                    $image = $_
                    if ($null -eq $image -or -not $image.path) { return }

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "processing image: $($image.path)")

                    # extract object detection data if available
                    $objects = $null
                    if ($image.objects -and $image.objects.objects) {
                        $objects = $image.objects.objects
                    }

                    # track coordinates of saved object rectangles to avoid duplicates
                    $savedObjectRects = @()

                    # process detected objects if any exist
                    if ($objects) {

                        # get the full path to the source image file
                        $imgPath = $image.path

                        try {
                            # load the source image using system drawing classes
                            $imgObj = [System.Drawing.Image]::FromFile($imgPath)

                            try {
                                # extract base filename without extension for output naming
                                $imgBase = [System.IO.Path]::GetFileNameWithoutExtension(
                                    $imgPath)

                                # initialize object index counter for unique naming
                                $objectIdx = 0

                                # iterate through each detected object to crop and save
                                foreach ($obj in $objects) {

                                    # calculate safe bounding rectangle coordinates within image bounds
                                    $x_min = [Math]::Max(0,
                                        [Math]::Min($obj.x_min, $imgObj.Width - 1))
                                    $y_min = [Math]::Max(0,
                                        [Math]::Min($obj.y_min, $imgObj.Height - 1))
                                    $x_max = [Math]::Max($x_min + 1,
                                        [Math]::Min($obj.x_max, $imgObj.Width))
                                    $y_max = [Math]::Max($y_min + 1,
                                        [Math]::Min($obj.y_max, $imgObj.Height))

                                    # calculate width and height of the crop rectangle
                                    $width = $x_max - $x_min
                                    $height = $y_max - $y_min

                                    # skip invalid rectangles with zero or negative dimensions
                                    if ($width -le 0 -or $height -le 0) { continue }

                                    # create rectangle objects for cropping operation
                                    $cropRect = [System.Drawing.Rectangle]::new(
                                        $x_min, $y_min, $width, $height)

                                    # create new bitmap to hold the cropped object
                                    $croppedBitmap = [System.Drawing.Bitmap]::new(
                                        $width, $height)

                                    # create graphics context for drawing the cropped region
                                    $croppedGraphics = [System.Drawing.Graphics]::FromImage(
                                        $croppedBitmap)

                                    # define destination rectangle for the cropped image
                                    $destRect = [System.Drawing.Rectangle]::new(
                                        0, 0, $width, $height)

                                    # draw the cropped portion of source image to new bitmap
                                    $null = $croppedGraphics.DrawImage($imgObj,
                                        $destRect, $cropRect,
                                        [System.Drawing.GraphicsUnit]::Pixel)

                                    # dispose graphics context to free resources
                                    $croppedGraphics.Dispose()

                                    # generate sanitized label for the detected object
                                    $objectLabel = if ($obj.label) {
                                        $obj.label
                                    } else {
                                        "object$objectIdx"
                                    }

                                    # remove invalid filename characters from object label
                                    $objectLabel = $objectLabel `
                                        -replace '[^\w\-_]', '_'

                                    # construct output filename with object information
                                    $outFile = Microsoft.PowerShell.Management\Join-Path `
                                        $OutputDirectory `
                                    ("${imgBase}_${objectLabel}_${objectIdx}.png")

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "saving object to: $outFile")

                                    # save the cropped bitmap as png file
                                    $croppedBitmap.Save($outFile,
                                        [System.Drawing.Imaging.ImageFormat]::Png)

                                    # dispose bitmap to free memory
                                    $croppedBitmap.Dispose()

                                    # record saved object coordinates for overlap checking
                                    $savedObjectRects += @{
                                        x_min = $x_min
                                        y_min = $y_min
                                        x_max = $x_max
                                        y_max = $y_max
                                    }

                                    # increment object index for next iteration
                                    $objectIdx++
                                }

                                # process unknown persons if the switch is enabled
                                if ($SaveUnknownPersons -and
                                    $image.people -and
                                    $image.people.predictions) {

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        'processing unknown persons')

                                    # initialize person index counter for unique naming
                                    $personIdx = 0

                                    # iterate through detected person predictions
                                    foreach ($person in $image.people.predictions) {

                                        try {
                                            # calculate safe person bounding rectangle coordinates
                                            $x_min = [Math]::Max(0,
                                                [Math]::Min($person.x_min,
                                                    $imgObj.Width - 1))
                                            $y_min = [Math]::Max(0,
                                                [Math]::Min($person.y_min,
                                                    $imgObj.Height - 1))
                                            $x_max = [Math]::Max($x_min + 1,
                                                [Math]::Min($person.x_max,
                                                    $imgObj.Width))
                                            $y_max = [Math]::Max($y_min + 1,
                                                [Math]::Min($person.y_max,
                                                    $imgObj.Height))

                                            # calculate person rectangle dimensions
                                            $width = $x_max - $x_min
                                            $height = $y_max - $y_min

                                            # skip invalid person rectangles
                                            if ($width -le 0 -or $height -le 0) {
                                                continue
                                            }

                                            # check for overlap with previously saved objects
                                            $overlap = $false
                                            foreach ($rect in $savedObjectRects) {

                                                # test for rectangle intersection using bounds checking
                                                if ((($x_min -le $rect.x_max) -and
                                                    ($x_max -ge $rect.x_min)) -and
                                                    (($y_min -le $rect.y_max) -and
                                                    ($y_max -ge $rect.y_min))) {

                                                    $overlap = $true
                                                    break
                                                }
                                            }

                                            # skip persons that overlap with saved objects
                                            if ($overlap) { continue }

                                            # create crop rectangle for person detection
                                            $cropRect = [System.Drawing.Rectangle]::new(
                                                $x_min, $y_min, $width, $height)

                                            # create bitmap for cropped person image
                                            $croppedBitmap = [System.Drawing.Bitmap]::new(
                                                $width, $height)

                                            # create graphics context for person cropping
                                            $croppedGraphics = [System.Drawing.Graphics]::FromImage(
                                                $croppedBitmap)

                                            # define destination rectangle for person crop
                                            $destRect = [System.Drawing.Rectangle]::new(
                                                0, 0, $width, $height)

                                            # draw cropped person region to new bitmap
                                            $null = $croppedGraphics.DrawImage($imgObj,
                                                $destRect, $cropRect,
                                                [System.Drawing.GraphicsUnit]::Pixel)

                                            # dispose graphics context
                                            $croppedGraphics.Dispose()

                                            # construct filename for unknown person image
                                            $outFile = Microsoft.PowerShell.Management\Join-Path `
                                                $OutputDirectory `
                                            ("${imgBase}_unknownperson_${personIdx}.png")

                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                "saving unknown person to: $outFile")

                                            # save person bitmap as png file
                                            $croppedBitmap.Save($outFile,
                                                [System.Drawing.Imaging.ImageFormat]::Png)

                                            # dispose person bitmap
                                            $croppedBitmap.Dispose()

                                            # increment person index counter
                                            $personIdx++
                                        }
                                        catch {
                                            # log warning for person processing failures
                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ('failed to crop/save unknown person ' +
                                                "for $($imgPath): $_"))
                                        }
                                    }
                                }
                            }
                            finally {
                                # ensure source image object is disposed to free memory
                                if ($null -ne $imgObj) {
                                    $imgObj.Dispose()
                                }
                            }
                        }
                        catch {
                            # log warning for general image processing failures
                            Microsoft.PowerShell.Utility\Write-Verbose (
                                ("failed to crop/save objects for $($imgPath): $_"))
                        }
                    }

                    # increment result counter for statistics tracking
                    $info.resultCount++

                    # output the processed image object to pipeline
                    Microsoft.PowerShell.Utility\Write-Output $image
                }
        }

        # process input based on whether explicit input objects are provided
        if ($null -ne $InputObject) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'processing provided input objects')

            # process each input object through the save image function
            $InputObject |
                Microsoft.PowerShell.Core\ForEach-Object { saveImage $_ }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'searching for indexed images')

            # copy parameters for find-indexedimage function call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Find-IndexedImage' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # find indexed images and process each through save image function
            GenXdev.AI\Find-IndexedImage @params |
                Microsoft.PowerShell.Core\ForEach-Object { saveImage $_ }
        }
    }
    ###############################################################################
    end {

        # output processing statistics to verbose stream
        Microsoft.PowerShell.Utility\Write-Verbose (
            "processed $($info.resultCount) images")
    }
}
###############################################################################