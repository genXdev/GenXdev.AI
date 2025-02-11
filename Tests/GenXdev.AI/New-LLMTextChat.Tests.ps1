Describe "New-LLMTextChat - Test default ExposedCmdlets" {

    BeforeAll {
        Import-Module GenXdev.AI -Force
    }

    It "Should test basic functionality" {

        $query = "Please check the content of https://powershell.genxdev.net/  and like the website BuildWith tell me everything there is to now about the technologies used. Also fetch referenced scripts and styles, etc. before jumping to conclusions."

        $result = New-LLMTextChat -Query $query -ChatOnce

        $result | Should -Not -BeNullOrEmpty

        $result | Should -BeLike "*Microsoft-IIS/10.0*"
    }
}