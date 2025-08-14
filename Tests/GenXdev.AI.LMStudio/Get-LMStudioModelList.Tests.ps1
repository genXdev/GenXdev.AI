Pester\Describe 'Get-LMStudioModelList.Tests' {

    Pester\Context 'Basic functionality' {

        Pester\It 'Should return models with required properties' {
            # get all models
            $result = GenXdev.AI\Get-LMStudioModelList

            # verify if any models exist
            if ($null -eq $result) {
                Pester\Set-ItResult -Skipped -Because 'No models found in LM Studio'
                return
            }

            # verify models have required properties
            $result | Pester\Should -Not -BeNullOrEmpty
            $result | Microsoft.PowerShell.Core\ForEach-Object {
                $_.path | Pester\Should -Not -BeNullOrEmpty
            }
        }
    }
}
