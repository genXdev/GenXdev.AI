if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major
$build = $osVersion.Build

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}



. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\ConvertComfyImageFormat.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\CreateComfySDXLWorkflow.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\CreateComfyUniversalWorkflow.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\DownloadComfyResults.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\EnsureComfyUI.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\EnsureComfyUIModel.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\Get-ComfyUIModelPath.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\Invoke-ComfyUIImageGeneration.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\QueueComfyWorkflow.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\ResizeComfyInputImage.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\Set-ComfyUIBackgroundImage.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\Set-ComfyUIModelPath.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\SetComfyUIProcessPriority.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\Stop-ComfyUI.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\Test-ComfyUIQueueEmpty.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\UploadComfyImage.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.ComfyUI\WaitForComfyCompletion.ps1"
