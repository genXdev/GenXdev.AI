################################################################################

function Invoke-AIPowershellCommand {

    [CmdletBinding()]
    [Alias("hint")]

    param (
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "The query string for the LLM."
        )]
        [ValidateNotNullOrEmpty()]
        [string]$Query,
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = "The LM-Studio model to use for generating the response.")]
        [PSDefaultValue(Value = "llama")]
        [string]$Model = "llama",

        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = "The temperature parameter for controlling the randomness of the response."
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $Temperature = 0.01,

        [Parameter(
            Mandatory = $false,
            HelpMessage = "Only set clipboard"
        )]
        [switch] $Clipboard
    )

    begin {
        $Instructions = "
take the user prompt as an instruction to generate a powershell commandline that does exactly what is requested and implement the latest best-practises when it comes to the latest PowerShell Core.
return nothing like chatter, markdown or anything besides a json string holding an object with a single response string property.
your output is always in the format: {`"response`":`"# powershell commandline here`"}
if prompt references the clipboard, use the following clipboard content: $("$(Get-Clipboard)" | ConvertTo-Json -Compress -Depth 1)
";
    }

    process {

        $result = (Invoke-LMStudioQuery `
                -Query:$Query `
                -Model:$Model `
                -Temperature:$Temperature `
                -Instructions:$Instructions | `

            ConvertFrom-Json).response

        if ($Clipboard) {
            $result | Set-Clipboard
        }
        else {
            $w = Get-PowershellMainWindow
            if ($null -ne $w) {

                $w.SetForeground();
            }

            Send-Keys ("`r`n$result".Replace("`r`n", " ``+{ENTER}"))
        }
    }
}
