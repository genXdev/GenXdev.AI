################################################################################
<#
.SYNOPSIS
Queries the LM-Studio API with the given parameters and returns the response.

.DESCRIPTION
The `Invoke-LMStudioQuery` function sends a query to the LM-Studio API and returns the response.

.PARAMETER query
The query string for the LLM

.PARAMETER attachments
The file paths of the attachments to send with the query.

.PARAMETER instructions
The system instructions for the LLM.
Default value: "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice."

.PARAMETER Model
The LM-Studio model to use for generating the response.

.PARAMETER temperature
The temperature parameter for controlling the randomness of the response.

.PARAMETER max_token
The maximum number of tokens to generate in the response.

.PARAMETER imageDetail
The image detail to use for the attachments.

.EXAMPLE
    Invoke-LMStudioQuery -query "Introduce yourself." -instructions "Always answer in rhymes." -model "lmstudio-community/yi-coder-9b-chat-GGUF" -temperature 0.9

    qlms "Introduce yourself." "Always answer in rhymes." "lmstudio-community/yi-coder-9b-chat-GGUF" 0.9

.EXAMPLE
Invoke-LMStudioQuery -query "What is PowerShell?" -temperature 0.7

.EXAMPLE
Invoke-LMStudioQuery -query "Analyze this code" -attachments ".\script.ps1" -instructions "Be thorough"

.EXAMPLE
qlms "give a technical summary of the content of this html document" -attachments ".\index.html" -model "llava"

