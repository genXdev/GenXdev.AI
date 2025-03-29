################################################################################

Pester\Describe "Initialize-LMStudioModel.Tests" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Initialize-LMStudioModel.ps1"

        # run analyzer with explicit settings
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath

        [string] $message = ""
        $analyzerResults | Microsoft.PowerShell.Core\ForEach-Object {

            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Pester\Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@;
    }
}

################################################################################

Pester\Describe "Initialize-LMStudioModel integration tests" {

    Pester\It "Should initialize a model by name" {
        # test with default model name that Should be available
        $result = GenXdev.AI\Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ModelLMSGetIdentifier "qwen2.5-14b-instruct"
        $result | Pester\Should -Not -Be $null
        $result.path | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It "Should fall back to preferred models if specified not found" {
        # test with non-existent model name to trigger fallback
        $result = GenXdev.AI\Initialize-LMStudioModel `
            -Model "nonexistent_model_12345" `
            -PreferredModels @("qwen2.5-14b-instruct", "mistral")
        $result | Pester\Should -Not -BeNullOrEmpty
    }
}

################################################################################