################################################################################
Describe "Start-AudioTranscription Start-AudioTranscription" {

    BeforeAll {
        $Script:scriptPath = GenXdev.FileSystem\Expand-Path `
            "$PSScriptRoot\..\..\Functions\GenXdev.AI\Start-AudioTranscription.ps1"
    }

    It "Should pass PSScriptAnalyzer rules" {
        # run analyzer with explicit settings
        $Script:analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $Script:scriptPath

        [string] $Script:message = ""
        $Script:analyzerResults | ForEach-Object {
            $Script:message = $Script:message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $Script:analyzerResults.Count | Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$Script:message
"@
    }
}
################################################################################