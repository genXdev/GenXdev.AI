<##############################################################################
Part of PowerShell module : GenXdev.AI.Queries
Original cmdlet filename  : Invoke-QueryImageContent.ps1
Original author           : René Vaessen / GenXdev
Version                   : 1.286.2025
################################################################################
MIT License

Copyright 2021-2025 GenXdev

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
################################################################################>
###############################################################################
<#
.SYNOPSIS
Analyzes image content using AI vision capabilities through the LM-Studio API.

.DESCRIPTION
Processes images using a specified model via the LM-Studio API to analyze
content and answer queries about the image. The function supports various
analysis parameters including temperature control for response randomness and
token limits for output length.

.PARAMETER Query
Specifies the question or prompt to analyze the image content. This drives the
AI's analysis focus and determines what aspects of the image to examine.

.PARAMETER ImagePath
The path to the image file for analysis. Supports both relative and absolute
paths. The file must exist and be accessible.

.PARAMETER Instructions
System instructions for the model to follow during the analysis.

.PARAMETER ResponseFormat
A JSON schema that specifies the requested output format for the response.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Lower values (closer
to 0) produce more focused and deterministic responses, while higher values
increase creativity and variability. Valid range: 0.0 to 1.0.

.PARAMETER ImageDetail
Sets the detail level for image analysis.
Valid values are "low", "medium", or "high".

.PARAMETER LLMQueryType
The type of LLM query to perform. Defaults to "Pictures" for image analysis.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER HuggingFaceIdentifier
The LM Studio specific model identifier.

.PARAMETER MaxToken
The maximum number of tokens to use in AI operations.

.PARAMETER Cpu
The number of CPU cores to dedicate to AI operations.

.PARAMETER Gpu
Specifies how much of the model to offload to the GPU.
- "off": Disables GPU offloading.
- "max": Offloads all layers to the GPU.
- 0 to 1: Offloads a fraction of layers to the GPU.
- -1: Lets LM Studio decide the offload amount.
- -2: Uses an automatic setting.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.PARAMETER ShowWindow
If specified, the LM Studio window will be shown.

.PARAMETER Force
If specified, forces LM Studio to stop before initialization.

.PARAMETER IncludeThoughts
If specified, includes the model's thoughts in the output.

.EXAMPLE
Invoke-QueryImageContent `
    -Query "What objects are in this image?" `
    -ImagePath "C:\Images\sample.jpg" `
    -Temperature 0.01 `
    -MaxToken 100

Analyzes an image with specific temperature and token limits.

.EXAMPLE
Query-Image "Describe this image" "C:\Images\photo.jpg"

