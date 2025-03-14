################################################################################

Describe "Get-LMStudioLoadedModelList basic functionality test" {

    It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Get-LMStudioLoadedModelList.ps1"

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

    It "Should return loaded models from LM Studio" {

        AssureLMStudio

        $result = Get-LMStudioLoadedModelList

        # verify we get valid response
        $result | Should -Not -BeNullOrEmpty
    }

    It "Should have qwen2.5-14b-instruct model present" {

        Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ModelLMSGetIdentifier "qwen2.5-14b-instruct"
        $result = Get-LMStudioLoadedModelList

        # verify qwen-7b model exists
        $qwenModel = $result | Where-Object { $_.identifier -like "qwen2.5-14b-instruct" }
        $qwenModel | Should -Not -BeNull
    }
}

################################################################################