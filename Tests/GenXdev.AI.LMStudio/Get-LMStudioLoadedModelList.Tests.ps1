Pester\Describe 'Get-LMStudioLoadedModelList basic functionality test' {

    Pester\It 'Should return loaded models from LM Studio' {

        GenXdev.AI\EnsureLMStudio

        $result = GenXdev.AI\Get-LMStudioLoadedModelList

        # verify we get valid response
        $result | Pester\Should -Not -BeNullOrEmpty
    }

}
