<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Invoke-ImageMetadataUpdate.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.290.2025
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
Updates EXIF metadata for images in a directory.

.DESCRIPTION
This function extracts and updates EXIF metadata for images in specified directories.
It processes each image to extract detailed EXIF metadata including camera details,
GPS coordinates, exposure settings, and other technical information. The metadata
is stored in alternate NTFS streams as :EXIF.json for later use by indexing and
search functions.

.PARAMETER ImageDirectories
Array of directory paths to process for image metadata updates.

.PARAMETER RetryFailed
Specifies whether to retry previously failed image metadata updates.

.PARAMETER OnlyNew
If specified, only processes images that don't already have metadata files or
have empty metadata files.

.PARAMETER Recurse
If specified, processes images in the specified directory and all
subdirectories recursively.

.PARAMETER Force
Force rebuilding of metadata even if it already exists.

.PARAMETER PassThru
Return structured objects instead of outputting to console.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER SkipSession
Don't use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.EXAMPLE
Invoke-ImageMetadataUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Force

.EXAMPLE
Invoke-ImageMetadataUpdate @("C:\Photos", "C:\Archive") -Force -PassThru | Export-Csv -Path metadata-log.csv
#>
###############################################################################
function Invoke-ImageMetadataUpdate {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('imagepropdetection')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Array of directory paths to process for image metadata updates'
        )]
        [string[]] $ImageDirectories = @('.\'),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will retry previously failed image metadata updates'
        )]
        [switch] $RetryFailed,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only process images that don''t already have metadata files'
        )]
        [switch] $OnlyNew,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, processes images in subdirectories recursively'
        )]
        [switch] $Recurse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuilding of metadata even if it already exists'
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return structured objects instead of outputting to console'
        )]
        [Alias('pt')]
        [switch]$PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Don''t use alternative settings stored in ' +
                'session for AI preferences like Language, Image ' +
                'collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath
        ###############################################################################
    )

    begin {
        # process each directory provided
        $processedDirectories = @()
        foreach ($directory in $ImageDirectories) {
            # resolve the absolute path for the image directory
            $path = GenXdev.FileSystem\Expand-Path $directory

            # check if the specified directory exists
            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $path -PathType Container)) {
                Microsoft.PowerShell.Utility\Write-Warning "Directory not found: $path - skipping"
                continue
            }

            $processedDirectories += $path
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing images in directory: $path"
            )
        }

        if ($processedDirectories.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Warning "No valid directories found to process"
            return
        }

        # Set flags for processing behavior

        Microsoft.PowerShell.Utility\Write-Verbose "Starting metadata extraction for images..."
    }

    process {
        # process each validated directory
        foreach ($path in $processedDirectories) {
            Microsoft.PowerShell.Utility\Write-Verbose "Processing directory: $path"

            # discover all image files in the specified directory path, selectively
            # applying recursion only if the -Recurse switch was provided
            # get all supported image files from the specified directory
            $imageTypes = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".tiff", ".tif")
            $findParams = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.FileSystem\Find-Item" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            # Add NoRecurse parameter if Recurse was not specified
            if (-not $Recurse) {
                $findParams['NoRecurse'] = $true
            }

            # Get all image files matching the criteria
            GenXdev.FileSystem\Find-Item @findParams -PassThru -SearchMask "$path\*" -Directory:$false | Microsoft.PowerShell.Core\Where-Object {
                $imageTypes.IndexOf(([IO.Path]::GetExtension($_.FullName).ToLowerInvariant())) -ge 0
            } | Microsoft.PowerShell.Core\ForEach-Object {
                try {
                    $imagePath = $_.FullName

                    # Generate the NTFS alternate stream path for metadata
                    $metadataStream = "${imagePath}:EXIF.json"

                    # Check if we have valid existing content (for RetryFailed logic)
                    $fileExists = [System.IO.File]::Exists($metadataStream)
                    $hasValidContent = $false
                    if ($fileExists) {
                        try {
                            $content = [System.IO.File]::ReadAllText($metadataStream)
                            $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue
                            # Content is valid if it's successful processing OR if it has actual metadata (not just failure JSON)
                            $hasValidContent = (($null -ne $existingData) -and ($existingData.PSObject.Properties.Count -gt 0)) -and
                                              (-not ($existingData.success -eq $false))
                        }
                        catch {
                            $hasValidContent = $false
                        }
                    }

                    # Check if we should process this image
                    # Process if: Force OR not OnlyNew OR file doesn't exist OR (RetryFailed and no valid content)
                    $shouldProcess = $Force -or
                                    (-not $OnlyNew) -or
                                    (-not $fileExists) -or
                                    ($RetryFailed -and (-not $hasValidContent))

                    if (-not $shouldProcess) {

                        return;
                    }

                    # Validate file exists and is accessible before processing
                    if (-not [System.IO.File]::Exists($imagePath)) {
                        Microsoft.PowerShell.Utility\Write-Warning "Image file not found: $imagePath"
                        return
                    }

                    # Check file size - skip very large files that might cause memory issues
                    $fileInfo = [System.IO.FileInfo]::new($imagePath)
                    if ($fileInfo.Length -gt 1024*1024*300) {
                        Microsoft.PowerShell.Utility\Write-Warning "Skipping large file (${fileInfo.Length} bytes): $imagePath"
                        return
                    }

                    # Test if file is readable by trying to open it
                    try {
                        $testStream = [System.IO.File]::OpenRead($imagePath)
                        $testStream.Close()
                        $testStream.Dispose()
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Warning "Cannot read file (may be locked or corrupted): $imagePath"
                        return
                    }

                    # Extract metadata using Get-ImageMetadata with proper error handling
                    try {
                        $metadata = GenXdev.Helpers\Get-ImageMetadata -ImagePath $imagePath -ErrorAction Stop
                    }
                    catch {
                        # Handle out of memory and other metadata extraction errors
                        Microsoft.PowerShell.Utility\Write-Warning "Failed to process metadata for ${imagePath}: $($_.Exception.Message)"

                        # Write failure JSON to prevent infinite retries
                        try {
                            $failureMetadata = @{
                                success = $false
                                has_metadata = $false
                                error = "Metadata extraction failed: $($_.Exception.Message)"
                            }
                            $failureJson = $failureMetadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress
                            [System.IO.File]::WriteAllText($metadataStream, $failureJson)
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Failed to write error metadata for ${imagePath}: $($_.Exception.Message)"
                        }
                        return
                    }

                    if ($null -eq $metadata) {

                        # Write empty metadata JSON to indicate no metadata available
                        $emptyMetadata = @{
                            success = $true
                            has_metadata = $false
                            error = "No EXIF metadata found"
                        }
                        $emptyJson = $emptyMetadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

                        # Safely write to alternate data stream
                        try {
                            [System.IO.File]::WriteAllText($metadataStream, $emptyJson)
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning "Failed to write metadata stream for ${imagePath}: $($_.Exception.Message)"
                            return
                        }

                        Microsoft.PowerShell.Utility\Write-Warning "No metadata found for image: $imagePath"
                        return;
                    }

                    # Convert metadata to JSON and store in alternate stream
                    $metadataJson = $metadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

                    # Safely write to alternate data stream
                    try {
                        [System.IO.File]::WriteAllText($metadataStream, $metadataJson)
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Warning "Failed to write metadata stream for ${imagePath}: $($_.Exception.Message)"
                        return
                    }

                    # Create result object for PassThru
                    $result = [PSCustomObject]@{
                        Path = $imagePath
                        Success = $true
                        HasMetadata = $true
                        ProcessedAt = Microsoft.PowerShell.Utility\Get-Date
                        MetadataSize = $metadataJson.Length
                        CameraMake = $metadata.Camera.Make
                        CameraModel = $metadata.Camera.Model
                        HasGPS = ($null -ne $metadata.GPS.Latitude -and $null -ne $metadata.GPS.Longitude)
                        GPSLatitude = $metadata.GPS.Latitude
                        GPSLongitude = $metadata.GPS.Longitude
                    }

                    if ($PassThru) {

                        Microsoft.PowerShell.Utility\Write-Output $result
                    } else {

                        Microsoft.PowerShell.Utility\Write-Verbose "Processed metadata for: $imagePath"
                    }
                }
                catch {
                    # write failure JSON to prevent infinite retries without -RetryFailed
                    try {
                        $failureData = @{
                            success = $false
                            has_metadata = $false
                            error = "Metadata extraction failed: $($_.Exception.Message)"
                        }

                        $failureJson = $failureData | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10
                        [System.IO.File]::WriteAllText($metadataStream, $failureJson)
                    }
                    catch {
                        # If we can't even write the failure JSON, just log it
                        Microsoft.PowerShell.Utility\Write-Verbose "Failed to write error metadata for ${imagePath}: $($_.Exception.Message)"
                    }

                    $errorMessage = "Failed to process metadata for $imagePath : $($_.Exception.Message)"
                    Microsoft.PowerShell.Utility\Write-Warning $errorMessage

                    if ($PassThru) {

                        $result = [PSCustomObject]@{
                            Path = $imagePath
                            Success = $false
                            HasMetadata = $false
                            ProcessedAt = Microsoft.PowerShell.Utility\Get-Date
                            Error = $_.Exception.Message
                        }
                        Microsoft.PowerShell.Utility\Write-Output $result
                    }
                }
            }
        }
    }

    end {
    }
}
###############################################################################