#>
function Invoke-LMStudioQuery {

    [CmdletBinding()]
    [Alias("qlms")]

    param (
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "The query string for the LLM."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$query,

        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The file paths of the attachments to send with the query."
        )]
        [string[]]$attachments = @(),

        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The system instructions for the LLM.")]
        [PSDefaultValue(Value = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.")]
        [string]$Instructions = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.",

        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$Model = "yi-coder-9b-chat",

        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $temperature = 0.01,

        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = "The maximum number of tokens to generate in the response."
        )]
        [int] $max_token = -1,

        [Parameter(
            Mandatory = $false,
            Position = 6,
            HelpMessage = "The image detail to use for the attachments."
        )]
        [ValidateSet("low", "medium", "high")]
        [string] $imageDetail = "low",

        [Parameter(
            Mandatory = $false,
            Position = 7,
            HelpMessage = "Show the LM-Studio window."
        )]
        [Switch] $ShowLMStudioWindow
    )

    $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

    function IsLMStudioInstalled {

        return Test-Path -Path $lmsPath -ErrorAction SilentlyContinue
    }

    # Function to check if LMStudio is running
    function IsLMStudioRunning {

        $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue | Where-Object -Property MainWindowHandle -NE 0

        if ($null -ne $process) {

            $w = [GenXdev.Helpers.WindowObj]::new($process.MainWindowHandle, "LM Studio");
            if ($null -ne $w) {

                if ($ShowLMStudioWindow) {

                    $w.Maximize();
                    $w.Show();
                }
                else {
                    $w.Minimize();
                    (Get-PowershellMainWindow).Focus();
                }
            }
        }

        return $null -ne $process
    }

    function IsWinGetInstalled {

        Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
        $module = Get-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue

        if ($null -eq $module) {

            return $false
        }

        return $true
    }

    function InstallWinGet {

        Write-Verbose "Installing WinGet PowerShell client.."
        Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
        Import-Module "Microsoft.WinGet.Client"
    }

    function InstallLMStudio {

        if (-not (IsWinGetInstalled)) {

            InstallWinGet
        }

        $lmStudio = "ElementLabs.LMStudio"
        $lmStudioPackage = Get-WinGetPackage -Name $lmStudio

        if ($null -eq $lmStudioPackage) {

            Write-Verbose "Installing LM-Studio.."
            Install-WinGetPackage -Id $lmStudio -Force
            $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
        }
    }

    # Function to start LMStudio if it's not running
    function Start-LMStudio {

        if (-not (IsLMStudioInstalled)) {

            InstallLMStudio
        }

        if (-not (IsLMStudioRunning)) {

            Write-Verbose "Starting LM-Studio..";
            $lmStudioPath = "$env:LOCALAPPDATA\LM-Studio\LM Studio.exe";
            Write-Verbose "$((Start-Process -FilePath $lmStudioPath -WindowStyle Minimized))";
            $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
            Start-Sleep -Seconds 10
            IsLMStudioRunning | Out-Null
        }
    }

    # Function to get the list of models
    function Get-ModelList {

        Write-Verbose "Getting installed model list.."
        $ModelList = & "$lmsPath" ls --yes --json | ConvertFrom-Json
        return $ModelList
    }
    function Get-LoadedModelList {

        Write-Verbose "Getting loaded model list.."
        $ModelList = & "$lmsPath" ps --yes --json | ConvertFrom-Json
        return $ModelList
    }

    # Function to load the LLava model
    function LoadLMStudioModel {

        $ModelList = Get-ModelList
        $foundModel = $ModelList | Where-Object { $_.path -like "*$Model*" } | Select-Object -First 1

        if ($foundModel) {

            Write-Output $foundModel

            $foundModelLoaded = (Get-LoadedModelList) | Where-Object {
                $_.path -eq $foundModel.path
            } | Select-Object -First 1

            if ($null -eq $foundModelLoaded) {

                $success = $true;
                try {

                    Write-Verbose "Loading model.."
                    [System.Console]::Write("`r`n");

                    if (-not (Get-HasCapableGpu)) {

                        & "$lmsPath" load "$($foundModel.path)" --yes --gpu off --exact
                    }
                    else {

                        & "$lmsPath" load "$($foundModel.path)" --yes --exact
                    }

                    if ($LASTEXITCODE -ne 0) {

                        $success = $false;
                    }
                    else {
                        # ansi for cursor up and clear line
                        [System.Console]::Write("`e[1A`e[2K")
                        # ansi for cursor up and clear line
                        [System.Console]::Write("`e[1A`e[2K")
                        # ansi for cursor up and clear line
                        [System.Console]::Write("`e[1A`e[2K")
                        # ansi for cursor up and clear line
                        [System.Console]::Write("`e[1A`e[2K")
                        # ansi for cursor up and clear line
                        [System.Console]::Write("`e[1A`e[2K")
                        # ansi for cursor up and clear line
                        [System.Console]::Write("`e[1A`e[2K")

                    }
                }
                catch {
                    $success = $false;
                }

                if (-not $success) {

                    Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue | Stop-Process -Force
                    Start-LMStudio

                    $success = $true;
                    try {
                        Write-Verbose "Loading model.."
                        & "$lmsPath" load $foundModel.path --yes --gpu off --context-length $max_token | Out-Null

                        if ($LASTEXITCODE -ne 0) {

                            $success = $false;
                        }
                    }
                    catch {
                        $success = $false;
                    }
                }

                if (-not $success) {

                    $ShowLMStudioWindow = $true
                    IsLMStudioRunning | Out-Null
                    throw "Model with path: '*$Model*', not found. Please install and configure startup-parameters manually in LM-Studio first."
                }
            }
        }
        else {
            $ShowLMStudioWindow = $true
            IsLMStudioRunning | Out-Null
            throw "Model with path: '*$Model*', not found. Please install and configure startup-parameters manually in LM-Studio first."
        }
    }

    # Function to upload image and query to LM-Studio local server
    function QueryLMStudio {

        param (
            $loadedModel,
            [string]$Instructions,
            [string]$query,
            [string[]]$attachments,
            [double]$temperature,
            [int]$max_token = -1
        )

        $messages = [System.Collections.ArrayList] @();
        $messages.Add(
            @{
                role    = "system"
                content = "$Instructions"
            }
        ) | Out-Null;

        $attachments | ForEach-Object {
            $filePath = Expand-Path $PSItem;
            $fileExtension = [IO.Path]::GetExtension($filePath).ToLowerInvariant();
            $mimeType = "application/octet-stream";
            $isText = $false;
            switch ($fileExtension) {

                ".jpg" {
                    $mimeType = "image/jpeg"
                    $isText = $false
                }
                ".jpeg" {
                    $mimeType = "image/jpeg"
                    $isText = $false
                }
                ".png" {
                    $mimeType = "image/png"
                    $isText = $false
                }
                ".gif" {
                    $mimeType = "image/gif"
                    $isText = $false
                }
                ".bmp" {
                    $mimeType = "image/bmp"
                    $isText = $false
                }
                ".tiff" {
                    $mimeType = "image/tiff"
                    $isText = $false
                }
                ".mp4" {
                    $mimeType = "video/mp4"
                    $isText = $false
                }
                ".avi" {
                    $mimeType = "video/avi"
                    $isText = $false
                }
                ".mov" {
                    $mimeType = "video/quicktime"
                    $isText = $false
                }
                ".webm" {
                    $mimeType = "video/webm"
                    $isText = $false
                }
                ".mkv" {
                    $mimeType = "video/x-matroska"
                    $isText = $false
                }
                ".flv" {
                    $mimeType = "video/x-flv"
                    $isText = $false
                }
                ".wmv" {
                    $mimeType = "video/x-ms-wmv"
                    $isText = $false
                }
                ".mpg" {
                    $mimeType = "video/mpeg"
                    $isText = $false
                }
                ".mpeg" {
                    $mimeType = "video/mpeg"
                    $isText = $false
                }
                ".3gp" {
                    $mimeType = "video/3gpp"
                    $isText = $false
                }
                ".3g2" {
                    $mimeType = "video/3gpp2"
                    $isText = $false
                }
                ".m4v" {
                    $mimeType = "video/x-m4v"
                    $isText = $false
                }
                ".webp" {
                    $mimeType = "image/webp"
                    $isText = $false
                }
                ".heic" {
                    $mimeType = "image/heic"
                    $isText = $false
                }
                ".heif" {
                    $mimeType = "image/heif"
                    $isText = $false
                }
                ".avif" {
                    $mimeType = "image/avif"
                    $isText = $false
                }
                ".jxl" {
                    $mimeType = "image/jxl"
                    $isText = $false
                }
                ".ps1" {
                    $mimeType = "text/x-powershell"
                    $isText = $true
                }
                ".psm1" {
                    $mimeType = "text/x-powershell"
                    $isText = $true
                }
                ".psd1" {
                    $mimeType = "text/x-powershell"
                    $isText = $true
                }
                ".sh" {
                    $mimeType = "application/x-sh"
                    $isText = $true
                }
                ".bat" {
                    $mimeType = "application/x-msdos-program"
                    $isText = $true
                }
                ".cmd" {
                    $mimeType = "application/x-msdos-program"
                    $isText = $true
                }
                ".py" {
                    $mimeType = "text/x-python"
                    $isText = $true
                }
                ".rb" {
                    $mimeType = "application/x-ruby"
                    $isText = $true
                }
                ".txt" {
                    $mimeType = "text/plain"
                    $isText = $true
                }
                ".pl" {
                    $mimeType = "text/x-perl"
                    $isText = $true
                }
                ".php" {
                    $mimeType = "application/x-httpd-php"
                    $isText = $true
                }
                ".js" {
                    $mimeType = "application/javascript"
                    $isText = $true
                }
                ".ts" {
                    $mimeType = "application/typescript"
                    $isText = $true
                }
                ".java" {
                    $mimeType = "text/x-java-source"
                    $isText = $true
                }
                ".c" {
                    $mimeType = "text/x-c"
                    $isText = $true
                }
                ".cpp" {
                    $mimeType = "text/x-c++src"
                    $isText = $true
                }
                ".cs" {
                    $mimeType = "text/x-csharp"
                    $isText = $true
                }
                ".go" {
                    $mimeType = "text/x-go"
                    $isText = $true
                }
                ".rs" {
                    $mimeType = "text/x-rustsrc"
                    $isText = $true
                }
                ".swift" {
                    $mimeType = "text/x-swift"
                    $isText = $true
                }
                ".kt" {
                    $mimeType = "text/x-kotlin"
                    $isText = $true
                }
                ".scala" {
                    $mimeType = "text/x-scala"
                    $isText = $true
                }
                ".r" {
                    $mimeType = "text/x-r"
                    $isText = $true
                }
                ".sql" {
                    $mimeType = "application/sql"
                    $isText = $true
                }
                ".html" {
                    $mimeType = "text/html"
                    $isText = $true
                }
                ".css" {
                    $mimeType = "text/css"
                    $isText = $true
                }
                ".xml" {
                    $mimeType = "application/xml"
                    $isText = $true
                }
                ".json" {
                    $mimeType = "application/json"
                    $isText = $true
                }
                ".yaml" {
                    $mimeType = "application/x-yaml"
                    $isText = $true
                }
                ".md" {
                    $mimeType = "text/markdown"
                    $isText = $true
                }

                default {
                    $mimeType = "image/jpeg"
                    $isText = $false
                }
            }

            function getImageBase64Data($filePath, $imageDetail) {

                $image = $null
                try {
                    $image = [System.Drawing.Image]::FromFile($filePath)
                }
                catch {
                    $image = $null
                }
                if ($null -eq $image) {

                    return [System.Convert]::ToBase64String([IO.File]::ReadAllBytes($filePath));
                }

                $maxImageDimension = [Math]::Max($image.Width, $image.Height);
                $maxDimension = $maxImageDimension;

                switch ($imageDetail) {

                    "low" {
                        $maxDimension = 800;
                    }
                    "medium" {
                        $maxDimension = 1600;
                    }
                }

                try {
                    if ($maxDimension -lt $maxImageDimension) {

                        $newWidth = $image.Width;
                        $newHeight = $image.Height;

                        if ($image.Width -gt $image.Height) {

                            $newWidth = $maxDimension
                            $newHeight = [math]::Round($image.Height * ($maxDimension / $image.Width))
                        }
                        else {
                            $newHeight = $maxDimension
                            $newWidth = [math]::Round($image.Width * ($maxDimension / $image.Height))
                        }

                        $scaledImage = New-Object System.Drawing.Bitmap $newWidth, $newHeight
                        $graphics = [System.Drawing.Graphics]::FromImage($scaledImage)
                        $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
                        $graphics.Dispose();
                    }
                }
                catch {
                }

                $memoryStream = New-Object System.IO.MemoryStream
                $image.Save($memoryStream, $image.RawFormat)
                $imageData = $memoryStream.ToArray()
                $memoryStream.Close()
                $image.Dispose()

                $base64Image = [System.Convert]::ToBase64String($imageData);

                return $base64Image;
            }



            if ($isText) {

                $base64Image = [System.Convert]::ToBase64String([IO.File]::ReadAllBytes($filePath));
                $messages.Add(
                    @{
                        role    = "user"
                        content = $query
                        file    = @{
                            name         = [IO.Path]::GetFileName($filePath)
                            content_type = $mimeType
                            bytes        = "data:$mimeType;base64,$base64Image"
                        }
                    }
                ) | Out-Null;
            }
            else {

                $base64Image = getImageBase64Data $filePath $imageDetail

                $messages.Add(
                    @{
                        role    = "user"
                        content = @(
                            @{
                                type      = "image_url"
                                image_url = @{
                                    url    = "data:$mimeType;base64,$base64Image"
                                    detail = "$imageDetail"
                                }
                            }
                        )
                    }
                ) | Out-Null;
            }
        }

        $messages.Add(
            @{
                role    = "user"
                content = @(
                    @{
                        type = "text"
                        text = $query
                    }
                )
            }
        ) | Out-Null;

        $json = @{
            "stream"      = $false
            "model"       = "$($loadedModel.path)"
            "messages"    = $messages
            "temperature" = $temperature
            "max_tokens"  = $max_token
        } | ConvertTo-Json -Depth 60 -Compress;

        $apiUrl = "http://localhost:1234/v1/chat/completions"
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json);

        $headers = @{
            "Content-Type" = "application/json"
        }

        Write-Verbose "Quering LM-Studio model '$Model'.."
        # ansi for cursor up and clear line
        [System.Console]::WriteLine("Quering LM-Studio model '$Model'..");

        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $bytes -Headers $headers -OperationTimeoutSeconds 900 -ConnectionTimeoutSeconds 900
        $response.choices.message | ForEach-Object content

        [System.Console]::Write("`e[1A`e[2K");
    }

    # Main script execution
    Start-LMStudio
    $loadedModel = LoadLMStudioModel
    if ($null -eq $loadedModel) { return }
    $result = QueryLMStudio -loadedModel $loadedModel -instructions $Instructions -query $query -attachments $attachments -temperature $temperature -max_token $max_token
    Write-Output $result
}
################################################################################

