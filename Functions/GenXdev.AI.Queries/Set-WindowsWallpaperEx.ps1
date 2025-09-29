<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Set-WindowsWallpaperEx.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.288.2025
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
################################################################################
<#
.SYNOPSIS
Sets a random wallpaper from a specified directory or search criteria.

.DESCRIPTION
Selects a random image file from the specified directory or search criteria and
sets it as the Windows desktop wallpaper. Supports JPG/JPEG image formats and
configures the wallpaper to "fit" the screen by default. Allows advanced
filtering by metadata, language, and other properties using either direct file
search or indexed image database search.

.PARAMETER InputObject
The file path pattern or object to search for wallpaper images. Supports
wildcards and recursive search. This is the path to the directory containing
the wallpaper images. When multiple images are found, one is selected at
random.

.PARAMETER DontUseImageIndex
Switch to disable the indexed image search and use direct file search instead.
When specified, the function uses Find-Image instead of Find-IndexedImage for
locating wallpaper candidates.

.PARAMETER Any
Array of metadata search terms that will match any of all the possible meta
data types including descriptions, keywords, people, objects, scenes, picture
types, style types, and overall moods.

.PARAMETER DatabaseFilePath
The path to the image database file. If not specified, a default path is used
based on the configured preferences and system settings.

.PARAMETER ImageDirectories
Array of directory paths to search for images. These directories will be
scanned for suitable wallpaper images matching the specified criteria.

.PARAMETER PathLike
Array of directory path-like search strings to filter images by path using SQL
LIKE patterns. For example, '%\2024\%' would match any path containing '\2024\'.

.PARAMETER Language
Language for descriptions and keywords. Must be one of the supported languages
from the ValidateSet. Controls the language used for metadata search terms.

.PARAMETER FacesDirectory
The directory containing face images organized by person folders. If not
specified, uses the configured faces directory preference from the system
settings.

.PARAMETER DescriptionSearch
Array of description text patterns to look for in image metadata. Wildcards
are allowed for flexible matching of image descriptions.

.PARAMETER Keywords
Array of keywords to look for in image metadata. Wildcards are allowed for
flexible matching of tagged keywords.

.PARAMETER People
Array of people names to look for in image metadata. Wildcards are allowed for
flexible matching of recognized faces or tagged people.

.PARAMETER Objects
Array of object names to look for in image metadata. Wildcards are allowed for
flexible matching of recognized objects in images.

.PARAMETER Scenes
Array of scene types to look for in image metadata. Wildcards are allowed for
flexible matching of scene classifications.

.PARAMETER PictureType
Array of picture types to filter by in image metadata. Wildcards are allowed
for flexible matching of image categorizations.

.PARAMETER StyleType
Array of style types to filter by in image metadata. Wildcards are allowed
for flexible matching of artistic or photographic styles.

.PARAMETER OverallMood
Array of overall moods to filter by in image metadata. Wildcards are allowed
for flexible matching of emotional or atmospheric classifications.

.PARAMETER ForceIndexRebuild
Switch to force rebuild of the image index database before searching. This
ensures the most up-to-date index but may take significant time.

.PARAMETER NoFallback
Switch to disable fallback behavior when no images match the specified
criteria. When enabled, the function will return nothing instead of using
default behavior.

.PARAMETER GeoLocation
Array of geographic coordinates [latitude, longitude] to search near for
geotagged images. Used to find images taken within a specific geographic area.

.PARAMETER GeoDistanceInMeters
Maximum distance in meters from GeoLocation to search for images. Defaults to
1000 meters. Only applies when GeoLocation is specified.

.PARAMETER NeverRebuild
Switch to skip database initialization and rebuilding entirely. This can
improve performance but may result in outdated index information.

.PARAMETER HasNudity
Switch to filter for images that contain nudity based on content analysis.
Only images flagged as containing nudity will be included.

.PARAMETER NoNudity
Switch to filter out images that contain nudity based on content analysis.
Images flagged as containing nudity will be excluded from results.

.PARAMETER HasExplicitContent
Switch to filter for images that contain explicit content based on content
analysis. Only images flagged as explicit will be included.

.PARAMETER NoExplicitContent
Switch to filter out images that contain explicit content based on content
analysis. Images flagged as explicit will be excluded from results.

.PARAMETER SessionOnly
Switch to use alternative settings stored in session for AI preferences like
Language, Image collections, etc. instead of persistent configuration.

.PARAMETER ClearSession
Switch to clear alternative settings stored in session for AI preferences like
Language, Image collections, etc. before processing.

.PARAMETER PreferencesDatabasePath
Database path for preference data files. Overrides the default preference
database location for storing and retrieving user settings.

.PARAMETER SkipSession
Switch to not use alternative settings stored in session for AI preferences
like Language, Image collections, etc. Forces use of persistent configuration.

.PARAMETER AllDrives
Switch to search across all available drives when looking for wallpaper images
instead of limiting to specified directories.

.PARAMETER NoRecurse
Switch to disable recursive searching into subdirectories. Only the specified
directories will be searched without traversing subdirectories.

