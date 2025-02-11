################################################################################
<#
.SYNOPSIS
Scans images in a directory for keywords and description.

.DESCRIPTION
The `Invoke-ImageKeywordScan` function scans images in a directory for keywords and description.

.PARAMETER Keywords
The keywords to look for, wildcards allowed.

.PARAMETER ImageDirectory
The image directory path.

.PARAMETER PassThru
Don't show the images in the web browser, return as object instead.

.EXAMPLE
Invoke-ImageKeywordScan -Keywords "cat" -ImageDirectory "C:\path\to\images"

.EXAMPLE
findimages -Keywords "cat" -ImageDirectory "C:\path\to\images"
#>
function Invoke-ImageKeywordScan {

    [CmdletBinding()]
    [Alias("findimages")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The keywords to look for, wildcards allowed."
        )]
        [string[]] $Keywords = @(),

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The image directory path."
        )]
        [string] $ImageDirectory = ".\",

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Don't show the images in the web browser, return as object instead."
        )]
        [switch] $PassThru
    )

    begin {

        # expand the image directory path to its full path
        $Path = Expand-Path $ImageDirectory

        # check if the directory exists
        if (-not [System.IO.Directory]::Exists($Path)) {

            Write-Host "The directory '$Path' does not exist."
            return
        }
    }

    process {

        # get all image files in the directory
        $results = Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {

            $image = $PSItem.FullName
            $keywordsFound = @()
            $descriptionFound = $null

            # check if description file exists
            if ([System.IO.File]::Exists("$($image):description.json")) {

                try {
                    # read and parse the description file
                    $descriptionFound = [System.IO.File]::ReadAllText("$($image):description.json") | ConvertFrom-Json
                    $keywordsFound = ($null -eq $descriptionFound.keywords) ? @() : $descriptionFound.keywords
                }
                catch {
                    $descriptionFound = $null
                }
            }

            # check if keywords file exists
            if ([System.IO.File]::Exists("$($image):keywords.json")) {

                try {
                    # read and parse the keywords file
                    $keywordsFound = [System.IO.File]::ReadAllText("$($image):keywords.json") | ConvertFrom-Json

                    if ($null -eq $descriptionFound.keywords) {

                        Add-Member -NotePropertyName "keywords" -InputObject $descriptionFound -NotePropertyValue $keywordsFound -Force | Out-Null

                        [System.IO.File]::Delete("$($image):keywords.json")

                        $descriptionFound | ConvertTo-Json -Depth 99 -Compress -WarningAction SilentlyContinue | Set-Content "$($image):description.json"
                    }
                }
                catch {
                    $keywordsFound = @()
                }
            }

            # check if no keywords specified or no keywords found
            if (
                ($null -eq $Keywords -or ($Keywords.Length -eq 0)) -and
                ($null -eq $keywordsFound -or ($keywordsFound.length -eq 0)) -and
                ($null -eq $descriptionFound)
            ) {
                return
            }

            # check if any of the keywords are found in the description or keywords
            $found = ($null -eq $Keywords -or ($Keywords.Length -eq 0))
            if (-not $found) {

                $descriptionFound = $null -ne $descriptionFound ? $descriptionFound : "" | ConvertTo-Json -Compress -Depth 10 -WarningAction SilentlyContinue

                foreach ($requiredKeyword in $Keywords) {

                    $found = "$descriptionFound" -like $requiredKeyword

                    if (-not $found) {

                        if ($null -eq $keywordsFound -or ($keywordsFound.Length -eq 0)) { continue }

                        foreach ($imageKeyword in $keywordsFound) {

                            if ($imageKeyword -like $requiredKeyword) {

                                $found = $true
                                break
                            }
                        }
                    }

                    if ($found) { break }
                }
            }

            if ($found) {

                @{
                    path        = $image
                    keywords    = $keywordsFound
                    description = $descriptionFound
                }
            }
        }
    }

    end {

        if ($PassThru) {

            $results
        }
        else {

            if ((-not $results) -or ($null -eq $results) -or ($results.Length -eq 0)) {

                if (($null -eq $Keywords) -or ($Keywords.Length -eq 0)) {

                    Write-Host "No images found."
                }
                else {

                    Write-Host "No images found with the specified keywords."
                }

                return
            }

            $filePath = Expand-Path "$env:TEMP\$([DateTime]::Now.Ticks)_images-masonry.html"
            try { Set-ItemProperty -Path $filePath -Name Attributes -Value ([System.IO.FileAttributes]::Temporary -bor [System.IO.FileAttributes]::Hidden) -ErrorAction SilentlyContinue } catch {}
            GenerateMasonryLayoutHtml -Images $results -FilePath $filePath

            Open-Webbrowser -NewWindow -Url $filePath -FullScreen
        }
    }
}
