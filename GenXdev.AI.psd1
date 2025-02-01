#
# Module manifest for module 'GenXdev.AI'
@{

  # Script module or binary module file associated with this manifest.
  RootModule           = 'GenXdev.AI.psm1'

  # Version number of this module.
  ModuleVersion        = '1.98.2025'
  # Supported PSEditions
  # CompatiblePSEditions = @()

  # ID used to uniquely identify this module
  GUID                 = '2f62080f-0483-7721-8497-b3d433b65180'

  # Author of this module
  Author               = 'René Vaessen'

  # Company or vendor of this module
  CompanyName          = 'GenXdev'

  # Copyright statement for this module
  Copyright            = 'Copyright 2021-2025 GenXdev'

  # Description of the functionality provided by this module
  Description          = 'A Windows PowerShell module for local AI related operations'

  # Minimum version of the PowerShell engine required by this module
  PowerShellVersion    = '7.5.0'

  # # Intended for PowerShell Core
  CompatiblePSEditions = 'Core'

  # # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
  ClrVersion           = '9.0.1'

  # Processor architecture (None, X86, Amd64) required by this module
  # ProcessorArchitecture = ''

  # Modules that must be imported into the global environment prior to importing this module
  RequiredModules      = @(@{ModuleName = 'GenXdev.Data'; ModuleVersion = '1.98.2025' },@{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.98.2025' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.98.2025' }, @{ModuleName = 'GenXdev.Queries'; ModuleVersion = '1.98.2025' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.98.2025' }, @{ModuleName = 'GenXdev.Console'; ModuleVersion = '1.98.2025' }, @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.98.2025' });

  # Assemblies that must be loaded prior to importing this module
  RequiredAssemblies   = @()

  # Script files (.ps1) that are run in the caller's environment prior to importing this module.
  # ScriptsToProcess = @()

  # Type files (.ps1xml) to be loaded when importing this module
  # TypesToProcess = @()

  # Format files (.ps1xml) to be loaded when importing this module
  # FormatsToProcess = @()

  # Modules to import as nested modules of the module specified in RootModule/ModuleToProcess
  # NestedModules = @()

  # Functions to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no functions to export.
  FunctionsToExport    = '*' # @("*")

  # Cmdlets to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no Cmdlets to export.
  CmdletsToExport      = '*' # = @("*")

  # Variables to export from this module
  VariablesToExport    = '*'

  # Aliases to export from this module, for best performance, do not use wildcards and do not delete the entry, use an empty array if there are no aliases to export.
  AliasesToExport      = '*'

  # DSC resources to export from this module
  # DscResourcesToExport = @()

  # List of all modules packaged with this module
  ModuleList           = @("GenXdev.AI")

  # List of all files packaged with this module
  FileList             = @(


  ".\\Functions\\GenXdev.AI\\Add-EmoticonsToText.ps1",
  ".\\Functions\\GenXdev.AI\\AssureGithubCLIInstalled.ps1",
  ".\\Functions\\GenXdev.AI\\AssureWinMergeInstalled.ps1",
  ".\\Functions\\GenXdev.AI\\GenerateMasonryLayoutHtml.ps1",
  ".\\Functions\\GenXdev.AI\\Get-FactSheetOfSubject.ps1",
  ".\\Functions\\GenXdev.AI\\Get-HasCapableGpu.ps1",
  ".\\Functions\\GenXdev.AI\\Get-MediaFileAudioTranscription.ps1",
  ".\\Functions\\GenXdev.AI\\Get-NumberOfCpuCores.ps1",
  ".\\Functions\\GenXdev.AI\\Get-TextTranslation.ps1",
  ".\\Functions\\GenXdev.AI\\Invoke-AIPowershellCommand.ps1",
  ".\\Functions\\GenXdev.AI\\Invoke-ImageKeywordScan.ps1",
  ".\\Functions\\GenXdev.AI\\Invoke-ImageKeywordUpdate.ps1",
  ".\\Functions\\GenXdev.AI\\Invoke-LMStudioQuery.ps1",
  ".\\Functions\\GenXdev.AI\\Invoke-QueryImageContent.ps1",
  ".\\Functions\\GenXdev.AI\\Save-Transcriptions.ps1",
  ".\\Functions\\GenXdev.AI\\Start-AudioChat.ps1",
  ".\\Functions\\GenXdev.AI\\Start-AudioTranscription.ps1",
  ".\\Tests\\GenXdev.AI\\Add-EmoticonsToText.Tests.ps1",
  ".\\Tests\\GenXdev.AI\\escalated-quickly.wav",
  ".\\Tests\\GenXdev.AI\\Get-TextTranslation.Tests.ps1",
  ".\\Tests\\GenXdev.AI\\Start-AudioTranscription.Tests.ps1",
  ".\\Tests\\TestResults.xml",
  ".\\GenXdev.AI.psd1",
  ".\\GenXdev.AI.psm1",
  ".\\LICENSE",
  ".\\license.txt",
  ".\\powershell.jpg",
  ".\\README.md"


)

  # Private data to pass to the module specified in RootModule/ModuleToProcess. This may also contain a PSData hashtable with additional module metadata used by PowerShell.
  PrivateData          = @{

    PSData = @{

      # Tags applied to this module. These help with module discovery in online galleries.
      Tags                     = 'Git', 'Shell', 'GenXdev', "AI"

      # A URL to the license for this module.
      LicenseUri               = 'https://raw.githubusercontent.com/genXdev/GenXdev.AI/main/LICENSE'

      # A URL to the main website for this project.
      ProjectUri               = 'https://github.com/genXdev/GenXdev.AI'

      # A URL to an icon representing this module.
      IconUri                  = 'https://genxdev.net/favicon.ico'

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
  # HelpInfoUri          = 'https://github.com/genXdev/GenXdev.AI/blob/main/README.md#cmdlet-index'

  # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
  # DefaultCommandPrefix = ''
}