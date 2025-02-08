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

    It "Should have qwen*-instruct model present" {

        Initialize-LMStudioModel -Model "qwen*-instruct" -ModelLMSGetIdentifier "qwen2.5-14b-instruct"
        $result = Get-LMStudioLoadedModelList

        # verify qwen-7b model exists
        $qwenModel = $result | Where-Object { $_.path -like "*qwen*-instruct*" }
        $qwenModel | Should -Not -BeNull
    }
}

################################################################################
