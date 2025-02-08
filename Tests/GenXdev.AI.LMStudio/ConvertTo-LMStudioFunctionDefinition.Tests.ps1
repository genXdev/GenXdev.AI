Describe "ConvertTo-LMStudioFunctionDefinition" {

    It "Should check my sanity" {

        $number = 123;

        $callback = {

            param($a, $b, $c)

            return (@($a, $b, $c, $number) | ConvertTo-Json -Compress)

        }.GetNewClosure();

        $callback.getType().FullName | Should -BeExactly "System.Management.Automation.ScriptBlock"

        $params = @{
            c = 3
            a = 1
        }

        $params.getType().FullName | Should -BeExactly "System.Collections.Hashtable"

        $result = & $callback @params

        $result | Should -Be (@(1, $null, 3, $number) | ConvertTo-Json -Compress)
    }

    It "Should invoke function properly" {

        $functionDefinition = (ConvertTo-LMStudioFunctionDefinition -ExposedCmdLets (Get-Command -name Get-ChildItem))[0].function

        $functionDefinition | Should -Not -Be $null

        $callback = $functionDefinition.callback;

        $callback | Should -BeOfType [System.Management.Automation.CommandInfo]

        # Convert dictionary to proper parameter hashtable
        $params = @{"Path" = "b:\" }

        Write-Verbose "Final parameter hashtable: $($params | ConvertTo-Json)"

        # Use $functionDefinition instead of undefined $matchedFunc
        $callbackResult = & $callback @params | ConvertTo-Json -Compress
        $callbackResult | Should -BeLike "*Movies*"
    }

}