Simple image analysis using alias and positional parameters.
#>
###############################################################################
function Invoke-QueryImageContent {

    [CmdletBinding()]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The query string for analyzing the image'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Query,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Path to the image file for analysis'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'System instructions for the model'
        )]
        [string] $Instructions,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'A JSON schema for the requested output format'
        )]
        [string] $ResponseFormat = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'high',
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The type of LLM query'
        )]
        [ValidateSet(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )]
        [string] $LLMQueryType = 'Pictures',
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The LM Studio specific model identifier'
        )]
        [Alias('ModelLMSGetIdentifier')]
        [string] $HuggingFaceIdentifier,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The maximum number of tokens to use in AI operations'
        )]
        [int] $MaxToken,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The number of CPU cores to dedicate to AI operations'
        )]
        [int] $Cpu,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("How much to offload to the GPU. If 'off', GPU " +
                "offloading is disabled. If 'max', all layers are " +
                'offloaded to GPU. If a number between 0 and 1, ' +
                'that fraction of layers will be offloaded to the ' +
                'GPU. -1 = LM Studio will decide how much to ' +
                'offload to the GPU. -2 = Auto')
        )]
        [ValidateRange(-2, 1)]
        [int] $Gpu = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the LM Studio window'
        )]
        [switch] $ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip LM-Studio initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoLMStudioInitialize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force stop LM Studio before initialization'
        )]
        [switch] $Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies the functions to use for the AI operation.'
        )]
        [string[]] $Functions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies the exposed cmdlets for the AI operation.'
        )]
        [string[]] $ExposedCmdLets,
        ###############################################################################
        [Alias('NoConfirmationFor')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies tool function names that do not require confirmation.'
        )]
        [string[]] $NoConfirmationToolFunctionNames,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Time-to-live in seconds for the AI operation.'
        )]
        [int] $TTLSeconds,
        ###############################################################################
        [Alias('m', 'mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies the monitor to use for display.'
        )]
        [int] $Monitor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Width for the display window.'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio response generation.'
        )]
        [double] $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for the response generation.'
        )]
        [double] $TemperatureResponse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The language for generated descriptions and ' +
                'keywords')
        )]
        [PSDefaultValue(Value = 'English')]
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu')]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use.'
        )]
        [int] $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress output.'
        )]
        [string] $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing.'
        )]
        [int] $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio processing.'
        )]
        [double] $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation.'
        )]
        [double] $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering.'
        )]
        [double] $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering.'
        )]
        [double] $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection.'
        )]
        [double] $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, do not speak the output.'
        )]
        [switch] $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "If specified, do not speak the model's thoughts."
        )]
        [switch] $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, disables VOX.'
        )]
        [switch] $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, use desktop audio capture.'
        )]
        [switch] $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, disables context usage.'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, use beam search sampling strategy.'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, only return responses.'
        )]
        [switch] $OnlyResponses,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Height for the display window.'
        )]
        [int] $Height,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys.'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "If specified, don't add thoughts to the history."
        )]
        [switch] $DontAddThoughtsToHistory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue the last conversation.'
        )]
        [switch] $ContinueLast,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Speak the output.'
        )]
        [switch] $Speak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Speak the model's thoughts."
        )]
        [switch] $SpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Output only markup blocks.'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for markup block types.'
        )]
        [string[]] $MarkupBlocksTypeFilter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, only chat once.'
        )]
        [switch] $ChatOnce,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable session caching.'
        )]
        [switch] $NoSessionCaching,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Unload after operation.'
        )]
        [switch] $Unload,
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable window borders.'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: left.'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: right.'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window position: bottom.'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window.'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window to full screen.'
        )]
        [switch] $FullScreen,
        ###############################################################################
        [Alias('rf', 'bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to the window.'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Display side by side.'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw', 'focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window.'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground.'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window.'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key.'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys.'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys.'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum callback length for tool calls.'
        )]
        [int] $MaxToolcallBackLength
    )
    begin {

        # log the initiation of the image analysis process
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Starting image analysis with query: $Query"

        # convert any relative or partial path to a full, absolute path for
        # reliability
        $imagePath = GenXdev.FileSystem\Expand-Path $ImagePath

        # ensure the specified image file exists before proceeding with the
        # analysis
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $imagePath)) {

            # if the file doesn't exist, throw a terminating error
            throw "Image file not found: $imagePath"
        }

        $actualPath = $imagePath
    }

    process {

        # log the start of the actual image processing step
        Microsoft.PowerShell.Utility\Write-Verbose ('Processing image: ' +
            "$imagePath")


        if ([IO.Path]::GetExtension($imagePath).ToLowerInvariant() -eq '.webp') {

            $actualPath = [IO.Path]::GetTempPath() + ".png"

            GenXdev.Helpers\EnsureNuGetAssembly -PackageKey "SixLabors.ImageSharp"
            GenXdev.Helpers\EnsureNuGetAssembly -PackageKey "Shorthand.ImageSharp.WebP"
            GenXdev.Helpers\EnsureNuGetAssembly -PackageKey "SixLabors.ImageSharp.Drawing"

            try {
                $webpImage = [SixLabors.ImageSharp.Image]::Load($ImagePath)
                try {
                    # Use Save method with PNG encoder
                    $pngEncoder = [SixLabors.ImageSharp.Formats.Png.PngEncoder]::new()
                    $fileStream = [System.IO.File]::Create($actualPath)
                    try {
                        $webpImage.Save($fileStream, $pngEncoder)
                    }
                    finally {
                        $fileStream.Close()
                    }
                }
                finally {
                    if ($webpImage -and ($webpImage -is [IDisposable])) {
                        $webpImage.Dispose()
                    }
                }
            }
            catch {
                $actualPath = $ImagePath
                Microsoft.PowerShell.Utility\Write-Warning "Error converting WebP to PNG: $($_.Exception.Message)"
            }
        }

        # construct a hashtable of parameters to be passed to the next function
        $parameters = GenXdev.Helpers\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev.AI\Invoke-LLMQuery' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope 'Local' `
                -ErrorAction SilentlyContinue)

        # add the image path to the attachments array for the llm query
        $parameters.Attachments = @($actualPath)

        # invoke the ai model with the constructed parameters and image analysis
        # configuration
        GenXdev.AI\Invoke-LLMQuery @parameters
    }

    end {

        if ($actualPath -ne $imagePath) {

            Microsoft.PowerShell.Utility\Write-Verbose "Removing temporary image file: $actualPath"
            Microsoft.PowerShell.Management\Remove-Item -LiteralPath $actualPath -Force -ErrorAction SilentlyContinue
        }
    }
}
###############################################################################