################################################################################
<#
.SYNOPSIS
Displays image search results in a masonry layout web gallery.

.DESCRIPTION
Takes image search results and displays them in a browser-based masonry layout.
Can operate in interactive mode with edit and delete capabilities, or in simple
display mode. Accepts image data objects typically from Find-Image and renders
them with hover tooltips showing metadata like face recognition, object
detection, and scene classification data.

.PARAMETER InputObject
Array of image data objects containing path, keywords, description, people,
objects, and scenes metadata.

.PARAMETER Interactive
When specified, connects to browser and adds additional buttons like Edit and
Delete for image management.

.PARAMETER Title
The title to display at the top of the image gallery.

.PARAMETER Description
The description text to display in the image gallery.

.PARAMETER Private
Opens in incognito/private browsing mode.

.PARAMETER Force
Force enable debugging port, stopping existing browsers if needed.

.PARAMETER Edge
Opens in Microsoft Edge.

.PARAMETER Chrome
Opens in Google Chrome.

.PARAMETER Chromium
Opens in Microsoft Edge or Google Chrome, depending on what the default
browser is.

.PARAMETER Firefox
Opens in Firefox.

.PARAMETER All
Opens in all registered modern browsers.

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary
monitor, defaults to Global:DefaultSecondaryMonitor or 2 if not found.

.PARAMETER FullScreen
Opens in fullscreen mode.

.PARAMETER Width
The initial width of the webbrowser window.

.PARAMETER Height
The initial height of the webbrowser window.

.PARAMETER X
The initial X position of the webbrowser window.

.PARAMETER Y
The initial Y position of the webbrowser window.

.PARAMETER Left
Place browser window on the left side of the screen.

.PARAMETER Right
Place browser window on the right side of the screen.

.PARAMETER Top
Place browser window on the top side of the screen.

.PARAMETER Bottom
Place browser window on the bottom side of the screen.

.PARAMETER Centered
Place browser window in the center of the screen.

.PARAMETER ApplicationMode
Hide the browser controls.

.PARAMETER NoBrowserExtensions
Prevent loading of browser extensions.

.PARAMETER DisablePopupBlocker
Disable the popup blocker.

.PARAMETER AcceptLang
Set the browser accept-lang http header.

.PARAMETER RestoreFocus
Restore PowerShell window focus.

.PARAMETER NoNewWindow
Re-use existing browser window, instead, create a new one.

.PARAMETER OnlyReturnHtml
Only return the generated HTML instead of displaying it in a browser.

.PARAMETER EmbedImages
Embed images as base64 data URLs instead of file:// URLs for better
portability.

.PARAMETER ShowOnlyPictures
Show only pictures in a rounded rectangle, no text below.

.EXAMPLE
$images | Show-FoundImagesInBrowser
Displays the image results in a simple web gallery.

.EXAMPLE
$images | Show-FoundImagesInBrowser -Interactive -Title "My Photos"
Displays images in interactive mode with edit/delete buttons.

