################################################################################
<#

#>
function Get-AIMetaLanguage {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias("getimgmetalang")]

    param(
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
        [string] $Language
    )

    begin {

        # initialize result object
        $result = GenXdev.Helpers\Get-DefaultWebLanguage
    }

    process {

        if (-not [string]::IsNullOrWhiteSpace($Language)) {

            # if no language specified, use default web language
            $result = $Language
            return;
        }

        # get image directories from preferences or global variable
        $LanguagePreference = $null

        try {

            # retrieve image directories preference from genxdev data storage
            $json = GenXdev.Data\Get-GenXdevPreference `
                -Name "ImagesMetaLanguage" `
                -DefaultValue $null `
                -ErrorAction SilentlyContinue

            if (-not [string]::IsNullOrEmpty($json)) {

                # convert json preference to powershell object
                $LanguagePreference = $json |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json
            }
        }
        catch {

            # set to null if preference retrieval fails
            $LanguagePreference = $null
        }

        # determine which image directories to use based on priority
        if (-not ([string]::IsNullOrWhiteSpace(($LanguagePreference)))) {

            # use preference value if available and not empty
            $result = $LanguagePreference
        }
        elseif (-not ([string]::IsNullOrWhiteSpace($Global:Language))) {

            # fallback to global variable if preference not available
            $result = $Global:Language
        }
        else {

            $result = "English";
        }
    }

    end {

        # return the configured image directories and language
        return $result
    }
}
################################################################################
