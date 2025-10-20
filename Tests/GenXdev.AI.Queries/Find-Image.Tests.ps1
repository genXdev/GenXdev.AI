Pester\Describe 'Find-Image' {

    Pester\It 'Should work the same as Find-IndexedImage' -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

        $dbPath = [IO.Path]::GetTempFileName() + ".db"
        $tmpPath = [IO.Path]::GetTempFileName()
        $testImagePath = GenXdev.FileSystem\Expand-Path $tmpPath -DeleteExistingFile
        $testImagePath = GenXdev.FileSystem\Expand-Path "$tmpPath\test-image.png" -CreateDirectory -DeleteExistingFile
        $sourceImage = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\programmer.jpg"

        Microsoft.PowerShell.Management\Copy-Item -LiteralPath $sourceImage -Destination $testImagePath -Force

        $null = GenXdev.AI\Remove-ImageMetaData -ImageDirectories $tmpPath -AllLanguages

        GenXdev.Windows\Set-WindowPosition -Left -Monitor 0
        GenXdev.AI\Update-AllImageMetaData -ImageDirectories $tmpPath -ShowWindow
        GenXdev.AI\Export-ImageIndex -DatabaseFilePath $dbPath -ImageDirectories $tmpPath -ShowWindow

        $resultsFindImage = GenXdev.AI\Find-Image -ImageDirectories @($tmpPath) -PathLike $tmpPath | GenXdev.Helpers\ConvertTo-HashTable | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20
        $resultsFindIndexedImage = GenXdev.AI\Find-IndexedImage -ImageDirectories @($tmpPath) -DatabaseFilePath $dbPath -PathLike $tmpPath | GenXdev.Helpers\ConvertTo-HashTable | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20

        Microsoft.PowerShell.Utility\Write-Verbose ($resultsFindImage | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20)
        Microsoft.PowerShell.Utility\Write-Verbose ($resultsFindIndexedImage | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20)

        $resultsFindImage | Pester\Should -Be $resultsFindIndexedImage -Because 'The results of Find-Image and Find-IndexedImage should be the same.'
    }
}