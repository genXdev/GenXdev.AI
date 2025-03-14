################################################################################
<#
.SYNOPSIS
Scans image files for keywords and descriptions using metadata files.

.DESCRIPTION
Searches for image files (jpg, jpeg, png) in the specified directory and its
subdirectories. For each image, checks associated description.json and
keywords.json files for metadata. Can filter images based on keyword matches and
display results in a masonry layout web view or return as objects.

.PARAMETER Keywords
Array of keywords to search for. Supports wildcards. If empty, returns all images
with any metadata.

.PARAMETER ImageDirectory
Directory path to search for images. Defaults to current directory.

.PARAMETER PassThru
Switch to return image data as objects instead of displaying in browser.

.EXAMPLE
Invoke-ImageKeywordScan -Keywords "cat","dog" -ImageDirectory "C:\Photos"

.EXAMPLE
findimages cat,dog "C:\Photos"
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
        # convert relative path to absolute path
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectory

        Write-Verbose "Scanning directory: $path"

        # validate directory exists before proceeding
        if (-not [System.IO.Directory]::Exists($path)) {

            Write-Host "The directory '$path' does not exist."
            return
        }
    }

    process {

        # search for jpg/jpeg/png files and process each one
        $results = Get-ChildItem -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
            -Recurse -File -ErrorAction SilentlyContinue |
        ForEach-Object {

            $image = $PSItem.FullName
            Write-Verbose "Processing image: $image"

            $keywordsFound = @()
            $descriptionFound = $null

            # try to load description metadata if it exists
            if ([System.IO.File]::Exists("$($image):description.json")) {

                try {
                    $descriptionFound = [System.IO.File]::ReadAllText(
                        "$($image):description.json") |
                    ConvertFrom-Json

                    $keywordsFound = ($null -eq $descriptionFound.keywords) ?
                    @() : $descriptionFound.keywords
                }
                catch {
                    $descriptionFound = $null
                }
            }

            # try to load and merge keywords metadata if it exists
            if ([System.IO.File]::Exists("$($image):keywords.json")) {

                try {
                    $keywordsFound = [System.IO.File]::ReadAllText(
                        "$($image):keywords.json") |
                    ConvertFrom-Json

                    # merge keywords into description if needed
                    if ($null -eq $descriptionFound.keywords) {

                        Add-Member -NotePropertyName "keywords" `
                            -InputObject $descriptionFound `
                            -NotePropertyValue $keywordsFound -Force |
                        Out-Null

                        $null = [System.IO.File]::Delete("$($image):keywords.json")

                        $descriptionFound |
                        ConvertTo-Json -Depth 99 -Compress `
                            -WarningAction SilentlyContinue |
                        Set-Content "$($image):description.json"
                    }
                }
                catch {
                    $keywordsFound = @()
                }
            }

            # skip if no metadata and no search keywords
            if (
                ($null -eq $Keywords -or ($Keywords.Length -eq 0)) -and
                ($null -eq $keywordsFound -or ($keywordsFound.length -eq 0)) -and
                ($null -eq $descriptionFound)
            ) {
                return
            }

            # check if keywords match metadata
            $found = ($null -eq $Keywords -or ($Keywords.Length -eq 0))
            if (-not $found) {

                $descriptionFound = $null -ne $descriptionFound ?
                $descriptionFound : "" |
                ConvertTo-Json -Compress -Depth 10 -WarningAction SilentlyContinue

                foreach ($requiredKeyword in $Keywords) {

                    $found = "$descriptionFound" -like $requiredKeyword

                    if (-not $found) {

                        if ($null -eq $keywordsFound -or ($keywordsFound.Length -eq 0)) {
                            continue
                        }

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

            # return matching image data
            if ($found) {

                Write-Verbose "Found matching image: $image"
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

            # generate unique temp file path for masonry layout
            $filePath = GenXdev.FileSystem\Expand-Path "$env:TEMP\$([DateTime]::Now.Ticks)_images-masonry.html"

            # set file attributes to temporary and hidden
            try {
                Set-ItemProperty -Path $filePath -Name Attributes `
                    -Value ([System.IO.FileAttributes]::Temporary -bor `
                        [System.IO.FileAttributes]::Hidden) `
                    -ErrorAction SilentlyContinue
            }
            catch {}

            # generate and display results in browser
            GenerateMasonryLayoutHtml -Images $results -FilePath $filePath
            Open-Webbrowser -NewWindow -Url $filePath -FullScreen
        }
    }
}
################################################################################