################################################################################

<#
.SYNOPSIS
Updates image metadata with AI-generated descriptions and keywords.

.DESCRIPTION
The Invoke-ImageKeywordUpdate function analyzes images using AI to generate
descriptions, keywords, and other metadata. It creates a companion JSON file for
each image containing this information. The function can process new images only
or update existing metadata, and supports recursive directory scanning.

.PARAMETER ImageDirectory
Specifies the directory containing images to process. Defaults to current
directory if not specified.

.PARAMETER Recurse
When specified, searches for images in the specified directory and all
subdirectories.

.PARAMETER OnlyNew
When specified, only processes images that don't already have metadata JSON
files.

.PARAMETER RetryFailed
When specified, reprocesses images where previous metadata generation attempts
failed.

.EXAMPLE
Invoke-ImageKeywordUpdate -ImageDirectory "C:\Photos" -Recurse -OnlyNew

.EXAMPLE
updateimages -Recurse -RetryFailed
#>
function Invoke-ImageKeywordUpdate {

    [CmdletBinding()]
    [Alias("updateimages")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The image directory path."
        )]
        [string] $ImageDirectory = ".\",

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Recurse directories."
        )]
        [switch] $Recurse,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Skip if already has meta data."
        )]
        [switch] $OnlyNew,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = "Will retry previously failed images."
        )]
        [switch] $RetryFailed
    )

    begin {

        # convert relative path to absolute path
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectory

        # verify directory exists before proceeding
        if (-not [System.IO.Directory]::Exists($path)) {

            Write-Host "The directory '$path' does not exist."
            return
        }
    }

    process {

        # get all supported image files from the specified directory
        Get-ChildItem -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
            -Recurse:$Recurse -File -ErrorAction SilentlyContinue |
        ForEach-Object {

            # handle retry logic for previously failed images
            if ($RetryFailed) {

                if ([System.IO.File]::Exists("$($PSItem):description.json")) {

                    # delete empty metadata files to force reprocessing
                    if ("$([System.IO.File]::ReadAllText(`
                        "$($PSItem):description.json"))".StartsWith("{}")) {

                        [System.IO.File]::Delete("$($PSItem):description.json")
                    }
                }
            }

            $image = $PSItem.FullName

            # ensure image is writable by removing read-only flag if present
            if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

                $PSItem.Attributes = $PSItem.Attributes -bxor `
                    [System.IO.FileAttributes]::ReadOnly
            }

            $fileExists = [System.IO.File]::Exists("$($image):description.json")

            # process image if new or update requested
            if ((-not $OnlyNew) -or (-not $fileExists)) {

                # create empty metadata file if needed
                if (-not $fileExists) {

                    "{}" > "$($image):description.json"
                }

                # Define response format schema
                $responseSchema = @{
                    type        = "json_schema"
                    json_schema = @{
                        name   = "image_analysis_response"
                        strict = "true"
                        schema = @{
                            type       = "object"
                            properties = @{
                                short_description     = @{
                                    type        = "string"
                                    description = "Brief description of the image (max 80 chars)"
                                    maxLength   = 80
                                }
                                long_description      = @{
                                    type        = "string"
                                    description = "Detailed description of the image"
                                }
                                has_nudity            = @{
                                    type        = "boolean"
                                    description = "Whether the image contains nudity"
                                }
                                keywords              = @{
                                    type        = "array"
                                    items       = @{
                                        type = "string"
                                    }
                                    description = "Array of descriptive keywords"
                                }
                                has_explicit_content  = @{
                                    type        = "boolean"
                                    description = "Whether the image contains explicit content"
                                }
                                overall_mood_of_image = @{
                                    type        = "string"
                                    description = "The general mood or emotion conveyed by the image"
                                }
                                picture_type          = @{
                                    type        = "string"
                                    description = "The type or category of the image"
                                }
                                style_type            = @{
                                    type        = "string"
                                    description = "The artistic or visual style of the image"
                                }
                            }
                            required   = @(
                                "short_description",
                                "long_description",
                                "has_nudity",
                                "keywords",
                                "has_explicit_content",
                                "overall_mood_of_image",
                                "picture_type",
                                "style_type"
                            )
                        }
                    }
                } | ConvertTo-Json -Depth 10

                Write-Verbose "Analyzing image content: $image"

                $query = (
                    "Analyze image and return a object with properties: " +
                    "'short_description' (max 80 chars), 'long_description', " +
                    "'has_nudity, keywords' (array of strings), " +
                    "'has_explicit_content', 'overall_mood_of_image', " +
                    "'picture_type' and 'style_type'. " +
                    "Output only json, no markdown or anything other then json."
                );

                # get AI-generated image description and metadata
                $description = Invoke-QueryImageContent `
                    -ResponseFormat $responseSchema `
                    -Query $query -ImagePath $image -Temperature 0.01

                Write-Verbose "Received analysis: $description"

                try {

                    # extract just the JSON portion of the response
                    $description = $description.trim()
                    $i0 = $description.IndexOf("{")
                    $i1 = $description.LastIndexOf("}")
                    if ($i0 -ge 0) {

                        $description = $description.Substring($i0, $i1 - $i0 + 1)
                    }

                    # save formatted JSON metadata
                    [System.IO.File]::WriteAllText(
                        "$($image):description.json",
                        ($description | ConvertFrom-Json |
                        ConvertTo-Json -Compress -Depth 20 `
                            -WarningAction SilentlyContinue))
                }
                catch {

                    Write-Warning "$PSItem`r`n$description"
                }
            }
        }
    }

    end {
    }
}

################################################################################