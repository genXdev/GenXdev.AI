# Tests for Add-ImageDirectories -SessionOnly
# This test verifies that Add-ImageDirectories adds directories when using -SessionOnly

Pester\Describe 'GenXdev.AI.Queries\Add-ImageDirectories (SessionOnly)' {

    Pester\BeforeAll {
        # Prepare test directory paths (these don't need to exist)
        $script:TestDirs = @(
            'C:\TestImages\Collection1',
            'C:\TestImages\Collection2'
        )

        # Ensure clean collections for the test
        GenXdev.AI\Set-AIImageCollection -ImageDirectories @() -SessionOnly -Confirm:$false

        # Retrieve the session-only collection
        $result = GenXdev.AI\Get-AIImageCollection -SessionOnly

        # Assert both directories are present in the session-only collection
        $result | Pester\Should -Not -Contain $script:TestDirs[0]
        $result | Pester\Should -Not -Contain $script:TestDirs[1]
    }

    Pester\It 'Adds specified directories to the session-only image collection' {
        # Add directories using session-only mode
        GenXdev.AI\Add-ImageDirectories -ImageDirectories ($script:TestDirs) -SessionOnly -Confirm:$false

        # Retrieve the session-only collection
        $result = GenXdev.AI\Get-AIImageCollection -SessionOnly

        # Assert both directories are present in the session-only collection
        $result | Pester\Should -Contain $script:TestDirs[0]
        $result | Pester\Should -Contain $script:TestDirs[1]
    }

    Pester\It 'Does not add directories to the real (non-session) image collection when using -SessionOnly' {
        # Get the real (persistent) collection before adding session-only directories
        $realCollectionBefore = GenXdev.AI\Get-AIImageCollection

        # Add directories using session-only mode
        GenXdev.AI\Add-ImageDirectories -ImageDirectories $script:TestDirs -SessionOnly -Confirm:$false

        # Get the real (persistent) collection after adding session-only directories
        $realCollectionAfter = GenXdev.AI\Get-AIImageCollection -SkipSession

        # Assert the real collection is unchanged
        $realCollectionAfter | Pester\Should -Not -Contain $script:TestDirs[0]
        $realCollectionAfter | Pester\Should -Not -Contain $script:TestDirs[1]
    }

    Pester\AfterAll {
        # Restore both original collections to avoid side effects
        if ($null -ne $script:originalSessionCollection) {
            GenXdev.AI\Set-AIImageCollection -ImageDirectories $script:originalSessionCollection -SessionOnly -Confirm:$false
        }
        else {
            GenXdev.AI\Set-AIImageCollection -ImageDirectories @() -SessionOnly -Confirm:$false
        }

        if ($null -ne $script:originalRealCollection) {
            GenXdev.AI\Set-AIImageCollection -ImageDirectories $script:originalRealCollection -SkipSession -Confirm:$false
        }
        else {
            GenXdev.AI\Set-AIImageCollection -ImageDirectories @() -SkipSession -Confirm:$false
        }
    }
}
