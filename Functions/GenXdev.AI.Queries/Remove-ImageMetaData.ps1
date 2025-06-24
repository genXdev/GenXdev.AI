################################################################################
<#
.SYNOPSIS
Removes image metadata files from image directories.

.DESCRIPTION
The Remove-ImageMetaData function removes companion JSON metadata files that
are associated with images. It can selectively remove only keywords
(description.json), people data (people.json), or objects data (objects.json),
or remove all metadata files if no specific switch is provided. Language-specific
metadata files can be removed by specifying the Language parameter, and all
language variants can be removed using the AllLanguages switch.

.PARAMETER ImageDirectories
Array of directory paths to process for image metadata removal. If not specified,
uses default system directories including Downloads, OneDrive, and Pictures folders.

.PARAMETER Recurse
When specified, searches for images in the specified directory and all
subdirectories.

.PARAMETER OnlyKeywords
When specified, only removes the description.json files (keywords/descriptions).

.PARAMETER OnlyPeople
When specified, only removes the people.json files (face recognition data).

.PARAMETER OnlyObjects
When specified, only removes the objects.json files (object detection data).

.PARAMETER Language
Specifies the language for removing language-specific metadata files. When
specified, removes both the default English description.json and the
language-specific file. Defaults to English.

.PARAMETER AllLanguages
When specified, removes metadata files for all supported languages by iterating
through all languages from Get-WebLanguageDictionary.

.EXAMPLE
Remove-ImageMetaData -ImageDirectories @("C:\Photos", "D:\MyImages") -Recurse

Removes all metadata files for images in multiple directories and all subdirectories.

.EXAMPLE
Remove-ImageMetaData -Recurse -OnlyKeywords

Removes only description.json files from default system directories and subdirectories.

.EXAMPLE
Remove-ImageMetaData -OnlyPeople -ImageDirectories @(".\MyPhotos")

Removes only people.json files from the MyPhotos directory.

.EXAMPLE
Remove-ImageMetaData -Language "Spanish" -OnlyKeywords -Recurse

Removes both English and Spanish description files recursively from default directories.

.EXAMPLE
removeimagedata -AllLanguages -OnlyKeywords

Uses alias to remove keyword files for all supported languages.

