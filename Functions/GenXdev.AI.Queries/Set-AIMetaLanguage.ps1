################################################################################
<#
.SYNOPSIS
Sets the default language and optionally the image directories for GenXdev.AI
image metadata operations.

.DESCRIPTION
This function configures the global default language for image metadata
operations in the GenXdev.AI module. Optionally, it can also set the global
image directories. Both settings are persisted in the module's preference
storage for use across sessions.

.PARAMETER Language
The default language to use for image metadata operations. This will be used
by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions
when no language is explicitly specified.

.PARAMETER ImageDirectories
An optional array of directory paths where image files are located. These
directories will be used by GenXdev.AI functions for image discovery and
processing operations if provided.

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
Set-AIMetaLanguage -Language "Spanish" -ImageDirectories @("C:\Images", "D:\Photos")

Sets the language and image directories persistently in preferences.

.EXAMPLE
Set-AIMetaLanguage "French"

Sets the language persistently in preferences.

.EXAMPLE
Set-AIMetaLanguage -Language "German" -SessionOnly

Sets the language only for the current session (Global variable).

.EXAMPLE
Set-AIMetaLanguage -ClearSession

Clears the session language setting (Global variable) without affecting
persistent preferences.
#>
################################################################################
function Set-AIMetaLanguage {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments',
        ''
    )]

    param(
    ########################################################################
        # specifies the default language for image metadata operations
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "The default language for image metadata operations"
        )]
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
            "Zulu"
        )]
        [string] $Language,
    ########################################################################
        # optionally specifies the array of directory paths for image files
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Array of directory paths for image files"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [string[]] $ImageDirectories,
    ########################################################################
        # specify database path for preference data files
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Database path for preference data files"
        )]
        [string] $PreferencesDatabasePath,
    ########################################################################
        # use alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $SessionOnly,
    ########################################################################
        # clear alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $ClearSession,
    ########################################################################
        # skip using alternative settings stored in session for AI preferences
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
    ########################################################################
    )

    begin {

        # validate parameters - language is required unless clearing session
        if ((-not $ClearSession) -and
            [string]::IsNullOrWhiteSpace($Language)) {

            throw ("Language parameter is required when not using " +
                   "-ClearSession")
        }

        # handle language parameter normalization only if not clearing session
        if (-not $ClearSession) {

            # copy parameters for nested function call
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # normalize the language using conditional operator and default
            $Language = GenXdev.AI\Get-AIMetaLanguage @params
        }
    }

    process {

        # handle clearing session variables
        if ($ClearSession) {

            # prepare base message for clearing session
            $clearMessage = "Clear session language setting"

            # check if image directories parameter was provided
            if ($PSBoundParameters.ContainsKey("ImageDirectories")) {

                # append image directories to clear message
                $clearMessage += " and image directories"
            }

            # complete the clear message
            $clearMessage += " (Global variables)"

            # confirm the operation with the user before proceeding
            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                $clearMessage
            )) {

                # clear the global language variable
                $Global:DefaultImagesMetaLanguage = $null

                # initialize array to track cleared settings
                $clearedSettings = @("DefaultImagesMetaLanguage")

                # check if image directories should also be cleared
                if ($PSBoundParameters.ContainsKey("ImageDirectories")) {

                    # clear the global image directories variable
                    $Global:ImageDirectories = $null

                    # add to cleared settings list
                    $clearedSettings += "ImageDirectories"
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Cleared session settings: " +
                    ($clearedSettings -join " and ")
                )
            }
            return
        }

        # handle session-only storage
        if ($SessionOnly) {

            # prepare base message for session-only storage
            $sessionMessage = ("Set session-only meta language to: " +
                             "$Language")

            # check if image directories parameter was provided
            if ($PSBoundParameters.ContainsKey("ImageDirectories")) {

                # append image directories to session message
                $sessionMessage += (" and set session-only image " +
                                  "directories to: [" +
                                  ($ImageDirectories -join ', ') + "]")
            }

            # confirm the operation with the user before proceeding
            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                $sessionMessage
            )) {

                # set global variable for session-only language storage
                $Global:DefaultImagesMetaLanguage = $Language

                Microsoft.PowerShell.Utility\Write-Verbose (
                    ("Set session-only language setting: " +
                     "DefaultImagesMetaLanguage = $Language")
                )

                # check if image directories should be set for session only
                if ($null -ne $ImageDirectories -and
                    $ImageDirectories.Count -gt 0 -and
                    $PSBoundParameters.ContainsKey("ImageDirectories")) {

                    # set global variable for session-only directories storage
                    $Global:ImageDirectories = $ImageDirectories

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        ("Set session-only image directories: [" +
                         ($ImageDirectories -join ', ') + "]")
                    )
                }
            }
            return
        }

        # handle persistent storage (default behavior)
        # prepare base message for persistent storage
        $persistentMessage = "Set meta language to: $Language"

        # check if image directories are provided for persistent storage
        if ($null -ne $ImageDirectories) {

            # append image directories to persistent message
            $persistentMessage += (" and set image directories to: [" +
                                 ($ImageDirectories -join ', ') + "]")
        }

        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            $persistentMessage
        )) {

            # output verbose message about setting default language
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting ImagesMetaLanguage preference to: $Language"
            )

            # check if image directories are provided and should be persisted
            if ($null -ne $ImageDirectories -and
                $ImageDirectories.Count -gt 0 -and
                $PSBoundParameters.ContainsKey("ImageDirectories")) {

                # output verbose message about setting image directories
                Microsoft.PowerShell.Utility\Write-Verbose (
                    ("Setting ImageDirectories preference to: [" +
                     ($ImageDirectories -join ', ') + "]")
                )

                # serialize the array to json for storage in preferences
                $serializedDirectories = $ImageDirectories |
                    Microsoft.PowerShell.Utility\ConvertTo-Json `
                        -Compress `
                        -ErrorAction SilentlyContinue

                # output verbose message about storing preferences
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Storing ImageDirectories in GenXdev preferences as JSON."
                )

                # store the image directories in module preferences
                $null = GenXdev.Data\Set-GenXdevPreference `
                    -PreferencesDatabasePath $PreferencesDatabasePath `
                    -Name "ImageDirectories" `
                    -Value $serializedDirectories
            }

            # store the default language configuration in module preferences
            $null = GenXdev.Data\Set-GenXdevPreference `
                -PreferencesDatabasePath $PreferencesDatabasePath `
                -Name "ImagesMetaLanguage" `
                -Value $Language

        }
    }

    end {
    }
}
################################################################################