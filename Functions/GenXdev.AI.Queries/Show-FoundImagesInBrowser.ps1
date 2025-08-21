###############################################################################
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

.PARAMETER KeysToSend
Send specified keys to the browser window after opening.

.PARAMETER FocusWindow
Focus the browser window after opening.

.PARAMETER SetForeground
Set the browser window to foreground after opening.

.PARAMETER Maximize
Maximize the browser window after positioning.

.PARAMETER RestoreFocus
Restore PowerShell window focus.

.PARAMETER NewWindow
Create a new browser window instead of reusing existing one.

.PARAMETER OnlyReturnHtml
Only return the generated HTML instead of displaying it in a browser.

.PARAMETER EmbedImages
Embed images as base64 data URLs instead of file:// URLs for better
portability.

.PARAMETER ShowOnlyPictures
Show only pictures in a rounded rectangle, no text below.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keys.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys.

.PARAMETER NoBorders
Remove window borders and title bar for a cleaner appearance.

.PARAMETER PassThru
Return the browser window helper object for further manipulation.

.PARAMETER SideBySide
Place browser window side by side with PowerShell on the same monitor.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Show-FoundImagesInBrowser -InputObject $images
Displays the image results in a simple web gallery.

.EXAMPLE
Show-FoundImagesInBrowser -InputObject $images -Interactive -Title "My Photos"
Displays images in interactive mode with edit/delete buttons.

