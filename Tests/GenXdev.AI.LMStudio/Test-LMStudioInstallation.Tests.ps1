################################################################################
Pester\Describe "Test-LMStudioInstallation function tests" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Test-LMStudioInstallation.ps1"

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

    Pester\It "Should verify LM Studio is properly installed and accessible" {
        # attempt to detect lm studio installation
        $result = GenXdev.AI\Test-LMStudioInstallation

        # test Should pass only if lm studio is actually installed
        $result | Pester\Should -Be $true -Because "LM Studio Should be installed
            for these tests to work"
    }
}

################################################################################