.EXAMPLE
showfoundimages $images -Private -FullScreen
Opens the gallery in private browsing mode in fullscreen.
#>
################################################################################
function Show-FoundImagesInBrowser {

    [CmdletBinding()]
    # PSScriptAnalyzer rule exception: allow use of $Global:chromeSession for browser session detection
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias("showfoundimages")]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = "Image data objects to display in the gallery."
        )]
        [object[]] $InputObject,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Will connect to browser and adds additional buttons " +
                          "like Edit and Delete")
        )]
        [Alias("i", "editimages")]
        [switch] $Interactive,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Title for the gallery"
        )]
        [string] $Title = "Photo Gallery",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Hover over images to see face recognition and " +
                          "object detection data")
        )]
        [string] $Description = ("Hover over images to see face recognition " +
                                "and object detection data"),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in incognito/private browsing mode"
        )]
        [Alias("incognito", "inprivate")]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Force enable debugging port, stopping existing " +
                          "browsers if needed")
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Microsoft Edge"
        )]
        [Alias("e")]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Google Chrome"
        )]
        [Alias("ch")]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Opens in Microsoft Edge or Google Chrome, " +
                          "depending on what the default browser is")
        )]
        [Alias("c")]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in Firefox"
        )]
        [Alias("ff")]
        [switch] $Firefox,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in all registered modern browsers"
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("The monitor to use, 0 = default, -1 is discard, " +
                          "-2 = Configured secondary monitor, defaults to " +
                          "Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [Alias("m", "mon")]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Opens in fullscreen mode"
        )]
        [Alias("fs", "f")]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial width of the webbrowser window"
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial height of the webbrowser window"
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial X position of the webbrowser window"
        )]
        [int] $X = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The initial Y position of the webbrowser window"
        )]
        [int] $Y = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the left side of the screen"
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the right side of the screen"
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the top side of the screen"
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window on the bottom side of the screen"
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Place browser window in the center of the screen"
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Hide the browser controls"
        )]
        [Alias("a", "app", "appmode")]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Prevent loading of browser extensions"
        )]
        [Alias("de", "ne", "NoExtensions")]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable the popup blocker"
        )]
        [Alias("allowpopups")]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Set the browser accept-lang http header"
        )]
        [Alias("lang", "locale")]
        [string] $AcceptLang = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Restore PowerShell window focus"
        )]
        [Alias("bg")]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Re-use existing browser window, instead, " +
                          "create a new one")
        )]
        [Alias("nnw", "keepwindow")]
        [switch] $NoNewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only return the generated HTML instead of " +
                          "displaying it in a browser.")
        )]
        [switch] $OnlyReturnHtml,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Embed images as base64 data URLs instead of " +
                          "file:// URLs for better portability.")
        )]
        [switch] $EmbedImages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show only pictures in a rounded rectangle, no text below."
        )]
        [Alias("NoMetadata", "OnlyPictures")]
        [switch] $ShowOnlyPictures
    )

    begin {

        # initialize collection to accumulate all input objects
        $results = @()
    }

    process {

        # collect all input objects from pipeline
        $results += $InputObject
    }

    end {

        # verify that we have images to display before proceeding
        if ((-not $results) -or ($null -eq $results) -or
            ($results.Length -eq 0)) {

            Microsoft.PowerShell.Utility\Write-Host (
                "No images to display in gallery.")
            return
        }

        # generate unique temp file path for masonry layout html
        $filePath = GenXdev.FileSystem\Expand-Path (
            "$env:TEMP\$([DateTime]::Now.Ticks)_images-masonry.html")

        # set file attributes to temporary and hidden for cleanup
        try {

            $null = Microsoft.PowerShell.Management\Set-ItemProperty `
                -Path $filePath `
                -Name Attributes `
                -Value ([System.IO.FileAttributes]::Temporary -bor `
                    [System.IO.FileAttributes]::Hidden) `
                -ErrorAction SilentlyContinue
        }
        catch {}

        # ensure title has a default value if empty
        if ([String]::IsNullOrWhiteSpace($Title)) {

            $Title = "Image Gallery"
        }

        # ensure description has a default value if empty
        if ([String]::IsNullOrWhiteSpace($Description)) {

            $Description = "Image gallery results"
        }

        # generate masonry layout html and display in browser
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\GenerateMasonryLayoutHtml" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        $null = GenXdev.AI\GenerateMasonryLayoutHtml @params `
                    -Images $results `

        # return html content if only html is requested
        if ($OnlyReturnHtml) {

            $html = Microsoft.PowerShell.Management\Get-Content `
                -Path $filePath `
                -Raw

            $null = [io.file]::Delete($filePath)

            return $html
        }

        # handle interactive mode with browser connection
        if ($Interactive) {

            # construct file url for browser navigation
            $filePathUrl = "file:///$($filePath -replace '\\', '/')"

            # attempt to select existing webbrowser tab
            try {

                $null = GenXdev.Webbrowser\Select-WebbrowserTab

                if ($null -eq $Global:chromeSession) {

                    throw "No active web browser session found."
                }
            }
            catch {

                # close browser if selection fails
                $null = GenXdev.Webbrowser\Close-Webbrowser -force
            }

            # copy parameter values for open-webbrowser function
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.Webbrowser\Open-Webbrowser" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            $params.NewWindow = -not $NoNewWindow

            # open generated html file in full screen browser window
            $null = GenXdev.Webbrowser\Open-Webbrowser `
                @params `
                -Url $filePathUrl

            # select the specific tab containing our gallery
            $name = "*$([IO.Path]::GetFileNameWithoutExtension($filePath))*"

            $null = GenXdev.Webbrowser\Select-WebbrowserTab -Name $name

            $null = Clear-Host
            Microsoft.PowerShell.Utility\Write-Host (
                "===================================================================") `
                -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host (
                "  PowerShell is waiting for instructions from the webpage") `
                -ForegroundColor Yellow
            Microsoft.PowerShell.Utility\Write-Host (
                "      (e.g., delete or edit image actions)") `
                -ForegroundColor Yellow
            Microsoft.PowerShell.Utility\Write-Host (
                "===================================================================") `
                -ForegroundColor Cyan

            Microsoft.PowerShell.Utility\Write-Host "Press any key to quit..."

            # main interactive loop waiting for user actions
            while (-not [Console]::KeyAvailable) {

                try {

                    # get actions from browser javascript
                    $actions = @(GenXdev.Webbrowser\Invoke-WebbrowserEvaluation (
                        "return window.getActions()") -ErrorAction SilentlyContinue)

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Found $($actions |
                            Microsoft.PowerShell.Utility\ConvertTo-Json)")

                    # process each action received from the browser
                    foreach ($action in $actions) {

                        try {

                            # handle different action types
                            switch ($action.action) {

                                "edit" {

                                    Microsoft.PowerShell.Utility\Write-Host (
                                        "Editing image metadata for " +
                                        "$($action.path)")

                                    # convert file uri to local path if needed
                                    $imagePath = $action.path

                                    if ($imagePath -like "file:///*") {

                                        # convert file:/// uri to local path
                                        $imagePath = $imagePath -replace (
                                            '^file:///', '')

                                        $imagePath = $imagePath -replace '/', '\'

                                        # handle windows drive letters
                                        if ($imagePath -match '^[A-Za-z]:') {
                                            # path already has drive letter,
                                            # no changes needed
                                        }
                                    }

                                    # ensure paint.net is available for editing
                                    $null = GenXdev.AI\EnsurePaintNet

                                    Microsoft.PowerShell.Utility\Write-Warning (
                                        ("Paint.NET is not installed or not " +
                                         "found in PATH. Please install it to " +
                                         "use the edit feature."))

                                    # handle cropping if bounding box is provided
                                    if ($null -ne $action.boundingBox) {

                                        $tempFilePath = $null
                                        $image = $null

                                        try {

                                            # use .net to crop the image using the
                                            # bounding box
                                            $image = [System.Drawing.Image]::FromFile(
                                                $imagePath)

                                            # validate and clamp bounding box
                                            # coordinates
                                            $box = $action.boundingBox

                                            $x_min = [Math]::Max(0, [Math]::Min(
                                                $box.x_min, $image.Width - 1))

                                            $y_min = [Math]::Max(0, [Math]::Min(
                                                $box.y_min, $image.Height - 1))

                                            $x_max = [Math]::Max($x_min + 1,
                                                [Math]::Min($box.x_max,
                                                    $image.Width))

                                            $y_max = [Math]::Max($y_min + 1,
                                                [Math]::Min($box.y_max,
                                                    $image.Height))

                                            # calculate validated width and height
                                            $width = $x_max - $x_min
                                            $height = $y_max - $y_min

                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ("Original box: x_min=$($box.x_min), " +
                                                 "y_min=$($box.y_min), " +
                                                 "x_max=$($box.x_max), " +
                                                 "y_max=$($box.y_max), " +
                                                 "width=$($box.width), " +
                                                 "height=$($box.height)"))

                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ("Image dimensions: " +
                                                 "$($image.Width) x $($image.Height)"))

                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ("Validated box: x_min=$x_min, " +
                                                 "y_min=$y_min, x_max=$x_max, " +
                                                 "y_max=$y_max, width=$width, " +
                                                 "height=$height"))

                                            # ensure minimum dimensions
                                            if ($width -le 0 -or $height -le 0) {

                                                Microsoft.PowerShell.Utility\Write-Warning (
                                                    ("Invalid bounding box " +
                                                     "dimensions: width=$width, " +
                                                     "height=$height"))
                                                continue
                                            }

                                            # create a rectangle for the bounding box
                                            $cropRect = [System.Drawing.Rectangle]::new(
                                                $x_min, $y_min, $width, $height)

                                            # create a new bitmap for the cropped region
                                            $croppedBitmap = [System.Drawing.Bitmap]::new(
                                                $width, $height)
                                            $croppedGraphics = [System.Drawing.Graphics]::FromImage(
                                                $croppedBitmap)

                                            # draw the cropped portion of the original
                                            # image
                                            $destRect = [System.Drawing.Rectangle]::new(
                                                0, 0, $width, $height)

                                            $null = $croppedGraphics.DrawImage(
                                                $image, $destRect, $cropRect,
                                                [System.Drawing.GraphicsUnit]::Pixel)

                                            # determine a safe title for the file
                                            $title = "crop"

                                            if (-not [String]::IsNullOrWhiteSpace(
                                                $action.faceName)) {

                                                $title = $action.faceName
                                            }
                                            elseif (-not [String]::IsNullOrWhiteSpace(
                                                $action.objectName)) {

                                                $title = $action.objectName
                                            }

                                            # sanitize the title for use in filename
                                            $title = $title -replace '[^\w\-_]', '_'

                                            # get a windows temp file path for the
                                            # cropped image
                                            $tempFilePath = GenXdev.FileSystem\Expand-Path (
                                                ("$env:TEMP\" +
                                                 "$([DateTime]::Now.Ticks)_$title." +
                                                 "$([IO.Path]::GetExtension($imagePath).TrimStart('.'))"))

                                            # save the cropped image
                                            $null = $croppedBitmap.Save($tempFilePath,
                                                [System.Drawing.Imaging.ImageFormat]::Png)

                                            # clean up graphics object
                                            $null = $croppedGraphics.Dispose()

                                            $null = $croppedBitmap.Dispose()
                                        }
                                        finally {

                                            if ($image) {
                                                $null = $image.Dispose()
                                            }
                                        }

                                        # open the cropped image in paint.net
                                        if ($tempFilePath) {
                                            [bool] $wasRunning = Microsoft.PowerShell.Management\Get-Process paintdotnet `
                                                -ErrorAction SilentlyContinue
                                            $null = paintdotnet.exe $tempFilePath

                                            if (-not $wasRunning) {
                                                Microsoft.PowerShell.Utility\Start-Sleep 2

                                                $w = GenXdev.Windows\Get-Window `
                                                    -ProcessName paintdotnet `
                                                    -ErrorAction silentlyContinue

                                                if ($w) {

                                                    $null = $w.Show()
                                                    $w.Restore();

                                                    $null = GenXdev.Windows\Set-WindowPosition `
                                                        -Fullscreen `
                                                        -Monitor 0 `
                                                        -WindowHelper $w `
                                                        -ErrorAction silentlyContinue

                                                    $null = $w.SetForeground()

                                                    $null = $w.Maximize();
                                                }
                                            }
                                        }
                                    }
                                    else {
                                        # open the original image in paint.net if no
                                        # bounding boxes provided
                                        [bool] $wasRunning = Microsoft.PowerShell.Management\Get-Process paintdotnet `
                                            -ErrorAction SilentlyContinue
                                        $null = paintdotnet.exe $imagePath

                                        if (-not $wasRunning) {
                                            Microsoft.PowerShell.Utility\Start-Sleep 2

                                            $w = GenXdev.Windows\Get-Window `
                                                -ProcessName paintdotnet `
                                                -ErrorAction silentlyContinue

                                            if ($w) {

                                                $null = $w.Show()
                                                $w.Restore();

                                                $null = GenXdev.Windows\Set-WindowPosition `
                                                    -Fullscreen `
                                                    -Monitor 0 `
                                                    -WindowHelper $w `
                                                    -ErrorAction silentlyContinue

                                                $null = $w.SetForeground()

                                                $null = $w.Maximize();
                                            }
                                        }
                                    }
                                }

                                "delete" {

                                    Microsoft.PowerShell.Utility\Write-Host (
                                        "Deleting image $($action.path)")

                                    # convert file uri to local path if needed
                                    $imagePath = $action.path

                                    if ($imagePath -like "file:///*") {

                                        # convert file:/// uri to local path
                                        $imagePath = $imagePath -replace (
                                            '^file:///', '')

                                        $imagePath = $imagePath -replace '/', '\'

                                        # handle windows drive letters
                                        if ($imagePath -match '^[A-Za-z]:') {
                                            # path already has drive letter,
                                            # no changes needed
                                        }
                                    }

                                    # handle delete action by moving to recycle bin
                                    $null = GenXdev.FileSystem\Move-ToRecycleBin `
                                        -Path $imagePath
                                }
                            }
                        }
                        catch {

                            Microsoft.PowerShell.Utility\Write-Warning (
                                ("Failed to process action $($action.action) " +
                                 "for $($action.path): $_"))
                        }
                    }
                }
                catch {

                    Microsoft.PowerShell.Utility\Start-Sleep 1
                    continue
                }

                Microsoft.PowerShell.Utility\Start-Sleep 1
            }

            return
        }

        # copy identical parameter values for open-webbrowser
        $parameters = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.Webbrowser\Open-Webbrowser" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # open generated html file in browser window
        $null = GenXdev.Webbrowser\Open-Webbrowser `
            @parameters -Url $filePath
    }
}
################################################################################
