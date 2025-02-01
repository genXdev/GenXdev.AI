Describe "Get-TextTranslation" {
    It "Should translate English to Spanish correctly" {
        Write-Verbose "Testing English to Spanish translation"
        $result = Get-TextTranslation -Text "Hello" -Language "spanish"
        $result | Should -BeLike "*Hola*"
    }
    It "Should translate English to Dutch correctly" {
        Write-Verbose "Testing English to Dutch translation"
        $result = Get-TextTranslation -Text "How are you doing?" -Language "Dutch"
        $result | Should -BeLike "*Hoe gaat het met je*"
    }
}