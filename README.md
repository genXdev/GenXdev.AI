<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME
    GenXdev.AI
### SYNOPSIS
    A Windows PowerShell module for local AI related operations
[![GenXdev.AI](https://img.shields.io/powershellgallery/v/GenXdev.AI.svg?style=flat-square&label=GenXdev.AI)](https://www.powershellgallery.com/packages/GenXdev.AI/) [![License](https://img.shields.io/github/license/genXdev/GenXdev.AI?style=flat-square)](./LICENSE)

## MIT License

```text
MIT License

Copyright (c) [year] [fullname]

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
````

### FEATURES
* ✅ Local Large Language Model (LLM) Integration
     * Perform AI operations through OpenAI-compatible chat completion endpoints with `Invoke-LLMQuery` -> `llm`, `qllm`, `qlms`
     * Seamless `LM Studio` integration with automatic installation and model management
     * Expose PowerShell cmdlets as tool functions to LLM models with user-controlled execution
     * Interactive text chat sessions with `New-LLMTextChat` -> `llmchat`
     * AI-powered command suggestions with `Invoke-AIPowershellCommand` -> `hint`
     * Secure execution model with mandatory user confirmation for system-modifying operations

* ✅ Audio and Speech Processing
     * Transcribe audio/video files using `Whisper AI` model with `Get-MediaFileAudioTranscription` -> `transcribefile`
     * Interactive audio chat sessions with `New-LLMAudioChat` -> `llmaudiochat`
     * Real-time audio transcription with `Start-AudioTranscription` -> `transcribe`
     * Generate subtitle files for media content using `Save-Transcriptions`
     * Record and process spoken audio with default input devices

* ✅ Advanced Image Intelligence and Database System
     * Uses Docker-integrated DeepStack services for face recognition, object detection, and scene analysis and `LM Studio` and model `MiniCPM` to update image metadata, all locally
     * Manually Schedule-Tasks for `Update-AllImageMetaData` and `Export-ImageDatabase` to
     update all AI generated metadata for quick access later
     * Comprehensive AI-powered image analysis with face recognition, object detection, and scene classification
     * High-performance SQLite database indexing with `Export-ImageDatabase` -> `indexcachedimages` for instant searches
     * Lightning-fast indexed image search with `Find-IndexedImage` -> `findindexedimages`, `lii` using optimized database queries
     * Image search functions `li`, `lii` have the -ShowInBrowser and -Interactive switches that allow you
       to show your collection in a masonry layout inside your webbrowser.
       The -Interactive switch parameter provides Edit and Delete buttons.
     * Update-AllMetaData uses alternative ntfs streams inside the imagefile itself
     these are preserved during file operations using `Windows Explorer` or
     robocopy ->  Start-RoboCopy, `xc`
     * Traditional file-based image search with `Find-Image` -> `findimages`, `li`
     * Multi-language support for image descriptions and keywords with automatic AI generation
     * Interactive image galleries with masonry layouts, metadata tooltips, and responsive design using `Show-FoundImagesInBrowser` -> showfoundimages
     * **Parameter Logic**: Both `Find-Image` and `Find-IndexedImage` use:
        - **OR within arrays**: `-Keywords "cat","dog"` finds images with cat OR dog
        - **AND between parameter types**: `-Keywords "cat" -People "John"` finds images with cat AND John
        - Use pipeline `|` for additional post-filtering when needed
     * Use `Set-AIImageCollection`, `Set-AIKnownFacesRootpath` and `Set-AIMetaLanguage` for setting up your preferences
     * [Check out this getting-started documentation](https://github.com/genXdev/GenXdev.AI/tree/main/Functions/GenXdev.AI.DeepStack#readme)

* ✅ Text Processing and Enhancement
     * Add contextual emoticons with `Add-EmoticonsToText` -> `emojify`
     * Translate text between languages with `Get-TextTranslation` -> `translate`
     * AI-powered text transformation with `Invoke-LLMTextTransformation` -> `spellcheck`
     * Extract string lists and evaluate statements with:
          * `Invoke-LLMStringListEvaluation` -> `getlist`
          * `Invoke-LLMBooleanEvaluation` -> `equalstrue`

* ✅ Development Tools and Utilities
     * Interactive file comparison with WinMerge integration
     * Automatic GPU capability detection
     * CPU core management and optimization
     * Vector similarity calculations for AI operations
     * Custom command-not-found handling with AI assistance

### DEPENDENCIES
[![WinOS - Windows-10 or later](https://img.shields.io/badge/WinOS-Windows--10--10.0.19041--SP0-brightgreen)](https://www.microsoft.com/en-us/windows/get-windows-10)  [![GenXdev.Data](https://img.shields.io/powershellgallery/v/GenXdev.Data.svg?style=flat-square&label=GenXdev.Data)](https://www.powershellgallery.com/packages/GenXdev.Data/)  [![GenXdev.Helpers](https://img.shields.io/powershellgallery/v/GenXdev.Helpers.svg?style=flat-square&label=GenXdev.Helpers)](https://www.powershellgallery.com/packages/GenXdev.Helpers/) [![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![GenXdev.Queries](https://img.shields.io/powershellgallery/v/GenXdev.Queries.svg?style=flat-square&label=GenXdev.Queries)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![GenXdev.Console](https://img.shields.io/powershellgallery/v/GenXdev.Console.svg?style=flat-square&label=GenXdev.Console)](https://www.powershellgallery.com/packages/GenXdev.Console/)  [![GenXdev.FileSystem](https://img.shields.io/powershellgallery/v/GenXdev.FileSystem.svg?style=flat-square&label=GenXdev.FileSystem)](https://www.powershellgallery.com/packages/GenXdev.FileSystem/)
### INSTALLATION
````PowerShell
Install-Module "GenXdev.AI"
Import-Module "GenXdev.AI"
````
### UPDATE
````PowerShell
Update-Module
````
<br/><hr/><hr/><br/>

# Cmdlet Index
### GenXdev.AI<hr/>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description                                                                             |
| ------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------- | --------------------------------------------------------------------------------------- |
| [Approve-NewTextFileContent](#Approve-NewTextFileContent)                                                     |                                                               | Interactive file content comparison and approval using WinMerge.                        |
| [Convert-DotNetTypeToLLMType](#Convert-DotNetTypeToLLMType)                                                   |                                                               | Converts .NET type names to LLM (Language Model) type names.                            |
| [ConvertTo-LMStudioFunctionDefinition](#ConvertTo-LMStudioFunctionDefinition)                                 |                                                               | Converts PowerShell functions to LMStudio function definitions.                         |
| [EnsureGithubCLIInstalled](#EnsureGithubCLIInstalled)                                                         |                                                               | Ensures GitHub CLI is properly installed and configured on the system.                  |
| [EnsurePaintNet](#EnsurePaintNet)                                                                             |                                                               | Ensures Paint.NET is properly installed and accessible on the system.                   |
| [EnsureWinMergeInstalled](#EnsureWinMergeInstalled)                                                           |                                                               | Ensures WinMerge is installed and available for file comparison operations.             |
| [GenerateMasonryLayoutHtml](#GenerateMasonryLayoutHtml)                                                       | nometadata, onlypictures                                      | Generates a responsive masonry layout HTML gallery from image data.                     |
| [Get-AIDefaultLLMSettings](#Get-AIDefaultLLMSettings)                                                         |                                                               | Gets all available default LLM settings configurations for AI operations in GenXdev.AI. |
| [Get-AILLMSettings](#Get-AILLMSettings)                                                                       |                                                               | Gets the LLM settings for AI operations in GenXdev.AI.                                  |
| [Get-CpuCore](#Get-CpuCore)                                                                                   |                                                               | Calculates and returns the total number of logical CPU cores in the system.             |
| [Get-HasCapableGpu](#Get-HasCapableGpu)                                                                       |                                                               | Determines if a CUDA-capable GPU with sufficient memory is present.                     |
| [Get-NumberOfCpuCores](#Get-NumberOfCpuCores)                                                                 |                                                               | Calculates and returns the total number of logical CPU cores in the system.             |
| [Get-TextTranslation](#Get-TextTranslation)                                                                   | translate                                                     | Translates text to another language using AI.                                           |
| [Get-VectorSimilarity](#Get-VectorSimilarity)                                                                 |                                                               |                                                                                         |
| [Invoke-CommandFromToolCall](#Invoke-CommandFromToolCall)                                                     |                                                               | Executes a tool call function with validation and parameter filtering.                  |
| [Invoke-LLMBooleanEvaluation](#Invoke-LLMBooleanEvaluation)                                                   | equalstrue                                                    | Evaluates a statement using AI to determine if it's true or false.                      |
| [Invoke-LLMQuery](#Invoke-LLMQuery)                                                                           | qllm, llm, invoke-lmstudioquery, qlms                         |                                                                                         |
| [Invoke-LLMStringListEvaluation](#Invoke-LLMStringListEvaluation)                                             | getlist                                                       |                                                                                         |
| [Invoke-LLMTextTransformation](#Invoke-LLMTextTransformation)                                                 | spellcheck                                                    | Transforms text using AI-powered processing.                                            |
| [Invoke-WinMerge](#Invoke-WinMerge)                                                                           |                                                               | Launches WinMerge to compare two files side by side.                                    |
| [New-LLMAudioChat](#New-LLMAudioChat)                                                                         | llmaudiochat                                                  | Creates an interactive audio chat session with an LLM model.                            |
| [New-LLMTextChat](#New-LLMTextChat)                                                                           | llmchat                                                       | Starts an interactive text chat session with AI capabilities.                           |
| [Set-AILLMSettings](#Set-AILLMSettings)                                                                       |                                                               | Sets the LLM settings for AI operations in GenXdev.AI.                                  |
| [Set-GenXdevAICommandNotFoundAction](#Set-GenXdevAICommandNotFoundAction)                                     |                                                               | Sets up custom command not found handling with AI assistance.                           |
| [Start-GenXdevMCPServer](#Start-GenXdevMCPServer)                                                             |                                                               | Starts the GenXdev MCP server that exposes PowerShell cmdlets as tools.                 |
| [Test-DeepLinkImageFile](#Test-DeepLinkImageFile)                                                             |                                                               | Tests if the specified file path is a valid image file with a supported format.         |

<hr/>
&nbsp;

### GenXdev.AI.DeepStack</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description                                                                    |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------ |
| [Compare-ImageFaces](#Compare-ImageFaces)                                                                           | comparefaces                                                        | Processes the face match result from DeepStack API.                            |
| [EnsureDeepStack](#EnsureDeepStack)                                                                                 |                                                                     | Ensures DeepStack face recognition service is installed and running.           |
| [Get-ImageDetectedFaces](#Get-ImageDetectedFaces)                                                                   |                                                                     |                                                                                |
| [Get-ImageDetectedObjects](#Get-ImageDetectedObjects)                                                               |                                                                     | Detects and classifies objects in an uploaded image using DeepStack.           |
| [Get-ImageDetectedScenes](#Get-ImageDetectedScenes)                                                                 |                                                                     | Classifies an image into one of 365 scene categories using DeepStack.          |
| [Get-RegisteredFaces](#Get-RegisteredFaces)                                                                         |                                                                     | Retrieves a list of all registered face identifiers from DeepStack.            |
| [Invoke-ImageEnhancement](#Invoke-ImageEnhancement)                                                                 | enhanceimage                                                        | Enhances an image by enlarging it 4X while improving quality using DeepStack.  |
| [Register-AllFaces](#Register-AllFaces)                                                                             | updatefaces                                                         | Updates all face recognition profiles from image files in the faces directory. |
| [Register-Face](#Register-Face)                                                                                     |                                                                     | Registers a new face with the DeepStack face recognition API.                  |
| [Unregister-AllFaces](#Unregister-AllFaces)                                                                         |                                                                     | Removes all registered faces from the DeepStack face recognition system.       |
| [Unregister-Face](#Unregister-Face)                                                                                 |                                                                     | Deletes a registered face by its identifier from DeepStack.                    |

<hr/>
&nbsp;

### GenXdev.AI.LMStudio</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description                                                            |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ---------------------------------------------------------------------- |
| [Add-GenXdevMCPServerToLMStudio](#Add-GenXdevMCPServerToLMStudio)                                                   |                                                                     |                                                                        |
| [EnsureLMStudio](#EnsureLMStudio)                                                                                   |                                                                     | Ensures LM Studio is properly initialized with the specified model.    |
| [Get-LMStudioLoadedModelList](#Get-LMStudioLoadedModelList)                                                         |                                                                     | Retrieves the list of currently loaded models from LM Studio.          |
| [Get-LMStudioModelList](#Get-LMStudioModelList)                                                                     |                                                                     | Retrieves a list of installed LM Studio models.                        |
| [Get-LMStudioPaths](#Get-LMStudioPaths)                                                                             |                                                                     | Retrieves file paths for LM Studio executables.                        |
| [Get-LMStudioTextEmbedding](#Get-LMStudioTextEmbedding)                                                             | embed-text, get-textembedding                                       | Gets text embeddings from LM Studio model.                             |
| [Get-LMStudioWindow](#Get-LMStudioWindow)                                                                           | lmstudiowindow, setlmstudiowindow                                   | Gets a window helper for the LM Studio application.                    |
| [Initialize-LMStudioModel](#Initialize-LMStudioModel)                                                               | initlmstudio                                                        | Initializes and loads an AI model in LM Studio.                        |
| [Install-LMStudioApplication](#Install-LMStudioApplication)                                                         |                                                                     | Installs LM Studio application using WinGet package manager.           |
| [Start-LMStudioApplication](#Start-LMStudioApplication)                                                             |                                                                     | Starts the LM Studio application if it's not already running.          |
| [Test-LMStudioInstallation](#Test-LMStudioInstallation)                                                             |                                                                     | Tests if LMStudio is installed and accessible on the system.           |
| [Test-LMStudioProcess](#Test-LMStudioProcess)                                                                       |                                                                     | Tests if LM Studio process is running and configures its window state. |

<hr/>
&nbsp;

### GenXdev.AI.Queries</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description                                                                          |
| ------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------- | ------------------------------------------------------------------------------------ |
| [Add-EmoticonsToText](#Add-EmoticonsToText)                                                                         | emojify                                                             | Enhances text by adding contextually appropriate emoticons using AI.                 |
| [Add-ImageDirectories](#Add-ImageDirectories)                                                                       | addimgdir                                                           | Adds directories to the configured image directories for GenXdev.AI operations.      |
| [ConvertFrom-CorporateSpeak](#ConvertFrom-CorporateSpeak)                                                           | uncorporatize                                                       | Converts polite, professional corporate speak into direct, clear language using AI.  |
| [ConvertFrom-DiplomaticSpeak](#ConvertFrom-DiplomaticSpeak)                                                         | undiplomatize                                                       |                                                                                      |
| [ConvertTo-CorporateSpeak](#ConvertTo-CorporateSpeak)                                                               | corporatize                                                         | Converts direct or blunt text into polite, professional corporate speak using AI.    |
| [ConvertTo-DiplomaticSpeak](#ConvertTo-DiplomaticSpeak)                                                             | diplomatize                                                         | Converts direct or blunt text into polite, tactful diplomatic language.              |
| [Export-ImageDatabase](#Export-ImageDatabase)                                                                       | indexcachedimages, inititalize-imagedatabase, recreate-imageindex   | Initializes and populates the SQLite database by discovering images directly.        |
| [Find-Image](#Find-Image)                                                                                           | findimages, li                                                      |                                                                                      |
| [Find-IndexedImage](#Find-IndexedImage)                                                                             | findindexedimages, lii                                              | Searches for images using an optimized SQLite database with fast indexed lookups.    |
| [Get-AIImageCollection](#Get-AIImageCollection)                                                                     | getimgdirs                                                          | Gets the configured directories for image files used in GenXdev.AI operations.       |
| [Get-AIKnownFacesRootpath](#Get-AIKnownFacesRootpath)                                                               |                                                                     |                                                                                      |
| [Get-AIMetaLanguage](#Get-AIMetaLanguage)                                                                           | getimgmetalang                                                      | Gets the configured default language for image metadata operations.                  |
| [Get-Fallacy](#Get-Fallacy)                                                                                         | dispicetext                                                         | Analyzes text to identify logical fallacies using AI-powered detection.              |
| [Get-ImageDatabasePath](#Get-ImageDatabasePath)                                                                     |                                                                     | Returns the path to the image database, initializing or rebuilding it if needed.     |
| [Get-ImageDatabaseStats](#Get-ImageDatabaseStats)                                                                   | getimagedbstats, gids                                               | Retrieves comprehensive statistics and information about the image database.         |
| [Get-MediaFileAudioTranscription](#Get-MediaFileAudioTranscription)                                                 | transcribefile                                                      | Transcribes an audio or video file to text.                                          |
| [Get-ScriptExecutionErrorFixPrompt](#Get-ScriptExecutionErrorFixPrompt)                                             | getfixprompt                                                        | Captures error messages from various streams and uses LLM to suggest fixes.          |
| [Get-SimularMovieTitles](#Get-SimularMovieTitles)                                                                   |                                                                     | Finds similar movie titles based on common properties.                               |
| [Invoke-AIPowershellCommand](#Invoke-AIPowershellCommand)                                                           | hint                                                                | Converts AI command suggestions to JSON format for processing.                       |
| [Invoke-ImageFacesUpdate](#Invoke-ImageFacesUpdate)                                                                 | facerecognition                                                     | Updates face recognition metadata for image files in a specified directory.          |
| [Invoke-ImageKeywordUpdate](#Invoke-ImageKeywordUpdate)                                                             | updateimages                                                        | Updates image metadata with AI-generated descriptions and keywords.                  |
| [Invoke-ImageMetadataUpdate](#Invoke-ImageMetadataUpdate)                                                           | updateimagemetadata                                                 | Updates EXIF metadata for images in a directory.                                     |
| [Invoke-ImageObjectsUpdate](#Invoke-ImageObjectsUpdate)                                                             | objectdetection                                                     | Updates object detection metadata for image files in a specified directory.          |
| [Invoke-ImageScenesUpdate](#Invoke-ImageScenesUpdate)                                                               | scenerecognition                                                    | Updates scene classification metadata for image files in a specified directory.      |
| [Invoke-QueryImageContent](#Invoke-QueryImageContent)                                                               | query-image                                                         | Analyzes image content using AI vision capabilities through the LM-Studio API.       |
| [Remove-ImageDirectories](#Remove-ImageDirectories)                                                                 | removeimgdir                                                        | Removes directories from the configured image directories for GenXdev.AI operations. |
| [Remove-ImageMetaData](#Remove-ImageMetaData)                                                                       | removeimagedata                                                     | Removes image metadata files from image directories.                                 |
| [Save-FoundImageFaces](#Save-FoundImageFaces)                                                                       | saveimagefaces                                                      | Saves cropped face images from indexed image search results.                         |
| [Save-FoundImageObjects](#Save-FoundImageObjects)                                                                   | saveimageobjects                                                    | Saves cropped object images from indexed image search results to files.              |
| [Save-Transcriptions](#Save-Transcriptions)                                                                         |                                                                     | Generates subtitle files for audio and video files using OpenAI Whisper.             |
| [Set-AIImageCollection](#Set-AIImageCollection)                                                                     |                                                                     |                                                                                      |
| [Set-AIKnownFacesRootpath](#Set-AIKnownFacesRootpath)                                                               |                                                                     | Sets the directory for face image files used in GenXdev.AI operations.               |
| [Set-AIMetaLanguage](#Set-AIMetaLanguage)                                                                           |                                                                     |                                                                                      |
| [Set-ImageDatabasePath](#Set-ImageDatabasePath)                                                                     |                                                                     | Sets the default database file path for image operations in GenXdev.AI.              |
| [Set-WindowsWallpaperEx](#Set-WindowsWallpaperEx)                                                                   | nextwallpaper                                                       | Sets a random wallpaper from a specified directory or search criteria.               |
| [Show-FoundImagesInBrowser](#Show-FoundImagesInBrowser)                                                             | showfoundimages                                                     | Displays image search results in a masonry layout web gallery.                       |
| [Show-GenXdevScriptErrorFixInIde](#Show-GenXdevScriptErrorFixInIde)                                                 | letsfixthis                                                         | Executes a script block and analyzes errors using AI to generate fixes in IDE.       |
| [Start-AudioTranscription](#Start-AudioTranscription)                                                               | transcribe, recordandtranscribe                                     |                                                                                      |
| [Update-AllImageMetaData](#Update-AllImageMetaData)                                                                 | updateallimages                                                     |                                                                                      |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.AI<hr/>
NAME
    Approve-NewTextFileContent

SYNOPSIS
    Interactive file content comparison and approval using WinMerge.


SYNTAX
    Approve-NewTextFileContent [-ContentPath] <String> [[-Monitor] <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AcceptLang <String>] [-Force] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-Private] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-NewWindow] [-FocusWindow] [-SetForeground] [-Maximize] [-PassThru] [-NoBorders] [-RestoreFocus] [-SideBySide] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    Facilitates content comparison and merging through WinMerge by creating a
    temporary file with proposed changes. The user can interactively review and
    modify changes before approving. Returns approval status and final content.


PARAMETERS
    -ContentPath <String>
        The path to the target file for comparison and potential update. If the file
        doesn't exist, it will be created.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>

        Required?                    false
        Position?                    2
        Default value                -2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>

        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>

        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AcceptLang <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Edge [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chrome [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chromium [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Firefox [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -All [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Private [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApplicationMode [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBrowserExtensions [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DisablePopupBlocker [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NewWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        Returns a hashtable with these properties:
        - approved: True if changes were saved, False if discarded
        - approvedAsIs: True if content was accepted without modifications
        - savedContent: Final content if modified by user
        - userDeletedFile: True if user deleted existing file

    -------------------------- EXAMPLE 1 --------------------------

    PS > $result = Approve-NewTextFileContent -ContentPath "C:\temp\myfile.txt" `
        -NewContent "New file content"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Convert-DotNetTypeToLLMType

SYNOPSIS
    Converts .NET type names to LLM (Language Model) type names.


SYNTAX
    Convert-DotNetTypeToLLMType [-DotNetType] <String> [<CommonParameters>]


DESCRIPTION
    This function takes a .NET type name as input and returns the corresponding
    simplified type name used in Language Models. It handles common .NET types
    and provides appropriate type mappings.


PARAMETERS
    -DotNetType <String>
        The .NET type name to convert to an LLM type name.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Convert-DotNetTypeToLLMType -DotNetType "System.String"
    Returns: "string"






    -------------------------- EXAMPLE 2 --------------------------

    PS > Convert-DotNetTypeToLLMType "System.Collections.Generic.List``1"
    Returns: "object"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    ConvertTo-LMStudioFunctionDefinition

SYNTAX
    ConvertTo-LMStudioFunctionDefinition [[-ExposedCmdLets] <ExposedCmdletDefinition[]>] [<CommonParameters>]


PARAMETERS
    -ExposedCmdLets <ExposedCmdletDefinition[]>
        PowerShell commands to convert to tool functions

        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).


INPUTS
    GenXdev.Helpers.ExposedCmdletDefinition[]


OUTPUTS
    System.Collections.Generic.List`1[[System.Collections.Hashtable, System.Private.CoreLib, Version=9.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]


ALIASES
    None


REMARKS
    None

<br/><hr/><hr/><br/>

NAME
    EnsureGithubCLIInstalled

SYNOPSIS
    Ensures GitHub CLI is properly installed and configured on the system.


SYNTAX
    EnsureGithubCLIInstalled [<CommonParameters>]


DESCRIPTION
    Performs comprehensive checks and setup for GitHub CLI (gh):
    - Verifies if GitHub CLI is installed and accessible in PATH
    - Installs GitHub CLI via WinGet if not present
    - Configures system PATH environment variable
    - Installs GitHub Copilot extension
    - Sets up GitHub authentication
    The function handles all prerequisites and ensures a working GitHub CLI setup.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > EnsureGithubCLIInstalled
    This will verify and setup GitHub CLI if needed.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    EnsurePaintNet

SYNOPSIS
    Ensures Paint.NET is properly installed and accessible on the system.


SYNTAX
    EnsurePaintNet [<CommonParameters>]


DESCRIPTION
    Performs comprehensive checks and setup for Paint.NET:
    - Verifies if Paint.NET is installed and accessible in PATH
    - Installs Paint.NET via WinGet if not present
    - Configures system PATH environment variable
    - Ensures paintdotnet.exe is available for command-line usage
    The function handles all prerequisites and ensures a working Paint.NET installation.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > EnsurePaintNet
    This will verify and setup Paint.NET if needed.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    EnsureWinMergeInstalled

SYNOPSIS
    Ensures WinMerge is installed and available for file comparison operations.


SYNTAX
    EnsureWinMergeInstalled [<CommonParameters>]


DESCRIPTION
    Verifies if WinMerge is installed and properly configured in the system PATH.
    If not found, installs WinMerge using WinGet and adds it to the user's PATH.
    Handles the complete installation and configuration process automatically.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > EnsureWinMergeInstalled
    Ensures WinMerge is installed and properly configured.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    GenerateMasonryLayoutHtml

SYNOPSIS
    Generates a responsive masonry layout HTML gallery from image data.


SYNTAX
    GenerateMasonryLayoutHtml [-Images] <Array> [[-FilePath] <String>] [-Title <String>] [-Description <String>] [-CanEdit] [-CanDelete] [-EmbedImages] [-ShowOnlyPictures] [-AutoScrollPixelsPerSecond <Int32>] [-AutoAnimateRectangles] [-SingleColumnMode] [-ImageUrlPrefix <String>] [-PageSize <Int32>] [-MaxPrintImages <Int32>] [-RootMargin <String>] [-Threshold <Double>] [<CommonParameters>]


DESCRIPTION
    Creates an interactive HTML gallery with responsive masonry grid layout for
    displaying images. Features include:
    - Responsive grid layout that adapts to screen size
    - Image tooltips showing descriptions and keywords
    - Click-to-copy image path functionality
    - Clean modern styling with hover effects


PARAMETERS
    -Images <Array>
        Array of image objects containing metadata. Each object requires:
        - path: String with full filesystem path to image
        - keywords: String array of descriptive tags
        - description: Object containing short_description and long_description

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -FilePath <String>
        Optional output path for the HTML file. If omitted, returns HTML as string.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Title <String>

        Required?                    false
        Position?                    named
        Default value                Photo Gallery
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Description <String>

        Required?                    false
        Position?                    named
        Default value                Hover over images to see face recognition, object detection, and scene classification data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CanEdit [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CanDelete [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowOnlyPictures [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoScrollPixelsPerSecond <Int32>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoAnimateRectangles [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SingleColumnMode [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageUrlPrefix <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PageSize <Int32>

        Required?                    false
        Position?                    named
        Default value                20
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxPrintImages <Int32>

        Required?                    false
        Position?                    named
        Default value                50
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RootMargin <String>

        Required?                    false
        Position?                    named
        Default value                1200px
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Threshold <Double>

        Required?                    false
        Position?                    named
        Default value                0.1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Create gallery from image array and save to file
    $images = @(
        @{
            path = "C:\photos\sunset.jpg"
            keywords = @("nature", "sunset", "landscape")
            description = @{
                short_description = "Mountain sunset"
                long_description = "Beautiful sunset over mountain range"
            }
        }
    )
    GenerateMasonryLayoutHtml -Images $images -FilePath "C:\output\gallery.html"






    -------------------------- EXAMPLE 2 --------------------------

    PS > Generate HTML string without saving
    $html = GenerateMasonryLayoutHtml $images







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-AIDefaultLLMSettings

SYNOPSIS
    Gets all available default LLM settings configurations for AI operations in GenXdev.AI.


SYNTAX
    Get-AIDefaultLLMSettings [[-LLMQueryType] <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-TTLSeconds <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-AutoSelect] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function retrieves all available LLM (Large Language Model) configurations
    from the default settings JSON file. It supports the same filtering and memory
    selection logic as Get-AILLMSettings, but returns all matching configurations
    instead of just one selected co                } else {
                        # use system RAM for memory checking
                        $memoryToCheck = [math]::Round(
                            (CimCmdlets\Get-CimInstance `
                                -Class Win32_OperatingSystem).TotalVisibleMemorySize / 1024 / 1024, 2
                        )
                        Microsoft.PowerShell.Utility\Write-Verbose "Using system RAM only: $memoryToCheck GB"
                    }ion.

    When used without -AutoSelect, it returns all configurations for the specified
    query type with their complete properties including RequiredMemoryGB.

    When used with -AutoSelect, it applies the same memory-based selection logic
    as Get-AILLMSettings and returns only the best matching configuration.

    Memory selection strategy is determined automatically based on the Gpu and Cpu
    parameters provided:
    - If both Gpu and Cpu parameters are specified: Uses combined CPU + GPU memory
    - If only Gpu parameter is specified: Prefers GPU memory (with system RAM fallback)
    - If only Cpu parameter is specified: Uses system RAM only
    - If neither parameter is specified: Uses combined CPU + GPU memory (default)


