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

.EXAMPLE
Set-AIMetaLanguage -Language "Spanish" -ImageDirectories @("C:\Images", "D:\Photos")

.EXAMPLE
Set-AIMetaLanguage "French"
#>
function Set-AIMetaLanguage {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###############################################################################
        # specifies the default language for image metadata operations
        [Parameter(
            Position = 0,
            Mandatory = $true,
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
        [string[]] $ImageDirectories
        ###############################################################################
    )

    begin {

        $Language = GenXdev.AI\Get-AIMetaLanguage -Language (
            [String]::IsNullOrWhiteSpace($Language) ?
            (GenXdev.Helpers\Get-DefaultWebLanguage) :
            $Language
        )
    }

    process {

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

            # set the global default language variable
            $Global:DefaultImagesMetaLanguage = $Language

            # output verbose message about setting default language
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Set global variable: DefaultImagesMetaLanguage = $Global:DefaultImagesMetaLanguage"
            )

            # if image directories are provided, set and persist them
            if ($null -ne $ImageDirectories -and $ImageDirectories.Count -gt 0 -and
                $PSBoundParameters.ContainsKey("ImageDirectories")) {

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