################################################################################

Pester\Describe "Get-LMStudioLoadedModelList basic functionality test" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Get-LMStudioLoadedModelList.ps1"

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

    Pester\It "Should return loaded models from LM Studio" {

        GenXdev.AI\AssureLMStudio

        $result = GenXdev.AI\Get-LMStudioLoadedModelList

        # verify we get valid response
        $result | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It "Should have qwen2.5-14b-instruct model present" {

        GenXdev.AI\Initialize-LMStudioModel -Model "qwen2.5-14b-instruct" -ModelLMSGetIdentifier "qwen2.5-14b-instruct"
        $result = GenXdev.AI\Get-LMStudioLoadedModelList

        # verify qwen-14b model exists
        $qwenModel = $result | Microsoft.PowerShell.Core\Where-Object { $_.identifier -like "qwen2.5-14b-instruct" }
        $qwenModel | Pester\Should -Not -BeNull
    }
}

################################################################################