<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME
    GenXdev.AI
### SYNOPSIS
    A Windows PowerShell module for local AI related operations
[![GenXdev.AI](https://img.shields.io/powershellgallery/v/GenXdev.AI.svg?style=flat-square&label=GenXdev.AI)](https://www.powershellgallery.com/packages/GenXdev.AI/) [![License](https://img.shields.io/github/license/genXdev/GenXdev.AI?style=flat-square)](./LICENSE)

### FEATURES
* ✅ Local Large Language Model (LLM) Integration
     * Perform AI operations through OpenAI-compatible chat completion endpoints with `Invoke-LLMQuery` -> `llm`, `qllm`, `qlms`
     * Seamless 'LM Studio' integration with automatic installation and model management
     * Expose PowerShell cmdlets as tool functions to LLM models with user-controlled execution
     * Interactive text chat sessions with `New-LLMTextChat` -> `llmchat`
     * AI-powered command suggestions with `Invoke-AIPowershellCommand` -> `hint`
     * Secure execution model with mandatory user confirmation for system-modifying operations

* ✅ Audio and Speech Processing
     * Transcribe audio/video files using Whisper AI model with `Get-MediaFileAudioTranscription` -> `transcribefile`
     * Interactive audio chat sessions with `New-LLMAudioChat` -> `llmaudiochat`
     * Real-time audio transcription with `Start-AudioTranscription` -> `transcribe`
     * Generate subtitle files for media content using `Save-Transcriptions`
     * Record and process spoken audio with default input devices

* ✅ Image Analysis and Management
     * Generate and store AI-powered image descriptions and keywords
     * Search images by content and metadata with `Invoke-ImageKeywordScan` -> `findimages`
     * Analyze image content using AI vision with `Invoke-QueryImageContent` -> `query-image`
     * Update image metadata automatically with `Invoke-ImageKeywordUpdate` -> `updateimages`
     * Generate responsive image galleries with `GenerateMasonryLayoutHtml`

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
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
| --- | --- | --- |
| [Add-EmoticonsToText](#Add-EmoticonsToText) | emojify | Enhances text by adding contextually appropriate emoticons using AI. |
| [Approve-NewTextFileContent](#Approve-NewTextFileContent) |  | Interactive file content comparison and approval using WinMerge. |
| [AssureWinMergeInstalled](#AssureWinMergeInstalled) |  | Ensures WinMerge is installed and available for file comparison operations. |
| [ConvertFrom-CorporateSpeak](#ConvertFrom-CorporateSpeak) | uncorporatize | Converts polite, professional corporate speak into direct, clear language using AI. |
| [ConvertTo-CorporateSpeak](#ConvertTo-CorporateSpeak) | corporatize | Converts direct or blunt text into polite, professional corporate speak using AI. |
| [GenerateMasonryLayoutHtml](#GenerateMasonryLayoutHtml) |  | Generates a responsive masonry layout HTML gallery from image data. |
| [Get-CpuCore](#Get-CpuCore) |  | Calculates and returns the total number of logical CPU cores in the system. |
| [Get-HasCapableGpu](#Get-HasCapableGpu) |  | Determines if a CUDA-capable GPU with sufficient memory is present. |
| [Get-MediaFileAudioTranscription](#Get-MediaFileAudioTranscription) | transcribefile | Transcribes an audio or video file to text.. |
| [Get-NumberOfCpuCores](#Get-NumberOfCpuCores) |  | Calculates and returns the total number of logical CPU cores in the system. |
| [Get-TextTranslation](#Get-TextTranslation) | translate | Translates text to another language using AI. |
| [Get-VectorSimilarity](#Get-VectorSimilarity) |  |  |
| [Invoke-AIPowershellCommand](#Invoke-AIPowershellCommand) | hint | Generates and executes PowerShell commands using AI assistance. |
| [Invoke-CommandFromToolCall](#Invoke-CommandFromToolCall) |  | Executes a tool call function with validation and parameter filtering. |
| [Invoke-ImageKeywordScan](#Invoke-ImageKeywordScan) | findimages | Scans image files for keywords and descriptions using metadata files. |
| [Invoke-ImageKeywordUpdate](#Invoke-ImageKeywordUpdate) | updateimages | Updates image metadata with AI-generated descriptions and keywords. |
| [Invoke-LLMBooleanEvaluation](#Invoke-LLMBooleanEvaluation) | equalstrue | Evaluates a statement using AI to determine if it's true or false. |
| [Invoke-LLMQuery](#Invoke-LLMQuery) | qllm, llm, invoke-lmstudioquery, qlms |  |
| [Invoke-LLMStringListEvaluation](#Invoke-LLMStringListEvaluation) | getlist | Extracts or generates a list of relevant strings from input text using AI analysis. |
| [Invoke-LLMTextTransformation](#Invoke-LLMTextTransformation) | spellcheck | Transforms text using AI-powered processing. |
| [Invoke-QueryImageContent](#Invoke-QueryImageContent) | query-image, analyze-image | Analyzes image content using AI vision capabilities through the LM-Studio API. |
| [Invoke-WinMerge](#Invoke-WinMerge) |  | Launches WinMerge to compare two files side by side. |
| [New-LLMAudioChat](#New-LLMAudioChat) | llmaudiochat | Creates an interactive audio chat session with an LLM model. |
| [New-LLMTextChat](#New-LLMTextChat) | llmchat | Starts an interactive text chat session with AI capabilities. |
| [Save-Transcriptions](#Save-Transcriptions) |  | Generates subtitle files for audio and video files using OpenAI Whisper. |
| [Set-GenXdevAICommandNotFoundAction](#Set-GenXdevAICommandNotFoundAction) |  | Sets up custom command not found handling with AI assistance. |
| [Start-AudioTranscription](#Start-AudioTranscription) | transcribe, recordandtranscribe |  |

<hr/>
&nbsp;

### GenXdev.AI.LMStudio</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
| --- | --- | --- |
| [AssureLMStudio](#AssureLMStudio) |  | Ensures LM Studio is properly initialized with the specified model. |
| [Convert-DotNetTypeToLLMType](#Convert-DotNetTypeToLLMType) |  | Converts .NET type names to LLM (Language Model) type names. |
| [ConvertTo-LMStudioFunctionDefinition](#ConvertTo-LMStudioFunctionDefinition) |  | Converts PowerShell functions to LMStudio function definitions. |
| [Get-LMStudioLoadedModelList](#Get-LMStudioLoadedModelList) |  | Retrieves the list of currently loaded models from LM Studio. |
| [Get-LMStudioModelList](#Get-LMStudioModelList) |  | Retrieves a list of installed LM Studio models. |
| [Get-LMStudioPaths](#Get-LMStudioPaths) |  | Retrieves file paths for LM Studio executables. |
| [Get-LMStudioTextEmbedding](#Get-LMStudioTextEmbedding) | embed-text, get-textembedding |  |
| [Get-LMStudioWindow](#Get-LMStudioWindow) |  | Gets a window helper for the LM Studio application. |
| [Initialize-LMStudioModel](#Initialize-LMStudioModel) |  | Initializes and loads an AI model in LM Studio. |
| [Install-LMStudioApplication](#Install-LMStudioApplication) |  | Installs LM Studio application using WinGet package manager. |
| [Start-LMStudioApplication](#Start-LMStudioApplication) |  | Starts the LM Studio application if it's not already running. |
| [Test-LMStudioInstallation](#Test-LMStudioInstallation) |  | Tests if LMStudio is installed and accessible on the system. |
| [Test-LMStudioProcess](#Test-LMStudioProcess) |  | Tests if LM Studio process is running and configures its window state. |

<hr/>
&nbsp;

### GenXdev.AI.Queries</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
| --- | --- | --- |
| [Get-SimularMovieTitles](#Get-SimularMovieTitles) | moremovietitles | Finds similar movie titles based on common properties |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.AI<hr/>

<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.AI.LMStudio<hr/>

<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


<br/><hr/><hr/><br/>


&nbsp;<hr/>
###	GenXdev.AI.Queries<hr/>

<br/><hr/><hr/><br/>