<#
.SYNOPSIS
Queries the LM-Studio API with an image and returns the response.

.DESCRIPTION
The `Invoke-QueryImageContent` function sends an image to the LM-Studio API and returns the response.

.PARAMETER query
The query string for the LLM.

.PARAMETER ImagePath
The file path of the image to send with the query.

.EXAMPLE
    Invoke-QueryImageContent -query "Analyze this image." -ImagePath "C:\path\to\image.jpg"
#>
function Invoke-QueryImageContent {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The query string for the LLM."
        )]
        [string]$query,

        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "The file path of the image to send with the query.")]
        [string]$ImagePath,

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $temperature = 0.1
    )

    # Invoke the LM-Studio query with the specified model, query, instructions, and attachments
    Invoke-LMStudioQuery -Model "MiniCPM" -query $query -Instructions "You are an AI assistant that analyzes images." -attachments @($ImagePath) -temperature $temperature -max_token 3253
    # Invoke-LMStudioQuery -model "xtuner/llava-llama-3-8b-v1_1-gguf/llava-llama-3-8b-v1_1-f16.gguf" -query $query -instructions "You are an AI assistant that analyzes images." -attachments @($ImagePath) -temperature $temperature
}

################################################################################
<#
.SYNOPSIS
Queries the LM-Studio API to get keywords from an image.

.DESCRIPTION
The `Invoke-ImageKeywordUpdate` function updates the keywords and description of images in a directory.

.PARAMETER imageDirectory
The directory path of the images to update.

.PARAMETER recurse
Recursively search for images in subdirectories.

.PARAMETER onlyNew
Only update images that do not have keywords and description.

.PARAMETER retryFailed
Retry previously failed images.

.EXAMPLE
    Invoke-ImageKeywordUpdate -imageDirectory "C:\path\to\images"

    or in short form:

    updateimages "C:\path\to\images"
