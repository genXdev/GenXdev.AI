Pester\Describe 'Test-LMStudioInstallation function tests' {

    Pester\It 'Should verify LM Studio is properly installed and accessible' -Skip:(-not ($Global:AllowLongRunningTests -eq $true)){

        # attempt to detect lm studio installation
        $result = GenXdev.AI\Test-LMStudioInstallation

        # test Should pass only if lm studio is actually installed
        $result | Pester\Should -Be $true -Because 'LM Studio Should be installed
            for these tests to work'
    }
}
