if (-not $IsWindows) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}

$osVersion = [System.Environment]::OSVersion.Version
$major = $osVersion.Major

if ($major -ne 10) {
    throw "This module only supports Windows 10+ x64 with PowerShell 7.5+ x64"
}



. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Add-EmoticonsToText.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\ConvertFrom-CorporateSpeak.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\ConvertFrom-DiplomaticSpeak.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\ConvertTo-CorporateSpeak.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\ConvertTo-DiplomaticSpeak.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Export-ImageIndex.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Find-Image.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Find-IndexedImage.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Get-AIImageCollection.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Get-Fallacy.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Get-ImageIndexPath.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Get-ImageIndexStats.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Get-ScriptExecutionErrorFixPrompt.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Get-SimularMovieTitles.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-AIPowershellCommand.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-ImageFacesUpdate.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-ImageKeywordUpdate.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-ImageMetadataUpdate.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-ImageObjectsUpdate.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-ImageScenesUpdate.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Invoke-QueryImageContent.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Remove-ImageDirectories.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Remove-ImageMetaData.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Save-FoundImageFaces.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Save-FoundImageObjects.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Save-Transcriptions.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Set-AIImageCollection.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Set-WindowsWallpaperEx.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Show-FoundImagesInBrowser.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Show-GenXdevScriptErrorFixInIde.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Start-AudioTranscription.ps1"
. "$PSScriptRoot\Functions\GenXdev.AI.Queries\Update-AllImageMetaData.ps1"