PARAMETERS
    -LLMQueryType <String>
        The type of LLM query to get settings for. This determines which default
        settings to use when no custom settings are found. Valid values include
        SimpleIntelligence, Knowledge, Pictures, TextTranslation, Coding, and ToolUse.

        Required?                    false
        Position?                    1
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        Filter configurations by model identifier or pattern.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        Filter configurations by LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        Filter configurations by maximum number of tokens.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations. Used for memory selection strategy.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        GPU offload level (-2=Auto through 1=Full). Used for memory selection strategy.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        Filter configurations by time-to-live in seconds for cached AI responses.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        Filter configurations by API endpoint URL.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        Filter configurations by API key.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        Filter configurations by timeout in seconds.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoSelect [<SwitchParameter>]
        When specified, applies memory-based auto-selection logic and returns only
        the best matching configuration based on available system memory. This makes
        the function behave like Get-AILLMSettings.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear the session setting (Global variable) before retrieving.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        When specified, skips session settings and retrieves only from persistent
        preferences or defaults.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Collections.Hashtable[]


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-AIDefaultLLMSettings -LLMQueryType "Coding"

    Gets all available default configurations for Coding query type.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-AIDefaultLLMSettings -LLMQueryType "Coding" -AutoSelect

    Gets the best configuration for Coding query type based on available memory.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-AIDefaultLLMSettings -LLMQueryType "Coding" -Cpu 8

    Gets all Coding configurations, with memory strategy set for CPU-only.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Get-AIDefaultLLMSettings -LLMQueryType "ToolUse" -AutoSelect -Gpu 2

    Gets the best ToolUse configuration based on GPU memory with offload level 2.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-AILLMSettings

SYNOPSIS
    Gets the LLM settings for AI operations in GenXdev.AI.


SYNTAX
    Get-AILLMSettings [[-LLMQueryType] <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-TTLSeconds <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function retrieves the LLM (Large Language Model) settings used by the
    GenXdev.AI module for various AI operations. Settings are retrieved from
    session variables, persistent preferences, or default settings JSON file, in
    that order of precedence. The function supports automatic configuration
    selection based on available system memory resources.

    Memory selection strategy is determined automatically based on the Gpu and Cpu
    parameters provided:
    - If both Gpu and Cpu parameters are specified: Uses combined CPU + GPU memory
    - If only Gpu parameter is specified: Prefers GPU memory (with system RAM fallback)
    - If only Cpu parameter is specified: Uses system RAM only
    - If neither parameter is specified: Uses combined CPU + GPU memory (default)


PARAMETERS
    -LLMQueryType <String>
        The type of LLM query to get settings for. This determines which default
        settings to use when no custom settings are found. Valid values include
        SimpleIntelligence, Knowledge, Pictures, TextTranslation, Coding, and ToolUse.

        Required?                    false
        Position?                    1
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        GPU offload level (-2=Auto through 1=Full).

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        The time-to-live in seconds for cached AI responses.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear the session setting (Global variable) before retrieving.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        When specified, skips session settings and retrieves only from persistent
        preferences or defaults. This is useful when you want to ignore any temporary
        session-level overrides.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Collections.Hashtable


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-AILLMSettings

    Gets the LLM settings for SimpleIntelligence query type (default).




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-AILLMSettings -LLMQueryType "Coding"

    Gets the LLM settings for Coding query type.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-AILLMSettings -Model "*custom*model*" -MaxToken 8192

    Gets LLM settings with specific model and token override parameters.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Get-AILLMSettings -Cpu 8 -Gpu 2 -TimeoutSeconds 300

    Gets LLM settings with specific CPU and GPU core counts and timeout override.




    -------------------------- EXAMPLE 5 --------------------------

    PS > Get-AILLMSettings -LLMQueryType "ToolUse" -Cpu 8

    Gets the LLM settings for ToolUse query type with 8 CPU cores specified.
    This will select the best configuration based on available system RAM.




    -------------------------- EXAMPLE 6 --------------------------

    PS > Get-AILLMSettings -LLMQueryType "Coding" -Gpu 2

    Gets the LLM settings for Coding query type with GPU offload level 2.
    This will select the best configuration based on available GPU RAM.




    -------------------------- EXAMPLE 7 --------------------------

    PS > Get-AILLMSettings -LLMQueryType "Pictures" -Cpu 4 -Gpu 1

    Gets the LLM settings for Pictures query type with both CPU and GPU specified.
    This will select the best configuration based on combined CPU + GPU memory.




    -------------------------- EXAMPLE 8 --------------------------

    PS > Get-AILLMSettings -SkipSession

    Gets the LLM settings from preferences or defaults only, ignoring session
    settings.




    -------------------------- EXAMPLE 9 --------------------------

    PS > Get-AILLMSettings "Knowledge"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-CpuCore

SYNOPSIS
    Calculates and returns the total number of logical CPU cores in the system.


SYNTAX
    Get-CpuCore [<CommonParameters>]


DESCRIPTION
    Queries the system hardware through Windows Management Instrumentation (WMI) to
    determine the total number of logical CPU cores. The function accounts for
    hyperthreading by multiplying the physical core count by 2.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get the total number of logical CPU cores
    $cores = Get-CpuCore
    Write-Host "System has $cores logical CPU cores available"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-HasCapableGpu

SYNOPSIS
    Determines if a CUDA-capable GPU with sufficient memory is present.


SYNTAX
    Get-HasCapableGpu [<CommonParameters>]


DESCRIPTION
    This function checks the system for CUDA-compatible GPUs with at least 4GB of
    video RAM. It uses Windows Management Instrumentation (WMI) to query installed
    video controllers and verify their memory capacity. This check is essential for
    AI workloads that require significant GPU memory.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    [bool] Returns true if a capable GPU is found, false otherwise.


    -------------------------- EXAMPLE 1 --------------------------

    PS > $hasGpu = Get-HasCapableGpu
    Write-Host "System has capable GPU: $hasGpu"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-NumberOfCpuCores

SYNOPSIS
    Calculates and returns the total number of logical CPU cores in the system.


SYNTAX
    Get-NumberOfCpuCores [<CommonParameters>]


DESCRIPTION
    Queries the system hardware through Windows Management Instrumentation (WMI) to
    determine the total number of logical CPU cores. The function accounts for
    hyperthreading by multiplying the physical core count by 2. This information is
    useful for optimizing parallel processing tasks and understanding system
    capabilities.

    The calculation process:
    1. Queries WMI for all physical processors
    2. Sums up the number of physical cores across all processors
    3. Multiplies by 2 to account for hyperthreading
    4. Returns the total logical core count


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        - Assumes all processors support hyperthreading
        - Requires WMI access permissions
        - Works on Windows systems only
        ##############################################################################

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get the total number of logical CPU cores
    $cores = Get-NumberOfCpuCores
    Write-Host "System has $cores logical CPU cores available"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-TextTranslation

SYNOPSIS
    Translates text to another language using AI.


SYNTAX
    Get-TextTranslation [[-Text] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function translates input text into a specified target language using AI
    models. It can accept input directly through parameters, from the pipeline, or
    from the system clipboard. The function preserves formatting and style while
    translating.


PARAMETERS
    -Text <String>
        The text to translate. Accepts pipeline input. If not provided, reads from system
        clipboard.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Controls response randomness (0.0-1.0). Lower values are more deterministic.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform for AI operations.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
        all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
        layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
        offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        Copy the translated text to clipboard.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Target language for translation. Supports 140+ languages including major world
        languages and variants.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-TextTranslation -Text "Hello world" -Language "French" -Model "qwen"






    -------------------------- EXAMPLE 2 --------------------------

    PS > "Bonjour" | translate -Language "English"
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-VectorSimilarity

SYNOPSIS
    Calculates the cosine similarity between two vectors, returning a value between
    0 and 1.


SYNTAX
    Get-VectorSimilarity [-Vector1] <Double[]> [-Vector2] <Double[]> [<CommonParameters>]


DESCRIPTION
    This function takes two numerical vectors (arrays) as input and computes their
    cosine similarity. The result indicates how closely related the vectors are,
    with 0 meaning completely dissimilar and 1 meaning identical.


PARAMETERS
    -Vector1 <Double[]>
        The first vector as an array of numbers (e.g., [0.12, -0.45, 0.89]). Must be
        the same length as Vector2.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Vector2 <Double[]>
        The second vector as an array of numbers (e.g., [0.15, -0.40, 0.92]). Must be
        the same length as Vector1.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Double


    -------------------------- EXAMPLE 1 --------------------------

    PS > $v1 = @(0.12, -0.45, 0.89)
    $v2 = @(0.15, -0.40, 0.92)
    Get-VectorSimilarity -Vector1 $v1 -Vector2 $v2
    Returns approximately 0.998, indicating high similarity







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-CommandFromToolCall

SYNOPSIS
    Executes a tool call function with validation and parameter filtering.


SYNTAX
    Invoke-CommandFromToolCall [-ToolCall] <Hashtable> [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-ForceAsText] [<CommonParameters>]


DESCRIPTION
    This function processes tool calls by validating arguments, filtering parameters,
    and executing callbacks with proper confirmation handling. It supports both script
    block and command info callbacks.


PARAMETERS
    -ToolCall <Hashtable>
        A hashtable containing the function details and arguments to be executed.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of function definitions that can be called as tools.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions available as tools.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of command names that can execute without user confirmation.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceAsText [<SwitchParameter>]
        Forces the output to be formatted as text.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-CommandFromToolCall -ToolCall $toolCall -Functions $functions `
        -ExposedCmdLets $exposedCmdlets






    -------------------------- EXAMPLE 2 --------------------------

    PS > $result = Invoke-CommandFromToolCall $toolCall $functions -ForceAsText







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-LLMBooleanEvaluation

SYNOPSIS
    Evaluates a statement using AI to determine if it's true or false.


SYNTAX
    Invoke-LLMBooleanEvaluation [[-Text] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function uses AI models to evaluate statements and determine their truth
    value. It can accept input directly through parameters, from the pipeline, or
    from the system clipboard. The function returns a boolean result along with
    confidence level and reasoning from the AI model.


PARAMETERS
    -Text <String>
        The statement to evaluate. If not provided, the function will read from the
        system clipboard.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        Instructions to guide the AI model in evaluating the statement. By default, it
        will determine if the statement is true or false.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>
        Array of file paths to attach to the AI query for additional context.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0). Controls creativity vs
        determinism in AI responses.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Image detail level for visual processing. Valid values are low, medium, or high.

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of function definitions for AI tool use capabilities.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools in AI operations.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of command names that don't require confirmation before execution.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to optimize for specific use cases.

        Required?                    false
        Position?                    named
        Default value                Knowledge
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier from Hugging Face.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU for AI processing.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        When specified, copies the result back to the system clipboard after processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]
        Include model's thoughts in output for debugging and transparency.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]
        Prevent model thoughts from being added to conversation history.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Continue from last conversation instead of starting fresh.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]
        Enable text-to-speech for AI responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]
        Enable text-to-speech for AI thought responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Don't store session in session cache for privacy or debugging.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]
        Allow the AI to use default tools and capabilities.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Boolean


    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-LLMBooleanEvaluation -Text "The Earth is flat" -Model "gpt-4"






    -------------------------- EXAMPLE 2 --------------------------

    PS > "Humans need oxygen to survive" | Invoke-LLMBooleanEvaluation






    -------------------------- EXAMPLE 3 --------------------------

    PS > equalstrue "2 + 2 = 4"
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-LLMQuery

SYNOPSIS
    Sends queries to an OpenAI compatible Large Language Chat completion API and
    processes responses.


SYNTAX
    Invoke-LLMQuery [[-Query] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-ResponseFormat <String>] [-Temperature <Double>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-ImageDetail <String>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-TTLSeconds <Int32>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-KeysToSend <String[]>] [-SendKeyDelayMilliSeconds <Int32>] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-ChatMode <String>] [-ChatOnce] [-NoSessionCaching] [-NoLMStudioInitialize] [-ShowWindow] [-Force] [-Unload] [-NoBorders] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function sends queries to an OpenAI compatible Large Language Chat
    completion API and processes responses. It supports text and image inputs,
    handles tool function calls, and can operate in various chat modes including
    text and audio.

    The function provides comprehensive support for LLM interaction including:
    - Text and image input processing
    - Tool function calling and command execution
    - Interactive chat modes (text and audio)
    - Model initialization and configuration
    - Response formatting and processing
    - Session management and caching
    - Window positioning and display control


PARAMETERS
    -Query <String>
        The text query to send to the model. Can be empty for chat modes.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        System instructions to provide context to the model.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>
        Array of file paths to attach to the query. Supports images and text files.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ResponseFormat <String>
        A JSON schema for the requested output format.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Controls response randomness (0.0-1.0). Lower values are more deterministic.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of function definitions that the model can call.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        PowerShell commands to expose as tools to the model.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Tool functions that don't require user confirmation.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Detail level for image processing (low/medium/high).

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to use for AI operations.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. Values range from -2 (Auto) to 1 (max).

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        Time-to-live in seconds for loaded models.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        The initial width of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        The initial height of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        The initial X position of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        The initial Y position of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Keystrokes to send to the Window, see documentation for cmdlet
        GenXdev.Windows\Send-Key.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between different input strings in milliseconds when sending keys.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]
        Include model's thought process in output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]
        Exclude thought processes from conversation history.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Continue from the last conversation context.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]
        Enable text-to-speech for AI responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]
        Enable text-to-speech for AI thought process.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]
        Only output markup block responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>
        Only output markup blocks of the specified types.

        Required?                    false
        Position?                    named
        Default value                @('json', 'powershell', 'C#',
                    'python', 'javascript', 'typescript', 'html', 'css', 'yaml',
                    'xml', 'bash')
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ChatMode <String>
        Enable interactive chat mode with specified input method.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ChatOnce [<SwitchParameter>]
        Internal parameter to control chat mode invocation.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Don't store session in session cache.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]
        Skip LM-Studio initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]
        Unloads the specified model instead of loading it.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Removes the borders of the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Place window on the left side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Place window on the right side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Place window on the top side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Place window on the bottom side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Place window in the center of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]
        Maximize the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell window focus.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Will either set the window fullscreen on a different monitor than PowerShell,
        or side by side with PowerShell on the same monitor.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Focus the window after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Set the window to foreground after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Maximize the window after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Escape control characters and modifiers when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Hold keyboard focus on target window when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Use Shift+Enter instead of Enter when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                100000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7

    Sends a simple mathematical query to the qwen model with specified temperature.




    -------------------------- EXAMPLE 2 --------------------------

    PS > qllm "What is 2+2?" -Model "qwen"

    Uses the alias to send a query with default parameters.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Invoke-LLMQuery -Query "Analyze this image" -Attachments @("image.jpg") -Model "qwen"

    Sends a query with an image attachment for analysis.




    -------------------------- EXAMPLE 4 --------------------------

    PS > llm "Start a conversation" -ChatMode "textprompt" -Model "qwen"

    Starts an interactive text chat session with the specified model.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-LLMStringListEvaluation

SYNOPSIS
    Extracts or generates a list of relevant strings from input text using AI
    analysis.


SYNTAX
    Invoke-LLMStringListEvaluation [[-Text] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left <Int32>] [-Right <Int32>] [-Bottom <Int32>] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function uses AI models to analyze input text and extract or generate a
    list of relevant strings. It can process text to identify key points, extract
    items from lists, or generate related concepts. Input can be provided directly
    through parameters, from the pipeline, or from the system clipboard. The
    function returns a string array and optionally copies results to clipboard.


PARAMETERS
    -Text <String>
        The text to analyze and extract strings from. If not provided, the function
        will read from the system clipboard.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        Optional instructions to guide the AI model in generating the string list. By
        default, it will extract key points, items, or relevant concepts from the
        input text.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>
        Array of file paths to attach to the AI query. These files will be included
        in the context for analysis.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0). Lower values produce more
        deterministic responses, higher values increase creativity.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Image detail level for image processing. Valid values are "low", "medium",
        or "high".

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of function definitions that can be called by the AI model during
        processing.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools that the AI can
        invoke.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of command names that don't require confirmation before execution.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform. Valid values are "SimpleIntelligence",
        "Knowledge", "Pictures", "TextTranslation", "Coding", or "ToolUse".

        Required?                    false
        Position?                    named
        Default value                Knowledge
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If
        'max', all layers are offloaded to GPU. If a number between 0 and 1, that
        fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
        how much to offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        When specified, copies the resulting string list back to the system clipboard
        after processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]
        Include model's thoughts in output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]
        Don't add model's thoughts to conversation history.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Continue from last conversation.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]
        Enable text-to-speech for AI responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]
        Enable text-to-speech for AI thought responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Don't store session in session cache.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]
        Enable default tools for the AI model.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String[]


    -------------------------- EXAMPLE 1 --------------------------

    PS>Invoke-LLMStringListEvaluation -Text ("PowerShell features: object-based " +
        "pipeline, integrated scripting environment, backwards compatibility, " +
        "and enterprise management.")
    Returns: @("Object-based pipeline", "Integrated scripting environment",
             "Backwards compatibility", "Enterprise management")






    -------------------------- EXAMPLE 2 --------------------------

    PS>"Make a shopping list with: keyboard, mouse, monitor, headset" |
        Invoke-LLMStringListEvaluation
    Returns: @("Keyboard", "Mouse", "Monitor", "Headset")






    -------------------------- EXAMPLE 3 --------------------------

    PS>getlist "List common PowerShell commands for file operations" -SetClipboard
    Returns and copies to clipboard: @("Get-ChildItem", "Copy-Item", "Move-Item",
                                      "Remove-Item", "Set-Content", "Get-Content")
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-LLMTextTransformation

SYNOPSIS
    Transforms text using AI-powered processing.


SYNTAX
    Invoke-LLMTextTransformation [[-Text] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function processes input text using AI models to perform various
    transformations such as spell checking, adding emoticons, or any other text
    enhancement specified through instructions. It can accept input directly
    through parameters, from the pipeline, or from the system clipboard.


PARAMETERS
    -Text <String>
        The input text to transform. If not provided, the function will read from the
        system clipboard. Multiple lines of text are supported.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        Instructions to guide the AI model in transforming the text. By default, it
        will perform spell checking and grammar correction.

        Required?                    false
        Position?                    2
        Default value                Check and correct any spelling or grammar errors in the text. Return the corrected text without any additional comments or explanations.
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>
        Array of file paths to attach to the AI processing request.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness, ranging from 0.0 to 1.0.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Image detail level for image processing operations.

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of function definitions for AI tool usage.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of command names that don't require confirmation.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU for AI processing.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        When specified, copies the transformed text back to the system clipboard after
        processing is complete.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]
        Include model's thoughts in output history.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Continue from last conversation in the AI session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]
        Enable text-to-speech for AI responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]
        Enable text-to-speech for AI thought responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Don't store session in session cache.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]
        Allow the use of default AI tools during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-LLMTextTransformation -Text "Hello, hwo are you todey?" `
        -Instructions "Fix spelling errors" -SetClipboard






    -------------------------- EXAMPLE 2 --------------------------

    PS > "Time to celerbate!" | Invoke-LLMTextTransformation `
        -Instructions "Add celebratory emoticons"






    -------------------------- EXAMPLE 3 --------------------------

    PS > spellcheck "This is a sentance with erors"
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-WinMerge

SYNOPSIS
    Launches WinMerge to compare two files side by side.


SYNTAX
    Invoke-WinMerge [-SourcecodeFilePath] <String> [-TargetcodeFilePath] <String> [[-Wait]] [<CommonParameters>]


DESCRIPTION
    Launches the WinMerge application to compare source and target files in a side by
    side diff view. The function validates the existence of both input files and
    ensures WinMerge is properly installed before launching. Provides optional
    wait functionality to pause execution until WinMerge closes.


PARAMETERS
    -SourcecodeFilePath <String>
        Full or relative path to the source file for comparison. The file must exist and
        be accessible.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TargetcodeFilePath <String>
        Full or relative path to the target file for comparison. The file must exist and
        be accessible.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Wait [<SwitchParameter>]
        Switch parameter that when specified will cause the function to wait for the
        WinMerge application to close before continuing execution.

        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-WinMerge -SourcecodeFilePath "C:\source\file1.txt" `
                    -TargetcodeFilePath "C:\target\file2.txt" `
                    -Wait






    -------------------------- EXAMPLE 2 --------------------------

    PS > merge "C:\source\file1.txt" "C:\target\file2.txt"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    New-LLMAudioChat

SYNOPSIS
    Creates an interactive audio chat session with an LLM model.


SYNTAX
    New-LLMAudioChat [[-Query] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-AudioTemperature <Double>] [-Temperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-Cpu <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Int32>] [-LengthPenalty <Single>] [-EntropyThreshold <Single>] [-LogProbThreshold <Single>] [-NoSpeechThreshold <Single>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-ImageDetail <String>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-ResponseFormat <String>] [-MarkupBlocksTypeFilter <String[]>] [-PreferencesDatabasePath <String>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-Monitor <Int32>] [-Functions <ScriptBlock[]>] [-NoConfirmationToolFunctionNames <String[]>] [-ChatMode <String>] [-MaxToolcallBackLength <Int32>] [-NoBorders] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-Unload] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-NoSessionCaching] [-OutputMarkdownBlocksOnly] [-ShowWindow] [-Force] [-SessionOnly] [-ClearSession] [-SkipSession] [-NoLMStudioInitialize] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    Initiates a voice-based conversation with a language model, supporting audio
    input and output. The function handles audio recording, transcription, model
    queries, and text-to-speech responses. Supports multiple language models and
    various configuration options including window management, GPU acceleration,
    and advanced audio processing features.


PARAMETERS
    -Query <String>
        Initial text query to send to the model. Can be empty to start with voice
        input.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        System instructions/prompt to guide the model's behavior.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>
        Array of file paths to attach to the conversation for context.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>
        Temperature setting for audio input recognition. Range: 0.0-1.0. Default: 0.0

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness. Range: 0.0-1.0. Default: 0.2

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>
        Temperature for controlling response randomness. Range: 0.0-1.0. Default: 0.01

        Required?                    false
        Position?                    named
        Default value                0.01
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language to detect in audio input. Default: "English"

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>
        Number of CPU threads to use. 0=auto. Default: 0

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>
        Regex pattern to suppress tokens from output.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>
        Size of the audio context window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Int32>
        Silence detect threshold (0..32767 defaults to 30)

        Required?                    false
        Position?                    named
        Default value                30
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Single>
        Penalty factor for response length. Range: 0-1

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Single>
        Threshold for entropy in responses. Range: 0-1

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Single>
        Threshold for log probability in responses. Range: 0-1

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Single>
        Threshold for no-speech detection. Range: 0-1. Default: 0.1

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query

        Required?                    false
        Position?                    named
        Default value                ToolUse
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        Time-to-live in seconds for models loaded via API requests. Use -1 for no TTL.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        GPU offloading configuration. -2=Auto, -1=LM Studio decides, 0-1=fraction of
        layers. Default: -1

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Image detail level setting. Options: "low", "medium", "high". Default: "low"

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ResponseFormat <String>
        A JSON schema for the requested output format

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>
        Will only output markup blocks of the specified types

        Required?                    false
        Position?                    named
        Default value                @(
                    'json',
                    'powershell',
                    'C#',
                    'python',
                    'javascript',
                    'typescript',
                    'html',
                    'css',
                    'yaml',
                    'xml',
                    'bash'
                )
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions available as tools to the model.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use for window display. 0=default, -1=discard

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <ScriptBlock[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ChatMode <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Switch to remove window borders from LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        The initial width of the LM Studio window

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        The initial height of the LM Studio window

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        The initial X position of the LM Studio window

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        The initial Y position of the LM Studio window

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Switch to place LM Studio window on the left side of the screen

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Switch to place LM Studio window on the right side of the screen

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Switch to place LM Studio window on the top side of the screen

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Switch to place LM Studio window on the bottom side of the screen

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Switch to place LM Studio window in the center of the screen

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]
        Switch to make LM Studio window fullscreen

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Switch to restore PowerShell window focus after initialization

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Switch to set window either fullscreen on different monitor or side by side

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Switch to focus the LM Studio window after opening

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Switch to set the LM Studio window to foreground after opening

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Switch to maximize the LM Studio window after positioning

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Array of keystrokes to send to the LM Studio window

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Switch to escape control characters when sending keys

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Switch to prevent returning keyboard focus to PowerShell after sending keys

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Switch to send Shift+Enter instead of regular Enter for line breaks

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between sending different key sequences in milliseconds

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]
        Switch to unload the specified model instead of loading it

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]
        Switch to include model's thought process in output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]
        Switch to include model's thoughts in output

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Switch to continue from last conversation context.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]
        Switch to disable text-to-speech for AI responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]
        Switch to disable text-to-speech for AI thought responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]
        Switch to disable silence detection for automatic recording stop.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]
        Switch to use desktop audio capture instead of microphone input.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]
        Switch to disable context usage in conversation.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]
        Switch to enable beam search sampling strategy.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]
        Switch to suppress recognized text in output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Switch to disable session caching.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]
        Will only output markup block responses

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Switch to show the LM Studio window during operation.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Switch to force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]
        Switch to skip LM-Studio initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > New-LLMAudioChat -Query "Tell me about PowerShell" `
        -Model "qwen2.5-14b-instruct" `
        -Temperature 0.7 `
        -MaxToken 4096






    -------------------------- EXAMPLE 2 --------------------------

    PS > llmaudiochat "What's the weather?" -DontSpeak







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    New-LLMTextChat

SYNTAX
    New-LLMTextChat [[-Query] <string>] [[-Instructions] <string>] [[-Attachments] <string[]>] [[-Temperature] <double>] [-ImageDetail {low | medium | high}] [-ResponseFormat <string>] [-LLMQueryType {SimpleIntelligence | Knowledge | Pictures | TextTranslation | Coding | ToolUse}] [-Model <string>] [-HuggingFaceIdentifier <string>] [-MaxToken <int>] [-Cpu <int>] [-Gpu <int>] [-ApiEndpoint <string>] [-ApiKey <string>] [-TimeoutSeconds <int>] [-PreferencesDatabasePath <string>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-MarkupBlocksTypeFilter <string[]>] [-TTLSeconds <int>] [-Monitor <int>] [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>] [-KeysToSend <string[]>] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-ShowWindow] [-Force] [-Speak] [-SpeakThoughts] [-OutputMarkdownBlocksOnly] [-ChatOnce] [-NoSessionCaching] [-SessionOnly] [-ClearSession] [-SkipSession] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <int>] [-NoConfirmationToolFunctionNames <string[]>] [-MaxToolcallBackLength <int>] [-AudioTemperature <Object>] [-TemperatureResponse <Object>] [-Language <Object>] [-CpuThreads <Object>] [-SuppressRegex <Object>] [-AudioContextSize <Object>] [-SilenceThreshold <Object>] [-LengthPenalty <Object>] [-EntropyThreshold <Object>] [-LogProbThreshold <Object>] [-NoSpeechThreshold <Object>] [-DontSpeak <Object>] [-DontSpeakThoughts <Object>] [-NoVOX <Object>] [-UseDesktopAudioCapture <Object>] [-NoContext <Object>] [-WithBeamSearchSamplingStrategy <Object>] [-OnlyResponses <Object>] [-WhatIf] [-Confirm] [<CommonParameters>]


