###############################################################################
<#
.SYNOPSIS
Saves cropped face images from indexed image search results.

.DESCRIPTION
This function takes image search results and extracts/saves individual face
regions as separate image files. It can search for faces using various criteria
and save them to a specified output directory. The function supports searching
by description, keywords, people, objects, scenes, picture type, style type,
and overall mood. It can also filter by nudity and explicit content.

.PARAMETER Any
Will match any of all the possible meta data types.

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

.PARAMETER DatabaseFilePath
Path to the SQLite database file.

.PARAMETER Language
Language for descriptions and keywords.

.PARAMETER ForceIndexRebuild
Force rebuild of the image index database.

.PARAMETER PathLike
Array of directory path-like search strings to filter images by path (SQL LIKE
patterns, e.g. '%\\2024\\%').

.PARAMETER InputObject
Accepts search results from a previous -PassThru call to regenerate the view.

.PARAMETER OutputDirectory
Directory to save cropped face images.

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

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Save-FoundImageFaces -People "John*" -OutputDirectory "C:\Faces"

.EXAMPLE
saveimagefaces -Any "vacation" -SaveUnknownPersons
#>
###############################################################################
function Save-FoundImageFaces {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([Object[]], [System.Collections.Generic.List[Object]], [string])]
    [Alias('saveimagefaces')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Will match any of all the possible meta data types.'
        )]
        [string[]] $Any = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The description text to look for, wildcards allowed.'
        )]
        [string[]] $DescriptionSearch = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The keywords to look for, wildcards allowed.'
        )]
        [string[]] $Keywords = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'People to look for, wildcards allowed.'
        )]
        [string[]] $People = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Objects to look for, wildcards allowed.'
        )]
        [string[]] $Objects = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Scenes to look for, wildcards allowed.'
        )]
        [string[]] $Scenes = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Picture types to filter by, wildcards allowed.'
        )]
        [string[]] $PictureType = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Style types to filter by, wildcards allowed.'
        )]
        [string[]] $StyleType = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Overall moods to filter by, wildcards allowed.'
        )]
        [string[]] $OverallMood = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path to the SQLite database file.'
        )]
        [string] $DatabaseFilePath,
        #######################################################################
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
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = (
                'Array of directory path-like search strings to filter images by ' +
                "path (SQL LIKE patterns, e.g. '%\\2024\\%')"
            )
        )]
        [string[]] $PathLike = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = ('Accepts search results from a previous -PassThru ' +
                'call to regenerate the view.')
        )]
        [System.Object[]] $InputObject,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Directory to save cropped face images.'
        )]
        [string] $OutputDirectory = '.\',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that contain nudity.'
        )]
        [switch] $HasNudity,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that do NOT contain nudity.'
        )]
        [switch] $NoNudity,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that contain explicit content.'
        )]
        [switch] $HasExplicitContent,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that do NOT contain explicit content.'
        )]
        [switch] $NoExplicitContent,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuild of the image index database.'
        )]
        [switch] $ForceIndexRebuild,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Geographic coordinates [latitude, longitude] to search near.'
        )]
        [double[]] $GeoLocation,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum distance in meters from GeoLocation to search for images.'
        )]
        [double] $GeoDistanceInMeters = 1000,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Also save unknown persons detected as objects.'
        )]
        [switch] $SaveUnknownPersons,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #######################################################################
    )

    #########################################################################
    begin {

        # copy identical parameter values for ai meta language function
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get ai meta language with fallback to default web language
        $language = GenXdev.AI\Get-AIMetaLanguage @params

        Microsoft.PowerShell.Utility\Write-Verbose ("Using language: $language")

        # initialize result counter for tracking processed images
        $info = @{
            resultCount = 0
        }

        # process any parameter if provided to expand search criteria
        if ($null -ne $Any -and $Any.Length -gt 0) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Processing 'Any' parameter " +
                "with $($Any.Length) entries")

            # add wildcards to any entries without them for better matching
            $any = @($Any | Microsoft.PowerShell.Core\ForEach-Object {

                    # trim whitespace from entry to normalize input
                    $entry = $_.Trim()

                    # add wildcards if none exist to enable partial matching
                    if ($entry.IndexOfAny([char[]]@('*', '?')) -lt 0) {

                        "*$entry*"
                    }
                    else {
                        $_
                    }
                })

            # merge any parameter with all search parameters for comprehensive search
            $descriptionSearch = $null -ne $DescriptionSearch ?
                ($DescriptionSearch + $any) :
            $any

            $keywords = $null -ne $Keywords ?
                ($Keywords + $any) :
            $any

            $people = $null -ne $People ?
                ($People + $any) :
            $any

            $objects = $null -ne $Objects ?
                ($Objects + $any) :
            $any

            $scenes = $null -ne $Scenes ?
                ($Scenes + $any) :
            $any

            $pictureType = $null -ne $PictureType ?
                ($PictureType + $any) :
            $any

            $styleType = $null -ne $StyleType ?
                ($StyleType + $any) :
            $any

            $overallMood = $null -ne $OverallMood ?
                ($OverallMood + $any) :
            $any
        }
    }
    #########################################################################
    process {

        # ensure output directory exists and get expanded path
        $outputDirectory = GenXdev.FileSystem\Expand-Path $OutputDirectory `
            -CreateDirectory

        Microsoft.PowerShell.Utility\Write-Verbose ('Using output directory: ' +
            "$outputDirectory")

        # define internal function to save image faces from processed images
        function saveImage {

            param ($inputObject)

            # process each image object in the pipeline
            $inputObject | Microsoft.PowerShell.Core\ForEach-Object {

                # get current image object for processing
                $image = $_

                # skip if image is null or has no path for processing
                if ($null -eq $image -or -not $image.path) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Skipping image ' +
                        'with null or missing path')
                    return
                }

                # get image path for loading
                $imgPath = $image.path

                Microsoft.PowerShell.Utility\Write-Verbose ('Processing image: ' +
                    "$imgPath")

                # handle face/people recognition data from different sources
                $people = $null
                if ($image.people -and $image.people.predictions) {

                    $people = $image.people.predictions
                }
                elseif ($image.faces -and $image.faces.predictions) {

                    $people = $image.faces.predictions
                }

                # initialize saved face rectangles for overlap detection
                $savedFaceRects = @()

                # process people/faces if found in image
                if ($people) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Found ' +
                        "$($people.Count) faces/people in image")

                    try {
                        # load image from file for processing
                        $imgObj = [System.Drawing.Image]::FromFile($imgPath)

                        try {
                            # get base filename without extension for output naming
                            $imgBase = [System.IO.Path]::GetFileNameWithoutExtension(
                                $imgPath)

                            # initialize face index counter for unique naming
                            $faceIdx = 0

                            # process each detected face in the image
                            foreach ($face in $people) {

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "Processing face $faceIdx")

                                # ensure coordinates are within image bounds to prevent errors
                                $x_min = [Math]::Max(0,
                                    [Math]::Min($face.x_min, $imgObj.Width - 1))
                                $y_min = [Math]::Max(0,
                                    [Math]::Min($face.y_min, $imgObj.Height - 1))
                                $x_max = [Math]::Max($x_min + 1,
                                    [Math]::Min($face.x_max, $imgObj.Width))
                                $y_max = [Math]::Max($y_min + 1,
                                    [Math]::Min($face.y_max, $imgObj.Height))

                                # calculate face dimensions for validation
                                $width = $x_max - $x_min
                                $height = $y_max - $y_min

                                # skip invalid dimensions to prevent errors
                                if ($width -le 0 -or $height -le 0) {

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        'Skipping face with invalid dimensions')
                                    continue
                                }

                                # create rectangle for cropping the face region
                                $cropRect = [System.Drawing.Rectangle]::new(
                                    $x_min, $y_min, $width, $height)

                                # create bitmap for cropped face output
                                $croppedBitmap = [System.Drawing.Bitmap]::new(
                                    $width, $height)

                                # create graphics object for drawing operations
                                $croppedGraphics = [System.Drawing.Graphics]::FromImage(
                                    $croppedBitmap)

                                # define destination rectangle for drawing
                                $destRect = [System.Drawing.Rectangle]::new(
                                    0, 0, $width, $height)

                                # crop face from original image to new bitmap
                                $null = $croppedGraphics.DrawImage(
                                    $imgObj, $destRect, $cropRect,
                                    [System.Drawing.GraphicsUnit]::Pixel)

                                # dispose graphics object to free memory
                                $croppedGraphics.Dispose()

                                # create face label from userid or default naming
                                $faceLabel = if ($face.userid) {
                                    $face.userid
                                }
                                else {
                                    "face$faceIdx"
                                }

                                # sanitize face label for filename compatibility
                                $faceLabel = $faceLabel -replace '[^\w\-_]', '_'

                                # create output filename with descriptive naming
                                $outFile = Microsoft.PowerShell.Management\Join-Path `
                                    $outputDirectory `
                                ("${imgBase}_${faceLabel}_${faceIdx}.png")

                                # save cropped face as png file
                                $croppedBitmap.Save($outFile,
                                    [System.Drawing.Imaging.ImageFormat]::Png)

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "Saved face to: $outFile")

                                # dispose cropped bitmap to free memory
                                $croppedBitmap.Dispose()

                                # store face rectangle for overlap detection
                                $savedFaceRects += @{
                                    x_min = $x_min
                                    y_min = $y_min
                                    x_max = $x_max
                                    y_max = $y_max
                                }

                                # increment face index for next iteration
                                $faceIdx++
                            }

                            # save unknown persons if requested and objects exist
                            if ($SaveUnknownPersons -and $image.objects -and
                                $image.objects.objects) {

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    'Processing unknown persons from objects')

                                # initialize object index counter for unique naming
                                $objIdx = 0

                                # process each detected object for person detection
                                foreach ($obj in $image.objects.objects) {

                                    # only process person objects for face extraction
                                    if ($obj.label -eq 'person') {

                                        try {
                                            # ensure coordinates are within bounds
                                            $x_min = [Math]::Max(0,
                                                [Math]::Min($obj.x_min, $imgObj.Width - 1))
                                            $y_min = [Math]::Max(0,
                                                [Math]::Min($obj.y_min, $imgObj.Height - 1))
                                            $x_max = [Math]::Max($x_min + 1,
                                                [Math]::Min($obj.x_max, $imgObj.Width))
                                            $y_max = [Math]::Max($y_min + 1,
                                                [Math]::Min($obj.y_max, $imgObj.Height))

                                            # calculate object dimensions
                                            $width = $x_max - $x_min
                                            $height = $y_max - $y_min

                                            # skip invalid dimensions
                                            if ($width -le 0 -or $height -le 0) {
                                                continue
                                            }

                                            # check for overlap with known faces to avoid duplicates
                                            $overlap = $false
                                            foreach ($rect in $savedFaceRects) {
                                                if ((($x_min -le $rect.x_max) -and
                                                    ($x_max -ge $rect.x_min)) -and
                                                    (($y_min -le $rect.y_max) -and
                                                    ($y_max -ge $rect.y_min))) {
                                                    $overlap = $true
                                                    break
                                                }
                                            }

                                            # skip if overlaps with known face
                                            if ($overlap) {
                                                continue
                                            }

                                            # create rectangle for cropping
                                            $cropRect = [System.Drawing.Rectangle]::new(
                                                $x_min, $y_min, $width, $height)

                                            # create bitmap for cropped person
                                            $croppedBitmap = [System.Drawing.Bitmap]::new(
                                                $width, $height)

                                            # create graphics object for drawing
                                            $croppedGraphics = [System.Drawing.Graphics]::FromImage(
                                                $croppedBitmap)

                                            # define destination rectangle
                                            $destRect = [System.Drawing.Rectangle]::new(
                                                0, 0, $width, $height)

                                            # crop person from original image
                                            $null = $croppedGraphics.DrawImage(
                                                $imgObj, $destRect, $cropRect,
                                                [System.Drawing.GraphicsUnit]::Pixel)

                                            # dispose graphics object
                                            $croppedGraphics.Dispose()

                                            # create output filename for unknown person
                                            $outFile = Microsoft.PowerShell.Management\Join-Path `
                                                $outputDirectory `
                                            ("${imgBase}_unknownperson_${objIdx}.png")

                                            # save cropped person as png
                                            $croppedBitmap.Save($outFile,
                                                [System.Drawing.Imaging.ImageFormat]::Png)

                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                "Saved unknown person to: $outFile")

                                            # dispose cropped bitmap
                                            $croppedBitmap.Dispose()

                                            # increment object index
                                            $objIdx++
                                        }
                                        catch {
                                            # warn about failed unknown person cropping
                                            Microsoft.PowerShell.Utility\Write-Verbose `
                                            ('Failed to crop/save unknown person ' +
                                                "for $($imgPath): $_")
                                        }
                                    }
                                }
                            }
                        }
                        finally {
                            # dispose image object if exists to free memory
                            if ($null -ne $imgObj) {
                                $imgObj.Dispose()
                            }
                        }
                    }
                    catch {
                        # warn about failed face cropping
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Failed to crop/save faces for $($imgPath): $_"
                    }
                }

                # increment result counter for statistics tracking
                $info.resultCount++

                # output processed image object to pipeline
                Microsoft.PowerShell.Utility\Write-Output $image
            }
        }

        # process input based on whether explicit input objects are provided
        if ($null -ne $InputObject) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Processing provided input objects')

            # process each input object through the save image function
            $InputObject | Microsoft.PowerShell.Core\ForEach-Object {
                saveImage $_
            }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Searching for indexed images')

            # copy parameters for find indexed image function call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Find-IndexedImage' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # find indexed images and process each through save image function
            GenXdev.AI\Find-IndexedImage @params |
                Microsoft.PowerShell.Core\ForEach-Object {
                    saveImage $_
                }
        }
    }
    #########################################################################
    end {

        Microsoft.PowerShell.Utility\Write-Verbose ('Processed ' +
            "$($info.resultCount) images")
    }
}
###############################################################################