.EXAMPLE
Set-WindowsWallpaperEx -InputObject "C:\Wallpapers\*.jpg"
Sets a random wallpaper from JPG files in the specified directory.

.EXAMPLE
nextwallpaper
Sets a random wallpaper from the default wallpaper directory using the alias.
#>
################################################################################


function Set-WindowsWallpaperEx {

    [CmdLetBinding(SupportsShouldProcess = $true)]
    [OutputType([System.Object[]])]
    [Alias("nextwallpaper")]

    param (
        ###############################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = ('Path to the directory containing the wallpaper ' +
                'images')
        )]
        [Alias('Path', 'FullName', 'FilePath', 'Input')]
        [Object] $InputObject,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Switch to not using the indexed image search')
        )]
        [switch] $DontUseImageIndex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will match any of all the possible meta data ' +
                'types.')
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
            HelpMessage = 'Array of directory paths to search for images.'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of directory path-like search strings to ' +
                'filter images by path (SQL LIKE patterns, e.g. ' +
                '''%\2024\%'')')
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
                'person folders. If not specified, uses the configured ' +
                'faces directory preference.')
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The description text to look for, wildcards ' +
                'allowed.')
        )]
        [string[]] $DescriptionSearch,
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
            HelpMessage = ('Geographic coordinates [latitude, longitude] to ' +
                'search near.')
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
            HelpMessage = ('Switch to skip database initialization and ' +
                'rebuilding.')
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
            HelpMessage = ('Filter images that do NOT contain explicit ' +
                'content.')
        )]
        [switch] $NoExplicitContent,
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
                'AI preferences like Language, Image collections, etc.')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Alias('DatabasePath')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files.'
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
            HelpMessage = 'Search across all available drives'
        )]
        [switch] $AllDrives,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not recurse into subdirectories'
        )]
        [switch] $NoRecurse
        ###############################################################################
    )

    begin {

        # determine the search function to use based on index preference
        $searchFunction = $DontUseImageIndex ?
            "GenXdev.AI\Find-Image" :
            "GenXdev.AI\Find-IndexedImage"

        # output verbose information about the selected search method
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using search method: ${searchFunction}"
        )
    }

    process {

        # copy all relevant parameters for the called genxdev cmdlet
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName $searchFunction `
            -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\Where-Object `
                    -Property Name `
                    -ne "InputObject"
            )

        # find images using either the indexed or direct search method
        $foundImages = @(
            if ($DontUseImageIndex) {

                GenXdev.AI\Find-Image @params
            }
            else {

                GenXdev.AI\Find-IndexedImage @params
            }
        )

        # output verbose information about the number of images found
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Found $($foundImages.Count) candidate images"
        )

        # if no images are found, exit the function
        if ((-not $foundImages) -or ($foundImages.Count -eq 0)) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "No images found matching the specified criteria"
            )
            return
        }

        # select a random image from the found images
        ($foundImages |
            Microsoft.PowerShell.Core\ForEach-Object Path) |
            Microsoft.PowerShell.Utility\Get-Random |
            Microsoft.PowerShell.Utility\Select-Object -First 1 |
            Microsoft.PowerShell.Core\ForEach-Object {

                $file = $_

                # show the selected wallpaper path
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Selected wallpaper: ${file}"
                )

                # set wallpaper style to fit the screen (10 = fit, 0 = center)
                $wallpaperStyle = '10'

                # set tile wallpaper to off
                $tileWallpaper = '0'

                # update the registry with the new wallpaper path
                Microsoft.PowerShell.Management\Set-ItemProperty `
                    -Path 'HKCU:\Control Panel\Desktop\' `
                    -Name Wallpaper `
                    -Value $file

                # update the registry with the wallpaper style
                Microsoft.PowerShell.Management\Set-ItemProperty `
                    -Path 'HKCU:\Control Panel\Desktop\' `
                    -Name WallpaperStyle `
                    -Value $wallpaperStyle

                # update the registry with the tile wallpaper setting
                Microsoft.PowerShell.Management\Set-ItemProperty `
                    -Path 'HKCU:\Control Panel\Desktop\' `
                    -Name TileWallpaper `
                    -Value $tileWallpaper

                # define a c# class to access the windows api for updating
                # wallpaper
                Microsoft.PowerShell.Utility\Add-Type -TypeDefinition @'
        using System;
        using System.Runtime.InteropServices;

        public class Wallpaper {
            [DllImport("user32.dll", CharSet=CharSet.Auto)]
            public static extern int SystemParametersInfo (
                int uAction, int uParam, string lpvParam, int fuWinIni);
        }
'@ -ErrorAction SilentlyContinue

                # apply the wallpaper changes using the windows api
                # 20 = SPI_SETDESKWALLPAPER
                # 0x1 | 0x2 = SPIF_UPDATEINIFILE | SPIF_SENDWININICHANGE
                $null = [Wallpaper]::SystemParametersInfo(
                    20, 0, $file, 0x1 -bor 0x2
                )

                # inform the user that the wallpaper has been updated
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Wallpaper has been updated successfully'
                )
            }
    }

    end {

    }
}
################################################################################