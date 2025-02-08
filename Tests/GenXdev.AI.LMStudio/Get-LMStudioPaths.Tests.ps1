Describe "Get-LMStudioPaths basic integration tests" {

    It "Returns valid default paths that exist on the system" {

        $result = Get-LMStudioPaths

        $result | Should -Not -BeNull
        [IO.File]::Exists($result.LMStudioExe) | Should -BeTrue
        [IO.File]::Exists($result.LMSExe) | Should -BeTrue
    }
}

################################################################################
