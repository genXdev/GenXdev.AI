Pester\Describe 'Get-LMStudioPaths basic integration tests' {

    Pester\It 'Returns valid default paths that exist on the system' {

        $result = GenXdev.AI\Get-LMStudioPaths

        $result | Pester\Should -Not -BeNull
        [IO.File]::Exists($result.LMStudioExe) | Pester\Should -BeTrue
        [IO.File]::Exists($result.LMSExe) | Pester\Should -BeTrue
    }
}
