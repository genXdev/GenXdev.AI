###############################################################################
Pester\Describe "Get-MediaFileAudioTranscription" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

# get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.Queries\Get-MediaFileAudioTranscription.ps1"

# run analyzer with explicit settings
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath

        [string] $message = ""
        $analyzerResults | Microsoft.PowerShell.Core\ForEach-Object {

            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Pester\Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@;
    }


    # It "Should get audio transcription from a media file" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

    #     # test with default model name that Should be available
    #     $result = Get-MediaFileAudioTranscription -FilePath "$PSScriptRoot\escalated-quickly.mp3" -Verbose
    #     $result | Should -Not -BeNullOrEmpty
    #     $result | Should -Contain "escalated quickly"
    # }
}
###############################################################################