.EXAMPLE
showfoundimages $images -Private -FullScreen
Opens the gallery in private browsing mode in fullscreen.
#>
###############################################################################
function Show-FoundImagesInBrowser {

    [CmdletBinding()]
    # PSScriptAnalyzer rule exception: allow use of $Global:chromeSession for browser session detection
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('showfoundimages')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'Image data objects to display in the gallery.'
        )]
        [System.Object[]] $InputObject = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will connect to browser and adds additional buttons ' +
                'like Edit and Delete')
        )]
        [Alias('i', 'editimages')]
        [switch] $Interactive,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Title for the gallery'
        )]
        [string] $Title = 'Photo Gallery',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Hover over images to see face recognition and ' +
                'object detection data')
        )]
        [string] $Description = ('Hover over images to see face recognition ' +
            'and object detection data'),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in incognito/private browsing mode'
        )]
        [Alias('incognito', 'inprivate')]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force enable debugging port, stopping existing ' +
                'browsers if needed')
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [Alias('e')]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens in Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [Alias('c')]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Firefox'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The monitor to use, 0 = default, -1 is discard, ' +
                '-2 = Configured secondary monitor, defaults to ' +
                'Global:DefaultSecondaryMonitor or 2 if not found')
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [Alias('fs', 'f')]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the webbrowser window'
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the webbrowser window'
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the webbrowser window'
        )]
        [int] $X = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the webbrowser window'
        )]
        [int] $Y = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the left side of the screen'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the right side of the screen'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the top side of the screen'
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window in the center of the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide the browser controls'
        )]
        [Alias('a', 'app', 'appmode')]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevent loading of browser extensions'
        )]
        [Alias('de', 'ne', 'NoExtensions')]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable the popup blocker'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser accept-lang http header'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Browser window, ' +
                'see documentation for cmdlet GenXdev.Windows\Send-Key')
        )]
        [string[]] $KeysToSend,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Create a new browser window instead of reusing ' +
                'existing one')
        )]
        [Alias('nw', 'new')]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only return the generated HTML instead of ' +
                'displaying it in a browser.')
        )]
        [switch] $OnlyReturnHtml,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Embed images as base64 data URLs instead of ' +
                'file:// URLs for better portability.')
        )]
        [switch] $EmbedImages,
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
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay between different input strings in milliseconds when sending keys'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Remove window borders and title bar for a cleaner appearance'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return the browser window helper object for further manipulation'
        )]
        [Alias('pt')]
        [switch]$PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window side by side with PowerShell on the same monitor'
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for AI preferences'
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear alternative settings stored in session for AI preferences'
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Store settings only in persistent preferences without affecting session'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
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
        [string]$ImageUrlPrefix = ''
    )

    begin {

        # initialize collection to accumulate all input objects
        [System.Collections.Generic.List[[GenXdev.Helpers.ImageSearchResult]]] $results = @()
    }

    process {
        # iterate through each input object for processing
        $InputObject |
            Microsoft.PowerShell.Core\ForEach-Object `
                -ErrorAction SilentlyContinue {

                # handle enumerable objects without path property
                if ($_ -is [System.Collections.IEnumerable] -and
                (-not $_.PSObject.Properties['Path'])) {

                    # process each item in the enumerable collection
                    $_ |
                        Microsoft.PowerShell.Core\ForEach-Object {

                            # convert object to hashtable for processing
                            $hashTable = $_ |
                                GenXdev.Helpers\ConvertTo-HashTable

                                # add object to results if it contains a path property
                                if ($hashTable.ContainsKey('Path')) {

                                    $null = $results.Add($_)
                                }
                            }
                            return
                        }

                        # add unique input objects to the results collection
                        $null = $results.Add($_)
                    }
    }

    end {

        # verify that we have images to display before proceeding
        if ((-not $results) -or ($null -eq $results) -or
            ($results.Count -eq 0)) {

            Microsoft.PowerShell.Utility\Write-Host (
                'No images to display in gallery.')
            return
        }

        # log the number of images being processed
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing $($results.Count) images for gallery display")

        # generate unique temp file path for masonry layout html
        $filePath = GenXdev.FileSystem\Expand-Path (
            "$env:TEMP\$([DateTime]::Now.Ticks)_images-masonry.html")

        # log the temporary file path being used
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Creating temporary HTML file at: $filePath")

        # set file attributes to temporary and hidden for cleanup
        try {

            $null = Microsoft.PowerShell.Management\Set-ItemProperty `
                -LiteralPath $filePath `
                -Name Attributes `
                -Value ([System.IO.FileAttributes]::Temporary -bor `
                    [System.IO.FileAttributes]::Hidden) `
                -ErrorAction SilentlyContinue
        }
        catch {

            # silently ignore errors when setting file attributes
        }

        # ensure title has a default value if empty
        if ([String]::IsNullOrWhiteSpace($Title)) {

            $Title = 'Image Gallery'
        }

        # ensure description has a default value if empty
        if ([String]::IsNullOrWhiteSpace($Description)) {

            $Description = 'Image gallery results'
        }

        # copy parameter values for masonry layout html generation
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\GenerateMasonryLayoutHtml' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # configure interactive mode capabilities for editing
        $params.CanEdit = $Interactive

        # configure interactive mode capabilities for deletion
        $params.CanDelete = $Interactive

        # generate masonry layout html with specified parameters
        $null = GenXdev.AI\GenerateMasonryLayoutHtml @params `
            -Images $results -FilePath $filePath

        # log successful html generation
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Generated masonry layout HTML successfully')

        # return html content if only html is requested
        if ($OnlyReturnHtml) {

            # read the generated html file content
            $html = Microsoft.PowerShell.Management\Get-Content `
                -LiteralPath $filePath `
                -Raw

            # delete the temporary file
            $null = [io.file]::Delete($filePath)

            # return the html content to caller
            return $html
        }

        # handle interactive mode with browser connection
        if ($Interactive) {

            # log that interactive mode is starting
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Starting interactive mode with browser connection')

            # construct file url for browser navigation
            $filePathUrl = "file:///$($filePath -replace '\\', '/')"

            # log the file url being used
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Using file URL: $filePathUrl")

            # attempt to select existing webbrowser tab
            try {

                $null = GenXdev.Webbrowser\Select-WebbrowserTab `
                    -Chrome:$Chrome `
                    -Edge:$Edge

                # check if chrome session is available
                if ($null -eq $Global:chromeSession) {

                    throw 'No active web browser session found.'
                }
            }
            catch {

                # close browser if selection fails
                $null = GenXdev.Webbrowser\Close-Webbrowser `
                    -Force `
                    -Chromium `
                    -Chrome:$Chrome `
                    -Edge:$Edge
            }

            # copy parameter values for open-webbrowser function
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev.Webbrowser\Open-Webbrowser' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # configure new window behavior based on parameter
            $params.NewWindow = $NewWindow

            # open generated html file in browser window
            $null = GenXdev.Webbrowser\Open-Webbrowser `
                @params `
                -Url $filePathUrl

            # create tab name pattern for selection
            $name = "*$([IO.Path]::GetFileNameWithoutExtension($filePath))*"

            # select the specific tab containing our gallery
            $null = GenXdev.Webbrowser\Select-WebbrowserTab -Name $name

            # clear the console for interactive mode display
            $null = Clear-Host

            # display interactive mode header
            Microsoft.PowerShell.Utility\Write-Host (
                '===================================================================') `
                -ForegroundColor Cyan

            Microsoft.PowerShell.Utility\Write-Host (
                '  PowerShell is waiting for instructions from the webpage') `
                -ForegroundColor Yellow

            Microsoft.PowerShell.Utility\Write-Host (
                '      (e.g., delete or edit image actions) ENTER to QUIT') `
                -ForegroundColor Yellow

            Microsoft.PowerShell.Utility\Write-Host (
                '===================================================================') `
                -ForegroundColor Cyan

            # display exit instruction
            Microsoft.PowerShell.Utility\Write-Host 'Press any key to quit...'

            # main interactive loop waiting for user actions
            while (-not [Console]::KeyAvailable) {

                try {

                    # get actions from browser javascript
                    $actions = @(GenXdev.Webbrowser\Invoke-WebbrowserEvaluation (
                            'return window.getActions()') `
                            -ErrorAction SilentlyContinue)

                    # log found actions for debugging
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Found $($actions |
                            Microsoft.PowerShell.Utility\ConvertTo-Json)")

                    # process each action received from the browser
                    foreach ($action in $actions) {

                        try {

                            # handle different action types
                            switch ($action.action) {

                                'edit' {

                                    # display edit action message
                                    Microsoft.PowerShell.Utility\Write-Host (
                                        'Editing image metadata for ' +
                                        "$($action.path)")

                                    # convert file uri to local path if needed
                                    $imagePath = $action.path

                                    # handle file uri conversion
                                    if ($imagePath -like 'file:///*') {

                                        # convert file:/// uri to local path
                                        $imagePath = $imagePath -replace (
                                            '^file:///', '')

                                        # replace forward slashes with backslashes
                                        $imagePath = $imagePath -replace '/', '\'

                                        # handle windows drive letters
                                        if ($imagePath -match '^[A-Za-z]:') {
                                            # path already has drive letter,
                                            # no changes needed
                                        }
                                    }

                                    # ensure paint.net is available for editing
                                    $null = GenXdev.AI\EnsurePaintNet

                                    # inform user about paint.net requirement
                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        ('Paint.NET is not installed or not ' +
                                        'found in PATH. Please install it to ' +
                                        'use the edit feature.'))

                                    # handle cropping if bounding box is provided
                                    if ($null -ne $action.boundingBox) {

                                        # initialize variables for image processing
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

                                            # log original bounding box information
                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ("Original box: x_min=$($box.x_min), " +
                                                "y_min=$($box.y_min), " +
                                                "x_max=$($box.x_max), " +
                                                "y_max=$($box.y_max), " +
                                                "width=$($box.width), " +
                                                "height=$($box.height)"))

                                            # log image dimensions
                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ('Image dimensions: ' +
                                                "$($image.Width) x $($image.Height)"))

                                            # log validated bounding box information
                                            Microsoft.PowerShell.Utility\Write-Verbose (
                                                ("Validated box: x_min=$x_min, " +
                                                "y_min=$y_min, x_max=$x_max, " +
                                                "y_max=$y_max, width=$width, " +
                                                "height=$height"))

                                            # ensure minimum dimensions
                                            if ($width -le 0 -or $height -le 0) {

                                                # warn about invalid dimensions
                                                Microsoft.PowerShell.Utility\Write-Verbose (
                                                    ('Invalid bounding box ' +
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

                                            # perform the image cropping operation
                                            $null = $croppedGraphics.DrawImage(
                                                $image, $destRect, $cropRect,
                                                [System.Drawing.GraphicsUnit]::Pixel)

                                            # determine a safe title for the file
                                            $title = 'crop'

                                            # use face name if available
                                            if (-not [String]::IsNullOrWhiteSpace(
                                                    $action.faceName)) {

                                                $title = $action.faceName
                                            }
                                            # use object name if available
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

                                            # ensure image object is disposed
                                            if ($image) {

                                                $null = $image.Dispose()
                                            }
                                        }

                                        # open the cropped image in paint.net
                                        if ($tempFilePath) {

                                            # check if paint.net is already running
                                            [bool] $wasRunning = Microsoft.PowerShell.Management\Get-Process paintdotnet `
                                                -ErrorAction SilentlyContinue

                                            # launch paint.net with the cropped image
                                            $null = paintdotnet.exe $tempFilePath

                                            # wait for paint.net to initialize
                                            Microsoft.PowerShell.Utility\Start-Sleep 2

                                            # get paint.net window handle
                                            $w = GenXdev.Windows\Get-Window `
                                                -ProcessName paintdotnet `
                                                -ErrorAction silentlyContinue

                                            # position and maximize paint.net window
                                            if ($w) {

                                                $null = GenXdev.Windows\Set-WindowPosition `
                                                    -WindowHelper $w `
                                                    -Monitor 0 `
                                                    -Maximize `
                                                    -SetForeground `
                                                    -FocusWindow
                                            }
                                        }
                                    }
                                    else {

                                        # open the original image in paint.net if no
                                        # bounding boxes provided
                                        [bool] $wasRunning = Microsoft.PowerShell.Management\Get-Process paintdotnet `
                                            -ErrorAction SilentlyContinue

                                        # launch paint.net with the original image
                                        $null = paintdotnet.exe $imagePath

                                        # wait for paint.net to initialize
                                        Microsoft.PowerShell.Utility\Start-Sleep 2

                                        # get paint.net window handle
                                        $w = GenXdev.Windows\Get-Window `
                                            -ProcessName paintdotnet `
                                            -ErrorAction silentlyContinue

                                        # position and maximize paint.net window
                                        if ($w) {

                                            $null = GenXdev.Windows\Set-WindowPosition `
                                                -WindowHelper $w `
                                                -Monitor 0 `
                                                -Maximize `
                                                -SetForeground `
                                                -FocusWindow
                                        }
                                    }
                                }

                                'delete' {

                                    # display delete action message
                                    Microsoft.PowerShell.Utility\Write-Host (
                                        "Deleting image $($action.path)")

                                    # convert file uri to local path if needed
                                    $imagePath = $action.path

                                    # handle file uri conversion
                                    if ($imagePath -like 'file:///*') {

                                        # convert file:/// uri to local path
                                        $imagePath = $imagePath -replace (
                                            '^file:///', '')

                                        # replace forward slashes with backslashes
                                        $imagePath = $imagePath -replace '/', '\'

                                        # handle windows drive letters
                                        if ($imagePath -match '^[A-Za-z]:') {
                                            # path already has drive letter,
                                            # no changes needed
                                        }
                                    }

                                    # handle delete action by moving to recycle bin
                                    $null = GenXdev.FileSystem\Move-ToRecycleBin `
                                       -LiteralPath $imagePath
                                }
                            }
                        }
                        catch {

                            # warn about failed action processing
                            Microsoft.PowerShell.Utility\Write-Verbose (
                                ("Failed to process action $($action.action) " +
                                "for $($action.path): $_"))
                        }
                    }
                }
                catch {

                    # sleep and continue on general errors
                    Microsoft.PowerShell.Utility\Start-Sleep 1
                    continue
                }

                # sleep to prevent excessive polling
                Microsoft.PowerShell.Utility\Start-Sleep 1
            }

            # exit interactive mode
            return
        }

        # copy identical parameter values for open-webbrowser
        $parameters = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Webbrowser\Open-Webbrowser' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # open generated html file in browser window and let it return naturally
        GenXdev.Webbrowser\Open-Webbrowser `
            @parameters -Url $filePath
    }
}
###############################################################################