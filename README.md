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
| [Approve-NewTextFileContent](#Approve-NewTextFileContent) |  | Interactive file content comparison and approval using WinMerge. |
| [AssureWinMergeInstalled](#AssureWinMergeInstalled) |  | Ensures WinMerge is installed and available for file comparison operations. |
| [Convert-DotNetTypeToLLMType](#Convert-DotNetTypeToLLMType) |  | Converts .NET type names to LLM (Language Model) type names. |
| [ConvertTo-LMStudioFunctionDefinition](#ConvertTo-LMStudioFunctionDefinition) |  | Converts PowerShell functions to LMStudio function definitions. |
| [GenerateMasonryLayoutHtml](#GenerateMasonryLayoutHtml) |  | Generates a responsive masonry layout HTML gallery from image data. |
| [Get-CpuCore](#Get-CpuCore) |  | Calculates and returns the total number of logical CPU cores in the system. |
| [Get-HasCapableGpu](#Get-HasCapableGpu) |  | Determines if a CUDA-capable GPU with sufficient memory is present. |
| [Get-NumberOfCpuCores](#Get-NumberOfCpuCores) |  | Calculates and returns the total number of logical CPU cores in the system. |
| [Get-TextTranslation](#Get-TextTranslation) | translate | Translates text to another language using AI. |
| [Get-VectorSimilarity](#Get-VectorSimilarity) |  |  |
| [Invoke-CommandFromToolCall](#Invoke-CommandFromToolCall) |  | Executes a tool call function with validation and parameter filtering. |
| [Invoke-LLMBooleanEvaluation](#Invoke-LLMBooleanEvaluation) | equalstrue | Evaluates a statement using AI to determine if it's true or false. |
| [Invoke-LLMQuery](#Invoke-LLMQuery) | qllm, llm, invoke-lmstudioquery, qlms |  |
| [Invoke-LLMStringListEvaluation](#Invoke-LLMStringListEvaluation) | getlist | Extracts or generates a list of relevant strings from input text using AI analysis. |
| [Invoke-LLMTextTransformation](#Invoke-LLMTextTransformation) | spellcheck | Transforms text using AI-powered processing. |
| [Invoke-WinMerge](#Invoke-WinMerge) |  | Launches WinMerge to compare two files side by side. |
| [New-LLMAudioChat](#New-LLMAudioChat) | llmaudiochat | Creates an interactive audio chat session with an LLM model. |
| [New-LLMTextChat](#New-LLMTextChat) | llmchat | Starts an interactive text chat session with AI capabilities. |
| [Set-GenXdevAICommandNotFoundAction](#Set-GenXdevAICommandNotFoundAction) |  | Sets up custom command not found handling with AI assistance. |

<hr/>
&nbsp;

### GenXdev.AI.LMStudio</hr>
| Command&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | aliases&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; | Description |
| --- | --- | --- |
| [AssureLMStudio](#AssureLMStudio) |  | Ensures LM Studio is properly initialized with the specified model. |
| [Get-LMStudioLoadedModelList](#Get-LMStudioLoadedModelList) |  | Retrieves the list of currently loaded models from LM Studio. |
| [Get-LMStudioModelList](#Get-LMStudioModelList) |  | Retrieves a list of installed LM Studio models. |
| [Get-LMStudioPaths](#Get-LMStudioPaths) |  | Retrieves file paths for LM Studio executables. |
| [Get-LMStudioTextEmbedding](#Get-LMStudioTextEmbedding) | embed-text, get-textembedding | Gets text embeddings from LM Studio model. |
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
| [Add-EmoticonsToText](#Add-EmoticonsToText) | emojify | Enhances text by adding contextually appropriate emoticons using AI. |
| [ConvertFrom-CorporateSpeak](#ConvertFrom-CorporateSpeak) | uncorporatize | Converts polite, professional corporate speak into direct, clear language using AI. |
| [ConvertFrom-DiplomaticSpeak](#ConvertFrom-DiplomaticSpeak) | undiplomatize |  |
| [ConvertTo-CorporateSpeak](#ConvertTo-CorporateSpeak) | corporatize | Converts direct or blunt text into polite, professional corporate speak using AI. |
| [ConvertTo-DiplomaticSpeak](#ConvertTo-DiplomaticSpeak) | diplomatize |  |
| [Get-Fallacy](#Get-Fallacy) | moremovietitles |  |
| [Get-MediaFileAudioTranscription](#Get-MediaFileAudioTranscription) | transcribefile | Transcribes an audio or video file to text.. |
| [Get-ScriptExecutionErrorFixPrompt](#Get-ScriptExecutionErrorFixPrompt) | getfixprompt | Captures error messages from various streams and uses LLM to suggest fixes. |
| [Get-SimularMovieTitles](#Get-SimularMovieTitles) | moremovietitles | Finds similar movie titles based on common properties. |
| [Invoke-AIPowershellCommand](#Invoke-AIPowershellCommand) | hint | Generates and executes PowerShell commands using AI assistance. |
| [Invoke-ImageKeywordScan](#Invoke-ImageKeywordScan) | findimages | Scans image files for keywords and descriptions using metadata files. |
| [Invoke-ImageKeywordUpdate](#Invoke-ImageKeywordUpdate) | updateimages | Updates image metadata with AI-generated descriptions and keywords. |
| [Invoke-QueryImageContent](#Invoke-QueryImageContent) | query-image, analyze-image | Analyzes image content using AI vision capabilities through the LM-Studio API. |
| [Save-Transcriptions](#Save-Transcriptions) |  | Generates subtitle files for audio and video files using OpenAI Whisper. |
| [Show-GenXdevScriptErrorFixInIde](#Show-GenXdevScriptErrorFixInIde) | letsfixthis | Parses error messages and fixes them using Github Copilot in VSCode. |
| [Start-AudioTranscription](#Start-AudioTranscription) | transcribe, recordandtranscribe |  |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.AI<hr/> 
NAME
    Approve-NewTextFileContent
    
SYNOPSIS
    Interactive file content comparison and approval using WinMerge.
    
    
SYNTAX
    Approve-NewTextFileContent [-ContentPath] <String> [-NewContent] <String> [<CommonParameters>]
    
    
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
        
    -NewContent <String>
        The proposed new content to compare against the existing file content.
        
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
    AssureWinMergeInstalled
    
SYNOPSIS
    Ensures WinMerge is installed and available for file comparison operations.
    
    
SYNTAX
    AssureWinMergeInstalled [<CommonParameters>]
    
    
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
    
    PS > AssureWinMergeInstalled
    Ensures WinMerge is installed and properly configured.
    
    
    
    
    
    
    
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
    # Returns: "string"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Convert-DotNetTypeToLLMType "System.Collections.Generic.List``1"
    # Returns: "array"
    
    
    
    
    
    
    
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
    GenerateMasonryLayoutHtml
    
SYNOPSIS
    Generates a responsive masonry layout HTML gallery from image data.
    
    
SYNTAX
    GenerateMasonryLayoutHtml [-Images] <Array> [[-FilePath] <String>] [<CommonParameters>]
    
    
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
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.String
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > # Create gallery from image array and save to file
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
    
    PS > # Generate HTML string without saving
    $html = GenerateMasonryLayoutHtml $images
    
    
    
    
    
    
    
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
    
    PS > # Get the total number of logical CPU cores
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
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > # Get the total number of logical CPU cores
    $cores = Get-NumberOfCpuCores
    Write-Host "System has $cores logical CPU cores available"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-TextTranslation
    
SYNOPSIS
    Translates text to another language using AI.
    
    
SYNTAX
    Get-TextTranslation [[-Text] <String>] [[-Language] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-SetClipboard] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
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
        
    -Language <String>
        Target language for translation. Supports 140+ languages including major world
        languages and variants.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Instructions <String>
        Additional instructions to guide the AI model in translation style and context.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        Specifies which AI model to use for translation. Supports wildcards.
        
        Required?                    false
        Position?                    4
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Identifier used for getting specific model from LM Studio.
        
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
        
    -MaxToken <Int32>
        Maximum tokens in response. Use -1 for default model limits.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SetClipboard [<SwitchParameter>]
        When specified, copies the translated text to system clipboard after translation.
        
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
        
    -TTLSeconds <Int32>
        Sets a Time-To-Live in seconds for models loaded via API requests.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        Controls GPU layer offloading: -2=Auto, -1=LM Studio decides, 0-1=fraction of
        layers, "off"=disabled, "max"=all layers.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces LM Studio to stop before initialization.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiEndpoint <String>
        API endpoint URL. Defaults to http://localhost:1234/v1/chat/completions
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiKey <String>
        API key for authentication with the endpoint.
        
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
    System.String
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-TextTranslation -Text "Hello world" -Language "French" -Model "qwen"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "Bonjour" | translate -Language "English"
    
    
    
    
    
    
    
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
    # Returns approximately 0.998, indicating high similarity
    
    
    
    
    
    
    
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
    Invoke-LLMBooleanEvaluation [[-Text] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [[-Attachments] <String[]>] [-SetClipboard] [-ShowWindow] [-Temperature <Double>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ImageDetail <String>] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [-AllowDefaultTools] [<CommonParameters>]
    
    
DESCRIPTION
    This function uses AI models to evaluate statements and determine their truth value.
    It can accept input directly through parameters, from the pipeline, or from the
    system clipboard.
    

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
        Instructions to guide the AI model in evaluating the statement. By default, it will
        determine if the statement is true or false.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        Specifies which AI model to use for the evaluation. Different models
        may produce varying results.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Attachments <String[]>
        
        Required?                    false
        Position?                    4
        Default value                @()
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
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    -MaxToken <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -Force [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
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
        Array of command names that don't require confirmation
        
        Required?                    false
        Position?                    named
        Default value                @()
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
        
    -AllowDefaultTools [<SwitchParameter>]
        
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
    
    PS > Invoke-LLMBooleanEvaluation -Text "The Earth is flat"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "Humans need oxygen to survive" | Invoke-LLMBooleanEvaluation
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-LLMQuery
    
SYNOPSIS
    Sends queries to an OpenAI compatible Large Language Chat completion API and
    processes responses.
    
    
SYNTAX
    Invoke-LLMQuery [[-Query] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-ResponseFormat <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ImageDetail <String>] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-Speak] [-SpeakThoughts] [-OutputMarkupBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-ChatMode <String>] [-ChatOnce] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This function sends queries to an OpenAI compatible Large Language Chat completion
    API and processes responses. It supports text and image inputs, handles tool
    function calls, and can operate in various chat modes including text and audio.
    

PARAMETERS
    -Query <String>
        The text query to send to the model. Can be empty for chat modes.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        The name or identifier of the LM Studio model to use.
        
        Required?                    false
        Position?                    2
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Alternative identifier for getting a specific model from LM Studio.
        
        Required?                    false
        Position?                    named
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Instructions <String>
        System instructions to provide context to the model.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Attachments <String[]>
        Array of file paths to attach to the query. Supports images and text files.
        
        Required?                    false
        Position?                    4
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
        
    -MaxToken <Int32>
        Maximum tokens allowed in the response. Use -1 for model default.
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -TTLSeconds <Int32>
        Time-to-live in seconds for loaded models.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        How much to offload to the GPU. Values range from -2 (Auto) to 1 (max).
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -ImageDetail <String>
        Detail level for image processing (low/medium/high).
        
        Required?                    false
        Position?                    named
        Default value                low
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
        
    -OutputMarkupBlocksOnly [<SwitchParameter>]
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
        Default value                @("json", "powershell", "C#", "python", "javascript", "typescript", "html", "css", "yaml", "xml", "bash")
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
        
    -ApiEndpoint <String>
        API endpoint URL, defaults to http://localhost:1234/v1/chat/completions.
        
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
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > qllm "What is 2+2?" -Model "qwen"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-LLMStringListEvaluation
    
SYNOPSIS
    Extracts or generates a list of relevant strings from input text using AI analysis.
    
    
SYNTAX
    Invoke-LLMStringListEvaluation [[-Text] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [[-Attachments] <String[]>] [-SetClipboard] [-ShowWindow] [-Temperature <Double>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ImageDetail <String>] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [-AllowDefaultTools] [<CommonParameters>]
    
    
DESCRIPTION
    This function uses AI models to analyze input text and extract or generate a list of relevant strings.
    It can process text to identify key points, extract items from lists, or generate related concepts.
    Input can be provided directly through parameters, from the pipeline, or from the system clipboard.
    

PARAMETERS
    -Text <String>
        The text to analyze and extract strings from. If not provided, the function will read from the
        system clipboard.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  false
        
    -Instructions <String>
        Optional instructions to guide the AI model in generating the string list. By default, it will
        extract key points, items, or relevant concepts from the input text.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        Specifies which AI model to use for the analysis. Different models may produce varying results.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Attachments <String[]>
        
        Required?                    false
        Position?                    4
        Default value                @()
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SetClipboard [<SwitchParameter>]
        When specified, copies the resulting string list back to the system clipboard after processing.
        
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
        
    -Temperature <Double>
        
        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -Force [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
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
        Array of command names that don't require confirmation
        
        Required?                    false
        Position?                    named
        Default value                @()
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
        
    -AllowDefaultTools [<SwitchParameter>]
        
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
    System.String[]
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS>Invoke-LLMStringListEvaluation -Text "PowerShell features: object-based pipeline, integrated scripting environment, backwards compatibility, and enterprise management."
    Returns: @("Object-based pipeline", "Integrated scripting environment", "Backwards compatibility", "Enterprise management")
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS>"Make a shopping list with: keyboard, mouse, monitor, headset" | Invoke-LLMStringListEvaluation
    Returns: @("Keyboard", "Mouse", "Monitor", "Headset")
    
    
    
    
    
    
    -------------------------- EXAMPLE 3 --------------------------
    
    PS>Invoke-LLMStringListEvaluation -Text "List common PowerShell commands for file operations" -SetClipboard
    Returns and copies to clipboard: @("Get-ChildItem", "Copy-Item", "Move-Item", "Remove-Item", "Set-Content", "Get-Content")
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-LLMTextTransformation
    
SYNOPSIS
    Transforms text using AI-powered processing.
    
    
SYNTAX
    Invoke-LLMTextTransformation [[-Text] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [[-Attachments] <String[]>] [-SetClipboard] [-ShowWindow] [-Temperature <Double>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ImageDetail <String>] [-DontAddThoughtsToHistory] [-ContinueLast] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [-AllowDefaultTools] [<CommonParameters>]
    
    
DESCRIPTION
    This function processes input text using AI models to perform various transformations
    such as spell checking, adding emoticons, or any other text enhancement specified
    through instructions. It can accept input directly through parameters, from the
    pipeline, or from the system clipboard.
    

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
        Instructions to guide the AI model in transforming the text. By default, it will
        perform spell checking and grammar correction.
        
        Required?                    false
        Position?                    2
        Default value                Check and correct any spelling or grammar errors in the text. Return the corrected text without any additional comments or explanations.
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        Specifies which AI model to use for the text transformation. Different models
        may produce varying results. Defaults to "qwen".
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Attachments <String[]>
        
        Required?                    false
        Position?                    4
        Default value                @()
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
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    -MaxToken <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -Force [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
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
        Array of command names that don't require confirmation
        
        Required?                    false
        Position?                    named
        Default value                @()
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
        
    -AllowDefaultTools [<SwitchParameter>]
        
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
    
    PS > Invoke-LLMTextTransformation -Text "Hello, hwo are you todey?"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "Time to celerbate!" | Invoke-LLMTextTransformation -Instructions "Add celebratory emoticons"
    
    
    
    
    
    
    
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
    New-LLMAudioChat [[-query] <String>] [[-Model] <String>] [[-ModelLMSGetIdentifier] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-AudioTemperature <Double>] [-Temperature <Double>] [-MaxToken <Int32>] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ImageDetail <String>] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-DontSpeak] [-DontSpeakThoughts] [-NoVOX] [-UseDesktopAudioCapture] [-TemperatureResponse <Double>] [-Language <String>] [-CpuThreads <Int32>] [-SuppressRegex <String>] [-AudioContextSize <Int32>] [-SilenceThreshold <Int32>] [-LengthPenalty <Single>] [-EntropyThreshold <Single>] [-LogProbThreshold <Single>] [-NoSpeechThreshold <Single>] [-NoContext] [-WithBeamSearchSamplingStrategy] [-OnlyResponses] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [-ResponseFormat <String>] [-OutputMarkupBlocksOnly] [-MarkupBlocksTypeFilter <String[]>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Initiates a voice-based conversation with a language model, supporting audio input
    and output. The function handles audio recording, transcription, model queries,
    and text-to-speech responses. Supports multiple language models and various
    configuration options.
    

PARAMETERS
    -query <String>
        Initial text query to send to the model. Can be empty to start with voice input.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        The model name/path to use. Supports -like pattern matching. Default: "qwen2.5-14b-instruct"
        
        Required?                    false
        Position?                    2
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Model identifier for LM Studio. Default: "qwen2.5-14b-instruct"
        
        Required?                    false
        Position?                    3
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Instructions <String>
        System instructions/prompt to guide the model's behavior.
        
        Required?                    false
        Position?                    4
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Attachments <String[]>
        Array of file paths to attach to the conversation for context.
        
        Required?                    false
        Position?                    5
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
        Temperature for response randomness. Range: 0.0-1.0. Default: 0.0
        
        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens in model response. Default: 8192
        
        Required?                    false
        Position?                    named
        Default value                8192
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
        
    -TTLSeconds <Int32>
        Time-to-live in seconds for models loaded via API requests. Default: -1
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        GPU offloading configuration. -2=Auto, -1=LM Studio decides, 0-1=fraction of layers
        Default: -1
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -ImageDetail <String>
        Image detail level setting. Options: "low", "medium", "high". Default: "low"
        
        Required?                    false
        Position?                    named
        Default value                low
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
        
    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions available as tools to the model.
        
        Required?                    false
        Position?                    named
        Default value                @()
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
        
    -ApiEndpoint <String>
        API endpoint URL. Default: http://localhost:1234/v1/chat/completions
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiKey <String>
        API key for authentication.
        
        Required?                    false
        Position?                    named
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
        
    -OutputMarkupBlocksOnly [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MarkupBlocksTypeFilter <String[]>
        
        Required?                    false
        Position?                    named
        Default value                @("json", "powershell", "C#", "python", "javascript", "typescript", "html", "css", "yaml", "xml", "bash")
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
    New-LLMTextChat [[-Query] <string>] [[-Model] <string>] [[-ModelLMSGetIdentifier] <string>] [[-Instructions] <string>] [[-Attachments] <string[]>] [-Temperature <double>] [-MaxToken <int>] [-ShowWindow] [-TTLSeconds <int>] [-Gpu <int>] [-Force] [-ImageDetail {low | medium | high}] [-IncludeThoughts] [-DontAddThoughtsToHistory] [-ContinueLast] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-Speak] [-SpeakThoughts] [-OutputMarkupBlocksOnly] [-MarkupBlocksTypeFilter <string[]>] [-ChatOnce] [-NoSessionCaching] [-ApiEndpoint <string>] [-ApiKey <string>] [-ResponseFormat <string>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
PARAMETERS
    -ApiEndpoint <string>
        Api endpoint url, defaults to http://localhost:1234/v1/chat/completions
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -ApiKey <string>
        The API key to use for the request
        
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
        Position?                    4
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
        
    -DontAddThoughtsToHistory
        Include model's thoughts in output
        
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
        
    -Force
        Force stop LM Studio before initialization
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Gpu <int>
        How much to offload to the GPU. If "off", GPU offloading is disabled. If "max", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto 
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        Position?                    3
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
        Maximum tokens in response (-1 for default)
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      MaxTokens
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Model <string>
        The LM-Studio model to use
        
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <string>
        The LM-Studio model identifier
        
        Required?                    false
        Position?                    2
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
        
    -OutputMarkupBlocksOnly
        Will only output markup block responses
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -ShowWindow
        Show the LM Studio window
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -TTLSeconds <int>
        Set a TTL (in seconds) for models loaded via API requests
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ttl
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
    System.String
    
    
OUTPUTS
    System.Object
    
ALIASES
    llmchat
    

REMARKS
    None 

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
 

&nbsp;<hr/>
###	GenXdev.AI.LMStudio<hr/> 
NAME
    AssureLMStudio
    
SYNOPSIS
    Ensures LM Studio is properly initialized with the specified model.
    
    
SYNTAX
    AssureLMStudio [[-Model] <String>] [[-ModelLMSGetIdentifier] <String>] [[-MaxToken] <Int32>] [[-TTLSeconds] <Int32>] [-ShowWindow] [-Force] [<CommonParameters>]
    
    
DESCRIPTION
    Initializes or reinitializes LM Studio with a specified model. This function
    handles process management, configuration settings, and ensures the proper model
    is loaded. It can force a restart if needed and manages window visibility.
    

PARAMETERS
    -Model <String>
        Name or partial path of the model to initialize. Supports wildcard patterns.
        Defaults to "qwen2.5-14b-instruct".
        
        Required?                    false
        Position?                    1
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        The specific LM-Studio model identifier to use. This should match an available
        model in LM Studio.
        
        Required?                    false
        Position?                    2
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum number of tokens allowed in responses. Use -1 for default setting.
        Default is 8192.
        
        Required?                    false
        Position?                    3
        Default value                8192
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        Time-to-live in seconds for models loaded via API requests. Use -1 for no TTL.
        
        Required?                    false
        Position?                    4
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ShowWindow [<SwitchParameter>]
        Shows the LM Studio window during initialization when specified.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces LM Studio to stop before initialization when specified.
        
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
    
    PS > AssureLMStudio -Model "qwen2.5-14b-instruct" -MaxToken 8192 -ShowWindow
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > AssureLMStudio "mistral-7b" -ttl 3600 -Force
    
    
    
    
    
    
    
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
    Get-LMStudioTextEmbedding [-Text] <String[]> [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
DESCRIPTION
    Gets text embeddings for the provided text using LM Studio's API. Can work with
    both local and remote LM Studio instances. Handles model initialization and API
    communication.
    

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
        The LM Studio model to use for embeddings.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Specific identifier used for getting model from LM Studio.
        
        Required?                    false
        Position?                    named
        Default value                
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
        
    -TTLSeconds <Int32>
        Time-to-live in seconds for models loaded via API requests.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        GPU offloading configuration:
        -2 = Auto
        -1 = LM Studio decides
        0-1 = Fraction of layers to offload
        "off" = Disabled
        "max" = Maximum offloading
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Forces LM Studio restart before processing.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiEndpoint <String>
        API endpoint URL, defaults to http://localhost:1234/v1/embeddings.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiKey <String>
        The API key to use for requests.
        
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
    
    PS > Get-LMStudioTextEmbedding -Text "Hello world" -Model "llama2" -ShowWindow
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "Sample text" | embed-text -ttl 3600
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-LMStudioWindow
    
SYNOPSIS
    Gets a window helper for the LM Studio application.
    
    
SYNTAX
    Get-LMStudioWindow [[-Model] <String>] [[-ModelLMSGetIdentifier] <String>] [[-MaxToken] <Int32>] [[-TTLSeconds] <Int32>] [-ShowWindow] [-Force] [-NoAutoStart] [<CommonParameters>]
    
    
DESCRIPTION
    Gets a window helper for the LM Studio application. If LM Studio is not running,
    it will be started automatically unless prevented by NoAutoStart switch.
    The function handles process management and window positioning.
    

PARAMETERS
    -Model <String>
        Name or partial path of the model to initialize.
        
        Required?                    false
        Position?                    1
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        The specific LM-Studio model identifier to use.
        
        Required?                    false
        Position?                    2
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens in response. Use -1 for default value.
        
        Required?                    false
        Position?                    3
        Default value                8192
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        Set a Time To Live (in seconds) for models loaded via API.
        
        Required?                    false
        Position?                    4
        Default value                -1
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
    
    PS > Get-LMStudioWindow "qwen2.5-14b-instruct" -ttl 3600
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Initialize-LMStudioModel
    
SYNOPSIS
    Initializes and loads an AI model in LM Studio.
    
    
SYNTAX
    Initialize-LMStudioModel [[-Model] <String>] [[-ModelLMSGetIdentifier] <String>] [[-MaxToken] <Int32>] [[-TTLSeconds] <Int32>] [[-Gpu] <Int32>] [-ShowWindow] [-Force] [-PreferredModels <String[]>] [-Unload] [<CommonParameters>]
    
    
DESCRIPTION
    Searches for and loads a specified AI model in LM Studio. Handles installation
    verification, process management, and model loading with GPU support.
    

PARAMETERS
    -Model <String>
        Name or partial path of the model to initialize. Searched against available models.
        
        Required?                    false
        Position?                    1
        Default value                [string]::Empty
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        The specific LM-Studio model identifier to use for download/initialization.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens allowed in response. -1 for default limit.
        
        Required?                    false
        Position?                    3
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        Time-to-live in seconds for loaded models. -1 for no TTL.
        
        Required?                    false
        Position?                    4
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        GPU offloading level: -2=Auto, -1=LMStudio decides, 0=Off, 0-1=Layer fraction
        
        Required?                    false
        Position?                    5
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ShowWindow [<SwitchParameter>]
        Shows the LM Studio window during initialization.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Force [<SwitchParameter>]
        Force stops LM Studio before initialization.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -PreferredModels <String[]>
        Array of model names to try if specified model not found.
        
        Required?                    false
        Position?                    named
        Default value                @(
                    "qwen2.5-14b-instruct", "vicuna", "alpaca", "gpt", "mistral", "falcon", "mpt",
                    "koala", "wizard", "guanaco", "bloom", "rwkv", "camel", "pythia",
                    "baichuan"
                )
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
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ShowWindow -MaxToken 2048
    
    
    
    
    
    
    
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
    Start-LMStudioApplication [[-WithVisibleWindow]] [-Passthru] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    This function checks if LM Studio is installed and running. If not installed, it
    will install it. If not running, it will start it with the specified window
    visibility.
    

PARAMETERS
    -WithVisibleWindow [<SwitchParameter>]
        
        Required?                    false
        Position?                    1
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
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
    
    PS > Start-LMStudioApplication -WithVisibleWindow -Passthru
    
    
    
    
    
    
    
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
    Add-EmoticonsToText [[-Text] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-SetClipboard] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
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
        
    -Model <String>
        Specifies which AI model to use for emoticon selection and placement. Different
        models may produce varying results in terms of emoticon selection and context
        understanding. Defaults to "qwen".
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        
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
        
    -MaxToken <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -Force [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
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
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    ConvertFrom-CorporateSpeak
    
SYNOPSIS
    Converts polite, professional corporate speak into direct, clear language using AI.
    
    
SYNTAX
    ConvertFrom-CorporateSpeak [[-Text] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-SetClipboard] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
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
        
    -Instructions <String>
        Additional instructions to guide the AI model in converting the text.
        These can help fine-tune the tone and style of the direct language.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        Specifies which AI model to use for text transformation. Different models may
        produce varying results in terms of language style.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Identifier used for getting specific model from LM Studio.
        
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
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens in response (-1 for default).
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -TTLSeconds <Int32>
        Set a TTL (in seconds) for models loaded via API requests.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        How much to offload to the GPU. -2=Auto, -1=LMStudio decides, 0=Off, 0-1=Layer
        fraction.
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    System.String
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > ConvertFrom-CorporateSpeak -Text "I would greatly appreciate your timely
    response" -Model "qwen" -SetClipboard
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > "We should circle back" | uncorporatize
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    ConvertFrom-DiplomaticSpeak
    
SYNTAX
    ConvertFrom-DiplomaticSpeak [[-Text] <string>] [[-Instructions] <string>] [[-Model] <string>] [-ModelLMSGetIdentifier <string>] [-Temperature <double>] [-MaxToken <int>] [-SetClipboard] [-ShowWindow] [-TTLSeconds <int>] [-Gpu <int>] [-Force] [-ApiEndpoint <string>] [-ApiKey <string>] [<CommonParameters>]
    
    
PARAMETERS
    -ApiEndpoint <string>
        Api endpoint url, defaults to http://localhost:1234/v1/chat/completions
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -ApiKey <string>
        The API key to use for the request
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -Gpu <int>
        How much to offload to the GPU. If "off", GPU offloading is disabled. If "max", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto 
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Instructions <string>
        Additional instructions for the AI model
        
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -MaxToken <int>
        Maximum tokens in response (-1 for default)
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      MaxTokens
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Model <string>
        The LM-Studio model to use
        
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <string>
        Identifier used for getting specific model from LM Studio
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -SetClipboard
        Copy the transformed text to clipboard
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -TTLSeconds <int>
        Set a TTL (in seconds) for models loaded via API requests
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ttl
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
        
    -Text <string>
        The text to convert from diplomatic speak
        
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
    System.String
    
    
OUTPUTS
    System.String
    
    
ALIASES
    undiplomatize
    

REMARKS
    None 

<br/><hr/><hr/><br/>
 
NAME
    ConvertTo-CorporateSpeak
    
SYNOPSIS
    Converts direct or blunt text into polite, professional corporate speak using AI.
    
    
SYNTAX
    ConvertTo-CorporateSpeak [[-Text] <String>] [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-SetClipboard] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This function processes input text to transform direct or potentially harsh
    language into diplomatic, professional corporate communications. It can accept
    input directly through parameters, from the pipeline, or from the system
    clipboard. The function leverages AI models to analyze and rephrase text while
    preserving the original intent.
    

PARAMETERS
    -Text <String>
        The input text to convert to corporate speak. If not provided, the function will
        read from the system clipboard. Multiple lines of text are supported.
        
        Required?                    false
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  false
        
    -Instructions <String>
        Additional instructions to guide the AI model in converting the text.
        These can help fine-tune the tone and style of the corporate language.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        Specifies which AI model to use for text transformation. Different models may
        produce varying results in terms of corporate language style.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Identifier used for getting specific model from LM Studio.
        
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
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens in response (-1 for default).
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -TTLSeconds <Int32>
        Set a TTL (in seconds) for models loaded via API requests.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        How much to offload to the GPU. -2=Auto, -1=LMStudio decides, 0=Off, 0-1=Layer
        fraction.
        
        Required?                    false
        Position?                    named
        Default value                -1
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
    
SYNTAX
    ConvertTo-DiplomaticSpeak [[-Text] <string>] [[-Instructions] <string>] [[-Model] <string>] [-ModelLMSGetIdentifier <string>] [-Temperature <double>] [-MaxToken <int>] [-SetClipboard] [-ShowWindow] [-TTLSeconds <int>] [-Gpu <int>] [-Force] [-ApiEndpoint <string>] [-ApiKey <string>] [<CommonParameters>]
    
    
PARAMETERS
    -ApiEndpoint <string>
        Api endpoint url
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -ApiKey <string>
        The API key to use for the request
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -Gpu <int>
        GPU offload level (-2=Auto through 1=Full)
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Instructions <string>
        Additional instructions for the AI model
        
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -MaxToken <int>
        Maximum tokens in response (-1 for default)
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      MaxTokens
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Model <string>
        The LM-Studio model to use
        
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <string>
        Identifier for getting specific model from LM Studio
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -SetClipboard
        Copy the transformed text to clipboard
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -TTLSeconds <int>
        Set a TTL (in seconds) for models loaded via API
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ttl
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
        
    -Text <string>
        The text to convert to diplomatic speak
        
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
    System.String
    
    
OUTPUTS
    System.String
    
    
ALIASES
    diplomatize
    

REMARKS
    None 

<br/><hr/><hr/><br/>
 
NAME
    Get-Fallacy
    
SYNTAX
    Get-Fallacy [-Text] <string[]> [[-Instructions] <string>] [[-Model] <string>] [[-Attachments] <string[]>] [-ModelLMSGetIdentifier <string>] [-OpenInImdb] [-ShowWindow] [-Temperature <double>] [-MaxToken <int>] [-TTLSeconds <int>] [-Gpu <int>] [-Force] [-ApiEndpoint <string>] [-ApiKey <string>] [-ImageDetail {low | medium | high}] [-IncludeThoughts] [-ContinueLast] [-Functions <hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <string[]>] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [<CommonParameters>]
    
    
PARAMETERS
    -ApiEndpoint <string>
        Api endpoint url, defaults to http://localhost:1234/v1/chat/completions
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -ApiKey <string>
        The API key to use for the request
        
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
        Position?                    3
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
        
    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to use as tools
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        How much to offload to the GPU. If "off", GPU offloading is disabled. If "max", all layers are offloaded to GPU. If a number between 0 and 1, that fraction of layers will be offloaded to the GPU. -1 = LM Studio will decide how much to offload to the GPU. -2 = Auto 
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        Instructions for the AI model on how to generate the string list
        
        Required?                    false
        Position?                    1
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -MaxToken <int>
        Maximum tokens in response (-1 for default)
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      MaxTokens
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -Model <string>
        The LM-Studio model to use
        
        Required?                    false
        Position?                    2
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <string>
        Identifier used for getting specific model from LM Studio
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
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
        
    -NoSessionCaching
        Don't store session in session cache
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      None
        Dynamic?                     false
        Accept wildcard characters?  false
        
    -OpenInImdb
        Opens IMDB searches for each result
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      imdb
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
        
    -TTLSeconds <int>
        Set a TTL (in seconds) for models loaded via API requests
        
        Required?                    false
        Position?                    Named
        Accept pipeline input?       false
        Parameter set name           (All)
        Aliases                      ttl
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
        
    -Text <string[]>
        Text to parse to find Fallacies in
        
        Required?                    true
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
    System.String[]
    
    
OUTPUTS
    System.Object[]
    
    
ALIASES
    None
    

REMARKS
    None 

<br/><hr/><hr/><br/>
 
NAME
    Get-MediaFileAudioTranscription
    
SYNOPSIS
    Transcribes an audio or video file to text..
    
    
SYNTAX
    Get-MediaFileAudioTranscription [-FilePath] <String> [[-LanguageIn] <String>] [[-LanguageOut] <String>] [-TranslateUsingLMStudioModel <String>] [-SRT] [-PassThru] [-UseDesktopAudioCapture] [-WithTokenTimestamps] [-TokenTimestampsSumThreshold <Single>] [-SplitOnWord] [-MaxTokensPerSegment <Int32>] [-IgnoreSilence] [-MaxDurationOfSilence <Object>] [-SilenceThreshold <Int32>] [-CpuThreads <Int32>] [-Temperature <Single>] [-TemperatureInc <Single>] [-Prompt <String>] [-SuppressRegex <String>] [-WithProgress] [-AudioContextSize <Int32>] [-DontSuppressBlank] [-MaxDuration <Object>] [-Offset <Object>] [-MaxLastTextTokens <Int32>] [-SingleSegmentOnly] [-PrintSpecialTokens] [-MaxSegmentLength <Int32>] [-MaxInitialTimestamp <Object>] [-LengthPenalty <Single>] [-EntropyThreshold <Single>] [-LogProbThreshold <Single>] [-NoSpeechThreshold <Single>] [-NoContext] [-WithBeamSearchSamplingStrategy] [<CommonParameters>]
    
    
DESCRIPTION
    Transcribes an audio or video file to text using the Whisper AI model
    

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
        
    -TranslateUsingLMStudioModel <String>
        The LM Studio model to use for translation.
        
        Required?                    false
        Position?                    named
        Default value                qwen
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
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
        
    -WithTokenTimestamps [<SwitchParameter>]
        Whether to include token timestamps in the output.
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    -SplitOnWord [<SwitchParameter>]
        Whether to split on word boundaries.
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    -IgnoreSilence [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    -WithProgress [<SwitchParameter>]
        Whether to show progress.
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    -DontSuppressBlank [<SwitchParameter>]
        Whether to NOT suppress blank lines.
        
        Required?                    false
        Position?                    named
        Default value                False
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
        
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters (https://go.microsoft.com/fwlink/?LinkID=113216). 
    
INPUTS
    
OUTPUTS
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > Get-MediaFileAudioTranscription -FilePath "C:\path\to\audio.wav" -LanguageIn "English" -LanguageOut "French" -SRT
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-ScriptExecutionErrorFixPrompt
    
SYNOPSIS
    Captures error messages from various streams and uses LLM to suggest fixes.
    
    
SYNTAX
    Get-ScriptExecutionErrorFixPrompt [-Script] <ScriptBlock> [[-Model] <String>] [[-ModelLMSGetIdentifier] <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This cmdlet captures error messages from various PowerShell streams (pipeline
    input, verbose, information, error, and warning) and formulates a structured
    prompt for an LLM to analyze and suggest fixes. It then invokes the LLM query
    and returns the suggested solution.
    

PARAMETERS
    -Script <ScriptBlock>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        The name or identifier of the LM Studio model to use.
        Default: qwen2.5-14b-instruct
        
        Required?                    false
        Position?                    2
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Alternative identifier for getting a specific model from LM Studio.
        Default: qwen2.5-14b-instruct
        
        Required?                    false
        Position?                    3
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Temperature <Double>
        Controls response randomness (0.0-1.0). Lower values are more deterministic.
        Default: 0.0
        
        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens allowed in the response. Use -1 for model default.
        Default: -1
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -TTLSeconds <Int32>
        Time-to-live in seconds for loaded models.
        Default: -1
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        GPU offloading control:
        -2 = Auto
        -1 = LM Studio decides
        0-1 = Fraction of layers to offload
        "off" = Disabled
        "max" = All layers
        Default: -1
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        Exclude model's thoughts from output history.
        
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
        
    -Functions <Hashtable[]>
        Array of function definitions to expose to LLM.
        
        Required?                    false
        Position?                    named
        Default value                @()
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ExposedCmdLets <ExposedCmdletDefinition[]>
        Array of PowerShell command definitions to expose as tools.
        
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
        
    -NoSessionCaching [<SwitchParameter>]
        Don't store session in session cache.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiEndpoint <String>
        API endpoint URL. Defaults to http://localhost:1234/v1/chat/completions
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiKey <String>
        The API key to use for requests.
        
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
    System.Object[]
    
    
    -------------------------- EXAMPLE 1 --------------------------
    
    PS > $errorInfo = Get-ScriptExecutionErrorFixPrompt -Model *70b* {
    
    My-ScriptThatFails
    }
    
    Write-Host $errorInfo
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Get-SimularMovieTitles
    
SYNOPSIS
    Finds similar movie titles based on common properties.
    
    
SYNTAX
    Get-SimularMovieTitles [-Movies] <String[]> [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-OpenInImdb] [-ShowWindow] [-Temperature <Double>] [-MaxToken <Int32>] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
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
        
    -Model <String>
        The LM-Studio model to use for analysis.
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Identifier used for getting specific model from LM Studio.
        
        Required?                    false
        Position?                    named
        Default value                
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
        
    -Temperature <Double>
        Temperature for response randomness (0.0-1.0).
        
        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens in response (-1 for default).
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        Set a TTL (in seconds) for models loaded via API requests.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        GPU offload configuration (-2=Auto, -1=LMStudio decides, 0-1=fraction, off=CPU).
        
        Required?                    false
        Position?                    named
        Default value                -1
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
    Invoke-AIPowershellCommand [-Query] <String> [[-Instructions] <String>] [[-Model] <String>] [-ModelLMSGetIdentifier <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-Clipboard] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-ApiEndpoint <String>] [-ApiKey <String>] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
DESCRIPTION
    Uses LM-Studio to generate PowerShell commands based on natural language queries.
    The function can either send commands directly to the PowerShell window or copy
    them to the clipboard. It leverages AI models to interpret natural language and
    convert it into executable PowerShell commands.
    

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
        
    -Instructions <String>
        
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        The LM-Studio model to use for command generation. Can be a name or partial path.
        Supports -like pattern matching for model selection.
        
        Required?                    false
        Position?                    3
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Temperature <Double>
        Controls the randomness in the AI's response generation. Values range from 0.0
        (more focused/deterministic) to 1.0 (more creative/random).
        
        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Clipboard [<SwitchParameter>]
        When specified, copies the generated command to clipboard.
        
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
        
    -TTLSeconds <Int32>
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        
    -Force [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
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
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > hint "list files modified today"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-ImageKeywordScan
    
SYNOPSIS
    Scans image files for keywords and descriptions using metadata files.
    
    
SYNTAX
    Invoke-ImageKeywordScan [[-Keywords] <String[]>] [[-ImageDirectory] <String>] [[-PassThru]] [<CommonParameters>]
    
    
DESCRIPTION
    Searches for image files (jpg, jpeg, png) in the specified directory and its
    subdirectories. For each image, checks associated description.json and
    keywords.json files for metadata. Can filter images based on keyword matches and
    display results in a masonry layout web view or return as objects.
    

PARAMETERS
    -Keywords <String[]>
        Array of keywords to search for. Supports wildcards. If empty, returns all images
        with any metadata.
        
        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ImageDirectory <String>
        Directory path to search for images. Defaults to current directory.
        
        Required?                    false
        Position?                    2
        Default value                .\
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -PassThru [<SwitchParameter>]
        Switch to return image data as objects instead of displaying in browser.
        
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
    
    PS > Invoke-ImageKeywordScan -Keywords "cat","dog" -ImageDirectory "C:\Photos"
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > findimages cat,dog "C:\Photos"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-ImageKeywordUpdate
    
SYNOPSIS
    Updates image metadata with AI-generated descriptions and keywords.
    
    
SYNTAX
    Invoke-ImageKeywordUpdate [[-ImageDirectory] <String>] [[-Recurse]] [[-OnlyNew]] [[-RetryFailed]] [<CommonParameters>]
    
    
DESCRIPTION
    The Invoke-ImageKeywordUpdate function analyzes images using AI to generate
    descriptions, keywords, and other metadata. It creates a companion JSON file for
    each image containing this information. The function can process new images only
    or update existing metadata, and supports recursive directory scanning.
    

PARAMETERS
    -ImageDirectory <String>
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
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -OnlyNew [<SwitchParameter>]
        When specified, only processes images that don't already have metadata JSON
        files.
        
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -RetryFailed [<SwitchParameter>]
        When specified, reprocesses images where previous metadata generation attempts
        failed.
        
        Required?                    false
        Position?                    4
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
    
    PS > Invoke-ImageKeywordUpdate -ImageDirectory "C:\Photos" -Recurse -OnlyNew
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > updateimages -Recurse -RetryFailed
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Invoke-QueryImageContent
    
SYNOPSIS
    Analyzes image content using AI vision capabilities through the LM-Studio API.
    
    
SYNTAX
    Invoke-QueryImageContent [-Query] <String> [-ImagePath] <String> [[-Temperature] <Double>] [-ResponseFormat <String>] [[-MaxToken] <Int32>] [<CommonParameters>]
    
    
DESCRIPTION
    Processes images using the MiniCPM model via LM-Studio API to analyze content and
    answer queries about the image. The function supports various analysis parameters
    including temperature control for response randomness and token limits for output
    length.
    

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
        
    -Temperature <Double>
        Controls the randomness in the AI's response generation. Lower values (closer
        to 0) produce more focused and deterministic responses, while higher values
        increase creativity and variability. Valid range: 0.0 to 1.0.
        
        Required?                    false
        Position?                    3
        Default value                0.01
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
        
    -MaxToken <Int32>
        Limits the length of the generated response by specifying maximum tokens.
        Use -1 for unlimited response length. Valid range: -1 to MaxInt.
        
        Required?                    false
        Position?                    4
        Default value                -1
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
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > Query-Image "Describe this image" "C:\Images\photo.jpg"
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Save-Transcriptions
    
SYNOPSIS
    Generates subtitle files for audio and video files using OpenAI Whisper.
    
    
SYNTAX
    Save-Transcriptions [[-DirectoryPath] <String>] [[-LanguageIn] <String>] [[-LanguageOut] <String>] [-TranslateUsingLMStudioModel <String>] [<CommonParameters>]
    
    
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
        Default value                English
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
        
    -TranslateUsingLMStudioModel <String>
        The LM Studio model name to use for translation. Defaults to "qwen". Only used
        when LanguageOut is specified.
        
        Required?                    false
        Position?                    named
        Default value                qwen
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
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Show-GenXdevScriptErrorFixInIde
    
SYNOPSIS
    Parses error messages and fixes them using Github Copilot in VSCode.
    
    
SYNTAX
    Show-GenXdevScriptErrorFixInIde [-Script] <ScriptBlock> [[-Model] <String>] [[-ModelLMSGetIdentifier] <String>] [-Temperature <Double>] [-MaxToken <Int32>] [-ShowWindow] [-TTLSeconds <Int32>] [-Gpu <Int32>] [-Force] [-DontAddThoughtsToHistory] [-ContinueLast] [-Functions <Hashtable[]>] [-ExposedCmdLets <ExposedCmdletDefinition[]>] [-NoConfirmationToolFunctionNames <String[]>] [-Speak] [-SpeakThoughts] [-NoSessionCaching] [-ApiEndpoint <String>] [-ApiKey <String>] [<CommonParameters>]
    
    
DESCRIPTION
    This function analyzes error messages from any input source, identifies
    files that need attention, and opens them in Visual Studio Code with appropriate
    Github Copilot prompts to assist in fixing the issues.
    

PARAMETERS
    -Script <ScriptBlock>
        
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       true (ByValue)
        Aliases                      
        Accept wildcard characters?  false
        
    -Model <String>
        The LM-Studio model to use for error analysis. Defaults to "qwen2.5-14b-instruct".
        
        Required?                    false
        Position?                    2
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  true
        
    -ModelLMSGetIdentifier <String>
        Identifier used for getting specific model from LM Studio.
        
        Required?                    false
        Position?                    3
        Default value                qwen2.5-14b-instruct
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Temperature <Double>
        Temperature setting for response randomness (0.0-1.0).
        
        Required?                    false
        Position?                    named
        Default value                0.2
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxToken <Int32>
        Maximum tokens allowed in response (-1 for default).
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ShowWindow [<SwitchParameter>]
        If specified, shows the LM Studio window during processing.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TTLSeconds <Int32>
        Set a TTL (in seconds) for models loaded via API requests.
        
        Required?                    false
        Position?                    named
        Default value                -1
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Gpu <Int32>
        GPU offloading configuration:
        - "off": GPU offloading disabled
        - "max": All layers offloaded to GPU
        - 0-1: Fraction of layers offloaded
        - -1: LM Studio decides offloading
        - -2: Auto configure
        
        Required?                    false
        Position?                    named
        Default value                -1
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
        Skip including model's thoughts in output.
        
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
        
    -ApiEndpoint <String>
        Api endpoint url, defaults to http://localhost:1234/v1/chat/completions.
        
        Required?                    false
        Position?                    named
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -ApiKey <String>
        The API key for authentication.
        
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
    
    PS > Show-GenXdevScriptErrorFixInIde -Model "qwen2.5-14b-instruct" -Script {
    
    Run-ErrorousScript
    }
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > $errorOutput | letsfixthis
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
 
NAME
    Start-AudioTranscription
    
SYNOPSIS
    Transcribes audio to text using various input methods and advanced configuration
    options.
    
    
SYNTAX
    Start-AudioTranscription [[-ModelFilePath] <String>] [[-WaveFile] <String>] [-VOX] [-PassThru] [-UseDesktopAudioCapture] [-WithTokenTimestamps] [[-TokenTimestampsSumThreshold] <Single>] [-SplitOnWord] [[-MaxTokensPerSegment] <Int32>] [-IgnoreSilence] [[-MaxDurationOfSilence] <Object>] [[-SilenceThreshold] <Int32>] [[-Language] <String>] [[-CpuThreads] <Int32>] [[-Temperature] <Single>] [[-TemperatureInc] <Single>] [-WithTranslate] [[-Prompt] <String>] [[-SuppressRegex] <String>] [-WithProgress] [[-AudioContextSize] <Int32>] [-DontSuppressBlank] [[-MaxDuration] <Object>] [[-Offset] <Object>] [[-MaxLastTextTokens] <Int32>] [-SingleSegmentOnly] [-PrintSpecialTokens] [[-MaxSegmentLength] <Int32>] [[-MaxInitialTimestamp] <Object>] [[-LengthPenalty] <Single>] [[-EntropyThreshold] <Single>] [[-LogProbThreshold] <Single>] [[-NoSpeechThreshold] <Single>] [-NoContext] [-WithBeamSearchSamplingStrategy] [-Realtime] [-WhatIf] [-Confirm] [<CommonParameters>]
    
    
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
        
    -VOX [<SwitchParameter>]
        
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
        
    -WithTokenTimestamps [<SwitchParameter>]
        Whether to include token timestamps in the output.
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TokenTimestampsSumThreshold <Single>
        Sum threshold for token timestamps, defaults to 0.5.
        
        Required?                    false
        Position?                    3
        Default value                0.5
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
        
    -MaxTokensPerSegment <Int32>
        Maximum number of tokens per segment.
        
        Required?                    false
        Position?                    4
        Default value                0
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
        
    -MaxDurationOfSilence <Object>
        Maximum duration of silence before automatically stopping recording.
        
        Required?                    false
        Position?                    5
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SilenceThreshold <Int32>
        Silence detect threshold (0..32767 defaults to 30).
        
        Required?                    false
        Position?                    6
        Default value                30
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Language <String>
        Sets the language to detect.
        
        Required?                    false
        Position?                    7
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -CpuThreads <Int32>
        Number of CPU threads to use, defaults to 0 (auto).
        
        Required?                    false
        Position?                    8
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Temperature <Single>
        Temperature for speech generation.
        
        Required?                    false
        Position?                    9
        Default value                0.01
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -TemperatureInc <Single>
        Temperature increment.
        
        Required?                    false
        Position?                    10
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -WithTranslate [<SwitchParameter>]
        
        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Prompt <String>
        Prompt to use for the model.
        
        Required?                    false
        Position?                    11
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -SuppressRegex <String>
        Regex to suppress tokens from the output.
        
        Required?                    false
        Position?                    12
        Default value                
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
        
    -AudioContextSize <Int32>
        Size of the audio context.
        
        Required?                    false
        Position?                    13
        Default value                0
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
        
    -MaxDuration <Object>
        Maximum duration of the audio.
        
        Required?                    false
        Position?                    14
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -Offset <Object>
        Offset for the audio.
        
        Required?                    false
        Position?                    15
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxLastTextTokens <Int32>
        Maximum number of last text tokens.
        
        Required?                    false
        Position?                    16
        Default value                0
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
        
    -MaxSegmentLength <Int32>
        Maximum segment length.
        
        Required?                    false
        Position?                    17
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -MaxInitialTimestamp <Object>
        Start timestamps at this moment.
        
        Required?                    false
        Position?                    18
        Default value                
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -LengthPenalty <Single>
        Length penalty.
        
        Required?                    false
        Position?                    19
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -EntropyThreshold <Single>
        Entropy threshold.
        
        Required?                    false
        Position?                    20
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -LogProbThreshold <Single>
        Log probability threshold.
        
        Required?                    false
        Position?                    21
        Default value                0
        Accept pipeline input?       false
        Aliases                      
        Accept wildcard characters?  false
        
    -NoSpeechThreshold <Single>
        No speech threshold.
        
        Required?                    false
        Position?                    22
        Default value                0
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
    
    PS > # Basic transcription using default settings
    $text = Start-AudioTranscription
    Write-Output $text
    
    
    
    
    
    
    -------------------------- EXAMPLE 2 --------------------------
    
    PS > # Advanced transcription with silence detection and desktop audio
    $result = Start-AudioTranscription -VOX -UseDesktopAudioCapture `
        -Language "English" -WithTokenTimestamps
    
    
    
    
    
    
    
RELATED LINKS 

<br/><hr/><hr/><br/>
