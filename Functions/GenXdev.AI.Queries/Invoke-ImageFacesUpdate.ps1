################################################################################
<#
.SYNOPSIS
Updates face recognition metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to identify and analyze
faces using AI recognition technology. It creates or updates metadata files
containing face information for each image. The metadata is stored in a
separate file with the same name as the image but with a ':faces.json' suffix.

.PARAMETER ImageDirectory
The directory path containing images to process. Can be relative or absolute.
Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all subdirectories.

.PARAMETER OnlyNew
If specified, only processes images that don't already have face metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images (empty metadata files).

.EXAMPLE
Invoke-ImageFacesUpdate -ImageDirectory "C:\Photos" -Recurse

.EXAMPLE
Invoke-ImageFacesUpdate "C:\Photos" -RetryFailed -OnlyNew
#>
function Invoke-ImageFacesUpdate {

    [CmdletBinding()]
    [Alias("facerecognition")]

    param(
        ###############################################################################
        <#
        .SYNOPSIS
        Specifies the directory containing images to process.

        .DESCRIPTION
        The directory path containing images to process. Can be relative or absolute.
        Default is the current directory.

        .PARAMETER ImageDirectory
        The directory path containing images to process. Can be relative or absolute.
        Default is the current directory.

        .EXAMPLE
        Invoke-ImageFacesUpdate -ImageDirectory "C:\Photos"
        #>
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The image directory path."
        )]
        [string] $ImageDirectory = ".\",

        ###############################################################################
        <#
        .SYNOPSIS
        If specified, processes images in the specified directory and all subdirectories.

        .DESCRIPTION
        When this switch is provided, the function will search for images not only in
        the specified directory but also in all of its subdirectories.

        .PARAMETER Recurse
        If specified, processes images in the specified directory and all subdirectories.

        .EXAMPLE
        Invoke-ImageFacesUpdate -Recurse
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Recurse directories."
        )]
        [switch] $Recurse,

        ###############################################################################
        <#
        .SYNOPSIS
        If specified, only processes images that don't already have face metadata files.

        .DESCRIPTION
        When this switch is provided, the function will skip processing images that
        already have a corresponding face metadata file.

        .PARAMETER OnlyNew
        If specified, only processes images that don't already have face metadata files.

        .EXAMPLE
        Invoke-ImageFacesUpdate -OnlyNew
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip if already has meta data."
        )]
        [switch] $OnlyNew,

        ###############################################################################
        <#
        .SYNOPSIS
        If specified, retries processing previously failed images (empty metadata files).

        .DESCRIPTION
        When this switch is provided, the function will reprocess images that have
        empty metadata files (indicating a previous processing failure).

        .PARAMETER RetryFailed
        If specified, retries processing previously failed images (empty metadata files).

        .EXAMPLE
        Invoke-ImageFacesUpdate -RetryFailed
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will retry previously failed images."
        )]
        [switch] $RetryFailed,
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip Docker initialization (used when already called by parent function)"
        )]
        [switch] $NoDockerInitialize
    )

    begin {

        # convert the possibly relative path to an absolute path for reliable access
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectory

        # ensure the target directory exists before proceeding with any operations
        if (-not [System.IO.Directory]::Exists($path)) {

            Microsoft.PowerShell.Utility\Write-Host "The directory '$path' does not exist."
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Processing images in directory: $path"
    }

    process {

        # retrieve all supported image files (jpg, jpeg, png) from the specified directory
        # applying recursion only if the -Recurse switch was provided
        Microsoft.PowerShell.Management\Get-ChildItem -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
            -Recurse:$Recurse -File -ErrorAction SilentlyContinue |        Microsoft.PowerShell.Core\ForEach-Object {
            # store the full path to the current image for better readability
            $image = $PSItem.FullName

            # if retry mode is active, handle previously failed images
            if ($RetryFailed) {

                if ([System.IO.File]::Exists("$($image):people.json")) {

                    # if metadata file exists but is empty or has no faces, delete it to force reprocessing
                    $content = [System.IO.File]::ReadAllText("$($image):people.json")
                    if ($content.StartsWith("{}") -or $content -eq '{"predictions":null,"count":1,"faces":[""]}') {

                        $content = "{}"
                    }
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Processing image: $image"

            # remove read-only attribute if present to ensure file can be modified
            if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

                $PSItem.Attributes = $PSItem.Attributes -bxor
                [System.IO.FileAttributes]::ReadOnly
            }
            # check if a metadata file already exists for this image
            $metadataFilePath = "$($image):people.json"
            $fileExists = [System.IO.File]::Exists($metadataFilePath)

            # process image if either we're updating all images or this is a new image without metadata
            $content = $fileExists ? [System.IO.File]::ReadAllText($metadataFilePath) : "{}"
            if (
                (-not $OnlyNew) -or
                (-not $fileExists) -or
                ($content -eq "{}") -or
                (-not $content.Contains("predictions"))) {

                # create an empty metadata file as a placeholder if one doesn't exist
                if (-not $fileExists) {

                    $null = [System.IO.File]::WriteAllText($metadataFilePath, "{}")
                    Microsoft.PowerShell.Utility\Write-Verbose "Created new metadata file for: $image"
                }                # obtain face recognition data using AI recognition technology
                # store the complete data including positions, confidence, and face names
                $faceData = GenXdev.AI\Get-ImageDetectedFaces -ImagePath $image -NoDockerInitialize:$NoDockerInitialize -ConfidenceThreshold 0.6

                # Process the face data to extract unique person names and store full prediction data
                $processedData = @{
                    count = $faceData.count
                    faces = @($faceData.faces | Microsoft.PowerShell.Core\ForEach-Object {
                        # Remove everything after and including the last underscore to get base person name
                        $name = "$_"
                        $lastUnderscoreIndex = $name.LastIndexOf("_")
                        if ($lastUnderscoreIndex -gt 0) {

                            # Changed from -ge to -gt to avoid empty strings
                            $name.Substring(0, $lastUnderscoreIndex)
                        } else {
                            $name
                        }
                    } | Microsoft.PowerShell.Utility\Sort-Object | Microsoft.PowerShell.Utility\Select-Object -Unique)
                    predictions = $faceData.predictions
                    # Store complete prediction data with positions and confidence
                }

                # Update count to reflect unique faces
                $processedData.count = $processedData.faces.Count

                # If no faces are detected, use empty structure
                if ($processedData.count -eq 0) {
                    $processedData = @{count = 0; faces = @(); predictions = @()}
                }

                $faces = $processedData | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20 -WarningAction SilentlyContinue

                Microsoft.PowerShell.Utility\Write-Verbose "Received face analysis for: $image"

                try {
                    $newContent =  ($faces |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20 `
                            -WarningAction SilentlyContinue)

                    if ($newContent -eq '{"predictions":null,"count":1,"faces":[""]}') {

                        $newContent = '{}'
                    }

                    # save the processed face data to a metadata file
                    # re-parse and re-serialize to ensure consistent JSON format
                    [System.IO.File]::WriteAllText(
                        $metadataFilePath,
                        $newContent
                    );

                    Microsoft.PowerShell.Utility\Write-Verbose "Successfully saved face metadata for: $image"
                }
                catch {

                    # log any errors that occur during metadata processing
                    Microsoft.PowerShell.Utility\Write-Warning "$PSItem`r`n$faces"
                }
            }
        }
    }

    end {
    }
}

################################################################################