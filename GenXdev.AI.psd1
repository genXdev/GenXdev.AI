#
# Module manifest for module 'GenXdev.AI'
#
# Generated by: genXdev
#
# Generated on: 09/03/2025
#

@{

# Script module or binary module file associated with this manifest.
RootModule = 'GenXdev.AI.psm1'

# Version number of this module.
ModuleVersion = '1.118.2025'

# Supported PSEditions
CompatiblePSEditions = 'Core'

# ID used to uniquely identify this module
GUID = '2f62080f-0483-7721-8497-b3d433b65180'

# Author of this module
Author = 'genXdev'

# Company or vendor of this module
CompanyName = 'GenXdev'

# Copyright statement for this module
Copyright = 'Copyright 2021-2025 GenXdev'

# Description of the functionality provided by this module
Description = 'A Windows PowerShell module for local AI related operations'

# Minimum version of the PowerShell engine required by this module
PowerShellVersion = '7.5.0'

# Name of the PowerShell host required by this module
# PowerShellHostName = ''

# Minimum version of the PowerShell host required by this module
# PowerShellHostVersion = ''

# Minimum version of Microsoft .NET Framework required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
# DotNetFrameworkVersion = ''

# Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
ClrVersion = '9.0.1'

# Processor architecture (None, X86, Amd64) required by this module
ProcessorArchitecture = 'Amd64'

# Modules that must be imported into the global environment prior to importing this module
RequiredModules = @(@{ModuleName = 'Microsoft.PowerShell.Management'; ModuleVersion = '7.0.0.0'; }, 
               @{ModuleName = 'GenXdev.Data'; ModuleVersion = '1.118.2025'; }, 
               @{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.118.2025'; }, 
               @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.118.2025'; }, 
               @{ModuleName = 'GenXdev.Queries'; ModuleVersion = '1.118.2025'; }, 
               @{ModuleName = 'GenXdev.Console'; ModuleVersion = '1.118.2025'; }, 
               @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.118.2025'; })

# Assemblies that must be loaded prior to importing this module
# RequiredAssemblies = @()

# Script files (.ps1) that are run in the caller's environment prior to importing this module.
# ScriptsToProcess = @()

# Type files (.ps1xml) to be loaded when importing this module
# TypesToProcess = @()

# Format files (.ps1xml) to be loaded when importing this module
# FormatsToProcess = @()

# Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
NestedModules = @('GenXdev.AI.LMStudio.psm1')

# Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
FunctionsToExport = 'Add-EmoticonsToText', 'Approve-NewTextFileContent', 
               'AssureGithubCLIInstalled', 'AssureLMStudio', 
               'AssureWinMergeInstalled', 'Convert-DotNetTypeToLLMType', 
               'ConvertTo-LMStudioFunctionDefinition', 'GenerateMasonryLayoutHtml', 
               'Get-CpuCore', 'Get-HasCapableGpu', 'Get-LMStudioLoadedModelList', 
               'Get-LMStudioModelList', 'Get-LMStudioPaths', 'Get-LMStudioWindow', 
               'Get-MediaFileAudioTranscription', 'Get-NumberOfCpuCores', 
               'Get-TextTranslation', 'Initialize-LMStudioModel', 
               'Install-LMStudioApplication', 'Invoke-AIPowershellCommand', 
               'Invoke-CommandFromToolCall', 'Invoke-ImageKeywordScan', 
               'Invoke-ImageKeywordUpdate', 'Invoke-LLMQuery', 
               'Invoke-QueryImageContent', 'Invoke-WinMerge', 'New-LLMAudioChat', 
               'New-LLMTextChat', 'Save-Transcriptions', 'Set-AICommandSuggestion', 
               'Set-GenXdevAICommandNotFoundAction', 'Start-AudioTranscription', 
               'Start-LMStudioApplication', 'Test-LMStudioInstallation', 
               'Test-LMStudioProcess'

# Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no cmdlets to export.
CmdletsToExport = @()

# Variables to export from this module
VariablesToExport = @()

# Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
AliasesToExport = 'Analyze-Image', 'emojify', 'findimages', 'Get-Translation', 'hint', 
               'Invoke-LMStudioQuery', 'llm', 'llmaudiochat', 'llmchat', 'qllm', 'qlms', 
               'Query-Image', 'recordandtranscribe', 'transcribe', 'transcribefile', 
               'translate', 'updateimages'

# DSC resources to export from this module
# DscResourcesToExport = @()

# List of all modules packaged with this module
ModuleList = @('GenXdev.AI')

# List of all files packaged with this module
FileList = 'GenXdev.AI.LMStudio.psm1', 'GenXdev.AI.psd1', 'GenXdev.AI.psm1', 
               'LICENSE', 'license.txt', 'powershell.jpg', 'README.md', 'Tests.psm1', 
               'Tests\GenXdev.AI.LMStudio\AssureLMStudio.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Convert-DotNetTypeToLLMType.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\ConvertTo-LMStudioFunctionDefinition.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Get-LMStudioLoadedModelList.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Get-LMStudioModelList.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Get-LMStudioPaths.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Get-LMStudioWindow.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Initialize-LMStudioModel.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Install-LMStudioApplication.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Start-LMStudioApplication.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Test-LMStudioInstallation.Tests.ps1', 
               'Tests\GenXdev.AI.LMStudio\Test-LMStudioProcess.Tests.ps1', 
               'Tests\GenXdev.AI\Add-EmoticonsToText.Tests.ps1', 
               'Tests\GenXdev.AI\Approve-NewTextFileContent.Tests.ps1', 
               'Tests\GenXdev.AI\AssureGithubCLIInstalled.Tests.ps1', 
               'Tests\GenXdev.AI\AssureWinMergeInstalled.Tests.ps1', 
               'Tests\GenXdev.AI\GenerateMasonryLayoutHtml.Tests.ps1', 
               'Tests\GenXdev.AI\Get-CpuCore.Tests.ps1', 
               'Tests\GenXdev.AI\Get-HasCapableGpu.Tests.ps1', 
               'Tests\GenXdev.AI\Get-MediaFileAudioTranscription.Tests.ps1', 
               'Tests\GenXdev.AI\Get-NumberOfCpuCores.Tests.ps1', 
               'Tests\GenXdev.AI\Get-TextTranslation.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-AIPowershellCommand.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-CommandFromToolCall.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-ImageKeywordScan.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-ImageKeywordUpdate.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-LLMQuery.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-QueryImageContent.Tests.ps1', 
               'Tests\GenXdev.AI\Invoke-WinMerge.Tests.ps1', 
               'Tests\GenXdev.AI\New-LLMAudioChat.Tests.ps1', 
               'Tests\GenXdev.AI\New-LLMTextChat.Tests.ps1', 
               'Tests\GenXdev.AI\Save-Transcriptions.Tests.ps1', 
               'Tests\GenXdev.AI\Set-GenXdevAICommandNotFoundAction.Tests.ps1', 
               'Tests\GenXdev.AI\Start-AudioTranscription.Tests.ps1', 
               'Functions\GenXdev.AI.LMStudio\AssureLMStudio.ps1', 
               'Functions\GenXdev.AI.LMStudio\Convert-DotNetTypeToLLMType.ps1', 
               'Functions\GenXdev.AI.LMStudio\ConvertTo-LMStudioFunctionDefinition.ps1', 
               'Functions\GenXdev.AI.LMStudio\Get-LMStudioLoadedModelList.ps1', 
               'Functions\GenXdev.AI.LMStudio\Get-LMStudioModelList.ps1', 
               'Functions\GenXdev.AI.LMStudio\Get-LMStudioPaths.ps1', 
               'Functions\GenXdev.AI.LMStudio\Get-LMStudioWindow.ps1', 
               'Functions\GenXdev.AI.LMStudio\Initialize-LMStudioModel.ps1', 
               'Functions\GenXdev.AI.LMStudio\Install-LMStudioApplication.ps1', 
               'Functions\GenXdev.AI.LMStudio\Start-LMStudioApplication.ps1', 
               'Functions\GenXdev.AI.LMStudio\Test-LMStudioInstallation.ps1', 
               'Functions\GenXdev.AI.LMStudio\Test-LMStudioProcess.ps1', 
               'Functions\GenXdev.AI\Add-EmoticonsToText.ps1', 
               'Functions\GenXdev.AI\Approve-NewTextFileContent.ps1', 
               'Functions\GenXdev.AI\AssureGithubCLIInstalled.ps1', 
               'Functions\GenXdev.AI\AssureWinMergeInstalled.ps1', 
               'Functions\GenXdev.AI\GenerateMasonryLayoutHtml.ps1', 
               'Functions\GenXdev.AI\Get-CpuCore.ps1', 
               'Functions\GenXdev.AI\Get-HasCapableGpu.ps1', 
               'Functions\GenXdev.AI\Get-MediaFileAudioTranscription.ps1', 
               'Functions\GenXdev.AI\Get-NumberOfCpuCores.ps1', 
               'Functions\GenXdev.AI\Get-TextTranslation.ps1', 
               'Functions\GenXdev.AI\Invoke-AIPowershellCommand.ps1', 
               'Functions\GenXdev.AI\Invoke-CommandFromToolCall.ps1', 
               'Functions\GenXdev.AI\Invoke-ImageKeywordScan.ps1', 
               'Functions\GenXdev.AI\Invoke-ImageKeywordUpdate.ps1', 
               'Functions\GenXdev.AI\Invoke-LLMQuery.ps1', 
               'Functions\GenXdev.AI\Invoke-QueryImageContent.ps1', 
               'Functions\GenXdev.AI\Invoke-WinMerge.ps1', 
               'Functions\GenXdev.AI\New-LLMAudioChat.ps1', 
               'Functions\GenXdev.AI\New-LLMTextChat.ps1', 
               'Functions\GenXdev.AI\Save-Transcriptions.ps1', 
               'Functions\GenXdev.AI\Set-GenXdevAICommandNotFoundAction.ps1', 
               'Functions\GenXdev.AI\Start-AudioTranscription.ps1'

# Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
PrivateData = @{

    PSData = @{

        # Tags applied to this module. These help with module discovery in online galleries.
        Tags = 'Git','Shell','GenXdev','AI'

        # A URL to the license for this module.
        LicenseUri = 'https://raw.githubusercontent.com/genXdev/GenXdev.AI/main/LICENSE'

        # A URL to the main website for this project.
        ProjectUri = 'https://powershell.genxdev.net/#GenXdev.AI'

        # A URL to an icon representing this module.
        IconUri = 'https://genxdev.net/favicon.ico'

        # ReleaseNotes of this module
        # ReleaseNotes = ''

        # Prerelease string of this module
        # Prerelease = ''

        # Flag to indicate whether the module requires explicit user acceptance for install/update/save
        RequireLicenseAcceptance = $true

        # External dependent modules of this module
        # ExternalModuleDependencies = @()

    } # End of PSData hashtable

 } # End of PrivateData hashtable

# HelpInfo URI of this module
# HelpInfoURI = ''

# Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
# DefaultCommandPrefix = ''

}

