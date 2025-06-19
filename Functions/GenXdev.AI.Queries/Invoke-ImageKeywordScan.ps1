################################################################################
<#
.SYNOPSIS
Scans image files for keywords and descriptions using metadata files.

.DESCRIPTION
Searches for image files (jpg, jpeg, png) in the specified directory and its
subdirectories. For each image, checks associated description.json and
keywords.json files for metadata. Can filter images based on keyword matches
and display results in a masonry layout web view or return as objects.

The function searches through image directories and examines alternate data
streams containing metadata in JSON format. It can match keywords using wildcard
patterns and filter for specific people. Results are displayed in a browser-based
masonry layout unless PassThru is specified.

.PARAMETER Keywords
Array of keywords to search for in image metadata. Supports wildcards. If empty,
returns all images with any metadata. Keywords are matched against both the
description content and keywords arrays in metadata files.

.PARAMETER People
Array of people names to search for in image metadata. Supports wildcards. Used
to filter images based on face recognition metadata stored in people.json files.

.PARAMETER ImageDirectories
Array of directory paths to search for images. Each directory is searched
recursively for jpg, jpeg, and png files. Relative paths are converted to
absolute paths automatically.

.PARAMETER PassThru
Switch to return image data as objects instead of displaying in browser. When
used, the function returns an array of hashtables containing image metadata
rather than opening a web browser view.

.EXAMPLE
Invoke-ImageKeywordScan -Keywords "cat","dog" -ImageDirectories "C:\Photos"
Searches for images containing 'cat' or 'dog' keywords in the C:\Photos directory.

.EXAMPLE
findimages cat,dog "C:\Photos"
Same as above using the alias and positional parameters.

