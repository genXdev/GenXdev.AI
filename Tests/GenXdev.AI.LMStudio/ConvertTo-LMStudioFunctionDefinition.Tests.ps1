Describe "ConvertTo-LMStudioFunctionDefinition" {

    It "Should pass PSScriptAnalyzer rules" {

        # get the script path for analysis
        $scriptPath = GenXdev.FileSystem\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.AI.LMStudio\ConvertTo-LMStudioFunctionDefinition.ps1"

        # run analyzer with explicit settings
        $analyzerResults = GenXdev.Coding\Invoke-GenXdevScriptAnalyzer `
            -Path $scriptPath

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

    It "Should check my sanity" {

        $number = 123;

        $callback = {

            param($a, $b, $c)

            return (@($a, $b, $c, $number) | ConvertTo-Json -Compress -WarningAction SilentlyContinue)

        }.GetNewClosure();

        $callback.getType().FullName | Should -BeExactly "System.Management.Automation.ScriptBlock"

        $params = @{
            c = 3
            a = 1
        }

        $params.getType().FullName | Should -BeExactly "System.Collections.Hashtable"

        $result = & $callback @params

        $result | Should -Be (@(1, $null, 3, $number) | ConvertTo-Json -Compress -WarningAction SilentlyContinue)
    }

    It "Should invoke function properly" {

        $converted = ConvertTo-LMStudioFunctionDefinition `
            -ExposedCmdLets @(
            @{
                Name          = "Get-ChildItem"
                AllowedParams = @("Path=string")
                Confirm       = $false
            }
        )

        $functionDefinition = $converted.function

        $functionDefinition | Should -Not -Be $null

        $callback = $functionDefinition.callback;

        $callback | Should -BeOfType [System.Management.Automation.CommandInfo]

        # Convert dictionary to proper parameter hashtable
        $params = @{"Path" = "B:\" }

        Write-Verbose "Final parameter hashtable: $($params | ConvertTo-Json -WarningAction SilentlyContinue)"

        # Use $functionDefinition instead of undefined $matchedFunc
        $callbackResult = & $callback @params | ConvertTo-Json -Compress -WarningAction SilentlyContinue
        $callbackResult | Should -BeLike "*Movies*"
    }
}