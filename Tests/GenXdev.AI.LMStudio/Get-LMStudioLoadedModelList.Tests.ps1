################################################################################

Describe "Get-LMStudioLoadedModelList basic functionality test" {

    BeforeAll {
        # ensure module is loaded
        Import-Module GenXdev.AI -Force
    }

    It "Should return loaded models from LM Studio" {

        $result = Get-LMStudioLoadedModelList

        # verify we get valid response
        $result | Should -Not -BeNullOrEmpty
    }

    It "Should have *-tool-use model present" {

        Initialize-LMStudioModel -Model "*-tool-use" -ModelLMSGetIdentifier "llama-3-groq-8b-tool-use"
        $result = Get-LMStudioLoadedModelList

        # verify qwen-7b model exists
        $qwenModel = $result | Where-Object { $_.path -like "**-tool-use*" }
        $qwenModel | Should -Not -BeNull
    }
}

################################################################################