#>
function Invoke-ImageKeywordUpdate {

    [CmdletBinding()]
    [Alias("updateimages")]

    param(

        [Parameter(Mandatory = $false, Position = 0, HelpMessage = "The image directory path.")]
        [string] $imageDirectory = ".\",

        [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Recurse directories.")]
        [switch] $recurse,

        [Parameter(Mandatory = $false, Position = 2, HelpMessage = "Skip if already has meta data.")]
        [switch] $onlyNew,

        [Parameter(Mandatory = $false, Position = 3, HelpMessage = "Will retry previously failed images.")]
        [switch] $retryFailed
    )

    $Path = Expand-Path $imageDirectory

    if (-not [IO.Directory]::Exists($Path)) {

        Write-Host "The directory '$Path' does not exist."
        return
    }

    Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse:$recurse -File -ErrorAction SilentlyContinue | ForEach-Object {

        if ($retryFailed) {

            if ([IO.File]::Exists("$($PSItem):description.json")) {

                if ("$([IO.File]::ReadAllText("$($PSItem):description.json"))".StartsWith("{}")) {

                    [IO.File]::Delete("$($PSItem):description.json");
                }
            }

            if ([IO.File]::Exists("$($PSItem):keywords.json")) {

                if ("$([IO.File]::ReadAllText("$($PSItem):keywords.json"))".StartsWith("[]")) {

                    [IO.File]::Delete("$($PSItem):keywords.json");
                }
            }
        }

        $image = $_.FullName

        if ($_.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

            $_.Attributes = $_.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
        }

        if ((-not $onlyNew) -or (-not [IO.File]::Exists("$($image):description.json") -or ([IO.File]::Exists("$($image):keywords.json")))) {

            if (-not [IO.File]::Exists("$($image):description.json")) {

                "{}" > "$($image):description.json"
            }

            Write-Verbose "Getting image description for $image.."
            $description = Invoke-QueryImageContent -query "Analyze image and return it as a single json object with properties: short_description (max 80 chars), long_description, has_nudity, keywords (array of strings), has_explicit_content, overall_mood_of_image, picture_type, style_type. The filepath of the image is: '$image'" -ImagePath $image -temperature 0.01
            Write-Verbose $description

            try {
                $description = $description.trim();
                $i0 = $description.IndexOf("{ ")
                $i1 = $description.LastIndexOf("}")
                if ($i0 -ge 0) {

                    $description = $description.Substring($i0, $i1 - $i0 + 1)
                }

                if ([IO.File]::Exists("$($image):keywords.json")) {

                    try {
                        $keywordsFound = [IO.File]::ReadAllText("$($image):keywords.json") | ConvertFrom-Json

                        if ($null -eq $descriptionFound.keywords) {

                            Add-Member -NotePropertyName "keywords" -InputObject $description -NotePropertyValue $keywordsFound -Force | Out-Null

                            [IO.File]::Delete("$($image):keywords.json")
                        }
                    }
                    catch {
                        $keywordsFound = @()
                    }
                }

                $description | ConvertFrom-Json | ConvertTo-Json -Compress -Depth 20 | Out-File -FilePath "$($image):description.json" -Force
            }
            catch {
                Write-Warning $_
            }
        }

        # if ($onlyNew -and [IO.File]::Exists("$($image):keywords.json")) {

        #     return
        # }

        # if (-not [IO.File]::Exists("$($image):keywords.json")) {

        #     "[]" > "$($image):keywords.json"
        # }

        # $keywords = Invoke-QueryImageKeywords -ImagePath $image

        # if ($null -ne $keywords) {

        #     $keywords = $keywords | ConvertTo-Json -Compress -Depth 20;
        #     Write-Verbose "$image : $keywords`r`n`r`n"

        #     $keywords | Out-File -FilePath "$($image):keywords.json" -Force
        # }
    }
}

################################################################################
<#
.SYNOPSIS
Queries the LM-Studio API to get keywords from an image.

.DESCRIPTION
The `Invoke-ImageKeywordScan` function scans images in a directory for keywords and description.

.PARAMETER keywords
The keywords to look for, wildcards allowed.

.PARAMETER imageDirectory
The image directory path.

.PARAMETER passthru
Don't show the images in the webbrowser, return as object instead.

.EXAMPLE
    Invoke-ImageKeywordScan -keywords "cat" -imageDirectory "C:\path\to\images"
#>
function Invoke-ImageKeywordScan {

    [CmdletBinding()]
    [Alias("findimages")]

    param(

        [Parameter(Mandatory = $false, Position = 0, HelpMessage = "The keywords to look for, wildcards allowed.")]
        [string[]] $keywords = @(),

        [Parameter(Mandatory = $false, Position = 1, HelpMessage = "The image directory path.")]
        [string] $imageDirectory = ".\",

        [Parameter(Mandatory = $false, Position = 2, HelpMessage = "Don't show the images in the webbrowser, return as object instead")]
        [switch] $passthru
    )

    $Path = Expand-Path $imageDirectory

    if (-not [IO.Directory]::Exists($Path)) {

        Write-Host "The directory '$Path' does not exist."
        return
    }

    $results = Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse -File -ErrorAction SilentlyContinue | ForEach-Object {

        $image = $_.FullName
        $keywordsFound = @()
        $descriptionFound = $null;

        if ([IO.File]::Exists("$($image):description.json")) {

            try {
                $descriptionFound = [IO.File]::ReadAllText("$($image):description.json") | ConvertFrom-Json
                $keywordsFound = ($null -eq $descriptionFound.keywords) ? @() : $descriptionFound.keywords;

            }
            catch {
                $descriptionFound = $null;
            }
        }

        if ([IO.File]::Exists("$($image):keywords.json")) {

            try {
                $keywordsFound = [IO.File]::ReadAllText("$($image):keywords.json") | ConvertFrom-Json

                if ($null -eq $descriptionFound.keywords) {

                    Add-Member -NotePropertyName "keywords" -InputObject $descriptionFound -NotePropertyValue $keywordsFound -Force | Out-Null

                    [IO.File]::Delete("$($image):keywords.json")

                    $descriptionFound | ConvertTo-Json -Depth 99 -Compress |  Set-Content "$($image):description.json" | ConvertFrom-Json
                }
            }
            catch {
                $keywordsFound = @()
            }
        }

        if (
            (
                # No keywords specified or no keywords found
                ($null -eq $keywords -or ($keywords.Length -eq 0)) -and
                (
                    # No keywords found
                    ($null -eq $keywordsFound -or ($keywordsFound.length -eq 0)) -and

                    # No description found
                    ($null -eq $descriptionFound)
                )
            )) {

            return;
        }

        # No keywords specified
        $found = ($null -eq $keywords -or ($keywords.Length -eq 0));

        # keywords specified
        if (-not $found) {

            # get json of description
            $descriptionFoundJson = $null -ne $descriptionFound ? $descriptionFound : "" | ConvertTo-Json -Compress -Depth 10

            # check if any of the keywords are found in the description
            foreach ($requiredKeyword in $keywords) {

                # check if the description contains the keyword
                $found = "$descriptionFoundJson" -like $requiredKeyword;

                # if not found, check if any of the keywords are found in the keywords
                if (-not $found) {

                    # skip if no keywords found for this image?
                    if ($null -eq $keywordsFound -or ($keywordsFound.Length -eq 0)) { continue; }

                    # check if any of the keywords are found in the keywords
                    foreach ($imageKeyword in $keywordsFound) {

                        # check if the keyword matches
                        if ($imageKeyword -like $requiredKeyword) {

                            $found = $true
                            break;
                        }
                    }
                }

                if ($found) {

                    break;
                }
            }
        }

        if ($found) {

            @{
                path        = $image
                keywords    = $keywordsFound
                description = $descriptionFound
            }
        }
    };

    if ($passthru) {

        $results
    }
    else {

        if ((-not $results) -or ($null -eq $results) -or ($results.Length -eq 0)) {

            if (($null -eq $keywords) -or ($keywords.Length -eq 0)) {

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
#>
function GenerateMasonryLayoutHtml {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [array]$Images,

        [Parameter(Mandatory = $false, Position = 1)]
        [string]$FilePath = $null
    )

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

    Add-Type -AssemblyName System.Web
    $i = 0;
    foreach ($image in $Images) {
        $keywords = $image.keywords -join ", "
        $html += @"
        <div class="item" id="img$i">
            <a href="$($image.path)" target="_blank" onclick="setClipboard($i)">
                <img src="$($image.path)" alt="$($image.description.short_description)" title='$(([System.Web.HttpUtility]::HtmlAttributeEncode("$($image.description.long_description)`r`n$keywords")))'>
            </a>
        </div>
"@

        $i++;
    }

    $html += @"
    </div>
</body>
</html>
"@

    if ($null -eq $FilePath) {
        $html
    }
    else {
        $html | Out-File -FilePath (Expand-Path $FilePath -CreateDirectory) -Encoding utf8
    }
}

################################################################################
<#
.SYNOPSIS
Transcribes audio to text using the default audio input device.

.DESCRIPTION
Records audio using the default audio input device and returns the detected text

.PARAMETER WaveFile
Path to the 16Khz mono, .WAV file to process.

.PARAMETER Passthru
Returns objects instead of strings.

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input

.PARAMETER WithTokenTimestamps
Whether to include token timestamps in the output.

.PARAMETER TokenTimestampsSumThreshold
Sum threshold for token timestamps, defaults to 0.5.

.PARAMETER SplitOnWord
Whether to split on word boundaries.

.PARAMETER MaxTokensPerSegment
Maximum number of tokens per segment.

.PARAMETER IgnoreSilence
Whether to ignore silence (will mess up timestamps).

.PARAMETER MaxDurationOfSilence
Maximum duration of silence before automatically stopping recording.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30).

.PARAMETER Language
Sets the language to detect, defaults to 'auto'.

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for speech generation.

.PARAMETER TemperatureInc
Temperature increment.

.PARAMETER Prompt
Prompt to use for the model.

.PARAMETER SuppressRegex
Regex to suppress tokens from the output.

.PARAMETER WithProgress
Whether to show progress.

.PARAMETER AudioContextSize
Size of the audio context.

.PARAMETER DontSuppressBlank
Whether to NOT suppress blank lines.

.PARAMETER MaxDuration
Maximum duration of the audio.

.PARAMETER Offset
Offset for the audio.

.PARAMETER MaxLastTextTokens
Maximum number of last text tokens.

.PARAMETER SingleSegmentOnly
Whether to use single segment only.

.PARAMETER PrintSpecialTokens
Whether to print special tokens.

.PARAMETER MaxSegmentLength
Maximum segment length.

.PARAMETER MaxInitialTimestamp
Start timestamps at this moment.

.PARAMETER LengthPenalty
Length penalty.

.PARAMETER EntropyThreshold
Entropy threshold.

.PARAMETER LogProbThreshold
Log probability threshold.

.PARAMETER NoSpeechThreshold
No speech threshold.

.PARAMETER NoContext
Don't use context.

.PARAMETER WithBeamSearchSamplingStrategy
Use beam search sampling strategy.

.EXAMPLE
    $text = Start-AudioTranscription;
    $text
#>
function Start-AudioTranscription {

    [Alias("transcribe", "recordandtranscribe")]

    param (
        [Parameter(Mandatory = $false, HelpMessage = "Path to the 16Khz mono, .WAV file to process")]
        [string] $WaveFile = $null,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use silence detection to automatically stop recording."
        )]
        [switch] $VOX,

        [Parameter(Mandatory = $false, HelpMessage = "Returns objects instead of strings")]
        [switch] $Passthru,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to use desktop audio capture instead of microphone input")]
        [switch] $UseDesktopAudioCapture,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to include token timestamps in the output")]
        [switch] $WithTokenTimestamps,

        [Parameter(Mandatory = $false, HelpMessage = "Sum threshold for token timestamps, defaults to 0.5")]
        [float] $TokenTimestampsSumThreshold = 0.5,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to split on word boundaries")]
        [switch] $SplitOnWord,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum number of tokens per segment")]
        [int] $MaxTokensPerSegment,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to ignore silence (will mess up timestamps)")]
        [switch] $IgnoreSilence,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of silence before automatically stopping recording")]
        [timespan] $MaxDurationOfSilence,

        [Parameter(Mandatory = $false, HelpMessage = "Silence detect threshold (0..32767 defaults to 30)")]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Sets the language to detect, defaults to 'auto'")]
        [string] $Language = "auto",

        [Parameter(Mandatory = $false, HelpMessage = "Number of CPU threads to use, defaults to 0 (auto)")]
        [int] $CpuThreads = 0,

        [Parameter(Mandatory = $false, HelpMessage = "Temperature for speech generation")]
        [ValidateRange(0, 100)]
        [float] $Temperature = 0.01,

        [Parameter(Mandatory = $false, HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        [float] $TemperatureInc,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to translate the output")]
        [switch] $WithTranslate,

        [Parameter(Mandatory = $false, HelpMessage = "Prompt to use for the model")]
        [string] $Prompt,

        [Parameter(Mandatory = $false, HelpMessage = "Regex to suppress tokens from the output")]
        [string] $SuppressRegex = $null,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to show progress")]
        [switch] $WithProgress,

        [Parameter(Mandatory = $false, HelpMessage = "Size of the audio context")]
        [int] $AudioContextSize,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to NOT suppress blank lines")]
        [switch] $DontSuppressBlank,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of the audio")]
        [timespan] $MaxDuration,

        [Parameter(Mandatory = $false, HelpMessage = "Offset for the audio")]
        [timespan] $Offset,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum number of last text tokens")]
        [int] $MaxLastTextTokens,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to use single segment only")]
        [switch] $SingleSegmentOnly,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to print special tokens")]
        [switch] $PrintSpecialTokens,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum segment length")]
        [int] $MaxSegmentLength,

        [Parameter(Mandatory = $false, HelpMessage = "Start timestamps at this moment")]
        [timespan] $MaxInitialTimestamp,

        [Parameter(Mandatory = $false, HelpMessage = "Length penalty")]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,

        [Parameter(Mandatory = $false, HelpMessage = "Entropy threshold")]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Log probability threshold")]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "No speech threshold")]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Don't use context")]
        [switch] $NoContext,

        [Parameter(Mandatory = $false, HelpMessage = "Use beam search sampling strategy")]
        [switch] $WithBeamSearchSamplingStrategy
    )

    process {


        $ModelFilePath = Expand-Path "$PSScriptRoot\..\..\GenXdev.Local\" -CreateDirectory

        if (-not $PSBoundParameters.ContainsKey("ModelFilePath")) {

            $PSBoundParameters.Add("ModelFilePath", $ModelFilePath) | Out-Null;
        }

        if ($VOX -eq $true) {

            if (-not $PSBoundParameters.ContainsKey("MaxDurationOfSilence")) {

                $PSBoundParameters.Add("MaxDurationOfSilence", [timespan]::FromSeconds(4)) | Out-Null;
            }
            else {

                $PSBoundParameters["MaxDurationOfSilence"] = [timespan]::FromSeconds(4);
            }

            if (-not $PSBoundParameters.ContainsKey("IgnoreSilence")) {

                $PSBoundParameters.Add("IgnoreSilence", $true) | Out-Null;
            }
            else {

                $PSBoundParameters["IgnoreSilence"] = $true
            }

            if ($PSBoundParameters.ContainsKey("VOX")) {
                $PSBoundParameters.Remove("VOX") | Out-Null;
            }
        }

        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null;
        }

        if (-not (Get-HasCapableGpu)) {

            if (-not $PSBoundParameters.ContainsKey("CpuThreads")) {

                $PSBoundParameters.Add("CpuThreads", (Get-NumberOfCpuCores)) | Out-Null;
            }
        }

        # Remove any parameters with $null values
        $PSBoundParameters.GetEnumerator() | ForEach-Object {
            if ($null -eq $_.Value) {
                $PSBoundParameters.Remove($_.Key) | Out-Null
            }
        }

        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = "Stop"
        try {

            Get-SpeechToText @PSBoundParameters
        }
        finally {

            $ErrorActionPreference = $oldErrorActionPreference
        }
    }
}

