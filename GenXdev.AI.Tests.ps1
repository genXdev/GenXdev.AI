# GenXdev.AI.Tests.ps1

# Load the module to be tested
Import-Module -Name GenXdev.Helpers -Force | Out-Null
Import-Module -Name GenXdev.AI -Force | Out-Null

AssurePester

# Describe the function to be tested
Describe "Get-TextTranslation" {
    It "Should translate the text" {

        # Act
        $result = Get-TextTranslation -Text "Hello" -Language "spanish"

        # Assert
        $result | Should -BeLike "*Hola*"
    }
}
