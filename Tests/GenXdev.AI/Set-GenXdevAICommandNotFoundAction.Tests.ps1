###############################################################################
Pester\Describe 'Set-GenXdevAICommandNotFoundAction Set-GenXdevAICommandNotFoundAction' {

    Pester\BeforeAll {
        $script:scriptPath = GenXdev.FileSystem\Expand-Path `
            "$PSScriptRoot\..\..\Functions\GenXdev.AI\Set-GenXdevAICommandNotFoundAction.ps1"
    }

    Pester\It 'Should pass PSScriptAnalyzer rules' {

        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $script:scriptPath

        [string] $message = ''
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
###############################################################################