PARAMETERS
    -ApiEndpoint <string>
        The API endpoint URL for AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ApiKey <string>
        The API key for authenticated AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Attachments <string[]>
        Array of file paths to attach

        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -AudioContextSize <Object>
        Audio context size for processing

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -AudioTemperature <Object>
        Temperature for audio generation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Bottom
        Place window on the bottom side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Centered
        Place window in the center of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ChatOnce
        Used internally, to only invoke chat mode once after the llm invocation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ClearSession
        Clear alternative settings stored in session for AI preferences

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Confirm

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false

    -ContinueLast
        Continue from last conversation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Cpu <int>
        The number of CPU cores to dedicate to AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -CpuThreads <Object>
        Number of CPU threads to use

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory
        Include model's thoughts in output

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontSpeak <Object>
        Disable speech output

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontSpeakThoughts <Object>
        Disable speech output for thoughts

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -EntropyThreshold <Object>
        Entropy threshold for output filtering

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FocusWindow
        Focus the window after opening

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false

    -Force
        Force stop LM Studio before initialization

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FullScreen
        Sends F11 to the window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs
        Dynamic?                     false
        Accept wildcard characters?  false

    -Gpu <int>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max', all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Height <int>
        The initial height of the window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <string>
        The LM Studio specific model identifier

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ModelLMSGetIdentifier
        Dynamic?                     false
        Accept wildcard characters?  false

    -ImageDetail <string>
        Image detail level

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -IncludeThoughts
        Include model's thoughts in output

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Instructions <string>
        System instructions for the model

        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -KeysToSend <string[]>
        Keystrokes to send to the Window, see documentation for cmdlet GenXdev.Windows\Send-Key

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -LLMQueryType <string>
        The type of LLM query

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Language <Object>
        Language for the model or output

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Left
        Place window on the left side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -LengthPenalty <Object>
        Length penalty for sequence generation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -LogProbThreshold <Object>
        Log probability threshold for output filtering

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <string[]>
        Will only output markup blocks of the specified types

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MaxToken <int>
        The maximum number of tokens to use in AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MaxToolcallBackLength <int>
        Maximum length for tool callback responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Maximize
        Maximize the window after positioning

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Model <string>
        The model identifier or pattern to use for AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoBorders
        Removes the borders of the window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <string[]>
        Names of tool functions that should not require confirmation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      NoConfirmationFor
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoContext <Object>
        Disable context usage

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoLMStudioInitialize
        Skip LM-Studio initialization (used when already called by parent function)

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoSessionCaching
        Don't store session in session cache

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoSpeechThreshold <Object>
        No speech threshold for audio detection

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoVOX <Object>
        Disable VOX (voice activation)

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OnlyResponses <Object>
        Return only responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly
        Will only output markup block responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PreferencesDatabasePath <string>
        Database path for preference data files

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DatabasePath
        Dynamic?                     false
        Accept wildcard characters?  false

    -Query <string>
        Query text to send to the model

        Required?                    false
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           Default
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ResponseFormat <string>
        A JSON schema for the requested output format

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -RestoreFocus
        Restore PowerShell window focus

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false

    -Right
        Place window on the right side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <int>
        Delay between different input strings in milliseconds when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyEscape
        Escape control characters and modifiers when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus
        Hold keyboard focus on target window when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter
        Use Shift+Enter instead of Enter when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false

    -SessionOnly
        Use alternative settings stored in session for AI preferences

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SetForeground
        Set the window to foreground after opening

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false

    -ShowWindow
        Show the LM Studio window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SideBySide
        Will either set the window fullscreen on a different monitor than Powershell, or side by side with Powershell on the same monitor

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false

    -SilenceThreshold <Object>
        Silence threshold for audio processing

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SkipSession
        Store settings only in persistent preferences without affecting session

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false

    -Speak
        Enable text-to-speech for AI responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SpeakThoughts
        Enable text-to-speech for AI thought responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SuppressRegex <Object>
        Regular expression to suppress output

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -TTLSeconds <int>
        Time-to-live in seconds for models loaded via API requests

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Temperature <double>
        Temperature for response randomness (0.0-1.0)

        Required?                    false
        Position?                    3
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -TemperatureResponse <Object>
        Temperature for response generation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -TimeoutSeconds <int>
        The timeout in seconds for AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Top
        Place window on the top side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Unload
        Unloads the specified model instead of loading it

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -UseDesktopAudioCapture <Object>
        Use desktop audio capture

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -WhatIf

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false

    -Width <int>
        The initial width of the window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy <Object>
        Use beam search sampling strategy

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -X <int>
        The initial X position of the window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Y <int>
        The initial Y position of the window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).


INPUTS
    System.String


OUTPUTS
    System.Object

ALIASES
    llmchat


REMARKS
    None

<br/><hr/><hr/><br/>

NAME
    Set-AILLMSettings

SYNOPSIS
    Sets the LLM settings for AI operations in GenXdev.AI.


SYNTAX
    Set-AILLMSettings [-LLMQueryType] <String> [[-Model] <String>] [[-HuggingFaceIdentifier] <String>] [[-MaxToken] <Int32>] [[-Cpu] <Int32>] [[-Gpu] <Int32>] [[-TTLSeconds] <Int32>] [[-ApiEndpoint] <String>] [[-ApiKey] <String>] [[-TimeoutSeconds] <Int32>] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function configures the LLM (Large Language Model) settings used by the
    GenXdev.AI module for various AI operations. Settings can be stored persistently
    in preferences (default), only in the current session (using -SessionOnly), or
    cleared from the session (using -ClearSession). The function validates that at
    least one setting parameter is provided unless clearing session settings.


PARAMETERS
    -LLMQueryType <String>
        The type of LLM query to set settings for. This determines which configuration
        to store or modify. Valid values are SimpleIntelligence, Knowledge, Pictures,
        TextTranslation, Coding, and ToolUse.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier to use for retrieving the model.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    5
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        GPU offload level (-2=Auto through 1=Full).

        Required?                    false
        Position?                    6
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        The time-to-live in seconds for cached AI responses.

        Required?                    false
        Position?                    7
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    8
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    9
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    10
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        When specified, stores the settings only in the current session (Global
        variables) without persisting to preferences. Settings will be lost when the
        session ends.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        When specified, clears only the session settings (Global variables) without
        affecting persistent preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        When specified, stores the settings only in persistent preferences without
        affecting the current session settings.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Set-AILLMSettings -LLMQueryType "Coding" -Model "*Qwen*14B*" -MaxToken 32768

    Sets the LLM settings for Coding query type persistently in preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "maziyarpanahi/llama-3-groq-8b-tool-use" -TimeoutSeconds 7200 -SessionOnly

    Sets the LLM settings for SimpleIntelligence only for the current
    session.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Set-AILLMSettings -LLMQueryType "Pictures" -ClearSession

    Clears the session LLM settings for Pictures query type without affecting
    persistent preferences.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Set-AILLMSettings "Coding" "*Qwen*14B*" -MaxToken 32768

    Sets the LLM settings for Coding query type using positional parameters.




    -------------------------- EXAMPLE 5 --------------------------

    PS > Set-AILLMSettings -LLMQueryType "Coding" -Cpu 8 -Gpu 2 -MaxToken 16384

    Sets the LLM settings for Coding query type with specific CPU and GPU core counts.
    ##############################################################################





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Set-GenXdevAICommandNotFoundAction

SYNOPSIS
    Sets up custom command not found handling with AI assistance.


SYNTAX
    Set-GenXdevAICommandNotFoundAction [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    Configures PowerShell to handle unknown commands by either navigating to
    directories or using AI to interpret user intent. The handler first tries any
    existing command not found handler, then checks if the command is a valid path
    for navigation, and finally offers AI assistance for unknown commands.


PARAMETERS
    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Set-GenXdevAICommandNotFoundAction







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Start-GenXdevMCPServer

SYNOPSIS
    Starts the GenXdev MCP server that exposes PowerShell cmdlets as tools.


SYNTAX
    Start-GenXdevMCPServer [[-Port] <Int32>] [[-ExposedCmdLets] <ExposedCmdletDefinition[]>] [[-NoConfirmationToolFunctionNames] <String[]>] [-StopExisting] [[-MaxOutputLength] <Int32>] [<CommonParameters>]


DESCRIPTION
    This function starts an HTTP server that implements the Model Context Protocol (MCP)
    server pattern, exposing PowerShell cmdlets as callable tools. The server provides
    endpoints for listing available tools and executing them, similar to the TypeScript
    example but using PowerShell's ExposedCmdLets functionality.


PARAMETERS
    -Port <Int32>
        The port on which the server will listen. Default is 2175.

        Required?                    false
        Position?                    1
        Default value                2175
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to expose as tools.

        Required?                    false
        Position?                    2
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of command names that can execute without user confirmation.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -StopExisting [<SwitchParameter>]
        Stop any existing server running on the specified port.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxOutputLength <Int32>
        Maximum length of tool output in characters. Output exceeding this length will be trimmed with a warning message. Default is 75000 characters (100KB).

        Required?                    false
        Position?                    4
        Default value                75000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Start-GenXdevMCPServer -Port 2175






    -------------------------- EXAMPLE 2 --------------------------

    PS > $exposedCmdlets = @(
        [GenXdev.Helpers.ExposedCmdletDefinition]@{
            Name = "Get-Process"
            Description = "Get running processes"
            AllowedParams = @("Name", "Id")
            Confirm = $false
        }
    )
    Start-GenXdevMCPServer -Port 2175 -ExposedCmdLets $exposedCmdlets







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Test-DeepLinkImageFile

SYNOPSIS
    Tests if the specified file path is a valid image file with a supported format.


SYNTAX
    Test-DeepLinkImageFile [-Path] <String> [<CommonParameters>]


DESCRIPTION
    This function validates that a file exists at the specified path and has a
    supported image file extension. It checks for common image formats including
    PNG, JPG, JPEG, and GIF files. The function throws exceptions for invalid
    paths or unsupported file formats.


PARAMETERS
    -Path <String>
        The file path to the image file to be tested. Must be a valid file system path.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Test-DeepLinkImageFile -Path "C:\Images\photo.jpg"






    -------------------------- EXAMPLE 2 --------------------------

    PS > Test-DeepLinkImageFile "C:\Images\logo.png"







RELATED LINKS

<br/><hr/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.AI.DeepStack<hr/>
NAME
    Compare-ImageFaces

SYNOPSIS
    Compares faces in two different images and returns their similarity using
    DeepStack.


SYNTAX
    Compare-ImageFaces [-ImagePath1] <String> [-ImagePath2] <String> [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function compares faces between two images to determine similarity. It
    uses a local DeepStack face match API running on a configurable port and
    returns a similarity score between 0.0 and 1.0. This is typically used for
    matching identity documents with pictures of a person or verifying if two
    photos show the same person.


PARAMETERS
    -ImagePath1 <String>
        The local path to the first image file to compare. This parameter accepts any
        valid file path that can be resolved by the system.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImagePath2 <String>
        The local path to the second image file to compare. This parameter accepts any
        valid file path that can be resolved by the system.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container. This allows multiple DeepStack instances
        or custom naming conventions. Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    3
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage. This ensures face data
        persists between container restarts. Default is "deepstack_face_data".

        Required?                    false
        Position?                    4
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Must be between 1 and 65535.
        Default is 5000.

        Required?                    false
        Position?                    5
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Must be between 10
        and 300 seconds. Default is 60.

        Required?                    false
        Position?                    6
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Must be between 1 and 10
        seconds. Default is 3.

        Required?                    false
        Position?                    7
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image. This
        allows using custom or updated DeepStack images.

        Required?                    false
        Position?                    8
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. This is typically used
        when already called by parent function to avoid duplicate initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This is useful for troubleshooting or updating the DeepStack image.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. This requires an
        NVIDIA GPU with proper Docker GPU support configured.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Collections.Hashtable


NOTES


        DeepStack API Documentation: POST /v1/vision/face/match endpoint for face
        comparison.
        Example: curl -X POST -F "image1=@person1.jpg" -F "image2=@person2.jpg"
        http://localhost:5000/v1/vision/face/match

    -------------------------- EXAMPLE 1 --------------------------

    PS > Compare-ImageFaces -ImagePath1 "C:\Users\YourName\photo1.jpg" `
                       -ImagePath2 "C:\Users\YourName\photo2.jpg"

    Compares faces between two images using default settings.




    -------------------------- EXAMPLE 2 --------------------------

    PS > comparefaces "C:\docs\id_photo.jpg" "C:\photos\person.jpg" -UseGPU

    Compares faces using GPU acceleration for identity verification with alias and
    positional parameters.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    EnsureDeepStack

SYNOPSIS
    Ensures DeepStack face recognition service is installed and running.


SYNTAX
    EnsureDeepStack [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-Force] [-UseGPU] [-ShowWindow] [-Monitor <Int32>] [-NoBorders] [-Width <Int32>] [-Height <Int32>] [-Left] [-Right] [-Bottom] [-Centered] [-Fullscreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function sets up and manages DeepStack face recognition service using
    Docker. It ensures that Docker Desktop is installed, pulls the DeepStack Docker
    image, and runs the service in a container with persistent storage for
    registered faces.

    DeepStack provides a simple REST API for face detection, registration, and
    recognition that is well-documented and actively maintained.


PARAMETERS
    -ContainerName <String>
        The name for the Docker container. Default: "deepstack_face_recognition"

        Required?                    false
        Position?                    1
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage.
        Default: "deepstack_face_data"

        Required?                    false
        Position?                    2
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Default: 5000

        Required?                    false
        Position?                    3
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Default: 60

        Required?                    false
        Position?                    4
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Default: 3

        Required?                    false
        Position?                    5
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use. If not specified, uses
        deepquestai/deepstack:latest or deepquestai/deepstack:gpu based on UseGPU
        parameter.

        Required?                    false
        Position?                    6
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        If specified, forces rebuilding of Docker container and removes existing data.
        This will remove existing containers and volumes, pull latest DeepStack image,
        create a fresh container with clean data, and clear all registered faces.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        If specified, uses the GPU-accelerated version of DeepStack (requires NVIDIA
        GPU).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Fullscreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Boolean


NOTES


        DeepStack Face Recognition API Endpoints:
        - POST /v1/vision/face/register : Register known faces
        - POST /v1/vision/face/list : List registered faces
        - POST /v1/vision/face/recognize : Recognize faces in image
        - POST /v1/vision/face/delete : Remove registered face

        For more information, see: https://docs.deepstack.cc/face-recognition/

    -------------------------- EXAMPLE 1 --------------------------

    PS > EnsureDeepStack -ContainerName "deepstack_face_recognition" `
                    -VolumeName "deepstack_face_data" `
                    -ServicePort 5000 `
                    -HealthCheckTimeout 60 `
                    -HealthCheckInterval 3






    -------------------------- EXAMPLE 2 --------------------------

    PS > EnsureDeepStack -Force -UseGPU







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-ImageDetectedFaces

SYNOPSIS
    Recognizes faces in an uploaded image by comparing to known faces using
    DeepStack.


SYNTAX
    Get-ImageDetectedFaces [-ImagePath] <String> [-ConfidenceThreshold <Double>] [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function analyzes an image file to identify faces by comparing them
    against known faces in the database. It uses a local DeepStack face
    recognition API running on a configurable port and returns face matches with
    their confidence scores. The function supports GPU acceleration, custom
    confidence thresholds, and Docker container management.


PARAMETERS
    -ImagePath <String>
        The local path to the image file to analyze. This parameter accepts any valid
        file path that can be resolved by the system.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false

    -ConfidenceThreshold <Double>
        Minimum confidence threshold (0.0-1.0) for face recognition matches. Faces
        with confidence below this threshold will be filtered out. Default is 0.5.

        Required?                    false
        Position?                    named
        Default value                0.5
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container. This allows multiple DeepStack instances
        or custom naming conventions. Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage. This ensures face data
        persists between container restarts. Default is "deepstack_face_data".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Must be between 1 and 65535.
        Default is 5000.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Must be between 10
        and 300 seconds. Default is 60.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Must be between 1 and 10
        seconds. Default is 3.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image. This
        allows using custom or updated DeepStack images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. This is typically used
        when already called by parent function to avoid duplicate initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This is useful for troubleshooting or updating the DeepStack image.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. This requires an
        NVIDIA GPU with proper Docker GPU support configured.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        DeepStack API Documentation: POST /v1/vision/face/recognize endpoint for face
        identification. Example: curl -X POST -F "image=@person1.jpg"
        http://localhost:5000/v1/vision/face/recognize
        ##############################################################################

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-ImageDetectedFaces -ImagePath "C:\Users\YourName\test.jpg" `
                           -ConfidenceThreshold 0.5 `
                           -ContainerName "deepstack_face_recognition" `
                           -VolumeName "deepstack_face_data" `
                           -ServicePort 5000 `
                           -HealthCheckTimeout 60 `
                           -HealthCheckInterval 3
    Recognizes faces in the specified image using full parameter names.






    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-ImageDetectedFaces "C:\photos\family.jpg" -Force -UseGPU
    Recognizes faces using positional parameter and aliases.






    -------------------------- EXAMPLE 3 --------------------------

    PS > "C:\Users\YourName\test.jpg" | Get-ImageDetectedFaces
    Recognizes faces using pipeline input.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-ImageDetectedObjects

SYNOPSIS
    Detects and classifies objects in an uploaded image using DeepStack.


SYNTAX
    Get-ImageDetectedObjects [-ImagePath] <String> [-ConfidenceThreshold <Double>] [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function analyzes an image file to detect and classify up to 80 different
    kinds of objects. It uses a local DeepStack object detection API running on a
    configurable port and returns object classifications with their bounding box
    coordinates and confidence scores. The function supports GPU acceleration,
    custom confidence thresholds, and Docker container management.


PARAMETERS
    -ImagePath <String>
        The local path to the image file to analyze. This parameter accepts any valid
        file path that can be resolved by the system.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false

    -ConfidenceThreshold <Double>
        Minimum confidence threshold (0.0-1.0) for object detection. Objects with
        confidence below this threshold will be filtered out. Default is 0.5.

        Required?                    false
        Position?                    named
        Default value                0.5
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container. This allows multiple DeepStack instances
        or custom naming conventions. Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage. This ensures face data
        persists between container restarts. Default is "deepstack_face_data".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Must be between 1 and 65535.
        Default is 5000.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Must be between 10
        and 300 seconds. Default is 60.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Must be between 1 and 10
        seconds. Default is 3.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image. This
        allows using custom or updated DeepStack images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. This is typically used
        when already called by parent function to avoid duplicate initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This is useful for troubleshooting or updating the DeepStack image.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. This requires an
        NVIDIA GPU with proper Docker GPU support configured.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        DeepStack API Documentation: POST /v1/vision/detection endpoint for object
        detection. Example: curl -X POST -F "image=@street.jpg"
        http://localhost:5000/v1/vision/detection

        Supported object classes include: person, bicycle, car, motorcycle, airplane,
        bus, train, truck, boat, traffic light, fire hydrant, stop sign, parking
        meter, bench, bird, cat, dog, horse, sheep, cow, elephant, bear, zebra,
        giraffe, backpack, umbrella, handbag, tie, suitcase, frisbee, skis, snowboard,
        sports ball, kite, baseball bat, baseball glove, skateboard, surfboard, tennis
        racket, bottle, wine glass, cup, fork, knife, spoon, bowl, banana, apple,
        sandwich, orange, broccoli, carrot, hot dog, pizza, donut, cake, chair, couch,
        potted plant, bed, dining table, toilet, tv, laptop, mouse, remote, keyboard,
        cell phone, microwave, oven, toaster, sink, refrigerator, book, clock, vase,
        scissors, teddy bear, hair drier, toothbrush.

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-ImageDetectedObjects -ImagePath "C:\Users\YourName\test.jpg" `
                             -ConfidenceThreshold 0.5 `
                             -ServicePort 5000

    Detects objects in the specified image with full parameter names.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-ImageDetectedObjects "C:\photos\street.jpg"

    Detects objects using positional parameter and default settings.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-ImageDetectedScenes

SYNOPSIS
    Classifies an image into one of 365 scene categories using DeepStack.


SYNTAX
    Get-ImageDetectedScenes [-ImagePath] <String> [[-ConfidenceThreshold] <Double>] [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [-ImageName <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function analyzes an image file to classify it into one of 365 different
    scene categories. It uses a local DeepStack scene recognition API running on a
    configurable port and returns the scene classification with confidence score.
    The function supports GPU acceleration and Docker container management.


PARAMETERS
    -ImagePath <String>
        The local path to the image file to analyze. This parameter accepts any valid
        file path that can be resolved by the system.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false

    -ConfidenceThreshold <Double>

        Required?                    false
        Position?                    2
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container. This allows multiple DeepStack instances
        or custom naming conventions. Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    3
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage. This ensures face data
        persists between container restarts. Default is "deepstack_face_data".

        Required?                    false
        Position?                    4
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Must be between 1 and 65535.
        Default is 5000.

        Required?                    false
        Position?                    5
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Must be between 10
        and 300 seconds. Default is 60.

        Required?                    false
        Position?                    6
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Must be between 1 and 10
        seconds. Default is 3.

        Required?                    false
        Position?                    7
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image. This
        allows using custom or updated DeepStack images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. This is typically used
        when already called by parent function to avoid duplicate initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This is useful for troubleshooting or updating the DeepStack image.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. This requires an
        NVIDIA GPU with proper Docker GPU support configured.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        DeepStack API Documentation: POST /v1/vision/scene endpoint for scene
        recognition.
        Example: curl -X POST -F "image=@landscape.jpg"
        http://localhost:5000/v1/vision/scene

        Scene categories include places like: abbey, airplane_cabin, airport_terminal,
        alley, amphitheater, amusement_arcade, amusement_park, anechoic_chamber,
        apartment_building, aquarium, aqueduct, arcade, arch, archive, art_gallery,
        art_school, art_studio, assembly_line, athletic_field, atrium, attic,
        auditorium, auto_factory, badlands, balcony, ball_pit, ballroom,
        bamboo_forest, banquet_hall, bar, barn, barndoor, baseball_field, basement,
        basilica, basketball_court, bathroom, bathtub, battlefield, beach,
        beauty_salon, bedroom, berth, biology_laboratory, boardwalk, boat_deck,
        boathouse, bookstore, booth, botanical_garden, bowling_alley, boxing_ring,
        bridge, building_facade, bullring, burial_chamber, bus_interior,
        bus_station, butchers_shop, butte, cabin, cafeteria, campsite, campus,
        canal, candy_store, canyon, car_interior, castle, catacomb, cemetery,
        chalet, chemistry_lab, chinatown, church, classroom, clean_room, cliff,
        cloister, closet, clothing_store, coast, cockpit, coffee_shop,
        computer_room, conference_center, conference_room, construction_site,
        corn_field, corridor, cottage, courthouse, courtyard, creek, crevasse,
        crosswalk, dam, delicatessen, department_store, desert, diner, dining_hall,
        dining_room, discotheque, dock, doorway, dorm_room, downtown, driveway,
        drugstore, elevator, engine_room, entrance_hall, escalator, excavation,
        fabric_store, farm, fastfood_restaurant, field, fire_escape, fire_station,
        fishpond, flea_market, florist_shop, food_court, football_field, forest,
        forest_path, forest_road, formal_garden, fountain, galley, game_room,
        garage, garbage_dump, gas_station, gazebo, general_store, gift_shop,
        glacier, golf_course, greenhouse, grotto, gymnasium, hangar, harbor,
        hardware_store, hayfield, heliport, highway, home_office, home_theater,
        hospital, hospital_room, hot_spring, hotel, hotel_room, house,
        hunting_lodge, ice_cream_parlor, ice_rink, ice_shelf, iceberg, igloo,
        industrial_area, inn, islet, jacuzzi, jail_cell, japanese_garden,
        jewelry_shop, junkyard, kasbah, kennel, kindergarten_classroom, kitchen,
        lagoon, lake, laundromat, lawn, lecture_room, legislature, library,
        lighthouse, living_room, lobby, lock_chamber, locker_room, mansion,
        manufactured_home, market, marsh, martial_arts_gym, mausoleum, medina,
        moat, monastery, mosque, motel, mountain, mountain_path, mountain_snowy,
        movie_theater, museum, music_studio, nursery, nursing_home, oast_house,
        ocean, office, office_building, oil_refinery, oilrig, operating_room,
        orchard, orchestra_pit, pagoda, palace, pantry, park, parking_garage,
        parking_lot, pasture, patio, pavilion, pharmacy, phone_booth,
        physics_laboratory, picnic_area, pier, pizzeria, playground, playroom,
        plaza, pond, porch, promenade, pub, public_pool, racecourse, raceway,
        raft, railroad_track, rainforest, reception, recreation_room,
        residential_neighborhood, restaurant, restaurant_kitchen,
        restaurant_patio, rice_paddy, river, rock_arch, rope_bridge, ruin,
        runway, sandbox, sauna, schoolhouse, science_museum, server_room, shed,
        shoe_shop, shopfront, shopping_mall, shower, ski_resort, ski_slope, sky,
        skyscraper, slum, snowfield, soccer_field, stable, stadium, stage,
        staircase, storage_room, storm_cellar, street, strip_mall,
        subway_station, supermarket, swamp, swimming_hole, swimming_pool,
        synagogue, television_room, television_studio, temple, throne_room,
        ticket_booth, topiary_garden, tower, toyshop, track, train_interior,
        train_station, tree_farm, tree_house, trench, tundra, underwater,
        university, upholstery_shop, urban_canal, valley, vegetable_garden,
        veterinarians_office, viaduct, village, vineyard, volcano,
        volleyball_court, waiting_room, water_park, water_tower, waterfall,
        watering_hole, wave, wet_bar, wheat_field, wind_farm, windmill, yard,
        youth_hostel, zen_garden.
        ##############################################################################

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-ImageDetectedScenes -ImagePath "C:\Users\YourName\landscape.jpg"
    Classifies the scene in the specified image using default settings.






    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-ImageDetectedScenes -ImagePath "C:\photos\vacation.jpg" -ConfidenceThreshold 0.6 -UseGPU
    Classifies the scene using GPU acceleration and only accepts results with confidence >= 60%.






    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-ImageDetectedScenes -ImagePath "C:\photos\vacation.jpg" -UseGPU
    Classifies the scene using GPU acceleration for faster processing.






    -------------------------- EXAMPLE 4 --------------------------

    PS > "C:\Users\YourName\beach.jpg" | Get-ImageDetectedScenes
    Pipeline support for processing multiple images.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-RegisteredFaces

SYNOPSIS
    Retrieves a list of all registered face identifiers from DeepStack.


SYNTAX
    Get-RegisteredFaces [-NoDockerInitialize] [-Force] [-UseGPU] [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function connects to a local DeepStack face recognition API and retrieves
    all registered face identifiers. It uses the /v1/vision/face/list endpoint to
    query the DeepStack service and returns an array of face identifier strings. The
    function handles Docker container initialization, API communication, and error
    handling for various failure scenarios.


PARAMETERS
    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this parameter is specified. This is used when
        the function is called by a parent function that has already initialized the
        DeepStack service.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of the Docker container and remove existing data. This will
        recreate the container from scratch and clear all stored face data.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version of DeepStack. This requires an NVIDIA GPU and
        appropriate drivers to be installed on the system.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container running DeepStack. Defaults to
        "deepstack_face_recognition" if not specified.

        Required?                    false
        Position?                    1
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume used for persistent storage of face data.
        Defaults to "deepstack_face_data" if not specified.

        Required?                    false
        Position?                    2
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Must be between 1 and 65535.
        Defaults to 5000 if not specified.

        Required?                    false
        Position?                    3
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check to complete. Must be
        between 10 and 300 seconds. Defaults to 60 seconds if not specified.

        Required?                    false
        Position?                    4
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Must be between 1 and 10
        seconds. Defaults to 3 seconds if not specified.

        Required?                    false
        Position?                    5
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image. This
        allows using custom or modified DeepStack images.

        Required?                    false
        Position?                    6
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        DeepStack API Documentation: POST /v1/vision/face/list endpoint

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-RegisteredFaces

    This example retrieves all registered faces using default parameters.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-RegisteredFaces -Force -UseGPU

    This example forces a rebuild of the container and uses GPU acceleration.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-RegisteredFaces -ContainerName "my_deepstack" -ServicePort 8080

    This example uses a custom container name and port number.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Get-RegisteredFaces |
    Where-Object { $_ -like "John*" }

    This example retrieves all faces and filters for those starting with "John".





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-ImageEnhancement

SYNOPSIS
    Enhances an image by enlarging it 4X while improving quality using DeepStack.


SYNTAX
    Invoke-ImageEnhancement [-ImagePath] <String> [[-OutputPath] <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function enhances an image by enlarging it to 4 times the original width
    and height while simultaneously increasing the quality of the image. It uses
    a local DeepStack image enhancement API running on a configurable port and
    returns the enhanced image as base64 data or saves it to a file. The function
    supports GPU acceleration and Docker container management.


PARAMETERS
    -ImagePath <String>
        The local path to the image file to enhance. This parameter accepts any valid
        file path that can be resolved by the system.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false

    -OutputPath <String>
        Optional path where the enhanced image should be saved. If not specified,
        the function returns the base64 encoded image data.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. This is typically used
        when already called by parent function to avoid duplicate initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This is useful for troubleshooting or updating the DeepStack image.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. This requires an
        NVIDIA GPU with proper Docker GPU support configured.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container. This allows multiple DeepStack instances
        or custom naming conventions. Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage. This ensures face data
        persists between container restarts. Default is "deepstack_face_data".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Must be between 1 and 65535.
        Default is 5000.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Must be between 10
        and 300 seconds. Default is 60.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Must be between 1 and 10
        seconds. Default is 3.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image. This
        allows using custom or updated DeepStack images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        DeepStack API Documentation: POST /v1/vision/enhance endpoint for image
        enhancement. Example: curl -X POST -F "image=@low_quality.jpg"
        http://localhost:5000/v1/vision/enhance

        The enhanced image will be 4 times larger (2x width, 2x height) than the
        original.
        ##############################################################################

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-ImageEnhancement -ImagePath "C:\Users\YourName\small_photo.jpg" `
                            -OutputPath "C:\Users\YourName\enhanced_photo.jpg"
    Enhances the image and saves it to the specified output path.






    -------------------------- EXAMPLE 2 --------------------------

    PS > enhanceimage "C:\photos\low_quality.jpg"
    Enhances the image and returns the base64 data and dimensions using alias.






    -------------------------- EXAMPLE 3 --------------------------

    PS > Invoke-ImageEnhancement -ImagePath "C:\photos\image.jpg" -UseGPU
    Enhances the image using GPU acceleration for faster processing.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Register-AllFaces

SYNOPSIS
    Updates all face recognition profiles from image files in the faces directory.


SYNTAX
    Register-AllFaces [[-FacesDirectory] <String>] [[-MaxRetries] <Int32>] [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-NoDockerInitialize] [-Force] [-RenameFailed] [-ForceRebuild] [-UseGPU] [-ShowWindow] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function updates the face recognition database with all images found in
    the specified faces directory. The process involves:
    1. Ensuring the face recognition service is running
    2. Processing all images in each person's folder, registering all faces for
       that person with a single identifier (the folder name) in a batch operation
    3. Supporting retry logic for failed registrations

    Each person's folder can contain multiple images, and all images will be
    registered under the same identifier (person name) in a single API call,
    eliminating the need for _1, _2, etc. suffixes.


PARAMETERS
    -FacesDirectory <String>
        The directory containing face images organized by person folders.
        If not specified, uses the configured faces directory from Set-AIKnownFacesRootpath.
        If no configuration exists, defaults to "b:\media\faces\"

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxRetries <Int32>
        Maximum number of retry attempts for failed registrations.
        Default: 3

        Required?                    false
        Position?                    2
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container.

        Required?                    false
        Position?                    3
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage.

        Required?                    false
        Position?                    4
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service.

        Required?                    false
        Position?                    5
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check.

        Required?                    false
        Position?                    6
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts.

        Required?                    false
        Position?                    7
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use.

        Required?                    false
        Position?                    8
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker Desktop initialization (used when already called by parent
        function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        If specified, forces re-registration of all faces.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RenameFailed [<SwitchParameter>]
        If specified, renames image files that fail with "400 Bad Request - Could not
        find any face" by adding a ".failed" extension to the filename.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceRebuild [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version (requires NVIDIA GPU).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Register-AllFaces -FacesDirectory "b:\media\faces\" -MaxRetries 3 `
        -ContainerName "deepstack_face_recognition" -VolumeName "deepstack_face_data" `
        -ServicePort 5000 -HealthCheckTimeout 60 -HealthCheckInterval 3






    -------------------------- EXAMPLE 2 --------------------------

    PS > Register-AllFaces
    Uses the configured faces directory from Set-AIKnownFacesRootpath or defaults to "b:\media\faces\"






    -------------------------- EXAMPLE 3 --------------------------

    PS > updatefaces -RenameFailed
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Register-Face

SYNOPSIS
    Registers a new face with the DeepStack face recognition API.


SYNTAX
    Register-Face [-Identifier] <String> [-ImagePath] <String[]> [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    This function registers a face image with the DeepStack face recognition API by
    uploading the image to the local API endpoint. It ensures the DeepStack
    service is running and validates the image file before upload. The function
    includes retry logic, error handling, and cleanup on failure.


PARAMETERS
    -Identifier <String>
        The unique identifier for the face (e.g., person's name). Cannot be empty or
        contain special characters.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImagePath <String[]>
        Array of local paths to image files (png, jpg, jpeg, or gif). All files must
        exist and be valid image formats. Multiple images can be registered for the
        same identifier in a single API call.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container.

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage.

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version (requires NVIDIA GPU).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Register-Face -Identifier "JohnDoe" -ImagePath @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")






    -------------------------- EXAMPLE 2 --------------------------

    PS > Register-Face "JohnDoe" @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")






    -------------------------- EXAMPLE 3 --------------------------

    PS > Register-Face -Identifier "JohnDoe" -ImagePath "C:\Users\YourName\faces\john.jpg"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Unregister-AllFaces

SYNOPSIS
    Removes all registered faces from the DeepStack face recognition system.


SYNTAX
    Unregister-AllFaces [-Force] [-NoDockerInitialize] [-ForceRebuild] [-UseGPU] [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-ShowWindow] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function clears all registered faces from the DeepStack face recognition
    database by removing all face files from the datastore directory and restarting
    the service to reload an empty face registry. This is a destructive operation
    that cannot be undone and will permanently remove all registered face data.


PARAMETERS
    -Force [<SwitchParameter>]
        Bypasses confirmation prompts when removing all registered faces.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker Desktop initialization. Used when already called by parent function
        to avoid duplicate initialization overhead.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceRebuild [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data. This will recreate
        the entire DeepStack container from scratch.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version of DeepStack. Requires NVIDIA GPU with proper
        Docker GPU support configured.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container running DeepStack face recognition service.

        Required?                    false
        Position?                    1
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume used for persistent storage of face data.

        Required?                    false
        Position?                    2
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack face recognition service HTTP API.

        Required?                    false
        Position?                    3
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check to pass after
        container operations.

        Required?                    false
        Position?                    4
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts when verifying service
        availability.

        Required?                    false
        Position?                    5
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image.

        Required?                    false
        Position?                    6
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Unregister-AllFaces

    Removes all registered faces with confirmation prompt.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Unregister-AllFaces -Force

    Removes all registered faces without confirmation prompt.




    -------------------------- EXAMPLE 3 --------------------------

    PS > unregall -Force

    Uses alias to remove all faces without confirmation.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Unregister-Face

SYNOPSIS
    Deletes a registered face by its identifier from DeepStack.


SYNTAX
    Unregister-Face [-Identifier] <String> [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function deletes a face from the DeepStack face recognition system using
    its unique identifier. It communicates with the API endpoint to remove the
    registered face data from the system permanently.


PARAMETERS
    -Identifier <String>
        The unique identifier of the face to delete from the DeepStack system.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container.

        Required?                    false
        Position?                    2
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage.

        Required?                    false
        Position?                    3
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service.

        Required?                    false
        Position?                    4
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check.

        Required?                    false
        Position?                    5
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts.

        Required?                    false
        Position?                    6
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use.

        Required?                    false
        Position?                    7
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version (requires NVIDIA GPU).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Boolean


NOTES


        DeepStack API Documentation: POST /v1/vision/face/delete endpoint
        This endpoint is used to remove a previously registered face from the system.

    -------------------------- EXAMPLE 1 --------------------------

    PS > Unregister-Face -Identifier "JohnDoe" -NoDockerInitialize $false `
        -ContainerName "deepstack_face_recognition" -ServicePort 5000






    -------------------------- EXAMPLE 2 --------------------------

    PS > rface "JohnDoe"







RELATED LINKS

<br/><hr/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.AI.LMStudio<hr/>
NAME
    Add-GenXdevMCPServerToLMStudio

SYNTAX
    Add-GenXdevMCPServerToLMStudio [[-ServerName] <string>] [[-Url] <string>]


PARAMETERS
    -ServerName <string>

        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Url <string>

        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false


INPUTS
    None


OUTPUTS
    System.Object

ALIASES
    None


REMARKS
    None

<br/><hr/><hr/><br/>

NAME
    EnsureLMStudio

SYNOPSIS
    Ensures LM Studio is properly initialized with the specified model.


SYNTAX
    EnsureLMStudio [[-Model] <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-TTLSeconds <Int32>] [-TimeoutSeconds <Int32>] [-LLMQueryType <String>] [-PreferencesDatabasePath <String>] [-Monitor <Int32>] [-ApiKey <String>] [-NoBorders] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-ShowWindow] [-Force] [-Unload] [-SessionOnly] [-ClearSession] [-SkipSession] [-NoLMStudioInitialize] [<CommonParameters>]


DESCRIPTION
    Initializes or reinitializes LM Studio with a specified model. This function
    handles process management, configuration settings, and ensures the proper model
    is loaded. It can force a restart if needed and manages window visibility.


PARAMETERS
    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        The time-to-live in seconds for cached AI responses.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Removes the borders of the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        The initial width of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        The initial height of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        The initial X position of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        The initial Y position of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Place window on the left side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Place window on the right side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Place window on the top side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Place window on the bottom side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Place window in the center of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]
        Maximize the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell window focus.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Will either set the window fullscreen on a different monitor than Powershell, or
        side by side with Powershell on the same monitor.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Focus the window after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Set the window to foreground after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Maximize the window after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Keystrokes to send to the Window, see documentation for cmdlet
        GenXdev.Windows\Send-Key.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show LM Studio window during initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]
        Unloads the specified model instead of loading it.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]
        Switch to skip LM-Studio initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > EnsureLMStudio -LLMQueryType "TextTranslation" -MaxToken 8192 -ShowWindow






    -------------------------- EXAMPLE 2 --------------------------

    PS > EnsureLMStudio -Model "mistral-7b" -TTLSeconds 3600 -Force







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-LMStudioLoadedModelList

