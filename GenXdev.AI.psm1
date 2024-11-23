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

.EXAMPLE
    -------------------------- Example 4 --------------------------
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

            $foundModelLoaded = (Get-LoadedModelList) | Where-Object {
                $_.path -eq $foundModel.path
            } | Select-Object -First 1

            if ($null -eq $foundModelLoaded) {

                $success = $true;
                try {

                    Write-Verbose "Loading model.."
                    & "$lmsPath" load "$($foundModel.path)" --yes --gpu off --exact

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
            Position = 2,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $temperature = 0.25
    )

    # Invoke the LM-Studio query with the specified model, query, instructions, and attachments
    Invoke-LMStudioQuery -model "MiniCPM" -query $query -instructions "You are an AI assistant that analyzes images." -attachments @($ImagePath) -temperature $temperature -max_token 3253
    # Invoke-LMStudioQuery -model "xtuner/llava-llama-3-8b-v1_1-gguf/llava-llama-3-8b-v1_1-f16.gguf" -query $query -instructions "You are an AI assistant that analyzes images." -attachments @($ImagePath) -temperature $temperature
}

# ################################################################################
# <#
# .SYNOPSIS
# Queries the LM-Studio API to get keywords from an image.

# .DESCRIPTION
# The `Invoke-QueryImageKeywords` function sends an image to the LM-Studio API and returns keywords found in the image.

# .PARAMETER ImagePath
# The file path of the image to send with the query.

# .EXAMPLE
#     -------------------------- Example 1 --------------------------

#     Invoke-QueryImageKeywords -ImagePath "C:\path\to\image.jpg"
# #>
# function Invoke-QueryImageKeywords {

#     [CmdletBinding()]
#     param (
#         [Parameter(
#             Mandatory = $true,
#             Position = 0,
#             HelpMessage = "The file path of the image to send with the query."
#         )]
#         [string]$ImagePath
#     )

