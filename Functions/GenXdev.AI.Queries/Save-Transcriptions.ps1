################################################################################
<#
.SYNOPSIS
Generates subtitle files for audio and video files using OpenAI Whisper.

.DESCRIPTION
Recursively searches for media files in the specified directory and uses a local
OpenAI Whisper model to generate subtitle files in SRT format. The function
supports multiple audio/video formats and can optionally translate subtitles to
a different language using LM Studio. File naming follows a standardized pattern
with language codes (e.g., video.mp4.en.srt).

.PARAMETER DirectoryPath
The root directory to search for media files. Defaults to the current directory.
Will recursively process all supported media files in subfolders.

.PARAMETER LanguageIn
The expected source language of the audio content. Used to improve transcription
accuracy. Defaults to English. Supports 150+ languages.

.PARAMETER LanguageOut
Optional target language for translation. If specified, the generated subtitles
will be translated from LanguageIn to this language using LM Studio.

.PARAMETER TranslateUsingLMStudioModel
The LM Studio model name to use for translation. Defaults to "qwen". Only used
when LanguageOut is specified.

.EXAMPLE
Save-Transcriptions -DirectoryPath "C:\Videos" -LanguageIn "English"

.EXAMPLE
Save-Transcriptions "C:\Media" "Japanese" "English" "qwen"
#>
################################################################################
function Save-Transcriptions {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]

    param(
        ################################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The directory path to search for media files"
        )]
        [string] $DirectoryPath = ".\",
        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "The language to expect in the audio."
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
        [string] $LanguageIn = "",
        ################################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "Sets the language to translate to."
        )]
        [string]$LanguageOut = $null,
        ################################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The LM Studio model to use for translation."
        )]
        [string] $TranslateUsingLMStudioModel = "qwen"
        ################################################################################
    )

    begin {

        # check if language input parameter is empty or whitespace
        if ([string]::IsNullOrWhiteSpace($LanguageIn)) {

            # get default language from system settings
            $LanguageIn = GenXdev.Helpers\Get-DefaultWebLanguage
        }

        # define array of supported media file extensions for processing
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
        )

        # store current location to restore at end of processing
        Microsoft.PowerShell.Management\Push-Location

        Microsoft.PowerShell.Utility\Write-Verbose ("Current working directory " +
            "stored for later restoration")
    }

    process {

        # change to target directory for file processing
        Microsoft.PowerShell.Management\Set-Location `
            (GenXdev.FileSystem\Expand-Path $DirectoryPath)

        Microsoft.PowerShell.Utility\Write-Verbose ("Changed working directory " +
            "to: $DirectoryPath")

        # recursively process each file in directory and subdirectories
        Microsoft.PowerShell.Management\Get-ChildItem -File -rec |
            Microsoft.PowerShell.Core\ForEach-Object {

            # skip files that don't have a supported media extension
            if ($extensions -notcontains $PSItem.Extension.ToLower()) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Skipping file with " +
                    "unsupported extension: $($PSItem.Name)")

                return
            }

            # construct paths for old and new subtitle file naming patterns
            $enPathOld = "$($PSItem.FullName).en.srt"

            $nlPathOld = "$($PSItem.FullName).nl.srt"

            $nlPath = [IO.Path]::ChangeExtension($PSItem.FullName, ".nl.srt")

            $enPath = [IO.Path]::ChangeExtension($PSItem.FullName, ".en.srt")

            # determine target language and output path for new subtitle file
            $lang = [string]::IsNullOrWhiteSpace($LanguageOut) ? $LanguageIn :
                $LanguageOut

            $langCode = (GenXdev.Helpers\Get-WebLanguageDictionary)[$lang]

            if ($null -ne $langCode) {

                $lang = $langCode
            }

            $newPath = [IO.Path]::ChangeExtension($PSItem.FullName, ".$lang.srt")

            # handle legacy Dutch subtitle file naming convention
            if ([io.file]::Exists($nlPathOld)) {

                if ([io.file]::Exists($nlPath)) {

                    $null = Microsoft.PowerShell.Management\Remove-Item $nlPathOld `
                        -Force
                }
                else {

                    $null = Microsoft.PowerShell.Management\Move-Item $nlPathOld `
                        $nlPath -Force
                }
            }

            # handle legacy English subtitle file naming convention
            if ([io.file]::Exists($enPathOld)) {

                if ([io.file]::Exists($enPath)) {

                    $null = Microsoft.PowerShell.Management\Remove-Item $enPathOld `
                        -Force
                }
                else {

                    $null = Microsoft.PowerShell.Management\Move-Item $enPathOld `
                        $enPath -Force
                }
            }

            # skip if subtitle file already exists for target language
            if ([io.file]::Exists($newPath)) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Subtitle file " +
                    "already exists: $newPath")

                return
            }

            try {

                # reduce CPU priority to minimize system impact during processing
                [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass =
                    [System.Diagnostics.ProcessPriorityClass]::Idle

                try {

                    Microsoft.PowerShell.Utility\Write-Verbose ("Generating " +
                        "transcription for: $($PSItem.FullName)")

                    # prepare parameters for transcription generation
                    $params = @{
                        FilePath                    = $PSItem.FullName
                        SRT                         = $true
                        MaxTokensPerSegment         = 20
                        CpuThreads                  = 4
                        TranslateUsingLMStudioModel = $TranslateUsingLMStudioModel
                    }

                    # add source language if specified
                    if (-not [String]::IsNullOrWhiteSpace($LanguageIn)) {

                        $params += @{ LanguageIn = $LanguageIn }
                    }

                    # add target language if translation requested
                    if (-not [String]::IsNullOrWhiteSpace($LanguageOut)) {

                        $params += @{ LanguageOut = $LanguageOut }
                    }

                    # generate transcription using whisper model
                    $transcription = GenXdev.AI\Get-MediaFileAudioTranscription `
                        @params
                }
                finally {

                    # restore normal CPU priority after processing
                    [System.Diagnostics.Process]::GetCurrentProcess().PriorityClass =
                        [System.Diagnostics.ProcessPriorityClass]::Normal
                }
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Verbose ("Failed to process " +
                    "file: $($PSItem.FullName)")

                Microsoft.PowerShell.Utility\Write-Verbose ("Error details: " +
                    "$PSItem")

                return
            }

            # save generated transcription to subtitle file
            $null = $transcription |
                Microsoft.PowerShell.Utility\Out-File $newPath -Force

            Microsoft.PowerShell.Utility\Write-Verbose ("Transcription saved " +
                "to: $newPath")

            $transcription
        }
    }

    end {

        # restore original working directory
        Microsoft.PowerShell.Management\Pop-Location

        Microsoft.PowerShell.Utility\Write-Verbose ("Original working directory " +
            "restored")
    }
}
################################################################################