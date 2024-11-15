#
# Module manifest for module 'GenXdev.AI'
@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'GenXdev.AI.psm1'

    # Version number of this module.
    ModuleVersion        = '1.50.2024'
    # Supported PSEditions
    # CompatiblePSEditions = @()

    # ID used to uniquely identify this module
    GUID                 = '2f62080f-0483-7721-8497-b3d433b65180'

    # Author of this module
    Author               = 'GenXdev'

    # Company or vendor of this module
    CompanyName          = 'GenXdev'

    # Copyright statement for this module
    Copyright            = 'Copyright (c) 2024 GenXdev'

    # Description of the functionality provided by this module
    Description          = 'A Windows PowerShell module for local and online AI related operations'

    # Minimum version of the PowerShell engine required by this module
    PowerShellVersion    = '7.4.2'

    # # Intended for PowerShell Core
    CompatiblePSEditions = 'Core'

    # # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    ClrVersion           = '8.0.4'

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(@{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.50.2024' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.50.2024' }, @{ModuleName = 'GenXdev.Queries'; ModuleVersion = '1.50.2024' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.50.2024' }, @{ModuleName = 'GenXdev.Console'; ModuleVersion = '1.50.2024' }, @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.50.2024' });

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies   = @("System.Speech", "GenXdev.AI.dll", "System.Management.Automation.dll")

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
        "GenXdev.AI.deps.json",
        "GenXdev.AI.dll",
        "GenXdev.AI.pdb",
        "GenXdev.AI.psd1",
        "GenXdev.AI.psm1",
        "LICENSE",
        "license.txt",
        "powershell.jpg",
        "README.md",
        "System.Management.Automation.dll"
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
    HelpInfoURI          = 'https://github.com/genXdev/GenXdev.AI/blob/main/README.md#cmdlet-index'

    # Default prefix for commands exported from this module. Override the default prefix using Import-Module -Prefix.
    # DefaultCommandPrefix = ''
}