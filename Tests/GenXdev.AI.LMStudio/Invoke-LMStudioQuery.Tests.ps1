################################################################################
<#
.SYNOPSIS
Reverses the characters in a string

.DESCRIPTION
This function takes a string as input and reverses the order of the characters

.PARAMETER Text
The text to reverse
#>
function global:Invoke-ReverseText {

    param(
        [Parameter(
            Mandatory = $true,
            HelpMessage = "The text to reverse"
        )]
        [string]$Text
    )

    $result = [System.Text.StringBuilder]::new()

    # reverse the text
    for ($i = $Text.Length - 1; $i -ge 0; $i--) {

        $null = $result.Append($Text[$i] + "_")
    }

    return "$($result.ToString())".TrimEnd("_")
}

################################################################################

Describe "Invoke-LMStudioQuery tests" {
    BeforeAll {

        Import-Module -Name GenXdev.AI -Force
    }

    It "Should test the the callback functions and parameter passing on model qwen" {

        # define proper function format with callback
        $testFunctions = @(
            @{
                type     = "function"
                function = @{
                    name        = 'calculateMagicNumber'
                    description = 'Calculates the MagicNumber of two numbers.'
                    strict      = $true
                    parameters  = @{
                        type       = 'object'
                        properties = @{
                            b = @{ type = 'number' }
                            a = @{ type = 'number' }
                        }
                        required   = @('a', 'b')
                    }
                    # important: callback is required for function execution
                    callback    = {
                        param([int] $b, [int] $a)

                        return ((($a * $b) + 181824) + ($b - $a))
                    }
                }
            }
        )

        # execute function with test data
        $result = Invoke-LMStudioQuery `
            -Verbose `
            -Model "qwen2.5-14b-instruct" `
            -Instructions "You are a helpful assistant" `
            -Query "Get the magic number using the 'calculateMagicNumber' function, for parameter a use 42 and for b use 9234" `
            -Functions $testFunctions `
            -NoConfirmationFor calculateMagicNumber `
            -MaxToken 32768

        "$result".Replace(",", "") | Should -BeLike "*578844*"

        Write-Verbose "Result: $result"
    }

    It "Should test the the callback functions and parameter passing on model llama-3-groq-8b-tool-use" {

        # define proper function format with callback
        $testFunctions = @(
            @{
                type     = "function"
                function = @{
                    name        = 'calculateMagicNumber'
                    description = 'Calculates the MagicNumber of two numbers.'
                    strict      = $true
                    parameters  = @{
                        type       = 'object'
                        properties = @{
                            a = @{ type = 'number' }
                            b = @{ type = 'number' }
                        }
                        required   = @('a', 'b')
                    }
                    # important: callback is required for function execution
                    callback    = {
                        param([int] $a, [int] $b)

                        return ((($a * $b) + 142311) + ($b - $a))
                    }
                }
            }
        )

        # execute function with test data
        $result = Invoke-LMStudioQuery `
            -Verbose `
            -Model "llama-3-groq-8b-tool-use" `
            -Instructions "You are a helpful assistant" `
            -Query "Get the magic number using the 'calculateMagicNumber' function, for parameter a use 5124 and for b use 134" `
            -Functions $testFunctions `
            -NoConfirmationFor calculateMagicNumber `
            -MaxToken 8192

        "$result".Replace(",", "") | Should -BeLike "*823937*"

        Write-Verbose "Result: $result"
    }

    It "Should test the the callback functions on model qwen" {

        # execute function with test data
        $result = Invoke-LMStudioQuery `
            -Model "qwen2.5-14b-instruct" `
            -Instructions "You are a helpful assistant" `
            -Query "Reverse the text using the 'Invoke-ReverseText' tool function, for parameter 'Text' use the value 'Hello world'" `
            -ExposedCmdLets (Get-Command Invoke-ReverseText) `
            -NoConfirmationFor Invoke-ReverseText `
            -MaxToken 32768

        "$result".Replace(",", "") | Should -BeLike "*d_l_r_o_w_ _o_l_l_e_H*"

        Write-Verbose "Result: $result"
    }

    It "Should test the the callback functions on model llama-3-groq-8b-tool-use" {

        # execute function with test data
        $result = Invoke-LMStudioQuery `
            -Verbose `
            -Model "llama-3-groq-8b-tool-use" `
            -Instructions "You are a helpful assistant" `
            -Query "Reverse the text using the 'Invoke-ReverseText' tool function, for parameter 'Text' use the value 'Welcome back'" `
            -ExposedCmdLets (Get-Command Invoke-ReverseText) `
            -NoConfirmationFor Invoke-ReverseText `
            -MaxToken 100

        "$result".Replace(",", "") | Should -BeLike "*k_c_a_b_ _e_m_o_c_l_e_W*"

        Write-Verbose "Result: $result"
    }
}
################################################################################
