Describe "Get-TextTranslation" {
    It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI\Get-TextTranslation.ps1"

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

    It "Should translate English to Spanish correctly" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        Write-Verbose "Testing English to Spanish translation"
        $result = Get-TextTranslation -Text "Hello" -Language "spanish"
        $result | Should -BeLike "*Hola*"
    }
    It "Should translate English to Dutch correctly" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        Write-Verbose "Testing English to Dutch translation"
        $result = Get-TextTranslation -Text "How are you doing?" -Language "Dutch"
        $result | Should -BeLike "*Hoe gaat het met je*"
    }
}