Pester\Describe 'Test-LMStudioProcess basic functionality' {

    Pester\It 'Should return true when LMStudio process is running' -Skip:(-not ($Global:AllowLongRunningTests -eq $true)){

        $null = GenXdev.AI\Start-LMStudioApplication
        $result = GenXdev.AI\Test-LMStudioProcess
        $result | Pester\Should -Be $true
    }
}