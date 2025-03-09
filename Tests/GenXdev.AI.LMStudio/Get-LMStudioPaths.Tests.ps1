Describe "Get-LMStudioPaths basic integration tests" {

    It "should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Get-LMStudioPaths.ps1"

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

    It "Returns valid default paths that exist on the system" {

        $result = Get-LMStudioPaths

        $result | Should -Not -BeNull
        [IO.File]::Exists($result.LMStudioExe) | Should -BeTrue
        [IO.File]::Exists($result.LMSExe) | Should -BeTrue
    }
}

################################################################################
