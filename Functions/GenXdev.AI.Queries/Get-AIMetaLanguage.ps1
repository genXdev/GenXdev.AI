###############################################################################
<#
.SYNOPSIS
Gets the configured default language for image metadata operations.

.DESCRIPTION
This function retrieves the default language used by the GenXdev.AI module
for image metadata operations. It checks Global variables first (unless
SkipSession is specified), then falls back to persistent preferences, and
finally uses system defaults.

.PARAMETER Language
Optional language override. If specified, this language will be returned
instead of retrieving from configuration.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving the
configuration.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Get-AIMetaLanguage

Gets the currently configured language from Global variables or preferences.

.EXAMPLE
Get-AIMetaLanguage -SkipSession

Gets the configured language only from persistent preferences, ignoring any
session setting.

.EXAMPLE
Get-AIMetaLanguage -ClearSession

Clears the session language setting and then gets the language from
persistent preferences.

.EXAMPLE
getimgmetalang

Uses alias to get the current language configuration.
#>
###############################################################################
function Get-AIMetaLanguage {

    [CmdletBinding()]
    [OutputType([string])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('getimgmetalang')]

    param(
        ###########################################################################
        [Parameter(
            Position = 0,
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
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Database path for preference data files')
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear the session setting (Global variable) ' +
                'before retrieving')
        )]
        [switch] $ClearSession,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
    )

    if (-not [string]::IsNullOrWhiteSpace($Language)) {
        return $Language
    }

    $params = GenXdev.Helpers\Copy-IdenticalParamValues `
        -BoundParameters $PSBoundParameters `
        -FunctionName 'GenXdev.Data\Get-GenXdevPreference'

    GenXdev.Data\Get-GenXdevPreference @params `
        -Name 'AIMetaLanguage' `
        -DefaultValue "$(([string]::IsNullOrWhiteSpace($Language) ? (GenXdev.Helpers\Get-DefaultWebLanguage) : $Language))"
}
###############################################################################
