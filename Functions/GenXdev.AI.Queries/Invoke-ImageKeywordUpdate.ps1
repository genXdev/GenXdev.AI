###############################################################################
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

.PARAMETER Language
Specifies the language for generated descriptions and keywords. Defaults to
English.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER Recurse
When specified, searches for images in the specified directory and all
subdirectories.

.PARAMETER OnlyNew
When specified, only processes images that don't already have metadata JSON
files.

.PARAMETER RetryFailed
When specified, reprocesses images where previous metadata generation attempts
failed.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Invoke-ImageKeywordUpdate -ImageDirectories "C:\Photos" -Recurse -OnlyNew

.EXAMPLE
updateimages -Recurse -RetryFailed -Language "Spanish"
#>
###############################################################################
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
        [string] $Language,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Recurse directories."
        )]
        [switch] $Recurse,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip if already has meta data."
        )]
        [switch] $OnlyNew,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Will retry previously failed images."
        )]
        [switch] $RetryFailed,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Use alternative settings stored in session for AI " +
                          "preferences like Language, Image collections, etc")
        )]
        [switch] $SessionOnly,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Clear alternative settings stored in session for AI " +
                          "preferences like Language, Image collections, etc")
        )]
        [switch] $ClearSession,
    ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Dont use alternative settings stored in session for " +
                          "AI preferences like Language, Image collections, etc")
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
    ###############################################################################
    )

    begin {

        # copy identical parameter values for ai meta language function
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -ErrorAction SilentlyContinue)

        # get the resolved language setting from ai meta system
        $language = GenXdev.AI\Get-AIMetaLanguage @params

        # convert relative path to absolute path
        $path = GenXdev.FileSystem\Expand-Path $ImageDirectories

        # verify directory exists before proceeding
        if (-not [System.IO.Directory]::Exists($path)) {

            Microsoft.PowerShell.Utility\Write-Host ("The directory '$path' " +
                                                     "does not exist.")
            return
        }
    }

    process {

        # get all supported image files from the specified directory
        Microsoft.PowerShell.Management\Get-ChildItem `
            -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.gif", "$path\*.png" `
            -Recurse:$Recurse -File -ErrorAction SilentlyContinue |
        Microsoft.PowerShell.Core\ForEach-Object {

            # get the full path of the current image file
            $image = $PSItem.FullName

            # ensure image is writable by removing read-only flag if present
            if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

                $PSItem.Attributes = $PSItem.Attributes -bxor `
                    [System.IO.FileAttributes]::ReadOnly
            }

            # determine which metadata file to check based on language preference
            $metadataFile = if ($language -eq "English") {
                "$($image):description.json"
            } else {
                "$($image):description.$language.json"
            }

            # check if metadata file already exists
            $fileExists = [System.IO.File]::Exists($metadataFile)

            # check if we have valid existing content
            $hasValidContent = $false
            if ($fileExists) {
                try {
                    $content = [System.IO.File]::ReadAllText($metadataFile)
                    $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                    $hasValidContent = $existingData.short_description -and $existingData.keywords
                }
                catch {
                    # If JSON parsing fails, treat as invalid content
                    $hasValidContent = $false
                }
            }

            # process image if conditions are met (new files or update requested)
            if ((-not $OnlyNew) -or (-not $fileExists) -or (-not $hasValidContent)) {

                # define response format schema for ai analysis
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
                                    description = ("Brief description of the " +
                                                   "image (max 80 chars)")
                                    maxLength   = 80
                                }
                                long_description      = @{
                                    type        = "string"
                                    description = ("Detailed description of " +
                                                   "the image")
                                }
                                has_nudity            = @{
                                    type        = "boolean"
                                    description = ("Whether the image " +
                                                   "contains nudity")
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
                                    description = ("Whether the image contains " +
                                                   "explicit content")
                                }
                                overall_mood_of_image = @{
                                    type        = "string"
                                    description = ("The general mood or emotion " +
                                                   "conveyed by the image")
                                }
                                picture_type          = @{
                                    type        = "string"
                                    description = ("The type or category of " +
                                                   "the image")
                                }
                                style_type            = @{
                                    type        = "string"
                                    description = ("The artistic or visual style " +
                                                   "of the image")
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
                } |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

                # output verbose information about the image being analyzed
                Microsoft.PowerShell.Utility\Write-Verbose ("Analyzing image " +
                    "content: $image with language: $language")

                $Additional = @{metadata=@(
                  GenXdev.FileSystem\Find-Item "$($image):people.json" -IncludeAlternateFileStreams -PassThru |
                  Microsoft.PowerShell.Core\ForEach-Object FullName |
                  Microsoft.PowerShell.Core\ForEach-Object {
                    try {
                         $content = [IO.File]::ReadAllText($_)
                         $obj = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                         if (($null -ne $obj) -and ($null -ne $obj.predictions) -and ($obj.predictions.Count -gt 0)) {

                             $obj.predictions | Microsoft.PowerShell.Core\ForEach-Object { $_ }
                         }
                    }
                    catch {
                        # ignore errors reading existing metadata
                    }
                });
                FileInfo = @{
                    ImageCollection = [IO.Path]::GetFileName($ImageDirectories)
                    ImageFilename = $image.Substring($ImageDirectories.Length + 1)
                }};

                $json = $Additional | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20

                # construct comprehensive ai query for image analysis
                $query = (
                    "Analyze image and return a JSON object with properties: " +
                    "'short_description' (max 80 chars), 'long_description', " +
                    "'has_nudity', 'keywords' (array of strings with all " +
                    "detected objects, text or anything describing this " +
                    "picture, max 15 keywords), " +
                    "'has_explicit_content', 'overall_mood_of_image', " +
                    "'picture_type' and 'style_type'.`r`n`r`n" +
                    "Generate all descriptions and keywords in $language " +
                    "language.`r`n`r`n" +
                    "Output only JSON, no markdown or anything other than JSON.`r`n`r`n" +
                    "$(($Additional.metadata.Count -gt 0 ? @"
Use the metadata below to enrich the descriptions and titles.
Like mentioning the person's name in the title when high confidence is detected (> 0.8).
If it the name is that of a famous person, tell about his/her life in the long description
and mention his name in the title.
$json`r`n
"@ : "$json`r`n"))"
                );

                # get ai-generated image description and metadata
                $description = GenXdev.AI\Invoke-QueryImageContent `
                    -ResponseFormat $responseSchema `
                    -Query $query `
                    -ImagePath $image `
                    -Temperature 0.01

                # output verbose information about the received analysis
                Microsoft.PowerShell.Utility\Write-Verbose ("Received " +
                    "analysis: $description")

                try {

                    # extract just the json portion of the response text
                    $description = $description.trim()

                    # find the first opening brace position
                    $i0 = $description.IndexOf("{")

                    # find the last closing brace position
                    $i1 = $description.LastIndexOf("}")

                    # extract only the json content if braces found
                    if ($i0 -ge 0) {

                        $description = $description.Substring(
                            $i0, $i1 - $i0 + 1)
                    }

                    $description = (($description | Microsoft.PowerShell.Utility\ConvertFrom-Json | GenXdev.Helpers\ConvertTo-HashTable) + $Additional.FileInfo) |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20  -WarningAction SilentlyContinue

                    # save formatted json metadata to companion file
                    $null = [System.IO.File]::WriteAllText(
                        $metadataFile,
                        $description
                    )
                }
                catch {

                    # output warning if json processing or file writing fails
                    Microsoft.PowerShell.Utility\Write-Warning ("$PSItem`r`n" +
                        "$description")
                }
        }
        }
    }
    end {
    }
}
###############################################################################