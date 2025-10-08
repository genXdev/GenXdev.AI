<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Set-AIImageCollection.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.298.2025
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
################################################################################
<#
.SYNOPSIS
Sets the directories and default language for image files used in GenXdev.AI
operations.

.DESCRIPTION
This function configures the global image directories and default language used
by the GenXdev.AI module for various image processing and AI operations.
Settings can be stored persistently in preferences (default), only in the
current session (using -SessionOnly), or cleared from the session (using
-ClearSession).

.PARAMETER ImageDirectories
An array of directory paths where image files are located. These directories
will be used by GenXdev.AI functions for image discovery and processing
operations.

.PARAMETER Language
The default language to use for image metadata operations. This will be used by
Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no
language is explicitly specified.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SessionOnly
When specified, stores the settings only in the current session (Global
variables) without persisting to preferences. Settings will be lost when the
session ends.

.PARAMETER ClearSession
When specified, clears only the session settings (Global variables) without
affecting persistent preferences.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Set-AIImageCollection -ImageDirectories @("C:\Images", "D:\Photos") -Language "Spanish"

Sets the image directories and language persistently in preferences.

.EXAMPLE
Set-AIImageCollection @("C:\Pictures", "E:\Graphics\Stock") "French"

Sets the image directories and language persistently in preferences.

.EXAMPLE
Set-AIImageCollection -ImageDirectories @("C:\TempImages") -Language "German" -SessionOnly

Sets the image directories and language only for the current session (Global
variables).

.EXAMPLE
Set-AIImageCollection -ClearSession

Clears the session image directories and language settings (Global variables)
without affecting persistent preferences.
#>
################################################################################
function Set-AIImageCollection {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Array of directory paths for image files'
        )]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory')]
        [string[]] $ImageDirectories,    ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The default language for image metadata operations'
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
            'Zulu')]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )

    # fallback to default system directories
    $picturesPath = GenXdev.FileSystem\Expand-Path '~\Pictures'

    try {

        # attempt to get known folder path for pictures directory
        $picturesPath = GenXdev.Windows\Get-KnownFolderPath Pictures
    }
    catch {

        # fallback to default if known folder retrieval fails
        $picturesPath = GenXdev.FileSystem\Expand-Path '~\Pictures'
    }

    # fallback to default system directories
    $desktopPath = GenXdev.FileSystem\Expand-Path '~\Desktop'

    try {

        # attempt to get known folder path for desktop directory
        $desktopPath = GenXdev.Windows\Get-KnownFolderPath Desktop
    }
    catch {

        # fallback to default if known folder retrieval fails
        $desktopPath = GenXdev.FileSystem\Expand-Path '~\Desktop'
    }

    # fallback to default system directories
    $documentsPath = GenXdev.FileSystem\Expand-Path '~\Documents'

    try {

        # attempt to get known folder path for documents directory
        $documentsPath = GenXdev.Windows\Get-KnownFolderPath Documents
    }
    catch {

        # fallback to default if known folder retrieval fails
        $documentsPath = GenXdev.FileSystem\Expand-Path '~\Documents'
    }

    # define default directories for image processing operations
    $DefaultValue = @(
            (GenXdev.FileSystem\Expand-Path '~\downloads'),
            (GenXdev.FileSystem\Expand-Path '~\onedrive'),
        $picturesPath,
        $desktopPath,
        $documentsPath
    )

    $ImageDirectories = ($ImageDirectories ? $ImageDirectories : $DefaultValue)
    $Json = $ImageDirectories | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

    # confirm the operation with the user before proceeding
    if ($PSCmdlet.ShouldProcess(
            "AI Image Collection settings",
            "Update image directories and language preferences")) {

        $params = GenXdev.FileSystem\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.Data\Set-GenXdevPreference'

        $null = GenXdev.Data\Set-GenXdevPreference @params `
            -Name 'AIImageCollection' `
            -Value $Json
    }

}
################################################################################