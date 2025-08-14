Pester\Describe 'ConvertTo-LMStudioFunctionDefinition' {

    Pester\It 'Should check my sanity' {

        $number = 123;

        $callback = {

            param($a, $b, $c)

            return (@($a, $b, $c, $number) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue)

        }.GetNewClosure();

        $callback.getType().FullName | Pester\Should -BeExactly 'System.Management.Automation.ScriptBlock'

        $params = @{
            c = 3
            a = 1
        }

        $params.getType().FullName | Pester\Should -BeExactly 'System.Collections.Hashtable'

        $result = & $callback @params

        $result | Pester\Should -Be (@(1, $null, 3, $number) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue)
    }

    Pester\It 'Should invoke function properly' {

        $converted = GenXdev.AI\ConvertTo-LMStudioFunctionDefinition `
            -ExposedCmdLets @(
            @{
                Name          = 'Get-ChildItem'
                AllowedParams = @('Path=string')
                Confirm       = $false
            }
        )

        $functionDefinition = $converted.function

        $functionDefinition | Pester\Should -Not -Be $null

        $callback = $functionDefinition.callback;

        $callback | Pester\Should -BeOfType [System.Management.Automation.CommandInfo]

        # Convert dictionary to proper parameter hashtable
        $params = @{'Path' = "$PSScriptRoot" }

        Microsoft.PowerShell.Utility\Write-Verbose "Final parameter hashtable: $($params | Microsoft.PowerShell.Utility\ConvertTo-Json -WarningAction SilentlyContinue)"

        # Use $functionDefinition instead of undefined $matchedFunc
        $callbackResult = & $callback @params | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue
        $callbackResult | Pester\Should -BeLike '*ConvertTo-LMStudioFunctionDefinition.Tests.ps1*'
    }
}