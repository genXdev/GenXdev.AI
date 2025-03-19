using module GenXdev.Helpers

Pester\Describe "Invoke-CommandFromToolCall cmdlet tests" {

    Pester\BeforeAll {
        # store test variables in script scope
        $Script:testFunctions = @(
            @{
                function = @{
                    name       = "Get-Movies"
                    parameters = @{
                        required   = @("path")
                        properties = @{
                            path = @{ type = "string" }
                        }
                    }
                    # fixed callback to return proper movie data
                    callback   = {
                        param($path)
                        return @{
                            movies = @(
                                "Movie1",
                                "Movie2"
                            )
                            path   = $path
                        } | Microsoft.PowerShell.Utility\ConvertTo-Json
                    }
                }
            }
        )

        $Script:testCmdlets = @(
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name          = "Get-Movies"
                AllowedParams = @("path")
                Confirm       = $false
            }
        )

        $Script:testToolCall = @{
            function = @{
                name      = "Get-Movies"
                arguments = '{"path":"B:\\"}'
            }
        }
    }

    Pester\It "Should pass PSScriptAnalyzer rules" {
        # analyze main function implementation
        $scriptPath = "$PSScriptRoot\..\..\Functions\GenXdev.AI\" +
        "Invoke-CommandFromToolCall.ps1"

        Microsoft.PowerShell.Utility\Write-Verbose "Analyzing  $scriptPath"

        # Get settings to verify what's being passed
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath `
            -ErrorAction SilentlyContinue

        [string] $message = ""
        $analyzerResults | Microsoft.PowerShell.Core\ForEach-Object {

            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Pester\Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@;
    }

    Pester\It "Should reject invalid parameters" {
        # create test call with invalid parameter
        $invalidCall = @{
            function = @{
                name      = "Get-Movies"
                arguments = '{"invalidParam":"test"}'
            }
        }

        $result = GenXdev.AI\Invoke-CommandFromToolCall `
            -ToolCall $invalidCall `
            -Functions $Script:testFunctions

        $result.CommandExposed | Pester\Should -Be $false
        $result.Reason | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It "Should require confirmation by default" {
        # mock host UI for confirmation prompt
        Pester\Mock -CommandName "Write-Host" -ModuleName "GenXdev.AI"
        Pester\Mock -CommandName "Read-Host" -ModuleName "GenXdev.AI" -MockWith { return 'y' }

        $result = GenXdev.AI\Invoke-CommandFromToolCall `
            -ToolCall $Script:testToolCall `
            -Functions $Script:testFunctions `
            -ExposedCmdLets $Script:testCmdlets

        $result.CommandExposed | Pester\Should -Be $true
        $result.Output | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It "Should handle missing required parameters" {
        # create test call without required parameter
        $invalidCall = @{
            function = @{
                name      = "Get-Movies"
                arguments = '{}'
            }
        }

        $result = GenXdev.AI\Invoke-CommandFromToolCall `
            -ToolCall $invalidCall `
            -Functions $Script:testFunctions

        $result.CommandExposed | Pester\Should -Be $false
        $result.Reason | Pester\Should -BeLike "*Missing required parameter*"
    }

    Pester\It "Should execute command with proper output format" {
        $result = GenXdev.AI\Invoke-CommandFromToolCall `
            -ToolCall $Script:testToolCall `
            -Functions $Script:testFunctions `
            -ExposedCmdLets $Script:testCmdlets `
            -NoConfirmationToolFunctionNames @("Get-Movies")

        # verify successful execution
        $result.CommandExposed | Pester\Should -Be $true
        $result.Output | Pester\Should -Not -BeNullOrEmpty

        # parse and verify JSON output
        $jsonOutput = $result.Output | Microsoft.PowerShell.Utility\ConvertFrom-Json
        $jsonOutput.movies | Pester\Should -Not -BeNullOrEmpty
        $jsonOutput.movies.Count | Pester\Should -Be 2
        $jsonOutput.movies[0] | Pester\Should -Be "Movie1"
        $jsonOutput.movies[1] | Pester\Should -Be "Movie2"
        $jsonOutput.path | Pester\Should -Be "B:\"
    }
}