################################################################################
<#
.SYNOPSIS
Translates text to another language using the LM-Studio API.

.DESCRIPTION
The `Get-TextTranslation` function translates text to another language using the LM-Studio API.

.PARAMETER Text
The text to translate.

.PARAMETER Language
The language to translate to.

.PARAMETER Instructions
The instructions for the model.
Defaults to:

.PARAMETER Model
The LM-Studio model to use for generating the response.

.EXAMPLE
    Get-TextTranslation -Text "Hello, how are you?" -Language "french"

    "Hello, how are you?" | translate -Language "french"

#>
function Get-TextTranslation {

    [CmdletBinding()]
    [Alias("translate", "Get-Translation")]

    param (
        [Parameter(
            Mandatory = $true,
            HelpMessage = "The text to translate",
            ValueFromPipeline = $true
        )]
        [string] $Text,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The language to translate to."
        )]
        [PSDefaultValue(Value = "english")]
        [string] $Language = "english",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The system instructions for the LLM."
        )]
        [PSDefaultValue(Value = "Translate this partial subtitle text, into the `[Language] language, leave in the same style of writing, and leave the paragraph structure in tact, ommit only the translation no yapping or chatting.")]
        $Instructions = "Translate this partial subtitle text, into the [Language] language, leave in the same style of writing, and leave the paragraph structure in tact, ommit only the translation no yapping or chatting.",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response."
        )]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$Model = "yi-coder-9b-chat"
    )

    begin {
        # initialize translation container
        [System.Text.StringBuilder] $translation = New-Object System.Text.StringBuilder;

        $Instructions = $Instructions.Replace("[Language]", $Language);

        [System.Console]::Write("translating to $Language..")
    }

    process {

        # initialize the cursor, trying +/- 1K characters
        $i = [Math]::Min(1000, $Text.Length)

        # perform translations in chunks
        while ($i -gt 0) {

            # move the cursor to the next word
            while (($i -gt 0) -and (" `t`r`n".indexOf($Text[$i]) -lt 0)) { $i--; }
            while (($i -lt $Text.Length) -and (" `t`r`n".indexOf($Text[$i]) -lt 0)) { $i++; }
            if ($i -lt 1000) { $i = $Text.Length; }

            # get the next part of the text
            $nextPart = $Text.Substring(0, $i);
            $spaceLeft = "";

            # remove the part from the work queue
            $Text = $Text.Substring($i);

            if ([string]::IsNullOrWhiteSpace($nextPart)) {

                $translation.Append("$nextPart") | Out-Null
                $i = [Math]::Min(100, $Text.Length)
                continue;
            }

            $spaceLeft = "";
            while ($nextPart.StartsWith(" ") -or $nextPart.StartsWith("`t") -or $nextPart.StartsWith("`r") -or $nextPart.StartsWith("`n")) {

                $spaceLeft += $nextPart[0];
                $nextPart = $nextPart.Substring(1);
            }
            $spaceRight = "";
            while ($nextPart.EndsWith(" ") -or $nextPart.EndsWith("`t") -or $nextPart.EndsWith("`r") -or $nextPart.EndsWith("`n")) {

                $spaceRight += $nextPart[-1];
                $nextPart = $nextPart.Substring(0, $nextPart.Length - 1);
            }

            Write-Verbose "Translating text to $Language for: `"$nextPart`".."

            try {
                # translate the text
                $translatedPart = qlms -query $nextPart -Instructions $Instructions -Model $Model -temperature 0.02

                # append the translated part
                $translation.Append("$spaceLeft$translatedPart$spaceRight") | Out-Null

                Write-Verbose "Text translated to: `"$translatedPart`".."
            }
            catch {

                # append the original part
                $translation.Append("$spaceLeft$nextPart$spaceRight") | Out-Null

                Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
            }

            $i = [Math]::Min(100, $Text.Length)
        }
    }

    end {
        [System.Console]::Write("`e[1A`e[2K")

        # return the translation
        $translation.ToString();
    }
}

