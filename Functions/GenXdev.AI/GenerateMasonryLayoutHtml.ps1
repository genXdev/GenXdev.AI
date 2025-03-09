################################################################################
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
# Create gallery from image array and save to file
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
# Generate HTML string without saving
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
            HelpMessage = "Array of image objects with path, keywords and description"
        )]
        [array]$Images,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Output path for the generated HTML file"
        )]
        [string]$FilePath = $null
        ###############################################################################
    )

    begin {

        # load system.web for html encoding
        Add-Type -AssemblyName System.Web

        Write-Verbose "Starting HTML generation for $($Images.Count) images"

        # initialize html template with styles and javascript
        $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Masonry Image Layout</title>
    <script type="text/javascript">
        function setClipboard(index) {
            let imageInfo = JSON.parse($(($Images | ConvertTo-Json -Compress -Depth 20 `
                -WarningAction SilentlyContinue | ConvertTo-Json -Compress -Depth 20 `
                -WarningAction SilentlyContinue)));
            while (imageInfo instanceof String) { imageInfo = JSON.parse(imageInfo); }
            path = imageInfo[index].path;
            navigator.clipboard.writeText('"'+path+'"');
        }
    </script>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 1em;
        }
        .masonry {
            column-count: 3;
            column-gap: 1em;
        }
        .item {
            break-inside: avoid;
            margin-bottom: 1em;
        }
        .item img {
            width: 100%;
            display: block;
        }
        .keywords {
            font-size: 0.9em;
            color: #555;
        }
        .description {
            white-space: pre-wrap;
            font-size: 0.9em;
            color: #333;
        }
        a, a:visited {
            cursor: pointer;
            text-decoration: none;
        }
    </style>
</head>
<body>
    <div class="masonry">
"@
    }

    process {

        Write-Verbose "Generating HTML elements for image gallery"

        # track image index for javascript callbacks
        $index = 0

        # generate html for each image with tooltips and click handlers
        foreach ($image in $Images) {

            # combine keywords into single tooltip string
            $keywords = $image.keywords -join ", "

            # create container div with image and interactive elements
            $html += @"
        <div class="item" id="img$index">
            <a href="$($image.path)" target="_blank" onclick="setClipboard($index)">
                <img src="$($image.path)"
                    alt="$($image.description.short_description)"
                    title='$(([System.Web.HttpUtility]::HtmlAttributeEncode(
                        "$($image.description.long_description)`r`n$keywords")))' />
            </a>
        </div>
"@
            $index++
        }
    }

    end {

        # close html document structure
        $html += @"
    </div>
</body>
</html>
"@

        # either return html string or save to file based on parameters
        if ($null -eq $FilePath) {
            Write-Verbose "Returning HTML as string output"
            $html
        }
        else {
            Write-Verbose "Saving HTML gallery to: $FilePath"
            $html | Out-File -FilePath (GenXdev.FileSystem\Expand-Path $FilePath -CreateDirectory) `
                -Encoding utf8
        }
    }
}
################################################################################
