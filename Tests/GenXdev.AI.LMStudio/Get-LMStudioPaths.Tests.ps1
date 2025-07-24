Pester\Describe 'Get-LMStudioPaths basic integration tests' {

    Pester\It 'Should pass PSScriptAnalyzer rules' {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Get-LMStudioPaths.ps1"

        # run analyzer with explicit settings
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath

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

    Pester\It 'Returns valid default paths that exist on the system' {

        $result = GenXdev.AI\Get-LMStudioPaths

        $result | Pester\Should -Not -BeNull
        [IO.File]::Exists($result.LMStudioExe) | Pester\Should -BeTrue
        [IO.File]::Exists($result.LMSExe) | Pester\Should -BeTrue
    }
}

###############################################################################