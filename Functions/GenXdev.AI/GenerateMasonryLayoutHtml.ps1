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
        ###############################################################################Create gallery from image array and save to file
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
        ###############################################################################Generate HTML string without saving
$html = GenerateMasonryLayoutHtml $images
        ###############################################################################>
function GenerateMasonryLayoutHtml {

    [CmdletBinding()]
    [OutputType([System.String])]
    param (
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = "Array of image objects with path, keywords and description"
        )]
        [array]$Images,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Output path for the generated HTML file"
        )]
        [string]$FilePath = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Title for the gallery"
        )]
        [string]$Title = "Photo Gallery",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Description for the gallery"
        )]
        [string]$Description = "Hover over images to see face recognition, object detection, and scene classification data",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Whether editing is enabled"
        )]
        [Switch]$CanEdit = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Whether deletion is enabled"
        )]
        [Switch]$CanDelete = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Embed images as base64 data URLs instead of file:// URLs for better portability"
        )]
        [Switch]$EmbedImages = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show only pictures in a rounded rectangle, no text below."
        )]
        [Alias("NoMetadata", "OnlyPictures")]
        [switch] $ShowOnlyPictures
    )

    begin {
        $templatePath = "$PSScriptRoot\masonary.html"

        # Load System.Web for HTML encoding
        Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Web

        Microsoft.PowerShell.Utility\Write-Verbose "Starting HTML generation for $($Images.Count) images using template: $templatePath"

        # Verify template file exists
        if (-not (Microsoft.PowerShell.Management\Test-Path $templatePath)) {
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
                if (-not (Microsoft.PowerShell.Management\Test-Path $ImagePath)) {
                    Microsoft.PowerShell.Utility\Write-Warning "Image file not found: $ImagePath"
                    return $null
                }

                # Determine MIME type based on file extension
                $extension = [System.IO.Path]::GetExtension($ImagePath).ToLower()
                $mimeType = switch ($extension) {
                    ".jpg"  { "image/jpeg" }
                    ".gif"  { "image/gif" }
                    ".jpeg" { "image/jpeg" }
                    ".png"  { "image/png" }
                    default {
                        Microsoft.PowerShell.Utility\Write-Warning "Unsupported image format: $extension"
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
                Microsoft.PowerShell.Utility\Write-Warning "Failed to convert image to base64: $ImagePath - $_"
                return $null
            }
        }
    }

    process
    {
        # Read the HTML template
        Microsoft.PowerShell.Utility\Write-Verbose "Reading HTML template from: $templatePath"
        $html = Microsoft.PowerShell.Management\Get-Content -Path $templatePath -Raw -Encoding UTF8
        # Convert image paths for browser compatibility
        if ($EmbedImages) {
            Microsoft.PowerShell.Utility\Write-Verbose "Converting image paths to base64 data URLs"
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose "Converting image paths to file:// URLs"
        }

        [System.Collections.Generic.List[object]] $processedImages = @()
        foreach ($image in $Images) {
            $imageCopy = $image.PSObject.Copy()
            if ($imageCopy.path) {
                # Store original path for copy functionality
                $imageCopy | Microsoft.PowerShell.Utility\Add-Member -MemberType NoteProperty -Name "originalPath" -Value $imageCopy.path -Force

                if ($EmbedImages) {
                    # Convert to base64 data URL for embedded display
                    $dataUrl = ConvertTo-Base64DataUrl -ImagePath $imageCopy.path
                    if ($null -ne $dataUrl) {
                        $imageCopy.path = $dataUrl
                    } else {
                        # Fallback to file:// URL if base64 conversion fails
                        $fileUrl = "file:///" + ($imageCopy.path -replace '\\', '/')
                        $imageCopy.path = $fileUrl
                    }
                } else {
                    # Convert Windows path to file:// URL for display
                    $fileUrl = "file:///" + ($imageCopy.path -replace '\\', '/')
                    $imageCopy.path = $fileUrl
                }
            }
            $processedImages.Add($imageCopy)
        }

        # Convert images array to JSON with proper escaping
        Microsoft.PowerShell.Utility\Write-Verbose "Converting $($processedImages.Count) images to JSON"
        $imagesJson = @($processedImages) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20 -WarningAction SilentlyContinue
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
        if (-not [String]::IsNullOrWhiteSpace($Title))  {
            $escapedTitle = $Title | Microsoft.PowerShell.Utility\ConvertTo-Json
            $html = "$html".Replace("title : `"Photo Gallery`"", "title : $escapedTitle")
            Microsoft.PowerShell.Utility\Write-Verbose "Updated title to: $Title"
        }
        if (-not [String]::IsNullOrWhiteSpace($Description))  {
            $escapedDescription = $Description | Microsoft.PowerShell.Utility\ConvertTo-Json
            $html = "$html".Replace("`"Hover over images to see face recognition data`"", $escapedDescription)
            Microsoft.PowerShell.Utility\Write-Verbose "Updated description to: $Description"
        }
        if ($CanEdit)  {
            $html = "$html".Replace("canEdit: false", "canEdit: true")
            Microsoft.PowerShell.Utility\Write-Verbose "Updated canEdit to: $CanEdit"
        }
        if ($CanDelete)  {
            $html = "$html".Replace("canDelete: false", "canDelete: true")
            Microsoft.PowerShell.Utility\Write-Verbose "Updated canDelete to: $CanDelete"
        }
        if ($ShowOnlyPictures) {
            $html = "$html".Replace("showOnlyPictures: false,", "showOnlyPictures: true,")
            Microsoft.PowerShell.Utility\Write-Verbose "Updated showOnlyPictures to: $ShowOnlyPictures"
        }
    }

    end {
        # Either return HTML string or save to file based on parameters
        if ($null -eq $FilePath) {
            Microsoft.PowerShell.Utility\Write-Verbose "Returning HTML as string output"
            return $html
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Saving HTML gallery to: $FilePath"
            $html | Microsoft.PowerShell.Utility\Out-File -FilePath (GenXdev.FileSystem\Expand-Path $FilePath -CreateDirectory) -Encoding utf8
        }
    }
}
        ###############################################################################