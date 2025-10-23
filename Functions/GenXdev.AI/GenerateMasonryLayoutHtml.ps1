<##############################################################################
Part of PowerShell module : GenXdev.AI
Original cmdlet filename  : GenerateMasonryLayoutHtml.ps1
Original author           : René Vaessen / GenXdev
Version                   : 2.1.2025
################################################################################
Copyright (c)  René Vaessen / GenXdev

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Generates a responsive masonry layout HTML gallery from image data.

.DESCRIPTION
Creates an interactive HTML gallery with responsive masonry grid layout for
displaying images. Features include:
- Responsive grid layout that adapts to screen size
- Image tooltips showing descriptions and keywords
- Click-to-copy image path functionality
- Clean modern styling with hover effects

.PARAMETER Images
Array of image objects containing metadata. Each object requires:
- path: String with full filesystem path to image
- keywords: String array of descriptive tags
- description: Object containing short_description and long_description

.PARAMETER FilePath
Optional output path for the HTML file. If omitted, returns HTML as string.

.EXAMPLE
Create gallery from image array and save to file
$images = @(
    @{
        path = "C:\photos\sunset.jpg"
        keywords = @("nature", "sunset", "landscape")
        description = @{
            short_description = "Mountain sunset"
            long_description = "Beautiful sunset over mountain range"
        }
    }
)
GenerateMasonryLayoutHtml -Images $images -FilePath "C:\output\gallery.html"

