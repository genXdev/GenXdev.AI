################################################################################
<#
.SYNOPSIS
Sets the directories and default language for image files used in GenXdev.AI operations.

.DESCRIPTION
This function configures the global image directories and default language used by the GenXdev.AI module for various image processing and AI operations. It updates both the global variables and the module's preference storage to persist the configuration across sessions.

.PARAMETER ImageDirectories
An array of directory paths where image files are located. These directories will be used by GenXdev.AI functions for image discovery and processing operations.

.PARAMETER Language
The default language to use for image metadata operations. This will be used by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no language is explicitly specified.

.EXAMPLE
Set-AIImageCollection -ImageDirectories @("C:\Images", "D:\Photos") -Language "Spanish"

.EXAMPLE
Set-AIImageCollection @("C:\Pictures", "E:\Graphics\Stock") "French"
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
            Mandatory = $true,
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
        [string] $Language
        ###############################################################################
    )

    begin {
        $Language = GenXdev.AI\Get-AIMetaLanguage -Language (
            [String]::IsNullOrWhiteSpace($Language) ?
            (GenXdev.Helpers\Get-DefaultWebLanguage) :
            $Language
        )
    }

    process
    {
        # confirm the operation with the user before proceeding
        if ($PSCmdlet.ShouldProcess((
            "GenXdev.AI Module Configuration",
            ("Set image directories to: [" +
                ($ImageDirectories -join ', ')+"]")))) {

            # set the global variable for immediate use by other functions
            $Global:ImageDirectories = $ImageDirectories

            # output verbose message about setting image directories
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Set global variable: ImageDirectories = [" +
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

                # set the global default language variable
                $Global:DefaultImagesMetaLanguage = $Language

                # output verbose message about setting default language
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set global variable: DefaultImagesMetaLanguage = $Language"
                )

                # store the default language configuration in module preferences
                $null = GenXdev.Data\Set-GenXdevPreference `
                    -Name "DefaultImagesMetaLanguage" `
                    -Value $Language
            }
        }
    }

    end {
    }
}
################################################################################