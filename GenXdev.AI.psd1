#
# Module manifest for module 'GenXdev.AI'
@{

    # Script module or binary module file associated with this manifest.
    RootModule           = 'GenXdev.AI.psm1'

    # Version number of this module.
    ModuleVersion        = '1.56.2024'
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
    PowerShellVersion    = '7.4.6'

    # # Intended for PowerShell Core
    CompatiblePSEditions = 'Core'

    # # Minimum version of the common language runtime (CLR) required by this module. This prerequisite is valid for the PowerShell Desktop edition only.
    ClrVersion           = '8.0.10'

    # Processor architecture (None, X86, Amd64) required by this module
    # ProcessorArchitecture = ''

    # Modules that must be imported into the global environment prior to importing this module
    RequiredModules      = @(@{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.56.2024' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.56.2024' }, @{ModuleName = 'GenXdev.Queries'; ModuleVersion = '1.56.2024' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.56.2024' }, @{ModuleName = 'GenXdev.Console'; ModuleVersion = '1.56.2024' }, @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.56.2024' });

    # Assemblies that must be loaded prior to importing this module
    RequiredAssemblies   = @(
      ".\\dependencies\\System.Management.Automation.dll",
      ".\\dependencies\\GenXdev.AI.dll"
    )

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


  ".\\.gitignore",
  ".\\ExampleCmdlet.cs",
  ".\\GenXdev.AI.csproj",
  ".\\GenXdev.AI.pdb",
  ".\\GenXdev.AI.psd1",
  ".\\GenXdev.AI.psm1",
  ".\\LICENSE",
  ".\\license.txt",
  ".\\NuGet.config",
  ".\\powershell.jpg",
  ".\\README.md",
  ".\\dependencies\\Accessibility.dll",
  ".\\dependencies\\clretwrc.dll",
  ".\\dependencies\\clrgc.dll",
  ".\\dependencies\\clrjit.dll",
  ".\\dependencies\\coreclr.dll",
  ".\\dependencies\\createdump.exe",
  ".\\dependencies\\D3DCompiler_47_cor3.dll",
  ".\\dependencies\\DirectWriteForwarder.dll",
  ".\\dependencies\\GenXdev.AI.deps.json",
  ".\\dependencies\\GenXdev.AI.dll",
  ".\\dependencies\\GenXdev.AI.pdb",
  ".\\dependencies\\getfilesiginforedist.dll",
  ".\\dependencies\\getfilesiginforedistwrapper.dll",
  ".\\dependencies\\hostfxr.dll",
  ".\\dependencies\\hostpolicy.dll",
  ".\\dependencies\\Microsoft.ApplicationInsights.dll",
  ".\\dependencies\\Microsoft.CSharp.dll",
  ".\\dependencies\\Microsoft.DiaSymReader.Native.amd64.dll",
  ".\\dependencies\\microsoft.management.infrastructure.dll",
  ".\\dependencies\\microsoft.management.infrastructure.native.dll",
  ".\\dependencies\\microsoft.management.infrastructure.native.unmanaged.dll",
  ".\\dependencies\\Microsoft.PowerShell.CoreCLR.Eventing.dll",
  ".\\dependencies\\Microsoft.VisualBasic.Core.dll",
  ".\\dependencies\\Microsoft.VisualBasic.dll",
  ".\\dependencies\\Microsoft.VisualBasic.Forms.dll",
  ".\\dependencies\\Microsoft.Win32.Primitives.dll",
  ".\\dependencies\\Microsoft.Win32.Registry.AccessControl.dll",
  ".\\dependencies\\Microsoft.Win32.Registry.dll",
  ".\\dependencies\\Microsoft.Win32.SystemEvents.dll",
  ".\\dependencies\\mscordaccore_amd64_amd64_8.0.1124.51707.dll",
  ".\\dependencies\\mscordaccore.dll",
  ".\\dependencies\\mscordbi.dll",
  ".\\dependencies\\mscorlib.dll",
  ".\\dependencies\\mscorrc.dll",
  ".\\dependencies\\msquic.dll",
  ".\\dependencies\\netstandard.dll",
  ".\\dependencies\\Newtonsoft.Json.dll",
  ".\\dependencies\\PenImc_cor3.dll",
  ".\\dependencies\\PowerShell.Core.Instrumentation.dll",
  ".\\dependencies\\PresentationCore.dll",
  ".\\dependencies\\PresentationFramework-SystemCore.dll",
  ".\\dependencies\\PresentationFramework-SystemData.dll",
  ".\\dependencies\\PresentationFramework-SystemDrawing.dll",
  ".\\dependencies\\PresentationFramework-SystemXml.dll",
  ".\\dependencies\\PresentationFramework-SystemXmlLinq.dll",
  ".\\dependencies\\PresentationFramework.Aero.dll",
  ".\\dependencies\\PresentationFramework.Aero2.dll",
  ".\\dependencies\\PresentationFramework.AeroLite.dll",
  ".\\dependencies\\PresentationFramework.Classic.dll",
  ".\\dependencies\\PresentationFramework.dll",
  ".\\dependencies\\PresentationFramework.Luna.dll",
  ".\\dependencies\\PresentationFramework.Royale.dll",
  ".\\dependencies\\PresentationNative_cor3.dll",
  ".\\dependencies\\PresentationUI.dll",
  ".\\dependencies\\pwrshplugin.dll",
  ".\\dependencies\\ReachFramework.dll",
  ".\\dependencies\\System.AppContext.dll",
  ".\\dependencies\\System.Buffers.dll",
  ".\\dependencies\\System.CodeDom.dll",
  ".\\dependencies\\System.Collections.Concurrent.dll",
  ".\\dependencies\\System.Collections.dll",
  ".\\dependencies\\System.Collections.Immutable.dll",
  ".\\dependencies\\System.Collections.NonGeneric.dll",
  ".\\dependencies\\System.Collections.Specialized.dll",
  ".\\dependencies\\System.ComponentModel.Annotations.dll",
  ".\\dependencies\\System.ComponentModel.DataAnnotations.dll",
  ".\\dependencies\\System.ComponentModel.dll",
  ".\\dependencies\\System.ComponentModel.EventBasedAsync.dll",
  ".\\dependencies\\System.ComponentModel.Primitives.dll",
  ".\\dependencies\\System.ComponentModel.TypeConverter.dll",
  ".\\dependencies\\System.Configuration.ConfigurationManager.dll",
  ".\\dependencies\\System.Configuration.dll",
  ".\\dependencies\\System.Console.dll",
  ".\\dependencies\\System.Core.dll",
  ".\\dependencies\\System.Data.Common.dll",
  ".\\dependencies\\System.Data.DataSetExtensions.dll",
  ".\\dependencies\\System.Data.dll",
  ".\\dependencies\\System.Design.dll",
  ".\\dependencies\\System.Diagnostics.Contracts.dll",
  ".\\dependencies\\System.Diagnostics.Debug.dll",
  ".\\dependencies\\System.Diagnostics.DiagnosticSource.dll",
  ".\\dependencies\\System.Diagnostics.EventLog.dll",
  ".\\dependencies\\System.Diagnostics.EventLog.Messages.dll",
  ".\\dependencies\\System.Diagnostics.FileVersionInfo.dll",
  ".\\dependencies\\System.Diagnostics.PerformanceCounter.dll",
  ".\\dependencies\\System.Diagnostics.Process.dll",
  ".\\dependencies\\System.Diagnostics.StackTrace.dll",
  ".\\dependencies\\System.Diagnostics.TextWriterTraceListener.dll",
  ".\\dependencies\\System.Diagnostics.Tools.dll",
  ".\\dependencies\\System.Diagnostics.TraceSource.dll",
  ".\\dependencies\\System.Diagnostics.Tracing.dll",
  ".\\dependencies\\System.DirectoryServices.dll",
  ".\\dependencies\\System.dll",
  ".\\dependencies\\System.Drawing.Common.dll",
  ".\\dependencies\\System.Drawing.Design.dll",
  ".\\dependencies\\System.Drawing.dll",
  ".\\dependencies\\System.Drawing.Primitives.dll",
  ".\\dependencies\\System.Dynamic.Runtime.dll",
  ".\\dependencies\\System.Formats.Asn1.dll",
  ".\\dependencies\\System.Formats.Tar.dll",
  ".\\dependencies\\System.Globalization.Calendars.dll",
  ".\\dependencies\\System.Globalization.dll",
  ".\\dependencies\\System.Globalization.Extensions.dll",
  ".\\dependencies\\System.IO.Compression.Brotli.dll",
  ".\\dependencies\\System.IO.Compression.dll",
  ".\\dependencies\\System.IO.Compression.FileSystem.dll",
  ".\\dependencies\\System.IO.Compression.Native.dll",
  ".\\dependencies\\System.IO.Compression.ZipFile.dll",
  ".\\dependencies\\System.IO.dll",
  ".\\dependencies\\System.IO.FileSystem.AccessControl.dll",
  ".\\dependencies\\System.IO.FileSystem.dll",
  ".\\dependencies\\System.IO.FileSystem.DriveInfo.dll",
  ".\\dependencies\\System.IO.FileSystem.Primitives.dll",
  ".\\dependencies\\System.IO.FileSystem.Watcher.dll",
  ".\\dependencies\\System.IO.IsolatedStorage.dll",
  ".\\dependencies\\System.IO.MemoryMappedFiles.dll",
  ".\\dependencies\\System.IO.Packaging.dll",
  ".\\dependencies\\System.IO.Pipes.AccessControl.dll",
  ".\\dependencies\\System.IO.Pipes.dll",
  ".\\dependencies\\System.IO.UnmanagedMemoryStream.dll",
  ".\\dependencies\\System.Linq.dll",
  ".\\dependencies\\System.Linq.Expressions.dll",
  ".\\dependencies\\System.Linq.Parallel.dll",
  ".\\dependencies\\System.Linq.Queryable.dll",
  ".\\dependencies\\System.Management.Automation.dll",
  ".\\dependencies\\System.Management.dll",
  ".\\dependencies\\System.Memory.dll",
  ".\\dependencies\\System.Net.dll",
  ".\\dependencies\\System.Net.Http.dll",
  ".\\dependencies\\System.Net.Http.Json.dll",
  ".\\dependencies\\System.Net.HttpListener.dll",
  ".\\dependencies\\System.Net.Mail.dll",
  ".\\dependencies\\System.Net.NameResolution.dll",
  ".\\dependencies\\System.Net.NetworkInformation.dll",
  ".\\dependencies\\System.Net.Ping.dll",
  ".\\dependencies\\System.Net.Primitives.dll",
  ".\\dependencies\\System.Net.Quic.dll",
  ".\\dependencies\\System.Net.Requests.dll",
  ".\\dependencies\\System.Net.Security.dll",
  ".\\dependencies\\System.Net.ServicePoint.dll",
  ".\\dependencies\\System.Net.Sockets.dll",
  ".\\dependencies\\System.Net.WebClient.dll",
  ".\\dependencies\\System.Net.WebHeaderCollection.dll",
  ".\\dependencies\\System.Net.WebProxy.dll",
  ".\\dependencies\\System.Net.WebSockets.Client.dll",
  ".\\dependencies\\System.Net.WebSockets.dll",
  ".\\dependencies\\System.Numerics.dll",
  ".\\dependencies\\System.Numerics.Vectors.dll",
  ".\\dependencies\\System.ObjectModel.dll",
  ".\\dependencies\\System.Printing.dll",
  ".\\dependencies\\System.Private.CoreLib.dll",
  ".\\dependencies\\System.Private.DataContractSerialization.dll",
  ".\\dependencies\\System.Private.Uri.dll",
  ".\\dependencies\\System.Private.Xml.dll",
  ".\\dependencies\\System.Private.Xml.Linq.dll",
  ".\\dependencies\\System.Reflection.DispatchProxy.dll",
  ".\\dependencies\\System.Reflection.dll",
  ".\\dependencies\\System.Reflection.Emit.dll",
  ".\\dependencies\\System.Reflection.Emit.ILGeneration.dll",
  ".\\dependencies\\System.Reflection.Emit.Lightweight.dll",
  ".\\dependencies\\System.Reflection.Extensions.dll",
  ".\\dependencies\\System.Reflection.Metadata.dll",
  ".\\dependencies\\System.Reflection.Primitives.dll",
  ".\\dependencies\\System.Reflection.TypeExtensions.dll",
  ".\\dependencies\\System.Resources.Extensions.dll",
  ".\\dependencies\\System.Resources.Reader.dll",
  ".\\dependencies\\System.Resources.ResourceManager.dll",
  ".\\dependencies\\System.Resources.Writer.dll",
  ".\\dependencies\\System.Runtime.CompilerServices.Unsafe.dll",
  ".\\dependencies\\System.Runtime.CompilerServices.VisualC.dll",
  ".\\dependencies\\System.Runtime.dll",
  ".\\dependencies\\System.Runtime.Extensions.dll",
  ".\\dependencies\\System.Runtime.Handles.dll",
  ".\\dependencies\\System.Runtime.InteropServices.dll",
  ".\\dependencies\\System.Runtime.InteropServices.JavaScript.dll",
  ".\\dependencies\\System.Runtime.InteropServices.RuntimeInformation.dll",
  ".\\dependencies\\System.Runtime.Intrinsics.dll",
  ".\\dependencies\\System.Runtime.Loader.dll",
  ".\\dependencies\\System.Runtime.Numerics.dll",
  ".\\dependencies\\System.Runtime.Serialization.dll",
  ".\\dependencies\\System.Runtime.Serialization.Formatters.dll",
  ".\\dependencies\\System.Runtime.Serialization.Json.dll",
  ".\\dependencies\\System.Runtime.Serialization.Primitives.dll",
  ".\\dependencies\\System.Runtime.Serialization.Xml.dll",
  ".\\dependencies\\System.Security.AccessControl.dll",
  ".\\dependencies\\System.Security.Claims.dll",
  ".\\dependencies\\System.Security.Cryptography.Algorithms.dll",
  ".\\dependencies\\System.Security.Cryptography.Cng.dll",
  ".\\dependencies\\System.Security.Cryptography.Csp.dll",
  ".\\dependencies\\System.Security.Cryptography.dll",
  ".\\dependencies\\System.Security.Cryptography.Encoding.dll",
  ".\\dependencies\\System.Security.Cryptography.OpenSsl.dll",
  ".\\dependencies\\System.Security.Cryptography.Pkcs.dll",
  ".\\dependencies\\System.Security.Cryptography.Primitives.dll",
  ".\\dependencies\\System.Security.Cryptography.ProtectedData.dll",
  ".\\dependencies\\System.Security.Cryptography.X509Certificates.dll",
  ".\\dependencies\\System.Security.Cryptography.Xml.dll",
  ".\\dependencies\\System.Security.dll",
  ".\\dependencies\\System.Security.Permissions.dll",
  ".\\dependencies\\System.Security.Principal.dll",
  ".\\dependencies\\System.Security.Principal.Windows.dll",
  ".\\dependencies\\System.Security.SecureString.dll",
  ".\\dependencies\\System.ServiceModel.Web.dll",
  ".\\dependencies\\System.ServiceProcess.dll",
  ".\\dependencies\\System.Text.Encoding.CodePages.dll",
  ".\\dependencies\\System.Text.Encoding.dll",
  ".\\dependencies\\System.Text.Encoding.Extensions.dll",
  ".\\dependencies\\System.Text.Encodings.Web.dll",
  ".\\dependencies\\System.Text.Json.dll",
  ".\\dependencies\\System.Text.RegularExpressions.dll",
  ".\\dependencies\\System.Threading.AccessControl.dll",
  ".\\dependencies\\System.Threading.Channels.dll",
  ".\\dependencies\\System.Threading.dll",
  ".\\dependencies\\System.Threading.Overlapped.dll",
  ".\\dependencies\\System.Threading.Tasks.Dataflow.dll",
  ".\\dependencies\\System.Threading.Tasks.dll",
  ".\\dependencies\\System.Threading.Tasks.Extensions.dll",
  ".\\dependencies\\System.Threading.Tasks.Parallel.dll",
  ".\\dependencies\\System.Threading.Thread.dll",
  ".\\dependencies\\System.Threading.ThreadPool.dll",
  ".\\dependencies\\System.Threading.Timer.dll",
  ".\\dependencies\\System.Transactions.dll",
  ".\\dependencies\\System.Transactions.Local.dll",
  ".\\dependencies\\System.ValueTuple.dll",
  ".\\dependencies\\System.Web.dll",
  ".\\dependencies\\System.Web.HttpUtility.dll",
  ".\\dependencies\\System.Windows.Controls.Ribbon.dll",
  ".\\dependencies\\System.Windows.dll",
  ".\\dependencies\\System.Windows.Extensions.dll",
  ".\\dependencies\\System.Windows.Forms.Design.dll",
  ".\\dependencies\\System.Windows.Forms.Design.Editors.dll",
  ".\\dependencies\\System.Windows.Forms.dll",
  ".\\dependencies\\System.Windows.Forms.Primitives.dll",
  ".\\dependencies\\System.Windows.Input.Manipulations.dll",
  ".\\dependencies\\System.Windows.Presentation.dll",
  ".\\dependencies\\System.Xaml.dll",
  ".\\dependencies\\System.Xml.dll",
  ".\\dependencies\\System.Xml.Linq.dll",
  ".\\dependencies\\System.Xml.ReaderWriter.dll",
  ".\\dependencies\\System.Xml.Serialization.dll",
  ".\\dependencies\\System.Xml.XDocument.dll",
  ".\\dependencies\\System.Xml.XmlDocument.dll",
  ".\\dependencies\\System.Xml.XmlSerializer.dll",
  ".\\dependencies\\System.Xml.XPath.dll",
  ".\\dependencies\\System.Xml.XPath.XDocument.dll",
  ".\\dependencies\\UIAutomationClient.dll",
  ".\\dependencies\\UIAutomationClientSideProviders.dll",
  ".\\dependencies\\UIAutomationProvider.dll",
  ".\\dependencies\\UIAutomationTypes.dll",
  ".\\dependencies\\vcruntime140_cor3.dll",
  ".\\dependencies\\WindowsBase.dll",
  ".\\dependencies\\WindowsFormsIntegration.dll",
  ".\\dependencies\\wpfgfx_cor3.dll",
  ".\\dependencies\\cs\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\cs\\PresentationCore.resources.dll",
  ".\\dependencies\\cs\\PresentationFramework.resources.dll",
  ".\\dependencies\\cs\\PresentationUI.resources.dll",
  ".\\dependencies\\cs\\ReachFramework.resources.dll",
  ".\\dependencies\\cs\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\cs\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\cs\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\cs\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\cs\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\cs\\System.Xaml.resources.dll",
  ".\\dependencies\\cs\\UIAutomationClient.resources.dll",
  ".\\dependencies\\cs\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\cs\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\cs\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\cs\\WindowsBase.resources.dll",
  ".\\dependencies\\cs\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\de\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\de\\PresentationCore.resources.dll",
  ".\\dependencies\\de\\PresentationFramework.resources.dll",
  ".\\dependencies\\de\\PresentationUI.resources.dll",
  ".\\dependencies\\de\\ReachFramework.resources.dll",
  ".\\dependencies\\de\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\de\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\de\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\de\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\de\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\de\\System.Xaml.resources.dll",
  ".\\dependencies\\de\\UIAutomationClient.resources.dll",
  ".\\dependencies\\de\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\de\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\de\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\de\\WindowsBase.resources.dll",
  ".\\dependencies\\de\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\es\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\es\\PresentationCore.resources.dll",
  ".\\dependencies\\es\\PresentationFramework.resources.dll",
  ".\\dependencies\\es\\PresentationUI.resources.dll",
  ".\\dependencies\\es\\ReachFramework.resources.dll",
  ".\\dependencies\\es\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\es\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\es\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\es\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\es\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\es\\System.Xaml.resources.dll",
  ".\\dependencies\\es\\UIAutomationClient.resources.dll",
  ".\\dependencies\\es\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\es\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\es\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\es\\WindowsBase.resources.dll",
  ".\\dependencies\\es\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\fr\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\fr\\PresentationCore.resources.dll",
  ".\\dependencies\\fr\\PresentationFramework.resources.dll",
  ".\\dependencies\\fr\\PresentationUI.resources.dll",
  ".\\dependencies\\fr\\ReachFramework.resources.dll",
  ".\\dependencies\\fr\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\fr\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\fr\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\fr\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\fr\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\fr\\System.Xaml.resources.dll",
  ".\\dependencies\\fr\\UIAutomationClient.resources.dll",
  ".\\dependencies\\fr\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\fr\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\fr\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\fr\\WindowsBase.resources.dll",
  ".\\dependencies\\fr\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\it\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\it\\PresentationCore.resources.dll",
  ".\\dependencies\\it\\PresentationFramework.resources.dll",
  ".\\dependencies\\it\\PresentationUI.resources.dll",
  ".\\dependencies\\it\\ReachFramework.resources.dll",
  ".\\dependencies\\it\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\it\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\it\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\it\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\it\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\it\\System.Xaml.resources.dll",
  ".\\dependencies\\it\\UIAutomationClient.resources.dll",
  ".\\dependencies\\it\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\it\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\it\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\it\\WindowsBase.resources.dll",
  ".\\dependencies\\it\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\ja\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\ja\\PresentationCore.resources.dll",
  ".\\dependencies\\ja\\PresentationFramework.resources.dll",
  ".\\dependencies\\ja\\PresentationUI.resources.dll",
  ".\\dependencies\\ja\\ReachFramework.resources.dll",
  ".\\dependencies\\ja\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\ja\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\ja\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\ja\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\ja\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\ja\\System.Xaml.resources.dll",
  ".\\dependencies\\ja\\UIAutomationClient.resources.dll",
  ".\\dependencies\\ja\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\ja\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\ja\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\ja\\WindowsBase.resources.dll",
  ".\\dependencies\\ja\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\ko\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\ko\\PresentationCore.resources.dll",
  ".\\dependencies\\ko\\PresentationFramework.resources.dll",
  ".\\dependencies\\ko\\PresentationUI.resources.dll",
  ".\\dependencies\\ko\\ReachFramework.resources.dll",
  ".\\dependencies\\ko\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\ko\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\ko\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\ko\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\ko\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\ko\\System.Xaml.resources.dll",
  ".\\dependencies\\ko\\UIAutomationClient.resources.dll",
  ".\\dependencies\\ko\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\ko\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\ko\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\ko\\WindowsBase.resources.dll",
  ".\\dependencies\\ko\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\pl\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\pl\\PresentationCore.resources.dll",
  ".\\dependencies\\pl\\PresentationFramework.resources.dll",
  ".\\dependencies\\pl\\PresentationUI.resources.dll",
  ".\\dependencies\\pl\\ReachFramework.resources.dll",
  ".\\dependencies\\pl\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\pl\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\pl\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\pl\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\pl\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\pl\\System.Xaml.resources.dll",
  ".\\dependencies\\pl\\UIAutomationClient.resources.dll",
  ".\\dependencies\\pl\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\pl\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\pl\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\pl\\WindowsBase.resources.dll",
  ".\\dependencies\\pl\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\pt-BR\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\pt-BR\\PresentationCore.resources.dll",
  ".\\dependencies\\pt-BR\\PresentationFramework.resources.dll",
  ".\\dependencies\\pt-BR\\PresentationUI.resources.dll",
  ".\\dependencies\\pt-BR\\ReachFramework.resources.dll",
  ".\\dependencies\\pt-BR\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\pt-BR\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\pt-BR\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\pt-BR\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\pt-BR\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\pt-BR\\System.Xaml.resources.dll",
  ".\\dependencies\\pt-BR\\UIAutomationClient.resources.dll",
  ".\\dependencies\\pt-BR\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\pt-BR\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\pt-BR\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\pt-BR\\WindowsBase.resources.dll",
  ".\\dependencies\\pt-BR\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\ru\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\ru\\PresentationCore.resources.dll",
  ".\\dependencies\\ru\\PresentationFramework.resources.dll",
  ".\\dependencies\\ru\\PresentationUI.resources.dll",
  ".\\dependencies\\ru\\ReachFramework.resources.dll",
  ".\\dependencies\\ru\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\ru\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\ru\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\ru\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\ru\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\ru\\System.Xaml.resources.dll",
  ".\\dependencies\\ru\\UIAutomationClient.resources.dll",
  ".\\dependencies\\ru\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\ru\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\ru\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\ru\\WindowsBase.resources.dll",
  ".\\dependencies\\ru\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\tr\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\tr\\PresentationCore.resources.dll",
  ".\\dependencies\\tr\\PresentationFramework.resources.dll",
  ".\\dependencies\\tr\\PresentationUI.resources.dll",
  ".\\dependencies\\tr\\ReachFramework.resources.dll",
  ".\\dependencies\\tr\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\tr\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\tr\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\tr\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\tr\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\tr\\System.Xaml.resources.dll",
  ".\\dependencies\\tr\\UIAutomationClient.resources.dll",
  ".\\dependencies\\tr\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\tr\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\tr\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\tr\\WindowsBase.resources.dll",
  ".\\dependencies\\tr\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\zh-Hans\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\zh-Hans\\PresentationCore.resources.dll",
  ".\\dependencies\\zh-Hans\\PresentationFramework.resources.dll",
  ".\\dependencies\\zh-Hans\\PresentationUI.resources.dll",
  ".\\dependencies\\zh-Hans\\ReachFramework.resources.dll",
  ".\\dependencies\\zh-Hans\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\zh-Hans\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\zh-Hans\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\zh-Hans\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\zh-Hans\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\zh-Hans\\System.Xaml.resources.dll",
  ".\\dependencies\\zh-Hans\\UIAutomationClient.resources.dll",
  ".\\dependencies\\zh-Hans\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\zh-Hans\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\zh-Hans\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\zh-Hans\\WindowsBase.resources.dll",
  ".\\dependencies\\zh-Hans\\WindowsFormsIntegration.resources.dll",
  ".\\dependencies\\zh-Hant\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\dependencies\\zh-Hant\\PresentationCore.resources.dll",
  ".\\dependencies\\zh-Hant\\PresentationFramework.resources.dll",
  ".\\dependencies\\zh-Hant\\PresentationUI.resources.dll",
  ".\\dependencies\\zh-Hant\\ReachFramework.resources.dll",
  ".\\dependencies\\zh-Hant\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\dependencies\\zh-Hant\\System.Windows.Forms.Design.resources.dll",
  ".\\dependencies\\zh-Hant\\System.Windows.Forms.Primitives.resources.dll",
  ".\\dependencies\\zh-Hant\\System.Windows.Forms.resources.dll",
  ".\\dependencies\\zh-Hant\\System.Windows.Input.Manipulations.resources.dll",
  ".\\dependencies\\zh-Hant\\System.Xaml.resources.dll",
  ".\\dependencies\\zh-Hant\\UIAutomationClient.resources.dll",
  ".\\dependencies\\zh-Hant\\UIAutomationClientSideProviders.resources.dll",
  ".\\dependencies\\zh-Hant\\UIAutomationProvider.resources.dll",
  ".\\dependencies\\zh-Hant\\UIAutomationTypes.resources.dll",
  ".\\dependencies\\zh-Hant\\WindowsBase.resources.dll",
  ".\\dependencies\\zh-Hant\\WindowsFormsIntegration.resources.dll"


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