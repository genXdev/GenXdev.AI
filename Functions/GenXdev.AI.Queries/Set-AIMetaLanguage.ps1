################################################################################
<#
.SYNOPSIS
Sets the default language and optionally the image directories for GenXdev.AI image metadata operations.

.DESCRIPTION
This function configures the global default language for image metadata operations in the GenXdev.AI module. Optionally, it can also set the global image directories. Both settings are persisted in the module's preference storage for use across sessions.

.PARAMETER Language
The default language to use for image metadata operations. This will be used by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no language is explicitly specified.

.PARAMETER ImageDirectories
An optional array of directory paths where image files are located. These directories will be used by GenXdev.AI functions for image discovery and processing operations if provided.

.PARAMETER SessionOnly
When specified, stores the settings only in the current session (Global variables) without persisting to preferences. Settings will be lost when the session ends.

.PARAMETER ClearSession
When specified, clears only the session settings (Global variables) without affecting persistent preferences.

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

Clears the session language setting (Global variable) without affecting persistent preferences.
#>
function Set-AIMetaLanguage {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
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
            "Zulu")]
        [string] $Language,
        ###############################################################################
        # optionally specifies the array of directory paths for image files
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "Array of directory paths for image files"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [string[]] $ImageDirectories,
        ###############################################################################
        # Use alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $SessionOnly,
        ###############################################################################
        # Clear alternative settings stored in session for AI preferences like Language, Image collections, etc
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Clear alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc"
        )]
        [Alias("FromPreferences")]
        [switch] $SkipSession
        ########################################################################

    )

    begin {

        # validate parameters - Language is required unless clearing session
        if ((-not $ClearSession) -and [string]::IsNullOrWhiteSpace($Language)) {
            throw "Language parameter is required when not using -ClearSession"
        }

        # handle language parameter normalization only if not clearing session
        if (-not $ClearSession) {
            $params = GenXdev.Helpers\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev.AI\Get-AIMetaLanguage" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
            $Language = GenXdev.AI\Get-AIMetaLanguage @params -Language (
                [String]::IsNullOrWhiteSpace($Language) ?
                (GenXdev.Helpers\Get-DefaultWebLanguage) :
                $Language
            )
        }
    }

    process {

        # handle clearing session variables
        if ($ClearSession) {

            $clearMessage = "Clear session language setting"
            if ($PSBoundParameters.ContainsKey("ImageDirectories")) {
                $clearMessage += " and image directories"
            }
            $clearMessage += " (Global variables)"

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                $clearMessage
            )) {

                # clear the global variables based on provided parameters
                $Global:DefaultImagesMetaLanguage = $null

                $clearedSettings = @("DefaultImagesMetaLanguage")

                if ($PSBoundParameters.ContainsKey("ImageDirectories")) {
                    $Global:ImageDirectories = $null
                    $clearedSettings += "ImageDirectories"
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Cleared session settings: " + ($clearedSettings -join " and ")
                )
            }
            return
        }

        # handle session-only storage
        if ($SessionOnly) {

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                ("Set session-only meta language to: $Language" +
                    (($PSBoundParameters.ContainsKey("ImageDirectories")) ? (
                        " and set session-only image directories to: [" +
                        ($ImageDirectories -join ', ') + "]"
                    ) :  "" )
                )
            )) {

                # set global variables for session-only storage
                $Global:DefaultImagesMetaLanguage = $Language

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only language setting: DefaultImagesMetaLanguage = $Language"
                )

                if ($null -ne $ImageDirectories -and $ImageDirectories.Count -gt 0 -and
                    $PSBoundParameters.ContainsKey("ImageDirectories")) {

                    $Global:ImageDirectories = $ImageDirectories

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Set session-only image directories: [" +
                        ($ImageDirectories -join ', ') + "]"
                    )
                }
            }
            return
        }

        # handle persistent storage (default behavior)

        # handle persistent storage (default parameter set)
        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            ("Set meta language to: $Language" +
                (($null -ne $ImageDirectories) ? (
                    " and set image directories to: [" +
                    ($ImageDirectories -join ', ') + "]"
                ) :  "" )
            )
        )) {

            # output verbose message about setting default language
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Setting ImagesMetaLanguage preference to: $Language"
            )

            # if image directories are provided, set and persist them
            if ($null -ne $ImageDirectories -and $ImageDirectories.Count -gt 0 -and
                $PSBoundParameters.ContainsKey("ImageDirectories")) {

                # output verbose message about setting image directories
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Setting ImageDirectories preference to: [" +
                    ($ImageDirectories -join ', ') + "]"
                )

                # serialize the array to json for storage in preferences
                $serializedDirectories = $ImageDirectories |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress `
                        -ErrorAction SilentlyContinue

                # output verbose message about storing preferences
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Storing ImageDirectories in GenXdev preferences as JSON."
                )

                # store the configuration in module preferences for persistence
                $null = GenXdev.Data\Set-GenXdevPreference `
                    -Name "ImageDirectories" `
                    -Value $serializedDirectories
            }

            # store the default language configuration in module preferences
            $null = GenXdev.Data\Set-GenXdevPreference `
                -Name "ImagesMetaLanguage" `
                -Value $Language
        }
    }

    end {
    }
}
################################################################################