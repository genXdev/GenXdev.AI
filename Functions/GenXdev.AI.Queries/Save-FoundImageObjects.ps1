################################################################################
<#
.SYNOPSIS
Saves cropped Object images from indexed image search results.

.DESCRIPTION
This function takes image search results and extracts/saves individual Object regions as separate image files.
It can search for Objects using various criteria and save them to a specified output directory.
#>
function Save-FoundImageObjects {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([Object[]], [System.Collections.Generic.List[Object]], [string])]
    [Alias("saveimageObjects")]

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
            HelpMessage = "Path to the SQLite database file."
        )]
        [string] $DatabaseFilePath,
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
            HelpMessage = "Language for descriptions and keywords."
        )]
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
            HelpMessage = (
                "Array of directory path-like search strings to filter images by " +
                "path (SQL LIKE patterns, e.g. '%\\2024\\%')"
            )
        )]
        [string[]] $PathLike = @(),
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
            HelpMessage = "Directory to save cropped Object images."
        )]
        [string] $OutputDirectory = ".\",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Also save unknown persons detected as objects."
        )]
        [switch] $SaveUnknownPersons
    )

    ###############################################################################
    begin {
        $Language = GenXdev.AI\Get-AIMetaLanguage -Language (
            [String]::IsNullOrWhiteSpace($Language) ?
            (GenXdev.Helpers\Get-DefaultWebLanguage) :
            $Language
        )


        $info = @{
            resultCount = 0
        }

        if ($null -ne $Any -and
            $Any.Length -gt 0) {

            $Any = @($Any | Microsoft.PowerShell.Core\ForEach-Object {

                $entry = $_.Trim()

                if ($entry.IndexOfAny([char[]]@('*', '?')) -lt 0) {

                    "*$entry*"
                }
                else {
                    $_
                }
            })

            # if Any parameter is used, treat it as a set of keywords
            $DescriptionSearch = $null -ne $DescriptionSearch ? ($DescriptionSearch + $Any) :
                $Any

            $Keywords = $null -ne $Keywords ? ($Keywords + $Any) :
                $Any

            $People = $null -ne $People ? ($People + $Any) :
                $Any

            $Objects = $null -ne $Objects ? ($Objects + $Any) :
                $Any

            $Scenes = $null -ne $Scenes ? ($Scenes + $Any) :
                $Any

            $PictureType = $null -ne $PictureType ? ($PictureType + $Any) :
                $Any

            $StyleType = $null -ne $StyleType ? ($StyleType + $Any) :
                $Any

            $OverallMood = $null -ne $OverallMood ? ($OverallMood + $Any) :
                $Any
        }
    }
    ###############################################################################
    process {
        # Ensure output directory exists
        $OutputDirectory = GenXdev.FileSystem\Expand-Path $OutputDirectory -CreateDirectory

        # if InputObject is provided, convert each item to an image object
        function saveImage {

            param ($InputObject)

            $InputObject | Microsoft.PowerShell.Core\ForEach-Object {
                $image = $_
                if ($null -eq $image -or -not $image.path) { return }

                # Handle object detection data
                $objects = $null
                if ($image.objects -and $image.objects.objects) {
                    $objects = $image.objects.objects
                }
                $savedObjectRects = @()
                if ($objects) {
                    $imgPath = $image.path
                    try {
                        $imgObj = [System.Drawing.Image]::FromFile($imgPath)
                        try {
                            $imgBase = [System.IO.Path]::GetFileNameWithoutExtension($imgPath)
                            $objectIdx = 0
                            foreach ($obj in $objects) {
                                $x_min = [Math]::Max(0, [Math]::Min($obj.x_min, $imgObj.Width - 1))
                                $y_min = [Math]::Max(0, [Math]::Min($obj.y_min, $imgObj.Height - 1))
                                $x_max = [Math]::Max($x_min + 1, [Math]::Min($obj.x_max, $imgObj.Width))
                                $y_max = [Math]::Max($y_min + 1, [Math]::Min($obj.y_max, $imgObj.Height))
                                $width = $x_max - $x_min
                                $height = $y_max - $y_min
                                if ($width -le 0 -or $height -le 0) { continue }
                                $cropRect = [System.Drawing.Rectangle]::new($x_min, $y_min, $width, $height)
                                $croppedBitmap = [System.Drawing.Bitmap]::new($width, $height)
                                $croppedGraphics = [System.Drawing.Graphics]::FromImage($croppedBitmap)
                                $destRect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
                                $null = $croppedGraphics.DrawImage($imgObj, $destRect, $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
                                $croppedGraphics.Dispose()
                                $objectLabel = if ($obj.label) { $obj.label } else { "object$objectIdx" }
                                $objectLabel = $objectLabel -replace '[^\w\-_]', '_'
                                $outFile = Microsoft.PowerShell.Management\Join-Path $OutputDirectory ("${imgBase}_${objectLabel}_${objectIdx}.png")
                                $croppedBitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
                                $croppedBitmap.Dispose()
                                $savedObjectRects += @{x_min=$x_min;y_min=$y_min;x_max=$x_max;y_max=$y_max}
                                $objectIdx++
                            }
                            # Save unknown persons if requested
                            if ($SaveUnknownPersons -and $image.people -and $image.people.predictions) {
                                $personIdx = 0
                                foreach ($person in $image.people.predictions) {
                                    try {
                                        $x_min = [Math]::Max(0, [Math]::Min($person.x_min, $imgObj.Width - 1))
                                        $y_min = [Math]::Max(0, [Math]::Min($person.y_min, $imgObj.Height - 1))
                                        $x_max = [Math]::Max($x_min + 1, [Math]::Min($person.x_max, $imgObj.Width))
                                        $y_max = [Math]::Max($y_min + 1, [Math]::Min($person.y_max, $imgObj.Height))
                                        $width = $x_max - $x_min
                                        $height = $y_max - $y_min
                                        if ($width -le 0 -or $height -le 0) { continue }
                                        # Check if this person overlaps with any saved object
                                        $overlap = $false
                                        foreach ($rect in $savedObjectRects) {
                                            if ((($x_min -le $rect.x_max) -and ($x_max -ge $rect.x_min)) -and (($y_min -le $rect.y_max) -and ($y_max -ge $rect.y_min))) {
                                                $overlap = $true
                                                break
                                            }
                                        }
                                        if ($overlap) { continue }
                                        $cropRect = [System.Drawing.Rectangle]::new($x_min, $y_min, $width, $height)
                                        $croppedBitmap = [System.Drawing.Bitmap]::new($width, $height)
                                        $croppedGraphics = [System.Drawing.Graphics]::FromImage($croppedBitmap)
                                        $destRect = [System.Drawing.Rectangle]::new(0, 0, $width, $height)
                                        $null = $croppedGraphics.DrawImage($imgObj, $destRect, $cropRect, [System.Drawing.GraphicsUnit]::Pixel)
                                        $croppedGraphics.Dispose()
                                        $outFile = Microsoft.PowerShell.Management\Join-Path $OutputDirectory ("${imgBase}_unknownperson_${personIdx}.png")
                                        $croppedBitmap.Save($outFile, [System.Drawing.Imaging.ImageFormat]::Png)
                                        $croppedBitmap.Dispose()
                                        $personIdx++
                                    }
                                    catch {
                                        Microsoft.PowerShell.Utility\Write-Warning "Failed to crop/save unknown person for $($imgPath): $_"
                                    }
                                }
                            }
                        }
                        finally {
                            if ($null -ne $ImageObj) { $imageObj.Dispose() }
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Warning "Failed to crop/save objects for $($imgPath): $_"
                    }
                }
                $info.resultCount++
                Microsoft.PowerShell.Utility\Write-Output $image
            }
        }

        if ($null -ne $InputObject) {

            $InputObject | Microsoft.PowerShell.Core\ForEach-Object { saveImage $_ }
        }
        else
         {
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Find-IndexedImage" `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            )

            GenXdev.AI\Find-IndexedImage @params | Microsoft.PowerShell.Core\ForEach-Object { saveImage $_ }
         }
    }
}
################################################################################
