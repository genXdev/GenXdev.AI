Describe "New-LLMTextChat - Test default ExposedCmdlets" {

    BeforeAll {
        Import-Module GenXdev.AI -Force
    }

    It "Should test basic functionality" {

        $query = "Please check the content of https://powershell.genxdev.net/ using the Invoke-WebRequest tool and tell me what web server is running."

        $result = New-LLMTextChat -Query $query -ChatOnce -Model "llama-3-groq-8b-tool-use"

        $result | Should -Not -BeNullOrEmpty

        $result | Should -BeLike "*Internet Information Services*"
    }
}