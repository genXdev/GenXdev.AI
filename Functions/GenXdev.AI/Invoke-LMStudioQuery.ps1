################################################################################
<#
.SYNOPSIS
Queries the LM-Studio API with given parameters and returns the response.

.DESCRIPTION
Sends a query to the LM-Studio API and returns the response. Can handle text and
image inputs, manages model loading, and supports various query parameters.

.PARAMETER Query
The query string to send to the LLM.

.PARAMETER Attachments
File paths of attachments to send with the query.

.PARAMETER Instructions
System instructions for the LLM.

.PARAMETER Model
The LM-Studio model to use.

.PARAMETER Temperature
Controls response randomness (0.0-1.0).

.PARAMETER Max_token
Maximum tokens to generate in response.

.PARAMETER ImageDetail
Detail level for image attachments (low/medium/high).

.PARAMETER ShowLMStudioWindow
Shows the LM-Studio window when set.

.PARAMETER IncludeThoughts
Include <think></think> patterns in output.

.EXAMPLE
Invoke-LMStudioQuery -Query "What is PowerShell?" -Temperature 0.7

.EXAMPLE
qlms "Analyze this code" -Attachments ".\script.ps1" -Instructions "Be thorough"
#>
function Invoke-LMStudioQuery {

    [CmdletBinding()]
    [Alias("qlms")]
    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = "Query string for the LLM"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,

        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "File paths of attachments"
        )]
        [string[]] $Attachments = @(),

        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = "System instructions for LLM"
        )]
        [string] $Instructions = "Your an AI assistent that never tells a lie " +
            "and always answers truthfully, first comprehensive then consice.",

        ################################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "llama")]
        [string]$Model = "llama",

        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.01,

        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 5,
            HelpMessage = "The maximum number of tokens to generate in the response."
        )]
        [int] $Max_token = -1,

        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 6,
            HelpMessage = "The image detail to use for the attachments."
        )]
        [ValidateSet("low", "medium", "high")]
        [string] $ImageDetail = "low",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the LM-Studio window."
        )]
        [Switch] $ShowLMStudioWindow,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Includes <think></think> patterns in output."
        )]
        [Switch] $IncludeThoughts
    )

    begin {
        # get full path expansions for lm studio executables
        $lmStudioPath = Get-ChildItem `
            "${env:LOCALAPPDATA}\LM-Studio\lm studio.exe", `
            "${env:LOCALAPPDATA}\Programs\LM-Studio\lm studio.exe" `
            -File -rec -ErrorAction SilentlyContinue |
            Select-Object -First 1 |
            ForEach-Object FullName

        $lmsPath = Get-ChildItem `
            "${env:LOCALAPPDATA}\LM-Studio\lms.exe", `
            "${env:LOCALAPPDATA}\Programs\LM-Studio\lms.exe" `
            -File -rec -ErrorAction SilentlyContinue |
            Select-Object -First 1 |
            ForEach-Object FullName
    }

    process {
        function IsLMStudioInstalled {
            return Test-Path -Path $lmsPath -ErrorAction SilentlyContinue
        }

        # Function to check if LMStudio is running
        function IsLMStudioRunning {
            $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue | Where-Object -Property MainWindowHandle -NE 0
            if ($null -ne $process) {
                $process.PriorityClass = "Idle"
                $w = [GenXdev.Helpers.WindowObj]::new($process.MainWindowHandle, "LM Studio");
                if ($null -ne $w) {
                    if ($ShowLMStudioWindow) {
                        $w.Maximize();
                        $w.Show();
                        (Get-PowershellMainWindow).Focus();
                        wp -Left -Process (Get-PowershellMainWindowProcess)
                        wp -Right -Process $process
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
            $lmStudioPackage = Get-WinGetPackage -Id $lmStudio
            if ($null -eq $lmStudioPackage) {
                Write-Verbose "Installing LM-Studio.."
                try {
                    Install-WinGetPackage -Id $lmStudio -Force
                }
                catch {
                    winget install $lmStudio
                }
                # get full path expansions for lm studio executables
                $lmStudioPath = Get-ChildItem `
                    "${env:LOCALAPPDATA}\LM-Studio\lm studio.exe", `
                    "${env:LOCALAPPDATA}\Programs\LM-Studio\lm studio.exe" `
                    -File -rec -ErrorAction SilentlyContinue |
                Select-Object -First 1 |
                ForEach-Object FullName

                $lmsPath = Get-ChildItem `
                    "${env:LOCALAPPDATA}\LM-Studio\lms.exe", `
                    "${env:LOCALAPPDATA}\Programs\LM-Studio\lms.exe" `
                    -File -rec -ErrorAction SilentlyContinue |
                Select-Object -First 1 |
                ForEach-Object FullName
            }
        }

        # Function to start LMStudio if it's not running
        function Start-LMStudio {
            if (-not (IsLMStudioInstalled)) {
                InstallLMStudio
            }
            if (-not (IsLMStudioRunning)) {
                Write-Verbose "Starting LM-Studio..";
                # get full path expansions for lm studio executables
                $lmStudioPath = Get-ChildItem `
                    "${env:LOCALAPPDATA}\LM-Studio\lm studio.exe", `
                    "${env:LOCALAPPDATA}\Programs\LM-Studio\lm studio.exe" `
                    -File -rec -ErrorAction SilentlyContinue |
                Select-Object -First 1 |
                ForEach-Object FullName

                $lmsPath = Get-ChildItem `
                    "${env:LOCALAPPDATA}\LM-Studio\lms.exe", `
                    "${env:LOCALAPPDATA}\Programs\LM-Studio\lms.exe" `
                    -File -rec -ErrorAction SilentlyContinue |
                Select-Object -First 1 |
                ForEach-Object FullName

                Start-Job { param($lmStudioPath) Start-Process -FilePath $lmStudioPath -WindowStyle Minimized } -ArgumentList @($lmStudioPath) | Out-Null
                Start-Sleep -Seconds 10
                IsLMStudioRunning | Out-Null
            }
        }

        # Function to get the list of models
        function Get-ModelList {
            Write-Verbose "Getting installed model list.."
            $ModelList = & "$lmsPath" ls --json | ConvertFrom-Json
            return $ModelList
        }
        function Get-LoadedModelList {
            Write-Verbose "Getting loaded model list.."
            $ModelList = & "$lmsPath" ps --json | ConvertFrom-Json
            return $ModelList
        }

        # Function to load the LLava model
        function LoadLMStudioModel {
            $ModelList = Get-ModelList
            $foundModel = $ModelList | Where-Object { $PSItem.path -like "*$Model*" } | Select-Object -First 1
            if (-not $foundModel) {
                $preferredModelList = @("llama", "vicuna", "alpaca", "gpt", "falcon", "mpt", "koala", "wizard", "guanaco", "bloom", "rwkv", "camel", "pythia", "baichuan")
                foreach ($preferredModel in $preferredModelList) {
                    $foundModel = $ModelList | Where-Object { $PSItem.path -like "*$preferredModel*" } | Select-Object -First 1
                    if ($foundModel) {
                        break
                    }
                }
            }
            if (-not $foundModel) {
                $foundModel = $ModelList | Select-Object -First 1
            }
            if (-not $foundModel) {
                $ShowLMStudioWindow = $true
                IsLMStudioRunning | Out-Null
                throw "Model with path: '*$Model*', not found. Please install and configure startup-parameters manually in LM-Studio first."
            }
            Write-Output $foundModel
            $foundModelLoaded = (Get-LoadedModelList) | Where-Object {
                $PSItem.path -eq $foundModel.path
            } | Select-Object -First 1
            if ($null -eq $foundModelLoaded) {
                $success = $true;
                try {
                    Write-Verbose "Loading model.."
                    [System.Console]::Write("`r`n");
                    if (-not (Get-HasCapableGpu)) {
                        & "$lmsPath" load "$($foundModel.path)" --gpu off --exact
                    }
                    else {
                        & "$lmsPath" load "$($foundModel.path)" --exact
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
                    & "$lmsPath" unload --all
                    $success = $true;
                    try {
                        Write-Verbose "Loading model.."
                        [System.Console]::Write("`r`n");
                        if (-not (Get-HasCapableGpu)) {
                            & "$lmsPath" load "$($foundModel.path)" --gpu off --exact
                        }
                        else {
                            & "$lmsPath" load "$($foundModel.path)" --exact
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
                }
                if (-not $success) {
                    $ShowLMStudioWindow = $true
                    IsLMStudioRunning | Out-Null
                    throw "Model with path: '*$Model*', not found. Please install and configure startup-parameters manually in LM-Studio first."
                }
            }
            $foundModelLoaded = (Get-LoadedModelList) | Where-Object {
                $PSItem.path -eq $foundModel.path
            } | Select-Object -First 1
            if ($null -eq $foundModelLoaded) {
                $ShowLMStudioWindow = $true
                IsLMStudioRunning | Out-Null
                throw "Model with path: '*$Model*', not found. Please install and configure startup-parameters manually in LM-Studio first."
            }
            $foundModelLoaded
        }

        # Function to upload image and query to LM-Studio local server
        function QueryLMStudio {
            param (
                $foundModelLoaded,
                [string]$Instructions,
                [string]$Query,
                [string[]]$Attachments,
                [double]$Temperature,
                [int]$Max_token = -1
            )
            $messages = [System.Collections.ArrayList]@()
            $messages.Add(
                @{
                    role    = "system"
                    content = "$Instructions"
                }
            ) | Out-Null;
            $Attachments | ForEach-Object {
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
                function getImageBase64Data($filePath, $ImageDetail) {
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
                    switch ($ImageDetail) {
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
                            content = $Query
                            file    = @{
                                name         = [IO.Path]::GetFileName($filePath)
                                content_type = $mimeType
                                bytes        = "data:$mimeType;base64,$base64Image"
                            }
                        }
                    ) | Out-Null;
                }
                else {
                    $base64Image = getImageBase64Data $filePath $ImageDetail
                    $messages.Add(
                        @{
                            role    = "user"
                            content = @(
                                @{
                                    type      = "image_url"
                                    image_url = @{
                                        url    = "data:$mimeType;base64,$base64Image"
                                        detail = "$ImageDetail"
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
                            text = $Query
                        }
                    )
                }
            ) | Out-Null;
            $json = @{
                "stream"      = $false
                "model"       = "$($foundModelLoaded.identifier)".trim()
                "messages"    = $messages
                "temperature" = $Temperature
                "max_tokens"  = $Max_token
            } | ConvertTo-Json -Depth 60 -Compress;
            $apiUrl = "http://localhost:1234/v1/chat/completions"
            $bytes = [System.Text.Encoding]::UTF8.GetBytes($json);
            $headers = @{
                "Content-Type" = "application/json"
            }
            Write-Verbose "Quering LM-Studio model '$Model'.."
            # ansi for cursor up and clear line
            [System.Console]::WriteLine("Quering LM-Studio model '$Model'..");
            $response = Invoke-RestMethod -Uri $apiUrl -Method Post -Body $bytes -Headers $headers -OperationTimeoutSeconds (3600 * 24) -ConnectionTimeoutSeconds (3600 * 24)
            [System.Console]::Write("`e[1A`e[2K");
            $response.choices.message | ForEach-Object content | ForEach-Object {

                if (-not $IncludeThoughts) {

                    $i = $PSItem.IndexOf("<think>")
                    if ($i -ge 0) {

                        $i2 = $PSItem.IndexOf("</think>")
                        if ($i2 -ge 0) {

                            $thoughts = $PSItem.Substring($i + 7, $i2 - $i - 7)
                            $message = $PSItem.Substring(0, $i) + $PSItem.Substring($i2 + 8)

                            Write-Information $thoughts
                            $message
                            return;
                        }
                    }
                }

                $PSItem
            }
        }

        # Main script execution
        Start-LMStudio
        $foundModelLoaded = LoadLMStudioModel
        if ($null -eq $foundModelLoaded) { return }
        QueryLMStudio -foundModelLoaded $foundModelLoaded -instructions $Instructions -query $Query -attachments $Attachments -temperature $Temperature -max_token $Max_token
    }

    end {
        # clean up resources or finalize logic if needed
    }
}
