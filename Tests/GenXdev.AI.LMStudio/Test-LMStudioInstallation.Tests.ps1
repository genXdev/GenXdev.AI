################################################################################

Describe "Test-LMStudioInstallation function tests" {

    It "Should verify LM Studio is properly installed and accessible" {
        # attempt to detect lm studio installation
        $result = Test-LMStudioInstallation

        # test should pass only if lm studio is actually installed
        $result | Should -Be $true -Because "LM Studio should be installed
            for these tests to work"
    }
}

################################################################################
