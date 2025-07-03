###############################################################################
Pester\Describe "Get-CpuCore" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

# get the analyzed script path
        $scriptPath = GenXdev.FileSystem\Expand-Path `
            "$PSScriptRoot\..\..\Functions\GenXdev.AI\Get-CpuCore.ps1"

# execute analyzer with settings
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
}
###############################################################################