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

        $dbPath = $tmpPath = GenXdev.FileSystem\Expand-Path ([IO.Path]::GetTempFileName()) -DeleteExistingFile
        $tmpPath = [IO.Path]::GetTempFileName()
        $testImagePath = GenXdev.FileSystem\Expand-Path $tmpPath -DeleteExistingFile
        $testImagePath = GenXdev.FileSystem\Expand-Path "$tmpPath\test-image.png" -CreateDirectory -DeleteExistingFile
        $sourceImage = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\programmer.jpg"

        Copy-Item $sourceImage $testImagePath -Force

        $null = GenXdev.AI\Remove-ImageMetaData -ImageDirectories $tmpPath -AllLanguages

        GenXdev.Windows\Set-WindowPosition -left -Monitor 0
        GenXdev.AI\Update-AllImageMetaData -ImageDirectories $tmpPath -ShowWindow
        GenXdev.AI\Export-ImageDirectories -DatabaseFilePath $dbPath -ImageDirectories $tmpPath -ShowWindow

        $resultsFindImage = GenXdev.AI\Find-Image -ImageDirectories @($tmpPath) | ConvertTo-HashTable | ConvertTo-Json -Depth 20
        $resultsFindIndexedImage = GenXdev.AI\Find-IndexedImage -ImageDirectories @($tmpPath) -DatabaseFilePath $dbPath | ConvertTo-HashTable | ConvertTo-Json -Depth 20

        $resultsFindImage | Pester\Should -Be $resultsFindIndexedImage -Because "The results of Find-Image and Find-IndexedImage should be the same."
    }
}
################################################################################