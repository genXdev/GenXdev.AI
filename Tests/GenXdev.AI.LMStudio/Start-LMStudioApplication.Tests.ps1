Pester\Describe 'Start-LMStudioApplication functionality tests' {

    Pester\It 'Should successfully start LM Studio application with default settings' {

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
        $process = Microsoft.PowerShell.Management\Get-Process -Name 'LM Studio' -ErrorAction SilentlyContinue
        $process | Pester\Should -Not -BeNullOrEmpty
    }
}