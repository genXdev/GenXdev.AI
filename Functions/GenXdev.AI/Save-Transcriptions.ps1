################################################################################
<#
.SYNOPSIS
Saves transcriptions for all audio and video files located under a directory path.

.DESCRIPTION
Searches for media files under a directory and uses a local OpenAI Whisper model to
generate subtitle files in .srt format for each media file.

.PARAMETER DirectoryPath
The directory path to search for media files.

.PARAMETER Language
Sets the language to detect, defaults to 'English'.

#>
function Save-Transcriptions {

    [CmdletBinding()]
    param(
        ######################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The directory path to search for media files"
        )]
        [string] $DirectoryPath = ".\",
        ######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The language to expect in the audio, defaults to 'English'."
        )]
        [PSDefaultValue(Value = "English")]
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
        [string] $LanguageIn = "English",
        ######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Sets the language to translate to."
        )]
        [string]$LanguageOut = $null,
        ######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio model to use for translation."
        )]
        [string] $TranslateUsingLMStudioModel = "llama"
        ######################################################################
    )
    begin {

        $extensions = @(
            ".3gp",
            ".a52",
            ".aac",
            ".ac3",
            ".amr",
            ".mp3",
            ".adp",
            ".aiff",
            ".amr",
            ".ape",
            ".asf",
            ".avi",
            ".avif",
            ".avs",
            ".bink",
            ".bmp",
            ".caf",
            ".cavs",
            ".cgm",
            ".clpi",
            ".cpx",
            ".dds",
            ".dcm",
            ".dcr",
            ".dpx",
            ".dsic",
            ".dts",
            ".dtshd",
            ".dv",
            ".dvh",
            ".dvr",
            ".dxa",
            ".eac3",
            ".exr",
            ".ffm",
            ".ffmetadata",
            ".flac",
            ".flv",
            ".fmp4",
            ".gif",
            ".gsm",
            ".h261",
            ".h263",
            ".h264",
            ".h265",
            ".hevc",
            ".hls",
            ".ico",
            ".iff",
            ".ilbc",
            ".image2",
            ".imgut",
            ".ircam",
            ".j2k",
            ".jpeg",
            ".jpg",
            ".jps",
            ".jp2",
            ".jxr",
            ".lcov",
            ".ljpg",
            ".m1v",
            ".m2v",
            ".m4a",
            ".m4v",
            ".matroska",
            ".mgm",
            ".mkv",
            ".mlp",
            ".mmf",
            ".mov",
            ".mp1",
            ".mp2",
            ".mp3",
            ".mp4",
            ".mpc",
            ".mpeg",
            ".mpg",
            ".mpp",
            ".mrs",
            ".msf",
            ".msr",
            ".mvi",
            ".mxf",
            ".nut",
            ".ogg",
            ".ogv",
            ".oma",
            ".opus",
            ".paf",
            ".pbm",
            ".pcx",
            ".pgm",
            ".png",
            ".ps",
            ".psd",
            ".pva",
            ".qcif",
            ".qdm2",
            ".rawvideo",
            ".rc",
            ".redspark",
            ".rl2",
            ".rm",
            ".rmvb",
            ".rso",
            ".rtp",
            ".s24be",
            ".s3m",
            ".sbg",
            ".sdp",
            ".sgi",
            ".smk",
            ".sox",
            ".spx",
            ".sub",
            ".swf",
            ".tak",
            ".tap",
            ".tga",
            ".thp",
            ".tif",
            ".tiff",
            ".trp",
            ".ts",
            ".tta",
            ".txd",
            ".u8",
            ".uyvy",
            ".vc1",
            ".vob",
            ".wav",
            ".webm",
            ".webp",
            ".wma",
            ".wmv",
            ".wtv",
            ".x-flv",
            ".x-matroska",
            ".x-mkv",
            ".x-wav",
            ".xvag",
            ".yuv4mpegpipe"
        );

        Push-Location
    }

    process {

        Set-Location (Expand-Path $DirectoryPath);

        Get-ChildItem -File -rec | ForEach-Object {

            if ($extensions -notcontains $PSItem.Extension.ToLower()) { return }

            $enPathOld = "$($PSItem.FullName).en.srt";
            $nlPathOld = "$($PSItem.FullName).nl.srt";
            $nlPath = [IO.Path]::ChangeExtension($PSItem.FullName, ".nl.srt");
            $enPath = [IO.Path]::ChangeExtension($PSItem.FullName, ".en.srt");

            $lang = [string]::IsNullOrWhiteSpace($LanguageOut) ? $LanguageIn : $LanguageOut
            $newPath = [IO.Path]::ChangeExtension($PSItem.FullName, ".$lang.srt");

            if ([io.file]::Exists($nlPathOld)) {

                if ([io.file]::Exists($nlPath)) {

                    Remove-Item $nlPathOld -Force
                }
                else {

                    Move-Item $nlPathOld $nlPath -Force
                }
            }

            if ([io.file]::Exists($enPathOld)) {

                if ([io.file]::Exists($enPath)) {

                    Remove-Item $enPathOld -Force
                }
                else {

                    Move-Item $enPathOld $enPath -Force
                }
            }

            if ([io.file]::Exists($newPath)) { return }

            try {
                [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Idle;
                try {

                    "Processing $($PSItem.FullName).."

                    $params = @{
                        FilePath                    = $PSItem.FullName
                        SRT                         = $true
                        MaxTokensPerSegment         = 20
                        CpuThreads                  = 4
                        TranslateUsingLMStudioModel = $TranslateUsingLMStudioModel
                    }

                    if (-not [String]::IsNullOrWhiteSpace($LanguageIn)) {

                        $params += @{
                            LanguageIn = $LanguageIn
                        }
                    }

                    if (-not [String]::IsNullOrWhiteSpace($LanguageOut)) {

                        $params += @{
                            LanguageOut = $LanguageOut
                        }
                    }

                    $a = Get-MediaFileAudioTranscription @params
                }
                finally {
                    [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass = [System.Diagnostics.ProcessPriorityClass]::Normal;
                }
            }
            catch {

                "Processing of $($PSItem.FullName) failed: $PSItem"
                "-----------------------------------"
                return;
            }


            $a | Out-File $newPath -Force
            "-----------------------------------"
            $a
            "-----------------------------------"
        }
    }

    end {

        Pop-Location
    }
}
