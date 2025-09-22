<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Remove-ImageMetaData.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.280.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################

<#
.SYNOPSIS
Removes image metadata files from image directories.

.DESCRIPTION
The Remove-ImageMetaData function removes companion JSON metadata files that
are associated with images. It can selectively remove only keywords
(description.json), people data (people.json), objects data (objects.json),
or scenes data (scenes.json), or remove all metadata files if no specific
switch is provided. Language-specific metadata files can be removed by
specifying the Language parameter, and all language variants can be removed
using the AllLanguages switch.

.PARAMETER ImageDirectories
Array of directory paths to process for image metadata removal. If not
specified, uses default system directories including Downloads, OneDrive,
and Pictures folders.

.PARAMETER Recurse
When specified, searches for images in the specified directory and all
subdirectories.

.PARAMETER Language
Specifies the language for removing language-specific metadata files. When
specified, removes both the default English description.json and the
language-specific file. Defaults to English.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER OnlyKeywords
When specified, only removes the description.json files
(keywords/descriptions).

.PARAMETER OnlyPeople
When specified, only removes the people.json files (face recognition data).

.PARAMETER OnlyObjects
When specified, only removes the objects.json files (object detection data).

.PARAMETER OnlyScenes
When specified, only removes the scenes.json files (scene classification
data).

.PARAMETER AllLanguages
When specified, removes metadata files for all supported languages by
iterating through all languages from Get-WebLanguageDictionary.

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
Remove-ImageMetaData -ImageDirectories @("C:\Photos", "D:\MyImages") -Recurse

Removes all metadata files for images in multiple directories and all
subdirectories.

.EXAMPLE
Remove-ImageMetaData -Recurse -OnlyKeywords

Removes only description.json files from default system directories and
subdirectories.

.EXAMPLE
Remove-ImageMetaData -OnlyPeople -ImageDirectories @(".\MyPhotos")

Removes only people.json files from the MyPhotos directory.

.EXAMPLE
Remove-ImageMetaData -Language "Spanish" -OnlyKeywords -Recurse

Removes both English and Spanish description files recursively from default
directories.

.EXAMPLE
removeimagedata -AllLanguages -OnlyKeywords

Uses alias to remove keyword files for all supported languages.

.NOTES
If none of the -OnlyKeywords, -OnlyPeople, -OnlyObjects, or -OnlyScenes
switches are specified, all four types of metadata files will be removed.
When Language is specified, both the default English and language-specific
files are removed.
When AllLanguages is specified, metadata files for all supported languages
are removed.
#>
###############################################################################
function Remove-ImageMetaData {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]
    [Alias('removeimagedata')]

    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = ('Array of directory paths to process for image ' +
                'metadata removal. If not specified, uses default ' +
                'system directories.')
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = ('The language for removing language-specific ' +
                'metadata files.')
        )]
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu'
        )]
        [string] $Language,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Recurse directories.'
        )]
        [switch] $Recurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only remove description.json files ' +
                '(keywords/descriptions).')
        )]
        [switch] $OnlyKeywords,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only remove people.json files ' +
                '(face recognition data).')
        )]
        [switch] $OnlyPeople,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only remove objects.json files ' +
                '(object detection data).')
        )]
        [switch] $OnlyObjects,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only remove scenes.json files ' +
                '(scene classification data).')
        )]
        [switch] $OnlyScenes,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Remove metadata files for all supported ' +
                'languages.')
        )]
        [switch] $AllLanguages,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, ' +
                'etc')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, ' +
                'etc')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image ' +
                'collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #######################################################################
    )

    begin {

        # copy identical parameter values for image collection retrieval
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIImageCollection' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get image directories using ai preferences
        $directories = GenXdev.AI\Get-AIImageCollection @params

        # copy identical parameter values for language retrieval
        $params = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # get configured language using ai preferences
        $Language = GenXdev.AI\Get-AIMetaLanguage @params

        # output verbose information about directories to process
        Microsoft.PowerShell.Utility\Write-Verbose `
        ('Processing directories: {0} with language: {1}' -f `
            ($directories -join ', '), $Language)
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

            # "$path\*.bmp", "$path\*.webp", "$path\*.tiff", "$path\*.tif"
            # get all supported image files from the specified directory
            (@(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.bmp" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.webp" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.tif" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.tiff" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.jpg" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.jpeg" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.gif" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue) +
                @(Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $path `
                -Filter "*.png" `
                -Recurse:$Recurse `
                -File `
                -ErrorAction SilentlyContinue)) |
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
                            if ($currentLanguage -ne 'English') {

                                $filesToRemove += `
                                    "$($image):description.$currentLanguage.json"
                            }
                        }
                        elseif ($OnlyPeople) {

                            # people data is not language-specific, so only add once
                            if ("$($image):people.json" -notin $filesToRemove) {

                                $filesToRemove += "$($image):people.json"
                            }
                        }
                        elseif ($OnlyObjects) {

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
                            if ($currentLanguage -ne 'English') {

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
                                    Microsoft.PowerShell.Utility\Write-Verbose `
                                    ('Failed to remove {0}: {1}' -f `
                                            $file, $_.Exception.Message)
                                }
                            }
                        }
                    }

                    # output information about what was removed
                    if ($removedFiles.Count -gt 0) {

                        # display successful removal summary
                        Microsoft.PowerShell.Utility\Write-Host `
                        ('Removed metadata for {0}: {1}' -f `
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

###############################################################################