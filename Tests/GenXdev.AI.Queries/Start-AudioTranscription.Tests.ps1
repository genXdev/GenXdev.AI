Pester\Describe 'Start-AudioTranscription' {

    Pester\BeforeAll {

        GenXdev.AI\Set-AILLMSettings -ClearSession TextTranslation
    }

    Pester\It "Should get audio transcription from a media file" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

        # test with default model name that Should be available
        $result = GenXdev.AI\Start-AudioTranscription -FilePath "$PSScriptRoot\escalated-quickly.mp3" -LanguageIn English -Verbose | Microsoft.PowerShell.Utility\Out-String
        $result | Pester\Should -Not -BeNullOrEmpty
        $result | Pester\Should -BeLike "*Boy, that escalated quickly.*"
        $result | Pester\Should -BeLike "*I mean, that really got out of hand fast*"
    }
}