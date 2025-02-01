################################################################################

function Get-FactSheetOfSubject {

    [CmdletBinding()]
    [Alias("facts")]

    param(
        [Parameter(
            Position = 0,
            Mandatory,
            HelpMessage = "The subject to create a fact sheet for."
        )]
        [string] $Query
    )

    $result = qlms -Instructions "create a fact sheet of the subject that is described in the request. Mention as many facts and properties about the subject that you know, but always keep it factual with well established facts. Each fact must have a single string as name that is used as the key inside the json object you return, it's value is a string with the fact description e.g: `"{`"Color`":`"Light blue`",`"Otherfacts`",`"etc..`"} don't add any markdown, just plain json." -Query "$Query"

    Write-Verbose $result

    $a = "$result" -split "(\{(.*)`})|(\[(.*)`])";

    for ($i = 0; $i -lt $a.length; $i++) {

        try {

            $newResult = $PSItem | ConvertFrom-Json

            if ($result -is [string]) {

                $result = [list[string]] @($result, $newResult);
            }
            else {

                $result.Add($newResult);
            }
        }
        catch {
        }
    }

    $result
}