SYNOPSIS
    Retrieves the list of currently loaded models from LM Studio.


SYNTAX
    Get-LMStudioLoadedModelList [<CommonParameters>]


DESCRIPTION
    Gets a list of all models that are currently loaded in LM Studio by querying
    the LM Studio process. Returns null if no models are loaded or if an error
    occurs. Requires LM Studio to be installed and accessible.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Management.Automation.PSObject[]


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-LMStudioLoadedModelList







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-LMStudioModelList

SYNOPSIS
    Retrieves a list of installed LM Studio models.


SYNTAX
    Get-LMStudioModelList [<CommonParameters>]


DESCRIPTION
    Gets a list of all models installed in LM Studio by executing the LM Studio CLI
    command and parsing its JSON output. Returns an array of model objects containing
    details about each installed model.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Object[]
    Returns an array of model objects containing details about installed models.


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-LMStudioModelList
    Retrieves all installed LM Studio models and returns them as objects.






    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-LMStudioModelList -Verbose
    Retrieves models while showing detailed progress information.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-LMStudioPaths

SYNOPSIS
    Retrieves file paths for LM Studio executables.


SYNTAX
    Get-LMStudioPaths [<CommonParameters>]


DESCRIPTION
    Searches common installation locations for LM Studio executables and returns their
    paths. The function maintains a cache of found paths to optimize performance on
    subsequent calls.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Collections.Hashtable
        Returns a hashtable with two keys:
        - LMStudioExe: Path to main LM Studio executable
        - LMSExe: Path to LMS command-line executable


    -------------------------- EXAMPLE 1 --------------------------

    PS > $paths = Get-LMStudioPaths
    Write-Output "LM Studio path: $($paths.LMStudioExe)"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-LMStudioTextEmbedding

SYNOPSIS
    Gets text embeddings from LM Studio model.


SYNTAX
    Get-LMStudioTextEmbedding [-Text] <String[]> [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-TTLSeconds <Int32>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-LLMQueryType <String>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-KeysToSend <String[]>] [-ShowWindow] [-Force] [-Unload] [-NoBorders] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SessionOnly] [-ClearSession] [-SkipSession] [-NoLMStudioInitialize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [<CommonParameters>]


DESCRIPTION
    Gets text embeddings for the provided text using LM Studio's API. Can work with
    both local and remote LM Studio instances. Handles model initialization and API
    communication for converting text into numerical vector representations.


PARAMETERS
    -Text <String[]>
        The text to get embeddings for. Can be a single string or an array of strings.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        The time-to-live in seconds for cached AI responses.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query for optimal model selection.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        The initial width of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        The initial height of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        The initial X position of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        The initial Y position of the window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Keystrokes to send to the Window, see documentation for cmdlet
        GenXdev.Windows\Send-Key.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force LM Studio restart before processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]
        Unload the specified model instead of loading it.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Remove the borders of the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Place window on the left side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Place window on the right side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Place window on the top side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Place window on the bottom side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Place window in the center of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]
        Maximize the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell window focus.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Set the window fullscreen on a different monitor than Powershell, or side by
        side with Powershell on the same monitor.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Focus the window after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Set the window to foreground after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Maximize the window after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]
        Switch to skip LM-Studio initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-LMStudioTextEmbedding -Text "Hello world" -Model "llama2" -ShowWindow






    -------------------------- EXAMPLE 2 --------------------------

    PS > "Sample text" | embed-text -TTLSeconds 3600







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-LMStudioWindow

SYNOPSIS
    Gets a window helper for the LM Studio application.


SYNTAX
    Get-LMStudioWindow [[-LLMQueryType] <String>] [[-Model] <String>] [[-HuggingFaceIdentifier] <String>] [[-MaxToken] <Int32>] [[-Cpu] <Int32>] [[-TTLSeconds] <Int32>] [[-TimeoutSeconds] <Int32>] [[-PreferencesDatabasePath] <String>] [-Unload] [-ShowWindow] [-Force] [-NoAutoStart] [-NoLMStudioInitialize] [[-Monitor] <Int32>] [-NoBorders] [[-Width] <Int32>] [[-Height] <Int32>] [[-X] <Int32>] [[-Y] <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-PassThru] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [[-KeysToSend] <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [[-SendKeyDelayMilliSeconds] <Int32>] [-SessionOnly] [-ClearSession] [-SkipSession] [[-ApiKey] <String>] [<CommonParameters>]


DESCRIPTION
    Gets a window helper for the LM Studio application. If LM Studio is not running,
    it will be started automatically unless prevented by NoAutoStart switch.
    The function handles process management and window positioning, model loading,
    and configuration. Provides comprehensive window manipulation capabilities
    including positioning, sizing, focusing, and keyboard input automation.


PARAMETERS
    -LLMQueryType <String>
        The type of LLM query to use for AI operations. Valid values include
        SimpleIntelligence, Knowledge, Pictures, TextTranslation, Coding, and ToolUse.

        Required?                    false
        Position?                    1
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier for loading specific AI models.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    5
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        The time-to-live in seconds for cached AI responses.

        Required?                    false
        Position?                    6
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    7
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    8
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]
        Switch to unload the specified model instead of loading it.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Switch to show LM Studio window during initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Switch to force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoAutoStart [<SwitchParameter>]
        Switch to prevent automatic start of LM Studio if not running.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard.

        Required?                    false
        Position?                    9
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Removes the borders of the LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        The initial width of the LM Studio window.

        Required?                    false
        Position?                    10
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        The initial height of the LM Studio window.

        Required?                    false
        Position?                    11
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        The initial X position of the LM Studio window.

        Required?                    false
        Position?                    12
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        The initial Y position of the LM Studio window.

        Required?                    false
        Position?                    13
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Place LM Studio window on the left side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Place LM Studio window on the right side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Place LM Studio window on the top side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Place LM Studio window on the bottom side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Place LM Studio window in the center of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]
        Maximize the LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell window focus after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Returns the window helper for each process.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Will either set the LM Studio window fullscreen on a different monitor than
        Powershell, or side by side with Powershell on the same monitor.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Focus the LM Studio window after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Set the LM Studio window to foreground after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Maximize the LM Studio window after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Keystrokes to send to the LM Studio Window, see documentation for cmdlet
        GenXdev.Windows\Send-Key.

        Required?                    false
        Position?                    14
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Escape control characters and modifiers when sending keys to LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Hold keyboard focus on target LM Studio window when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Use Shift+Enter instead of Enter when sending keys to LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between different input strings in milliseconds when sending keys to
        LM Studio window.

        Required?                    false
        Position?                    15
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>

        Required?                    false
        Position?                    16
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-LMStudioWindow -Model "llama-2" -MaxToken 4096 -ShowWindow






    -------------------------- EXAMPLE 2 --------------------------

    PS > lmstudiowindow "qwen2.5-14b-instruct" -TTLSeconds 3600







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Initialize-LMStudioModel

SYNOPSIS
    Initializes and loads an AI model in LM Studio.


SYNTAX
    Initialize-LMStudioModel [-Force] [-Unload] [[-LLMQueryType] <String>] [[-Model] <String>] [[-HuggingFaceIdentifier] <String>] [[-MaxToken] <Int32>] [[-Cpu] <Int32>] [[-TTLSeconds] <Int32>] [[-TimeoutSeconds] <Int32>] [[-PreferencesDatabasePath] <String>] [-ShowWindow] [[-Monitor] <Int32>] [-NoBorders] [[-Width] <Int32>] [[-Height] <Int32>] [[-X] <Int32>] [[-Y] <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-PassThru] [-SideBySide] [-FocusWindow] [-SetForeground] [[-ApiKey] <String>] [-Maximize] [[-KeysToSend] <String[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [[-SendKeyDelayMilliSeconds] <Int32>] [-SessionOnly] [-ClearSession] [-SkipSession] [-NoLMStudioInitialize] [<CommonParameters>]


DESCRIPTION
    Searches for and loads a specified AI model in LM Studio. Handles installation
    verification, process management, and model loading with GPU support.


PARAMETERS
    -Force [<SwitchParameter>]
        Switch to force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]
        Switch to unload the specified model instead of loading it.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to use for AI operations.

        Required?                    false
        Position?                    1
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        Name or partial path of the model to initialize. Searched against available models.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The specific LM-Studio model identifier to use for download/initialization.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        Maximum tokens allowed in response. -1 for default limit.

        Required?                    false
        Position?                    4
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    5
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        Time-to-live in seconds for loaded models. -1 for no TTL.

        Required?                    false
        Position?                    6
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    7
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    8
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Switch to show LM Studio window during initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>

        Required?                    false
        Position?                    9
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    10
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    11
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>

        Required?                    false
        Position?                    12
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>

        Required?                    false
        Position?                    13
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>

        Required?                    false
        Position?                    14
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>

        Required?                    false
        Position?                    15
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    16
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Switch to use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Switch to clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Switch to store settings only in persistent preferences without affecting
        session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]
        Switch to skip LM-Studio initialization (used when already called by parent function).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ShowWindow -MaxToken 2048

    ##############################################################################





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Install-LMStudioApplication

SYNOPSIS
    Installs LM Studio application using WinGet package manager.


SYNTAX
    Install-LMStudioApplication [<CommonParameters>]


DESCRIPTION
    Ensures LM Studio is installed on the system by checking WinGet dependencies and
    installing LM Studio if not already present. Uses WinGet module with CLI fallback.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Install-LMStudioApplication







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Start-LMStudioApplication

SYNOPSIS
    Starts the LM Studio application if it's not already running.


