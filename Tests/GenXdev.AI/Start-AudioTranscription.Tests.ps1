################################################################################
BeforeAll {

    # create test paths
    $script:testRoot = Expand-Path "${env:TEMP}\Start-AudioTranscriptionTests\" -CreateDirectory
    $script:testWaveFile = Expand-Path "$PSScriptRoot\escalated-quickly.wav"

    # ensure test directory exists
    if (-not (Test-Path ($Script:testRoot))) {
        New-Item -ItemType Directory -Path ($Script:testRoot) | Out-Null
    }

    # Mock the module
    Mock -CommandName Get-SpeechToText -ModuleName GenXdev.AI
}

################################################################################
AfterAll {
    # cleanup test directory
    if (Test-Path ($Script:testRoot)) {

        Remove-AllItems ($Script:testRoot) -DeleteFolder
    }
}

################################################################################
Describe "Start-AudioTranscription" {

    It "Should use default language when not specified" {
        # Call the function with explicit module scope
        & "GenXdev.AI\Start-AudioTranscription"

        Should -Invoke Get-SpeechToText -ModuleName GenXdev.AI -ParameterFilter {
            $Language -eq "English"
        }
    }
}
################################################################################
