if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major
$build = $osVersion.Build

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}


. "$PSScriptRoot\Functions\GenXdev.AI\Approve-NewTextFileContent.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Convert-DotNetTypeToLLMType.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\ConvertTo-LMStudioFunctionDefinition.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\EnsureGithubCLIInstalled.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\EnsurePaintNet.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\EnsureWinMergeInstalled.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\GenerateMasonryLayoutHtml.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-AIDefaultLLMSettings.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-AILLMSettings.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-CpuCore.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-HasCapableGpu.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-NumberOfCpuCores.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-TextTranslation.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Get-VectorSimilarity.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Invoke-CommandFromToolCall.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Invoke-LLMBooleanEvaluation.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Invoke-LLMQuery.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Invoke-LLMStringListEvaluation.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Invoke-LLMTextTransformation.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Invoke-WinMerge.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\New-LLMAudioChat.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\New-LLMTextChat.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Set-AILLMSettings.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Set-ClipboardFiles.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Set-GenXdevAICommandNotFoundAction.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Start-GenXdevMCPServer.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI\Test-DeepLinkImageFile.ps1"
