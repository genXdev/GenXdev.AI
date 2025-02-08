Describe "Test-LMStudioProcess basic functionality" {

    It "Should return true when LMStudio process is running" {

        $null = Start-LMStudioApplication
        $result = Test-LMStudioProcess
        $result | Should -Be $true
    }
}
