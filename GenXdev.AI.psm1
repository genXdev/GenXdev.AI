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

.PARAMETER model
The LM-Studio model to use for generating the response.

.PARAMETER temperature
The temperature parameter for controlling the randomness of the response.

.PARAMETER max_token
The maximum number of tokens to generate in the response.

.PARAMETER imageDetail
The image detail to use for the attachments.

.EXAMPLE
    -------------------------- Example 1 --------------------------

    Invoke-LMStudioQuery -query "Introduce yourself." -instructions "Always answer in rhymes." -model "lmstudio-community/yi-coder-9b-chat-GGUF" -temperature 0.9

    qlms "Introduce yourself." "Always answer in rhymes." "lmstudio-community/yi-coder-9b-chat-GGUF" 0.9

.EXAMPLE
    -------------------------- Example 2 --------------------------

Invoke-LMStudioQuery -query "What is PowerShell?" -temperature 0.7

.EXAMPLE
    -------------------------- Example 3 --------------------------
Invoke-LMStudioQuery -query "Analyze this code" -attachments ".\script.ps1" -instructions "Be thorough"

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
        [string]$instructions = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.",

        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$model = "yi-coder-9b-chat",

        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $temperature = 0.7,

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
        [string] $imageDetail = "low"
    )

    $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec | Select-Object -First 1).FullName

    function IsLMStudioInstalled {

        $lmStudioPath = "$env:LOCALAPPDATA\LM-Studio\LM Studio.exe"
        return Test-Path -Path $lmStudioPath
    }

    # Function to check if LMStudio is running
    function IsLMStudioRunning {

        $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue
        return $null -ne $process
    }

    function IsWinGetInstalled {

        $module = Get-Module "Microsoft.WinGet.Client"

        if ($null -eq $module) {

            return $false
        }
    }
    function InstallWinGet {

        Write-Verbose "Installing WinGet PowerShell client.."
        Install-Module "Microsoft.WinGet.Client" -Force -AllowClobber
    }

    function InstallLMStudio {

        if (-not (IsWinGetInstalled)) {

            InstallWinGet
        }

        $lmStudio = "ElementLabs.LMStudio"
        $lmStudioPackage = Get-WinGetPackage -Name $lmStudio

        if ($null -eq $lmStudioPackage) {

            Write-Verbose "Installing LM-Studio.."
            Install-WinGetPackage -Name $lmStudio -Force
            $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec | Select-Object -First 1).FullName
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
            $lmsPath = (Get-ChildItem "$env:LOCALAPPDATA\LM-Studio\lms.exe" -File -rec | Select-Object -First 1).FullName
            Start-Sleep -Seconds 10
        }
    }

    # Function to get the list of models
    function Get-ModelList {

        Write-Verbose "Getting installed model list.."
        $modelList = & "$lmsPath" ls --yes --json | ConvertFrom-Json
        return $modelList
    }
    function Get-LoadedModelList {

        Write-Verbose "Getting loaded model list.."
        $modelList = & "$lmsPath" ps --yes --json | ConvertFrom-Json
        return $modelList
    }

    # Function to load the LLava model
    function LoadLMStudioModel {

        $modelList = Get-ModelList
        $foundModel = $modelList | Where-Object { $_.path -like "*$model*" } | Select-Object -First 1

        if ($foundModel) {

            Write-Output $foundModel

            $foundModelLoaded = (Get-LoadedModelList) | Where-Object { $_.path -eq $foundModel.path } | Select-Object -First 1

            if ($null -eq $foundModelLoaded) {

                $success = $true;
                try {

                    Write-Verbose "Loading model.."
                    & "$lmsPath" load --identifier $foundModel.path --yes --gpu off

                    if ($LASTEXITCODE -ne 0) {

                        $success = $false;
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

                    throw "Model with path: '*$model*', could not be loaded."
                }
            }
        }
        else {

            throw "Model with path: '*$model*', not found. Please install it manually in LM-Studio first, using the discovery page of LM-Studio."
        }
    }

    # Function to upload image and query to LM-Studio local server
    function QueryLMStudio {

        param (
            $loadedModel,
            [string]$instructions,
            [string]$query,
            [string[]]$attachments,
            [double]$temperature,
            [int]$max_token = -1
        )

        $messages = [System.Collections.ArrayList] @();
        $messages.Add(
            @{
                role    = "system"
                content = "$instructions"
            }
        ) | Out-Null;

        $attachments | ForEach-Object {
            $filePath = Expand-Path $PSItem;
            $fileExtension = [IO.Path]::GetExtension($filePath).ToLowerInvariant();
            $mimeType = "application/octet-stream";
            switch ($fileExtension) {

                ".jpg" { $mimeType = "image/jpeg" }
                ".jpeg" { $mimeType = "image/jpeg" }
                ".png" { $mimeType = "image/png" }
                ".gif" { $mimeType = "image/gif" }
                ".bmp" { $mimeType = "image/bmp" }
                ".tiff" { $mimeType = "image/tiff" }
                ".mp4" { $mimeType = "video/mp4" }
                ".avi" { $mimeType = "video/avi" }
                ".mov" { $mimeType = "video/quicktime" }
                ".webm" { $mimeType = "video/webm" }
                ".mkv" { $mimeType = "video/x-matroska" }
                ".flv" { $mimeType = "video/x-flv" }
                ".wmv" { $mimeType = "video/x-ms-wmv" }
                ".mpg" { $mimeType = "video/mpeg" }
                ".mpeg" { $mimeType = "video/mpeg" }
                ".3gp" { $mimeType = "video/3gpp" }
                ".3g2" { $mimeType = "video/3gpp2" }
                ".m4v" { $mimeType = "video/x-m4v" }
                ".webp" { $mimeType = "image/webp" }
                ".heic" { $mimeType = "image/heic" }
                ".heif" { $mimeType = "image/heif" }
                ".avif" { $mimeType = "image/avif" }
                ".jxl" { $mimeType = "image/jxl" }
                ".ps1" { $mimeType = "text/x-powershell" }
                ".psm1" { $mimeType = "text/x-powershell" }
                ".psd1" { $mimeType = "text/x-powershell" }
                ".sh" { $mimeType = "application/x-sh" }
                ".bat" { $mimeType = "application/x-msdos-program" }
                ".cmd" { $mimeType = "application/x-msdos-program" }
                ".py" { $mimeType = "text/x-python" }
                ".rb" { $mimeType = "application/x-ruby" }
                ".pl" { $mimeType = "text/x-perl" }
                ".php" { $mimeType = "application/x-httpd-php" }
                ".js" { $mimeType = "application/javascript" }
                ".ts" { $mimeType = "application/typescript" }
                ".java" { $mimeType = "text/x-java-source" }
                ".c" { $mimeType = "text/x-c" }
                ".cpp" { $mimeType = "text/x-c++src" }
                ".cs" { $mimeType = "text/x-csharp" }
                ".go" { $mimeType = "text/x-go" }
                ".rs" { $mimeType = "text/x-rustsrc" }
                ".swift" { $mimeType = "text/x-swift" }
                ".kt" { $mimeType = "text/x-kotlin" }
                ".scala" { $mimeType = "text/x-scala" }
                ".r" { $mimeType = "text/x-r" }
                ".sql" { $mimeType = "application/sql" }
                ".html" { $mimeType = "text/html" }
                ".css" { $mimeType = "text/css" }
                ".xml" { $mimeType = "application/xml" }
                ".json" { $mimeType = "application/json" }
                ".yaml" { $mimeType = "application/x-yaml" }
                ".md" { $mimeType = "text/markdown" }

                default { $mimeType = "image/jpeg" }
            }

            function getImageBase64Data($filePath, $imageDetail) {
                $image = $null
                try {
                    $image = [System.Drawing.Image]::FromFile($filePath)
                }
                catch {
                    return
                }
                if ($null -eq $image) {

                    return [System.Convert]::ToBase64String([IO.File]::ReadAllBytes($filePath));
                }

                $image = [System.Drawing.Image]::FromFile($filePath)
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

                if ($maxDimension -lt $maxImageDimension) {

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
                    $graphics.Dispose()
                    $image.Dispose();
                    $image = $scaledImage
                }

                $memoryStream = New-Object System.IO.MemoryStream
                $image.Save($memoryStream, $image.RawFormat)
                $imageData = $memoryStream.ToArray()
                $memoryStream.Close()
                $image.Dispose()
                $base64Image = [System.Convert]::ToBase64String($imageData);
                return $base64Image;
            }

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

        Write-Verbose "Quering LM-Studio model '$model'.."

        $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $bytes -Headers $headers -OperationTimeoutSeconds 900 -ConnectionTimeoutSeconds 900
        $response.choices.message | ForEach-Object content
    }

    # Main script execution
    Start-LMStudio
    $loadedModel = LoadLMStudioModel
    if ($null -eq $loadedModel) { return }
    $result = QueryLMStudio -loadedModel $loadedModel -instructions $instructions -query $query -attachments $attachments -temperature $temperature -max_token $max_token
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
    -------------------------- Example 1 --------------------------

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
            Position = 3,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $temperature = 0.25
    )

    # Invoke the LM-Studio query with the specified model, query, instructions, and attachments
    Invoke-LMStudioQuery -model "MiniCPM" -query $query -instructions "You are an AI assistant that analyzes images." -attachments @($ImagePath) -temperature $temperature -max_token 3253
    # Invoke-LMStudioQuery -model "xtuner/llava-llama-3-8b-v1_1-gguf/llava-llama-3-8b-v1_1-f16.gguf" -query $query -instructions "You are an AI assistant that analyzes images." -attachments @($ImagePath) -temperature $temperature
}

