################################################################################
<#
.SYNOPSIS
Sets the directories and default language for image files used in GenXdev.AI operations.

.DESCRIPTION
This function configures the global image directories and default language used by the GenXdev.AI module for various image processing and AI operations. Settings can be stored persistently in preferences (default), only in the current session (using -SessionOnly), or cleared from the session (using -ClearSession).

.PARAMETER ImageDirectories
An array of directory paths where image files are located. These directories will be used by GenXdev.AI functions for image discovery and processing operations.

.PARAMETER Language
The default language to use for image metadata operations. This will be used by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no language is explicitly specified.

.PARAMETER SessionOnly
When specified, stores the settings only in the current session (Global variables) without persisting to preferences. Settings will be lost when the session ends.

.PARAMETER ClearSession
When specified, clears only the session settings (Global variables) without affecting persistent preferences.

.EXAMPLE
Set-AIImageCollection -ImageDirectories @("C:\Images", "D:\Photos") -Language "Spanish"

Sets the image directories and language persistently in preferences.

.EXAMPLE
Set-AIImageCollection @("C:\Pictures", "E:\Graphics\Stock") "French"

Sets the image directories and language persistently in preferences.

.EXAMPLE
Set-AIImageCollection -ImageDirectories @("C:\TempImages") -Language "German" -SessionOnly

Sets the image directories and language only for the current session (Global variables).

.EXAMPLE
Set-AIImageCollection -ClearSession

Clears the session image directories and language settings (Global variables) without affecting persistent preferences.
#>
function Set-AIImageCollection {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
        # specifies the array of directory paths for image files
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "Array of directory paths for image files"
        )]
        [ValidateNotNullOrEmpty()]
        [Alias("imagespath", "directories", "imgdirs", "imagedirectory")]
        [string[]] $ImageDirectories,
        ###############################################################################
        # specifies the default language for image metadata operations
        [Parameter(
            Position = 1,
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

        # validate parameters - ImageDirectories is required unless clearing session
        if ((-not $ClearSession) -and ($null -eq $ImageDirectories -or $ImageDirectories.Count -eq 0)) {
            throw "ImageDirectories parameter is required when not using -ClearSession"
        }

        # handle language parameter normalization only if not clearing session
        if (-not $ClearSession -and $PSBoundParameters.ContainsKey("Language")) {
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

    process
    {
        # handle clearing session variables
        if ($ClearSession) {

            $clearMessage = "Clear session image directories"
            if ($PSBoundParameters.ContainsKey("Language")) {
                $clearMessage += " and language settings"
            }
            $clearMessage += " (Global variables)"

            if ($PSCmdlet.ShouldProcess(
                "GenXdev.AI Module Configuration",
                $clearMessage
            )) {

                # clear the global variables based on provided parameters
                $Global:ImageDirectories = $null

                $clearedSettings = @("ImageDirectories")

                if ($PSBoundParameters.ContainsKey("Language")) {
                    $Global:DefaultImagesMetaLanguage = $null
                    $clearedSettings += "DefaultImagesMetaLanguage"
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
                ("Set session-only image directories to: [" +
                    ($ImageDirectories -join ', ') + "]" +
                    (($PSBoundParameters.ContainsKey("Language")) ? (
                        " and session-only meta language to: $Language"
                    ) :  "" )
                )
            )) {

                # set global variables for session-only storage
                $Global:ImageDirectories = $ImageDirectories

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only image directories: [" +
                    ($ImageDirectories -join ', ') + "]"
                )

                if ($PSBoundParameters.ContainsKey("Language")) {

                    $Global:DefaultImagesMetaLanguage = $Language

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Set session-only language setting: DefaultImagesMetaLanguage = $Language"
                    )
                }
            }
            return
        }

        # handle persistent storage (default behavior)
        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess(
            "GenXdev.AI Module Configuration",
            ("Set image directories to: [" +
                ($ImageDirectories -join ', ')+"]" +
                (($PSBoundParameters.ContainsKey("Language")) ? (
                    " and meta language to: $Language"
                ) :  "" )
            )
        )) {

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

            if ($null -ne $Language -and $PSBoundParameters.ContainsKey("Language")) {

                # output verbose message about setting default language
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Setting ImagesMetaLanguage preference to: $Language"
                )

                # store the default language configuration in module preferences
                $null = GenXdev.Data\Set-GenXdevPreference `
                    -Name "ImagesMetaLanguage" `
                    -Value $Language
            }
        }
    }

    end {
    }
}
################################################################################