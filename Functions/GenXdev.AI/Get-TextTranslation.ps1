################################################################################
<#
.SYNOPSIS
Translates text to another language using the LM-Studio API.

.DESCRIPTION
The Get-TextTranslation function translates text into a specified target language
using LM-Studio's API. It processes text in chunks to handle large inputs
efficiently and maintains formatting.

.PARAMETER Text
The source text to be translated. Can be provided via pipeline.

.PARAMETER Language
The target language for translation. Defaults to "English".
Supports 140+ languages including major world languages and fun variants.

.PARAMETER Instructions
Custom instructions for the LLM model about how to perform the translation.
Defaults to maintaining style and paragraph structure while translating.

.PARAMETER Model
The LM-Studio model to use for translation. Defaults to "qwen".

.EXAMPLE
Get-TextTranslation -Text "Hello, how are you?" -Language "French" `
    -Model "qwen"

.EXAMPLE
"Bonjour" | translate -Language "English"
#>
function Get-TextTranslation {

    [CmdletBinding()]
    [Alias("translate", "Get-Translation")]

    param (
        ################################################################################
        [Parameter(
            Mandatory = $true,
            HelpMessage = "The text to translate",
            ValueFromPipeline = $true
        )]
        [string] $Text,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The target language for translation"
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


        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom instructions for the translation model"
        )]
        [PSDefaultValue(Value = "Translate this partial subtitle text, into the " +
                "[Language] language, leave in the same style of writing, and leave " +
                "the paragraph structure in tact, ommit only the translation no " +
                "yapping or chatting.")]
        $Instructions = "Translate this partial subtitle text, into the [Language] " +
            "language, leave in the same style of writing, and leave the paragraph " +
            "structure in tact, ommit only the translation no yapping or chatting.",


        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for translation"
        )]
        [PSDefaultValue(Value = "qwen")]
        [SupportsWildcards()]
        [string]$Model = "qwen"
    )


    begin {

        # create a string builder for efficient string concatenation
        [System.Text.StringBuilder] $translation = `
            New-Object System.Text.StringBuilder


        # inject target language into instructions template
        $Instructions = $Instructions.Replace("[Language]", $Language)


        # show initial progress indication
        [System.Console]::Write("translating to $Language..")
    }


    process {

        # set initial chunk size for text processing (1000 chars or text length)
        $i = [Math]::Min(1000, $Text.Length)


        # process text in chunks until complete
        while ($i -gt 0) {

            # find word boundary for clean chunk split
            while (($i -gt 0) -and (" `t`r`n".indexOf($Text[$i]) -lt 0)) {
                $i--
            }
            while (($i -lt $Text.Length) -and (" `t`r`n".indexOf($Text[$i]) -lt 0)) {
                $i++
            }

            # handle last chunk
            if ($i -lt 1000) {
                $i = $Text.Length
            }


            # extract next chunk for translation
            $nextPart = $Text.Substring(0, $i)
            $spaceLeft = ""


            # remove processed chunk from remaining text
            $Text = $Text.Substring($i)


            # skip empty chunks
            if ([string]::IsNullOrWhiteSpace($nextPart)) {
                $null = $translation.Append("$nextPart")
                $i = [Math]::Min(100, $Text.Length)
                continue
            }


            # preserve leading whitespace
            $spaceLeft = ""
            while ($nextPart.StartsWith(" ") -or $nextPart.StartsWith("`t") -or `
                    $nextPart.StartsWith("`r") -or $nextPart.StartsWith("`n")) {
                $spaceLeft += $nextPart[0]
                $nextPart = $nextPart.Substring(1)
            }


            # preserve trailing whitespace
            $spaceRight = ""
            while ($nextPart.EndsWith(" ") -or $nextPart.EndsWith("`t") -or `
                    $nextPart.EndsWith("`r") -or $nextPart.EndsWith("`n")) {
                $spaceRight += $nextPart[-1]
                $nextPart = $nextPart.Substring(0, $nextPart.Length - 1)
            }

            Write-Verbose "Translating text to $Language for: `"$nextPart`".."

            try {
                # attempt translation of current chunk
                $translatedPart = Invoke-LLMQuery `
                    -Query "partial subtitle text: '$nextPart'" `
                    -Instructions $Instructions `
                    -Model:$Model `
                    -Temperature 0.02

                # append successful translation with preserved spacing
                $null = $translation.Append("$spaceLeft$translatedPart$spaceRight")

                Write-Verbose "Text translated to: `"$translatedPart`".."
            }
            catch {
                # on error, preserve original text
                $null = $translation.Append("$spaceLeft$nextPart$spaceRight")

                Write-Verbose "Translation failed: $PSItem"
            }


            # prepare for next chunk
            $i = [Math]::Min(100, $Text.Length)
        }
    }


    end {
        # return completed translation
        $translation.ToString()
    }
}
################################################################################