################################################################################
<#
.SYNOPSIS
Queries the LM-Studio API to get keywords from an image.

.DESCRIPTION
The `Invoke-QueryImageKeywords` function sends an image to the LM-Studio API and returns keywords found in the image.

.PARAMETER ImagePath
The file path of the image to send with the query.

.EXAMPLE
    -------------------------- Example 1 --------------------------

    Invoke-QueryImageKeywords -ImagePath "C:\path\to\image.jpg"
#>
function Invoke-QueryImageKeywords {

    [CmdletBinding()]
    param (
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The file path of the image to send with the query."
        )]
        [string]$ImagePath
    )

    # Invoke the query to get keywords from the image
    Invoke-LMStudioQuery -model "MiniCPM" -instructions "You are an AI assistant that analyzes images that returns nothing other then text in the form of a array of strings in json format that holds short names for each object you see in the picture. Only return json strings in a single array, no json objects. return only no other text, explanations or notes" -query "analyze this image" -attachments @($ImagePath) -temperature 0.01
    # Invoke-LMStudioQuery -model "xtuner/llava-llama-3-8b-v1_1-gguf/llava-llama-3-8b-v1_1-f16.gguf" -instructions "You are an AI assistant that analyzes images that returns nothing other then text in the form of a array of strings in json format that holds short names for each object you see in the picture. Only return json strings in a single array, no json objects. return only no other text, explanations or notes" -query "analyze this image" -attachments @($ImagePath) -temperature 0.01
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
    -------------------------- Example 1 --------------------------

    Invoke-ImageKeywordUpdate -imageDirectory "C:\path\to\images"
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

    Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse:$recurse -File | ForEach-Object {

        if ($retryFailed) {

            if (Test-Path "$($PSItem):description.json") {

                if ("$(Get-Content "$($PSItem):description.json")".StartsWith("{}")) {

                    Remove-Item "$($PSItem):description.json" -Force
                }
            }

            if (Test-Path "$($PSItem):keywords.json") {

                if ("$(Get-Content "$($PSItem):keywords.json")".StartsWith("{}")) {

                    Remove-Item "$($PSItem):keywords.json" -Force
                }
            }
        }

        $image = $_.FullName

        if ($_.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

            $_.Attributes = $_.Attributes -bxor [System.IO.FileAttributes]::ReadOnly
        }

        if ((-not $onlyNew) -or (-not [IO.File]::Exists("$($image):description.json"))) {

            if (-not [IO.File]::Exists("$($image):description.json")) {

                "{}" > "$($image):description.json"
            }

            Write-Verbose "Getting image description for $image.."
            $description = Invoke-QueryImageContent -query "Analyze image and return it as a single json object with properties: short_description (max 80 chars), long_description, has_nudity, has_explicit_content, overall_mood_of_image, picture_type, style_type. The filepath of the image is: '$image'" -ImagePath $image -temperature 0.01
            Write-Verbose $description

            try {
                $description = $description.trim();
                $i0 = $description.IndexOf("{ ")
                $i1 = $description.LastIndexOf("}")
                if ($i0 -ge 0) {

                    $description = $description.Substring($i0, $i1 - $i0 + 1)
                }
                $description | ConvertFrom-Json | ConvertTo-Json -Compress -Depth 20 | Out-File -FilePath "$($image):description.json" -Force
            }
            catch {
                Write-Warning $_
            }
        }

        if ($onlyNew -and [IO.File]::Exists("$($image):keywords.json")) {

            return
        }

        if (-not [IO.File]::Exists("$($image):keywords.json")) {

            "[]" > "$($image):keywords.json"
        }

        $keywords = Invoke-QueryImageKeywords -ImagePath $image

        if ($null -ne $keywords) {

            $keywords = $keywords | ConvertTo-Json -Compress -Depth 20;
            Write-Verbose "$image : $keywords`r`n`r`n"

            $keywords | Out-File -FilePath "$($image):keywords.json" -Force
        }
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
    -------------------------- Example 1 --------------------------

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

    $results = Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse -File | ForEach-Object {

        $image = $_.FullName
        $keywordsFound = @()
        $descriptionFound = $null;

        if ([IO.File]::Exists("$($image):description.json")) {

            try {
                $descriptionFound = Get-Content "$($image):description.json" | ConvertFrom-Json
            }
            catch {
                $descriptionFound = $null;
            }
        }

        if ([IO.File]::Exists("$($image):keywords.json")) {

            try {
                $keywordsFound = Get-Content "$($image):keywords.json" | ConvertFrom-Json
            }
            catch {
                $keywordsFound = @()
            }
        }

        if ((($null -eq $keywords -or ($keywords.Length -eq 0)) -and (($null -eq $keywordsFound -or ($keywordsFound.length -eq 0)) -and ($null -eq $descriptionFound)))) {

            return;
        }

        $found = ($null -eq $keywords -or ($keywords.Length -eq 0));

        if (-not $found) {

            $descriptionFoundJson = $null -ne $descriptionFound ? $descriptionFound : "" | ConvertTo-Json -Compress -Depth 10

            foreach ($requiredKeyword in $keywords) {

                $found = "$descriptionFoundJson" -like $requiredKeyword;

                if (-not $found) {

                    if ($null -eq $keywordsFound -or ($keywordsFound.Length -eq 0)) { continue; }

                    foreach ($imageKeyword in $keywordsFound) {

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
    -------------------------- Example 1 --------------------------

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
Adds image descriptions to file names in a specified directory.

.DESCRIPTION
This function iterates through all image files in a given directory and appends a description to each file name. The description is extracted from the image metadata.

.PARAMETER DirectoryPath
The path to the directory containing the image files.

.PARAMETER DescriptionKey
The metadata key used to extract the description from the image files.

.EXAMPLE
Add-ImageDescriptionsToFileNames -DirectoryPath "C:\Images" -DescriptionKey "Title"
This example adds the title metadata as a description to each image file name in the "C:\Images" directory.
#>
function Add-ImageDescriptionsToFileNames {

    [CmdletBinding()]

    $Path = Expand-Path $imageDirectory

    if (-not [IO.Directory]::Exists($Path)) {

        Write-Host "The directory '$Path' does not exist."
        return
    }

    Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse:$recurse -File | ForEach-Object {

        $image = $_.FullName
        $directory = [io.path]::GetDirectoryName($image);
        $extension = [io.path]::GetExtension($image);
        $onlyFilename = [io.path]::GetFileNameWithoutExtension($image)

        if ($onlyFilename -match ".*_\[.*\]\..*") {

            return
        }

        if ([IO.File]::Exists("$($image):description.json")) {

            try {
                $descriptionFound = Get-Content "$($image):description.json" | ConvertFrom-Json
            }
            catch {

                return;
            }

            if (-not [String]::IsNullOrWhiteSpace($descriptionFound.short_description)) {

                $newFileName = [GenXdev.Helpers.Security]::SanitizeFileName($descriptionFound.short_description).Replace(" ", "_").Replace("__", "_")
                $newFilePath = "$directory\$onlyFilename_[$newFileName]$extension"

                try {

                    Write-Verbose "$onlyFileName$extension => $onlyFilename_[$newFileName]$extension"
                    Rename-Item $image $newFilePath -Force

                }
                catch {

                    Write-Warning $_
                }
            }
        }
    }
}

################################################################################
################################################################################
