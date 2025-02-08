Describe "Start-LMStudioApplication functionality tests" {

    It "Should successfully start LM Studio application with default settings" {

        # start lm studio
        $result = Start-LMStudioApplication

        # verify process started
        $result | Should -BeNull

        # start lm studio
        $result = Start-LMStudioApplication -Passthru

        # verify process started
        $result | Should -not -BeNullOrEmpty

        # give it time to start
        Start-Sleep -Seconds 2

        # verify process is running
        $process = Get-Process -Name "LM Studio" -ErrorAction SilentlyContinue
        $process | Should -Not -BeNullOrEmpty
    }
}
