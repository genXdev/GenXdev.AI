################################################################################
<#
.SYNOPSIS
Retrieves comprehensive statistics and information about the image database.

.DESCRIPTION
Provides detailed statistics about the SQLite image database including record
counts, index usage, most common keywords, people, objects, and scenes. Useful
for understanding database health and content distribution.

.PARAMETER DatabaseFilePath
Optional path to the SQLite database file. If not specified, uses the default
location under Storage\allimages.meta.db.

.PARAMETER ShowDetails
Shows detailed statistics including top keywords, people, objects, and scenes.

.EXAMPLE
Get-ImageDatabaseStat

.EXAMPLE
Get-ImageDatabaseStat -ShowDetails
#>
function Get-ImageDatabaseStats {

    [CmdletBinding()]
    # Suppress PSScriptAnalyzer PSUseSingularNouns rule for this function
    [System.Diagnostics.CodeAnalysis.SuppressMessage('PSUseSingularNouns', '')]
    [Alias("getimagedbstats", "gids")]
    param(
        ########################################################################
        [Parameter(
            HelpMessage = "Path to the SQLite database file"
        )]
        [string]$DatabaseFilePath,
        ########################################################################
        [Parameter(
            HelpMessage = "Show detailed statistics including top items"
        )]
        [switch]$ShowDetails
        ########################################################################
    )

    begin {

        # determine database file path if not provided
        if ([String]::IsNullOrWhiteSpace($DatabaseFilePath)) {

            $DatabaseFilePath = GenXdev.FileSystem\Expand-Path "$($ENV:LOCALAPPDATA)\GenXdev.PowerShell\allimages.meta.db"
        }
        else {
            $DatabaseFilePath = GenXdev.FileSystem\Expand-Path $DatabaseFilePath
        }

        # check if database exists
        if (-not (Microsoft.PowerShell.Management\Test-Path $DatabaseFilePath)) {

            throw "Image database not found at: $DatabaseFilePath. Please run Export-ImageDatabase first."
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Using database: $DatabaseFilePath"
    }

    process {

        # show cool progress effects while gathering stats
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Status "Analyzing database structure..." -PercentComplete 0

        # get basic table counts
        $imageCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM Images").count
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Status "Counting records..." -PercentComplete 20

        $keywordCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM ImageKeywords").count
        $peopleCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM ImagePeople").count
        $objectCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM ImageObjects").count
        $sceneCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM ImageScenes").count

        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Status "Analyzing content types..." -PercentComplete 40

        # get content analysis
        $pictureTypeStats = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT picture_type, COUNT(*) as count
FROM Images
WHERE picture_type IS NOT NULL AND picture_type != ''
GROUP BY picture_type
ORDER BY count DESC
"@

        $moodStats = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT overall_mood_of_image, COUNT(*) as count
FROM Images
WHERE overall_mood_of_image IS NOT NULL AND overall_mood_of_image != ''
GROUP BY overall_mood_of_image
ORDER BY count DESC
"@

        $styleStats = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT style_type, COUNT(*) as count
FROM Images
WHERE style_type IS NOT NULL AND style_type != ''
GROUP BY style_type
ORDER BY count DESC
"@

        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Status "Calculating content flags..." -PercentComplete 60

        # get content flags
        $explicitContentCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM Images WHERE has_explicit_content = 1").count
        $nudityCount = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(*) as count FROM Images WHERE has_nudity = 1").count

        # get file statistics
        $dbFileInfo = Microsoft.PowerShell.Management\Get-Item $DatabaseFilePath
        $dbSizeMB = [Math]::Round($dbFileInfo.Length / 1MB, 2)

        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Status "Gathering detailed statistics..." -PercentComplete 80

        # create basic statistics object
        $stats = [PSCustomObject]@{
            DatabasePath = $DatabaseFilePath
            DatabaseSizeMB = $dbSizeMB
            LastModified = $dbFileInfo.LastWriteTime
            TotalImages = $imageCount
            TotalKeywords = $keywordCount
            TotalPeopleEntries = $peopleCount
            TotalObjectEntries = $objectCount
            TotalSceneEntries = $sceneCount
            ImagesWithExplicitContent = $explicitContentCount
            ImagesWithNudity = $nudityCount
            PictureTypes = $pictureTypeStats
            Moods = $moodStats
            Styles = $styleStats
        }

        # get detailed statistics if requested
        if ($ShowDetails) {
            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Status "Finding top keywords..." -PercentComplete 0

            $topKeywords = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT keyword, COUNT(*) as count
FROM ImageKeywords
GROUP BY keyword
ORDER BY count DESC
LIMIT 20
"@

            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Status "Finding top people..." -PercentComplete 25

            $topPeople = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT person_name, COUNT(*) as count
FROM ImagePeople
GROUP BY person_name
ORDER BY count DESC
LIMIT 20
"@

            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Status "Finding top objects..." -PercentComplete 50

            $topObjects = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT object_name, COUNT(*) as count
FROM ImageObjects
GROUP BY object_name
ORDER BY count DESC
LIMIT 20
"@

            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Status "Finding top scenes..." -PercentComplete 75

            $topScenes = GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries @"
SELECT scene_name, COUNT(*) as count, AVG(confidence) as avg_confidence
FROM ImageScenes
GROUP BY scene_name
ORDER BY count DESC
LIMIT 20
"@

            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Status "Analyzing unique counts..." -PercentComplete 90

            $uniqueKeywords = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(DISTINCT keyword) as count FROM ImageKeywords").count
            $uniquePeople = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(DISTINCT person_name) as count FROM ImagePeople").count
            $uniqueObjects = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(DISTINCT object_name) as count FROM ImageObjects").count
            $uniqueScenes = (GenXdev.Data\Invoke-SQLiteQuery -DatabaseFilePath $DatabaseFilePath -Queries "SELECT COUNT(DISTINCT scene_name) as count FROM ImageScenes").count

            # add detailed stats to the object
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "UniqueKeywords" -NotePropertyValue $uniqueKeywords
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "UniquePeople" -NotePropertyValue $uniquePeople
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "UniqueObjects" -NotePropertyValue $uniqueObjects
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "UniqueScenes" -NotePropertyValue $uniqueScenes
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "TopKeywords" -NotePropertyValue $topKeywords
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "TopPeople" -NotePropertyValue $topPeople
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "TopObjects" -NotePropertyValue $topObjects
            $stats | Microsoft.PowerShell.Utility\Add-Member -NotePropertyName "TopScenes" -NotePropertyValue $topScenes

            Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Status "✅ Detailed analysis complete!" -PercentComplete 100
        }

        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Status "✅ Statistics gathered successfully!" -PercentComplete 100

        Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500
        Microsoft.PowerShell.Utility\Write-Progress -Id 2 -ParentId 1 -Activity "🔍 Detailed Analysis" -Completed
        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "📊 Gathering Database Statistics" -Completed

        # display formatted output
        Microsoft.PowerShell.Utility\Write-Host ""
        Microsoft.PowerShell.Utility\Write-Host "🗄️  IMAGE DATABASE STATISTICS" -ForegroundColor Cyan
        Microsoft.PowerShell.Utility\Write-Host "═══════════════════════════════════════════════════════════════" -ForegroundColor DarkCyan
        Microsoft.PowerShell.Utility\Write-Host ""
        Microsoft.PowerShell.Utility\Write-Host "📍 Database Location: " -NoNewline -ForegroundColor Yellow
        Microsoft.PowerShell.Utility\Write-Host $stats.DatabasePath -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "💾 Database Size: " -NoNewline -ForegroundColor Yellow
        Microsoft.PowerShell.Utility\Write-Host "$($stats.DatabaseSizeMB) MB" -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "🕐 Last Modified: " -NoNewline -ForegroundColor Yellow
        Microsoft.PowerShell.Utility\Write-Host $stats.LastModified -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host ""
        Microsoft.PowerShell.Utility\Write-Host "📊 RECORD COUNTS" -ForegroundColor Green
        Microsoft.PowerShell.Utility\Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor DarkGreen
        Microsoft.PowerShell.Utility\Write-Host "🖼️  Total Images: " -NoNewline -ForegroundColor Magenta
        Microsoft.PowerShell.Utility\Write-Host $stats.TotalImages.ToString("N0") -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "🔖 Total Keywords: " -NoNewline -ForegroundColor Magenta
        Microsoft.PowerShell.Utility\Write-Host $stats.TotalKeywords.ToString("N0") -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "👥 Total People Entries: " -NoNewline -ForegroundColor Magenta
        Microsoft.PowerShell.Utility\Write-Host $stats.TotalPeopleEntries.ToString("N0") -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "🎯 Total Object Entries: " -NoNewline -ForegroundColor Magenta
        Microsoft.PowerShell.Utility\Write-Host $stats.TotalObjectEntries.ToString("N0") -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "🎬 Total Scene Entries: " -NoNewline -ForegroundColor Magenta
        Microsoft.PowerShell.Utility\Write-Host $stats.TotalSceneEntries.ToString("N0") -ForegroundColor White

        if ($ShowDetails) {
            Microsoft.PowerShell.Utility\Write-Host ""
            Microsoft.PowerShell.Utility\Write-Host "🔢 UNIQUE COUNTS" -ForegroundColor Blue
            Microsoft.PowerShell.Utility\Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor DarkBlue
            Microsoft.PowerShell.Utility\Write-Host "🔖 Unique Keywords: " -NoNewline -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host $stats.UniqueKeywords.ToString("N0") -ForegroundColor White
            Microsoft.PowerShell.Utility\Write-Host "👥 Unique People: " -NoNewline -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host $stats.UniquePeople.ToString("N0") -ForegroundColor White
            Microsoft.PowerShell.Utility\Write-Host "🎯 Unique Objects: " -NoNewline -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host $stats.UniqueObjects.ToString("N0") -ForegroundColor White
            Microsoft.PowerShell.Utility\Write-Host "🎬 Unique Scenes: " -NoNewline -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host $stats.UniqueScenes.ToString("N0") -ForegroundColor White
        }

        Microsoft.PowerShell.Utility\Write-Host ""
        Microsoft.PowerShell.Utility\Write-Host "⚠️  CONTENT FLAGS" -ForegroundColor Red
        Microsoft.PowerShell.Utility\Write-Host "───────────────────────────────────────────────────────────────" -ForegroundColor DarkRed
        Microsoft.PowerShell.Utility\Write-Host "🔞 Explicit Content: " -NoNewline -ForegroundColor Red
        Microsoft.PowerShell.Utility\Write-Host "$($stats.ImagesWithExplicitContent.ToString('N0')) images" -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "🔞 Nudity: " -NoNewline -ForegroundColor Red
        Microsoft.PowerShell.Utility\Write-Host "$($stats.ImagesWithNudity.ToString('N0')) images" -ForegroundColor White

        Microsoft.PowerShell.Utility\Write-Host ""

        return $stats
    }

    end {
    }
}
################################################################################