SYNTAX
    Start-LMStudioApplication [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function checks if LM Studio is installed and running. If not installed, it
    will install it. If not running, it will start it with the specified window
    visibility.


PARAMETERS
    -Passthru [<SwitchParameter>]
        When specified, returns the Process object of the LM Studio application.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Start-LMStudioApplication -ShowWindow -Passthru







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Test-LMStudioInstallation

SYNOPSIS
    Tests if LMStudio is installed and accessible on the system.


SYNTAX
    Test-LMStudioInstallation [<CommonParameters>]


DESCRIPTION
    Verifies the LMStudio installation by checking if the executable exists at the
    expected path location. Uses Get-LMStudioPaths helper function to determine the
    installation path and validates the executable's existence.


PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Boolean


    -------------------------- EXAMPLE 1 --------------------------

    PS > Test-LMStudioInstallation
    Returns $true if LMStudio is properly installed, $false otherwise.






    -------------------------- EXAMPLE 2 --------------------------

    PS > tlms
    Uses the alias to check LMStudio installation status.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Test-LMStudioProcess

SYNOPSIS
    Tests if LM Studio process is running and configures its window state.


SYNTAX
    Test-LMStudioProcess [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    Checks if LM Studio is running, and if so, returns true. If not running, it
    returns false.


PARAMETERS
    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Boolean


    -------------------------- EXAMPLE 1 --------------------------

    PS > [bool] $lmStudioRunning = Test-LMStudioProcess







RELATED LINKS

<br/><hr/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.AI.Queries<hr/>
NAME
    Add-EmoticonsToText

SYNOPSIS
    Enhances text by adding contextually appropriate emoticons using AI.


SYNTAX
    Add-EmoticonsToText [[-Text] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function processes input text to add emoticons that match the emotional
    context. It can accept input directly through parameters, from the pipeline, or
    from the system clipboard. The function leverages AI models to analyze the text
    and select appropriate emoticons, making messages more expressive and engaging.


PARAMETERS
    -Text <String>
        The input text to enhance with emoticons. If not provided, the function will
        read from the system clipboard. Multiple lines of text are supported.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        Additional instructions to guide the AI model in selecting and placing emoticons.
        These can help fine-tune the emotional context and style of added emoticons.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
        all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
        layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
        offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        When specified, copies the enhanced text back to the system clipboard after
        processing is complete.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Add-EmoticonsToText -Text "Hello, how are you today?" -Model "qwen" `
        -SetClipboard






    -------------------------- EXAMPLE 2 --------------------------

    PS > "Time to celebrate!" | emojify
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Add-ImageDirectories

SYNOPSIS
    Adds directories to the configured image directories for GenXdev.AI operations.


SYNTAX
    Add-ImageDirectories [-ImageDirectories] <String[]> [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function adds one or more directory paths to the existing image directories
    configuration used by the GenXdev.AI module. It updates both the global variable
    and the module's preference storage to persist the configuration across sessions.
    Duplicate directories are automatically filtered out to prevent configuration
    redundancy. Paths are expanded to handle relative paths and environment
    variables automatically.


PARAMETERS
    -ImageDirectories <String[]>
        An array of directory paths to add to the existing image directories
        configuration. Paths can be relative or absolute and will be expanded
        automatically. Duplicates are filtered out using case-insensitive comparison.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Add-ImageDirectories -ImageDirectories @("C:\NewPhotos", "D:\MoreImages")

    Adds the specified directories to the existing image directories configuration
    using full parameter names.




    -------------------------- EXAMPLE 2 --------------------------

    PS > addimgdir @("C:\Temp\Photos", "E:\Backup\Images")

    Uses alias to add multiple directories to the configuration with positional
    parameters.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    ConvertFrom-CorporateSpeak

SYNOPSIS
    Converts polite, professional corporate speak into direct, clear language using AI.


SYNTAX
    ConvertFrom-CorporateSpeak [[-Text] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function processes input text to transform diplomatic, corporate
    communications into more direct and clear language. It can accept input directly
    through parameters, from the pipeline, or from the system clipboard. The function
    leverages AI models to analyze and rephrase text while preserving the original
    intent.


PARAMETERS
    -Text <String>
        The corporate speak text to convert to direct language. If not provided, the
        function will read from the system clipboard. Multiple lines of text are
        supported.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to use for processing the text transformation.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        Specifies which AI model to use for text transformation. Different models may
        produce varying results in terms of language style.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        Identifier used for getting specific model from LM Studio.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. -2=Auto, -1=LMStudio decides, 0=Off, 0-1=Layer
        fraction.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key to use for the request.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        When specified, copies the transformed text back to the system clipboard.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Shows the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        Maximum tokens in response (-1 for default).

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > ConvertFrom-CorporateSpeak -Text "I would greatly appreciate your timely response" -SetClipboard






    -------------------------- EXAMPLE 2 --------------------------

    PS > "We should circle back" | uncorporatize
    ###############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    ConvertFrom-DiplomaticSpeak

SYNOPSIS
    Converts diplomatic or tactful language into direct, clear, and
    straightforward language.


SYNTAX
    ConvertFrom-DiplomaticSpeak [[-Text] <String>] [[-Instructions] <String>] [-Temperature <Double>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-SessionOnly] [-ClearSession] [-SkipSession] [-Attachments <Object[]>] [-ImageDetail <String>] [-Functions <Object[]>] [-ExposedCmdLets <Object[]>] [-NoConfirmationToolFunctionNames <String[]>] [-DontAddThoughtsToHistory] [-ContinueLast] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-TTLSeconds <Int32>] [-Monitor] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-CpuThreads <Int32>] [-SuppressRegex <String[]>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left <Int32>] [-Bottom <Int32>] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function takes diplomatic speak and translates it to reveal the true
    meaning behind polite or politically correct language. It uses AI language
    models to transform euphemistic expressions into direct statements, making
    communication unambiguous and easy to understand. The function is particularly
    useful for analyzing political statements, business communications, or any text
    where the real meaning might be obscured by diplomatic language.


PARAMETERS
    -Text <String>
        The text to convert from diplomatic speak. This can be provided through the
        pipeline.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        Additional instructions for the AI model to customize the transformation
        process.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0). Lower values produce more
        consistent outputs while higher values increase creativity.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to use for the transformation process.

        Required?                    false
        Position?                    named
        Default value                Knowledge
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier for Hugging Face models.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If
        'max', all layers are offloaded to GPU. If a number between 0 and 1, that
        fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
        how much to offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations when using external services.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations with external services.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations to prevent hanging.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files storage.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        Copy the transformed text to clipboard after processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing for monitoring AI operations.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization to ensure clean startup.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <Object[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Object[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <Object[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > ConvertFrom-DiplomaticSpeak -Text "We have some concerns about your
    approach"






    -------------------------- EXAMPLE 2 --------------------------

    PS > undiplomatize "Your proposal has merit but requires further consideration"






    -------------------------- EXAMPLE 3 --------------------------

    PS > "We're putting you on timeout" |
        ConvertFrom-DiplomaticSpeak -SetClipboard -Temperature 0.2







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    ConvertTo-CorporateSpeak

SYNOPSIS
    Converts direct or blunt text into polite, professional corporate speak using AI.


SYNTAX
    ConvertTo-CorporateSpeak [[-Text] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function processes input text to transform direct or potentially harsh
    language into diplomatic, professional corporate communications. It can accept
    input directly through parameters, from the pipeline, or from the system
    clipboard. The function leverages AI models to analyze and rephrase text while
    preserving the original intent.


PARAMETERS
    -Text <String>
        The input text to convert to corporate speak. If not provided, the function
        will read from the system clipboard. Multiple lines of text are supported.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If
        'max', all layers are offloaded to GPU. If a number between 0 and 1, that
        fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
        how much to offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        When specified, copies the transformed text back to the system clipboard.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Shows the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > ConvertTo-CorporateSpeak -Text "That's a terrible idea" -Model "qwen"
        -SetClipboard






    -------------------------- EXAMPLE 2 --------------------------

    PS > "This makes no sense" | corporatize







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    ConvertTo-DiplomaticSpeak

SYNOPSIS
    Converts direct or blunt text into polite, tactful diplomatic language.


SYNTAX
    ConvertTo-DiplomaticSpeak [[-Text] <String>] [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function transforms user input from direct or blunt phrasing into
    diplomatic, tactful language suitable for high-level discussions, negotiations,
    or formal communications. The function uses AI language models to maintain
    the original intent while softening the tone and making the message more
    diplomatic and professional.


PARAMETERS
    -Text <String>
        The text to convert to diplomatic speak.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
        all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
        layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
        offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]
        Copy the transformed text to clipboard.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > ConvertTo-DiplomaticSpeak -Text "Your proposal is terrible" -Temperature 0.2 `
        -SetClipboard -ShowWindow






    -------------------------- EXAMPLE 2 --------------------------

    PS > diplomatize "Your code is full of bugs"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Export-ImageDatabase

SYNOPSIS
    Initializes and populates the SQLite database by discovering images directly.


SYNTAX
    Export-ImageDatabase [[-InputObject] <Object[]>] [[-DatabaseFilePath] <String>] [-ImageDirectories <String[]>] [-PathLike <String[]>] [-Language <String>] [-FacesDirectory <String>] [-EmbedImages] [-ForceIndexRebuild] [-NoFallback] [-NeverRebuild] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [-ShowWindow] [<CommonParameters>]


DESCRIPTION
    Creates a SQLite database with optimized schema for fast image searching based on
    metadata including keywords, people, objects, scenes, and descriptions. The function
    always deletes any existing database file and creates a fresh one, discovers images
    using Find-Image from specified directories or configured image directories, and
    populates the database directly without requiring a metadata JSON file. Finally,
    it creates indexes for optimal performance.


PARAMETERS
    -InputObject <Object[]>
        Accepts search results from a Find-Image call to regenerate the view.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -DatabaseFilePath <String>
        Path to the SQLite database file. If not specified, uses the default location
        under Storage\allimages.meta.db.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDirectories <String[]>
        Array of directory paths to search for images. If not specified, uses the
        configured image directories from Get-AIImageCollection.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PathLike <String[]>
        Array of directory path-like search strings to filter images by path (SQL LIKE
        patterns, e.g. '%\\2024\\%').

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>
        The directory containing face images organized by person folders. If not
        specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]
        Embed images as base64.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceIndexRebuild [<SwitchParameter>]
        Force rebuild of the image index database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoFallback [<SwitchParameter>]
        Switch to disable fallback behavior.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NeverRebuild [<SwitchParameter>]
        Switch to skip database initialization and rebuilding.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Export-ImageDatabase -DatabaseFilePath "C:\Custom\Path\images.db" `
        -ImageDirectories @("C:\Photos", "D:\Images") -EmbedImages






    -------------------------- EXAMPLE 2 --------------------------

    PS > indexcachedimages







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Find-Image

SYNTAX
    Find-Image [[-Any] <string[]>] [[-DatabaseFilePath] <string>] [-ImageDirectories <string[]>] [-PathLike <string[]>] [-Language {Afrikaans | Akan | Albanian | Amharic | Arabic | Armenian | Azerbaijani | Basque | Belarusian | Bemba | Bengali | Bihari | Bork, bork, bork! | Bosnian | Breton | Bulgarian | Cambodian | Catalan | Cherokee | Chichewa | Chinese (Simplified) | Chinese (Traditional) | Corsican | Croatian | Czech | Danish | Dutch | Elmer Fudd | English | Esperanto | Estonian | Ewe | Faroese | Filipino | Finnish | French | Frisian | Ga | Galician | Georgian | German | Greek | Guarani | Gujarati | Hacker | Haitian Creole | Hausa | Hawaiian | Hebrew | Hindi | Hungarian | Icelandic | Igbo | Indonesian | Interlingua | Irish | Italian | Japanese | Javanese | Kannada | Kazakh | Kinyarwanda | Kirundi | Klingon | Kongo | Korean | Krio (Sierra Leone) | Kurdish | Kurdish (Soranî) | Kyrgyz | Laothian | Latin | Latvian | Lingala | Lithuanian | Lozi | Luganda | Luo | Macedonian | Malagasy | Malay | Malayalam | Maltese | Maori | Marathi | Mauritian Creole | Moldavian | Mongolian | Montenegrin | Nepali | Nigerian Pidgin | Northern Sotho | Norwegian | Norwegian (Nynorsk) | Occitan | Oriya | Oromo | Pashto | Persian | Pirate | Polish | Portuguese (Brazil) | Portuguese (Portugal) | Punjabi | Quechua | Romanian | Romansh | Runyakitara | Russian | Scots Gaelic | Serbian | Serbo-Croatian | Sesotho | Setswana | Seychellois Creole | Shona | Sindhi | Sinhalese | Slovak | Slovenian | Somali | Spanish | Spanish (Latin American) | Sundanese | Swahili | Swedish | Tajik | Tamil | Tatar | Telugu | Thai | Tigrinya | Tonga | Tshiluba | Tumbuka | Turkish | Turkmen | Twi | Uighur | Ukrainian | Urdu | Uzbek | Vietnamese | Welsh | Wolof | Xhosa | Yiddish | Yoruba | Zulu}] [-FacesDirectory <string>] [-DescriptionSearch <string[]>] [-Keywords <string[]>] [-People <string[]>] [-Objects <string[]>] [-Scenes <string[]>] [-InputObject <Object[]>] [-PictureType <string[]>] [-StyleType <string[]>] [-OverallMood <string[]>] [-MetaCameraMake <string[]>] [-MetaCameraModel <string[]>] [-MetaGPSLatitude <double[]>] [-MetaGPSLongitude <double[]>] [-MetaGPSAltitude <double[]>] [-GeoLocation <double[]>] [-GeoDistanceInMeters <double>] [-MetaExposureTime <double[]>] [-MetaFNumber <double[]>] [-MetaISO <int[]>] [-MetaFocalLength <double[]>] [-MetaWidth <int[]>] [-MetaHeight <int[]>] [-MetaDateTaken <datetime[]>] [-Title <string>] [-Description <string>] [-AcceptLang <string>] [-KeysToSend <string[]>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <int>] [-FocusWindow] [-SetForeground] [-Maximize] [-Monitor <int>] [-Width <int>] [-Height <int>] [-X <int>] [-Y <int>] [-PreferencesDatabasePath <string>] [-EmbedImages] [-ForceIndexRebuild] [-NoFallback] [-NeverRebuild] [-HasNudity] [-NoNudity] [-HasExplicitContent] [-NoExplicitContent] [-ShowInBrowser] [-PassThru] [-NoBorders] [-SideBySide] [-Interactive] [-Private] [-Force] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-FullScreen] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-OnlyReturnHtml] [-ShowOnlyPictures] [-SessionOnly] [-ClearSession] [-SkipSession] [-AutoScrollPixelsPerSecond <int>] [-AutoAnimateRectangles] [-SingleColumnMode] [-ImageUrlPrefix <string>] [-AllDrives] [-NoRecurse] [<CommonParameters>]


PARAMETERS
    -AcceptLang <string>
        Set the browser accept-lang http header

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      lang, locale
        Dynamic?                     false
        Accept wildcard characters?  false

    -All
        Opens in all registered modern browsers

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -AllDrives
        Search across all available drives

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Any <string[]>
        Will match any of all the possible meta data types.

        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ApplicationMode
        Hide the browser controls

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      a, app, appmode
        Dynamic?                     false
        Accept wildcard characters?  false

    -AutoAnimateRectangles
        Animate rectangles (objects/faces) in visible range, cycling every 300ms

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -AutoScrollPixelsPerSecond <int>
        Auto-scroll the page by this many pixels per second (null to disable)

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Bottom
        Place browser window on the bottom side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Centered
        Place browser window in the center of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Chrome
        Opens in Google Chrome

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ch
        Dynamic?                     false
        Accept wildcard characters?  false

    -Chromium
        Opens in Microsoft Edge or Google Chrome, depending on what the default browser is

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      c
        Dynamic?                     false
        Accept wildcard characters?  false

    -ClearSession
        Clear alternative settings stored in session for AI preferences like Language, Image collections, etc

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DatabaseFilePath <string>
        The path to the image database file. If not specified, a default path is used.

        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Description <string>
        Description for the gallery

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DescriptionSearch <string[]>
        The description text to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DisablePopupBlocker
        Disable the popup blocker

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      allowpopups
        Dynamic?                     false
        Accept wildcard characters?  false

    -Edge
        Opens in Microsoft Edge

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      e
        Dynamic?                     false
        Accept wildcard characters?  false

    -EmbedImages
        Embed images as base64.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FacesDirectory <string>
        The directory containing face images organized by person folders. If not specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Firefox
        Opens in Firefox

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ff
        Dynamic?                     false
        Accept wildcard characters?  false

    -FocusWindow
        Focus the browser window after opening

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false

    -Force
        Force enable debugging port, stopping existing browsers if needed

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ForceIndexRebuild
        Force rebuild of the image index database.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FullScreen
        Opens in fullscreen mode

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs, f
        Dynamic?                     false
        Accept wildcard characters?  false

    -GeoDistanceInMeters <double>
        Maximum distance in meters from GeoLocation to search for images.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -GeoLocation <double[]>
        Geographic coordinates [latitude, longitude] to search near.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -HasExplicitContent
        Filter images that contain explicit content.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -HasNudity
        Filter images that contain nudity.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Height <int>
        The initial height of the webbrowser window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ImageDirectories <string[]>
        Array of directory paths to search for images

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      imagespath, directories, imgdirs, imagedirectory
        Dynamic?                     false
        Accept wildcard characters?  false

    -ImageUrlPrefix <string>
        Prefix to prepend to each image path (e.g. for remote URLs)

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -InputObject <Object[]>
        Accepts search results from a previous -PassThru call to regenerate the view.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Interactive
        Will connect to browser and adds additional buttons like Edit and Delete. Only effective when used with -ShowInBrowser.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      i, editimages
        Dynamic?                     false
        Accept wildcard characters?  false

    -KeysToSend <string[]>
        Keystrokes to send to the Browser window, see documentation for cmdlet GenXdev.Windows\Send-Key

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Keywords <string[]>
        The keywords to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Language <string>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Left
        Place browser window on the left side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Maximize
        Maximize the window after positioning

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaCameraMake <string[]>
        Filter by camera make in image EXIF metadata. Supports wildcards.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaCameraModel <string[]>
        Filter by camera model in image EXIF metadata. Supports wildcards.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaDateTaken <datetime[]>
        Filter by date taken from EXIF metadata. Can be a date range.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaExposureTime <double[]>
        Filter by exposure time range in image EXIF metadata (in seconds).

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaFNumber <double[]>
        Filter by F-number (aperture) range in image EXIF metadata.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaFocalLength <double[]>
        Filter by focal length range in image EXIF metadata (in mm).

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaGPSAltitude <double[]>
        Filter by GPS altitude range in image EXIF metadata (in meters).

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaGPSLatitude <double[]>
        Filter by GPS latitude range in image EXIF metadata.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaGPSLongitude <double[]>
        Filter by GPS longitude range in image EXIF metadata.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaHeight <int[]>
        Filter by image height range in pixels from EXIF metadata.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaISO <int[]>
        Filter by ISO sensitivity range in image EXIF metadata.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MetaWidth <int[]>
        Filter by image width range in pixels from EXIF metadata.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Monitor <int>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to Global:DefaultSecondaryMonitor or 2 if not found

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false

    -NeverRebuild
        Switch to skip database initialization and rebuilding.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NewWindow
        Don't re-use existing browser window, instead, create a new one

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nw, new
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoBorders
        Remove window borders and title bar for a cleaner appearance

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoBrowserExtensions
        Prevent loading of browser extensions

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      de, ne, NoExtensions
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoExplicitContent
        Filter images that do NOT contain explicit content.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoFallback
        Switch to disable fallback behavior.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoNudity
        Filter images that do NOT contain nudity.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoRecurse
        Do not recurse into subdirectories

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Objects <string[]>
        Objects to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OnlyReturnHtml
        Only return the generated HTML instead of displaying it in a browser.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OverallMood <string[]>
        Overall mood to filter by (e.g., 'calm', 'cheerful', 'sad', etc). Supports wildcards.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PassThru
        Return image data as objects. When used with -ShowInBrowser, both displays the gallery and returns the objects.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      pt
        Dynamic?                     false
        Accept wildcard characters?  false

    -PathLike <string[]>
        Array of directory path-like search strings to filter images by path (SQL LIKE patterns, e.g. '%\\2024\\%')

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -People <string[]>
        People to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PictureType <string[]>
        Picture type to filter by (e.g., 'daylight', 'evening', 'indoor', etc). Supports wildcards.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PreferencesDatabasePath <string>
        Database path for preference data files

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DatabasePath
        Dynamic?                     false
        Accept wildcard characters?  false

    -Private
        Opens in incognito/private browsing mode

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      incognito, inprivate
        Dynamic?                     false
        Accept wildcard characters?  false

    -RestoreFocus
        Restore PowerShell window focus

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false

    -Right
        Place browser window on the right side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Scenes <string[]>
        Scene categories to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <int>
        Delay between different input strings in milliseconds when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyEscape
        Escape control characters and modifiers when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus
        Prevent returning keyboard focus to PowerShell after sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter
        Use Shift+Enter instead of Enter when sending keys

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false

    -SessionOnly
        Use alternative settings stored in session for AI preferences like Language, Image collections, etc

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SetForeground
        Set the browser window to foreground after opening

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false

    -ShowInBrowser
        Display the search results in a browser-based image gallery.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      show, s
        Dynamic?                     false
        Accept wildcard characters?  false

    -ShowOnlyPictures
        Show only pictures in a rounded rectangle, no text below.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      NoMetadata, OnlyPictures
        Dynamic?                     false
        Accept wildcard characters?  false

    -SideBySide
        Place browser window side by side with PowerShell on the same monitor

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false

    -SingleColumnMode
        Force single column layout (centered, 1/3 screen width)

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SkipSession
        Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false

    -StyleType <string[]>
        Style type to filter by (e.g., 'casual', 'formal', etc). Supports wildcards.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Title <string>
        Title for the gallery

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Top
        Place browser window on the top side of the screen

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Width <int>
        The initial width of the webbrowser window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -X <int>
        The initial X position of the webbrowser window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Y <int>
        The initial Y position of the webbrowser window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).


INPUTS
    System.Object[]


OUTPUTS
    System.Object[]
    System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=9.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]
    System.String


ALIASES
    findimages
    li


REMARKS
    None

<br/><hr/><hr/><br/>

NAME
    Find-IndexedImage

SYNOPSIS
    Searches for images using an optimized SQLite database with fast indexed lookups.


SYNTAX
    Find-IndexedImage [[-Any] <String[]>] [-DatabaseFilePath <String>] [-ImageDirectories <String[]>] [-PathLike <String[]>] [-Language <String>] [-FacesDirectory <String>] [-DescriptionSearch <String[]>] [-Keywords <String[]>] [-People <String[]>] [-Objects <String[]>] [-Scenes <String[]>] [-PictureType <String[]>] [-StyleType <String[]>] [-OverallMood <String[]>] [-InputObject <Object[]>] [-EmbedImages] [-ForceIndexRebuild] [-NoFallback] [-NeverRebuild] [-HasNudity] [-NoNudity] [-HasExplicitContent] [-NoExplicitContent] [-ShowInBrowser] [-PassThru] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-NoBorders] [-SideBySide] [-Title <String>] [-Description <String>] [-AcceptLang <String>] [-Monitor <Int32>] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-ShowOnlyPictures] [-Interactive] [-Private] [-Force] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-ShowWindow] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-OnlyReturnHtml] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-AutoScrollPixelsPerSecond <Int32>] [-AutoAnimateRectangles] [-SingleColumnMode] [-ImageUrlPrefix <String>] [-AllDrives] [-NoRecurse] [-MetaCameraMake <String[]>] [-MetaCameraModel <String[]>] [-MetaGPSLatitude <Double[]>] [-MetaGPSLongitude <Double[]>] [-MetaGPSAltitude <Double[]>] [-MetaExposureTime <Double[]>] [-MetaFNumber <Double[]>] [-MetaISO <Int32[]>] [-MetaFocalLength <Double[]>] [-MetaWidth <Int32[]>] [-MetaHeight <Int32[]>] [-MetaDateTaken <DateTime[]>] [-GeoLocation <Double[]>] [-GeoDistanceInMeters <Double>] [<CommonParameters>]


DESCRIPTION
    Performs high-performance image searches using a pre-built SQLite database with
    optimized indexes. This function provides the same search capabilities as
    Find-Image but with significantly faster performance by eliminating file system
    scans and using database indexes for all search criteria.


PARAMETERS
    -Any <String[]>
        Will match any of all the possible meta data types.

        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DatabaseFilePath <String>
        The path to the image database file. If not specified, a default path is used.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDirectories <String[]>
        Array of directory paths to search for images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PathLike <String[]>
        Array of directory path-like search strings to filter images by path (SQL LIKE
        patterns, e.g. '%\2024\%').

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>
        The directory containing face images organized by person folders. If not
        specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DescriptionSearch <String[]>
        The description text to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Keywords <String[]>
        The keywords to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -People <String[]>
        People to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Objects <String[]>
        Objects to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Scenes <String[]>
        Scenes to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PictureType <String[]>
        Picture types to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -StyleType <String[]>
        Style types to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OverallMood <String[]>
        Overall moods to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -InputObject <Object[]>
        Accepts search results from a previous -PassThru call to regenerate the view.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]
        Embed images as base64.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceIndexRebuild [<SwitchParameter>]
        Force rebuild of the image index database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoFallback [<SwitchParameter>]
        Switch to disable fallback behavior.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NeverRebuild [<SwitchParameter>]
        Switch to skip database initialization and rebuilding.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HasNudity [<SwitchParameter>]
        Filter images that contain nudity.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoNudity [<SwitchParameter>]
        Filter images that do NOT contain nudity.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HasExplicitContent [<SwitchParameter>]
        Filter images that contain explicit content.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoExplicitContent [<SwitchParameter>]
        Filter images that do NOT contain explicit content.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowInBrowser [<SwitchParameter>]
        Show results in a browser gallery.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Return image data as objects.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Escape control characters and modifiers when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Prevents returning keyboard focus to PowerShell after sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Use Shift+Enter instead of Enter when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between different input strings in milliseconds when sending keys.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Remove window borders and title bar for a cleaner appearance.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Place browser window side by side with PowerShell on the same monitor.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Title <String>
        Title for the image gallery.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Description <String>
        Description for the image gallery.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AcceptLang <String>
        Browser accept-language header.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        Monitor to use for display.

        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        Initial width of browser window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        Initial height of browser window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        Initial X position of browser window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        Initial Y position of browser window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowOnlyPictures [<SwitchParameter>]
        Show only pictures in a rounded rectangle, no text below.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Interactive [<SwitchParameter>]
        Enable interactive browser features.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Private [<SwitchParameter>]
        Open in private/incognito mode.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force enable debugging port.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Edge [<SwitchParameter>]
        Open in Microsoft Edge.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chrome [<SwitchParameter>]
        Open in Google Chrome.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chromium [<SwitchParameter>]
        Open in Chromium-based browser.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Firefox [<SwitchParameter>]
        Open in Firefox.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -All [<SwitchParameter>]
        Open in all browsers.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Place window on left side.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Place window on right side.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Place window on top.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Place window on bottom.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Center the window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApplicationMode [<SwitchParameter>]
        Hide browser controls.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBrowserExtensions [<SwitchParameter>]
        Disable browser extensions.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DisablePopupBlocker [<SwitchParameter>]
        Disable popup blocker.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell focus.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NewWindow [<SwitchParameter>]
        Create new browser window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyReturnHtml [<SwitchParameter>]
        Only return HTML.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Focus the browser window after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Set the browser window to foreground after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Maximize the browser window after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Array of key combinations to send to the browser after opening (e.g., @('F11', 'Ctrl+Shift+I')).

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoScrollPixelsPerSecond <Int32>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoAnimateRectangles [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SingleColumnMode [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageUrlPrefix <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllDrives [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoRecurse [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaCameraMake <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaCameraModel <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaGPSLatitude <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaGPSLongitude <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaGPSAltitude <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaExposureTime <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaFNumber <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaISO <Int32[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaFocalLength <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaWidth <Int32[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaHeight <Int32[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MetaDateTaken <DateTime[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -GeoLocation <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -GeoDistanceInMeters <Double>

        Required?                    false
        Position?                    named
        Default value                1000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Object[]

    System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=9.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Find-IndexedImage -Keywords "cat","dog" -ShowInBrowser -NoNudity






    -------------------------- EXAMPLE 2 --------------------------

    PS > lii "cat","dog" -ShowInBrowser -NoNudity







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-AIImageCollection

SYNOPSIS
    Gets the configured directories for image files used in GenXdev.AI operations.


SYNTAX
    Get-AIImageCollection [[-ImageDirectories] <String[]>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function retrieves the global image directories used by the GenXdev.AI
    module for various image processing and AI operations. It returns the
    configuration from both global variables and the module's preference storage,
    with fallback to system defaults.

    The function follows a priority order: first checks global variables (unless
    SkipSession is specified), then falls back to persistent preferences (unless
    SessionOnly is specified), and finally uses system default directories.


PARAMETERS
    -ImageDirectories <String[]>
        Optional default value to return if no image directories are configured. If
        not specified, returns the system default directories (Downloads, OneDrive,
        Pictures).

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear the session setting (Global variable) before retrieving.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-AIImageCollection

    Gets the currently configured image directories from Global variables or
    preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-AIImageCollection -SkipSession

    Gets the configured image directories only from persistent preferences,
    ignoring any session setting.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-AIImageCollection -ClearSession

    Clears the session image directories setting and then gets the directories
    from persistent preferences.




    -------------------------- EXAMPLE 4 --------------------------

    PS > $config = Get-AIImageCollection -ImageDirectories @("C:\MyImages")

    Returns configured directories or the specified default if none are configured.




    -------------------------- EXAMPLE 5 --------------------------

    PS > getimgdirs

    Uses alias to get the current image directory configuration.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-AIKnownFacesRootpath

SYNOPSIS
    Gets the configured directory for face image files used in GenXdev.AI
    operations.


SYNTAX
    Get-AIKnownFacesRootpath [[-FacesDirectory] <String>] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function retrieves the global face directory used by the GenXdev.AI
    module for various face recognition and AI operations. It checks Global
    variables first (unless SkipSession is specified), then falls back to
    persistent preferences, and finally uses system defaults.


PARAMETERS
    -FacesDirectory <String>
        Optional faces directory override. If specified, this directory will be
        returned instead of retrieving from configuration.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear the session setting (Global variable) before retrieving

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-AIKnownFacesRootpath

    Gets the currently configured faces directory from Global variables or
    preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-AIKnownFacesRootpath -SkipSession

    Gets the configured faces directory only from persistent preferences, ignoring
    any session setting.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-AIKnownFacesRootpath -ClearSession

    Clears the session faces directory setting and then gets the directory from
    persistent preferences.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Get-AIKnownFacesRootpath "C:\MyFaces"

    Returns the specified directory after expanding the path.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-AIMetaLanguage

SYNOPSIS
    Gets the configured default language for image metadata operations.


SYNTAX
    Get-AIMetaLanguage [[-Language] <String>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function retrieves the default language used by the GenXdev.AI module
    for image metadata operations. It checks Global variables first (unless
    SkipSession is specified), then falls back to persistent preferences, and
    finally uses system defaults.


PARAMETERS
    -Language <String>
        Optional language override. If specified, this language will be returned
        instead of retrieving from configuration.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear the session setting (Global variable) before retrieving the
        configuration.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-AIMetaLanguage

    Gets the currently configured language from Global variables or preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-AIMetaLanguage -SkipSession

    Gets the configured language only from persistent preferences, ignoring any
    session setting.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Get-AIMetaLanguage -ClearSession

    Clears the session language setting and then gets the language from
    persistent preferences.




    -------------------------- EXAMPLE 4 --------------------------

    PS > getimgmetalang

    Uses alias to get the current language configuration.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-Fallacy

SYNOPSIS
    Analyzes text to identify logical fallacies using AI-powered detection.


SYNTAX
    Get-Fallacy [-Text] <String[]> [[-Instructions] <String>] [[-Attachments] <String[]>] [-Functions <Hashtable[]>] [-ImageDetail <String>] [-NoConfirmationToolFunctionNames <String[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-Temperature <Double>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-ContinueLast] [-Force] [-IncludeThoughts] [-NoSessionCaching] [-OpenInImdb] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-ShowWindow] [-Speak] [-SpeakThoughts] [-SessionOnly] [-ClearSession] [-SkipSession] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-SendKeyDelayMilliSeconds <Int32>] [-DontAddThoughtsToHistory] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left <Int32>] [-Right <Int32>] [-Bottom <Int32>] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    This function analyzes provided text to detect logical fallacies using an AI
    model trained on Wikipedia's List of Fallacies. It returns detailed information
    about each fallacy found, including the specific quote, fallacy name,
    description, explanation, and formal classification. The function uses a
    structured response format to ensure consistent output.


PARAMETERS
    -Text <String[]>
        The text content to analyze for logical fallacies. Can accept multiple text
        inputs through pipeline or array.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        Additional instructions for the AI model on how to analyze the text or focus
        on specific types of fallacies.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>
        Array of file paths to attach to the analysis request for additional context.

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of custom function definitions to make available to the AI model during
        analysis.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Detail level for image processing when attachments include images. Options are
        low, medium, or high.

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of function names that don't require user confirmation before execution
        when used by the AI model.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions that the AI model can use as tools
        during analysis.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Controls the randomness of the AI response. Lower values (0.0-0.3) provide
        more focused analysis, higher values (0.7-1.0) allow more creative
        interpretation.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform for the analysis.

        Required?                    false
        Position?                    named
        Default value                Knowledge
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
        all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
        layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
        offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Switch to continue from the last conversation context instead of starting a
        new analysis session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Forces LM Studio to stop and restart before initializing the model for
        analysis.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]
        Switch to include the model's reasoning process in the output alongside the
        final analysis.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Switch to disable storing the analysis session in the session cache for
        privacy or performance reasons.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OpenInImdb [<SwitchParameter>]
        Switch to open IMDB searches for each detected fallacy result (legacy parameter
        from inherited function structure).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Switch to display the LM Studio window during processing for monitoring
        purposes.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]
        Switch to enable text-to-speech output for the AI analysis results.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]
        Switch to enable text-to-speech output for the AI model's reasoning process
        when IncludeThoughts is enabled.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Object[]


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-Fallacy -Text ("All politicians are corrupt because John was corrupt " +
    "and he was a politician")

    Analyzes the provided text for logical fallacies and returns structured
    information about any fallacies detected.




    -------------------------- EXAMPLE 2 --------------------------

    PS > "This product is the best because everyone uses it" | Get-Fallacy -Temperature 0.1

    Uses pipeline input to analyze text with low temperature for focused analysis.




    -------------------------- EXAMPLE 3 --------------------------

    PS > dispicetext "Everyone knows this is true"

    Uses the alias to analyze text for logical fallacies.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-ImageDatabasePath

SYNOPSIS
    Returns the path to the image database, initializing or rebuilding it if needed.


SYNTAX
    Get-ImageDatabasePath [[-DatabaseFilePath] <String>] [-ImageDirectories <String[]>] [-PathLike <String[]>] [-Language <String>] [-FacesDirectory <String>] [-EmbedImages] [-ForceIndexRebuild] [-NoFallback] [-NeverRebuild] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function determines the correct path for the image database file, checks if
    it exists and is up to date, and initializes or rebuilds it if required. It
    supports options for language, embedding images, forcing index rebuilds, and
    filtering images by directory or path patterns. The function returns the path to
    the database file, or $null if initialization fails.


PARAMETERS
    -DatabaseFilePath <String>
        The path to the image database file. If not specified, a default path is used.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDirectories <String[]>
        An array of directory paths to search for images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PathLike <String[]>
        An array of SQL LIKE patterns to filter images by path (e.g. '%\\2024\\%').

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>
        The directory containing face images organized by person folders. If not
        specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]
        Switch to embed images as base64 in the database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceIndexRebuild [<SwitchParameter>]
        Switch to force a rebuild of the image index database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoFallback [<SwitchParameter>]
        Switch to disable fallback behavior.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NeverRebuild [<SwitchParameter>]
        Switch to skip database initialization and rebuilding.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-ImageDatabasePath -DatabaseFilePath "C:\\Temp\\mydb.db" `
        -ImageDirectories "C:\\Images" `
        -PathLike '%\\2024\\%' `
        -Language 'English' `
        -EmbedImages `
        -ForceIndexRebuild






    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-ImageDatabasePath







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-ImageDatabaseStats

SYNOPSIS
    Retrieves comprehensive statistics and information about the image database.


SYNTAX
    Get-ImageDatabaseStats [[-DatabaseFilePath] <String>] [-ImageDirectories <String[]>] [-PathLike <String[]>] [-Language <String>] [-FacesDirectory <String>] [-PreferencesDatabasePath <String>] [-EmbedImages] [-ForceIndexRebuild] [-ShowDetails] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    Provides detailed statistics about the SQLite image database including record
    counts, index usage, most common keywords, people, objects, and scenes. Useful
    for understanding database health and content distribution.


PARAMETERS
    -DatabaseFilePath <String>
        The path to the image database file. If not specified, a default path is used.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDirectories <String[]>
        Array of directory paths to search for images.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PathLike <String[]>
        Array of directory path-like search strings to filter images by path (SQL LIKE
        patterns, e.g. '%\\2024\\%').

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>
        The directory containing face images organized by person folders. If not
        specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]
        Embed images as base64.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceIndexRebuild [<SwitchParameter>]
        Force rebuild of the image index database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowDetails [<SwitchParameter>]
        Show detailed statistics including top keywords, people, objects, and scenes.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-ImageDatabaseStats






    -------------------------- EXAMPLE 2 --------------------------

    PS > Get-ImageDatabaseStats -ShowDetails






    -------------------------- EXAMPLE 3 --------------------------

    PS > gids -ShowDetails







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-MediaFileAudioTranscription

SYNOPSIS
    Transcribes an audio or video file to text.


SYNTAX
    Get-MediaFileAudioTranscription [-FilePath] <String> [[-LanguageIn] <String>] [[-LanguageOut] <String>] [-TokenTimestampsSumThreshold <Single>] [-MaxTokensPerSegment <Int32>] [-MaxDurationOfSilence <Object>] [-SilenceThreshold <Int32>] [-CpuThreads <Int32>] [-Temperature <Single>] [-TemperatureInc <Single>] [-Prompt <String>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-MaxDuration <Object>] [-Offset <Object>] [-MaxLastTextTokens <Int32>] [-MaxSegmentLength <Int32>] [-MaxInitialTimestamp <Object>] [-LengthPenalty <Single>] [-EntropyThreshold <Single>] [-LogProbThreshold <Single>] [-NoSpeechThreshold <Single>] [-PreferencesDatabasePath <String>] [-WithTokenTimestamps] [-SplitOnWord] [-IgnoreSilence] [-WithProgress] [-DontSuppressBlank] [-SingleSegmentOnly] [-PrintSpecialTokens] [-NoContext] [-WithBeamSearchSamplingStrategy] [-SRT] [-PassThru] [-UseDesktopAudioCapture] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    Transcribes an audio or video file to text using the Whisper AI model. The
    function can handle various audio and video formats, convert them to the
    appropriate format for transcription, and optionally translate the output
    to a different language. Supports SRT subtitle format output and various
    audio processing parameters for fine-tuning the transcription quality.


PARAMETERS
    -FilePath <String>
        The file path of the audio or video file to transcribe.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LanguageIn <String>
        The language to expect in the audio. E.g. "English", "French", "German", "Dutch"

        Required?                    false
        Position?                    2
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LanguageOut <String>
        The language to translate to. E.g. "french", "german", "dutch"

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TokenTimestampsSumThreshold <Single>
        Sum threshold for token timestamps, defaults to 0.5.

        Required?                    false
        Position?                    named
        Default value                0.5
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxTokensPerSegment <Int32>
        Maximum number of tokens per segment.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxDurationOfSilence <Object>
        Maximum duration of silence before automatically stopping recording.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Int32>
        Silence detect threshold (0..32767 defaults to 30)

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>
        Number of CPU threads to use, defaults to 0 (auto).

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Single>
        Temperature for speech recognition.

        Required?                    false
        Position?                    named
        Default value                0.01
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureInc <Single>
        Temperature increment.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Prompt <String>
        Prompt to use for the model.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>
        Regex to suppress tokens from the output.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>
        Size of the audio context.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxDuration <Object>
        Maximum duration of the audio.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Offset <Object>
        Offset for the audio.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxLastTextTokens <Int32>
        Maximum number of last text tokens.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxSegmentLength <Int32>
        Maximum segment length.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxInitialTimestamp <Object>
        Start timestamps at this moment.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Single>
        Length penalty.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Single>
        Entropy threshold.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Single>
        Log probability threshold.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Single>
        No speech threshold.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithTokenTimestamps [<SwitchParameter>]
        Whether to include token timestamps in the output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SplitOnWord [<SwitchParameter>]
        Whether to split on word boundaries.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IgnoreSilence [<SwitchParameter>]
        Whether to ignore silence (will mess up timestamps).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithProgress [<SwitchParameter>]
        Whether to show progress.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSuppressBlank [<SwitchParameter>]
        Whether to NOT suppress blank lines.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SingleSegmentOnly [<SwitchParameter>]
        Whether to use single segment only.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PrintSpecialTokens [<SwitchParameter>]
        Whether to print special tokens.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]
        Don't use context.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]
        Use beam search sampling strategy.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SRT [<SwitchParameter>]
        Output in SRT format.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Returns objects instead of strings.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]
        Whether to use desktop audio capture instead of microphone input

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-MediaFileAudioTranscription -FilePath "C:\path\to\audio.wav" `
        -LanguageIn "English" -LanguageOut "French" -SRT






    -------------------------- EXAMPLE 2 --------------------------

    PS > transcribefile "C:\video.mp4" "English"
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Get-ScriptExecutionErrorFixPrompt

SYNTAX
    Get-ScriptExecutionErrorFixPrompt [-Script] <scriptblock> [-Temperature <double>] [-LLMQueryType {SimpleIntelligence | Knowledge | Pictures | TextTranslation | Coding | ToolUse}] [-Model <string>] [-HuggingFaceIdentifier <string>] [-MaxToken <int>] [-Cpu <int>] [-Gpu <int>] [-ApiEndpoint <string>] [-ApiKey <string>] [-TimeoutSeconds <int>] [-PreferencesDatabasePath <string>] [-Functions <hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <string[]>] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-SessionOnly] [-ClearSession] [-SkipSession] [-Attachments <Object>] [-ImageDetail <Object>] [-TTLSeconds <Object>] [-Monitor <Object>] [-Width <Object>] [-Height <Object>] [-SendKeyDelayMilliSeconds <Object>] [-IncludeThoughts <Object>] [-OutputMarkdownBlocksOnly <Object>] [-MarkupBlocksTypeFilter <Object>] [-ChatOnce <Object>] [-NoLMStudioInitialize <Object>] [-Unload <Object>] [-NoBorders <Object>] [-Left <Object>] [-Right <Object>] [-Bottom <Object>] [-Centered <Object>] [-FullScreen <Object>] [-RestoreFocus <Object>] [-SideBySide <Object>] [-FocusWindow <Object>] [-SetForeground <Object>] [-Maximize <Object>] [-SendKeyEscape <Object>] [-SendKeyHoldKeyboardFocus <Object>] [-SendKeyUseShiftEnter <Object>] [-MaxToolcallBackLength <Object>] [-AudioTemperature <Object>] [-TemperatureResponse <Object>] [-Language <Object>] [-CpuThreads <Object>] [-SuppressRegex <Object>] [-AudioContextSize <Object>] [-SilenceThreshold <Object>] [-LengthPenalty <Object>] [-EntropyThreshold <Object>] [-LogProbThreshold <Object>] [-NoSpeechThreshold <Object>] [-DontSpeak <Object>] [-DontSpeakThoughts <Object>] [-NoVOX <Object>] [-UseDesktopAudioCapture <Object>] [-NoContext <Object>] [-WithBeamSearchSamplingStrategy <Object>] [-OnlyResponses <Object>] [<CommonParameters>]


PARAMETERS
    -ApiEndpoint <string>
        The API endpoint URL for AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ApiKey <string>
        The API key for authenticated AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Attachments <Object>
        Attachments to include in the LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -AudioContextSize <Object>
        Audio context size for LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -AudioTemperature <Object>
        Temperature for audio generation.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Bottom <Object>
        Set window position: bottom.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Centered <Object>
        Center the window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ChatOnce <Object>
        Run chat only once for the LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ClearSession
        Clear alternative settings stored in session for AI preferences

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ContinueLast
        Continue from last conversation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Cpu <int>
        The number of CPU cores to dedicate to AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -CpuThreads <Object>
        Number of CPU threads to use.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory
        Include model's thoughts in output

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontSpeak <Object>
        Do not speak audio output.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontSpeakThoughts <Object>
        Do not speak model thoughts.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -EntropyThreshold <Object>
        Entropy threshold for LLM output.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FocusWindow <Object>
        Focus the LLM Studio window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fw, focus
        Dynamic?                     false
        Accept wildcard characters?  false

    -Force
        Force stop LM Studio before initialization

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FullScreen <Object>
        Set window to fullscreen.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fs
        Dynamic?                     false
        Accept wildcard characters?  false

    -Functions <hashtable[]>
        Array of function definitions

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Gpu <int>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max', all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Height <Object>
        Height of the LLM Studio window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <string>
        The LM Studio specific model identifier

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ModelLMSGetIdentifier
        Dynamic?                     false
        Accept wildcard characters?  false

    -ImageDetail <Object>
        Level of image detail for LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -IncludeThoughts <Object>
        Include model thoughts in the LLM response.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -LLMQueryType <string>
        The type of LLM query

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Language <Object>
        Language for LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Left <Object>
        Set window position: left.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -LengthPenalty <Object>
        Length penalty for LLM output.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -LogProbThreshold <Object>
        Log probability threshold for LLM output.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <Object>
        Filter for markup block types in the LLM response.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MaxToken <int>
        The maximum number of tokens to use in AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Object>
        Maximum tool call back length for LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Maximize <Object>
        Maximize the LLM Studio window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Model <string>
        The model identifier or pattern to use for AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Monitor <Object>
        Monitor to use for LLM Studio window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      m, mon
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoBorders <Object>
        Do not show window borders.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      nb
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <string[]>
        Array of command names that don't require confirmation

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      NoConfirmationFor
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoContext <Object>
        Do not use context for LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoLMStudioInitialize <Object>
        Do not initialize LM Studio.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoSessionCaching
        Don't store session in session cache

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoSpeechThreshold <Object>
        No speech threshold for audio processing.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoVOX <Object>
        Disable VOX for audio output.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OnlyResponses <Object>
        Return only responses from LLM.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly <Object>
        Output only markup blocks from the LLM response.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PreferencesDatabasePath <string>
        Database path for preference data files

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DatabasePath
        Dynamic?                     false
        Accept wildcard characters?  false

    -RestoreFocus <Object>
        Restore focus to previous window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      rf, bg
        Dynamic?                     false
        Accept wildcard characters?  false

    -Right <Object>
        Set window position: right.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Script <scriptblock>
        The script to execute and analyze for errors

        Required?                    true
        Position?                    0
        Accept pipeline input?       true (ByValue)
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Object>
        Delay in milliseconds between sending keys.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DelayMilliSeconds
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyEscape <Object>
        Send Escape key to LLM Studio.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      Escape
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus <Object>
        Hold keyboard focus when sending keys.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      HoldKeyboardFocus
        Dynamic?                     false
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter <Object>
        Use Shift+Enter when sending keys.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      UseShiftEnter
        Dynamic?                     false
        Accept wildcard characters?  false

    -SessionOnly
        Use alternative settings stored in session for AI preferences

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SetForeground <Object>
        Set LLM Studio window to foreground.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      fg
        Dynamic?                     false
        Accept wildcard characters?  false

    -ShowWindow
        Show the LM Studio window

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SideBySide <Object>
        Show LLM Studio and script side by side.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      sbs
        Dynamic?                     false
        Accept wildcard characters?  false

    -SilenceThreshold <Object>
        Silence threshold for audio processing.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SkipSession
        Store settings only in persistent preferences without affecting session

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false

    -Speak
        Enable text-to-speech for AI responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SpeakThoughts
        Enable text-to-speech for AI thought responses

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SuppressRegex <Object>
        Regular expression to suppress output.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -TTLSeconds <Object>
        Time-to-live in seconds for the LLM query.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Temperature <double>
        Temperature for response randomness (0.0-1.0)

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -TemperatureResponse <Object>
        Temperature for response generation.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -TimeoutSeconds <int>
        The timeout in seconds for AI operations

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Unload <Object>
        Unload LM Studio after operation.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -UseDesktopAudioCapture <Object>
        Use desktop audio capture.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Width <Object>
        Width of the LLM Studio window.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy <Object>
        Use beam search sampling strategy.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).


INPUTS
    System.Management.Automation.ScriptBlock


OUTPUTS
    System.Object[]


ALIASES
    getfixprompt


REMARKS
    None

<br/><hr/><hr/><br/>

NAME
    Get-SimularMovieTitles

SYNOPSIS
    Finds similar movie titles based on common properties.


SYNTAX
    Get-SimularMovieTitles [-Movies] <String[]> [[-LLMQueryType] <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-Temperature <Double>] [-OpenInImdb] [-ShowWindow] [-Language <String>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AcceptLang <String>] [-Private] [-Chrome] [-Chromium] [-Firefox] [-Left <Int32>] [-Right <Int32>] [-Bottom <Int32>] [-Centered] [-FullScreen] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-FocusWindow] [-SetForeground] [-Maximize] [-RestoreFocus] [-NewWindow] [-ReturnURL] [-ReturnOnlyURL] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-NoBorders] [-SideBySide] [-Force] [-SessionOnly] [-ClearSession] [-SkipSession] [-Instructions <String>] [-Attachments <String[]>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SetClipboard] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-TTLSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    Analyzes the provided movies to find common properties and returns a list of 10
    similar movie titles. Uses AI to identify patterns and themes across the input
    movies to suggest relevant recommendations.


PARAMETERS
    -Movies <String[]>
        Array of movie titles to analyze for similarities.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query.

        Required?                    false
        Position?                    2
        Default value                Knowledge
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
        all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
        layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
        offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OpenInImdb [<SwitchParameter>]
        Opens IMDB searches for each result in default browser.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AcceptLang <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Private [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chrome [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chromium [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Firefox [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApplicationMode [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBrowserExtensions [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DisablePopupBlocker [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NewWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ReturnURL [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ReturnOnlyURL [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Get-SimularMovieTitles -Movies "The Matrix","Inception" -OpenInImdb






    -------------------------- EXAMPLE 2 --------------------------

    PS > moremovietitles "The Matrix","Inception" -imdb







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-AIPowershellCommand

SYNOPSIS
    Generates and executes PowerShell commands using AI assistance.


SYNTAX
    Invoke-AIPowershellCommand [-Query] <String> [[-Attachments] <String[]>] [-Temperature <Double>] [-ImageDetail <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-SetClipboard] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-AllowDefaultTools] [-SessionOnly] [-ClearSession] [-SkipSession] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-Height <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-SendKeyDelayMilliSeconds <Int32>] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-NoLMStudioInitialize] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    Uses LM-Studio or other AI models to generate PowerShell commands based on
    natural language queries. The function can either send commands directly to
    the PowerShell window or copy them to the clipboard. It leverages AI models
    to interpret natural language and convert it into executable PowerShell
    commands with comprehensive parameter support for various AI backends.


PARAMETERS
    -Query <String>
        The natural language description of what you want to accomplish. The AI will
        convert this into an appropriate PowerShell command.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Attachments <String[]>

        Required?                    false
        Position?                    3
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Controls the randomness in the AI's response generation. Values range from
        0.0 (more focused/deterministic) to 1.0 (more creative/random).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                low
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform. Determines the AI model's behavior and
        response style for different use cases.

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations. Can be a name or
        partial path with support for pattern matching.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier for Hugging Face models.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations for performance
        optimization.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If
        'max', all layers are offloaded to GPU. If a number between 0 and 1, that
        fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide
        how much to offload to the GPU. -2 = Auto

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations when using external AI services.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations with external services.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations to prevent hanging requests.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files to store AI configuration settings.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetClipboard [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during AI command generation for monitoring
        purposes.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization to ensure clean startup state.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllowDefaultTools [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences instead of
        persistent configuration.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences and reset
        to defaults.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session
        state.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations to control response
        length and processing time.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between different input strings in milliseconds when sending keys to
        the PowerShell window.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Escape control characters and modifiers when sending keys to the PowerShell
        window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Hold keyboard focus on target window when sending keys to the PowerShell
        window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Use Shift+Enter instead of Enter when sending keys to the PowerShell window.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Void


    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-AIPowershellCommand -Query "list all running processes" -Model "qwen"

    Generates a PowerShell command to list running processes using the qwen model.




    -------------------------- EXAMPLE 2 --------------------------

    PS > hint "list files modified today"

    Uses the alias to generate a command for finding files modified today.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Invoke-AIPowershellCommand -Query "stop service" -Clipboard

    Generates a command to stop a service and copies it to clipboard.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-ImageFacesUpdate

SYNOPSIS
    Updates face recognition metadata for image files in a specified directory.


SYNTAX
    Invoke-ImageFacesUpdate [[-ImageDirectories] <String>] [-Recurse] [-OnlyNew] [-RetryFailed] [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-ConfidenceThreshold <Double>] [-Language <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSecond <Int32>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-FacesDirectory <String>] [-PreferencesDatabasePath <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [-PassThru] [-AutoUpdateFaces] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function processes images in a specified directory to identify and analyze
    faces using AI recognition technology. It creates or updates metadata files
    containing face information for each image. The metadata is stored in a
    separate file with the same name as the image but with a ':people.json' suffix.


PARAMETERS
    -ImageDirectories <String>
        The directory path containing images to process. Can be relative or absolute.
        Default is the current directory.

        Required?                    false
        Position?                    1
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Recurse [<SwitchParameter>]
        If specified, processes images in the specified directory and all subdirectories.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyNew [<SwitchParameter>]
        If specified, only processes images that don't already have face metadata files.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RetryFailed [<SwitchParameter>]
        If specified, retries processing previously failed images (empty metadata files).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container. Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage. Default is
        "deepstack_face_data".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service. Default is 5000.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check. Default is 60.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts. Default is 3.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ConfidenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0.7
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  true

    -HuggingFaceIdentifier <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSecond <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        = 8192,

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. Used when already called by
        parent function.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch is
        used.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoUpdateFaces [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-ImageFacesUpdate -ImageDirectories "C:\Photos" -Recurse






    -------------------------- EXAMPLE 2 --------------------------

    PS > facerecognition "C:\Photos" -RetryFailed -OnlyNew
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-ImageKeywordUpdate

SYNOPSIS
    Updates image metadata with AI-generated descriptions and keywords.


SYNTAX
    Invoke-ImageKeywordUpdate [[-ImageDirectories] <String>] [-Recurse] [-OnlyNew] [-RetryFailed] [-Language <String>] [-FacesDirectory <String>] [[-Instructions] <String>] [-ResponseFormat <String>] [-Temperature <Double>] [-ImageDetail <String>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-ShowWindow] [-NoLMStudioInitialize] [-Force] [-IncludeThoughts] [-SessionOnly] [-ClearSession] [-SkipSession] [-Functions <String[]>] [-ExposedCmdLets <String[]>] [-NoConfirmationToolFunctionNames <String[]>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-Height <Int32>] [-SendKeyDelayMilliSeconds <Int32>] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-ChatOnce] [-NoSessionCaching] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [-PassThru] [-AutoUpdateFaces] [<CommonParameters>]


DESCRIPTION
    The Invoke-ImageKeywordUpdate function analyzes images using AI to generate
    descriptions, keywords, and other metadata. It creates a companion JSON file for
    each image containing this information. The function can process new images only
    or update existing metadata, and supports recursive directory scanning.


PARAMETERS
    -ImageDirectories <String>
        Specifies the directory containing images to process. Defaults to current
        directory if not specified.

        Required?                    false
        Position?                    1
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Recurse [<SwitchParameter>]
        When specified, searches for images in the specified directory and all
        subdirectories.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyNew [<SwitchParameter>]
        When specified, only processes images that don't already have metadata JSON
        files.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RetryFailed [<SwitchParameter>]
        When specified, reprocesses images where previous metadata generation attempts
        failed.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Specifies the language for generated descriptions and keywords. Defaults to
        English.

        Required?                    false
        Position?                    named
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ResponseFormat <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>

        Required?                    false
        Position?                    named
        Default value                high
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>

        Required?                    false
        Position?                    named
        Default value                Pictures
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ChatOnce [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoUpdateFaces [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-ImageKeywordUpdate -ImageDirectories "C:\Photos" -Recurse -OnlyNew






    -------------------------- EXAMPLE 2 --------------------------

    PS > updateimages -Recurse -RetryFailed -Language "Spanish"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-ImageMetadataUpdate

SYNOPSIS
    Updates EXIF metadata for images in a directory.


SYNTAX
    Invoke-ImageMetadataUpdate [[-ImageDirectories] <String[]>] [-RetryFailed] [-NoRecurse] [-RedoAll] [-Force] [-PassThru] [-SessionOnly] [-ClearSession] [-SkipSession] [-PreferencesDatabasePath <String>] [<CommonParameters>]


DESCRIPTION
    This function extracts and updates EXIF metadata for images in specified directories.
    It processes each image to extract detailed EXIF metadata including camera details,
    GPS coordinates, exposure settings, and other technical information. The metadata
    is stored in alternate NTFS streams as :EXIF.json for later use by indexing and
    search functions.


PARAMETERS
    -ImageDirectories <String[]>
        Array of directory paths to process for image metadata updates.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RetryFailed [<SwitchParameter>]
        Specifies whether to retry previously failed image metadata updates.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoRecurse [<SwitchParameter>]
        Don't recurse into subdirectories when processing images.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RedoAll [<SwitchParameter>]
        Forces reprocessing of all images regardless of previous processing status.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuilding of metadata even if it already exists.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Return structured objects instead of outputting to console.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Don't use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-ImageMetadataUpdate -ImageDirectories "C:\Photos" -Force






    -------------------------- EXAMPLE 2 --------------------------

    PS > Invoke-ImageMetadataUpdate -RedoAll -PassThru | Export-Csv -Path metadata-log.csv







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-ImageObjectsUpdate

SYNOPSIS
    Updates object detection metadata for image files in a specified directory.


SYNTAX
    Invoke-ImageObjectsUpdate [[-ImageDirectories] <String>] [-Recurse] [-OnlyNew] [-RetryFailed] [-Language <String>] [-NoLMStudioInitialize] [-Force] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-TTLSeconds <Int32>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-ShowWindow] [-Monitor <Int32>] [-NoBorders] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-PassThru] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-KeysToSend <String[]>] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function processes images in a specified directory to detect objects using
    artificial intelligence. It creates JSON metadata files containing detected
    objects, their positions, confidence scores, and labels. The function supports
    batch processing with configurable confidence thresholds and can optionally
    skip existing metadata files or retry previously failed detections.


PARAMETERS
    -ImageDirectories <String>
        The directory path containing images to process. Can be relative or absolute
        path. Default is the current directory.

        Required?                    false
        Position?                    1
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Recurse [<SwitchParameter>]
        If specified, processes images in the specified directory and all
        subdirectories recursively.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyNew [<SwitchParameter>]
        If specified, only processes images that don't already have object metadata
        files or have empty metadata files.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RetryFailed [<SwitchParameter>]
        If specified, retries processing previously failed images that have empty
        metadata files or contain error indicators.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This will recreate the entire detection environment.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>

        Required?                    false
        Position?                    named
        Default value                SimpleIntelligence
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -Recurse

    This example processes all images in C:\Photos and all subdirectories using
    default settings with 0.5 confidence threshold.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Invoke-ImageObjectsUpdate "C:\Photos" -RetryFailed -OnlyNew

    This example processes only new images and retries previously failed ones
    in the C:\Photos directory using positional parameter syntax.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -UseGPU `
        -ConfidenceThreshold 0.7

    This example uses GPU acceleration with higher confidence threshold of 0.7
    for more accurate but fewer object detections.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-ImageScenesUpdate

