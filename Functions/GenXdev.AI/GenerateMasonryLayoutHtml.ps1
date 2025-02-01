################################################################################
<#
.SYNOPSIS
Generates an HTML file with a masonry layout for displaying images.

.DESCRIPTION
The `GenerateMasonryLayoutHtml` function creates an HTML file with a masonry layout for displaying images, including their descriptions and keywords.

.PARAMETER Images
An array of image objects containing path, keywords, and description.

.PARAMETER FilePath
The file path where the HTML file will be saved.

.EXAMPLE
$images = @(
    @{ path = "C:\path\to\image1.jpg"; keywords = @("keyword1", "keyword2"); description = @{ short_description = "Short description"; long_description = "Long description" } },
    @{ path = "C:\path\to\image2.jpg"; keywords = @("keyword3", "keyword4"); description = @{ short_description = "Short description"; long_description = "Long description" } }
)
GenerateMasonryLayoutHtml -Images $images -FilePath "C:\path\to\output.html"

.EXAMPLE
$images = @(
    @{ path = "C:\path\to\image1.jpg"; keywords = @("keyword1", "keyword2"); description = @{ short_description = "Short description"; long_description = "Long description" } },
    @{ path = "C:\path\to\image2.jpg"; keywords = @("keyword3", "keyword4"); description = @{ short_description = "Short description"; long_description = "Long description" } }
)
GenerateMasonryLayoutHtml $images "C:\path\to\output.html"
#>
function GenerateMasonryLayoutHtml {

    [CmdletBinding()]

    param (
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "An array of image objects containing path, keywords, and description."
        )]
        [array]$Images,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The file path where the HTML file will be saved."
        )]
        [string]$FilePath = $null
    )

    begin {
        # add each image to the HTML content
        Add-Type -AssemblyName System.Web

        # initialize the HTML content with the header
        $html = @"
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Masonry Image Layout</title>
    <script type="text/javascript">
        function setClipboard(index) {
            let imageInfo = JSON.parse($(($images | ConvertTo-Json -Compress -Depth 20 | ConvertTo-Json -Compress -Depth 20)));
            while (imageInfo instanceof String) { imageInfo = JSON.parse(imageInfo); }
            path = imageInfo[index].path;
            navigator.clipboard.writeText('"'+path+'"');
        }
    </script>
    <style type="text/css">
        body {
            font-family: Arial, sans-serif;
            margin: 0;
            padding: 0;
            padding-left:1em;
            padding-top:1em;
            padding-bottom:1em;
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

        $i = 0
        foreach ($image in $Images) {
            $keywords = $image.keywords -join ", "
            $html += @"
        <div class="item" id="img$i">
            <a href="$($image.path)" target="_blank" onclick="setClipboard($i)">
                <img src="$($image.path)" alt="$($image.description.short_description)" title='$(([System.Web.HttpUtility]::HtmlAttributeEncode("$($image.description.long_description)`r`n$keywords")))' />
            </a>
        </div>
"@
            $i++
        }

    }

    end {

        # finalize the HTML content
        $html += @"
    </div>
</body>
</html>
"@

        # output the HTML content or save to file
        if ($null -eq $FilePath) {
            $html
        }
        else {
            $html | Out-File -FilePath (Expand-Path $FilePath -CreateDirectory) -Encoding utf8
        }
    }
}
