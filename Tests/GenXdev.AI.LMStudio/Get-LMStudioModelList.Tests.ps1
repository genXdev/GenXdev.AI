################################################################################

Describe "Get-LMStudioModelList functionality tests" {

    Context "Basic functionality" {

        It "Should return models with required properties" {
            # get all models
            $result = Get-LMStudioModelList

            # verify if any models exist
            if ($null -eq $result) {
                Set-ItResult -Skipped -Because "No models found in LM Studio"
                return
            }

            # verify models have required properties
            $result | Should -Not -BeNullOrEmpty
            $result | ForEach-Object {
                $_.path | Should -Not -BeNullOrEmpty
            }
        }

        It "Should be able to find qwen-7b model if present" {
            # get all models and filter for qwen-7b
            $result = Get-LMStudioModelList

            # verify if any models exist
            if ($null -eq $result) {
                Set-ItResult -Skipped -Because "No models found in LM Studio"
                return
            }

            # check for qwen-7b in model paths
            $qwenModel = $result | Where-Object { $_.path -like "*qwen-7b*" }

            # skip if not found (don't fail - model might not be installed)
            if ($null -eq $qwenModel) {
                Set-ItResult -Skipped -Because "Qwen-7b model not installed"
                return
            }

            # verify model properties if found
            $qwenModel.path | Should -Not -BeNullOrEmpty
            $qwenModel.path | Should -BeLike "*qwen-7b*"
        }
    }
}

################################################################################
