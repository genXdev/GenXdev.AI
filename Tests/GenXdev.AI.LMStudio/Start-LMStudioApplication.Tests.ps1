Describe "Start-LMStudioApplication functionality tests" {

    It "should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Start-LMStudioApplication.ps1"

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

    It "Should successfully start LM Studio application with default settings" {

        # start lm studio
        $result = Start-LMStudioApplication

        # verify process started
        $result | Should -BeNull

        # start lm studio
        $result = Start-LMStudioApplication -Passthru

        # verify process started
        $result | Should -Not -BeNullOrEmpty

        # give it time to start
        Start-Sleep -Seconds 2

        # verify process is running
        $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue
        $process | Should -Not -BeNullOrEmpty
    }
}
