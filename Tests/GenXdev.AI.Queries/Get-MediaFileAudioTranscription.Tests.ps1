Pester\Describe 'Get-MediaFileAudioTranscription' {

    # It "Should get audio transcription from a media file" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

    #     # test with default model name that Should be available
    #     $result = Get-MediaFileAudioTranscription -FilePath "$PSScriptRoot\escalated-quickly.mp3" -Verbose
    #     $result | Should -Not -BeNullOrEmpty
    #     $result | Should -Contain "escalated quickly"
    # }
}