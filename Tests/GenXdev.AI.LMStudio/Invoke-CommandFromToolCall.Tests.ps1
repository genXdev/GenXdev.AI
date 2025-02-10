################################################################################
Describe "Invoke-CommandFromToolCall parameter validation tests" {

    BeforeAll {

        # import required module
        Import-Module -Name GenXdev.AI -Force

        $ExposedCmdLets = @(
            @{
                Name          = "Get-ChildItem";
                AllowedParams = @("Path=string")
                Confirm       = $false
            }
        );

        $ToolCall = @{
            id       = "339160998"
            type     = "function"
            function = @{
                name      = "Get-ChildItem"
                arguments = "{`"Path`":`"B:\\`"}"
            }
        }

        [System.Collections.Generic.List[object]] $Functions = @(ConvertTo-LMStudioFunctionDefinition `
                -ExposedCmdLets:$ExposedCmdLets `
        )
    }

    It "Should execute command with basic parameters" {

        # generate command using LM-Studio with exposed cmdlet
        [GenXdev.Helpers.ExposedToolCallInvocationResult] $result = Invoke-CommandFromToolCall `
            -ToolCall $ToolCall `
            -Functions $Functions `
            -ExposedCmdLets $ExposedCmdLets | Select-Object -First 1

        $result.CommandExposed | Should -Be $true
        [string]::IsNullOrWhiteSpace($result.Reason) | Should -Be $true
        $result.FilteredArguments.Path | Should -Be "B:\"
        $result.UnfilteredArguments.Path | Should -Be "B:\"
        $result.Output | Should -BeLike "*Movies*"
    }
}
################################################################################
