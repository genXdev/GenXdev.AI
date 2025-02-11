################################################################################
<#
.SYNOPSIS
Translates text to another language using the LM-Studio API.

.DESCRIPTION
The `Get-TextTranslation` function translates text to another language using the LM-Studio API.

.PARAMETER Text
The text to translate.

.PARAMETER Language
The language to translate to.

.PARAMETER Instructions
The instructions for the model.
Defaults to:

.PARAMETER Model
Name or partial path of the model to initialize, detects and excepts -like 'patterns*' for search
.EXAMPLE
    Get-TextTranslation -Text "Hello, how are you?" -Language "french"

    "Hello, how are you?" | translate -Language "french"

#>
function Get-TextTranslation {

    [CmdletBinding()]
    [Alias("translate", "Get-Translation")]

    param (
        ################################################################################
        [Parameter(
            Mandatory,
            HelpMessage = "The text to translate",
            ValueFromPipeline
        )]
        [string] $Text,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The language to translate to."
        )]
        [PSDefaultValue(Value = "english")]
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
            "Bork, bork, bork!",
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
            "Elmer Fudd",
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
            "Hacker",
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
            "Klingon",
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
            "Pirate",
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
        [string] $Language = "English",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The system instructions for the LLM."
        )]
        [PSDefaultValue(Value = "Translate this partial subtitle text, into the `[Language] language, leave in the same style of writing, and leave the paragraph structure in tact, ommit only the translation no yapping or chatting.")]
        $Instructions = "Translate this partial subtitle text, into the [Language] language, leave in the same style of writing, and leave the paragraph structure in tact, ommit only the translation no yapping or chatting.",

        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response."
        )]
        [PSDefaultValue(Value = "qwen")]
        [string]$Model = "qwen"
    )

    begin {
        # initialize translation container
        [System.Text.StringBuilder] $translation = New-Object System.Text.StringBuilder;

        $Instructions = $Instructions.Replace("[Language]", $Language);

        [System.Console]::Write("translating to $Language..")
    }

    process {

        # initialize the cursor, trying +/- 1K characters
        $i = [Math]::Min(1000, $Text.Length)

        # perform translations in chunks
        while ($i -gt 0) {

            # move the cursor to the next word
            while (($i -gt 0) -and (" `t`r`n".indexOf($Text[$i]) -lt 0)) { $i--; }
            while (($i -lt $Text.Length) -and (" `t`r`n".indexOf($Text[$i]) -lt 0)) { $i++; }
            if ($i -lt 1000) { $i = $Text.Length; }

            # get the next part of the text
            $nextPart = $Text.Substring(0, $i);
            $spaceLeft = "";

            # remove the part from the work queue
            $Text = $Text.Substring($i);

            if ([string]::IsNullOrWhiteSpace($nextPart)) {

                $translation.Append("$nextPart") | Out-Null
                $i = [Math]::Min(100, $Text.Length)
                continue;
            }

            $spaceLeft = "";
            while ($nextPart.StartsWith(" ") -or $nextPart.StartsWith("`t") -or $nextPart.StartsWith("`r") -or $nextPart.StartsWith("`n")) {

                $spaceLeft += $nextPart[0];
                $nextPart = $nextPart.Substring(1);
            }
            $spaceRight = "";
            while ($nextPart.EndsWith(" ") -or $nextPart.EndsWith("`t") -or $nextPart.EndsWith("`r") -or $nextPart.EndsWith("`n")) {

                $spaceRight += $nextPart[-1];
                $nextPart = $nextPart.Substring(0, $nextPart.Length - 1);
            }

            Write-Verbose "Translating text to $Language for: `"$nextPart`".."

            try {
                # translate the text
                $translatedPart = qlms -Query "partial subtitle text: '$nextPart'" -Instructions $Instructions -Model:$Model -Temperature 0.02

                # append the translated part
                $translation.Append("$spaceLeft$translatedPart$spaceRight") | Out-Null

                Write-Verbose "Text translated to: `"$translatedPart`".."
            }
            catch {

                # append the original part
                $translation.Append("$spaceLeft$nextPart$spaceRight") | Out-Null

                Write-Verbose "Translating text to $LanguageOut, failed: $PSItem"
            }

            $i = [Math]::Min(100, $Text.Length)
        }
    }

    end {
        # return the translation
        $translation.ToString();
    }
}
