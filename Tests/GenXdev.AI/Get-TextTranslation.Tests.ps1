Pester\Describe "Get-TextTranslation" {
    Pester\It "Should pass PSScriptAnalyzer rules" {

# get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI\Get-TextTranslation.ps1"

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

    Pester\It "Should translate English to Spanish correctly" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        Microsoft.PowerShell.Utility\Write-Verbose "Testing English to Spanish translation"
        $result = GenXdev.AI\Get-TextTranslation -Text "Hello" -Language "Spanish"
        $result | Pester\Should -BeLike "*Hola*"
    }
    Pester\It "Should translate English to Dutch correctly" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        Microsoft.PowerShell.Utility\Write-Verbose "Testing English to Dutch translation"
        $result = GenXdev.AI\Get-TextTranslation -Text "How are you doing?" -Language "Dutch"
        $result | Pester\Should -BeLike "*Hoe gaat het met je*"
    }
}