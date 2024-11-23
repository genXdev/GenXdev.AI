#
# Module manifest for module 'GenXdev.AI'
@{

  # Script module or binary module file associated with this manifest.
  RootModule           = 'GenXdev.AI.psm1'

  # Version number of this module.
  ModuleVersion        = '1.74.2024'
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
  RequiredModules      = @(@{ModuleName = 'GenXdev.Helpers'; ModuleVersion = '1.74.2024' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.74.2024' }, @{ModuleName = 'GenXdev.Queries'; ModuleVersion = '1.74.2024' }, @{ModuleName = 'GenXdev.Webbrowser'; ModuleVersion = '1.74.2024' }, @{ModuleName = 'GenXdev.Console'; ModuleVersion = '1.74.2024' }, @{ModuleName = 'GenXdev.FileSystem'; ModuleVersion = '1.74.2024' });

  # Assemblies that must be loaded prior to importing this module
  RequiredAssemblies   = @(
    ".\\lib\\System.Management.Automation.dll",
    ".\\lib\\GenXdev.AI.dll"
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
  ".\\lib\\Accessibility.dll",
  ".\\lib\\clretwrc.dll",
  ".\\lib\\clrgc.dll",
  ".\\lib\\clrjit.dll",
  ".\\lib\\coreclr.dll",
  ".\\lib\\createdump.exe",
  ".\\lib\\D3DCompiler_47_cor3.dll",
  ".\\lib\\DirectWriteForwarder.dll",
  ".\\lib\\GenXdev.AI.deps.json",
  ".\\lib\\GenXdev.AI.dll",
  ".\\lib\\GenXdev.AI.pdb",
  ".\\lib\\getfilesiginforedist.dll",
  ".\\lib\\getfilesiginforedistwrapper.dll",
  ".\\lib\\hostfxr.dll",
  ".\\lib\\hostpolicy.dll",
  ".\\lib\\Microsoft.ApplicationInsights.dll",
  ".\\lib\\Microsoft.CSharp.dll",
  ".\\lib\\Microsoft.DiaSymReader.Native.amd64.dll",
  ".\\lib\\microsoft.management.infrastructure.dll",
  ".\\lib\\microsoft.management.infrastructure.native.dll",
  ".\\lib\\microsoft.management.infrastructure.native.unmanaged.dll",
  ".\\lib\\Microsoft.PowerShell.CoreCLR.Eventing.dll",
  ".\\lib\\Microsoft.VisualBasic.Core.dll",
  ".\\lib\\Microsoft.VisualBasic.dll",
  ".\\lib\\Microsoft.VisualBasic.Forms.dll",
  ".\\lib\\Microsoft.Win32.Primitives.dll",
  ".\\lib\\Microsoft.Win32.Registry.AccessControl.dll",
  ".\\lib\\Microsoft.Win32.Registry.dll",
  ".\\lib\\Microsoft.Win32.SystemEvents.dll",
  ".\\lib\\mscordaccore_amd64_amd64_8.0.1124.51707.dll",
  ".\\lib\\mscordaccore.dll",
  ".\\lib\\mscordbi.dll",
  ".\\lib\\mscorlib.dll",
  ".\\lib\\mscorrc.dll",
  ".\\lib\\msquic.dll",
  ".\\lib\\netstandard.dll",
  ".\\lib\\Newtonsoft.Json.dll",
  ".\\lib\\PenImc_cor3.dll",
  ".\\lib\\PowerShell.Core.Instrumentation.dll",
  ".\\lib\\PresentationCore.dll",
  ".\\lib\\PresentationFramework-SystemCore.dll",
  ".\\lib\\PresentationFramework-SystemData.dll",
  ".\\lib\\PresentationFramework-SystemDrawing.dll",
  ".\\lib\\PresentationFramework-SystemXml.dll",
  ".\\lib\\PresentationFramework-SystemXmlLinq.dll",
  ".\\lib\\PresentationFramework.Aero.dll",
  ".\\lib\\PresentationFramework.Aero2.dll",
  ".\\lib\\PresentationFramework.AeroLite.dll",
  ".\\lib\\PresentationFramework.Classic.dll",
  ".\\lib\\PresentationFramework.dll",
  ".\\lib\\PresentationFramework.Luna.dll",
  ".\\lib\\PresentationFramework.Royale.dll",
  ".\\lib\\PresentationNative_cor3.dll",
  ".\\lib\\PresentationUI.dll",
  ".\\lib\\pwrshplugin.dll",
  ".\\lib\\ReachFramework.dll",
  ".\\lib\\System.AppContext.dll",
  ".\\lib\\System.Buffers.dll",
  ".\\lib\\System.CodeDom.dll",
  ".\\lib\\System.Collections.Concurrent.dll",
  ".\\lib\\System.Collections.dll",
  ".\\lib\\System.Collections.Immutable.dll",
  ".\\lib\\System.Collections.NonGeneric.dll",
  ".\\lib\\System.Collections.Specialized.dll",
  ".\\lib\\System.ComponentModel.Annotations.dll",
  ".\\lib\\System.ComponentModel.DataAnnotations.dll",
  ".\\lib\\System.ComponentModel.dll",
  ".\\lib\\System.ComponentModel.EventBasedAsync.dll",
  ".\\lib\\System.ComponentModel.Primitives.dll",
  ".\\lib\\System.ComponentModel.TypeConverter.dll",
  ".\\lib\\System.Configuration.ConfigurationManager.dll",
  ".\\lib\\System.Configuration.dll",
  ".\\lib\\System.Console.dll",
  ".\\lib\\System.Core.dll",
  ".\\lib\\System.Data.Common.dll",
  ".\\lib\\System.Data.DataSetExtensions.dll",
  ".\\lib\\System.Data.dll",
  ".\\lib\\System.Design.dll",
  ".\\lib\\System.Diagnostics.Contracts.dll",
  ".\\lib\\System.Diagnostics.Debug.dll",
  ".\\lib\\System.Diagnostics.DiagnosticSource.dll",
  ".\\lib\\System.Diagnostics.EventLog.dll",
  ".\\lib\\System.Diagnostics.EventLog.Messages.dll",
  ".\\lib\\System.Diagnostics.FileVersionInfo.dll",
  ".\\lib\\System.Diagnostics.PerformanceCounter.dll",
  ".\\lib\\System.Diagnostics.Process.dll",
  ".\\lib\\System.Diagnostics.StackTrace.dll",
  ".\\lib\\System.Diagnostics.TextWriterTraceListener.dll",
  ".\\lib\\System.Diagnostics.Tools.dll",
  ".\\lib\\System.Diagnostics.TraceSource.dll",
  ".\\lib\\System.Diagnostics.Tracing.dll",
  ".\\lib\\System.DirectoryServices.dll",
  ".\\lib\\System.dll",
  ".\\lib\\System.Drawing.Common.dll",
  ".\\lib\\System.Drawing.Design.dll",
  ".\\lib\\System.Drawing.dll",
  ".\\lib\\System.Drawing.Primitives.dll",
  ".\\lib\\System.Dynamic.Runtime.dll",
  ".\\lib\\System.Formats.Asn1.dll",
  ".\\lib\\System.Formats.Tar.dll",
  ".\\lib\\System.Globalization.Calendars.dll",
  ".\\lib\\System.Globalization.dll",
  ".\\lib\\System.Globalization.Extensions.dll",
  ".\\lib\\System.IO.Compression.Brotli.dll",
  ".\\lib\\System.IO.Compression.dll",
  ".\\lib\\System.IO.Compression.FileSystem.dll",
  ".\\lib\\System.IO.Compression.Native.dll",
  ".\\lib\\System.IO.Compression.ZipFile.dll",
  ".\\lib\\System.IO.dll",
  ".\\lib\\System.IO.FileSystem.AccessControl.dll",
  ".\\lib\\System.IO.FileSystem.dll",
  ".\\lib\\System.IO.FileSystem.DriveInfo.dll",
  ".\\lib\\System.IO.FileSystem.Primitives.dll",
  ".\\lib\\System.IO.FileSystem.Watcher.dll",
  ".\\lib\\System.IO.IsolatedStorage.dll",
  ".\\lib\\System.IO.MemoryMappedFiles.dll",
  ".\\lib\\System.IO.Packaging.dll",
  ".\\lib\\System.IO.Pipes.AccessControl.dll",
  ".\\lib\\System.IO.Pipes.dll",
  ".\\lib\\System.IO.UnmanagedMemoryStream.dll",
  ".\\lib\\System.Linq.dll",
  ".\\lib\\System.Linq.Expressions.dll",
  ".\\lib\\System.Linq.Parallel.dll",
  ".\\lib\\System.Linq.Queryable.dll",
  ".\\lib\\System.Management.Automation.dll",
  ".\\lib\\System.Management.dll",
  ".\\lib\\System.Memory.dll",
  ".\\lib\\System.Net.dll",
  ".\\lib\\System.Net.Http.dll",
  ".\\lib\\System.Net.Http.Json.dll",
  ".\\lib\\System.Net.HttpListener.dll",
  ".\\lib\\System.Net.Mail.dll",
  ".\\lib\\System.Net.NameResolution.dll",
  ".\\lib\\System.Net.NetworkInformation.dll",
  ".\\lib\\System.Net.Ping.dll",
  ".\\lib\\System.Net.Primitives.dll",
  ".\\lib\\System.Net.Quic.dll",
  ".\\lib\\System.Net.Requests.dll",
  ".\\lib\\System.Net.Security.dll",
  ".\\lib\\System.Net.ServicePoint.dll",
  ".\\lib\\System.Net.Sockets.dll",
  ".\\lib\\System.Net.WebClient.dll",
  ".\\lib\\System.Net.WebHeaderCollection.dll",
  ".\\lib\\System.Net.WebProxy.dll",
  ".\\lib\\System.Net.WebSockets.Client.dll",
  ".\\lib\\System.Net.WebSockets.dll",
  ".\\lib\\System.Numerics.dll",
  ".\\lib\\System.Numerics.Vectors.dll",
  ".\\lib\\System.ObjectModel.dll",
  ".\\lib\\System.Printing.dll",
  ".\\lib\\System.Private.CoreLib.dll",
  ".\\lib\\System.Private.DataContractSerialization.dll",
  ".\\lib\\System.Private.Uri.dll",
  ".\\lib\\System.Private.Xml.dll",
  ".\\lib\\System.Private.Xml.Linq.dll",
  ".\\lib\\System.Reflection.DispatchProxy.dll",
  ".\\lib\\System.Reflection.dll",
  ".\\lib\\System.Reflection.Emit.dll",
  ".\\lib\\System.Reflection.Emit.ILGeneration.dll",
  ".\\lib\\System.Reflection.Emit.Lightweight.dll",
  ".\\lib\\System.Reflection.Extensions.dll",
  ".\\lib\\System.Reflection.Metadata.dll",
  ".\\lib\\System.Reflection.Primitives.dll",
  ".\\lib\\System.Reflection.TypeExtensions.dll",
  ".\\lib\\System.Resources.Extensions.dll",
  ".\\lib\\System.Resources.Reader.dll",
  ".\\lib\\System.Resources.ResourceManager.dll",
  ".\\lib\\System.Resources.Writer.dll",
  ".\\lib\\System.Runtime.CompilerServices.Unsafe.dll",
  ".\\lib\\System.Runtime.CompilerServices.VisualC.dll",
  ".\\lib\\System.Runtime.dll",
  ".\\lib\\System.Runtime.Extensions.dll",
  ".\\lib\\System.Runtime.Handles.dll",
  ".\\lib\\System.Runtime.InteropServices.dll",
  ".\\lib\\System.Runtime.InteropServices.JavaScript.dll",
  ".\\lib\\System.Runtime.InteropServices.RuntimeInformation.dll",
  ".\\lib\\System.Runtime.Intrinsics.dll",
  ".\\lib\\System.Runtime.Loader.dll",
  ".\\lib\\System.Runtime.Numerics.dll",
  ".\\lib\\System.Runtime.Serialization.dll",
  ".\\lib\\System.Runtime.Serialization.Formatters.dll",
  ".\\lib\\System.Runtime.Serialization.Json.dll",
  ".\\lib\\System.Runtime.Serialization.Primitives.dll",
  ".\\lib\\System.Runtime.Serialization.Xml.dll",
  ".\\lib\\System.Security.AccessControl.dll",
  ".\\lib\\System.Security.Claims.dll",
  ".\\lib\\System.Security.Cryptography.Algorithms.dll",
  ".\\lib\\System.Security.Cryptography.Cng.dll",
  ".\\lib\\System.Security.Cryptography.Csp.dll",
  ".\\lib\\System.Security.Cryptography.dll",
  ".\\lib\\System.Security.Cryptography.Encoding.dll",
  ".\\lib\\System.Security.Cryptography.OpenSsl.dll",
  ".\\lib\\System.Security.Cryptography.Pkcs.dll",
  ".\\lib\\System.Security.Cryptography.Primitives.dll",
  ".\\lib\\System.Security.Cryptography.ProtectedData.dll",
  ".\\lib\\System.Security.Cryptography.X509Certificates.dll",
  ".\\lib\\System.Security.Cryptography.Xml.dll",
  ".\\lib\\System.Security.dll",
  ".\\lib\\System.Security.Permissions.dll",
  ".\\lib\\System.Security.Principal.dll",
  ".\\lib\\System.Security.Principal.Windows.dll",
  ".\\lib\\System.Security.SecureString.dll",
  ".\\lib\\System.ServiceModel.Web.dll",
  ".\\lib\\System.ServiceProcess.dll",
  ".\\lib\\System.Text.Encoding.CodePages.dll",
  ".\\lib\\System.Text.Encoding.dll",
  ".\\lib\\System.Text.Encoding.Extensions.dll",
  ".\\lib\\System.Text.Encodings.Web.dll",
  ".\\lib\\System.Text.Json.dll",
  ".\\lib\\System.Text.RegularExpressions.dll",
  ".\\lib\\System.Threading.AccessControl.dll",
  ".\\lib\\System.Threading.Channels.dll",
  ".\\lib\\System.Threading.dll",
  ".\\lib\\System.Threading.Overlapped.dll",
  ".\\lib\\System.Threading.Tasks.Dataflow.dll",
  ".\\lib\\System.Threading.Tasks.dll",
  ".\\lib\\System.Threading.Tasks.Extensions.dll",
  ".\\lib\\System.Threading.Tasks.Parallel.dll",
  ".\\lib\\System.Threading.Thread.dll",
  ".\\lib\\System.Threading.ThreadPool.dll",
  ".\\lib\\System.Threading.Timer.dll",
  ".\\lib\\System.Transactions.dll",
  ".\\lib\\System.Transactions.Local.dll",
  ".\\lib\\System.ValueTuple.dll",
  ".\\lib\\System.Web.dll",
  ".\\lib\\System.Web.HttpUtility.dll",
  ".\\lib\\System.Windows.Controls.Ribbon.dll",
  ".\\lib\\System.Windows.dll",
  ".\\lib\\System.Windows.Extensions.dll",
  ".\\lib\\System.Windows.Forms.Design.dll",
  ".\\lib\\System.Windows.Forms.Design.Editors.dll",
  ".\\lib\\System.Windows.Forms.dll",
  ".\\lib\\System.Windows.Forms.Primitives.dll",
  ".\\lib\\System.Windows.Input.Manipulations.dll",
  ".\\lib\\System.Windows.Presentation.dll",
  ".\\lib\\System.Xaml.dll",
  ".\\lib\\System.Xml.dll",
  ".\\lib\\System.Xml.Linq.dll",
  ".\\lib\\System.Xml.ReaderWriter.dll",
  ".\\lib\\System.Xml.Serialization.dll",
  ".\\lib\\System.Xml.XDocument.dll",
  ".\\lib\\System.Xml.XmlDocument.dll",
  ".\\lib\\System.Xml.XmlSerializer.dll",
  ".\\lib\\System.Xml.XPath.dll",
  ".\\lib\\System.Xml.XPath.XDocument.dll",
  ".\\lib\\UIAutomationClient.dll",
  ".\\lib\\UIAutomationClientSideProviders.dll",
  ".\\lib\\UIAutomationProvider.dll",
  ".\\lib\\UIAutomationTypes.dll",
  ".\\lib\\vcruntime140_cor3.dll",
  ".\\lib\\WindowsBase.dll",
  ".\\lib\\WindowsFormsIntegration.dll",
  ".\\lib\\wpfgfx_cor3.dll",
  ".\\lib\\cs\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\cs\\PresentationCore.resources.dll",
  ".\\lib\\cs\\PresentationFramework.resources.dll",
  ".\\lib\\cs\\PresentationUI.resources.dll",
  ".\\lib\\cs\\ReachFramework.resources.dll",
  ".\\lib\\cs\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\cs\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\cs\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\cs\\System.Windows.Forms.resources.dll",
  ".\\lib\\cs\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\cs\\System.Xaml.resources.dll",
  ".\\lib\\cs\\UIAutomationClient.resources.dll",
  ".\\lib\\cs\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\cs\\UIAutomationProvider.resources.dll",
  ".\\lib\\cs\\UIAutomationTypes.resources.dll",
  ".\\lib\\cs\\WindowsBase.resources.dll",
  ".\\lib\\cs\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\de\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\de\\PresentationCore.resources.dll",
  ".\\lib\\de\\PresentationFramework.resources.dll",
  ".\\lib\\de\\PresentationUI.resources.dll",
  ".\\lib\\de\\ReachFramework.resources.dll",
  ".\\lib\\de\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\de\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\de\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\de\\System.Windows.Forms.resources.dll",
  ".\\lib\\de\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\de\\System.Xaml.resources.dll",
  ".\\lib\\de\\UIAutomationClient.resources.dll",
  ".\\lib\\de\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\de\\UIAutomationProvider.resources.dll",
  ".\\lib\\de\\UIAutomationTypes.resources.dll",
  ".\\lib\\de\\WindowsBase.resources.dll",
  ".\\lib\\de\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\es\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\es\\PresentationCore.resources.dll",
  ".\\lib\\es\\PresentationFramework.resources.dll",
  ".\\lib\\es\\PresentationUI.resources.dll",
  ".\\lib\\es\\ReachFramework.resources.dll",
  ".\\lib\\es\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\es\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\es\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\es\\System.Windows.Forms.resources.dll",
  ".\\lib\\es\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\es\\System.Xaml.resources.dll",
  ".\\lib\\es\\UIAutomationClient.resources.dll",
  ".\\lib\\es\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\es\\UIAutomationProvider.resources.dll",
  ".\\lib\\es\\UIAutomationTypes.resources.dll",
  ".\\lib\\es\\WindowsBase.resources.dll",
  ".\\lib\\es\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\fr\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\fr\\PresentationCore.resources.dll",
  ".\\lib\\fr\\PresentationFramework.resources.dll",
  ".\\lib\\fr\\PresentationUI.resources.dll",
  ".\\lib\\fr\\ReachFramework.resources.dll",
  ".\\lib\\fr\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\fr\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\fr\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\fr\\System.Windows.Forms.resources.dll",
  ".\\lib\\fr\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\fr\\System.Xaml.resources.dll",
  ".\\lib\\fr\\UIAutomationClient.resources.dll",
  ".\\lib\\fr\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\fr\\UIAutomationProvider.resources.dll",
  ".\\lib\\fr\\UIAutomationTypes.resources.dll",
  ".\\lib\\fr\\WindowsBase.resources.dll",
  ".\\lib\\fr\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\it\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\it\\PresentationCore.resources.dll",
  ".\\lib\\it\\PresentationFramework.resources.dll",
  ".\\lib\\it\\PresentationUI.resources.dll",
  ".\\lib\\it\\ReachFramework.resources.dll",
  ".\\lib\\it\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\it\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\it\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\it\\System.Windows.Forms.resources.dll",
  ".\\lib\\it\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\it\\System.Xaml.resources.dll",
  ".\\lib\\it\\UIAutomationClient.resources.dll",
  ".\\lib\\it\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\it\\UIAutomationProvider.resources.dll",
  ".\\lib\\it\\UIAutomationTypes.resources.dll",
  ".\\lib\\it\\WindowsBase.resources.dll",
  ".\\lib\\it\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\ja\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\ja\\PresentationCore.resources.dll",
  ".\\lib\\ja\\PresentationFramework.resources.dll",
  ".\\lib\\ja\\PresentationUI.resources.dll",
  ".\\lib\\ja\\ReachFramework.resources.dll",
  ".\\lib\\ja\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\ja\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\ja\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\ja\\System.Windows.Forms.resources.dll",
  ".\\lib\\ja\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\ja\\System.Xaml.resources.dll",
  ".\\lib\\ja\\UIAutomationClient.resources.dll",
  ".\\lib\\ja\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\ja\\UIAutomationProvider.resources.dll",
  ".\\lib\\ja\\UIAutomationTypes.resources.dll",
  ".\\lib\\ja\\WindowsBase.resources.dll",
  ".\\lib\\ja\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\ko\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\ko\\PresentationCore.resources.dll",
  ".\\lib\\ko\\PresentationFramework.resources.dll",
  ".\\lib\\ko\\PresentationUI.resources.dll",
  ".\\lib\\ko\\ReachFramework.resources.dll",
  ".\\lib\\ko\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\ko\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\ko\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\ko\\System.Windows.Forms.resources.dll",
  ".\\lib\\ko\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\ko\\System.Xaml.resources.dll",
  ".\\lib\\ko\\UIAutomationClient.resources.dll",
  ".\\lib\\ko\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\ko\\UIAutomationProvider.resources.dll",
  ".\\lib\\ko\\UIAutomationTypes.resources.dll",
  ".\\lib\\ko\\WindowsBase.resources.dll",
  ".\\lib\\ko\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\pl\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\pl\\PresentationCore.resources.dll",
  ".\\lib\\pl\\PresentationFramework.resources.dll",
  ".\\lib\\pl\\PresentationUI.resources.dll",
  ".\\lib\\pl\\ReachFramework.resources.dll",
  ".\\lib\\pl\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\pl\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\pl\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\pl\\System.Windows.Forms.resources.dll",
  ".\\lib\\pl\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\pl\\System.Xaml.resources.dll",
  ".\\lib\\pl\\UIAutomationClient.resources.dll",
  ".\\lib\\pl\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\pl\\UIAutomationProvider.resources.dll",
  ".\\lib\\pl\\UIAutomationTypes.resources.dll",
  ".\\lib\\pl\\WindowsBase.resources.dll",
  ".\\lib\\pl\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\pt-BR\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\pt-BR\\PresentationCore.resources.dll",
  ".\\lib\\pt-BR\\PresentationFramework.resources.dll",
  ".\\lib\\pt-BR\\PresentationUI.resources.dll",
  ".\\lib\\pt-BR\\ReachFramework.resources.dll",
  ".\\lib\\pt-BR\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\pt-BR\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\pt-BR\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\pt-BR\\System.Windows.Forms.resources.dll",
  ".\\lib\\pt-BR\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\pt-BR\\System.Xaml.resources.dll",
  ".\\lib\\pt-BR\\UIAutomationClient.resources.dll",
  ".\\lib\\pt-BR\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\pt-BR\\UIAutomationProvider.resources.dll",
  ".\\lib\\pt-BR\\UIAutomationTypes.resources.dll",
  ".\\lib\\pt-BR\\WindowsBase.resources.dll",
  ".\\lib\\pt-BR\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\ru\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\ru\\PresentationCore.resources.dll",
  ".\\lib\\ru\\PresentationFramework.resources.dll",
  ".\\lib\\ru\\PresentationUI.resources.dll",
  ".\\lib\\ru\\ReachFramework.resources.dll",
  ".\\lib\\ru\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\ru\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\ru\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\ru\\System.Windows.Forms.resources.dll",
  ".\\lib\\ru\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\ru\\System.Xaml.resources.dll",
  ".\\lib\\ru\\UIAutomationClient.resources.dll",
  ".\\lib\\ru\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\ru\\UIAutomationProvider.resources.dll",
  ".\\lib\\ru\\UIAutomationTypes.resources.dll",
  ".\\lib\\ru\\WindowsBase.resources.dll",
  ".\\lib\\ru\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\tr\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\tr\\PresentationCore.resources.dll",
  ".\\lib\\tr\\PresentationFramework.resources.dll",
  ".\\lib\\tr\\PresentationUI.resources.dll",
  ".\\lib\\tr\\ReachFramework.resources.dll",
  ".\\lib\\tr\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\tr\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\tr\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\tr\\System.Windows.Forms.resources.dll",
  ".\\lib\\tr\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\tr\\System.Xaml.resources.dll",
  ".\\lib\\tr\\UIAutomationClient.resources.dll",
  ".\\lib\\tr\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\tr\\UIAutomationProvider.resources.dll",
  ".\\lib\\tr\\UIAutomationTypes.resources.dll",
  ".\\lib\\tr\\WindowsBase.resources.dll",
  ".\\lib\\tr\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\zh-Hans\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\zh-Hans\\PresentationCore.resources.dll",
  ".\\lib\\zh-Hans\\PresentationFramework.resources.dll",
  ".\\lib\\zh-Hans\\PresentationUI.resources.dll",
  ".\\lib\\zh-Hans\\ReachFramework.resources.dll",
  ".\\lib\\zh-Hans\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\zh-Hans\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\zh-Hans\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\zh-Hans\\System.Windows.Forms.resources.dll",
  ".\\lib\\zh-Hans\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\zh-Hans\\System.Xaml.resources.dll",
  ".\\lib\\zh-Hans\\UIAutomationClient.resources.dll",
  ".\\lib\\zh-Hans\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\zh-Hans\\UIAutomationProvider.resources.dll",
  ".\\lib\\zh-Hans\\UIAutomationTypes.resources.dll",
  ".\\lib\\zh-Hans\\WindowsBase.resources.dll",
  ".\\lib\\zh-Hans\\WindowsFormsIntegration.resources.dll",
  ".\\lib\\zh-Hant\\Microsoft.VisualBasic.Forms.resources.dll",
  ".\\lib\\zh-Hant\\PresentationCore.resources.dll",
  ".\\lib\\zh-Hant\\PresentationFramework.resources.dll",
  ".\\lib\\zh-Hant\\PresentationUI.resources.dll",
  ".\\lib\\zh-Hant\\ReachFramework.resources.dll",
  ".\\lib\\zh-Hant\\System.Windows.Controls.Ribbon.resources.dll",
  ".\\lib\\zh-Hant\\System.Windows.Forms.Design.resources.dll",
  ".\\lib\\zh-Hant\\System.Windows.Forms.Primitives.resources.dll",
  ".\\lib\\zh-Hant\\System.Windows.Forms.resources.dll",
  ".\\lib\\zh-Hant\\System.Windows.Input.Manipulations.resources.dll",
  ".\\lib\\zh-Hant\\System.Xaml.resources.dll",
  ".\\lib\\zh-Hant\\UIAutomationClient.resources.dll",
  ".\\lib\\zh-Hant\\UIAutomationClientSideProviders.resources.dll",
  ".\\lib\\zh-Hant\\UIAutomationProvider.resources.dll",
  ".\\lib\\zh-Hant\\UIAutomationTypes.resources.dll",
  ".\\lib\\zh-Hant\\WindowsBase.resources.dll",
  ".\\lib\\zh-Hant\\WindowsFormsIntegration.resources.dll"


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