################################################################################
<#
.SYNOPSIS
Transcribes an audio or video file to text..

.DESCRIPTION
Transcribes an audio or video file to text using the Whisper AI model

.PARAMETER FilePath
The file path of the audio or video file to transcribe.

.PARAMETER LanguageIn
The language to expect in the audio. E.g. "en", "fr", "de", "nl"

.PARAMETER LanguageOut
The language to translate to. E.g. "french", "german", "dutch"

.PARAMETER SRT
Output in SRT format.

.PARAMETER Passthru
Returns objects instead of strings.

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input

.PARAMETER TranslateUsingLMStudioModel
The LM Studio model to use for translation.

.PARAMETER MaxSrtChars
The maximum number of characters per line in the SRT output.

.PARAMETER WithTokenTimestamps
Whether to include token timestamps in the output.

.PARAMETER TokenTimestampsSumThreshold
Sum threshold for token timestamps, defaults to 0.5.

.PARAMETER SplitOnWord
Whether to split on word boundaries.

.PARAMETER MaxTokensPerSegment
Maximum number of tokens per segment.

.PARAMETER MaxDurationOfSilence
Maximum duration of silence before automatically stopping recording.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30)

.PARAMETER ModelFilePath
Path to the model file.

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for speech generation.

.PARAMETER TemperatureInc
Temperature increment.

.PARAMETER SuppressRegex
Regex to suppress tokens from the output.

.PARAMETER WithProgress
Whether to show progress.

.PARAMETER AudioContextSize
Size of the audio context.

.PARAMETER DontSuppressBlank
Whether to NOT suppress blank lines.

.PARAMETER MaxDuration
Maximum duration of the audio.

.PARAMETER Offset
Offset for the audio.

.PARAMETER MaxLastTextTokens
Maximum number of last text tokens.

.PARAMETER SingleSegmentOnly
Whether to use single segment only.

.PARAMETER PrintSpecialTokens
Whether to print special tokens.

.PARAMETER MaxSegmentLength
Maximum segment length.

.PARAMETER MaxInitialTimestamp
Start timestamps at this moment.

.PARAMETER LengthPenalty
Length penalty.

.PARAMETER EntropyThreshold
Entropy threshold.

.PARAMETER LogProbThreshold
Log probability threshold.

.PARAMETER NoSpeechThreshold
No speech threshold.

.PARAMETER NoContext
Don't use context.

.PARAMETER WithBeamSearchSamplingStrategy
Use beam search sampling strategy.

.PARAMETER Prompt
Prompt to use for the model.

.EXAMPLE
    Get-MediaFileAudioTranscription -FilePath "C:\path\to\audio.wav" -LanguageIn "en" -LanguageOut "french" -SRT
