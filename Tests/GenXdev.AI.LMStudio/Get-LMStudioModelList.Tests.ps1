###############################################################################

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
    }
}

###############################################################################