.EXAMPLE
Generate HTML string without saving
$html = GenerateMasonryLayoutHtml $images
#>
function GenerateMasonryLayoutHtml {

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'Array of image objects with path, keywords and description'
        )]
        [System.Collections.Generic.IEnumerable[GenXdev.Helpers.ImageSearchResult]] $Images,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Output path for the generated HTML file'
        )]
        [string]$FilePath = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Title for the gallery'
        )]
        [string]$Title = 'Photo Gallery',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Description for the gallery'
        )]
        [string]$Description = 'Hover over images to see face recognition, object detection, and scene classification data',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether editing is enabled'
        )]
        [Switch]$CanEdit = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether deletion is enabled'
        )]
        [Switch]$CanDelete = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Embed images as base64 data URLs instead of file:// URLs for better portability'
        )]
        [Switch]$EmbedImages = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show only pictures in a rounded rectangle, no text below.'
        )]
        [Alias('NoMetadata', 'OnlyPictures')]
        [switch] $ShowOnlyPictures,
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
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of images to load per page (for dynamic loading)'
        )]
        [int]$PageSize = 20,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum number of images to load for print mode'
        )]
        [int]$MaxPrintImages = 50,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'IntersectionObserver rootMargin for infinite scroll trigger (e.g. "1200px")'
        )]
        [string]$RootMargin = '1200px',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'IntersectionObserver threshold for infinite scroll trigger'
        )]
        [double]$Threshold = 0.1
    )

    begin {
        $templatePath = "$PSScriptRoot\masonary.html"

        # Load System.Web for HTML encoding
        Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Web

        Microsoft.PowerShell.Utility\Write-Verbose "Starting HTML generation for $($Images.Count) images using template: $templatePath"

        # Verify template file exists
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $templatePath)) {

            throw "Template file not found: $templatePath"
        }

        # Helper function to convert image to base64 data URL
        function ConvertTo-Base64DataUrl {
            param(
                [Parameter(Mandatory = $true)]
                [string]$ImagePath
            )

            try {
                # Check if file exists
                if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $ImagePath)) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Image file not found: $ImagePath"
                    return $null
                }

                # Determine MIME type based on file extension
                $extension = [System.IO.Path]::GetExtension($ImagePath).ToLower()
                $mimeType = switch ($extension) {
                    '.jpg'  { 'image/jpeg' }
                    '.gif'  { 'image/gif' }
                    '.jpeg' { 'image/jpeg' }
                    '.png'  { 'image/png' }
                    '.bmp'   { 'image/bmp' }
                    '.webp'  { 'image/webp' }
                    '.tiff'  { 'image/tiff' }
                    '.tif'   { 'image/tiff' }
                    default {
                        Microsoft.PowerShell.Utility\Write-Verbose "Unsupported image format: $extension"
                        return $null
                    }
                }

                # Read image file and convert to base64
                $imageBytes = [System.IO.File]::ReadAllBytes($ImagePath)
                $base64String = [System.Convert]::ToBase64String($imageBytes)

                # Create data URL
                $dataUrl = "data:$mimeType;base64,$base64String"

                Microsoft.PowerShell.Utility\Write-Verbose "Converted image to base64 data URL: $ImagePath ($(($imageBytes.Length / 1KB).ToString('F1')) KB)"

                return $dataUrl
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Failed to convert image to base64: $ImagePath - $_"
                return $null
            }
        }
    }

    process {
        # Read the HTML template
        Microsoft.PowerShell.Utility\Write-Verbose "Reading HTML template from: $templatePath"
        $html = Microsoft.PowerShell.Management\Get-Content -LiteralPath $templatePath -Raw -Encoding UTF8

        # Convert image paths for browser compatibility
        if ($EmbedImages) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Converting image paths to base64 data URLs'
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose 'Converting image paths to file:// URLs'
        }

        [System.Collections.Generic.List[GenXdev.Helpers.ImageSearchResult]] $processedImages = @()
        foreach ($image in $Images) {
            $imageCopy = $image.PSObject.Copy()
            if ($imageCopy.path) {
                # Store original path for copy functionality
                $imageCopy | Microsoft.PowerShell.Utility\Add-Member -MemberType NoteProperty -Name 'originalPath' -Value $imageCopy.path -Force

                # If ImageUrlPrefix is provided, always use it + filename (with forward slashes)
                if ($ImageUrlPrefix) {
                    $prefix = $ImageUrlPrefix
                    if ($prefix[-1] -ne '/') { $prefix += '/' }
                    $filename = [System.IO.Path]::GetFileName($imageCopy.path)
                    $imageCopy.path = ($prefix + $filename) -replace '\\', '/'
                }
                # else, just normalize slashes
                else {
                    $imageCopy.path = $imageCopy.path -replace '\\', '/'
                }

                if ($EmbedImages) {
                    # Convert to base64 data URL for embedded display
                    $dataUrl = ConvertTo-Base64DataUrl -ImagePath $imageCopy.path
                    if ($null -ne $dataUrl) {
                        $imageCopy.path = $dataUrl
                    }
                }
            }
            $processedImages.Add($imageCopy)
        }

        # Convert images array to JSON with proper escaping
        Microsoft.PowerShell.Utility\Write-Verbose "Converting $($processedImages.Count) images to JSON"

        $imagesJson = [GenXdev.Helpers.ImageSearchResultSerialize]::ToJson(($processedImages))

        if ([string]::IsNullOrWhiteSpace($imagesJson) -or $imagesJson.Substring(0, 1) -ne '[') {

            # If the JSON does not start with an array, wrap it in an array
            $imagesJson = "[$imagesJson]"
        }

        # Escape the JSON for JavaScript string literal
        $escapedJson = $imagesJson | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress
        # Replace the placeholder with actual image data
        Microsoft.PowerShell.Utility\Write-Verbose "Replacing placeholder JSON.parse(`"[]`") with actual image data"
        $html = "$html".Replace('images: JSON.parse("[]")', "images: JSON.parse($escapedJson)")

        # Replace other template variables if they exist
        if (-not [String]::IsNullOrWhiteSpace($Title)) {
            $escapedTitle = $Title | Microsoft.PowerShell.Utility\ConvertTo-Json
            # Replace JS property (mydata.title)
            $html = $html -replace '(title\s*:\s*)"[^"]*"', "`$1$escapedTitle"
            # Replace <title> tag
            $html = $html -replace '(<title>)(.*?)(</title>)', "`$1$Title`$3"
            Microsoft.PowerShell.Utility\Write-Verbose "Updated title to: $Title"
        }
        if (-not [String]::IsNullOrWhiteSpace($Description)) {
            $escapedDescription = $Description | Microsoft.PowerShell.Utility\ConvertTo-Json
            # Replace JS property (mydata.description)
            $html = $html -replace '(description\s*:\s*)"[^"]*"', "`$1$escapedDescription"
            # Replace meta description
            $html = $html -replace '(<meta name="description" content=")(.*?)(")', "`$1$Description`$3"
            Microsoft.PowerShell.Utility\Write-Verbose "Updated description to: $Description"
        }
        if ($CanEdit) {
            $html = "$html".Replace('canEdit: false', 'canEdit: true')
            Microsoft.PowerShell.Utility\Write-Verbose "Updated canEdit to: $CanEdit"
        }
        if ($CanDelete) {
            $html = "$html".Replace('canDelete: false', 'canDelete: true')
            Microsoft.PowerShell.Utility\Write-Verbose "Updated canDelete to: $CanDelete"
        }
        if ($ShowOnlyPictures) {
            $html = "$html".Replace('showOnlyPictures: false,', 'showOnlyPictures: true,')
            Microsoft.PowerShell.Utility\Write-Verbose "Updated showOnlyPictures to: $ShowOnlyPictures"
        }

        # Inject new mydata properties for dynamic loading
        $html = "$html".Replace('pageSize: 20', "pageSize: $PageSize")
        $html = "$html".Replace('maxPrintImages: 50', "maxPrintImages: $MaxPrintImages")
        $html = "$html".Replace('rootMargin: "1200px"', "rootMargin: `"$RootMargin`"")
        $html = "$html".Replace('threshold: 0.1', "threshold: $Threshold")

        # Inject new mydata properties
        if ($null -ne $AutoScrollPixelsPerSecond) {
            $autoScrollValue = if ($null -ne $AutoScrollPixelsPerSecond) { $AutoScrollPixelsPerSecond } else { 'null' }
            $html = "$html".replace('AutoScrollPixelsPerSecond: null', "AutoScrollPixelsPerSecond: $autoScrollValue")
        }
        if ($AutoAnimateRectangles) {
            $autoAnimateValue = if ($AutoAnimateRectangles) { 'true' } else { 'false' }
            $html = "$html".replace('AutoAnimateRectangles: false', "AutoAnimateRectangles: $autoAnimateValue")
        }
        # Inject SingleColumnMode property
        $singleColumnValue = if ($SingleColumnMode) { 'true' } else { 'false' }
        $html = "$html".replace('SingleColumnMode: false', "SingleColumnMode: $singleColumnValue")
    }

    end {
        # Either return HTML string or save to file based on parameters
        if ([string]::IsNullOrWhiteSpace($FilePath)) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Returning HTML as string output'
            return $html
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Saving HTML gallery to: $FilePath"
            $html | Microsoft.PowerShell.Utility\Out-File  (GenXdev.FileSystem\Expand-Path $FilePath -CreateDirectory) -Encoding utf8
        }
    }
}