if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major
$build = $osVersion.Build

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}



. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Add-GenXdevMCPServerToLMStudio.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\EnsureLMStudio.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Get-LMStudioLoadedModelList.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Get-LMStudioModelList.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Get-LMStudioPaths.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Get-LMStudioTextEmbedding.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Get-LMStudioWindow.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Initialize-LMStudioModel.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Install-LMStudioApplication.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Start-LMStudioApplication.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Test-LMStudioInstallation.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.LMStudio\Test-LMStudioProcess.ps1"