SYNOPSIS
    Updates scene classification metadata for image files in a specified directory.


SYNTAX
    Invoke-ImageScenesUpdate [[-ImageDirectories] <String>] [-Recurse] [-OnlyNew] [-RetryFailed] [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-ConfidenceThreshold <Double>] [-Language <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSecond <Int32>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-FacesDirectory <String>] [-PreferencesDatabasePath <String>] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [-PassThru] [-AutoUpdateFaces] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function processes images in a specified directory to classify scenes using
    artificial intelligence. It creates JSON metadata files containing scene
    classifications, confidence scores, and labels. The function supports batch
    processing with configurable confidence thresholds and can optionally skip
    existing metadata files or retry previously failed classifications.


PARAMETERS
    -ImageDirectories <String>
        The directory path containing images to process. Can be relative or absolute
        path. Default is the current directory.

        Required?                    false
        Position?                    1
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Recurse [<SwitchParameter>]
        If specified, processes images in the specified directory and all
        subdirectories recursively.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyNew [<SwitchParameter>]
        If specified, only processes images that don't already have scene metadata
        files or have empty metadata files.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RetryFailed [<SwitchParameter>]
        If specified, retries processing previously failed images that have empty
        metadata files or contain error indicators.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container running the scene classification service.
        Default is "deepstack_face_recognition".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage of classification models
        and data. Default is "deepstack_face_data".

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack service to listen on. Must be between
        1 and 65535. Default is 5000.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check before timing out.
        Must be between 10 and 300 seconds. Default is 60.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts when waiting for service
        startup. Must be between 1 and 10 seconds. Default is 3.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use instead of the default DeepStack image.
        Allows using alternative scene classification models or configurations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ConfidenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0.7
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  true

    -HuggingFaceIdentifier <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSecond <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        = 8192,

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when this switch is used. Used when already called
        by parent function to avoid redundant container setup.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data when this switch
        is used. This will recreate the entire scene classification environment.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU
        with appropriate drivers and CUDA support.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoUpdateFaces [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        This function stores scene classification data in NTFS alternative data streams
        as 'ImageFile.jpg:scenes.json' files. Each metadata file contains scene
        classification results with confidence scores and scene labels from DeepStack's
        365 scene categories including places like: abbey, airplane_cabin, beach,
        forest, kitchen, office, etc.
        ##############################################################################

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-ImageScenesUpdate -ImageDirectories "C:\Photos" -Recurse

    Processes all images in C:\Photos and subdirectories for scene classification.




    -------------------------- EXAMPLE 2 --------------------------

    PS > scenerecognition "C:\Photos" -RetryFailed -OnlyNew

    Uses alias to retry failed classifications and only process new images.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Invoke-ImageScenesUpdate -ImageDirectories ".\MyImages" -Force -UseGPU

    Forces container rebuild and uses GPU acceleration for faster processing.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Invoke-ImageScenesUpdate -ImageDirectories "C:\Photos" -ConfidenceThreshold 0.6 -Recurse

    Processes all images recursively and only stores scene classifications with confidence >= 60%.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Invoke-QueryImageContent

SYNOPSIS
    Analyzes image content using AI vision capabilities through the LM-Studio API.


SYNTAX
    Invoke-QueryImageContent [-Query] <String> [-ImagePath] <String> [[-Instructions] <String>] [-ResponseFormat <String>] [-Temperature <Double>] [-ImageDetail <String>] [-LLMQueryType <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-ShowWindow] [-NoLMStudioInitialize] [-Force] [-IncludeThoughts] [-SessionOnly] [-ClearSession] [-SkipSession] [-Functions <String[]>] [-ExposedCmdLets <String[]>] [-NoConfirmationToolFunctionNames <String[]>] [-TTLSeconds <Int32>] [-Monitor <String>] [-Width <Int32>] [-AudioTemperature <Double>] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Double>] [-LengthPenalty <Double>] [-EntropyThreshold <Double>] [-LogProbThreshold <Double>] [-NoSpeechThreshold <Double>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-Height <Int32>] [-SendKeyDelayMilliSeconds <Int32>] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-OutputMarkdownBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-ChatOnce] [-NoSessionCaching] [-Unload] [-NoBorders] [-Left] [-Right] [-Bottom] [-Centered] [-FullScreen] [-RestoreFocus] [-SideBySide] [-FocusWindow] [-SetForeground] [-Maximize] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-MaxToolcallBackLength <Int32>] [<CommonParameters>]


