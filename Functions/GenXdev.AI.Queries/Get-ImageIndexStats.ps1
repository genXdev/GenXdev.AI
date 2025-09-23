<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Get-ImageIndexStats.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.284.2025
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
Retrieves comprehensive statistics and information about the image database.

.DESCRIPTION
Provides detailed statistics about the SQLite image database including record
counts, index usage, most common keywords, people, objects, and scenes. Useful
for understanding database health and content distribution.

.PARAMETER DatabaseFilePath
The path to the image database file. If not specified, a default path is used.

.PARAMETER ImageDirectories
Array of directory paths to search for images.

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

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER ShowDetails
Show detailed statistics including top keywords, people, objects, and scenes.

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
Get-ImageIndexStats

.EXAMPLE
Get-ImageIndexStats -ShowDetails

.EXAMPLE
gids -ShowDetails
#>
################################################################################
function Get-ImageIndexStats {

    [CmdletBinding()]
    # suppress psscriptanalyzer psusesinguralnouns rule for this function
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseSingularNouns', '')]
    [Alias('getimagedbstats', 'gids')]
    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = ('The path to the image database file. If not ' +
                'specified, a default path is used.')
        )]
        [string] $DatabaseFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of directory paths to search for images'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of directory path-like search strings to ' +
                'filter images by path (SQL LIKE patterns, e.g. ' +
                "'%\\2024\\%')")
        )]
        [string[]] $PathLike = @(),
        ########################################################################
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
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized by ' +
                'person folders. If not specified, uses the ' +
                'configured faces directory preference.')
        )]
        [string] $FacesDirectory,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Embed images as base64.'
        )]
        [switch] $EmbedImages,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuild of the image index database.'
        )]
        [switch] $ForceIndexRebuild,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show detailed statistics including top items'
        )]
        [switch] $ShowDetails,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image ' +
                'collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # determine database file path if not provided
        if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            # copy identical parameter values for helper function call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.AI\Get-ImageIndexPath' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -ErrorAction SilentlyContinue)

            # get the default database path without rebuilding
            $DatabaseFilePath = GenXdev.AI\Get-ImageIndexPath @params `
                -NoFallback -NeverRebuild
        }
        else {
            # expand the provided path to full absolute path
            $DatabaseFilePath = GenXdev.FileSystem\Expand-Path $DatabaseFilePath
        }

        # check if database exists before proceeding
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $DatabaseFilePath)) {

            throw ("Image database not found at: $DatabaseFilePath. Please " +
                'run Export-ImageIndex first.')
        }

        # output verbose information about database location
        Microsoft.PowerShell.Utility\Write-Verbose "Using database: $DatabaseFilePath"
    }

    process {

        # show cool progress effects while gathering stats
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Status 'Analyzing database structure...' `
            -PercentComplete 0

        # get basic table counts from the main images table
        $imageCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries 'SELECT COUNT(*) as count FROM Images').count

        # update progress indicator for user feedback
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Status 'Counting records...' `
            -PercentComplete 20

        # count total keyword associations across all images
        $keywordCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries 'SELECT COUNT(*) as count FROM ImageKeywords').count

        # count total people associations across all images
        $peopleCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries 'SELECT COUNT(*) as count FROM ImagePeople').count

        # count total object associations across all images
        $objectCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries 'SELECT COUNT(*) as count FROM ImageObjects').count

        # count total scene associations across all images
        $sceneCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries 'SELECT COUNT(*) as count FROM ImageScenes').count

        # update progress indicator for content analysis phase
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Status 'Analyzing content types...' `
            -PercentComplete 40

        # get content analysis grouped by picture type with counts
        $pictureTypeStats = GenXdev.Data\Invoke-SQLiteQuery `
            -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT picture_type, COUNT(*) as count
FROM Images
WHERE picture_type IS NOT NULL AND picture_type != ''
GROUP BY picture_type
ORDER BY count DESC
'@

        # get mood analysis grouped by overall mood with counts
        $moodStats = GenXdev.Data\Invoke-SQLiteQuery `
            -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT overall_mood_of_image, COUNT(*) as count
