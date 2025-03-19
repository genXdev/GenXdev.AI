################################################################################

Pester\Describe "Get-LMStudioModelList.Tests" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Get-LMStudioModelList.ps1"

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

    Pester\Context "Basic functionality" {

        Pester\It "Should return models with required properties" {
            # get all models
            $result = GenXdev.AI\Get-LMStudioModelList

            # verify if any models exist
            if ($null -eq $result) {
                Pester\Set-ItResult -Skipped -Because "No models found in LM Studio"
                return
            }

            # verify models have required properties
            $result | Pester\Should -Not -BeNullOrEmpty
            $result | Microsoft.PowerShell.Core\ForEach-Object {
                $_.path | Pester\Should -Not -BeNullOrEmpty
            }
        }

        Pester\It "Should be able to find qwen-14b model if present" {
            # get all models and filter for qwen-14b
            $result = GenXdev.AI\Get-LMStudioModelList

            # verify if any models exist
            if ($null -eq $result) {
                Pester\Set-ItResult -Skipped -Because "No models found in LM Studio"
                return
            }

            # check for qwen-14b in model paths
            $qwenModel = $result | Microsoft.PowerShell.Core\Where-Object { $_.path -like "*Qwen2.5-14B*" }

            # skip if not found (don't fail - model might not be installed)
            if ($null -eq $qwenModel) {
                Pester\Set-ItResult -Skipped -Because "qwen-14b model not installed"
                return
            }

            # verify model properties if found
            $qwenModel.path | Pester\Should -Not -BeNullOrEmpty
            $qwenModel.path | Pester\Should -BeLike "*Qwen2.5-14B*"
        }
    }
}

################################################################################