#>
function Get-MediaFileAudioTranscription {
    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The file path of the audio or video file to transcribe."
        )]
        [string] $FilePath,

        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The language to expect in the audio."
        )]
        [PSDefaultValue(Value = "auto")]
        [string] $LanguageIn = "auto",


        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Sets the language to translate to."
        )]
        [string]$LanguageOut = $null,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio model to use for translation."
        )]
        [string] $TranslateUsingLMStudioModel = "yi-coder-9b-chat",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Output in SRT format."
        )]
        [switch] $SRT,

        [Parameter(Mandatory = $false, HelpMessage = "Returns objects instead of strings")]
        [switch] $Passthru,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to use desktop audio capture instead of microphone input")]
        [switch] $UseDesktopAudioCapture,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to include token timestamps in the output")]
        [switch] $WithTokenTimestamps,

        [Parameter(Mandatory = $false, HelpMessage = "Sum threshold for token timestamps, defaults to 0.5")]
        [float] $TokenTimestampsSumThreshold = 0.5,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to split on word boundaries")]
        [switch] $SplitOnWord,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum number of tokens per segment")]
        [int] $MaxTokensPerSegment,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to ignore silence (will mess up timestamps)")]
        [switch] $IgnoreSilence,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of silence before automatically stopping recording")]
        [timespan] $MaxDurationOfSilence,

        [Parameter(Mandatory = $false, HelpMessage = "Silence detect threshold (0..32767 defaults to 30)")]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Number of CPU threads to use, defaults to 0 (auto)")]
        [int] $CpuThreads = 0,

        [Parameter(Mandatory = $false, HelpMessage = "Temperature for speech recognition")]
        [ValidateRange(0, 100)]
        [float] $Temperature = 0.01,

        [Parameter(Mandatory = $false, HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        [float] $TemperatureInc,

        [Parameter(Mandatory = $false, HelpMessage = "Prompt to use for the model")]
        [string] $Prompt,

        [Parameter(Mandatory = $false, HelpMessage = "Regex to suppress tokens from the output")]
        [string] $SuppressRegex = $null,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to show progress")]
        [switch] $WithProgress,

        [Parameter(Mandatory = $false, HelpMessage = "Size of the audio context")]
        [int] $AudioContextSize,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to NOT suppress blank lines")]
        [switch] $DontSuppressBlank,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of the audio")]
        [timespan] $MaxDuration,

        [Parameter(Mandatory = $false, HelpMessage = "Offset for the audio")]
        [timespan] $Offset,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum number of last text tokens")]
        [int] $MaxLastTextTokens,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to use single segment only")]
        [switch] $SingleSegmentOnly,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to print special tokens")]
        [switch] $PrintSpecialTokens,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum segment length")]
        [int] $MaxSegmentLength,

        [Parameter(Mandatory = $false, HelpMessage = "Start timestamps at this moment")]
        [timespan] $MaxInitialTimestamp,

        [Parameter(Mandatory = $false, HelpMessage = "Length penalty")]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,

        [Parameter(Mandatory = $false, HelpMessage = "Entropy threshold")]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Log probability threshold")]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "No speech threshold")]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Don't use context")]
        [switch] $NoContext,

        [Parameter(Mandatory = $false, HelpMessage = "Use beam search sampling strategy")]
        [switch] $WithBeamSearchSamplingStrategy
    )

    process {

        $MaxSrtChars = [System.Math]::Min(200, [System.Math]::Max(20, $MaxSrtChars))

        $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName

        function IsLMStudioInstalled {

            return Test-Path -Path $lmsPath -ErrorAction SilentlyContinue
        }

        # Function to check if LMStudio is running
        function IsLMStudioRunning {

            $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue
            return $null -ne $process
        }

        function IsWinGetInstalled {

            Import-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue
            $module = Get-Module "Microsoft.WinGet.Client" -ErrorAction SilentlyContinue

            if ($null -eq $module) {

                return $false
            }

            return $true
        }

        function InstallWinGet {

            Write-Verbose "Installing WinGet PowerShell client.."
            Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
            Import-Module "Microsoft.WinGet.Client"
        }

        $ffmpegPath = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1 | ForEach-Object FullName)

        function Installffmpeg {

            if ($null -ne $ffmpegPath) { return }

            if (-not (IsWinGetInstalled)) {

                InstallWinGet
            }

            $ffmpeg = "Gyan.FFmpeg"
            $ffmpegPackage = Get-WinGetPackage -Id $ffmpeg

            if ($null -ne $ffmpegPackage) {

                Write-Verbose "Installing ffmpeg.."
                Install-WinGetPackage -Id $ffmpeg -Force
                $ffmpegPath = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\ffmpeg.exe" -File -rec -ErrorAction SilentlyContinue | Select-Object -First 1).FullName
            }
        }

        # Make sure ffmpeg is installed
        Installffmpeg | Out-Null

        # Replace these paths with your actual file paths
        $inputFile = Expand-Path $FilePath
        $outputFile = [IO.Path]::GetTempFileName() + ".wav";

        # Construct and execute the ffmpeg command
        $job = Start-Job -ArgumentList $ffmpegPath, $inputFile, $outputFile -ScriptBlock {

            param($ffmpegPath, $inputFile, $outputFile)

            try {
                [System.Console]::WriteLine("Converting the file '$inputFile' to WAV format..");
                # Convert the file to WAV format
                & $ffmpegPath -i "$inputFile" -ac 1 -ar 16000 -sample_fmt s16 "$outputFile" -loglevel quiet -y | Out-Null
            }
            finally {
                [System.Console]::Write("`e[1A`e[2K")
            }

            return $LASTEXITCODE
        }

        # Wait for the job to complete and check the result
        $job | Wait-Job | Out-Null
        $success = ($job | Receive-Job) -eq 0
        Remove-Job -Job $job | Out-Null

        if (-not $success) {

            Write-Warning "Failed to convert the file '$inputFile' to WAV format."

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Remove-Item -Path $outputFile -Force | Out-Null
            }

            return
        }

        if (-not $PSBoundParameters.ContainsKey("Language")) {

            $PSBoundParameters.Add("Language", $LanguageIn) | Out-Null;
        }
        else {

            $PSBoundParameters["Language"] = $LanguageIn;
        }

        if ($PSBoundParameters.ContainsKey("WithTranslate")) {

            $PSBoundParameters.Remove("WithTranslate", $true) | Out-Null;
        }

        if (($SRT -eq $true) -and (-not $PSBoundParameters.ContainsKey("Passthru"))) {

            $PSBoundParameters.Add("Passthru", $true) | Out-Null;
        }
        else {

            if ((-not $SRT) -and $PSBoundParameters.ContainsKey("Passthru")) {

                $PSBoundParameters.Remove("Passthru") | Out-Null
            }
        }

        if ($PSBoundParameters.ContainsKey("FilePath")) {

            $PSBoundParameters.Remove("FilePath") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("LanguageIn")) {

            $PSBoundParameters.Remove("LanguageIn") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("LanguageOut")) {

            $PSBoundParameters.Remove("LanguageOut") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("SRT")) {

            $PSBoundParameters.Remove("SRT") | Out-Null
        }
        if ($PSBoundParameters.ContainsKey("TranslateUsingLMStudioModel")) {

            $PSBoundParameters.Remove("TranslateUsingLMStudioModel") | Out-Null
        }

        if (-not $PSBoundParameters.ContainsKey("WaveFile")) {

            $PSBoundParameters.Add("WaveFile", $outputFile) | Out-Null;
        }

        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null;
        }

        if (-not (Get-HasCapableGpu)) {

            if (-not $PSBoundParameters.ContainsKey("CpuThreads")) {

                $PSBoundParameters.Add("CpuThreads", (Get-NumberOfCpuCores)) | Out-Null;
            }
        }

        try {

            # outputting in SRT format?
            if ($SRT) {

                # initialize srt counter
                $i = 1

                Start-AudioTranscription @PSBoundParameters | ForEach-Object {

                    $result = $PSItem;

                    # needs translation?
                    if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                        Write-Verbose "Translating text to $LanguageOut for: `"$($result.Text)`".."

                        try {
                            # translate the text
                            $result = @{
                                Text  = (Get-TextTranslation -Text:($result.Text) -Language:$LanguageOut -Model:$TranslateUsingLMStudioModel -Instructions "Translate this partial subtitle text, into the [Language] language. ommit only the translation no yapping or chatting. return in json format like so: {`"Translation`":`"Translated text here`"}" | ConvertFrom-Json).Translation;
                                Start = $result.Start;
                                End   = $result.End;
                            }

                            Write-Verbose "Text translated to: `"$($result.Text)`".."
                        }
                        catch {

                            Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
                        }
                    }

                    $start = $result.Start.ToString("hh\:mm\:ss\,fff", [CultureInfo]::InvariantCulture);
                    $end = $result.end.ToString("hh\:mm\:ss\,fff", [CultureInfo]::InvariantCulture);

                    "$i`r`n$start --> $end`r`n$($result.Text)`r`n`r`n"

                    # increment the counter
                    $i++
                }

                # end of SRT format
                return;
            }

            #  needs translation?
            if (-not [string]::IsNullOrWhiteSpace($LanguageOut) -and ![string]::IsNullOrWhiteSpace($TranslateUsingLMStudioModel)) {

                # transcribe the audio file to text
                $results = Get-SpeechToText @PSBoundParameters

                # delegate
                Get-TextTranslation -Text "$results" -Language $LanguageOut -Model $TranslateUsingLMStudioModel

                # end of translation
                return;
            }

            # return the text results without translation
            Start-AudioTranscription @PSBoundParameters
        }
        catch {

            if ("$PSItem" -notlike "*aborted*") {

                Write-Error $PSItem
            }
        }
        finally {

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Remove-Item -Path $outputFile -Force
            }
        }
    }
}

################################################################################
<#
.SYNOPSIS
Starts a rudimentary audio chat session.

.DESCRIPTION
Starts a rudimentary audio chat session using Whisper and the LM-Studio API.

.PARAMETER Instructions
The system instructions for the responding LLM.
Default value: "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice."

.PARAMETER Model
The LM-Studio model to use for generating the response.
Default value: "yi-coder-9b-chat"

.PARAMETER UseDesktopAudioCapture
Whether to use desktop audio capture instead of microphone input.

.PARAMETER TemperatureResponse
The temperature parameter for controlling the randomness of the response.

.PARAMETER Language
Sets the language to detect, defaults to 'auto'.

.PARAMETER CpuThreads
Number of CPU threads to use, defaults to 0 (auto).

.PARAMETER Temperature
Temperature for response generation.

.PARAMETER TemperatureInc
Temperature increment.

.PARAMETER Prompt
Prompt to use for the model.

.PARAMETER SuppressRegex
Regex to suppress tokens from the output.

.PARAMETER AudioContextSize
Size of the audio context.

.PARAMETER MaxDuration
Maximum duration of the audio.

.PARAMETER LengthPenalty
Length penalty.

.PARAMETER EntropyThreshold
Entropy threshold.

.PARAMETER LogProbThreshold
Log probability threshold.

.PARAMETER NoSpeechThreshold
No speech threshold.

.PARAMETER NoContext
Don't use context.

.PARAMETER WithBeamSearchSamplingStrategy
Use beam search sampling strategy.

.PARAMETER OnlyResponses
Whether to suppress reconized text in the output.

.PARAMETER NoTextToSpeech
Whether to suppress text to speech.

#>
function Start-AudioChat {

    [Alias("llmchat")]

    param(
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The system instructions for the responding LLM.")]
        [PSDefaultValue(Value = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.")]
        [string]$Instructions = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$Model = "yi-coder-9b-chat",

        [Parameter(Mandatory = $false, HelpMessage = "Whether to use desktop audio capture instead of microphone input")]
        [switch] $UseDesktopAudioCapture,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $TemperatureResponse = 0.01,

        [Parameter(Mandatory = $false, HelpMessage = "Sets the language to detect, defaults to 'auto'")]
        [string] $Language = "auto",

        [Parameter(Mandatory = $false, HelpMessage = "Number of CPU threads to use, defaults to 0 (auto)")]
        [int] $CpuThreads = 0,

        [Parameter(Mandatory = $false, HelpMessage = "Temperature for response generation")]
        [ValidateRange(0, 100)]
        [float] $Temperature = 0.01,

        [Parameter(Mandatory = $false, HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        [float] $TemperatureInc,

        [Parameter(Mandatory = $false, HelpMessage = "Prompt to use for the model")]
        [string] $Prompt,

        [Parameter(Mandatory = $false, HelpMessage = "Regex to suppress tokens from the output")]
        [string] $SuppressRegex = $null,

        [Parameter(Mandatory = $false, HelpMessage = "Size of the audio context")]
        [int] $AudioContextSize,

        [Parameter(Mandatory = $false, HelpMessage = "Maximum duration of the audio")]
        [timespan] $MaxDuration,

        [Parameter(Mandatory = $false, HelpMessage = "Length penalty")]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,

        [Parameter(Mandatory = $false, HelpMessage = "Entropy threshold")]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Log probability threshold")]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "No speech threshold")]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,

        [Parameter(Mandatory = $false, HelpMessage = "Don't use context")]
        [switch] $NoContext,

        [Parameter(Mandatory = $false, HelpMessage = "Use beam search sampling strategy")]
        [switch] $WithBeamSearchSamplingStrategy,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to suppress reconized text in the output")]
        [switch] $OnlyResponses,

        [Parameter(Mandatory = $false, HelpMessage = "Whether to suppress text to speech")]
        [switch] $NoTextToSpeech
    )

    process {
        if (-not $PSBoundParameters.ContainsKey("VOX")) {

            $PSBoundParameters.Add("VOX", $true) | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("OnlyResponses")) {

            $PSBoundParameters.Remove("OnlyResponses") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("NoTextToSpeech")) {

            $PSBoundParameters.Remove("NoTextToSpeech") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("instructions")) {

            $PSBoundParameters.Remove("instructions") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("model")) {

            $PSBoundParameters.Remove("model") | Out-Null;
        }
        if ($PSBoundParameters.ContainsKey("TemperatureResponse")) {

            $PSBoundParameters.Remove("TemperatureResponse") | Out-Null;
        }

        if (-not $PSBoundParameters.ContainsKey("ErrorAction")) {

            $PSBoundParameters.Add("ErrorAction", "Stop") | Out-Null;
        }

        [string] $session = "";

        while ($true) {

            try {

                $text = Start-AudioTranscription @PSBoundParameters
            }
            catch {

                if ("$PSItem" -notlike "*aborted*") {

                    Write-Error $PSItem
                }
                return;
            }

            if (-not [string]::IsNullOrWhiteSpace($text)) {

                $question = $text
                $session += "<< $text`r`n`r`n"

                if (-not $OnlyResponses) {

                    $a = [System.Console]::ForegroundColor
                    [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
                    Write-Host "<< $text"
                    [System.Console]::ForegroundColor = $a;
                }

                $answer = (qlms -query $session -Instructions:$Instructions -Model:$Model -temperature:$TemperatureResponse)
                $session = ">> $question`r`n`r`n<< `r`n$answer`r`n`r`n"

                $a = [System.Console]::ForegroundColor
                [System.Console]::ForegroundColor = [System.ConsoleColor]::Green

                if ($OnlyResponses) {

                    Write-Host "$answer"
                }
                else {
                    Write-Host "<< $answer"
                }
                [System.Console]::ForegroundColor = $a;

                if (-not ($true -eq $NoTextToSpeech)) {

                    Start-TextToSpeech -Text $answer
                }

                Write-Host "Press any key to interrupt and start recording or Q to quit"
            }
            else {

                Write-Host "Only silence recorded";
            }

            # should we wait until a key is pressed?
            while ((Get-IsSpeaking)) {

                while ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey().Key
                    [System.Console]::Write("`e[1G`e[2K")

                    if ($key -eq [ConsoleKey]::Q) {

                        sst;
                        Write-Host "---------------"
                        throw "aborted";
                        return;
                    }
                    else {

                        break
                    }
                }

                Start-Sleep -Milliseconds 100 | Out-Null
            }

            # ansi for cursor up and clear line
            [System.Console]::Write("`e[1A`e[2K")

            sst;
            Write-Host "---------------"
        }
    }
}


################################################################################
<#
.SYNOPSIS
Add suitable emoticons to a text.

.DESCRIPTION
Add suitable emoticons to a text, which can come from pipeline or parameter or clipboard.

.PARAMETER Text
Optionally the text to outfit with emoticons, if not specified, will read and set the clipboard.

.PARAMETER Instructions
Addiitional instructions for the model.

.PARAMETER Model
The LM-Studio model to use for generating the response.

.PARAMETER SetClipboard
Force the result to be set to the clipboard.

.EXAMPLE
    Add-EmoticonsToText -Text "Hello, how are you?"

.EXAMPLE
    or just get emojify the clipboard text:

    emojify

.EXAMPLE
    "This is lion, this is a dog, this is a sheep" | emojify

#>
function Add-EmoticonsToText {

    [CmdletBinding()]
    [Alias("emojify")]

    param (
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The text to emojify.",
            ValueFromPipeline = $true
        )]
        [string] $Text,

        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Additional instructions for the LLM."
        )]
        $Instructions = "",

        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response."
        )]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$Model = "yi-coder-9b-chat",

        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "Whether to set the clipboard with the result."
        )]
        [switch] $SetClipboard
    )

    begin {
        [System.Text.StringBuilder] $allResults = New-Object System.Text.StringBuilder;
        $Instructions = "Add funny or expressive emojii to the text. Don't change the text otherwise.`r`n$Instructions `r`nRespond only in json format, like: {`"response`":`"Hello, how are you? 😊`"}"

        [Console]::Write("emojifying..")
    }

    process {

        $isFromClipboard = [string]::IsNullOrWhiteSpace($Text)
        $Text = "$Text"

        if ($isFromClipboard) {

            $Text = Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {

                Write-Warning "No text found in the clipboard."
                return;
            }
        }

        try {
            Write-Verbose "Emojifying text: `"$Text`".."

            # translate the text
            $Text = (qlms -query "$Text" -Instructions $Instructions -Model $Model | ConvertFrom-Json).response
        }
        finally {


            $allResults.Append("$Text`r`n") | Out-Null
        }
    }

    end {
        $result = $allResults.ToString();

        if ($SetClipboard) {

            Set-Clipboard -Value $result
        }

        $result

        [Console]::Write("`e[1A`e[2K");
    }
}

################################################################################

function Get-HasCapableGpu {

    # Check for CUDA-compatible GPU with at least 8 GB of RAM

    # Get the list of video controllers
    $videoControllers = Get-WmiObject Win32_VideoController | Where-Object { $_.AdapterRAM -ge 8GB }

    return $null -ne $videoControllers
}

################################################################################

function Get-NumberOfCpuCores {

    $cores = 0;

    Get-WmiObject -Class Win32_Processor | Select-Object -Property NumberOfCores  | ForEach-Object { $cores += $_.NumberOfCores }

    return $cores * 2;
}
