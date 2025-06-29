################################################################################
<#
.SYNOPSIS
Updates image metadata with AI-generated descriptions and keywords.

.DESCRIPTION
The Invoke-ImageKeywordUpdate function analyzes images using AI to generate
descriptions, keywords, and other metadata. It creates a companion JSON file for
each image containing this information. The function can process new images only
or update existing metadata, and supports recursive directory scanning.

.PARAMETER ImageDirectories
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

.PARAMETER Language
Specifies the language for generated descriptions and keywords. Defaults to English.

.EXAMPLE
Invoke-ImageKeywordUpdate -ImageDirectories "C:\Photos" -Recurse -OnlyNew

.EXAMPLE
updateimages -Recurse -RetryFailed -Language "Spanish"
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
        [string] $ImageDirectories = ".\",

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
        [switch] $RetryFailed,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 4,
            HelpMessage = "The language for generated descriptions and keywords."
        )]
        [PSDefaultValue(Value = "English")]
        [ValidateSet(
            "Afrikaans",
            "Akan",
            "Albanian",
            "Amharic",
            "Arabic",
            "Armenian",
            "Azerbaijani",
            "Basque",
            "Belarusian",
            "Bemba",
            "Bengali",
            "Bihari",
            "Bosnian",
            "Breton",
            "Bulgarian",
            "Cambodian",
            "Catalan",
            "Cherokee",
            "Chichewa",
            "Chinese (Simplified)",
            "Chinese (Traditional)",
            "Corsican",
            "Croatian",
            "Czech",
            "Danish",
            "Dutch",
            "English",
            "Esperanto",
            "Estonian",
            "Ewe",
            "Faroese",
            "Filipino",
            "Finnish",
            "French",
            "Frisian",
            "Ga",
            "Galician",
            "Georgian",
            "German",
            "Greek",
            "Guarani",
            "Gujarati",
            "Haitian Creole",
            "Hausa",
            "Hawaiian",
            "Hebrew",
            "Hindi",
            "Hungarian",
            "Icelandic",
            "Igbo",
            "Indonesian",
            "Interlingua",
            "Irish",
            "Italian",
            "Japanese",
            "Javanese",
            "Kannada",
            "Kazakh",
            "Kinyarwanda",
            "Kirundi",
            "Kongo",
            "Korean",
            "Krio (Sierra Leone)",
            "Kurdish",
            "Kurdish (Soranî)",
            "Kyrgyz",
            "Laothian",
            "Latin",
            "Latvian",
            "Lingala",
            "Lithuanian",
            "Lozi",
            "Luganda",
            "Luo",
            "Macedonian",
            "Malagasy",
            "Malay",
            "Malayalam",
            "Maltese",
            "Maori",
            "Marathi",
            "Mauritian Creole",
            "Moldavian",
            "Mongolian",
            "Montenegrin",
            "Nepali",
            "Nigerian Pidgin",
            "Northern Sotho",
            "Norwegian",
            "Norwegian (Nynorsk)",
            "Occitan",
            "Oriya",
            "Oromo",
            "Pashto",
            "Persian",
            "Polish",
            "Portuguese (Brazil)",
            "Portuguese (Portugal)",
            "Punjabi",
            "Quechua",
            "Romanian",
            "Romansh",
            "Runyakitara",
            "Russian",
            "Scots Gaelic",
            "Serbian",
            "Serbo-Croatian",
            "Sesotho",
            "Setswana",
            "Seychellois Creole",
            "Shona",
            "Sindhi",
            "Sinhalese",
            "Slovak",
            "Slovenian",
            "Somali",
            "Spanish",
            "Spanish (Latin American)",
            "Sundanese",
            "Swahili",
            "Swedish",
            "Tajik",
            "Tamil",
            "Tatar",
            "Telugu",
            "Thai",
            "Tigrinya",
            "Tonga",
            "Tshiluba",
            "Tumbuka",
            "Turkish",
            "Turkmen",
            "Twi",
            "Uighur",
            "Ukrainian",
            "Urdu",
            "Uzbek",
            "Vietnamese",
            "Welsh",
            "Wolof",
            "Xhosa",
            "Yiddish",
            "Yoruba",
            "Zulu")]
        [string] $Language
    )

    begin {

        $Language = GenXdev.AI\Get-AIMetaLanguage -Language (
            [String]::IsNullOrWhiteSpace($Language) ?
            (GenXdev.Helpers\Get-DefaultWebLanguage) :
            $Language
        )

        # convert relative path to absolute path
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectories

        # verify directory exists before proceeding
        if (-not [System.IO.Directory]::Exists($path)) {

            Microsoft.PowerShell.Utility\Write-Host "The directory '$path' does not exist."
            return
        }
    }