.EXAMPLE
Invoke-ImageKeywordScan -People "John","Jane" -ImageDirectories "C:\Family" `
    -PassThru
Returns image objects for photos containing John or Jane without opening browser.
#>
###############################################################################
function Invoke-ImageKeywordScan {

    [CmdletBinding(DefaultParameterSetName = "Default")]
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
            HelpMessage = "People to look for, wildcards allowed."
        )]
        [string[]] $People = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The image directory paths to search."
        )]
        [Alias("ImageDirectory")]
        [string[]] $ImageDirectories,
        ###############################################################################
        [Parameter(
            ParameterSetName = "PassThru",
            Mandatory = $false,
            HelpMessage = ("Don't show the images in the web browser, return as " +
                "object instead.")
        )]
        [switch] $PassThru,
        ###############################################################################
        [Parameter(
            ParameterSetName = "Interactive",
            Mandatory = $false,
            HelpMessage = ("Will connect to browser and adds additional buttons like Edit and Delete")
        )]
        [switch] $Interactive,
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
        [string]$Description = "Hover over images to see face recognition data"
        ###############################################################################

    )

    begin {

        # initialize results collection for all found images
        $results = @()

        # use provided directories or default system directories
        if ($ImageDirectories) {

            # convert provided directories to simple path array
            $directories = $ImageDirectories
        }
        else {

            $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
            try {
                # attempt to get known folder path for Pictures
                $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
            }
            catch {
                # fallback to default if known folder retrieval fails
                $picturesPath = GenXdev.FileSystem\Expand-Path "~\Pictures"
            }

            # define default directories for processing
            $directories = @(
                (GenXdev.FileSystem\Expand-Path '~\downloads'),
                (GenXdev.FileSystem\Expand-Path '~\\onedrive'),
                $picturesPath
            )
        }
    }

    process {

        # iterate through each specified image directory
        foreach ($imageDirectory in $directories) {

            # convert relative path to absolute path for consistency
            $path = GenXdev.FileSystem\Expand-Path $imageDirectory

            # output directory being scanned for debugging purposes
            Microsoft.PowerShell.Utility\Write-Verbose "Scanning directory: $path"

            # validate directory exists before proceeding with search
            if (-not [System.IO.Directory]::Exists($path)) {

                Microsoft.PowerShell.Utility\Write-Host (
                    "The directory '$path' does not exist.")
                return
            }

            # search for jpg/jpeg/png files and process each one found
            $results += Microsoft.PowerShell.Management\Get-ChildItem `
                -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
                -Recurse `
                -File `
                -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                # get full path of current image file being processed
                $image = $PSItem.FullName

                # output current image being processed for debugging
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing image: $image")

                # initialize metadata containers for this image
                $keywordsFound = @()
                $descriptionFound = $null

                # try to load description metadata if alternate data stream exists
                if ([System.IO.File]::Exists("$($image):description.json")) {

                    try {
                        # read and parse description json from alternate data stream
                        $descriptionFound = [System.IO.File]::ReadAllText(
                            "$($image):description.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                        # extract keywords from description if they exist
                        $keywordsFound = ($null -eq $descriptionFound.keywords) ?
                        @() : $descriptionFound.keywords
                    }
                    catch {
                        # reset description if json parsing fails
                        $descriptionFound = $null
                    }
                }

                # try to load and merge keywords metadata if it exists separately
                if ([System.IO.File]::Exists("$($image):keywords.json")) {

                    try {
                        # read keywords from separate alternate data stream
                        $keywordsFound = [System.IO.File]::ReadAllText(
                            "$($image):keywords.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                        # merge keywords into description if description exists but lacks keywords
                        if ($null -eq $descriptionFound.keywords) {

                            # add keywords property to existing description object
                            $null = Microsoft.PowerShell.Utility\Add-Member `
                                -NotePropertyName "keywords" `
                                -InputObject $descriptionFound `
                                -NotePropertyValue $keywordsFound `
                                -Force

                            # remove separate keywords file since it's now merged
                            $null = [System.IO.File]::Delete(
                                "$($image):keywords.json")

                            # save updated description back to alternate data stream
                            $descriptionFound |
                            Microsoft.PowerShell.Utility\ConvertTo-Json `
                                -Depth 99 `
                                -Compress `
                                -WarningAction SilentlyContinue |
                            Microsoft.PowerShell.Management\Set-Content `
                                "$($image):description.json"
                        }
                    }
                    catch {
                        # reset keywords if json parsing fails
                        $keywordsFound = @()
                    }
                }

                # initialize people metadata container with default structure
                $peopleFound = @{count = 0; faces = @() }

                # try to load people metadata if alternate data stream exists
                if ([System.IO.File]::Exists("$($image):people.json")) {

                    try {
                        # read and parse people json from alternate data stream
                        $peopleFound = [System.IO.File]::ReadAllText(
                            "$($image):people.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                        # ensure people data has proper structure or reset to default
                        $peopleFound = (($null -eq $peopleFound) -or
                            ($peopleFound.count -eq 0)) ?
                        @{count = 0; faces = @() } : $peopleFound
                    }
                    catch {
                        # reset people data if json parsing fails
                        $peopleFound = @{count = 0; faces = @() }
                    }
                }

                # skip processing if no metadata exists and no search criteria provided
                if (
                (($null -eq $Keywords) -or ($Keywords.Length -eq 0)) -and
                (($null -eq $keywordsFound) -or ($keywordsFound.length -eq 0)) -and
                ($null -eq $descriptionFound) -and
                (($null -eq $People) -or ($People.Count -eq 0))
                ) {
                    return
                }

                # assume match if no keyword search criteria specified
                $found = (($null -eq $Keywords) -or ($Keywords.Length -eq 0))

                # perform keyword matching if keywords were specified for search
                if (-not $found) {

                    # convert description to json string for wildcard matching
                    $descriptionFound = ($null -ne $descriptionFound) ?
                    $descriptionFound : "" |
                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                        -Compress `
                        -Depth 10 `
                        -WarningAction SilentlyContinue

                    # check each required keyword against available metadata
                    foreach ($requiredKeyword in $Keywords) {

                        # first check if keyword matches in description content
                        $found = "$descriptionFound" -like $requiredKeyword

                        # if not found in description, check individual keywords array
                        if (-not $found) {

                            # skip keyword array check if no keywords exist
                            if (($null -eq $keywordsFound) -or
                                ($keywordsFound.Length -eq 0)) {
                                continue
                            }

                            # check each image keyword against required keyword pattern
                            foreach ($imageKeyword in $keywordsFound) {

                                # use wildcard matching for flexible keyword search
                                if ($imageKeyword -like $requiredKeyword) {

                                    $found = $true
                                    break
                                }
                            }
                        }

                        # exit early if any required keyword matches
                        if ($found) { break }
                    }
                }

                # perform additional people filtering if people criteria specified
                if ($found) {

                    # only filter by people if people search criteria were provided
                    if ($People.Count -gt 0) {

                        # reset found flag to require people match
                        $found = $false

                        # check each found person against search criteria
                        foreach ($foundPerson in $peopleFound.faces) {

                            # check each searched person against found person
                            foreach ($searchedForPerson in $People) {

                                # use wildcard matching for flexible people search
                                if ($foundPerson -like $searchedForPerson) {
                                    $found = $true
                                    break
                                }
                            }

                            # exit early if any person matches
                            if ($found) { break }
                        }
                    }
                }

                # return image data if all criteria matched
                if ($found) {

                    # output match found for debugging purposes
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Found matching image: $image")

                    # return hashtable with all image metadata
                    @{
                        path        = $image
                        keywords    = $keywordsFound
                        description = $descriptionFound
                        people      = $peopleFound
                    }
                }
            }
        }
    }

    end {

        # return raw results if passthru mode requested
        if ($PassThru) {

            return $results
        }

        # check if any results were found before displaying
        if ((-not $results) -or ($null -eq $results) -or
            ($results.Length -eq 0)) {

            # provide appropriate message based on search criteria
            if (($null -eq $Keywords) -or ($Keywords.Length -eq 0)) {

                Microsoft.PowerShell.Utility\Write-Host "No images found."
            }
            else {

                Microsoft.PowerShell.Utility\Write-Host (
                    "No images found with the specified keywords.")
            }

            return
        }

        # generate unique temp file path for masonry layout html
        $filePath = GenXdev.FileSystem\Expand-Path (
            "$env:TEMP\$([DateTime]::Now.Ticks)_images-masonry.html")

        # set file attributes to temporary and hidden for cleanup
        try {
            Microsoft.PowerShell.Management\Set-ItemProperty `
                -Path $filePath `
                -Name Attributes `
                -Value ([System.IO.FileAttributes]::Temporary -bor `
                    [System.IO.FileAttributes]::Hidden) `
                -ErrorAction SilentlyContinue
        }
        catch {}


        if ([String]::IsNullOrWhiteSpace($Title)) {

            $Title = "Image Keyword Scan Results"
        }

        if ([String]::IsNullOrWhiteSpace($Description)) {

            $Description = $MyInvocation.Statement
        }

        # generate masonry layout html and display in browser
        GenXdev.AI\GenerateMasonryLayoutHtml `
            -Images $results `
            -FilePath $filePath `
            -CanEdit:$Interactive `
            -CanDelete:$Interactive `
            -Title $Title `
            -Description $Description

        if ($Interactive) {

            # $filePath = Expand-Path "$PSScriptRoot\..\GenXdev.AI\masonary.html"
            $filePathUrl = "file:///$($filePath -replace '\\', '/')"

            try {
                $null =  GenXdev.Webbrowser\Select-WebbrowserTab
            }
            catch {
                GenXdev.Webbrowser\Close-Webbrowser -force
            }

            # open generated html file in full screen browser window
            GenXdev.Webbrowser\Open-Webbrowser `
                -NewWindow `
                -Monitor -2 `
                -Url $filePathUrl

            $Name = "*$([IO.Path]::GetFileNameWithoutExtension($filePath))*"
            $null = GenXdev.Webbrowser\Select-WebbrowserTab -Name $Name

            Microsoft.PowerShell.Utility\Write-Host "Press any key to quit..."

            while (-not [Console]::KeyAvailable) {

                try {

                    $actions = @(GenXdev.Webbrowser\Invoke-WebbrowserEvaluation "return window.getActions()" -ErrorAction SilentlyContinue)

                    Microsoft.PowerShell.Utility\Write-Verbose "Found $($actions | Microsoft.PowerShell.Utility\ConvertTo-Json)"

                    foreach ($action in $actions) {

                        switch ($action.action) {
                            "edit" {
                                Microsoft.PowerShell.Utility\Write-Host "Editing image metadata for $($action.path)"

                                GenXdev.AI\EnsurePaintNet

                                paintdotnet.exe $action.path
                            }
                            "delete" {
                                Microsoft.PowerShell.Utility\Write-Host "Deleting image $($action.path)"

                                # handle delete action
                                GenXdev.FileSystem\Move-ToRecycleBin `
                                    -Path $action.path
                            }
                        }
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Start-Sleep 1
                    continue
                }

                Microsoft.PowerShell.Utility\Start-Sleep 1
            }

            # GenXdev.Webbrowser\Invoke-WebbrowserEvaluation "window.close()"

            return
        }

        # open generated html file in full screen browser window
        GenXdev.Webbrowser\Open-Webbrowser `
            -NewWindow `
            -Url $filePath
    }
}
################################################################################