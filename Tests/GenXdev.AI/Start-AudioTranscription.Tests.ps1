################################################################################
Pester\Describe "Start-AudioTranscription Start-AudioTranscription" {

    Pester\BeforeAll {
        $Script:scriptPath = GenXdev.FileSystem\Expand-Path `
            "$PSScriptRoot\..\..\Functions\GenXdev.AI\Start-AudioTranscription.ps1"
    }

    Pester\It "Should pass PSScriptAnalyzer rules" {
        # run analyzer with explicit settings
        $Script:analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $Script:scriptPath

        [string] $Script:message = ""
        $Script:analyzerResults | Microsoft.PowerShell.Core\ForEach-Object {
            $Script:message = $Script:message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $Script:analyzerResults.Count | Pester\Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$Script:message
"@
    }
}
################################################################################