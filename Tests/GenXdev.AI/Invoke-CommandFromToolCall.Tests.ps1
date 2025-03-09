using module GenXdev.Helpers

Describe "Invoke-CommandFromToolCall cmdlet tests" {

    BeforeAll {
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
                        } | ConvertTo-Json
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

    It "should pass PSScriptAnalyzer rules" {
        # analyze main function implementation
        $scriptPath = "$PSScriptRoot\..\..\Functions\GenXdev.AI\" +
        "Invoke-CommandFromToolCall.ps1"

        Write-Verbose "Analyzing  $scriptPath"

        # Get settings to verify what's being passed
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath `
            -ErrorAction SilentlyContinue

        [string] $message = ""
        $analyzerResults | ForEach-Object {

            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@;
    }

    It "Should reject invalid parameters" {
        # create test call with invalid parameter
        $invalidCall = @{
            function = @{
                name      = "Get-Movies"
                arguments = '{"invalidParam":"test"}'
            }
        }

        $result = Invoke-CommandFromToolCall `
            -ToolCall $invalidCall `
            -Functions $Script:testFunctions

        $result.CommandExposed | Should -Be $false
        $result.Reason | Should -Not -BeNullOrEmpty
    }

    It "Should require confirmation by default" {
        # mock host UI for confirmation prompt
        Mock -CommandName "Write-Host" -ModuleName "GenXdev.AI"
        Mock -CommandName "Read-Host" -ModuleName "GenXdev.AI" -MockWith { return 'y' }

        $result = Invoke-CommandFromToolCall `
            -ToolCall $Script:testToolCall `
            -Functions $Script:testFunctions `
            -ExposedCmdLets $Script:testCmdlets

        $result.CommandExposed | Should -Be $true
        $result.Output | Should -Not -BeNullOrEmpty
    }

    It "Should handle missing required parameters" {
        # create test call without required parameter
        $invalidCall = @{
            function = @{
                name      = "Get-Movies"
                arguments = '{}'
            }
        }

        $result = Invoke-CommandFromToolCall `
            -ToolCall $invalidCall `
            -Functions $Script:testFunctions

        $result.CommandExposed | Should -Be $false
        $result.Reason | Should -BeLike "*Missing required parameter*"
    }

    It "Should execute command with proper output format" {
        $result = Invoke-CommandFromToolCall `
            -ToolCall $Script:testToolCall `
            -Functions $Script:testFunctions `
            -ExposedCmdLets $Script:testCmdlets `
            -NoConfirmationToolFunctionNames @("Get-Movies")

        # verify successful execution
        $result.CommandExposed | Should -Be $true
        $result.Output | Should -Not -BeNullOrEmpty

        # parse and verify JSON output
        $jsonOutput = $result.Output | ConvertFrom-Json
        $jsonOutput.movies | Should -Not -BeNullOrEmpty
        $jsonOutput.movies.Count | Should -Be 2
        $jsonOutput.movies[0] | Should -Be "Movie1"
        $jsonOutput.movies[1] | Should -Be "Movie2"
        $jsonOutput.path | Should -Be "B:\"
    }
}
