if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}



. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Compare-ImageFaces.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\EnsureDeepStack.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Get-ImageDetectedFaces.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Get-ImageDetectedObjects.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Get-ImageDetectedScenes.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Get-RegisteredFaces.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Invoke-ImageEnhancement.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Register-AllFaces.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Register-Face.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Unregister-AllFaces.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.DeepStack\Unregister-Face.ps1"
