<hr/>

<img src="powershell.jpg" alt="GenXdev" width="50%"/>

<hr/>

### NAME
    GenXdev.AI
### SYNOPSIS
    A Windows PowerShell module for local and online AI related operations
[![GenXdev.AI](https://img.shields.io/powershellgallery/v/GenXdev.AI.svg?style=flat-square&label=GenXdev.AI)](https://www.powershellgallery.com/packages/GenXdev.AI/) [![License](https://img.shields.io/github/license/genXdev/GenXdev.AI?style=flat-square)](./LICENSE)

### FEATURES

### DEPENDENCIES
[![WinOS - Windows-10](https://img.shields.io/badge/WinOS-Windows--10--10.0.19041--SP0-brightgreen)](https://www.microsoft.com/en-us/windows/get-windows-10) [![GenXdev.Helpers](https://img.shields.io/powershellgallery/v/GenXdev.Helpers.svg?style=flat-square&label=GenXdev.Helpers)](https://www.powershellgallery.com/packages/GenXdev.Helpers/) [![GenXdev.Webbrowser](https://img.shields.io/powershellgallery/v/GenXdev.Webbrowser.svg?style=flat-square&label=GenXdev.Webbrowser)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![GenXdev.Queries](https://img.shields.io/powershellgallery/v/GenXdev.Queries.svg?style=flat-square&label=GenXdev.Queries)](https://www.powershellgallery.com/packages/GenXdev.Webbrowser/) [![GenXdev.Console](https://img.shields.io/powershellgallery/v/GenXdev.Console.svg?style=flat-square&label=GenXdev.Console)](https://www.powershellgallery.com/packages/GenXdev.Console/)  [![GenXdev.FileSystem](https://img.shields.io/powershellgallery/v/GenXdev.FileSystem.svg?style=flat-square&label=GenXdev.FileSystem)](https://www.powershellgallery.com/packages/GenXdev.FileSystem/)
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
| [Invoke-LMStudioQuery](#Invoke-LMStudioQuery) | qlms | The `Invoke-LMStudioQuery` function sends a query to the LM-Studio API and returns the response. |
| [Invoke-QueryImageContent](#Invoke-QueryImageContent) |  | The `Invoke-QueryImageContent` function sends an image to the LM-Studio API and returns the response. |
| [Invoke-QueryImageKeywords](#Invoke-QueryImageKeywords) |  | The `Invoke-QueryImageKeywords` function sends an image to the LM-Studio API and returns keywords found in the image. |
| [Invoke-ImageKeywordUpdate](#Invoke-ImageKeywordUpdate) | updateimages | The `Invoke-ImageKeywordUpdate` function updates the keywords and description of images in a directory. |
| [Invoke-ImageKeywordScan](#Invoke-ImageKeywordScan) | findimages | The `Invoke-ImageKeywordScan` function scans images in a directory for keywords and description. |
| [GenerateMasonryLayoutHtml](#GenerateMasonryLayoutHtml) |  | The `GenerateMasonryLayoutHtml` function creates an HTML file with a masonry layout for displaying images, including their descriptions and keywords. |
| [Add-ImageDescriptionsToFileNames](#Add-ImageDescriptionsToFileNames) |  | This function iterates through all image files in a given directory and appends a description to each file name. The description is extracted from the image metadata. |
| [Start-AudioTranscription](#Start-AudioTranscription) |  | Records audio using the default audio input device and returns the detected text |
| [Start-AudioChat](#Start-AudioChat) |  | Starts an audio chat session by recording audio and invoking the default LLM |
| [Get-MediaFileAudioTranscription](#Get-MediaFileAudioTranscription) |  | Transcribes an audio or video file to text using the Whisper AI model |

<br/><hr/><hr/><br/>


# Cmdlets

&nbsp;<hr/>
###	GenXdev.AI<hr/>

##	Invoke-LMStudioQuery
````PowerShell
Invoke-LMStudioQuery                 --> qlms
````

### SYNOPSIS
    Queries the LM-Studio API with the given parameters and returns the response.

### SYNTAX
````PowerShell
Invoke-LMStudioQuery [-query] <String> [[-attachments] <String[]>] [[-instructions] 
<String>] [[-model] <String>] [[-temperature] <Double>] [[-max_token] <Int32>] 
[[-imageDetail] <String>] [<CommonParameters>]
````

### DESCRIPTION
    The `Invoke-LMStudioQuery` function sends a query to the LM-Studio API and returns the 
    response.

### PARAMETERS
    -query <String>
        The query string for the LLM
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -attachments <String[]>
        The file paths of the attachments to send with the query.
        Required?                    false
        Position?                    2
        Default value                @()
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -instructions <String>
        The system instructions for the LLM.
        Required?                    false
        Position?                    3
        Default value                Your an AI assistent that never tells a lie and always 
        answers truthfully, first of all comprehensive and then if possible consice.
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -model <String>
        The LM-Studio model to use for generating the response.
        Required?                    false
        Position?                    4
        Default value                yi-coder-9b-chat
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -temperature <Double>
        The temperature parameter for controlling the randomness of the response.
        Required?                    false
        Position?                    5
        Default value                0.7
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -max_token <Int32>
        The maximum number of tokens to generate in the response.
        Required?                    false
        Position?                    6
        Default value                -1
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -imageDetail <String>
        The image detail to use for the attachments.
        Required?                    false
        Position?                    7
        Default value                low
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Invoke-QueryImageContent
````PowerShell
Invoke-QueryImageContent
````

### SYNOPSIS
    Queries the LM-Studio API with an image and returns the response.

### SYNTAX
````PowerShell
Invoke-QueryImageContent [-query] <String> [-ImagePath] <String> [[-temperature] <Double>] 
[<CommonParameters>]
````

### DESCRIPTION
    The `Invoke-QueryImageContent` function sends an image to the LM-Studio API and returns 
    the response.

### PARAMETERS
    -query <String>
        The query string for the LLM.
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -ImagePath <String>
        The file path of the image to send with the query.
        Required?                    true
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -temperature <Double>
        Required?                    false
        Position?                    4
        Default value                0.25
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Invoke-QueryImageKeywords
````PowerShell
Invoke-QueryImageKeywords
````

### SYNOPSIS
    Queries the LM-Studio API to get keywords from an image.

### SYNTAX
````PowerShell
Invoke-QueryImageKeywords [-ImagePath] <String> [<CommonParameters>]
````

### DESCRIPTION
    The `Invoke-QueryImageKeywords` function sends an image to the LM-Studio API and returns 
    keywords found in the image.

### PARAMETERS
    -ImagePath <String>
        The file path of the image to send with the query.
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Invoke-ImageKeywordUpdate
````PowerShell
Invoke-ImageKeywordUpdate            --> updateimages
````

### SYNOPSIS
    Queries the LM-Studio API to get keywords from an image.

### SYNTAX
````PowerShell
Invoke-ImageKeywordUpdate [[-imageDirectory] <String>] [[-recurse]] [[-onlyNew]] 
[[-retryFailed]] [<CommonParameters>]
````

### DESCRIPTION
    The `Invoke-ImageKeywordUpdate` function updates the keywords and description of images in 
    a directory.

### PARAMETERS
    -imageDirectory <String>
        The directory path of the images to update.
        Required?                    false
        Position?                    1
        Default value                .\
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -recurse [<SwitchParameter>]
        Recursively search for images in subdirectories.
        Required?                    false
        Position?                    2
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -onlyNew [<SwitchParameter>]
        Only update images that do not have keywords and description.
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -retryFailed [<SwitchParameter>]
        Retry previously failed images.
        Required?                    false
        Position?                    4
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Invoke-ImageKeywordScan
````PowerShell
Invoke-ImageKeywordScan              --> findimages
````

### SYNOPSIS
    Queries the LM-Studio API to get keywords from an image.

### SYNTAX
````PowerShell
Invoke-ImageKeywordScan [[-keywords] <String[]>] [[-imageDirectory] <String>] 
[[-passthru]] [<CommonParameters>]
````

### DESCRIPTION
    The `Invoke-ImageKeywordScan` function scans images in a directory for keywords and 
    description.

### PARAMETERS
    -keywords <String[]>
        The keywords to look for, wildcards allowed.
        Required?                    false
        Position?                    1
        Default value                @()
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -imageDirectory <String>
        The image directory path.
        Required?                    false
        Position?                    2
        Default value                .\
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -passthru [<SwitchParameter>]
        Do not show the images in the webbrowser, return as object instead.
        Required?                    false
        Position?                    3
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	GenerateMasonryLayoutHtml
````PowerShell
GenerateMasonryLayoutHtml
````

### SYNOPSIS
    Generates an HTML file with a masonry layout for displaying images.

### SYNTAX
````PowerShell
GenerateMasonryLayoutHtml [-Images] <Array> [[-FilePath] <String>] [<CommonParameters>]
````

### DESCRIPTION
    The `GenerateMasonryLayoutHtml` function creates an HTML file with a masonry layout for 
    displaying images, including their descriptions and keywords.

### PARAMETERS
    -Images <Array>
        An array of image objects containing path, keywords, and description.
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -FilePath <String>
        The file path where the HTML file will be saved.
        Required?                    false
        Position?                    2
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Add-ImageDescriptionsToFileNames
````PowerShell
Add-ImageDescriptionsToFileNames
````

### SYNOPSIS
    Adds image descriptions to file names in a specified directory.

### SYNTAX
````PowerShell
Add-ImageDescriptionsToFileNames [<CommonParameters>]
````

### DESCRIPTION
    This function iterates through all image files in a given directory and appends a 
    description to each file name. The description is extracted from the image metadata.

### PARAMETERS
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Start-AudioTranscription
````PowerShell
Start-AudioTranscription
````

### SYNOPSIS
    Transcribes audio to text using the default audio input device.

### SYNTAX
````PowerShell
Start-AudioTranscription [[-Language] <String>] [<CommonParameters>]
````

### DESCRIPTION
    Records audio using the default audio input device and returns the detected text

### PARAMETERS
    -Language <String>
        The language to expect in the audio.
        Required?                    false
        Position?                    1
        Default value                auto
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Start-AudioChat
````PowerShell
Start-AudioChat
````

### SYNOPSIS
    Starts a rudimentary audio chat session.

### SYNTAX
````PowerShell
Start-AudioChat [[-Language] <String>] [[-instructions] <String>] [[-model] <String>] 
[[-temperature] <Double>] [<CommonParameters>]
````

### DESCRIPTION
    Starts an audio chat session by recording audio and invoking the default LLM

### PARAMETERS
    -Language <String>
        The language to expect in the audio.
        Required?                    false
        Position?                    1
        Default value                auto
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -instructions <String>
        Required?                    false
        Position?                    2
        Default value                Your an AI assistent that never tells a lie and always 
        answers truthfully, first of all comprehensive and then if possible consice.
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -model <String>
        Required?                    false
        Position?                    3
        Default value                yi-coder-9b-chat
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -temperature <Double>
        Required?                    false
        Position?                    4
        Default value                0.7
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>

##	Get-MediaFileAudioTranscription
````PowerShell
Get-MediaFileAudioTranscription
````

### SYNOPSIS
    Transcribes an audio or video file to text..

### SYNTAX
````PowerShell
Get-MediaFileAudioTranscription [-FilePath] <String> [[-Language] <String>] 
[<CommonParameters>]
````

### DESCRIPTION
    Transcribes an audio or video file to text using the Whisper AI model

### PARAMETERS
    -FilePath <String>
        The file path of the audio or video file to transcribe.
        Required?                    true
        Position?                    1
        Default value                
        Accept pipeline input?       false
        Accept wildcard characters?  false
    -Language <String>
        The language to expect in the audio.
        Required?                    false
        Position?                    2
        Default value                auto
        Accept pipeline input?       false
        Accept wildcard characters?  false
    <CommonParameters>
        This cmdlet supports the common parameters: Verbose, Debug,
        ErrorAction, ErrorVariable, WarningAction, WarningVariable,
        OutBuffer, PipelineVariable, and OutVariable. For more information, see
        about_CommonParameters     (https://go.microsoft.com/fwlink/?LinkID=113216). 

<br/><hr/><hr/><br/>
