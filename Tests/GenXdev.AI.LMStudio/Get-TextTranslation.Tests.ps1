Pester\Describe 'Get-TextTranslation' {

    Pester\It 'Should translate English to Spanish correctly' -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        Microsoft.PowerShell.Utility\Write-Verbose 'Testing English to Spanish translation'
        $result = GenXdev.AI\Get-TextTranslation -Text 'Hello' -Language 'Spanish'
        $result | Pester\Should -BeLike '*Hola*'
    }
    Pester\It 'Should translate English to Dutch correctly' -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        Microsoft.PowerShell.Utility\Write-Verbose 'Testing English to Dutch translation'
        $result = GenXdev.AI\Get-TextTranslation -Text 'How are you doing?' -Language 'Dutch'
        $result | Pester\Should -BeLike '*Hoe gaat het met je*'
    }
}