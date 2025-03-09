################################################################################

Describe "Test-LMStudioInstallation function tests" {

    It "should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Test-LMStudioInstallation.ps1"

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

    It "Should verify LM Studio is properly installed and accessible" {
        # attempt to detect lm studio installation
        $result = Test-LMStudioInstallation

        # test should pass only if lm studio is actually installed
        $result | Should -Be $true -Because "LM Studio should be installed
            for these tests to work"
    }
}

################################################################################
