Pester\Describe "Start-LMStudioApplication functionality tests" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

# get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\Start-LMStudioApplication.ps1"

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

    Pester\It "Should successfully start LM Studio application with default settings" {

# start lm studio
        $result = GenXdev.AI\Start-LMStudioApplication

# verify process started
        $result | Pester\Should -BeNull

# start lm studio
        $result = GenXdev.AI\Start-LMStudioApplication -Passthru

# verify process started
        $result | Pester\Should -Not -BeNullOrEmpty

# give it time to start
        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2

# verify process is running
        $process = Microsoft.PowerShell.Management\Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue
        $process | Pester\Should -Not -BeNullOrEmpty
    }
}