DESCRIPTION
    Processes images using a specified model via the LM-Studio API to analyze
    content and answer queries about the image. The function supports various
    analysis parameters including temperature control for response randomness and
    token limits for output length.


PARAMETERS
    -Query <String>
        Specifies the question or prompt to analyze the image content. This drives the
        AI's analysis focus and determines what aspects of the image to examine.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImagePath <String>
        The path to the image file for analysis. Supports both relative and absolute
        paths. The file must exist and be accessible.

        Required?                    true
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Instructions <String>
        System instructions for the model to follow during the analysis.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ResponseFormat <String>
        A JSON schema that specifies the requested output format for the response.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Controls the randomness in the AI's response generation. Lower values (closer
        to 0) produce more focused and deterministic responses, while higher values
        increase creativity and variability. Valid range: 0.0 to 1.0.

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDetail <String>
        Sets the detail level for image analysis.
        Valid values are "low", "medium", or "high".

        Required?                    false
        Position?                    named
        Default value                high
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform. Defaults to "Pictures" for image analysis.

        Required?                    false
        Position?                    named
        Default value                Pictures
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        Specifies how much of the model to offload to the GPU.
        - "off": Disables GPU offloading.
        - "max": Offloads all layers to the GPU.
        - 0 to 1: Offloads a fraction of layers to the GPU.
        - -1: Lets LM Studio decide the offload amount.
        - -2: Uses an automatic setting.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        If specified, the LM Studio window will be shown.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        If specified, forces LM Studio to stop before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IncludeThoughts [<SwitchParameter>]
        If specified, includes the model's thoughts in the output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioTemperature <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureResponse <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>

        Required?                    false
        Position?                    named
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Double>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoVOX [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyResponses [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OutputMarkdownBlocksOnly [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MarkupBlocksTypeFilter <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ChatOnce [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Unload [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToolcallBackLength <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Invoke-QueryImageContent `
        -Query "What objects are in this image?" `
        -ImagePath "C:\Images\sample.jpg" `
        -Temperature 0.01 `
        -MaxToken 100

    Analyzes an image with specific temperature and token limits.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Query-Image "Describe this image" "C:\Images\photo.jpg"

    Simple image analysis using alias and positional parameters.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Remove-ImageDirectories

SYNOPSIS
    Removes directories from the configured image directories for GenXdev.AI operations.


SYNTAX
    Remove-ImageDirectories [-ImageDirectories] <String[]> [[-PreferencesDatabasePath] <String>] [-Force] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function removes one or more directory paths from the existing image
    directories configuration used by the GenXdev.AI module. It updates both the
    global variable and the module's preference storage to persist the configuration
    across sessions. Supports wildcard patterns for flexible directory matching.


PARAMETERS
    -ImageDirectories <String[]>
        An array of directory paths or wildcard patterns to remove from the existing
        image directories configuration.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Forces removal without confirmation prompts.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Remove-ImageDirectories -ImageDirectories @("C:\OldPhotos", "D:\TempImages")

    Removes the specified directories from the image directories configuration.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Remove-ImageDirectories "C:\Temp\*"

    Removes all directories that match the wildcard pattern.




    -------------------------- EXAMPLE 3 --------------------------

    PS > removeimgdir @("C:\OldPhotos") -Force

    Uses alias to forcibly remove a directory from the configuration without
    confirmation.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Remove-ImageMetaData

SYNOPSIS
    Removes image metadata files from image directories.


SYNTAX
    Remove-ImageMetaData [[-ImageDirectories] <String[]>] [[-Language] <String>] [[-PreferencesDatabasePath] <String>] [-Recurse] [-OnlyKeywords] [-OnlyPeople] [-OnlyObjects] [-OnlyScenes] [-AllLanguages] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    The Remove-ImageMetaData function removes companion JSON metadata files that
    are associated with images. It can selectively remove only keywords
    (description.json), people data (people.json), objects data (objects.json),
    or scenes data (scenes.json), or remove all metadata files if no specific
    switch is provided. Language-specific metadata files can be removed by
    specifying the Language parameter, and all language variants can be removed
    using the AllLanguages switch.


PARAMETERS
    -ImageDirectories <String[]>
        Array of directory paths to process for image metadata removal. If not
        specified, uses default system directories including Downloads, OneDrive,
        and Pictures folders.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Specifies the language for removing language-specific metadata files. When
        specified, removes both the default English description.json and the
        language-specific file. Defaults to English.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Recurse [<SwitchParameter>]
        When specified, searches for images in the specified directory and all
        subdirectories.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyKeywords [<SwitchParameter>]
        When specified, only removes the description.json files
        (keywords/descriptions).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyPeople [<SwitchParameter>]
        When specified, only removes the people.json files (face recognition data).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyObjects [<SwitchParameter>]
        When specified, only removes the objects.json files (object detection data).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyScenes [<SwitchParameter>]
        When specified, only removes the scenes.json files (scene classification
        data).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AllLanguages [<SwitchParameter>]
        When specified, removes metadata files for all supported languages by
        iterating through all languages from Get-WebLanguageDictionary.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

NOTES


        If none of the -OnlyKeywords, -OnlyPeople, -OnlyObjects, or -OnlyScenes
        switches are specified, all four types of metadata files will be removed.
        When Language is specified, both the default English and language-specific
        files are removed.
        When AllLanguages is specified, metadata files for all supported languages
        are removed.

    -------------------------- EXAMPLE 1 --------------------------

    PS > Remove-ImageMetaData -ImageDirectories @("C:\Photos", "D:\MyImages") -Recurse

    Removes all metadata files for images in multiple directories and all
    subdirectories.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Remove-ImageMetaData -Recurse -OnlyKeywords

    Removes only description.json files from default system directories and
    subdirectories.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Remove-ImageMetaData -OnlyPeople -ImageDirectories @(".\MyPhotos")

    Removes only people.json files from the MyPhotos directory.




    -------------------------- EXAMPLE 4 --------------------------

    PS > Remove-ImageMetaData -Language "Spanish" -OnlyKeywords -Recurse

    Removes both English and Spanish description files recursively from default
    directories.




    -------------------------- EXAMPLE 5 --------------------------

    PS > removeimagedata -AllLanguages -OnlyKeywords

    Uses alias to remove keyword files for all supported languages.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Save-FoundImageFaces

SYNOPSIS
    Saves cropped face images from indexed image search results.


SYNTAX
    Save-FoundImageFaces [[-Any] <String[]>] [-DescriptionSearch <String[]>] [-Keywords <String[]>] [-People <String[]>] [-Objects <String[]>] [-Scenes <String[]>] [-PictureType <String[]>] [-StyleType <String[]>] [-OverallMood <String[]>] [-DatabaseFilePath <String>] [-Language <String>] [-PathLike <String[]>] [-InputObject <Object[]>] [-OutputDirectory <String>] [-PreferencesDatabasePath <String>] [-HasNudity] [-NoNudity] [-HasExplicitContent] [-NoExplicitContent] [-ForceIndexRebuild] [-GeoLocation <Double[]>] [-GeoDistanceInMeters <Double>] [-SaveUnknownPersons] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function takes image search results and extracts/saves individual face
    regions as separate image files. It can search for faces using various criteria
    and save them to a specified output directory. The function supports searching
    by description, keywords, people, objects, scenes, picture type, style type,
    and overall mood. It can also filter by nudity and explicit content.


PARAMETERS
    -Any <String[]>
        Will match any of all the possible meta data types.

        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DescriptionSearch <String[]>
        The description text to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Keywords <String[]>
        The keywords to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -People <String[]>
        People to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Objects <String[]>
        Objects to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Scenes <String[]>
        Scenes to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PictureType <String[]>
        Picture types to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -StyleType <String[]>
        Style types to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OverallMood <String[]>
        Overall moods to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DatabaseFilePath <String>
        Path to the SQLite database file.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PathLike <String[]>
        Array of directory path-like search strings to filter images by path (SQL LIKE
        patterns, e.g. '%\\2024\\%').

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -InputObject <Object[]>
        Accepts search results from a previous -PassThru call to regenerate the view.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -OutputDirectory <String>
        Directory to save cropped face images.

        Required?                    false
        Position?                    named
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HasNudity [<SwitchParameter>]
        Filter images that contain nudity.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoNudity [<SwitchParameter>]
        Filter images that do NOT contain nudity.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HasExplicitContent [<SwitchParameter>]
        Filter images that contain explicit content.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoExplicitContent [<SwitchParameter>]
        Filter images that do NOT contain explicit content.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceIndexRebuild [<SwitchParameter>]
        Force rebuild of the image index database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -GeoLocation <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -GeoDistanceInMeters <Double>

        Required?                    false
        Position?                    named
        Default value                1000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SaveUnknownPersons [<SwitchParameter>]
        Also save unknown persons detected as objects.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Object[]

    System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=9.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Save-FoundImageFaces -People "John*" -OutputDirectory "C:\Faces"






    -------------------------- EXAMPLE 2 --------------------------

    PS > saveimagefaces -Any "vacation" -SaveUnknownPersons







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Save-FoundImageObjects

SYNOPSIS
    Saves cropped object images from indexed image search results to files.


SYNTAX
    Save-FoundImageObjects [[-Any] <String[]>] [-DescriptionSearch <String[]>] [-Keywords <String[]>] [-People <String[]>] [-Objects <String[]>] [-Scenes <String[]>] [-PictureType <String[]>] [-StyleType <String[]>] [-OverallMood <String[]>] [-DatabaseFilePath <String>] [-Title <String>] [-Description <String>] [-Language <String>] [-PathLike <String[]>] [-InputObject <Object[]>] [-OutputDirectory <String>] [-PreferencesDatabasePath <String>] [-ImageDirectories <String[]>] [-FacesDirectory <String>] [-EmbedImages] [-NoFallback] [-NeverRebuild] [-ShowInBrowser] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-NoBorders] [-SideBySide] [-AcceptLang <String>] [-Monitor <Int32>] [-ShowOnlyPictures] [-Interactive] [-Private] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-ShowWindow] [-Left <Int32>] [-Right <Int32>] [-Top <Int32>] [-Bottom <Int32>] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-RestoreFocus] [-NewWindow] [-OnlyReturnHtml] [-FocusWindow] [-SetForeground] [-Maximize] [-HasNudity] [-NoNudity] [-HasExplicitContent] [-NoExplicitContent] [-ForceIndexRebuild] [-GeoLocation <Double[]>] [-GeoDistanceInMeters <Double>] [-SaveUnknownPersons] [-SessionOnly] [-ClearSession] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    This function takes image search results and extracts individual detected
    object regions, saving them as separate image files. It can search for objects
    using various criteria including keywords, people, scenes, and metadata filters.
    The function processes images with AI-detected object boundaries and crops them
    to individual PNG files in the specified output directory.


PARAMETERS
    -Any <String[]>
        Will match any of all the possible meta data types including descriptions,
        keywords, people, objects, scenes, picture types, style types, and moods.

        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DescriptionSearch <String[]>
        The description text to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Keywords <String[]>
        The keywords to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -People <String[]>
        People to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Objects <String[]>
        Objects to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Scenes <String[]>
        Scenes to look for, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PictureType <String[]>
        Picture types to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -StyleType <String[]>
        Style types to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OverallMood <String[]>
        Overall moods to filter by, wildcards allowed.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DatabaseFilePath <String>
        Path to the SQLite database file.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Title <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Description <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PathLike <String[]>
        Array of directory path-like search strings to filter images by path
        (SQL LIKE patterns, e.g. '%\2024\%').

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -InputObject <Object[]>
        Accepts search results from a previous -PassThru call to regenerate the view.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -OutputDirectory <String>
        Directory to save cropped object images.

        Required?                    false
        Position?                    named
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageDirectories <String[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoFallback [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NeverRebuild [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowInBrowser [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AcceptLang <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowOnlyPictures [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Interactive [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Private [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Edge [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chrome [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chromium [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Firefox [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom <Int32>

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApplicationMode [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBrowserExtensions [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DisablePopupBlocker [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NewWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyReturnHtml [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HasNudity [<SwitchParameter>]
        Filter images that contain nudity.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoNudity [<SwitchParameter>]
        Filter images that do NOT contain nudity.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HasExplicitContent [<SwitchParameter>]
        Filter images that contain explicit content.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoExplicitContent [<SwitchParameter>]
        Filter images that do NOT contain explicit content.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ForceIndexRebuild [<SwitchParameter>]
        Force rebuild of the image index database.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -GeoLocation <Double[]>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -GeoDistanceInMeters <Double>

        Required?                    false
        Position?                    named
        Default value                1000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SaveUnknownPersons [<SwitchParameter>]
        Also save unknown persons detected as objects.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS
    System.Object[]

    System.Collections.Generic.List`1[[System.Object, System.Private.CoreLib, Version=9.0.0.0, Culture=neutral, PublicKeyToken=7cec85d7bea7798e]]

    System.String


    -------------------------- EXAMPLE 1 --------------------------

    PS > Save-FoundImageObjects -Objects "car", "tree" -OutputDirectory "C:\CroppedObjects"






    -------------------------- EXAMPLE 2 --------------------------

    PS > saveimageObjects -Any "sunset" -SaveUnknownPersons







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Save-Transcriptions

SYNOPSIS
    Generates subtitle files for audio and video files using OpenAI Whisper.


SYNTAX
    Save-Transcriptions [[-DirectoryPath] <String>] [[-LanguageIn] <String>] [[-LanguageOut] <String>] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <String>] [-SkipSession] [<CommonParameters>]


DESCRIPTION
    Recursively searches for media files in the specified directory and uses a local
    OpenAI Whisper model to generate subtitle files in SRT format. The function
    supports multiple audio/video formats and can optionally translate subtitles to
    a different language using LM Studio. File naming follows a standardized pattern
    with language codes (e.g., video.mp4.en.srt).


PARAMETERS
    -DirectoryPath <String>
        The root directory to search for media files. Defaults to the current directory.
        Will recursively process all supported media files in subfolders.

        Required?                    false
        Position?                    1
        Default value                .\
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LanguageIn <String>
        The expected source language of the audio content. Used to improve transcription
        accuracy. Defaults to English. Supports 150+ languages.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LanguageOut <String>
        Optional target language for translation. If specified, the generated subtitles
        will be translated from LanguageIn to this language using LM Studio.

        Required?                    false
        Position?                    3
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Save-Transcriptions -DirectoryPath "C:\Videos" -LanguageIn "English"






    -------------------------- EXAMPLE 2 --------------------------

    PS > Save-Transcriptions "C:\Media" "Japanese" "English" "qwen"
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Set-AIImageCollection

SYNOPSIS
    Sets the directories and default language for image files used in GenXdev.AI
    operations.


SYNTAX
    Set-AIImageCollection [[-ImageDirectories] <String[]>] [[-Language] <String>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function configures the global image directories and default language used
    by the GenXdev.AI module for various image processing and AI operations.
    Settings can be stored persistently in preferences (default), only in the
    current session (using -SessionOnly), or cleared from the session (using
    -ClearSession).


PARAMETERS
    -ImageDirectories <String[]>
        An array of directory paths where image files are located. These directories
        will be used by GenXdev.AI functions for image discovery and processing
        operations.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        The default language to use for image metadata operations. This will be used by
        Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions when no
        language is explicitly specified.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        When specified, stores the settings only in the current session (Global
        variables) without persisting to preferences. Settings will be lost when the
        session ends.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        When specified, clears only the session settings (Global variables) without
        affecting persistent preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Set-AIImageCollection -ImageDirectories @("C:\Images", "D:\Photos") -Language "Spanish"

    Sets the image directories and language persistently in preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Set-AIImageCollection @("C:\Pictures", "E:\Graphics\Stock") "French"

    Sets the image directories and language persistently in preferences.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Set-AIImageCollection -ImageDirectories @("C:\TempImages") -Language "German" -SessionOnly

    Sets the image directories and language only for the current session (Global
    variables).




    -------------------------- EXAMPLE 4 --------------------------

    PS > Set-AIImageCollection -ClearSession

    Clears the session image directories and language settings (Global variables)
    without affecting persistent preferences.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Set-AIKnownFacesRootpath

SYNOPSIS
    Sets the directory for face image files used in GenXdev.AI operations.


SYNTAX
    Set-AIKnownFacesRootpath [[-FacesDirectory] <String>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function configures the global face directory used by the GenXdev.AI
    module for various face recognition and AI operations. Settings can be stored
    persistently in preferences (default), only in the current session (using
    -SessionOnly), or cleared from the session (using -ClearSession).


PARAMETERS
    -FacesDirectory <String>
        A directory path where face image files are located. This directory
        will be used by GenXdev.AI functions for face discovery and processing
        operations.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        When specified, stores the setting only in the current session (Global
        variable) without persisting to preferences. Setting will be lost when the
        session ends.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        When specified, clears only the session setting (Global variable) without
        affecting persistent preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Set-AIKnownFacesRootpath -FacesDirectory "C:\Faces"

    Sets the faces directory persistently in preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Set-AIKnownFacesRootpath "C:\FacePictures"

    Sets the faces directory persistently in preferences.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Set-AIKnownFacesRootpath -FacesDirectory "C:\TempFaces" -SessionOnly

    Sets the faces directory only for the current session (Global variable).




    -------------------------- EXAMPLE 4 --------------------------

    PS > Set-AIKnownFacesRootpath -ClearSession

    Clears the session faces directory setting (Global variable) without affecting
    persistent preferences.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Set-AIMetaLanguage

SYNOPSIS
    Sets the default language and optionally the image directories for GenXdev.AI
    image metadata operations.


SYNTAX
    Set-AIMetaLanguage [[-Language] <String>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function configures the global default language for image metadata
    operations in the GenXdev.AI module. Optionally, it can also set the global
    image directories. Both settings are persisted in the module's preference
    storage for use across sessions.


PARAMETERS
    -Language <String>
        The default language to use for image metadata operations. This will be used
        by Remove-ImageMetaData, Update-AllImageMetaData, and Find-Image functions
        when no language is explicitly specified.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        When specified, stores the settings only in the current session (Global
        variables) without persisting to preferences. Settings will be lost when the
        session ends.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        When specified, clears only the session settings (Global variables) without
        affecting persistent preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Set-AIMetaLanguage -Language "Spanish" -ImageDirectories @("C:\Images", "D:\Photos")

    Sets the language and image directories persistently in preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Set-AIMetaLanguage "French"

    Sets the language persistently in preferences.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Set-AIMetaLanguage -Language "German" -SessionOnly

    Sets the language only for the current session (Global variable).




    -------------------------- EXAMPLE 4 --------------------------

    PS > Set-AIMetaLanguage -ClearSession

    Clears the session language setting (Global variable) without affecting
    persistent preferences.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Set-ImageDatabasePath

SYNOPSIS
    Sets the default database file path for image operations in GenXdev.AI.


SYNTAX
    Set-ImageDatabasePath [[-DatabaseFilePath] <String>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function configures the default database file path used by GenXdev.AI
    functions for image processing and AI operations. The path can be stored
    persistently in preferences (default), only in the current session (using
    -SessionOnly), or cleared from the session (using -ClearSession).


PARAMETERS
    -DatabaseFilePath <String>
        The path to the image database file. The directory will be created if it
        doesn't exist.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        When specified, stores the setting only in the current session (Global
        variables) without persisting to preferences. Settings will be lost when the
        session ends.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        When specified, clears only the session setting (Global variable) without
        affecting persistent preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        When specified, stores the setting only in persistent preferences without
        affecting the current session setting.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Set-ImageDatabasePath -DatabaseFilePath "C:\MyProject\images.db"

    Sets the image database path persistently in preferences.




    -------------------------- EXAMPLE 2 --------------------------

    PS > Set-ImageDatabasePath "D:\Data\custom_images.db"

    Sets the image database path persistently in preferences using positional
    parameter.




    -------------------------- EXAMPLE 3 --------------------------

    PS > Set-ImageDatabasePath -DatabaseFilePath "C:\Temp\temp_images.db" -SessionOnly

    Sets the image database path only for the current session (Global variables).




    -------------------------- EXAMPLE 4 --------------------------

    PS > Set-ImageDatabasePath -ClearSession

    Clears the session image database path setting (Global variable) without
    affecting persistent preferences.





RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Set-WindowsWallpaperEx

SYNTAX
    Set-WindowsWallpaperEx [[-Any] <string[]>] [-InputObject <Object>] [-DontUseImageIndex] [-DatabaseFilePath <string>] [-ImageDirectories <string[]>] [-PathLike <string[]>] [-Language {Afrikaans | Akan | Albanian | Amharic | Arabic | Armenian | Azerbaijani | Basque | Belarusian | Bemba | Bengali | Bihari | Bork, bork, bork! | Bosnian | Breton | Bulgarian | Cambodian | Catalan | Cherokee | Chichewa | Chinese (Simplified) | Chinese (Traditional) | Corsican | Croatian | Czech | Danish | Dutch | Elmer Fudd | English | Esperanto | Estonian | Ewe | Faroese | Filipino | Finnish | French | Frisian | Ga | Galician | Georgian | German | Greek | Guarani | Gujarati | Hacker | Haitian Creole | Hausa | Hawaiian | Hebrew | Hindi | Hungarian | Icelandic | Igbo | Indonesian | Interlingua | Irish | Italian | Japanese | Javanese | Kannada | Kazakh | Kinyarwanda | Kirundi | Klingon | Kongo | Korean | Krio (Sierra Leone) | Kurdish | Kurdish (Soranî) | Kyrgyz | Laothian | Latin | Latvian | Lingala | Lithuanian | Lozi | Luganda | Luo | Macedonian | Malagasy | Malay | Malayalam | Maltese | Maori | Marathi | Mauritian Creole | Moldavian | Mongolian | Montenegrin | Nepali | Nigerian Pidgin | Northern Sotho | Norwegian | Norwegian (Nynorsk) | Occitan | Oriya | Oromo | Pashto | Persian | Pirate | Polish | Portuguese (Brazil) | Portuguese (Portugal) | Punjabi | Quechua | Romanian | Romansh | Runyakitara | Russian | Scots Gaelic | Serbian | Serbo-Croatian | Sesotho | Setswana | Seychellois Creole | Shona | Sindhi | Sinhalese | Slovak | Slovenian | Somali | Spanish | Spanish (Latin American) | Sundanese | Swahili | Swedish | Tajik | Tamil | Tatar | Telugu | Thai | Tigrinya | Tonga | Tshiluba | Tumbuka | Turkish | Turkmen | Twi | Uighur | Ukrainian | Urdu | Uzbek | Vietnamese | Welsh | Wolof | Xhosa | Yiddish | Yoruba | Zulu}] [-FacesDirectory <string>] [-DescriptionSearch <string[]>] [-Keywords <string[]>] [-People <string[]>] [-Objects <string[]>] [-Scenes <string[]>] [-PictureType <string[]>] [-StyleType <string[]>] [-OverallMood <string[]>] [-ForceIndexRebuild] [-NoFallback] [-GeoLocation <double[]>] [-GeoDistanceInMeters <double>] [-NeverRebuild] [-HasNudity] [-NoNudity] [-HasExplicitContent] [-NoExplicitContent] [-SessionOnly] [-ClearSession] [-PreferencesDatabasePath <string>] [-SkipSession] [-AllDrives] [-NoRecurse] [-WhatIf] [-Confirm] [<CommonParameters>]


PARAMETERS
    -AllDrives
        Search across all available drives

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Any <string[]>
        Will match any of all the possible meta data types.

        Required?                    false
        Position?                    0
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ClearSession
        Clear alternative settings stored in session for AI preferences like Language, Image collections, etc.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Confirm

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      cf
        Dynamic?                     false
        Accept wildcard characters?  false

    -DatabaseFilePath <string>
        The path to the image database file. If not specified, a default path is used.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DescriptionSearch <string[]>
        The description text to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -DontUseImageIndex
        Switch to not using the indexed image search

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -FacesDirectory <string>
        The directory containing face images organized by person folders. If not specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ForceIndexRebuild
        Force rebuild of the image index database.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -GeoDistanceInMeters <double>
        Maximum distance in meters from GeoLocation to search for images.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -GeoLocation <double[]>
        Geographic coordinates [latitude, longitude] to search near.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -HasExplicitContent
        Filter images that contain explicit content.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -HasNudity
        Filter images that contain nudity.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -ImageDirectories <string[]>
        Array of directory paths to search for images.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      imagespath, directories, imgdirs, imagedirectory
        Dynamic?                     false
        Accept wildcard characters?  false

    -InputObject <Object>
        Path to the directory containing the wallpaper images

        Required?                    false
        Position?                    Named
        Accept pipeline input?       true (ByValue, ByPropertyName)
        Parameter set name           (All)
        Aliases                      Path, FullName, FilePath, Input
        Dynamic?                     false
        Accept wildcard characters?  false

    -Keywords <string[]>
        The keywords to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Language <string>
        Language for descriptions and keywords.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NeverRebuild
        Switch to skip database initialization and rebuilding.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoExplicitContent
        Filter images that do NOT contain explicit content.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoFallback
        Switch to disable fallback behavior.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoNudity
        Filter images that do NOT contain nudity.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -NoRecurse
        Do not recurse into subdirectories

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -Objects <string[]>
        Objects to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -OverallMood <string[]>
        Overall moods to filter by, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PathLike <string[]>
        Array of directory path-like search strings to filter images by path (SQL LIKE patterns, e.g. '%\2024\%')

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -People <string[]>
        People to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PictureType <string[]>
        Picture types to filter by, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -PreferencesDatabasePath <string>
        Database path for preference data files.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      DatabasePath
        Dynamic?                     false
        Accept wildcard characters?  false

    -Scenes <string[]>
        Scenes to look for, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SessionOnly
        Use alternative settings stored in session for AI preferences like Language, Image collections, etc

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -SkipSession
        Dont use alternative settings stored in session for AI preferences like Language, Image collections, etc

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      FromPreferences
        Dynamic?                     false
        Accept wildcard characters?  false

    -StyleType <string[]>
        Style types to filter by, wildcards allowed.

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false

    -WhatIf

        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      wi
        Dynamic?                     false
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).


INPUTS
    System.Object


OUTPUTS
    System.Object[]


ALIASES
    nextwallpaper


REMARKS
    None

<br/><hr/><hr/><br/>

NAME
    Show-FoundImagesInBrowser

SYNOPSIS
    Displays image search results in a masonry layout web gallery.


SYNTAX
    Show-FoundImagesInBrowser [[-InputObject] <Object[]>] [-Interactive] [-Title <String>] [-Description <String>] [-Private] [-Force] [-Edge] [-Chrome] [-Chromium] [-Firefox] [-All] [-Monitor <Int32>] [-FullScreen] [-Width <Int32>] [-Height <Int32>] [-X <Int32>] [-Y <Int32>] [-Left] [-Right] [-Top] [-Bottom] [-Centered] [-ApplicationMode] [-NoBrowserExtensions] [-DisablePopupBlocker] [-AcceptLang <String>] [-KeysToSend <String[]>] [-FocusWindow] [-SetForeground] [-Maximize] [-RestoreFocus] [-NewWindow] [-OnlyReturnHtml] [-EmbedImages] [-ShowOnlyPictures] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [-NoBorders] [-PassThru] [-SideBySide] [-SessionOnly] [-ClearSession] [-SkipSession] [-AutoScrollPixelsPerSecond <Int32>] [-AutoAnimateRectangles] [-SingleColumnMode] [-ImageUrlPrefix <String>] [<CommonParameters>]


DESCRIPTION
    Takes image search results and displays them in a browser-based masonry layout.
    Can operate in interactive mode with edit and delete capabilities, or in simple
    display mode. Accepts image data objects typically from Find-Image and renders
    them with hover tooltips showing metadata like face recognition, object
    detection, and scene classification data.


PARAMETERS
    -InputObject <Object[]>
        Array of image data objects containing path, keywords, description, people,
        objects, and scenes metadata.

        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Interactive [<SwitchParameter>]
        When specified, connects to browser and adds additional buttons like Edit and
        Delete for image management.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Title <String>
        The title to display at the top of the image gallery.

        Required?                    false
        Position?                    named
        Default value                Photo Gallery
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Description <String>
        The description text to display in the image gallery.

        Required?                    false
        Position?                    named
        Default value                Hover over images to see face recognition and object detection data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Private [<SwitchParameter>]
        Opens in incognito/private browsing mode.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force enable debugging port, stopping existing browsers if needed.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Edge [<SwitchParameter>]
        Opens in Microsoft Edge.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chrome [<SwitchParameter>]
        Opens in Google Chrome.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Chromium [<SwitchParameter>]
        Opens in Microsoft Edge or Google Chrome, depending on what the default
        browser is.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Firefox [<SwitchParameter>]
        Opens in Firefox.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -All [<SwitchParameter>]
        Opens in all registered modern browsers.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Monitor <Int32>
        The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary
        monitor, defaults to Global:DefaultSecondaryMonitor or 2 if not found.

        Required?                    false
        Position?                    named
        Default value                -2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FullScreen [<SwitchParameter>]
        Opens in fullscreen mode.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Width <Int32>
        The initial width of the webbrowser window.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Height <Int32>
        The initial height of the webbrowser window.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -X <Int32>
        The initial X position of the webbrowser window.

        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Y <Int32>
        The initial Y position of the webbrowser window.

        Required?                    false
        Position?                    named
        Default value                -999999
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Left [<SwitchParameter>]
        Place browser window on the left side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Right [<SwitchParameter>]
        Place browser window on the right side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Top [<SwitchParameter>]
        Place browser window on the top side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Bottom [<SwitchParameter>]
        Place browser window on the bottom side of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Centered [<SwitchParameter>]
        Place browser window in the center of the screen.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApplicationMode [<SwitchParameter>]
        Hide the browser controls.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBrowserExtensions [<SwitchParameter>]
        Prevent loading of browser extensions.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DisablePopupBlocker [<SwitchParameter>]
        Disable the popup blocker.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AcceptLang <String>
        Set the browser accept-lang http header.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -KeysToSend <String[]>
        Send specified keys to the browser window after opening.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FocusWindow [<SwitchParameter>]
        Focus the browser window after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SetForeground [<SwitchParameter>]
        Set the browser window to foreground after opening.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Maximize [<SwitchParameter>]
        Maximize the browser window after positioning.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RestoreFocus [<SwitchParameter>]
        Restore PowerShell window focus.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NewWindow [<SwitchParameter>]
        Create a new browser window instead of reusing existing one.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -OnlyReturnHtml [<SwitchParameter>]
        Only return the generated HTML instead of displaying it in a browser.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EmbedImages [<SwitchParameter>]
        Embed images as base64 data URLs instead of file:// URLs for better
        portability.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowOnlyPictures [<SwitchParameter>]
        Show only pictures in a rounded rectangle, no text below.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Escape control characters and modifiers when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Prevents returning keyboard focus to PowerShell after sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Use Shift+Enter instead of Enter when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between different input strings in milliseconds when sending keys.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoBorders [<SwitchParameter>]
        Remove window borders and title bar for a cleaner appearance.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Return the browser window helper object for further manipulation.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SideBySide [<SwitchParameter>]
        Place browser window side by side with PowerShell on the same monitor.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoScrollPixelsPerSecond <Int32>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoAnimateRectangles [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SingleColumnMode [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageUrlPrefix <String>

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Show-FoundImagesInBrowser -InputObject $images
    Displays the image results in a simple web gallery.






    -------------------------- EXAMPLE 2 --------------------------

    PS > Show-FoundImagesInBrowser -InputObject $images -Interactive -Title "My Photos"
    Displays images in interactive mode with edit/delete buttons.






    -------------------------- EXAMPLE 3 --------------------------

    PS > showfoundimages $images -Private -FullScreen
    Opens the gallery in private browsing mode in fullscreen.







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Show-GenXdevScriptErrorFixInIde

SYNOPSIS
    Executes a script block and analyzes errors using AI to generate fixes in IDE.


SYNTAX
    Show-GenXdevScriptErrorFixInIde [-Script] <ScriptBlock> [-Temperature <Double>] [[-LLMQueryType] <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-MaxToken <Int32>] [-Cpu <Int32>] [-Gpu <Int32>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-PreferencesDatabasePath <String>] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-ShowWindow] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-SessionOnly] [-ClearSession] [-SkipSession] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SendKeyDelayMilliSeconds <Int32>] [<CommonParameters>]


DESCRIPTION
    This function executes a provided script block, captures any errors that occur,
    and analyzes them using AI language models to generate intelligent fix prompts.
    The function then opens Visual Studio Code with the identified problematic files
    and provides AI-generated suggestions through GitHub Copilot to assist in
    resolving the issues.


PARAMETERS
    -Script <ScriptBlock>
        The script block to execute and analyze for errors.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  false

    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).

        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LLMQueryType <String>
        The type of LLM query to perform for error analysis.

        Required?                    false
        Position?                    2
        Default value                Coding
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        The model identifier or pattern to use for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HuggingFaceIdentifier <String>
        The LM Studio specific model identifier.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        The maximum number of tokens to use in AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Cpu <Int32>
        The number of CPU cores to dedicate to AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Gpu <Int32>
        How much to offload to the GPU. If 'off', GPU offloading is disabled. If 'max',
        all layers are offloaded to GPU. If a number between 0 and 1, that fraction of
        layers will be offloaded to the GPU. -1 = LM Studio will decide how much to
        offload to the GPU. -2 = Auto.

        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        The API endpoint URL for AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key for authenticated AI operations.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        The timeout in seconds for AI operations.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Functions <Hashtable[]>
        Array of function definitions.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoConfirmationToolFunctionNames <String[]>
        Array of command names that don't require confirmation.

        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show the LM Studio window during processing.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force stop LM Studio before initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontAddThoughtsToHistory [<SwitchParameter>]
        Include model's thoughts in output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContinueLast [<SwitchParameter>]
        Continue from last conversation.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Speak [<SwitchParameter>]
        Enable text-to-speech for AI responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SpeakThoughts [<SwitchParameter>]
        Enable text-to-speech for AI thought responses.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSessionCaching [<SwitchParameter>]
        Don't store session in session cache.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Store settings only in persistent preferences without affecting session.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyEscape [<SwitchParameter>]
        Escape control characters and modifiers when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyHoldKeyboardFocus [<SwitchParameter>]
        Hold keyboard focus on target window when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyUseShiftEnter [<SwitchParameter>]
        Use Shift+Enter instead of Enter when sending keys.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SendKeyDelayMilliSeconds <Int32>
        Delay between different input strings in milliseconds when sending keys.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Show-GenXdevScriptErrorFixInIde -Script { Get-ChildItem -Path "NonExistentPath" }






    -------------------------- EXAMPLE 2 --------------------------

    PS > letsfixthis { Import-Module "NonExistentModule" }
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Start-AudioTranscription

SYNOPSIS
    Transcribes audio to text using various input methods and advanced configuration
    options.


SYNTAX
    Start-AudioTranscription [[-ModelFilePath] <String>] [[-WaveFile] <String>] [-MaxDurationOfSilence <Object>] [-SilenceThreshold <Int32>] [-Language <String>] [-CpuThreads <Int32>] [-Temperature <Single>] [-TemperatureInc <Single>] [-Prompt <String>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-MaxDuration <Object>] [-Offset <Object>] [-MaxLastTextTokens <Int32>] [-MaxSegmentLength <Int32>] [-MaxInitialTimestamp <Object>] [-LengthPenalty <Single>] [-EntropyThreshold <Single>] [-LogProbThreshold <Single>] [-NoSpeechThreshold <Single>] [-TokenTimestampsSumThreshold <Single>] [-MaxTokensPerSegment <Int32>] [-PreferencesDatabasePath <String>] [-VOX] [-PassThru] [-UseDesktopAudioCapture] [-WithTokenTimestamps] [-SplitOnWord] [-IgnoreSilence] [-WithTranslate] [-WithProgress] [-DontSuppressBlank] [-SingleSegmentOnly] [-PrintSpecialTokens] [-NoContext] [-WithBeamSearchSamplingStrategy] [-Realtime] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function provides comprehensive audio transcription capabilities, supporting
    both real-time recording and file-based transcription. It offers extensive
    configuration options for language detection, audio processing, and output
    formatting.

    Key features:
    - Multiple audio input sources (microphone, desktop audio, wav files)
    - Automatic silence detection (VOX)
    - Multi-language support
    - Token timestamp generation
    - CPU/GPU processing optimization
    - Advanced audio processing parameters


PARAMETERS
    -ModelFilePath <String>
        Path to store model files. Defaults to local GenXdev folder.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WaveFile <String>
        Path to the 16Khz mono, .WAV file to process.

        Required?                    false
        Position?                    2
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxDurationOfSilence <Object>
        Maximum duration of silence before automatically stopping recording.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SilenceThreshold <Int32>
        Silence detect threshold (0..32767 defaults to 30).

        Required?                    false
        Position?                    named
        Default value                30
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Sets the language to detect.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -CpuThreads <Int32>
        Number of CPU threads to use, defaults to 0 (auto).

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Temperature <Single>
        Temperature for speech generation.

        Required?                    false
        Position?                    named
        Default value                0.01
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TemperatureInc <Single>
        Temperature increment.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Prompt <String>
        Prompt to use for the model.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SuppressRegex <String>
        Regex to suppress tokens from the output.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AudioContextSize <Int32>
        Size of the audio context.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxDuration <Object>
        Maximum duration of the audio.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Offset <Object>
        Offset for the audio.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxLastTextTokens <Int32>
        Maximum number of last text tokens.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxSegmentLength <Int32>
        Maximum segment length.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxInitialTimestamp <Object>
        Start timestamps at this moment.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LengthPenalty <Single>
        Length penalty.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -EntropyThreshold <Single>
        Entropy threshold.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -LogProbThreshold <Single>
        Log probability threshold.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoSpeechThreshold <Single>
        No speech threshold.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TokenTimestampsSumThreshold <Single>
        Sum threshold for token timestamps, defaults to 0.5.

        Required?                    false
        Position?                    named
        Default value                0.5
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxTokensPerSegment <Int32>
        Maximum number of tokens per segment.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VOX [<SwitchParameter>]
        Use silence detection to automatically stop recording.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        Returns objects instead of strings.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseDesktopAudioCapture [<SwitchParameter>]
        Whether to use desktop audio capture instead of microphone input.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithTokenTimestamps [<SwitchParameter>]
        Whether to include token timestamps in the output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SplitOnWord [<SwitchParameter>]
        Whether to split on word boundaries.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -IgnoreSilence [<SwitchParameter>]
        Whether to ignore silence (will mess up timestamps).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithTranslate [<SwitchParameter>]
        Whether to translate the output.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithProgress [<SwitchParameter>]
        Whether to show progress.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -DontSuppressBlank [<SwitchParameter>]
        Whether to NOT suppress blank lines.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SingleSegmentOnly [<SwitchParameter>]
        Whether to use single segment only.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PrintSpecialTokens [<SwitchParameter>]
        Whether to print special tokens.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoContext [<SwitchParameter>]
        Don't use context.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WithBeamSearchSamplingStrategy [<SwitchParameter>]
        Use beam search sampling strategy.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Realtime [<SwitchParameter>]
        Enable real-time transcription mode.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Don't use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Start-AudioTranscription -ModelFilePath "C:\Models" -Language "English" `
        -WithTokenTimestamps $true -PassThru $false






    -------------------------- EXAMPLE 2 --------------------------

    PS > transcribe -VOX -UseDesktopAudioCapture -Language "English"







RELATED LINKS

<br/><hr/><hr/><br/>

NAME
    Update-AllImageMetaData

SYNOPSIS
    Batch updates image keywords, faces, objects, and scenes across multiple system
    directories.


SYNTAX
    Update-AllImageMetaData [[-ImageDirectories] <String[]>] [-ContainerName <String>] [-VolumeName <String>] [-ServicePort <Int32>] [-HealthCheckTimeout <Int32>] [-HealthCheckInterval <Int32>] [-ImageName <String>] [-ConfidenceThreshold <Double>] [-Language <String>] [-Model <String>] [-HuggingFaceIdentifier <String>] [-ApiEndpoint <String>] [-ApiKey <String>] [-TimeoutSeconds <Int32>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-FacesDirectory <String>] [-PreferencesDatabasePath <String>] [-RetryFailed] [-NoRecurse] [-RedoAll] [-NoLMStudioInitialize] [-NoDockerInitialize] [-Force] [-UseGPU] [-ShowWindow] [-PassThru] [-AutoUpdateFaces] [-SessionOnly] [-ClearSession] [-SkipSession] [-WhatIf] [-Confirm] [<CommonParameters>]


DESCRIPTION
    This function systematically processes images across various system directories
    to update their keywords, face recognition data, object detection data, and
    scene classification data using AI services. It covers media storage, system
    files, downloads, OneDrive, and personal pictures folders.

    The function processes images by going through each directory and processing files
    individually. DeepStack functions (faces, objects, scenes) are performed first,
    followed by keyword and description generation. This ensures optimal processing
    order and outputs structured objects compatible with Export-ImageDatabase.

    This allows for structured data output for pipeline operations like:
    Update-AllImageMetaData | Export-ImageDatabase


PARAMETERS
    -ImageDirectories <String[]>
        Array of directory paths to process for image keyword and face recognition
        updates. If not specified, uses default system directories.

        Required?                    false
        Position?                    1
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ContainerName <String>
        The name for the Docker container used for face recognition processing.

        Required?                    false
        Position?                    named
        Default value                deepstack_face_recognition
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -VolumeName <String>
        The name for the Docker volume for persistent storage of face recognition data.

        Required?                    false
        Position?                    named
        Default value                deepstack_face_data
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ServicePort <Int32>
        The port number for the DeepStack face recognition service.

        Required?                    false
        Position?                    named
        Default value                5000
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckTimeout <Int32>
        Maximum time in seconds to wait for service health check during startup.

        Required?                    false
        Position?                    named
        Default value                60
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -HealthCheckInterval <Int32>
        Interval in seconds between health check attempts during service startup.

        Required?                    false
        Position?                    named
        Default value                3
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ImageName <String>
        Custom Docker image name to use for face recognition processing.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ConfidenceThreshold <Double>
        Minimum confidence threshold (0.0-1.0) for object detection. Objects with
        confidence below this threshold will be filtered out. Default is 0.5.

        Required?                    false
        Position?                    named
        Default value                0.7
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Language <String>
        Specifies the language for generated descriptions and keywords. Defaults to
        English.

        Required?                    false
        Position?                    named
        Default value                English
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Model <String>
        Name or partial path of the model to initialize.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       true (ByValue)
        Aliases
        Accept wildcard characters?  true

    -HuggingFaceIdentifier <String>
        The LM-Studio model to use.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiEndpoint <String>
        Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ApiKey <String>
        The API key to use for the request.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TimeoutSeconds <Int32>
        Timeout in seconds for the request, defaults to 24 hours.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -MaxToken <Int32>
        Maximum tokens in response (-1 for default).

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -TTLSeconds <Int32>
        Set a TTL (in seconds) for models loaded via API.

        Required?                    false
        Position?                    named
        Default value                0
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -FacesDirectory <String>
        The directory containing face images organized by person folders. If not
        specified, uses the configured faces directory preference.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PreferencesDatabasePath <String>
        Database path for preference data files.

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RetryFailed [<SwitchParameter>]
        Specifies whether to retry previously failed image keyword updates. When
        enabled, the function will attempt to process images that failed in previous
        runs.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoRecurse [<SwitchParameter>]
        Dont't recurse into subdirectories when processing images.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -RedoAll [<SwitchParameter>]
        Forces reprocessing of all images regardless of previous processing status.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoLMStudioInitialize [<SwitchParameter>]
        Skip LM-Studio initialization when already called by parent function to avoid
        duplicate container setup.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -NoDockerInitialize [<SwitchParameter>]
        Skip Docker initialization when already called by parent function to avoid
        duplicate container setup.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Force [<SwitchParameter>]
        Force rebuild of Docker container and remove existing data for clean start.
        And force restart of LMStudio.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -UseGPU [<SwitchParameter>]
        Use GPU-accelerated version for faster processing (requires NVIDIA GPU).

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ShowWindow [<SwitchParameter>]
        Show Docker + LM Studio window during initialization.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -PassThru [<SwitchParameter>]
        PassThru to return structured objects instead of outputting to console.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -AutoUpdateFaces [<SwitchParameter>]
        Detects changes in the faces directory and re-registers faces if needed.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SessionOnly [<SwitchParameter>]
        Use alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -ClearSession [<SwitchParameter>]
        Clear alternative settings stored in session for AI preferences like Language,
        Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -SkipSession [<SwitchParameter>]
        Dont use alternative settings stored in session for AI preferences like
        Language, Image collections, etc.

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -WhatIf [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    -Confirm [<SwitchParameter>]

        Required?                    false
        Position?                    named
        Default value
        Accept pipeline input?       false
        Aliases
        Accept wildcard characters?  false

    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216).

INPUTS

OUTPUTS

    -------------------------- EXAMPLE 1 --------------------------

    PS > Update-AllImageMetaData -ImageDirectories @("C:\Pictures", "D:\Photos") `
        -ServicePort 5000






    -------------------------- EXAMPLE 2 --------------------------

    PS > Update-AllImageMetaData -RetryFailed -Force -Language "Spanish"






    -------------------------- EXAMPLE 3 --------------------------

    PS > updateallimages @("C:\MyImages") -ContainerName "custom_face_recognition"
    ##############################################################################







RELATED LINKS

<br/><hr/><hr/><br/>