FROM Images
WHERE overall_mood_of_image IS NOT NULL AND overall_mood_of_image != ''
GROUP BY overall_mood_of_image
ORDER BY count DESC
'@

        # get style analysis grouped by style type with counts
        $styleStats = GenXdev.Data\Invoke-SQLiteQuery `
            -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT style_type, COUNT(*) as count
FROM Images
WHERE style_type IS NOT NULL AND style_type != ''
GROUP BY style_type
ORDER BY count DESC
'@

        # update progress indicator for content flags calculation
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Status 'Calculating content flags...' `
            -PercentComplete 60

        # count images flagged with explicit content
        $explicitContentCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries ('SELECT COUNT(*) as count FROM ' +
                'Images WHERE has_explicit_content = 1')).count

        # count images flagged with nudity content
        $nudityCount = (GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath `
                -Queries ('SELECT COUNT(*) as count FROM Images ' +
                'WHERE has_nudity = 1')).count

        # get file statistics for database size and modification time
        $dbFileInfo = Microsoft.PowerShell.Management\Get-Item -LiteralPath $DatabaseFilePath

        # calculate database size in megabytes rounded to 2 decimal places
        $dbSizeMB = [Math]::Round($dbFileInfo.Length / 1MB, 2)

        # update progress indicator for final statistics gathering
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Status 'Gathering detailed statistics...' `
            -PercentComplete 80

        # create basic statistics object with core database information
        $stats = [PSCustomObject]@{
            DatabasePath              = $DatabaseFilePath
            DatabaseSizeMB            = $dbSizeMB
            LastModified              = $dbFileInfo.LastWriteTime
            TotalImages               = $imageCount
            TotalKeywords             = $keywordCount
            TotalPeopleEntries        = $peopleCount
            TotalObjectEntries        = $objectCount
            TotalSceneEntries         = $sceneCount
            ImagesWithExplicitContent = $explicitContentCount
            ImagesWithNudity          = $nudityCount
            PictureTypes              = $pictureTypeStats
            Moods                     = $moodStats
            Styles                    = $styleStats
        }

        # get detailed statistics if requested by the user
        if ($ShowDetails) {
            # start nested progress indicator for detailed analysis
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
                -Activity '🔍 Detailed Analysis' `
                -Status 'Finding top keywords...' `
                -PercentComplete 0

            # find top 20 most common keywords across all images
            $topKeywords = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT keyword, COUNT(*) as count
FROM ImageKeywords
GROUP BY keyword
ORDER BY count DESC
LIMIT 20
'@

            # update detailed analysis progress
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
                -Activity '🔍 Detailed Analysis' `
                -Status 'Finding top people...' `
                -PercentComplete 25

            # find top 20 most recognized people across all images
            $topPeople = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT person_name, COUNT(*) as count
FROM ImagePeople
GROUP BY person_name
ORDER BY count DESC
LIMIT 20
'@

            # update detailed analysis progress
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
                -Activity '🔍 Detailed Analysis' `
                -Status 'Finding top objects...' `
                -PercentComplete 50

            # find top 20 most detected objects across all images
            $topObjects = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT object_name, COUNT(*) as count
FROM ImageObjects
GROUP BY object_name
ORDER BY count DESC
LIMIT 20
'@

            # update detailed analysis progress
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
                -Activity '🔍 Detailed Analysis' `
                -Status 'Finding top scenes...' `
                -PercentComplete 75

            # find top 20 most common scenes with average confidence scores
            $topScenes = GenXdev.Data\Invoke-SQLiteQuery `
                -DatabaseFilePath $DatabaseFilePath -Queries @'
SELECT scene_name, COUNT(*) as count, AVG(confidence) as avg_confidence
FROM ImageScenes
GROUP BY scene_name
ORDER BY count DESC
LIMIT 20
'@

            # update detailed analysis progress for unique counts
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
                -Activity '🔍 Detailed Analysis' `
                -Status 'Analyzing unique counts...' `
                -PercentComplete 90

            # count unique keywords to show vocabulary diversity
            $uniqueKeywords = (GenXdev.Data\Invoke-SQLiteQuery `
                    -DatabaseFilePath $DatabaseFilePath `
                    -Queries ('SELECT COUNT(DISTINCT keyword) as ' +
                    'count FROM ImageKeywords')).count

            # count unique people to show recognition diversity
            $uniquePeople = (GenXdev.Data\Invoke-SQLiteQuery `
                    -DatabaseFilePath $DatabaseFilePath `
                    -Queries ('SELECT COUNT(DISTINCT person_name) as ' +
                    'count FROM ImagePeople')).count

            # count unique objects to show detection diversity
            $uniqueObjects = (GenXdev.Data\Invoke-SQLiteQuery `
                    -DatabaseFilePath $DatabaseFilePath `
                    -Queries ('SELECT COUNT(DISTINCT object_name) as ' +
                    'count FROM ImageObjects')).count

            # count unique scenes to show scene recognition diversity
            $uniqueScenes = (GenXdev.Data\Invoke-SQLiteQuery `
                    -DatabaseFilePath $DatabaseFilePath `
                    -Queries ('SELECT COUNT(DISTINCT scene_name) as ' +
                    'count FROM ImageScenes')).count

            # add detailed stats to the statistics object dynamically
            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'UniqueKeywords' `
                -NotePropertyValue $uniqueKeywords

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'UniquePeople' `
                -NotePropertyValue $uniquePeople

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'UniqueObjects' `
                -NotePropertyValue $uniqueObjects

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'UniqueScenes' `
                -NotePropertyValue $uniqueScenes

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'TopKeywords' `
                -NotePropertyValue $topKeywords

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'TopPeople' `
                -NotePropertyValue $topPeople

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'TopObjects' `
                -NotePropertyValue $topObjects

            $stats | Microsoft.PowerShell.Utility\Add-Member `
                -NotePropertyName 'TopScenes' `
                -NotePropertyValue $topScenes

            # complete detailed analysis progress
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
                -Activity '🔍 Detailed Analysis' `
                -Status '✅ Detailed analysis complete!' `
                -PercentComplete 100
        }

        # complete main statistics gathering progress
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Status '✅ Statistics gathered successfully!' `
            -PercentComplete 100

        # brief pause to show completion status
        Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500

        # clean up progress indicators
        Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 `
            -Activity '🔍 Detailed Analysis' `
            -Completed

        Microsoft.PowerShell.Utility\Write-Progress -Id 1 `
            -Activity '📊 Gathering Database Statistics' `
            -Completed

        # display formatted output with visual header
        Microsoft.PowerShell.Utility\Write-Host ''

        Microsoft.PowerShell.Utility\Write-Host '🗄️  IMAGE DATABASE STATISTICS' `
            -ForegroundColor Cyan

        Microsoft.PowerShell.Utility\Write-Host ('═══════════════════════════════════════' +
            '════════════════════════════════') `
            -ForegroundColor DarkCyan

        Microsoft.PowerShell.Utility\Write-Host ''

        # display database location information
        Microsoft.PowerShell.Utility\Write-Host '📍 Database Location: ' `
            -NoNewline -ForegroundColor Yellow

        Microsoft.PowerShell.Utility\Write-Host $stats.DatabasePath `
            -ForegroundColor White

        # display database size information
        Microsoft.PowerShell.Utility\Write-Host '💾 Database Size: ' `
            -NoNewline -ForegroundColor Yellow

        Microsoft.PowerShell.Utility\Write-Host "$($stats.DatabaseSizeMB) MB" `
            -ForegroundColor White

        # display last modification timestamp
        Microsoft.PowerShell.Utility\Write-Host '🕐 Last Modified: ' `
            -NoNewline -ForegroundColor Yellow

        Microsoft.PowerShell.Utility\Write-Host $stats.LastModified `
            -ForegroundColor White

        Microsoft.PowerShell.Utility\Write-Host ''

        # display record counts section with visual separator
        Microsoft.PowerShell.Utility\Write-Host '📊 RECORD COUNTS' `
            -ForegroundColor Green

        Microsoft.PowerShell.Utility\Write-Host ('───────────────────────────────────────' +
            '────────────────────────────────') `
            -ForegroundColor DarkGreen

        # display total images count with formatting
        Microsoft.PowerShell.Utility\Write-Host '🖼️  Total Images: ' `
            -NoNewline -ForegroundColor Magenta

        Microsoft.PowerShell.Utility\Write-Host $stats.TotalImages.ToString('N0') `
            -ForegroundColor White

        # display total keywords count with formatting
        Microsoft.PowerShell.Utility\Write-Host '🔖 Total Keywords: ' `
            -NoNewline -ForegroundColor Magenta

        Microsoft.PowerShell.Utility\Write-Host $stats.TotalKeywords.ToString('N0') `
            -ForegroundColor White

        # display total people entries count with formatting
        Microsoft.PowerShell.Utility\Write-Host '👥 Total People Entries: ' `
            -NoNewline -ForegroundColor Magenta

        Microsoft.PowerShell.Utility\Write-Host $stats.TotalPeopleEntries.ToString('N0') `
            -ForegroundColor White

        # display total object entries count with formatting
        Microsoft.PowerShell.Utility\Write-Host '🎯 Total Object Entries: ' `
            -NoNewline -ForegroundColor Magenta

        Microsoft.PowerShell.Utility\Write-Host $stats.TotalObjectEntries.ToString('N0') `
            -ForegroundColor White

        # display total scene entries count with formatting
        Microsoft.PowerShell.Utility\Write-Host '🎬 Total Scene Entries: ' `
            -NoNewline -ForegroundColor Magenta

        Microsoft.PowerShell.Utility\Write-Host $stats.TotalSceneEntries.ToString('N0') `
            -ForegroundColor White

        # display detailed unique counts if requested
        if ($ShowDetails) {
            Microsoft.PowerShell.Utility\Write-Host ''

            # display unique counts section with visual separator
            Microsoft.PowerShell.Utility\Write-Host '🔢 UNIQUE COUNTS' `
                -ForegroundColor Blue

            Microsoft.PowerShell.Utility\Write-Host ('───────────────────────────────────────' +
                '────────────────────────────────') `
                -ForegroundColor DarkBlue

            # display unique keywords count
            Microsoft.PowerShell.Utility\Write-Host '🔖 Unique Keywords: ' `
                -NoNewline -ForegroundColor Cyan

            Microsoft.PowerShell.Utility\Write-Host $stats.UniqueKeywords.ToString('N0') `
                -ForegroundColor White

            # display unique people count
            Microsoft.PowerShell.Utility\Write-Host '👥 Unique People: ' `
                -NoNewline -ForegroundColor Cyan

            Microsoft.PowerShell.Utility\Write-Host $stats.UniquePeople.ToString('N0') `
                -ForegroundColor White

            # display unique objects count
            Microsoft.PowerShell.Utility\Write-Host '🎯 Unique Objects: ' `
                -NoNewline -ForegroundColor Cyan

            Microsoft.PowerShell.Utility\Write-Host $stats.UniqueObjects.ToString('N0') `
                -ForegroundColor White

            # display unique scenes count
            Microsoft.PowerShell.Utility\Write-Host '🎬 Unique Scenes: ' `
                -NoNewline -ForegroundColor Cyan

            Microsoft.PowerShell.Utility\Write-Host $stats.UniqueScenes.ToString('N0') `
                -ForegroundColor White
        }

        Microsoft.PowerShell.Utility\Write-Host ''

        # display content flags section with visual separator
        Microsoft.PowerShell.Utility\Write-Host '⚠️  CONTENT FLAGS' `
            -ForegroundColor Red

        Microsoft.PowerShell.Utility\Write-Host ('───────────────────────────────────────' +
            '────────────────────────────────') `
            -ForegroundColor DarkRed

        # display explicit content count with warning styling
        Microsoft.PowerShell.Utility\Write-Host '🔞 Explicit Content: ' `
            -NoNewline -ForegroundColor Red

        Microsoft.PowerShell.Utility\Write-Host ("$($stats.ImagesWithExplicitContent.ToString('N0')) " +
            'images') `
            -ForegroundColor White

        # display nudity content count with warning styling
        Microsoft.PowerShell.Utility\Write-Host '🔞 Nudity: ' `
            -NoNewline -ForegroundColor Red

        Microsoft.PowerShell.Utility\Write-Host ("$($stats.ImagesWithNudity.ToString('N0')) " +
            'images') `
            -ForegroundColor White

        Microsoft.PowerShell.Utility\Write-Host ''

        # return the statistics object for programmatic use
        return $stats
    }

    end {
    }
}
################################################################################