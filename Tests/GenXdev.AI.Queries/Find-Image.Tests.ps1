################################################################################
Pester\Describe "Find-Image" {

    Pester\It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.Queries\Find-Image.ps1"

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

    ################################################################################

    Pester\It "Should work the same as Find-IndexedImage" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

        $tmpPath = [IO.Path]::GetTempPath()
        $testImagePath = GenXdev.FileSystem\Expand-Path ([IO.Path]::Combine($tmpPath, "test-image.png")) -CreateDirectory -DeleteExistingFile
        $sourceImage = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\programmer.jpg"

        Copy-Item $sourceImage $testImagePath -Force

        $null = GenXdev.AI\Remove-ImageMetaData -ImageDirectories $tmpPath -AllLanguages

        $resultsFindImage = GenXdev.AI.Queries\Find-Image -ImageDirectories $tmpPath | ConvertTo-HashTable | ConvertTo-Json -depth 20 | ConvertFrom-Json
        $resultsFindIndexedImage = GenXdev.AI.Queries\Find-IndexedImage -ImageDirectories $tmpPath | ConvertTo-HashTable | ConvertTo-Json -depth 20 | ConvertFrom-Json

        $resultsFindImage | Pester\Should -BeLikeExactly @resultsFindIndexedImage
    }
}
################################################################################