process {

        # get all supported image files from the specified directory
        Microsoft.PowerShell.Management\Get-ChildItem -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
            -Recurse:$Recurse -File -ErrorAction SilentlyContinue |
        Microsoft.PowerShell.Core\ForEach-Object {

            # handle retry logic for previously failed images
            if ($RetryFailed) {
                # Try to find any language version first
                $existingMetadata = $false
                if ($Language -ne "English") {
                    $existingMetadata = [System.IO.File]::Exists("$($PSItem):description.$Language.json")
                }

                # If no language-specific file or English is requested, check standard file
                if (-not $existingMetadata) {
                    $existingMetadata = [System.IO.File]::Exists("$($PSItem):description.json")
                }

                if ($existingMetadata) {
                    # For language-specific file
                    if ($Language -ne "English" -and [System.IO.File]::Exists("$($PSItem):description.$Language.json")) {
                        # delete empty metadata files to force reprocessing
                        if ("$([System.IO.File]::ReadAllText(`
                            "$($PSItem):description.$Language.json"))".StartsWith("{}")) {

                            [System.IO.File]::Delete("$($PSItem):description.$Language.json")
                        }
                    }
                    # For standard English file
                    elseif ([System.IO.File]::Exists("$($PSItem):description.json")) {
                        # delete empty metadata files to force reprocessing
                        if ("$([System.IO.File]::ReadAllText(`
                            "$($PSItem):description.json"))".StartsWith("{}")) {

                            [System.IO.File]::Delete("$($PSItem):description.json")
                        }
                    }
                }
            }

            $image = $PSItem.FullName

            # ensure image is writable by removing read-only flag if present
            if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {
                $PSItem.Attributes = $PSItem.Attributes -bxor `
                    [System.IO.FileAttributes]::ReadOnly
            }

            # Determine which file to check based on language
            $metadataFile = if ($Language -eq "English") {
                "$($image):description.json"
            } else {
                "$($image):description.$Language.json"
            }

            $fileExists = [System.IO.File]::Exists($metadataFile)

            # process image if new or update requested
            if ((-not $OnlyNew) -or (-not $fileExists)) {

                # create empty metadata file if needed
                if (-not $fileExists) {

                    [IO.File]::WriteAllText($metadataFile, "{}")
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
                } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

                Microsoft.PowerShell.Utility\Write-Verbose "Analyzing image content: $image with language: $Language"

                $query = (
                    "Analyze image and return a object with properties: " +
                    "'short_description' (max 80 chars), 'long_description', " +
                    "'has_nudity, keywords' (array of strings with all detected objects, text or anything describing this picture, max 500 keywords), " +
                    "'has_explicit_content', 'overall_mood_of_image', " +
                    "'picture_type' and 'style_type'. " +
                    "Generate all descriptions and keywords in $Language language. " +
                    "Output only json, no markdown or anything other then json."
                );

                # get AI-generated image description and metadata
                $description = GenXdev.AI\Invoke-QueryImageContent `
                    -ResponseFormat $responseSchema `
                    -Query $query -ImagePath $image -Temperature 0.01

                Microsoft.PowerShell.Utility\Write-Verbose "Received analysis: $description"

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
                        $metadataFile,
                        ($description | Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20 `
                            -WarningAction SilentlyContinue))
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "$PSItem`r`n$description"
                }
            }
        }
    }

    end {
    }
}

################################################################################