################################################################################

Describe "Initialize-LMStudioModel.Tests" {

    It "should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Initialize-LMStudioModel.ps1"

        # run analyzer with explicit settings
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath

        [string] $message = ""
        $analyzerResults | ForEach-Object {

            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@;
    }
}

################################################################################

Describe "Initialize-LMStudioModel integration tests" {

    It "Should initialize a model by name" {
        # test with default model name that should be available
        $result = Initialize-LMStudioModel -Model "*-tool-use" -ModelLMSGetIdentifier "llama-3-groq-8b-tool-use"
        $result | Should -Not -Be $null
        $result.path | Should -Not -BeNullOrEmpty
    }

    It "Should initialize with window visible" {
        $result = Initialize-LMStudioModel -Model "*-tool-use" -ModelLMSGetIdentifier "llama-3-groq-8b-tool-use" -ShowWindow
        $result | Should -Not -Be $null
        $result.path | Should -Not -BeNullOrEmpty

        $window = Get-Window "LM Studio"
        $window  | Should -Not -Be $null
        $window.Handle  | Should -Not -Be 0
        $window.IsVisible() | Should -Be $true
    }

    It "Should fall back to preferred models if specified not found" {
        # test with non-existent model name to trigger fallback
        $result = Initialize-LMStudioModel `
            -Model "nonexistent_model_12345" `
            -PreferredModels @("*-tool-use", "mistral")
        $result | Should -Not -BeNullOrEmpty
    }
}

################################################################################