.NOTES
If none of the -OnlyKeywords, -OnlyPeople, -OnlyObjects, or -OnlyScenes switches are
specified, all four types of metadata files will be removed.
When Language is specified, both the default English and language-specific
files are removed.
When AllLanguages is specified, metadata files for all supported languages
are removed.
#>
function Remove-ImageMetaData {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias("removeimagedata")]

    param(        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Array of directory paths to process for image metadata removal. If not specified, uses default system directories."
        )]
        [Alias("ImageDirectory")]
        [string[]] $ImageDirectories,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Recurse directories."
        )]
        [switch] $Recurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only remove description.json files " +
                          "(keywords/descriptions).")
        )]
        [switch] $OnlyKeywords,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only remove people.json files " +
                          "(face recognition data).")
        )]
        [switch] $OnlyPeople,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only remove objects.json files " +
                          "(object detection data).")
        )]
        [switch] $OnlyObjects,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only remove scenes.json files " +
                          "(scene classification data).")
        )]
        [switch] $OnlyScenes,
        #######################################################################        [Parameter(
        [Parameter(
                Mandatory = $false,
            HelpMessage = ("The language for removing language-specific " +
                          "metadata files.")
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
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Remove metadata files for all supported " +
                          "languages.")
        )]
        [switch] $AllLanguages
        #######################################################################
    )

    begin {

        # get configured directories and language using Get-ImageDirectories
        $config = GenXdev.AI\Get-ImageDirectories -DefaultValue $ImageDirectories

        # use provided directories or get from configuration
        if ($ImageDirectories) {

            $directories = $ImageDirectories
        }
        else {

            $directories = $config.ImageDirectories
        }

        # resolve default language if not explicitly provided
        if ([string]::IsNullOrEmpty($Language)) {

            $Language = $config.Language
        }

        # output verbose information about directories to process
        Microsoft.PowerShell.Utility\Write-Verbose `
            ("Processing directories: {0} with language: {1}" -f ($directories -join ', '), $Language)
    }

    process {
        # iterate through each specified directory path
        foreach ($path in $directories) {

            # convert relative path to absolute path for consistency
            $path = GenXdev.FileSystem\Expand-Path $path

            # verify directory exists before proceeding
            if (-not [System.IO.Directory]::Exists($path)) {

                Microsoft.PowerShell.Utility\Write-Host `
                    "The directory '$path' does not exist."
                continue
            }

            # output verbose information about current directory being processed
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Processing directory: $path"

            # get all supported image files from the specified directory
            Microsoft.PowerShell.Management\Get-ChildItem `
                -Path "$path\*.jpg", "$path\*.jpeg", "$path\*.png" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                # store the full path of the current image
                $image = $PSItem.FullName

                # initialize array to track successfully removed files
                $removedFiles = @()

                # determine which metadata files to remove based on switches
                $filesToRemove = @()

                # determine languages to process
                $languagesToProcess = @()
                if ($AllLanguages) {

                    # get all supported languages from the dictionary
                    $languageDict = GenXdev.Helpers\Get-WebLanguageDictionary

                    # use all available language keys
                    $languagesToProcess = $languageDict.Keys
                }
                else {

                    # use only the specified language
                    $languagesToProcess = @($Language)
                }

                # iterate through each language to process
                foreach ($currentLanguage in $languagesToProcess) {

                    if ($OnlyKeywords) {

                        # always add the default english description file
                        if ("$($image):description.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):description.json"
                        }

                        # add language-specific description file if not english
                        if ($currentLanguage -ne "English") {

                            $filesToRemove += `
                                "$($image):description.$currentLanguage.json"
                        }
                    }
                    elseif ($OnlyPeople) {

                        # people data is not language-specific, so only add once
                        if ("$($image):people.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):people.json"
                        }
                    }                    elseif ($OnlyObjects) {

                        # objects data is not language-specific, so only add once
                        if ("$($image):objects.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):objects.json"
                        }
                    }
                    elseif ($OnlyScenes) {

                        # scenes data is not language-specific, so only add once
                        if ("$($image):scenes.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):scenes.json"
                        }
                    }
                    else {

                        # remove all metadata files for comprehensive cleanup

                        # always add the default english description file
                        if ("$($image):description.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):description.json"
                        }

                        # add language-specific description file if not english
                        if ($currentLanguage -ne "English") {

                            $filesToRemove += `
                                "$($image):description.$currentLanguage.json"
                        }

                        # add people and objects files only once
                        if ("$($image):people.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):people.json"
                        }

                        if ("$($image):objects.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):objects.json"
                        }

                        if ("$($image):scenes.json" -notin $filesToRemove) {

                            $filesToRemove += "$($image):scenes.json"
                        }
                    }
                }

                # remove the specified metadata files
                foreach ($file in $filesToRemove) {

                    # check if the metadata file actually exists
                    if ([System.IO.File]::Exists($file)) {

                        # extract just the filename for display purposes
                        $fileName = [System.IO.Path]::GetFileName($file)

                        # use whatif processing to respect -whatif parameter
                        if ($PSCmdlet.ShouldProcess($file, `
                            "Remove metadata file '$fileName'")) {

                            try {

                                # delete the metadata file
                                [System.IO.File]::Delete($file)

                                # track the successfully removed file
                                $removedFiles += $fileName

                                # output verbose information about file removal
                                Microsoft.PowerShell.Utility\Write-Verbose `
                                    "Removed: $file"
                            }
                            catch {

                                # handle file deletion errors gracefully
                                Microsoft.PowerShell.Utility\Write-Warning `
                                    ("Failed to remove {0}: {1}" -f `
                                     $file, $_.Exception.Message)
                            }
                        }
                    }
                }

                # output information about what was removed
                if ($removedFiles.Count -gt 0) {

                    # display successful removal summary
                    Microsoft.PowerShell.Utility\Write-Host `
                        ("Removed metadata for {0}: {1}" -f `
                         $PSItem.Name, ($removedFiles -join ', ')) `
                        -ForegroundColor Green
                }
                else {

                    # output verbose message when no files were found
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "No metadata files found for $($PSItem.Name)"
                }
            }
        }
    }

    end {
    }
}

################################################################################