#     # Invoke the query to get keywords from the image
#     Invoke-LMStudioQuery -model "MiniCPM" -instructions "You are an AI assistant that analyzes images that returns nothing other then text in the form of a array of strings in json format that holds short names for each object you see in the picture. Only return json strings in a single array, no json objects. return only no other text, explanations or notes" -query "analyze this image" -attachments @($ImagePath) -temperature 0.01
#     # Invoke-LMStudioQuery -model "xtuner/llava-llama-3-8b-v1_1-gguf/llava-llama-3-8b-v1_1-f16.gguf" -instructions "You are an AI assistant that analyzes images that returns nothing other then text in the form of a array of strings in json format that holds short names for each object you see in the picture. Only return json strings in a single array, no json objects. return only no other text, explanations or notes" -query "analyze this image" -attachments @($ImagePath) -temperature 0.01
# }

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

    Get-ChildItem -Path "$Path\*.jpg", "$Path\*.jpeg", "$Path\*.png" -Recurse:$recurse -File | ForEach-Object {

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
Transcribes audio to text using the default audio input device.

.DESCRIPTION
Records audio using the default audio input device and returns the detected text

.PARAMETER Language
The language to expect in the audio.
#>
function Start-AudioTranscription {

    [CmdletBinding()]

    param (
        [Parameter(Mandatory = $false, Position = 0, HelpMessage = "The language to expect")]
        [PSDefaultValue(Value = "auto")]
        [string] $Language = "auto"
    )

    process {
        $ModelFilePath = Expand-Path "$PSScriptRoot\..\..\GenXdev.Local\" -CreateDirectory

        Get-SpeechToText -ModelFilePath $ModelFilePath -Language $Language
    }
}

################################################################################
<#
.SYNOPSIS
Starts a rudimentary audio chat session.

.DESCRIPTION
Starts an audio chat session by recording audio and invoking the default LLM

.PARAMETER Language
The language to expect in the audio.
#>
function Start-AudioChat {

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false, Position = 0, HelpMessage = "The language to expect")]
        [PSDefaultValue(Value = "auto")]
        [string] $Language = "auto",

        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The system instructions for the LLM.")]
        [PSDefaultValue(Value = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.")]
        [string]$instructions = "Your an AI assistent that never tells a lie and always answers truthfully, first of all comprehensive and then if possible consice.",

        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$model = "yi-coder-9b-chat",

        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $temperature = 0.7
    )
    process {

        [string] $session = "";

        while ($true) {
            $text = (Start-AudioTranscription -Language:$Language)
            $question = $text
            $session += "Current content to respond to: `r`n$text`r`n`r`n"
            Write-Host "--"
            $a = [System.Console]::ForegroundColor
            [System.Console]::ForegroundColor = [System.ConsoleColor]::Yellow
            Write-Host ">> $text"
            [System.Console]::ForegroundColor = $a;
            Write-Host "--"
            $answer = (qlms -query $session -instructions:$instructions -model:$model -temperature:$temperature)
            $session = "Previous content responded to: `r`n$question`r`n`r`nPrevious response: `r`n$answer`r`n`r`n"
            Write-Host "--"

            [System.Console]::ForegroundColor = [System.ConsoleColor]::Green
            Write-Host "<< $answer"
            [System.Console]::ForegroundColor = $a;
            Write-Host "--"
            say $answer
            Write-Host "Press any key to start recording or Q to quit"
            if ([Console]::ReadKey().Key -eq "Q") { sst; break }
            sst;
            Write-Host "---------------"
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

.PARAMETER model
The LM-Studio model to use for generating the response.

.EXAMPLE
    -------------------------- Example 1 --------------------------

    Get-TextTranslation -Text "Hello, how are you?" -Language "french"

#>
function Get-TextTranslation {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The text to translate")]
        [string] $Text,

        [Parameter(Mandatory = $false, Position = 1, HelpMessage = "The language to translate to.")]
        [PSDefaultValue(Value = "english")]
        [string] $Language = "english",

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The system instructions for the LLM."
        )]
        [PSDefaultValue(Value = "Translate this partial subtitle text, into the `[Language] language, leave in the same style of writing, and leave the paragraph structure in tact, ommit only the translation no yapping or chatting.")]
        $Instructions = "Translate this partial subtitle text, into the [Language] language, leave in the same style of writing, and leave the paragraph structure in tact, ommit only the translation no yapping or chatting.",

        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$model = "yi-coder-9b-chat"
    )

    process {

        $Instructions = $Instructions.Replace("[Language]", $Language);

        # initialize translation container
        [System.Text.StringBuilder] $translation = New-Object System.Text.StringBuilder;

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

                $translation.Append("$nextPart");
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
                $translatedPart = qlms -query $nextPart -instructions $Instructions -model $model -temperature 0.02

                # append the translated part
                $translation.Append("$spaceLeft$translatedPart$spaceRight");

                Write-Verbose "Text translated to: `"$translatedPart`".."
            }
            catch {

                # append the original part
                $translation.Append("$spaceLeft$nextPart$spaceRight");

                Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
            }

            $i = [Math]::Min(100, $Text.Length)
        }

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

.PARAMETER model
The LM-Studio model to use for translations

.PARAMETER SRT
Output in SRT format.

.PARAMETER MaxSrtChars
The maximum number of characters per line in the SRT output.

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
            ParameterSetName = "Translate",
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The language to translate the text to using LM Studio."
        )]
        [string] $LanguageOut = $null,

        [Parameter(
            ParameterSetName = "Translate",
            Position = 3,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for translations")]
        [PSDefaultValue(Value = "yi-coder-9b-chat")]
        [string]$model = "yi-coder-9b-chat",

        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "Output in SRT format."
        )]
        [switch] $SRT,

        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = "The maximum number of characters per line in the SRT output."
        )]
        [int] $MaxSrtChars = 25
    )

    process {

        $MaxSrtChars = [System.Math]::Min(200, [System.Math]::Max(20, $MaxSrtChars))

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

        $ffmpegPath = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\ffmpeg.exe" -File -rec | Select-Object -First 1 | ForEach-Object FullName)

        function Installffmpeg {

            if ($null -ne $ffmpegPath) { return }

            if (-not (IsWinGetInstalled)) {

                InstallWinGet
            }

            $ffmpeg = "Gyan.FFmpeg"
            $ffmpegPackage = Get-WinGetPackage -Id $ffmpeg

            if ($null -eq $ffmpegPackage) {

                Write-Verbose "Installing ffmpeg.."
                Install-WinGetPackage -Name $lmStudio -Force
                $ffmpegPath = (Get-ChildItem "$env:LOCALAPPDATA\Microsoft\WinGet\ffmpeg.exe" -File -rec | Select-Object -First 1).FullName
            }
        }

        # Make sure ffmpeg is installed
        Installffmpeg;

        # Re-use downloaded models
        $ModelFilePath = Expand-Path "$PSScriptRoot\..\..\GenXdev.Local\" -CreateDirectory

        # Replace these paths with your actual file paths
        $inputFile = Expand-Path $FilePath
        $outputFile = [IO.Path]::GetTempFileName() + ".wav";

        # Construct and execute the ffmpeg command
        $job = Start-Job -ArgumentList $ffmpegPath, $inputFile, $outputFile -ScriptBlock {

            param($ffmpegPath, $inputFile, $outputFile)

            # Convert the file to WAV format
            & $ffmpegPath -i "$inputFile" -ac 1 -ar 16000 -sample_fmt s16 "$outputFile" -loglevel quiet -y | Out-Null

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

                Remove-Item -Path $outputFile -Force
            }

            return
        }

        try {

            # outputting in SRT format?
            if ($SRT) {

                # initialize srt counter
                $i = 1

                # iterate over the results
                Get-SpeechToText -ModelFilePath:$ModelFilePath -Language:$LanguageIn -WaveFile:$outputFile -Passthru:($SRT -eq $true) | ForEach-Object {

                    $result = $PSItem;

                    # needs translation?
                    if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                        Write-Verbose "Translating text to $LanguageOut for: `"$($result.Text)`".."

                        try {
                            # translate the text
                            $result = @{
                                Text  = Get-TextTranslation -Text:($result.Text) -Language:$LanguageOut -model:$model -Instructions "Translate this partial subtitle text, into the [Language] language. ommit only the translation no yapping or chatting.";
                                Start = $result.Start;
                                End   = $result.End;
                            }

                            Write-Verbose "Text translated to: `"$($result.Text)`".."
                        }
                        catch {

                            Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
                        }
                    }

                    $Lines = @("$($result.Text.Replace("`r", "`n").Replace("`n`n", "`n").Replace("`n`n", "`n"))".Split("`n", [System.StringSplitOptions]::RemoveEmptyEntries));
                    $Lengths = @($Lines | ForEach-Object { $_.Length })
                    $TotalLength = [string]::Join(". ", $Lines).Length;
                    $TotalDuration = $result.End - $result.Start;
                    $Durations = @($Lengths | ForEach-Object { [TimeSpan]::FromSeconds((($PSItem / $TotalLength) * $TotalDuration.Seconds)) });

                    for ($iLine = 0; $iLine -lt $lines.Length; $iLine++) {

                        $Line = $Lines[$iLine];
                        $max = [Math]::Min($MaxSrtChars, $Line.Length);

                        $startTimespan = $result.Start

                        while ($max -gt 0) {

                            # move the cursor to the next word
                            while (($max -gt 0) -and (" `t`r`n".indexOf($Line[$max]) -lt 0)) { $max--; }
                            while (($max -lt $Line.Length) -and (" `t`r`n".indexOf($Line[$max]) -lt 0)) { $max++; }
                            if ($max -lt $MaxSrtChars) { $max = $Line.Length; }

                            # get the next part of the text
                            $nextPart = $Line.Substring(0, $max).Trim("`r`t`n ".ToCharArray());
                            $Line = $Line.Substring($max).Trim("`r`t`n ".ToCharArray());

                            $Duration = [Timespan]::FromSeconds($Durations[$iLine].TotalSeconds * ($nextPart.Length / $Lengths[$iLine]));
                            $FullDuration = $Duration

                            if ($Duration.Seconds -gt 8) {

                                $Duration = [TimeSpan]::FromSeconds(8)
                            }

                            $startTimespan = $result.Start
                            $endTimespan = $startTimespan + $Duration;

                            $result = @{
                                Text  = $nextPart;
                                Start = $result.Start + $FullDuration;
                                End   = $result.End;
                            }

                            $start = $startTimespan.ToString("hh\:mm\:ss\,fff", [CultureInfo]::InvariantCulture);
                            $end = $endTimespan.ToString("hh\:mm\:ss\,fff", [CultureInfo]::InvariantCulture);

                            "$i`r`n$start --> $end`r`n$nextPart`r`n`r`n"

                            # increment the counter
                            $i++

                            # find next part
                            $max = [Math]::Min($MaxSrtChars, $line.Length);
                        }
                    }
                }

                # end of SRT format
                return;
            }

            # transcribe the audio file to text
            $results = Get-SpeechToText -ModelFilePath:$ModelFilePath -Language:$LanguageIn -WaveFile:$outputFile -Passthru:($SRT -eq $true)

            #  needs translation?
            if (-not [string]::IsNullOrWhiteSpace($LanguageOut)) {

                # delegate
                Get-TextTranslation -Text "$results" -Language $LanguageOut -model $model

                # end of translation
                return;
            }

            # return the text results without translation
            $results
        }
        finally {

            # Clean up the temporary file
            if ([IO.File]::Exists($outputFile)) {

                Remove-Item -Path $outputFile -Force
            }
        }
    }
}
